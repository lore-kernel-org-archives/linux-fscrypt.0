Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Fri, 24 Aug 2018 09:16:39 -0700
Message-Id: <20180824161642.1144-8-ebiggers@kernel.org>
In-Reply-To: <20180824161642.1144-1-ebiggers@kernel.org>
References: <20180824161642.1144-1-ebiggers@kernel.org>
Subject: [f2fs-dev] [RFC PATCH 07/10] fs-verity: support builtin file
 signatures
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

Add optional support for:

- At module initialization time, creating an ".fs-verity" keyring to
  which trusted X.509 certificates can be added via sys_add_key().

- Parsing a signed file measurement from the fs-verity metadata (as a
  PKCS7_SIGNATURE unauthenticated extension item), and verifying it
  against the certificates in the ".fs-verity" keyring.

- Registering a sysctl fs.verity.require_signatures.  This can be set to
  enforce that all fs-verity files have a valid signature.

This is meant as a relatively simple mechanism that can be used to
provide an authenticity guarantee for fs-verity files, as an alternative
to IMA-appraisal.  Userspace programs still need to check that the
fs-verity bit is set in order to get an authenticity guarantee.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/verity/Kconfig             |  17 ++++
 fs/verity/Makefile            |   2 +
 fs/verity/fsverity_private.h  |  34 +++++++
 fs/verity/setup.c             |  63 +++++++++++-
 fs/verity/signature.c         | 187 ++++++++++++++++++++++++++++++++++
 include/uapi/linux/fsverity.h |  10 ++
 6 files changed, 311 insertions(+), 2 deletions(-)
 create mode 100644 fs/verity/signature.c

diff --git a/fs/verity/Kconfig b/fs/verity/Kconfig
index 308d733a9401b..485488021ac16 100644
--- a/fs/verity/Kconfig
+++ b/fs/verity/Kconfig
@@ -34,3 +34,20 @@ config FS_VERITY_DEBUG
 	  Enable debugging messages related to fs-verity by default.
 
 	  Say N unless you are an fs-verity developer.
+
+config FS_VERITY_BUILTIN_SIGNATURES
+	bool "FS Verity builtin signature support"
+	depends on FS_VERITY
+	select SYSTEM_DATA_VERIFICATION
+	help
+	  Support verifying signatures of verity files against the X.509
+	  certificates that have been loaded into the ".fs-verity"
+	  kernel keyring.
+
+	  This is meant as a relatively simple mechanism that can be
+	  used to provide an authenticity guarantee for verity files, as
+	  an alternative to IMA appraisal.  Userspace programs still
+	  need to check that the verity bit is set in order to get an
+	  authenticity guarantee.
+
+	  If unsure, say N.
diff --git a/fs/verity/Makefile b/fs/verity/Makefile
index 6450925e3a8b7..d293ea2a1b393 100644
--- a/fs/verity/Makefile
+++ b/fs/verity/Makefile
@@ -1,3 +1,5 @@
 obj-$(CONFIG_FS_VERITY)	+= fsverity.o
 
 fsverity-y := hash_algs.o ioctl.o setup.o verify.o
