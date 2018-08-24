Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Fri, 24 Aug 2018 09:16:33 -0700
Message-Id: <20180824161642.1144-2-ebiggers@kernel.org>
In-Reply-To: <20180824161642.1144-1-ebiggers@kernel.org>
References: <20180824161642.1144-1-ebiggers@kernel.org>
Subject: [f2fs-dev] [RFC PATCH 01/10] fs-verity: add setup code, UAPI,
 and Kconfig
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-integrity@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fs-verity is a filesystem feature that provides efficient, transparent
integrity verification and authentication of read-only files.  It uses a
dm-verity like mechanism at the file level: a Merkle tree hidden past
the end of the file is used to verify any block in the file in
log(filesize) time.  It is implemented mainly by helper functions in
fs/verity/ that will be shared by multiple filesystems.

Essentially, fs-verity reports a file's hash in constant time, but reads
that would violate that hash fail at runtime.  This is useful when only
a portion of the file is actually accessed, as only the accessed portion
has to be hashed, and the latency to the first read is much reduced over
a full file hash.  On top of this hashing mechanism, auditing or
authentication policies can be implemented to log or verify file hashes.

Note that in general, fs-verity is *not* a replacement for IMA.
fs-verity is a lower-level feature, primarily a way to hash a file;
whereas IMA deals more with higher-level policy logic, like defining
which files are "measured" and what to do with those measurements.  We
plan for IMA to support fs-verity measurements as an alternative to the
traditional full file hash.  Still, some users find fs-verity useful by
itself, so it's also usable without IMA in simple cases, e.g. in cases
where just retrieving the file measurement via an ioctl is enough.

A structure containing the properties of the Merkle tree -- such as the
hash algorithm used, the block size, and the root hash -- is also stored
on-disk, following the Merkle tree.  The actual file measurement hash
that fs-verity reports is the hash of this structure.

All fs-verity metadata is written by userspace; the kernel only reads
it.  Extended attributes aren't used because the Merkle tree may be much
larger than XATTR_SIZE_MAX, we want the hash pages to be cached in the
page cache as usual, and in the case of fs-verity combined with fscrypt
we want the metadata to be encrypted to avoid leaking plaintext hashes.
The fs-verity metadata is hidden from userspace by overriding the i_size
of the in-memory VFS inode; ext4 additionally will override the on-disk
i_size in order to make verity a RO_COMPAT filesystem feature.

This initial patch only adds the fs-verity Kconfig option, UAPI, and
setup code, e.g. the ->open() hook that parses the fs-verity descriptor.
The actual ->readpages() data verification, the ioctls, ext4 and f2fs
support, and other functionality comes in later patches.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/Kconfig                    |   2 +
 fs/Makefile                   |   1 +
 fs/verity/Kconfig             |  36 ++
 fs/verity/Makefile            |   3 +
 fs/verity/fsverity_private.h  |  99 ++++
 fs/verity/hash_algs.c         | 106 +++++
 fs/verity/setup.c             | 846 ++++++++++++++++++++++++++++++++++
 include/linux/fs.h            |   9 +
 include/linux/fsverity.h      |  62 +++
 include/uapi/linux/fsverity.h |  86 ++++
 10 files changed, 1250 insertions(+)
 create mode 100644 fs/verity/Kconfig
 create mode 100644 fs/verity/Makefile
 create mode 100644 fs/verity/fsverity_private.h
 create mode 100644 fs/verity/hash_algs.c
 create mode 100644 fs/verity/setup.c
 create mode 100644 include/linux/fsverity.h
 create mode 100644 include/uapi/linux/fsverity.h

diff --git a/fs/Kconfig b/fs/Kconfig
index ac474a61be379..ddadc4e999429 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -105,6 +105,8 @@ config MANDATORY_FILE_LOCKING
 
 source "fs/crypto/Kconfig"
 
+source "fs/verity/Kconfig"
+
 source "fs/notify/Kconfig"
 
 source "fs/quota/Kconfig"
diff --git a/fs/Makefile b/fs/Makefile
index 293733f61594b..10b37f651ffde 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -32,6 +32,7 @@ obj-$(CONFIG_USERFAULTFD)	+= userfaultfd.o
 obj-$(CONFIG_AIO)               += aio.o
 obj-$(CONFIG_FS_DAX)		+= dax.o
 obj-$(CONFIG_FS_ENCRYPTION)	+= crypto/
+obj-$(CONFIG_FS_VERITY)		+= verity/
 obj-$(CONFIG_FILE_LOCKING)      += locks.o
 obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
 obj-$(CONFIG_BINFMT_AOUT)	+= binfmt_aout.o