+
+fsverity-$(CONFIG_FS_VERITY_BUILTIN_SIGNATURES) += signature.o
diff --git a/fs/verity/fsverity_private.h b/fs/verity/fsverity_private.h
index 1046b87b12dee..73a3f04776fce 100644
--- a/fs/verity/fsverity_private.h
+++ b/fs/verity/fsverity_private.h
@@ -63,6 +63,7 @@ struct fsverity_info {
 	u8 root_hash[FS_VERITY_MAX_DIGEST_SIZE];   /* Merkle tree root hash */
 	u8 measurement[FS_VERITY_MAX_DIGEST_SIZE]; /* file measurement */
 	bool have_root_hash;		/* have root hash from disk? */
+	bool have_signed_measurement;	/* have measurement from signature? */
 
 	/* Starting blocks for each tree level. 'depth-1' is the root level. */
 	u64 hash_lvl_region_idx[FS_VERITY_MAX_LEVELS];
@@ -96,6 +97,39 @@ static inline bool set_fsverity_info(struct inode *inode,
 	return true;
 }
 
+/* signature.c */
+#ifdef CONFIG_FS_VERITY_BUILTIN_SIGNATURES
+extern int fsverity_require_signatures;
+
+int fsverity_parse_pkcs7_signature_extension(struct fsverity_info *vi,
+					     const void *raw_pkcs7,
+					     size_t size);
+
+int __init fsverity_signature_init(void);
+
+void __exit fsverity_signature_exit(void);
+#else /* CONFIG_FS_VERITY_BUILTIN_SIGNATURES */
+
+#define fsverity_require_signatures 0
+
+static inline int
+fsverity_parse_pkcs7_signature_extension(struct fsverity_info *vi,
+					 const void *raw_pkcs7, size_t size)
+{
+	pr_warn("PKCS#7 signatures not supported in this kernel build!\n");
+	return -EINVAL;
+}
+
+static inline int fsverity_signature_init(void)
+{
+	return 0;
+}
+
+static inline void fsverity_signature_exit(void)
+{
+}
+#endif /* !CONFIG_FS_VERITY_BUILTIN_SIGNATURES */
+
 /* verify.c */
 extern struct workqueue_struct *fsverity_read_workqueue;
 
diff --git a/fs/verity/setup.c b/fs/verity/setup.c
index 3f5cb9526dbc9..6a11cdcbd01d4 100644
--- a/fs/verity/setup.c
+++ b/fs/verity/setup.c
@@ -132,6 +132,10 @@ static const struct extension_type {
 	[FS_VERITY_EXT_SALT] = {
 		.parse = parse_salt_extension,
 	},
+	[FS_VERITY_EXT_PKCS7_SIGNATURE] = {
+		.parse = fsverity_parse_pkcs7_signature_extension,
+		.unauthenticated = true,
+	},
 };
 
 static int do_parse_extensions(struct fsverity_info *vi,
@@ -449,6 +453,54 @@ static int compute_measurement(const struct fsverity_info *vi,
 	return err;
 }
 
+/*
+ * Compute the file's measurement; then, if a signature was present, verify that
+ * the signed measurement matches the actual one.
+ */
+static int
+verify_file_measurement(struct fsverity_info *vi,
+			const struct fsverity_descriptor *desc,
+			int desc_auth_len,
+			struct page *desc_pages[MAX_DESCRIPTOR_PAGES],
+			int nr_desc_pages)
+{
+	u8 measurement[FS_VERITY_MAX_DIGEST_SIZE];
+	int err;
+
+	err = compute_measurement(vi, desc, desc_auth_len, desc_pages,
+				  nr_desc_pages, measurement);
+	if (err) {
+		pr_warn("Error computing fs-verity measurement: %d\n", err);
+		return err;
+	}
+
+	if (!vi->have_signed_measurement) {
+		pr_debug("Computed measurement: %s:%*phN (used desc_auth_len %d)\n",
+			 vi->hash_alg->name, vi->hash_alg->digest_size,
+			 measurement, desc_auth_len);
+		if (fsverity_require_signatures) {
+			pr_warn("require_signatures=1, rejecting unsigned file!\n");
+			return -EBADMSG;
+		}
+		memcpy(vi->measurement, measurement, vi->hash_alg->digest_size);
+		return 0;
+	}
+
+	if (!memcmp(measurement, vi->measurement, vi->hash_alg->digest_size)) {
+		pr_debug("Verified measurement: %s:%*phN (used desc_auth_len %d)\n",
+			 vi->hash_alg->name, vi->hash_alg->digest_size,
+			 measurement, desc_auth_len);
+		return 0;
+	}
+
+	pr_warn("FILE CORRUPTED (actual measurement mismatches signed measurement): "
+		"want %s:%*phN, real %s:%*phN (used desc_auth_len %d)\n",
+		vi->hash_alg->name, vi->hash_alg->digest_size, vi->measurement,
+		vi->hash_alg->name, vi->hash_alg->digest_size, measurement,
+		desc_auth_len);
+	return -EBADMSG;
+}
+
 static struct fsverity_info *alloc_fsverity_info(void)
 {
 	return kmem_cache_zalloc(fsverity_info_cachep, GFP_NOFS);
@@ -693,8 +745,8 @@ struct fsverity_info *create_fsverity_info(struct inode *inode, bool enabling)
 	err = compute_tree_depth_and_offsets(vi);
 	if (err)
 		goto out;
-	err = compute_measurement(vi, desc, desc_auth_len, desc_pages,
-				  nr_desc_pages, vi->measurement);
+	err = verify_file_measurement(vi, desc, desc_auth_len,
+				      desc_pages, nr_desc_pages);
 out:
 	if (desc)
 		unmap_fsverity_descriptor(desc, desc_pages, nr_desc_pages);
@@ -848,11 +900,17 @@ static int __init fsverity_module_init(void)
 	if (!fsverity_info_cachep)
 		goto error_free_workqueue;
 
+	err = fsverity_signature_init();
+	if (err)
+		goto error_free_info_cache;
+
 	fsverity_check_hash_algs();
 
 	pr_debug("Initialized fs-verity\n");
 	return 0;
 
+error_free_info_cache:
+	kmem_cache_destroy(fsverity_info_cachep);
 error_free_workqueue:
 	destroy_workqueue(fsverity_read_workqueue);
 error:
@@ -863,6 +921,7 @@ static void __exit fsverity_module_exit(void)
 {
 	destroy_workqueue(fsverity_read_workqueue);
 	kmem_cache_destroy(fsverity_info_cachep);
+	fsverity_signature_exit();
 	fsverity_exit_hash_algs();
 }
 
diff --git a/fs/verity/signature.c b/fs/verity/signature.c
new file mode 100644
index 0000000000000..bb8407e7914c8
--- /dev/null
+++ b/fs/verity/signature.c
@@ -0,0 +1,187 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * fs/verity/signature.c: verification of builtin signatures
+ *
+ * Copyright (C) 2018 Google LLC
+ *
+ * Written by Eric Biggers.
+ */
+
+#include "fsverity_private.h"
+
+#include <linux/cred.h>
+#include <linux/key.h>
+#include <linux/verification.h>
+
+/*
+ * /proc/sys/fs/verity/require_signatures
+ * If 1, all verity files must have a valid builtin signature.
+ */
+int fsverity_require_signatures;
+
+/*
+ * Keyring that contains the trusted X.509 certificates.
+ *
+ * Only root (kuid=0) can modify this.  Also, root may use
+ * keyctl_restrict_keyring() to prevent any more additions.
+ */
+static struct key *fsverity_keyring;
+
+static int extract_measurement(void *ctx, const void *data, size_t len,
+			       size_t asn1hdrlen)
+{
+	struct fsverity_info *vi = ctx;
+	const struct fsverity_digest_disk *d;
+	const struct fsverity_hash_alg *hash_alg;
+
+	if (len < sizeof(*d)) {
+		pr_warn("Signed file measurement has unrecognized format\n");
+		return -EBADMSG;
+	}
+	d = (const void *)data;
+
+	hash_alg = fsverity_get_hash_alg(le16_to_cpu(d->digest_algorithm));
+	if (IS_ERR(hash_alg))
+		return PTR_ERR(hash_alg);
+
+	if (le16_to_cpu(d->digest_size) != hash_alg->digest_size) {
+		pr_warn("Wrong digest_size in signed measurement: wanted %u for algorithm %s, but got %u\n",
+			hash_alg->digest_size, hash_alg->name,
+			le16_to_cpu(d->digest_size));
+		return -EBADMSG;
+	}
+
+	if (len < sizeof(*d) + hash_alg->digest_size) {
+		pr_warn("Signed file measurement is truncated\n");
+		return -EBADMSG;
+	}
+
+	if (hash_alg != vi->hash_alg) {
+		pr_warn("Signed file measurement uses %s, but file uses %s\n",
+			hash_alg->name, vi->hash_alg->name);
+		return -EBADMSG;
+	}
+
+	memcpy(vi->measurement, d->digest, hash_alg->digest_size);
+	vi->have_signed_measurement = true;
+	return 0;
+}
+
+/**
+ * fsverity_parse_pkcs7_signature_extension - verify the signed file measurement
+ *
+ * Verify a signed fsverity_measurement against the certificates in the
+ * fs-verity keyring.  The signature is given as a PKCS#7 formatted message, and
+ * the signed data is included in the message (not detached).
+ *
+ * Return: 0 if the signature checks out and the signed measurement is
+ * well-formed and uses the expected hash algorithm; -EBADMSG on signature
+ * verification failure or malformed data; else another -errno code.
+ */
+int fsverity_parse_pkcs7_signature_extension(struct fsverity_info *vi,
+					     const void *raw_pkcs7, size_t size)
+{
+	int err;
+
+	if (vi->have_signed_measurement) {
+		pr_warn("Found multiple PKCS#7 signatures\n");
+		return -EBADMSG;
+	}
+
+	if (!vi->hash_alg->cryptographic) {
+		/* Might as well check this... */
+		pr_warn("Found signed %s file measurement, but %s isn't a cryptographic hash algorithm.\n",
+			vi->hash_alg->name, vi->hash_alg->name);
+		return -EBADMSG;
+	}
+
+	err = verify_pkcs7_signature(NULL, 0, raw_pkcs7, size, fsverity_keyring,
+				     VERIFYING_UNSPECIFIED_SIGNATURE,
+				     extract_measurement, vi);
+	if (err)
+		pr_warn("PKCS#7 signature verification error: %d\n", err);
+
+	return err;
+}
+
+#ifdef CONFIG_SYSCTL
+static int zero;
+static int one = 1;
+static struct ctl_table_header *fsverity_sysctl_header;
+
+static struct ctl_path fsverity_sysctl_path[] = {
+	{ .procname = "fs", },
+	{ .procname = "verity", },
+	{ }
+};
+
+static struct ctl_table fsverity_sysctl_table[] = {
+	{
+		.procname       = "require_signatures",
+		.data           = &fsverity_require_signatures,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = proc_dointvec_minmax,
+		.extra1         = &zero,
+		.extra2         = &one,
+	},
+	{ }
+};
+
+static int __init fsverity_sysctl_init(void)
+{
+	fsverity_sysctl_header = register_sysctl_paths(fsverity_sysctl_path,
+						       fsverity_sysctl_table);
+	if (!fsverity_sysctl_header) {
+		pr_warn("sysctl registration failed!");
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+static void __exit fsverity_sysctl_exit(void)
+{
+	unregister_sysctl_table(fsverity_sysctl_header);
+}
+#else /* CONFIG_SYSCTL */
+static inline int fsverity_sysctl_init(void)
+{
+	return 0;
+}
+
+static inline void fsverity_sysctl_exit(void)
+{
+}
+#endif /* !CONFIG_SYSCTL */
+
+int __init fsverity_signature_init(void)
+{
+	struct key *ring;
+	int err;
+
+	ring = keyring_alloc(".fs-verity", KUIDT_INIT(0), KGIDT_INIT(0),
+			     current_cred(),
+			     ((KEY_POS_ALL & ~KEY_POS_SETATTR) |
+			      KEY_USR_VIEW | KEY_USR_READ |
+			      KEY_USR_WRITE | KEY_USR_SEARCH | KEY_USR_SETATTR),
+			     KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);
+	if (IS_ERR(ring))
+		return PTR_ERR(ring);
+
+	err = fsverity_sysctl_init();
+	if (err)
+		goto error_put_ring;
+
+	fsverity_keyring = ring;
+	return 0;
+
+error_put_ring:
+	key_put(ring);
+	return err;
+}
+
+void __exit fsverity_signature_exit(void)
+{
+	key_put(fsverity_keyring);
+	fsverity_sysctl_exit();
+}
diff --git a/include/uapi/linux/fsverity.h b/include/uapi/linux/fsverity.h
index b1afd205bbf87..3d97181f50a77 100644
--- a/include/uapi/linux/fsverity.h
+++ b/include/uapi/linux/fsverity.h
@@ -56,6 +56,7 @@ struct fsverity_descriptor {
 /* Extension types */
 #define FS_VERITY_EXT_ROOT_HASH		1
 #define FS_VERITY_EXT_SALT		2
+#define FS_VERITY_EXT_PKCS7_SIGNATURE	3
 
 /* Header of each extension (variable-length metadata item) */
 struct fsverity_extension {
@@ -78,6 +79,15 @@ struct fsverity_extension {
 
 /* FS_VERITY_EXT_SALT payload is just a byte array, any size */
 
+/*
+ * FS_VERITY_EXT_PKCS7_SIGNATURE payload is a DER-encoded PKCS#7 message
+ * containing the signed file measurement in the following format:
+ */
+struct fsverity_digest_disk {
+	__le16 digest_algorithm;
+	__le16 digest_size;
+	__u8 digest[];
+};
 
 /* Fields stored at the very end of the file */
 struct fsverity_footer {
-- 
2.18.0


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