diff --git a/fs/verity/Kconfig b/fs/verity/Kconfig
new file mode 100644
index 0000000000000..308d733a9401b
--- /dev/null
+++ b/fs/verity/Kconfig
@@ -0,0 +1,36 @@
+config FS_VERITY
+	tristate "FS Verity (file-based integrity/authentication)"
+	depends on BLOCK
+	select CRYPTO
+	# SHA-256 is selected as it's intended to be the default hash algorithm.
+	# To avoid bloat, other wanted algorithms must be selected explicitly.
+	select CRYPTO_SHA256
+	help
+	  This option enables fs-verity.  fs-verity is the dm-verity
+	  mechanism implemented at the file level.  On supported
+	  filesystems, userspace can append a Merkle tree (hash tree) to
+	  a file, then enable fs-verity on the file.  The filesystem
+	  will then transparently verify any data read from the file
+	  against the Merkle tree.  The file is also made read-only.
+
+	  This serves as an integrity check, but the availability of the
+	  Merkle tree root hash also allows efficiently supporting
+	  various use cases where normally the whole file would need to
+	  be hashed at once, such as: (a) auditing (logging the file's
+	  hash), or (b) authenticity verification (comparing the hash
+	  against a known good value, e.g. from a digital signature).
+
+	  fs-verity is especially useful on large files where not all
+	  the contents may actually be needed.  Also, fs-verity verifies
+	  data each time it is paged back in, which provides better
+	  protection against malicious disks vs. an ahead-of-time hash.
+
+	  If unsure, say N.
+
+config FS_VERITY_DEBUG
+	bool "FS Verity debugging"
+	depends on FS_VERITY
+	help
+	  Enable debugging messages related to fs-verity by default.
+
+	  Say N unless you are an fs-verity developer.
diff --git a/fs/verity/Makefile b/fs/verity/Makefile
new file mode 100644
index 0000000000000..39e123805c827
--- /dev/null
+++ b/fs/verity/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_FS_VERITY)	+= fsverity.o
+
+fsverity-y := hash_algs.o setup.o
diff --git a/fs/verity/fsverity_private.h b/fs/verity/fsverity_private.h
new file mode 100644
index 0000000000000..a18ff645695f4
--- /dev/null
+++ b/fs/verity/fsverity_private.h
@@ -0,0 +1,99 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * fs-verity: read-only file-based integrity/authentication
+ *
+ * Copyright (C) 2018 Google LLC
+ */
+
+#ifndef _FSVERITY_PRIVATE_H
+#define _FSVERITY_PRIVATE_H
+
+#ifdef CONFIG_FS_VERITY_DEBUG
+#define DEBUG
+#endif
+
+#define pr_fmt(fmt) "fs-verity: " fmt
+
+#include <crypto/sha.h>
+#define __FS_HAS_VERITY 1
+#include <linux/fsverity.h>
+
+/*
+ * Maximum depth of the Merkle tree.  Up to 64 levels are theoretically possible
+ * with a very small block size, but we'd like to limit stack usage during
+ * verification, and in practice this is plenty.  E.g., with SHA-256 and 4K
+ * blocks, a file with size UINT64_MAX bytes needs just 8 levels.
+ */
+#define FS_VERITY_MAX_LEVELS		16
+
+/*
+ * Largest digest size among all hash algorithms supported by fs-verity.  This
+ * can be increased if needed.
+ */
+#define FS_VERITY_MAX_DIGEST_SIZE	SHA256_DIGEST_SIZE
+
+/* A hash algorithm supported by fs-verity */
+struct fsverity_hash_alg {
+	struct crypto_ahash *tfm; /* allocated on demand */
+	const char *name;
+	unsigned int digest_size;
+	bool cryptographic;
+};
+
+/**
+ * fsverity_info - cached verity metadata for an inode
+ *
+ * When a verity file is first opened, an instance of this struct is allocated
+ * and stored in ->i_verity_info.  It caches various values from the verity
+ * metadata, such as the tree topology and the root hash, which are needed to
+ * efficiently verify data read from the file.  Once created, it remains until
+ * the inode is evicted.
+ *
+ * (The tree pages themselves are not cached here, though they may be cached in
+ * the inode's page cache.)
+ */
+struct fsverity_info {
+	const struct fsverity_hash_alg *hash_alg; /* hash algorithm */
+	u8 block_bits;			/* log2(block size) */
+	u8 log_arity;			/* log2(hashes per hash block) */
+	u8 depth;			/* depth of the Merkle tree */
+	u8 *hashstate;			/* salted initial hash state */
+	u64 data_i_size;		/* original file size */
+	u64 full_i_size;		/* full file size including metadata */
+	u8 root_hash[FS_VERITY_MAX_DIGEST_SIZE];   /* Merkle tree root hash */
+	u8 measurement[FS_VERITY_MAX_DIGEST_SIZE]; /* file measurement */
+	bool have_root_hash;		/* have root hash from disk? */
+
+	/* Starting blocks for each tree level. 'depth-1' is the root level. */
+	u64 hash_lvl_region_idx[FS_VERITY_MAX_LEVELS];
+};
+
+/* hash_algs.c */
+extern struct fsverity_hash_alg fsverity_hash_algs[];
+const struct fsverity_hash_alg *fsverity_get_hash_alg(unsigned int num);
+void __init fsverity_check_hash_algs(void);
+void __exit fsverity_exit_hash_algs(void);
+
+/* setup.c */
+struct fsverity_info *create_fsverity_info(struct inode *inode, bool enabling);
+void free_fsverity_info(struct fsverity_info *vi);
+
+static inline struct fsverity_info *get_fsverity_info(const struct inode *inode)
+{
+	/* pairs with cmpxchg_release() in set_fsverity_info() */
+	return smp_load_acquire(&inode->i_verity_info);
+}
+
+static inline bool set_fsverity_info(struct inode *inode,
+				     struct fsverity_info *vi)
+{
+	/* pairs with smp_load_acquire() in get_fsverity_info() */
+	if (cmpxchg_release(&inode->i_verity_info, NULL, vi) != NULL)
+		return false;
+
+	/* Set the in-memory i_size to the data size */
+	i_size_write(inode, vi->data_i_size);
+	return true;
+}
+
+#endif /* _FSVERITY_PRIVATE_H */
diff --git a/fs/verity/hash_algs.c b/fs/verity/hash_algs.c
new file mode 100644
index 0000000000000..424a26ee2f3c2
--- /dev/null
+++ b/fs/verity/hash_algs.c
@@ -0,0 +1,106 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * fs/verity/hash_algs.c: fs-verity hash algorithm management
+ *
+ * Copyright (C) 2018 Google LLC
+ *
+ * Written by Eric Biggers.
+ */
+
+#include "fsverity_private.h"
+
+#include <crypto/hash.h>
+
+/* The list of hash algorithms supported by fs-verity */
+struct fsverity_hash_alg fsverity_hash_algs[] = {
+	[FS_VERITY_ALG_SHA256] = {
+		.name = "sha256",
+		.digest_size = 32,
+		.cryptographic = true,
+	},
+};
+
+/*
+ * Translate the given fs-verity hash algorithm number into a struct describing
+ * the algorithm, and ensure it has a hash transform ready to go.  The hash
+ * transforms are allocated on-demand firstly to not waste resources when they
+ * aren't needed, and secondly because the fs-verity module may be loaded
+ * earlier than the needed crypto modules.
+ */
+const struct fsverity_hash_alg *fsverity_get_hash_alg(unsigned int num)
+{
+	struct fsverity_hash_alg *alg;
+	struct crypto_ahash *tfm;
+	int err;
+
+	if (num >= ARRAY_SIZE(fsverity_hash_algs) ||
+	    !fsverity_hash_algs[num].digest_size) {
+		pr_warn("Unknown hash algorithm: %u\n", num);
+		return ERR_PTR(-EINVAL);
+	}
+	alg = &fsverity_hash_algs[num];
+retry:
+	/* pairs with cmpxchg_release() below */
+	tfm = smp_load_acquire(&alg->tfm);
+	if (tfm)
+		return alg;
+	/*
+	 * Using the shash API would make things a bit simpler, but the ahash
+	 * API is preferable as it allows the use of crypto accelerators.
+	 */
+	tfm = crypto_alloc_ahash(alg->name, 0, 0);
+	if (IS_ERR(tfm)) {
+		if (PTR_ERR(tfm) == -ENOENT)
+			pr_warn("Algorithm %u (%s) is unavailable\n",
+				num, alg->name);
+		else
+			pr_warn("Error allocating algorithm %u (%s): %ld\n",
+				num, alg->name, PTR_ERR(tfm));
+		return ERR_CAST(tfm);
+	}
+
+	err = -EINVAL;
+	if (WARN_ON(alg->digest_size != crypto_ahash_digestsize(tfm)))
+		goto err_free_tfm;
+
+	pr_info("%s using implementation \"%s\"\n", alg->name,
+		crypto_hash_alg_common(tfm)->base.cra_driver_name);
+
+	/* pairs with smp_load_acquire() above */
+	if (cmpxchg_release(&alg->tfm, NULL, tfm) != NULL) {
+		crypto_free_ahash(tfm);
+		goto retry;
+	}
+
+	return alg;
+
+err_free_tfm:
+	crypto_free_ahash(tfm);
+	return ERR_PTR(err);
+}
+
+void __init fsverity_check_hash_algs(void)
+{
+	int i;
+
+	/*
+	 * Sanity check the digest sizes (could be a build-time check, but
+	 * they're in an array)
+	 */
+	for (i = 0; i < ARRAY_SIZE(fsverity_hash_algs); i++) {
+		struct fsverity_hash_alg *alg = &fsverity_hash_algs[i];
+
+		if (!alg->digest_size)
+			continue;
+		BUG_ON(alg->digest_size > FS_VERITY_MAX_DIGEST_SIZE);
+		BUG_ON(!is_power_of_2(alg->digest_size));
+	}
+}
+
+void __exit fsverity_exit_hash_algs(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(fsverity_hash_algs); i++)
+		crypto_free_ahash(fsverity_hash_algs[i].tfm);
+}
diff --git a/fs/verity/setup.c b/fs/verity/setup.c
new file mode 100644
index 0000000000000..e675c52898d5b
--- /dev/null
+++ b/fs/verity/setup.c
@@ -0,0 +1,846 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * fs/verity/setup.c: fs-verity module initialization and descriptor parsing
+ *
+ * Copyright (C) 2018 Google LLC
+ *
+ * Originally written by Jaegeuk Kim and Michael Halcrow;
+ * heavily rewritten by Eric Biggers.
+ */
+
+#include "fsverity_private.h"
+
+#include <crypto/hash.h>
+#include <linux/highmem.h>
+#include <linux/list_sort.h>
+#include <linux/module.h>
+#include <linux/pagemap.h>
+#include <linux/scatterlist.h>
+#include <linux/vmalloc.h>
+
+static struct kmem_cache *fsverity_info_cachep;
+
+static void dump_fsverity_descriptor(const struct fsverity_descriptor *desc)
+{
+	pr_debug("magic = %.*s\n", (int)sizeof(desc->magic), desc->magic);
+	pr_debug("major_version = %u\n", desc->major_version);
+	pr_debug("minor_version = %u\n", desc->minor_version);
+	pr_debug("log_data_blocksize = %u\n", desc->log_data_blocksize);
+	pr_debug("log_tree_blocksize = %u\n", desc->log_tree_blocksize);
+	pr_debug("data_algorithm = %u\n", le16_to_cpu(desc->data_algorithm));
+	pr_debug("tree_algorithm = %u\n", le16_to_cpu(desc->tree_algorithm));
+	pr_debug("flags = %#x\n", le32_to_cpu(desc->flags));
+	pr_debug("orig_file_size = %llu\n", le64_to_cpu(desc->orig_file_size));
+	pr_debug("auth_ext_count = %u\n", le16_to_cpu(desc->auth_ext_count));
+}
+
+/* Precompute the salted initial hash state */
+static int set_salt(struct fsverity_info *vi, const u8 *salt, size_t saltlen)
+{
+	struct crypto_ahash *tfm = vi->hash_alg->tfm;
+	struct ahash_request *req;
+	unsigned int reqsize = sizeof(*req) + crypto_ahash_reqsize(tfm);
+	struct scatterlist sg;
+	DECLARE_CRYPTO_WAIT(wait);
+	u8 *saltbuf;
+	int err;
+
+	vi->hashstate = kmalloc(crypto_ahash_statesize(tfm), GFP_KERNEL);
+	if (!vi->hashstate)
+		return -ENOMEM;
+	/* On error, vi->hashstate is freed by free_fsverity_info() */
+
+	/*
+	 * Allocate a hash request buffer.  Also reserve space for a copy of
+	 * the salt, since the given 'salt' may point into vmap'ed memory, so
+	 * sg_init_one() may not work on it.
+	 */
+	req = kmalloc(reqsize + saltlen, GFP_KERNEL);
+	if (!req)
+		return -ENOMEM;
+	saltbuf = (u8 *)req + reqsize;
+	memcpy(saltbuf, salt, saltlen);
+	sg_init_one(&sg, saltbuf, saltlen);
+
+	ahash_request_set_tfm(req, tfm);
+	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP |
+				   CRYPTO_TFM_REQ_MAY_BACKLOG,
+				   crypto_req_done, &wait);
+	ahash_request_set_crypt(req, &sg, NULL, saltlen);
+
+	err = crypto_wait_req(crypto_ahash_init(req), &wait);
+	if (err)
+		goto out;
+	err = crypto_wait_req(crypto_ahash_update(req), &wait);
+	if (err)
+		goto out;
+	err = crypto_ahash_export(req, vi->hashstate);
+out:
+	kfree(req);
+	return err;
+}
+
+/*
+ * Copy in the root hash stored on disk.
+ *
+ * Note that the root hash could be computed by hashing the root block of the
+ * Merkle tree.  But it works out a bit simpler to store the hash separately;
+ * then it gets included in the file measurement without special-casing it, and
+ * the root block gets verified on the ->readpages() path like the other blocks.
+ */
+static int parse_root_hash_extension(struct fsverity_info *vi,
+				     const void *hash, size_t size)
+{
+	const struct fsverity_hash_alg *alg = vi->hash_alg;
+
+	if (vi->have_root_hash) {
+		pr_warn("Multiple root hashes were found!\n");
+		return -EINVAL;
+	}
+	if (size != alg->digest_size) {
+		pr_warn("Wrong root hash size; got %zu bytes, but expected %u for hash algorithm %s\n",
+			size, alg->digest_size, alg->name);
+		return -EINVAL;
+	}
+	memcpy(vi->root_hash, hash, size);
+	vi->have_root_hash = true;
+	pr_debug("Root hash: %s:%*phN\n", alg->name,
+		 alg->digest_size, vi->root_hash);
+	return 0;
+}
+
+static int parse_salt_extension(struct fsverity_info *vi,
+				const void *salt, size_t saltlen)
+{
+	if (vi->hashstate) {
+		pr_warn("Multiple salts were found!\n");
+		return -EINVAL;
+	}
+	return set_salt(vi, salt, saltlen);
+}
+
+/* The available types of extensions (variable-length metadata items) */
+static const struct extension_type {
+	int (*parse)(struct fsverity_info *vi, const void *_ext,
+		     size_t extra_len);
+	size_t base_len;      /* length of fixed-size part of payload, if any */
+	bool unauthenticated; /* true if not included in file measurement */
+} extension_types[] = {
+	[FS_VERITY_EXT_ROOT_HASH] = {
+		.parse = parse_root_hash_extension,
+	},
+	[FS_VERITY_EXT_SALT] = {
+		.parse = parse_salt_extension,
+	},
+};
+
+static int do_parse_extensions(struct fsverity_info *vi,
+			       const struct fsverity_extension **ext_hdr_p,
+			       const void *end, int count, bool authenticated)
+{
+	const struct fsverity_extension *ext_hdr = *ext_hdr_p;
+	int i;
+	int err;
+
+	for (i = 0; i < count; i++) {
+		const struct extension_type *type;
+		u32 len, rounded_len;
+		u16 type_code;
+
+		if (end - (const void *)ext_hdr < sizeof(*ext_hdr)) {
+			pr_warn("Extension list overflows buffer\n");
+			return -EINVAL;
+		}
+		type_code = le16_to_cpu(ext_hdr->type);
+		if (type_code >= ARRAY_SIZE(extension_types) ||
+		    !extension_types[type_code].parse) {
+			pr_warn("Unknown extension type: %u\n", type_code);
+			return -EINVAL;
+		}
+		type = &extension_types[type_code];
+		if (authenticated != !type->unauthenticated) {
+			pr_warn("Extension type %u must be %sauthenticated\n",
+				type_code, type->unauthenticated ? "un" : "");
+			return -EINVAL;
+		}
+		if (ext_hdr->reserved) {
+			pr_warn("Reserved bits set in extension header\n");
+			return -EINVAL;
+		}
+		len = le32_to_cpu(ext_hdr->length);
+		if (len < sizeof(*ext_hdr)) {
+			pr_warn("Invalid length in extension header\n");
+			return -EINVAL;
+		}
+		rounded_len = round_up(len, 8);
+		if (rounded_len == 0 ||
+		    rounded_len > end - (const void *)ext_hdr) {
+			pr_warn("Extension item overflows buffer\n");
+			return -EINVAL;
+		}
+		if (len < sizeof(*ext_hdr) + type->base_len) {
+			pr_warn("Extension length too small for type\n");
+			return -EINVAL;
+		}
+		err = type->parse(vi, ext_hdr + 1,
+				  len - sizeof(*ext_hdr) - type->base_len);
+		if (err)
+			return err;
+		ext_hdr = (const void *)ext_hdr + rounded_len;
+	}
+	*ext_hdr_p = ext_hdr;
+	return 0;
+}
+
+/*
+ * Parse the extension items following the fixed-size portion of the fs-verity
+ * descriptor.  The fsverity_info is updated accordingly.
+ *
+ * Return: On success, the size of the authenticated portion of the descriptor
+ *	   (the fixed-size portion plus the authenticated extensions).
+ *	   Otherwise, a -errno value.
+ */
+static int parse_extensions(struct fsverity_info *vi,
+			    const struct fsverity_descriptor *desc,
+			    int desc_len)
+{
+	const struct fsverity_extension *ext_hdr = (const void *)(desc + 1);
+	const void *end = (const void *)desc + desc_len;
+	u16 auth_ext_count = le16_to_cpu(desc->auth_ext_count);
+	int auth_desc_len;
+	int err;
+
+	err = do_parse_extensions(vi, &ext_hdr, end, auth_ext_count, true);
+	if (err)
+		return err;
+	auth_desc_len = (void *)ext_hdr - (void *)desc;
+
+	/*
+	 * Unauthenticated extensions (optional).  Careful: an attacker able to
+	 * corrupt the file can change these arbitrarily without being detected.
+	 * Thus, only specific types of extensions are whitelisted here --
+	 * namely, the ones containing a signature of the file measurement,
+	 * which by definition can't be included in the file measurement itself.
+	 */
+	if (end - (void *)ext_hdr >= 8) {
+		u16 unauth_ext_count = le16_to_cpup((__le16 *)ext_hdr);
+
+		ext_hdr = (void *)ext_hdr + 8;
+		err = do_parse_extensions(vi, &ext_hdr, end,
+					  unauth_ext_count, false);
+		if (err)
+			return err;
+	}
+
+	return auth_desc_len;
+}
+
+/*
+ * Parse an fs-verity descriptor, loading information into the fsverity_info.
+ *
+ * Return: On success, the size of the authenticated portion of the descriptor
+ *	   (the fixed-size portion plus the authenticated extensions).
+ *	   Otherwise, a -errno value.
+ */
+static int parse_fsverity_descriptor(struct fsverity_info *vi,
+				     const struct fsverity_descriptor *desc,
+				     int desc_len, loff_t desc_start)
+{
+	unsigned int alg_num;
+	unsigned int hashes_per_block;
+	u64 orig_file_size;
+	int desc_auth_len;
+	int err;
+
+	BUILD_BUG_ON(sizeof(*desc) != 64);
+
+	/* magic */
+	if (memcmp(desc->magic, FS_VERITY_MAGIC, sizeof(desc->magic))) {
+		pr_warn("Wrong magic bytes\n");
+		return -EINVAL;
+	}
+
+	/* major_version */
+	if (desc->major_version != 1) {
+		pr_warn("Unsupported major version (%u)\n",
+			desc->major_version);
+		return -EINVAL;
+	}
+
+	/* minor_version */
+	if (desc->minor_version != 0) {
+		pr_warn("Unsupported minor version (%u)\n",
+			desc->minor_version);
+		return -EINVAL;
+	}
+
+	/* data_algorithm and tree_algorithm */
+	alg_num = le16_to_cpu(desc->data_algorithm);
+	if (alg_num != le16_to_cpu(desc->tree_algorithm)) {
+		pr_warn("Unimplemented case: data (%u) and tree (%u) hash algorithms differ\n",
+			alg_num, le16_to_cpu(desc->tree_algorithm));
+		return -EINVAL;
+	}
+	vi->hash_alg = fsverity_get_hash_alg(alg_num);
+	if (IS_ERR(vi->hash_alg))
+		return PTR_ERR(vi->hash_alg);
+
+	/* log_data_blocksize and log_tree_blocksize */
+	if (desc->log_data_blocksize != PAGE_SHIFT) {
+		pr_warn("Unsupported log_blocksize (%u).  Need block_size == PAGE_SIZE.\n",
+			desc->log_data_blocksize);
+		return -EINVAL;
+	}
+	if (desc->log_tree_blocksize != desc->log_data_blocksize) {
+		pr_warn("Unimplemented case: data (%u) and tree (%u) block sizes differ\n",
+			desc->log_data_blocksize, desc->log_data_blocksize);
+		return -EINVAL;
+	}
+	vi->block_bits = desc->log_data_blocksize;
+	hashes_per_block = (1 << vi->block_bits) / vi->hash_alg->digest_size;
+	if (!is_power_of_2(hashes_per_block)) {
+		pr_warn("Unimplemented case: hashes per block (%u) isn't a power of 2\n",
+			hashes_per_block);
+		return -EINVAL;
+	}
+	vi->log_arity = ilog2(hashes_per_block);
+
+	/* flags */
+	if (desc->flags) {
+		pr_warn("Unsupported flags (%#x)\n", le32_to_cpu(desc->flags));
+		return -EINVAL;
+	}
+
+	/* reserved fields */
+	if (desc->reserved1 ||
+	    memchr_inv(desc->reserved2, 0, sizeof(desc->reserved2))) {
+		pr_warn("Reserved bits set in fsverity_descriptor\n");
+		return -EINVAL;
+	}
+
+	/*
+	 * orig_file_size.  For filesystems that set the on-disk i_size to
+	 * data_i_size rather than to full_i_size, this field is redundant --
+	 * though it still must be included in the file measurement!  Make sure
+	 * it's really the same.
+	 */
+	orig_file_size = le64_to_cpu(desc->orig_file_size);
+	if (vi->data_i_size) {
+		if (orig_file_size != vi->data_i_size) {
+			pr_warn("fsverity_descriptor.orig_file_size (%llu) doesn't match i_size (%llu)!\n",
+				orig_file_size, vi->data_i_size);
+			return -EINVAL;
+		}
+	} else {
+		vi->data_i_size = orig_file_size;
+	}
+	if (vi->data_i_size == 0) {
+		pr_warn("Original file size is 0; this is not supported\n");
+		return -EINVAL;
+	}
+	if (vi->data_i_size > desc_start) {
+		pr_warn("Original file size is too large (%llu)\n",
+			vi->data_i_size);
+		return -EINVAL;
+	}
+
+	/* extensions */
+	desc_auth_len = parse_extensions(vi, desc, desc_len);
+	if (desc_auth_len < 0)
+		return desc_auth_len;
+
+	if (!vi->have_root_hash) {
+		pr_warn("Root hash wasn't found!\n");
+		return -EINVAL;
+	}
+
+	/* Use an empty salt if no salt was found in the extensions list */
+	if (!vi->hashstate) {
+		err = set_salt(vi, "", 0);
+		if (err)
+			return err;
+	}
+
+	return desc_auth_len;
+}
+
+/*
+ * Calculate the depth of the Merkle tree, then create a map from level to the
+ * block offset at which that level's hash blocks start.  Level 'depth - 1' is
+ * the root and is stored first in the file, in the first block following the
+ * original data.  Level 0 is the level directly "above" the data blocks and is
+ * stored last in the file, just before the fsverity_descriptor.
+ */
+static int compute_tree_depth_and_offsets(struct fsverity_info *vi)
+{
+	unsigned int hashes_per_block = 1 << vi->log_arity;
+	u64 blocks = (vi->data_i_size + (1 << vi->block_bits) - 1) >>
+			vi->block_bits;
+	u64 offset = blocks;
+	int depth = 0;
+	int i;
+
+	while (blocks > 1) {
+		if (depth >= FS_VERITY_MAX_LEVELS) {
+			pr_warn("Too many tree levels (max is %d)\n",
+				FS_VERITY_MAX_LEVELS);
+			return -EINVAL;
+		}
+		blocks = (blocks + hashes_per_block - 1) >> vi->log_arity;
+		vi->hash_lvl_region_idx[depth++] = blocks;
+	}
+	vi->depth = depth;
+
+	for (i = depth - 1; i >= 0; i--) {
+		u64 next_count = vi->hash_lvl_region_idx[i];
+
+		vi->hash_lvl_region_idx[i] = offset;
+		pr_debug("Level %d is [%llu..%llu] (%llu blocks)\n",
+			 i, offset, offset + next_count - 1, next_count);
+		offset += next_count;
+	}
+	return 0;
+}
+
+/* Arbitrary limit, can be increased if needed */
+#define MAX_DESCRIPTOR_PAGES	16
+
+/*
+ * Compute the file's measurement by hashing the first 'desc_auth_len' bytes of
+ * the fs-verity descriptor (which includes the Merkle tree root hash as an
+ * authenticated extension item).
+ *
+ * Note: 'desc' may point into vmap'ed memory, so it can't be passed directly to
+ * sg_set_buf() for the ahash API.  Instead, we pass the pages directly.
+ */
+static int compute_measurement(const struct fsverity_info *vi,
+			       const struct fsverity_descriptor *desc,
+			       int desc_auth_len,
+			       struct page *desc_pages[MAX_DESCRIPTOR_PAGES],
+			       int nr_desc_pages, u8 *measurement)
+{
+	struct ahash_request *req;
+	DECLARE_CRYPTO_WAIT(wait);
+	struct scatterlist sg[MAX_DESCRIPTOR_PAGES];
+	int offset, len, remaining;
+	int i;
+	int err;
+
+	req = ahash_request_alloc(vi->hash_alg->tfm, GFP_KERNEL);
+	if (!req)
+		return -ENOMEM;
+
+	sg_init_table(sg, nr_desc_pages);
+	offset = offset_in_page(desc);
+	remaining = desc_auth_len;
+	for (i = 0; i < nr_desc_pages && remaining; i++) {
+		len = min_t(int, PAGE_SIZE - offset, remaining);
+		sg_set_page(&sg[i], desc_pages[i], len, offset);
+		remaining -= len;
+		offset = 0;
+	}
+
+	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP |
+				   CRYPTO_TFM_REQ_MAY_BACKLOG,
+				   crypto_req_done, &wait);
+	ahash_request_set_crypt(req, sg, measurement, desc_auth_len);
+	err = crypto_wait_req(crypto_ahash_digest(req), &wait);
+	ahash_request_free(req);
+	return err;
+}
+
+static struct fsverity_info *alloc_fsverity_info(void)
+{
+	return kmem_cache_zalloc(fsverity_info_cachep, GFP_NOFS);
+}
+
+void free_fsverity_info(struct fsverity_info *vi)
+{
+	if (!vi)
+		return;
+	kfree(vi->hashstate);
+	kmem_cache_free(fsverity_info_cachep, vi);
+}
+
+/**
+ * find_fsverity_footer - find the fsverity_footer in the last page of the file
+ *
+ * To find the fsverity_footer we have to scan backwards from the end, skipping
+ * zero bytes.  This is needed because some filesystems (e.g. ext4) set the
+ * on-disk i_size to data_i_size rather than to full_i_size, and full_i_size is
+ * instead gotten indirectly via the end of the last extent.  This causes
+ * full_i_size to be rounded up to the end of the filesystem block.
+ *
+ * Return: pointer to the footer if found, else NULL
+ */
+static const struct fsverity_footer *
+find_fsverity_footer(const u8 *last_virt, size_t last_validsize)
+{
+	const u8 *p = last_virt + last_validsize;
+	const struct fsverity_footer *ftr;
+
+	/* Find the last nonzero byte, which should be ftr->magic[7] */
+	do {
+		if (p <= last_virt)
+			return NULL;
+	} while (*--p == 0);
+
+	BUILD_BUG_ON(sizeof(ftr->magic) != 8);
+	BUILD_BUG_ON(offsetof(struct fsverity_footer, magic[8]) !=
+		     sizeof(*ftr));
+	if (p - last_virt < offsetof(struct fsverity_footer, magic[7]))
+		return NULL;
+	ftr = container_of(p, struct fsverity_footer, magic[7]);
+	if (memcmp(ftr->magic, FS_VERITY_MAGIC, sizeof(ftr->magic)))
+		return NULL;
+	return ftr;
+}
+
+/**
+ * map_fsverity_descriptor - map an inode's fs-verity descriptor into memory
+ *
+ * If the descriptor fits in one page, we use kmap; otherwise we use vmap.
+ * unmap_fsverity_descriptor() must be called later to unmap it.
+ *
+ * It's assumed that the file contents cannot be modified concurrently.
+ * (This is guaranteed by either deny_write_access() or by the verity bit.)
+ *
+ * Return: the virtual address of the start of the descriptor, in virtually
+ * contiguous memory.  Also fills in desc_pages and returns in *desc_len the
+ * length of the descriptor including all extensions, and in *desc_start the
+ * offset of the descriptor from the start of the file, in bytes.
+ */
+static const struct fsverity_descriptor *
+map_fsverity_descriptor(struct inode *inode, loff_t full_i_size,
+			struct page *desc_pages[MAX_DESCRIPTOR_PAGES],
+			int *nr_desc_pages, int *desc_len, loff_t *desc_start)
+{
+	const int last_validsize = ((full_i_size - 1) & ~PAGE_MASK) + 1;
+	const pgoff_t last_pgoff = (full_i_size - 1) >> PAGE_SHIFT;
+	struct page *last_page;
+	const void *last_virt;
+	const struct fsverity_footer *ftr;
+	pgoff_t first_pgoff;
+	u32 desc_reverse_offset;
+	pgoff_t pgoff;
+	const void *desc_virt;
+	int i;
+	int err;
+
+	*nr_desc_pages = 0;
+	*desc_len = 0;
+	*desc_start = 0;
+
+	if (full_i_size <= 0) {
+		pr_warn("File is empty!\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	last_page = read_mapping_page(inode->i_mapping, last_pgoff, NULL);
+	if (IS_ERR(last_page)) {
+		pr_warn("Error reading last page: %ld\n", PTR_ERR(last_page));
+		return ERR_CAST(last_page);
+	}
+	last_virt = kmap(last_page);
+
+	ftr = find_fsverity_footer(last_virt, last_validsize);
+	if (!ftr) {
+		pr_warn("No verity metadata found\n");
+		err = -EINVAL;
+		goto err_out;
+	}
+	full_i_size -= (last_virt + last_validsize - sizeof(*ftr)) -
+		       (void *)ftr;
+
+	desc_reverse_offset = le32_to_cpu(ftr->desc_reverse_offset);
+	if (desc_reverse_offset <
+	    sizeof(struct fsverity_descriptor) + sizeof(*ftr) ||
+	    desc_reverse_offset > full_i_size) {
+		pr_warn("Unexpected desc_reverse_offset: %u\n",
+			desc_reverse_offset);
+		err = -EINVAL;
+		goto err_out;
+	}
+	*desc_start = full_i_size - desc_reverse_offset;
+	if (*desc_start & 7) {
+		pr_warn("fs-verity descriptor is misaligned (desc_start=%lld)\n",
+			*desc_start);
+		err = -EINVAL;
+		goto err_out;
+	}
+
+	first_pgoff = *desc_start >> PAGE_SHIFT;
+	if (last_pgoff - first_pgoff >= MAX_DESCRIPTOR_PAGES) {
+		pr_warn("fs-verity descriptor is too long (%lu pages)\n",
+			last_pgoff - first_pgoff + 1);
+		err = -EINVAL;
+		goto err_out;
+	}
+
+	*desc_len = desc_reverse_offset - sizeof(__le32);
+
+	if (first_pgoff == last_pgoff) {
+		/* Single-page descriptor; use the already-kmapped last page */
+		desc_pages[0] = last_page;
+		*nr_desc_pages = 1;
+		return last_virt + (*desc_start & ~PAGE_MASK);
+	}
+
+	/* Multi-page descriptor; map the additional pages into memory */
+
+	for (pgoff = first_pgoff; pgoff < last_pgoff; pgoff++) {
+		struct page *page;
+
+		page = read_mapping_page(inode->i_mapping, pgoff, NULL);
+		if (IS_ERR(page)) {
+			err = PTR_ERR(page);
+			pr_warn("Error reading descriptor page: %d\n", err);
+			goto err_out;
+		}
+		desc_pages[(*nr_desc_pages)++] = page;
+	}
+
+	desc_pages[(*nr_desc_pages)++] = last_page;
+	kunmap(last_page);
+	last_page = NULL;
+
+	desc_virt = vmap(desc_pages, *nr_desc_pages, VM_MAP, PAGE_KERNEL_RO);
+	if (!desc_virt) {
+		err = -ENOMEM;
+		goto err_out;
+	}
+
+	return desc_virt + (*desc_start & ~PAGE_MASK);
+
+err_out:
+	for (i = 0; i < *nr_desc_pages; i++)
+		put_page(desc_pages[i]);
+	if (last_page) {
+		kunmap(last_page);
+		put_page(last_page);
+	}
+	return ERR_PTR(err);
+}
+
+static void
+unmap_fsverity_descriptor(const struct fsverity_descriptor *desc,
+			  struct page *desc_pages[MAX_DESCRIPTOR_PAGES],
+			  int nr_desc_pages)
+{
+	int i;
+
+	if (is_vmalloc_addr(desc)) {
+		vunmap((void *)((unsigned long)desc & PAGE_MASK));
+	} else {
+		WARN_ON(nr_desc_pages != 1);
+		kunmap(desc_pages[0]);
+	}
+	for (i = 0; i < nr_desc_pages; i++)
+		put_page(desc_pages[i]);
+}
+
+/*
+ * Read the file's fs-verity descriptor and create an fsverity_info for it.
+ */
+struct fsverity_info *create_fsverity_info(struct inode *inode, bool enabling)
+{
+	loff_t full_i_size;
+	struct fsverity_info *vi;
+	const struct fsverity_descriptor *desc = NULL;
+	struct page *desc_pages[MAX_DESCRIPTOR_PAGES];
+	int nr_desc_pages;
+	int desc_len;
+	loff_t desc_start;
+	int desc_auth_len;
+	int err;
+
+	vi = alloc_fsverity_info();
+	if (!vi)
+		return ERR_PTR(-ENOMEM);
+
+	full_i_size = i_size_read(inode);
+
+	if (inode->i_sb->s_vop->get_full_i_size && !enabling) {
+		/*
+		 * For filesystems that set the on-disk i_size to data_i_size
+		 * rather than to full_i_size, we have to get full_i_size from
+		 * somewhere else, e.g. the end of the last extent.
+		 */
+		vi->data_i_size = full_i_size;
+		err = inode->i_sb->s_vop->get_full_i_size(inode, &full_i_size);
+		if (err)
+			goto out;
+	}
+	vi->full_i_size = full_i_size;
+	pr_debug("full_i_size=%lld\n", full_i_size);
+
+	desc = map_fsverity_descriptor(inode, full_i_size, desc_pages,
+				       &nr_desc_pages, &desc_len, &desc_start);
+	if (IS_ERR(desc)) {
+		err = PTR_ERR(desc);
+		desc = NULL;
+		goto out;
+	}
+
+	dump_fsverity_descriptor(desc);
+	desc_auth_len = parse_fsverity_descriptor(vi, desc, desc_len,
+						  desc_start);
+	if (desc_auth_len < 0) {
+		err = desc_auth_len;
+		goto out;
+	}
+
+	err = compute_tree_depth_and_offsets(vi);
+	if (err)
+		goto out;
+	err = compute_measurement(vi, desc, desc_auth_len, desc_pages,
+				  nr_desc_pages, vi->measurement);
+out:
+	if (desc)
+		unmap_fsverity_descriptor(desc, desc_pages, nr_desc_pages);
+	if (err) {
+		free_fsverity_info(vi);
+		vi = ERR_PTR(err);
+	}
+	return vi;
+}
+
+/* Ensure the inode has an ->i_verity_info */
+static int setup_fsverity_info(struct inode *inode)
+{
+	struct fsverity_info *vi = get_fsverity_info(inode);
+
+	if (vi)
+		return 0;
+
+	vi = create_fsverity_info(inode, false);
+	if (IS_ERR(vi))
+		return PTR_ERR(vi);
+
+	if (!set_fsverity_info(inode, vi))
+		free_fsverity_info(vi);
+	return 0;
+}
+
+/**
+ * fsverity_file_open - prepare to open a verity file
+ * @inode: the inode being opened
+ * @filp: the struct file being set up
+ *
+ * When opening a verity file, deny the open if it is for writing.  Otherwise,
+ * set up the inode's ->i_verity_info (if not already done) by parsing the
+ * verity metadata at the end of the file.
+ *
+ * When combined with fscrypt, this must be called after fscrypt_file_open().
+ * Otherwise, we won't have the key set up to decrypt the verity metadata.
+ *
+ * Return: 0 on success, -errno on failure
+ */
+int fsverity_file_open(struct inode *inode, struct file *filp)
+{
+	if (filp->f_mode & FMODE_WRITE) {
+		pr_debug("Denying opening verity file (ino %lu) for write\n",
+			 inode->i_ino);
+		return -EPERM;
+	}
+
+	return setup_fsverity_info(inode);
+}
+EXPORT_SYMBOL_GPL(fsverity_file_open);
+
+/**
+ * fsverity_prepare_setattr - prepare to change a verity inode's attributes
+ * @dentry: dentry through which the inode is being changed
+ * @attr: attributes to change
+ *
+ * Verity files are immutable, so deny truncates.  This isn't covered by the
+ * open-time check because sys_truncate() takes a path, not a file descriptor.
+ *
+ * Return: 0 on success, -errno on failure
+ */
+int fsverity_prepare_setattr(struct dentry *dentry, struct iattr *attr)
+{
+	if (attr->ia_valid & ATTR_SIZE) {
+		pr_debug("Denying truncate of verity file (ino %lu)\n",
+			 d_inode(dentry)->i_ino);
+		return -EPERM;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(fsverity_prepare_setattr);
+
+/**
+ * fsverity_prepare_getattr - prepare to get a verity inode's attributes
+ * @inode: the inode for which the attributes are being retrieved
+ *
+ * For filesystems that set the on-disk i_size to full_i_size rather than to
+ * data_i_size, to make st_size exclude the verity metadata even before the file
+ * has been opened for the first time we need to grab the original data size
+ * from the fs-verity descriptor.  Currently, to implement this we just set up
+ * the ->i_verity_info, like in the ->open() hook.
+ *
+ * However, when combined with fscrypt, on an encrypted file this must only be
+ * called if the encryption key has been set up!
+ *
+ * Return: 0 on success, -errno on failure
+ */
+int fsverity_prepare_getattr(struct inode *inode)
+{
+	return setup_fsverity_info(inode);
+}
+EXPORT_SYMBOL_GPL(fsverity_prepare_getattr);
+
+/**
+ * fsverity_cleanup_inode - free the inode's verity info, if present
+ *
+ * Filesystems must call this on inode eviction to free ->i_verity_info.
+ */
+void fsverity_cleanup_inode(struct inode *inode)
+{
+	free_fsverity_info(inode->i_verity_info);
+	inode->i_verity_info = NULL;
+}
+EXPORT_SYMBOL_GPL(fsverity_cleanup_inode);
+
+/**
+ * fsverity_full_i_size - get the full (on-disk) file size
+ *
+ * If the inode has had its in-memory ->i_size overridden for fs-verity (to
+ * exclude the metadata at the end of the file), then return the full i_size
+ * which is stored on-disk.  Otherwise, just return the in-memory ->i_size.
+ *
+ * Return: the full (on-disk) file size
+ */
+loff_t fsverity_full_i_size(const struct inode *inode)
+{
+	struct fsverity_info *vi = get_fsverity_info(inode);
+
+	if (vi)
+		return vi->full_i_size;
+
+	return i_size_read(inode);
+}
+EXPORT_SYMBOL_GPL(fsverity_full_i_size);
+
+static int __init fsverity_module_init(void)
+{
+	fsverity_info_cachep = KMEM_CACHE(fsverity_info, SLAB_RECLAIM_ACCOUNT);
+	if (!fsverity_info_cachep)
+		return -ENOMEM;
+
+	fsverity_check_hash_algs();
+
+	pr_debug("Initialized fs-verity\n");
+	return 0;
+}
+
+static void __exit fsverity_module_exit(void)
+{
+	kmem_cache_destroy(fsverity_info_cachep);
+	fsverity_exit_hash_algs();
+}
+
+module_init(fsverity_module_init)
+module_exit(fsverity_module_exit);
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("fs-verity: read-only file-based integrity/authentication");
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 805bf22898cf2..26764ebcb7724 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -61,6 +61,8 @@ struct workqueue_struct;
 struct iov_iter;
 struct fscrypt_info;
 struct fscrypt_operations;
+struct fsverity_info;
+struct fsverity_operations;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
@@ -671,6 +673,10 @@ struct inode {
 	struct fscrypt_info	*i_crypt_info;
 #endif
 
+#if IS_ENABLED(CONFIG_FS_VERITY)
+	struct fsverity_info	*i_verity_info;
+#endif
+
 	void			*i_private; /* fs or device private pointer */
 } __randomize_layout;
 
@@ -1369,6 +1375,9 @@ struct super_block {
 	const struct xattr_handler **s_xattr;
 #if IS_ENABLED(CONFIG_FS_ENCRYPTION)
 	const struct fscrypt_operations	*s_cop;
+#endif
+#if IS_ENABLED(CONFIG_FS_VERITY)
+	const struct fsverity_operations *s_vop;
 #endif
 	struct hlist_bl_head	s_roots;	/* alternate root dentries for NFS */
 	struct list_head	s_mounts;	/* list of mounts; _not_ for fs use */
diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
new file mode 100644
index 0000000000000..3af55241046aa
--- /dev/null
+++ b/include/linux/fsverity.h
@@ -0,0 +1,62 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/*
+ * fs-verity: read-only file-based integrity/authentication
+ *
+ * Copyright (C) 2018 Google, Inc.
+ */
+
+#ifndef _LINUX_FSVERITY_H
+#define _LINUX_FSVERITY_H
+
+#include <linux/fs.h>
+#include <uapi/linux/fsverity.h>
+
+/*
+ * fs-verity operations for filesystems
+ */
+struct fsverity_operations {
+	int (*set_verity)(struct inode *inode, loff_t data_i_size);
+	int (*get_full_i_size)(struct inode *inode, loff_t *full_i_size_ret);
+};
+
+#if __FS_HAS_VERITY
+
+/* setup.c */
+extern int fsverity_file_open(struct inode *inode, struct file *filp);
+extern int fsverity_prepare_setattr(struct dentry *dentry, struct iattr *attr);
+extern int fsverity_prepare_getattr(struct inode *inode);
+extern void fsverity_cleanup_inode(struct inode *inode);
+extern loff_t fsverity_full_i_size(const struct inode *inode);
+
+#else /* !__FS_HAS_VERITY */
+
+/* setup.c */
+
+static inline int fsverity_file_open(struct inode *inode, struct file *filp)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int fsverity_prepare_setattr(struct dentry *dentry,
+					   struct iattr *attr)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int fsverity_prepare_getattr(struct inode *inode)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void fsverity_cleanup_inode(struct inode *inode)
+{
+}
+
+static inline loff_t fsverity_full_i_size(const struct inode *inode)
+{
+	return i_size_read(inode);
+}
+
+#endif	/* !__FS_HAS_VERITY */
+
+#endif	/* _LINUX_FSVERITY_H */
diff --git a/include/uapi/linux/fsverity.h b/include/uapi/linux/fsverity.h
new file mode 100644
index 0000000000000..24ebb8b6ea0d4
--- /dev/null
+++ b/include/uapi/linux/fsverity.h
@@ -0,0 +1,86 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
+/*
+ * fs-verity (file-based verity) support
+ *
+ * Copyright (C) 2018 Google LLC
+ */
+#ifndef _UAPI_LINUX_FSVERITY_H
+#define _UAPI_LINUX_FSVERITY_H
+
+#include <linux/limits.h>
+#include <linux/ioctl.h>
+#include <linux/types.h>
+
+/* ========== Ioctls ========== */
+
+struct fsverity_digest {
+	__u16 digest_algorithm;
+	__u16 digest_size; /* input/output */
+	__u8 digest[];
+};
+
+#define FS_IOC_ENABLE_VERITY	_IO('f', 133)
+#define FS_IOC_MEASURE_VERITY	_IOWR('f', 134, struct fsverity_digest)
+
+/* ========== On-disk format ========== */
+
+#define FS_VERITY_MAGIC		"FSVerity"
+
+/* Supported hash algorithms */
+#define FS_VERITY_ALG_SHA256	1
+
+/* Metadata stored near the end of verity files, after the Merkle tree */
+/* This structure is 64 bytes long */
+struct fsverity_descriptor {
+	__u8 magic[8];		/* must be FS_VERITY_MAGIC */
+	__u8 major_version;	/* must be 1 */
+	__u8 minor_version;	/* must be 0 */
+	__u8 log_data_blocksize;/* log2(data-bytes-per-hash), e.g. 12 for 4KB */
+	__u8 log_tree_blocksize;/* log2(tree-bytes-per-hash), e.g. 12 for 4KB */
+	__le16 data_algorithm;	/* hash algorithm for data blocks */
+	__le16 tree_algorithm;	/* hash algorithm for tree blocks */
+	__le32 flags;		/* flags */
+	__le32 reserved1;	/* must be 0 */
+	__le64 orig_file_size;	/* size of the original, unpadded data */
+	__le16 auth_ext_count;	/* number of authenticated extensions */
+	__u8 reserved2[30];	/* must be 0 */
+};
+/* followed by list of 'auth_ext_count' authenticated extensions */
+/*
+ * then followed by '__le16 unauth_ext_count' padded to next 8-byte boundary,
+ * then a list of 'unauth_ext_count' (may be 0) unauthenticated extensions
+ */
+
+/* Extension types */
+#define FS_VERITY_EXT_ROOT_HASH		1
+#define FS_VERITY_EXT_SALT		2
+
+/* Header of each extension (variable-length metadata item) */
+struct fsverity_extension {
+	/*
+	 * Length in bytes, including this header but excluding padding to next
+	 * 8-byte boundary that is applied when advancing to the next extension.
+	 */
+	__le32 length;
+	__le16 type;		/* Type of this extension (see codes above) */
+	__le16 reserved;	/* Reserved, must be 0 */
+};
+/* followed by the payload of 'length - 8' bytes */
+
+/* Extension payload formats */
+
+/*
+ * FS_VERITY_EXT_ROOT_HASH payload is just a byte array, with size equal to the
+ * digest size of the hash algorithm given in the fsverity_descriptor
+ */
+
+/* FS_VERITY_EXT_SALT payload is just a byte array, any size */
+
+
+/* Fields stored at the very end of the file */
+struct fsverity_footer {
+	__le32 desc_reverse_offset;	/* distance to fsverity_descriptor */
+	__u8 magic[8];			/* FS_VERITY_MAGIC */
+} __packed;
+
+#endif /* _UAPI_LINUX_FSVERITY_H */
-- 
2.18.0


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
