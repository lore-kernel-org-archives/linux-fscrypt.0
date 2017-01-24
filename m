Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fscrypt: split supp and notsupp declarations into their own headers
Date: Tue, 24 Jan 2017 10:58:06 -0800
Message-Id: <20170124185806.125261-1-ebiggers3@gmail.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Previously, each filesystem configured without encryption support would
define all the public fscrypt functions to their notsupp_* stubs.  This
list of #defines had to be updated in every filesystem whenever a change
was made to the public fscrypt functions.  To make things more
maintainable now that we have three filesystems using fscrypt, split the
old header fscrypto.h into several new headers.  fscrypt_supp.h contains
the real declarations and is included by filesystems when configured
with encryption support, whereas fscrypt_notsupp.h contains the inline
stubs and is included by filesystems when configured without encryption
support.  fscrypt_common.h contains common declarations needed by both.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 MAINTAINERS                     |   2 +-
 fs/crypto/fscrypt_private.h     |   2 +-
 fs/ext4/ext4.h                  |  28 +---
 fs/ext4/page-io.c               |   1 -
 fs/f2fs/f2fs.h                  |  30 +---
 fs/ubifs/ubifs.h                |  28 +---
 include/linux/fscrypt_common.h  | 146 +++++++++++++++++
 include/linux/fscrypt_notsupp.h | 168 +++++++++++++++++++
 include/linux/fscrypt_supp.h    |  66 ++++++++
 include/linux/fscrypto.h        | 347 ----------------------------------------
 10 files changed, 397 insertions(+), 421 deletions(-)
 create mode 100644 include/linux/fscrypt_common.h
 create mode 100644 include/linux/fscrypt_notsupp.h
 create mode 100644 include/linux/fscrypt_supp.h
 delete mode 100644 include/linux/fscrypto.h

diff --git a/MAINTAINERS b/MAINTAINERS
index cfff2c9e3d94..4d20b03648fa 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5268,7 +5268,7 @@ M:	Jaegeuk Kim <jaegeuk@kernel.org>
 L:	linux-fsdevel@vger.kernel.org
 S:	Supported
 F:	fs/crypto/
-F:	include/linux/fscrypto.h
+F:	include/linux/fscrypt*.h
 
 F2FS FILE SYSTEM
 M:	Jaegeuk Kim <jaegeuk@kernel.org>
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 7bff7b4c7498..e8a229e1d45d 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -11,7 +11,7 @@
 #ifndef _FSCRYPT_PRIVATE_H
 #define _FSCRYPT_PRIVATE_H
 
-#include <linux/fscrypto.h>
+#include <linux/fscrypt_supp.h>
 
 #define FS_FNAME_CRYPTO_DIGEST_SIZE	32
 
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 6bcb9622fdf9..a5c756b80b7d 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -32,7 +32,11 @@
 #include <linux/percpu_counter.h>
 #include <linux/ratelimit.h>
 #include <crypto/hash.h>
-#include <linux/fscrypto.h>
+#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#include <linux/fscrypt_supp.h>
+#else
+#include <linux/fscrypt_notsupp.h>
+#endif
 #include <linux/falloc.h>
 #include <linux/percpu-rwsem.h>
 #ifdef __KERNEL__
@@ -2309,28 +2313,6 @@ static inline int ext4_fname_setup_filename(struct inode *dir,
 }
 static inline void ext4_fname_free_filename(struct ext4_filename *fname) { }
 
-#define fscrypt_set_d_op(i)
-#define fscrypt_get_ctx			fscrypt_notsupp_get_ctx
-#define fscrypt_release_ctx		fscrypt_notsupp_release_ctx
-#define fscrypt_encrypt_page		fscrypt_notsupp_encrypt_page
-#define fscrypt_decrypt_page		fscrypt_notsupp_decrypt_page
-#define fscrypt_decrypt_bio_pages	fscrypt_notsupp_decrypt_bio_pages
-#define fscrypt_pullback_bio_page	fscrypt_notsupp_pullback_bio_page
-#define fscrypt_restore_control_page	fscrypt_notsupp_restore_control_page
-#define fscrypt_zeroout_range		fscrypt_notsupp_zeroout_range
-#define fscrypt_ioctl_set_policy	fscrypt_notsupp_ioctl_set_policy
-#define fscrypt_ioctl_get_policy	fscrypt_notsupp_ioctl_get_policy
-#define fscrypt_has_permitted_context	fscrypt_notsupp_has_permitted_context
-#define fscrypt_inherit_context		fscrypt_notsupp_inherit_context
-#define fscrypt_get_encryption_info	fscrypt_notsupp_get_encryption_info
-#define fscrypt_put_encryption_info	fscrypt_notsupp_put_encryption_info
-#define fscrypt_setup_filename		fscrypt_notsupp_setup_filename
-#define fscrypt_free_filename		fscrypt_notsupp_free_filename
-#define fscrypt_fname_encrypted_size	fscrypt_notsupp_fname_encrypted_size
-#define fscrypt_fname_alloc_buffer	fscrypt_notsupp_fname_alloc_buffer
-#define fscrypt_fname_free_buffer	fscrypt_notsupp_fname_free_buffer
-#define fscrypt_fname_disk_to_usr	fscrypt_notsupp_fname_disk_to_usr
-#define fscrypt_fname_usr_to_disk	fscrypt_notsupp_fname_usr_to_disk
 #endif
 
 /* dir.c */
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index d83b0f3c5fe9..e55624c50898 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -24,7 +24,6 @@
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/backing-dev.h>
-#include <linux/fscrypto.h>
 
 #include "ext4_jbd2.h"
 #include "xattr.h"
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 93d38d854a41..069fc7277d8d 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -22,7 +22,11 @@
 #include <linux/vmalloc.h>
 #include <linux/bio.h>
 #include <linux/blkdev.h>
-#include <linux/fscrypto.h>
+#ifdef CONFIG_F2FS_FS_ENCRYPTION
+#include <linux/fscrypt_supp.h>
+#else
+#include <linux/fscrypt_notsupp.h>
+#endif
 #include <crypto/hash.h>
 
 #ifdef CONFIG_F2FS_CHECK_FS
@@ -2501,28 +2505,4 @@ static inline bool f2fs_may_encrypt(struct inode *inode)
 #endif
 }
 
-#ifndef CONFIG_F2FS_FS_ENCRYPTION
-#define fscrypt_set_d_op(i)
-#define fscrypt_get_ctx			fscrypt_notsupp_get_ctx
-#define fscrypt_release_ctx		fscrypt_notsupp_release_ctx
-#define fscrypt_encrypt_page		fscrypt_notsupp_encrypt_page
-#define fscrypt_decrypt_page		fscrypt_notsupp_decrypt_page
-#define fscrypt_decrypt_bio_pages	fscrypt_notsupp_decrypt_bio_pages
-#define fscrypt_pullback_bio_page	fscrypt_notsupp_pullback_bio_page
-#define fscrypt_restore_control_page	fscrypt_notsupp_restore_control_page
-#define fscrypt_zeroout_range		fscrypt_notsupp_zeroout_range
-#define fscrypt_ioctl_set_policy	fscrypt_notsupp_ioctl_set_policy
-#define fscrypt_ioctl_get_policy	fscrypt_notsupp_ioctl_get_policy
-#define fscrypt_has_permitted_context	fscrypt_notsupp_has_permitted_context
-#define fscrypt_inherit_context		fscrypt_notsupp_inherit_context
-#define fscrypt_get_encryption_info	fscrypt_notsupp_get_encryption_info
-#define fscrypt_put_encryption_info	fscrypt_notsupp_put_encryption_info
-#define fscrypt_setup_filename		fscrypt_notsupp_setup_filename
-#define fscrypt_free_filename		fscrypt_notsupp_free_filename
-#define fscrypt_fname_encrypted_size	fscrypt_notsupp_fname_encrypted_size
-#define fscrypt_fname_alloc_buffer	fscrypt_notsupp_fname_alloc_buffer
-#define fscrypt_fname_free_buffer	fscrypt_notsupp_fname_free_buffer
-#define fscrypt_fname_disk_to_usr	fscrypt_notsupp_fname_disk_to_usr
-#define fscrypt_fname_usr_to_disk	fscrypt_notsupp_fname_usr_to_disk
-#endif
 #endif
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index ca72382ce6cc..d9df379bacc6 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -38,7 +38,11 @@
 #include <linux/backing-dev.h>
 #include <linux/security.h>
 #include <linux/xattr.h>
-#include <linux/fscrypto.h>
+#ifdef CONFIG_UBIFS_FS_ENCRYPTION
+#include <linux/fscrypt_supp.h>
+#else
+#include <linux/fscrypt_notsupp.h>
+#endif
 #include <linux/random.h>
 #include "ubifs-media.h"
 
@@ -1797,28 +1801,6 @@ int ubifs_decompress(const struct ubifs_info *c, const void *buf, int len,
 #include "key.h"
 
 #ifndef CONFIG_UBIFS_FS_ENCRYPTION
-#define fscrypt_set_d_op(i)
-#define fscrypt_get_ctx                 fscrypt_notsupp_get_ctx
-#define fscrypt_release_ctx             fscrypt_notsupp_release_ctx
-#define fscrypt_encrypt_page            fscrypt_notsupp_encrypt_page
-#define fscrypt_decrypt_page            fscrypt_notsupp_decrypt_page
-#define fscrypt_decrypt_bio_pages       fscrypt_notsupp_decrypt_bio_pages
-#define fscrypt_pullback_bio_page       fscrypt_notsupp_pullback_bio_page
-#define fscrypt_restore_control_page    fscrypt_notsupp_restore_control_page
-#define fscrypt_zeroout_range           fscrypt_notsupp_zeroout_range
-#define fscrypt_ioctl_set_policy	fscrypt_notsupp_ioctl_set_policy
-#define fscrypt_ioctl_get_policy	fscrypt_notsupp_ioctl_get_policy
-#define fscrypt_has_permitted_context   fscrypt_notsupp_has_permitted_context
-#define fscrypt_inherit_context         fscrypt_notsupp_inherit_context
-#define fscrypt_get_encryption_info     fscrypt_notsupp_get_encryption_info
-#define fscrypt_put_encryption_info     fscrypt_notsupp_put_encryption_info
-#define fscrypt_setup_filename          fscrypt_notsupp_setup_filename
-#define fscrypt_free_filename           fscrypt_notsupp_free_filename
-#define fscrypt_fname_encrypted_size    fscrypt_notsupp_fname_encrypted_size
-#define fscrypt_fname_alloc_buffer      fscrypt_notsupp_fname_alloc_buffer
-#define fscrypt_fname_free_buffer       fscrypt_notsupp_fname_free_buffer
-#define fscrypt_fname_disk_to_usr       fscrypt_notsupp_fname_disk_to_usr
-#define fscrypt_fname_usr_to_disk       fscrypt_notsupp_fname_usr_to_disk
 static inline int ubifs_encrypt(const struct inode *inode,
 				struct ubifs_data_node *dn,
 				unsigned int in_len, unsigned int *out_len,
diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt_common.h
new file mode 100644
index 000000000000..547f81592ba1
--- /dev/null
+++ b/include/linux/fscrypt_common.h
@@ -0,0 +1,146 @@
+/*
+ * fscrypt_common.h: common declarations for per-file encryption
+ *
+ * Copyright (C) 2015, Google, Inc.
+ *
+ * Written by Michael Halcrow, 2015.
+ * Modified by Jaegeuk Kim, 2015.
+ */
+
+#ifndef _LINUX_FSCRYPT_COMMON_H
+#define _LINUX_FSCRYPT_COMMON_H
+
+#include <linux/key.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/bio.h>
+#include <linux/dcache.h>
+#include <crypto/skcipher.h>
+#include <uapi/linux/fs.h>
+
+#define FS_CRYPTO_BLOCK_SIZE		16
+
+struct fscrypt_info;
+
+struct fscrypt_ctx {
+	union {
+		struct {
+			struct page *bounce_page;	/* Ciphertext page */
+			struct page *control_page;	/* Original page  */
+		} w;
+		struct {
+			struct bio *bio;
+			struct work_struct work;
+		} r;
+		struct list_head free_list;	/* Free list */
+	};
+	u8 flags;				/* Flags */
+};
+
+/**
+ * For encrypted symlinks, the ciphertext length is stored at the beginning
+ * of the string in little-endian format.
+ */
+struct fscrypt_symlink_data {
+	__le16 len;
+	char encrypted_path[1];
+} __packed;
+
+/**
+ * This function is used to calculate the disk space required to
+ * store a filename of length l in encrypted symlink format.
+ */
+static inline u32 fscrypt_symlink_data_len(u32 l)
+{
+	if (l < FS_CRYPTO_BLOCK_SIZE)
+		l = FS_CRYPTO_BLOCK_SIZE;
+	return (l + sizeof(struct fscrypt_symlink_data) - 1);
+}
+
+struct fscrypt_str {
+	unsigned char *name;
+	u32 len;
+};
+
+struct fscrypt_name {
+	const struct qstr *usr_fname;
+	struct fscrypt_str disk_name;
+	u32 hash;
+	u32 minor_hash;
+	struct fscrypt_str crypto_buf;
+};
+
+#define FSTR_INIT(n, l)		{ .name = n, .len = l }
+#define FSTR_TO_QSTR(f)		QSTR_INIT((f)->name, (f)->len)
+#define fname_name(p)		((p)->disk_name.name)
+#define fname_len(p)		((p)->disk_name.len)
+
+/*
+ * fscrypt superblock flags
+ */
+#define FS_CFLG_OWN_PAGES (1U << 1)
+
+/*
+ * crypto opertions for filesystems
+ */
+struct fscrypt_operations {
+	unsigned int flags;
+	const char *key_prefix;
+	int (*get_context)(struct inode *, void *, size_t);
+	int (*prepare_context)(struct inode *);
+	int (*set_context)(struct inode *, const void *, size_t, void *);
+	int (*dummy_context)(struct inode *);
+	bool (*is_encrypted)(struct inode *);
+	bool (*empty_dir)(struct inode *);
+	unsigned (*max_namelen)(struct inode *);
+};
+
+static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
+{
+	if (inode->i_sb->s_cop->dummy_context &&
+				inode->i_sb->s_cop->dummy_context(inode))
+		return true;
+	return false;
+}
+
+static inline bool fscrypt_valid_contents_enc_mode(u32 mode)
+{
+	return (mode == FS_ENCRYPTION_MODE_AES_256_XTS);
+}
+
+static inline bool fscrypt_valid_filenames_enc_mode(u32 mode)
+{
+	return (mode == FS_ENCRYPTION_MODE_AES_256_CTS);
+}
+
+static inline bool fscrypt_is_dot_dotdot(const struct qstr *str)
+{
+	if (str->len == 1 && str->name[0] == '.')
+		return true;
+
+	if (str->len == 2 && str->name[0] == '.' && str->name[1] == '.')
+		return true;
+
+	return false;
+}
+
+static inline struct page *fscrypt_control_page(struct page *page)
+{
+#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
+	return ((struct fscrypt_ctx *)page_private(page))->w.control_page;
+#else
+	WARN_ON_ONCE(1);
+	return ERR_PTR(-EINVAL);
+#endif
+}
+
+static inline int fscrypt_has_encryption_key(const struct inode *inode)
+{
+#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
+	return (inode->i_crypt_info != NULL);
+#else
+	return 0;
+#endif
+}
+
+#endif	/* _LINUX_FSCRYPT_COMMON_H */
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
new file mode 100644
index 000000000000..3511ca798804
--- /dev/null
+++ b/include/linux/fscrypt_notsupp.h
@@ -0,0 +1,168 @@
+/*
+ * fscrypt_notsupp.h
+ *
+ * This stubs out the fscrypt functions for filesystems configured without
+ * encryption support.
+ */
+
+#ifndef _LINUX_FSCRYPT_NOTSUPP_H
+#define _LINUX_FSCRYPT_NOTSUPP_H
+
+#include <linux/fscrypt_common.h>
+
+/* crypto.c */
+static inline struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode,
+						  gfp_t gfp_flags)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static inline void fscrypt_release_ctx(struct fscrypt_ctx *ctx)
+{
+	return;
+}
+
+static inline struct page *fscrypt_encrypt_page(const struct inode *inode,
+						struct page *page,
+						unsigned int len,
+						unsigned int offs,
+						u64 lblk_num, gfp_t gfp_flags)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static inline int fscrypt_decrypt_page(const struct inode *inode,
+				       struct page *page,
+				       unsigned int len, unsigned int offs,
+				       u64 lblk_num)
+{
+	return -EOPNOTSUPP;
+}
+
+
+static inline void fscrypt_restore_control_page(struct page *page)
+{
+	return;
+}
+
+static inline void fscrypt_set_d_op(struct dentry *dentry)
+{
+	return;
+}
+
+static inline void fscrypt_set_encrypted_dentry(struct dentry *dentry)
+{
+	return;
+}
+
+/* policy.c */
+static inline int fscrypt_ioctl_set_policy(struct file *filp,
+					   const void __user *arg)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int fscrypt_ioctl_get_policy(struct file *filp, void __user *arg)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int fscrypt_has_permitted_context(struct inode *parent,
+						struct inode *child)
+{
+	return 0;
+}
+
+static inline int fscrypt_inherit_context(struct inode *parent,
+					  struct inode *child,
+					  void *fs_data, bool preload)
+{
+	return -EOPNOTSUPP;
+}
+
+/* keyinfo.c */
+static inline int fscrypt_get_encryption_info(struct inode *inode)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void fscrypt_put_encryption_info(struct inode *inode,
+					       struct fscrypt_info *ci)
+{
+	return;
+}
+
+ /* fname.c */
+static inline int fscrypt_setup_filename(struct inode *dir,
+					 const struct qstr *iname,
+					 int lookup, struct fscrypt_name *fname)
+{
+	if (dir->i_sb->s_cop->is_encrypted(dir))
+		return -EOPNOTSUPP;
+
+	memset(fname, 0, sizeof(struct fscrypt_name));
+	fname->usr_fname = iname;
+	fname->disk_name.name = (unsigned char *)iname->name;
+	fname->disk_name.len = iname->len;
+	return 0;
+}
+
+static inline void fscrypt_free_filename(struct fscrypt_name *fname)
+{
+	return;
+}
+
+static inline u32 fscrypt_fname_encrypted_size(const struct inode *inode,
+					       u32 ilen)
+{
+	/* never happens */
+	WARN_ON(1);
+	return 0;
+}
+
+static inline int fscrypt_fname_alloc_buffer(const struct inode *inode,
+					     u32 ilen,
+					     struct fscrypt_str *crypto_str)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline void fscrypt_fname_free_buffer(struct fscrypt_str *crypto_str)
+{
+	return;
+}
+
+static inline int fscrypt_fname_disk_to_usr(struct inode *inode,
+					    u32 hash, u32 minor_hash,
+					    const struct fscrypt_str *iname,
+					    struct fscrypt_str *oname)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int fscrypt_fname_usr_to_disk(struct inode *inode,
+					    const struct qstr *iname,
+					    struct fscrypt_str *oname)
+{
+	return -EOPNOTSUPP;
+}
+
+/* bio.c */
+static inline void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *ctx,
+					     struct bio *bio)
+{
+	return;
+}
+
+static inline void fscrypt_pullback_bio_page(struct page **page, bool restore)
+{
+	return;
+}
+
+static inline int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
+					sector_t pblk, unsigned int len)
+{
+	return -EOPNOTSUPP;
+}
+
+#endif	/* _LINUX_FSCRYPT_NOTSUPP_H */
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
new file mode 100644
index 000000000000..a140f47e9b27
--- /dev/null
+++ b/include/linux/fscrypt_supp.h
@@ -0,0 +1,66 @@
+/*
+ * fscrypt_supp.h
+ *
+ * This is included by filesystems configured with encryption support.
+ */
+
+#ifndef _LINUX_FSCRYPT_SUPP_H
+#define _LINUX_FSCRYPT_SUPP_H
+
+#include <linux/fscrypt_common.h>
+
+/* crypto.c */
+extern struct kmem_cache *fscrypt_info_cachep;
+extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
+extern void fscrypt_release_ctx(struct fscrypt_ctx *);
+extern struct page *fscrypt_encrypt_page(const struct inode *, struct page *,
+						unsigned int, unsigned int,
+						u64, gfp_t);
+extern int fscrypt_decrypt_page(const struct inode *, struct page *, unsigned int,
+				unsigned int, u64);
+extern void fscrypt_restore_control_page(struct page *);
+
+extern const struct dentry_operations fscrypt_d_ops;
+
+static inline void fscrypt_set_d_op(struct dentry *dentry)
+{
+	d_set_d_op(dentry, &fscrypt_d_ops);
+}
+
+static inline void fscrypt_set_encrypted_dentry(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	dentry->d_flags |= DCACHE_ENCRYPTED_WITH_KEY;
+	spin_unlock(&dentry->d_lock);
+}
+
+/* policy.c */
+extern int fscrypt_ioctl_set_policy(struct file *, const void __user *);
+extern int fscrypt_ioctl_get_policy(struct file *, void __user *);
+extern int fscrypt_has_permitted_context(struct inode *, struct inode *);
+extern int fscrypt_inherit_context(struct inode *, struct inode *,
+					void *, bool);
+/* keyinfo.c */
+extern int fscrypt_get_encryption_info(struct inode *);
+extern void fscrypt_put_encryption_info(struct inode *, struct fscrypt_info *);
+
+/* fname.c */
+extern int fscrypt_setup_filename(struct inode *, const struct qstr *,
+				int lookup, struct fscrypt_name *);
+extern void fscrypt_free_filename(struct fscrypt_name *);
+extern u32 fscrypt_fname_encrypted_size(const struct inode *, u32);
+extern int fscrypt_fname_alloc_buffer(const struct inode *, u32,
+				struct fscrypt_str *);
+extern void fscrypt_fname_free_buffer(struct fscrypt_str *);
+extern int fscrypt_fname_disk_to_usr(struct inode *, u32, u32,
+			const struct fscrypt_str *, struct fscrypt_str *);
+extern int fscrypt_fname_usr_to_disk(struct inode *, const struct qstr *,
+			struct fscrypt_str *);
+
+/* bio.c */
+extern void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *, struct bio *);
+extern void fscrypt_pullback_bio_page(struct page **, bool);
+extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
+				 unsigned int);
+
+#endif	/* _LINUX_FSCRYPT_SUPP_H */
diff --git a/include/linux/fscrypto.h b/include/linux/fscrypto.h
deleted file mode 100644
index 715f17b3c6d7..000000000000
--- a/include/linux/fscrypto.h
+++ /dev/null
@@ -1,347 +0,0 @@
-/*
- * General per-file encryption definition
- *
- * Copyright (C) 2015, Google, Inc.
- *
- * Written by Michael Halcrow, 2015.
- * Modified by Jaegeuk Kim, 2015.
- */
-
-#ifndef _LINUX_FSCRYPTO_H
-#define _LINUX_FSCRYPTO_H
-
-#include <linux/key.h>
-#include <linux/fs.h>
-#include <linux/mm.h>
-#include <linux/bio.h>
-#include <linux/dcache.h>
-#include <crypto/skcipher.h>
-#include <uapi/linux/fs.h>
-
-#define FS_CRYPTO_BLOCK_SIZE		16
-
-struct fscrypt_info;
-
-struct fscrypt_ctx {
-	union {
-		struct {
-			struct page *bounce_page;	/* Ciphertext page */
-			struct page *control_page;	/* Original page  */
-		} w;
-		struct {
-			struct bio *bio;
-			struct work_struct work;
-		} r;
-		struct list_head free_list;	/* Free list */
-	};
-	u8 flags;				/* Flags */
-};
-
-/**
- * For encrypted symlinks, the ciphertext length is stored at the beginning
- * of the string in little-endian format.
- */
-struct fscrypt_symlink_data {
-	__le16 len;
-	char encrypted_path[1];
-} __packed;
-
-/**
- * This function is used to calculate the disk space required to
- * store a filename of length l in encrypted symlink format.
- */
-static inline u32 fscrypt_symlink_data_len(u32 l)
-{
-	if (l < FS_CRYPTO_BLOCK_SIZE)
-		l = FS_CRYPTO_BLOCK_SIZE;
-	return (l + sizeof(struct fscrypt_symlink_data) - 1);
-}
-
-struct fscrypt_str {
-	unsigned char *name;
-	u32 len;
-};
-
-struct fscrypt_name {
-	const struct qstr *usr_fname;
-	struct fscrypt_str disk_name;
-	u32 hash;
-	u32 minor_hash;
-	struct fscrypt_str crypto_buf;
-};
-
-#define FSTR_INIT(n, l)		{ .name = n, .len = l }
-#define FSTR_TO_QSTR(f)		QSTR_INIT((f)->name, (f)->len)
-#define fname_name(p)		((p)->disk_name.name)
-#define fname_len(p)		((p)->disk_name.len)
-
-/*
- * fscrypt superblock flags
- */
-#define FS_CFLG_OWN_PAGES (1U << 1)
-
-/*
- * crypto opertions for filesystems
- */
-struct fscrypt_operations {
-	unsigned int flags;
-	const char *key_prefix;
-	int (*get_context)(struct inode *, void *, size_t);
-	int (*prepare_context)(struct inode *);
-	int (*set_context)(struct inode *, const void *, size_t, void *);
-	int (*dummy_context)(struct inode *);
-	bool (*is_encrypted)(struct inode *);
-	bool (*empty_dir)(struct inode *);
-	unsigned (*max_namelen)(struct inode *);
-};
-
-static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
-{
-	if (inode->i_sb->s_cop->dummy_context &&
-				inode->i_sb->s_cop->dummy_context(inode))
-		return true;
-	return false;
-}
-
-static inline bool fscrypt_valid_contents_enc_mode(u32 mode)
-{
-	return (mode == FS_ENCRYPTION_MODE_AES_256_XTS);
-}
-
-static inline bool fscrypt_valid_filenames_enc_mode(u32 mode)
-{
-	return (mode == FS_ENCRYPTION_MODE_AES_256_CTS);
-}
-
-static inline bool fscrypt_is_dot_dotdot(const struct qstr *str)
-{
-	if (str->len == 1 && str->name[0] == '.')
-		return true;
-
-	if (str->len == 2 && str->name[0] == '.' && str->name[1] == '.')
-		return true;
-
-	return false;
-}
-
-static inline struct page *fscrypt_control_page(struct page *page)
-{
-#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
-	return ((struct fscrypt_ctx *)page_private(page))->w.control_page;
-#else
-	WARN_ON_ONCE(1);
-	return ERR_PTR(-EINVAL);
-#endif
-}
-
-static inline int fscrypt_has_encryption_key(const struct inode *inode)
-{
-#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
-	return (inode->i_crypt_info != NULL);
-#else
-	return 0;
-#endif
-}
-
-static inline void fscrypt_set_encrypted_dentry(struct dentry *dentry)
-{
-#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
-	spin_lock(&dentry->d_lock);
-	dentry->d_flags |= DCACHE_ENCRYPTED_WITH_KEY;
-	spin_unlock(&dentry->d_lock);
-#endif
-}
-
-#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
-extern const struct dentry_operations fscrypt_d_ops;
-#endif
-
-static inline void fscrypt_set_d_op(struct dentry *dentry)
-{
-#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
-	d_set_d_op(dentry, &fscrypt_d_ops);
-#endif
-}
-
-#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
-/* crypto.c */
-extern struct kmem_cache *fscrypt_info_cachep;
-extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
-extern void fscrypt_release_ctx(struct fscrypt_ctx *);
-extern struct page *fscrypt_encrypt_page(const struct inode *, struct page *,
-						unsigned int, unsigned int,
-						u64, gfp_t);
-extern int fscrypt_decrypt_page(const struct inode *, struct page *, unsigned int,
-				unsigned int, u64);
-extern void fscrypt_restore_control_page(struct page *);
-
-/* policy.c */
-extern int fscrypt_ioctl_set_policy(struct file *, const void __user *);
-extern int fscrypt_ioctl_get_policy(struct file *, void __user *);
-extern int fscrypt_has_permitted_context(struct inode *, struct inode *);
-extern int fscrypt_inherit_context(struct inode *, struct inode *,
-					void *, bool);
-/* keyinfo.c */
-extern int fscrypt_get_encryption_info(struct inode *);
-extern void fscrypt_put_encryption_info(struct inode *, struct fscrypt_info *);
-
-/* fname.c */
-extern int fscrypt_setup_filename(struct inode *, const struct qstr *,
-				int lookup, struct fscrypt_name *);
-extern void fscrypt_free_filename(struct fscrypt_name *);
-extern u32 fscrypt_fname_encrypted_size(const struct inode *, u32);
-extern int fscrypt_fname_alloc_buffer(const struct inode *, u32,
-				struct fscrypt_str *);
-extern void fscrypt_fname_free_buffer(struct fscrypt_str *);
-extern int fscrypt_fname_disk_to_usr(struct inode *, u32, u32,
-			const struct fscrypt_str *, struct fscrypt_str *);
-extern int fscrypt_fname_usr_to_disk(struct inode *, const struct qstr *,
-			struct fscrypt_str *);
-
-/* bio.c */
-extern void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *, struct bio *);
-extern void fscrypt_pullback_bio_page(struct page **, bool);
-extern int fscrypt_zeroout_range(const struct inode *, pgoff_t, sector_t,
-				 unsigned int);
-#endif
-
-/* crypto.c */
-static inline struct fscrypt_ctx *fscrypt_notsupp_get_ctx(const struct inode *i,
-							gfp_t f)
-{
-	return ERR_PTR(-EOPNOTSUPP);
-}
-
-static inline void fscrypt_notsupp_release_ctx(struct fscrypt_ctx *c)
-{
-	return;
-}
-
-static inline struct page *fscrypt_notsupp_encrypt_page(const struct inode *i,
-						struct page *p,
-						unsigned int len,
-						unsigned int offs,
-						u64 lblk_num, gfp_t f)
-{
-	return ERR_PTR(-EOPNOTSUPP);
-}
-
-static inline int fscrypt_notsupp_decrypt_page(const struct inode *i, struct page *p,
-						unsigned int len, unsigned int offs,
-						u64 lblk_num)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline void fscrypt_notsupp_decrypt_bio_pages(struct fscrypt_ctx *c,
-						struct bio *b)
-{
-	return;
-}
-
-static inline void fscrypt_notsupp_pullback_bio_page(struct page **p, bool b)
-{
-	return;
-}
-
-static inline void fscrypt_notsupp_restore_control_page(struct page *p)
-{
-	return;
-}
-
-static inline int fscrypt_notsupp_zeroout_range(const struct inode *i, pgoff_t p,
-					sector_t s, unsigned int f)
-{
-	return -EOPNOTSUPP;
-}
-
-/* policy.c */
-static inline int fscrypt_notsupp_ioctl_set_policy(struct file *f,
-				const void __user *arg)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int fscrypt_notsupp_ioctl_get_policy(struct file *f,
-				void __user *arg)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int fscrypt_notsupp_has_permitted_context(struct inode *p,
-				struct inode *i)
-{
-	return 0;
-}
-
-static inline int fscrypt_notsupp_inherit_context(struct inode *p,
-				struct inode *i, void *v, bool b)
-{
-	return -EOPNOTSUPP;
-}
-
-/* keyinfo.c */
-static inline int fscrypt_notsupp_get_encryption_info(struct inode *i)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline void fscrypt_notsupp_put_encryption_info(struct inode *i,
-					struct fscrypt_info *f)
-{
-	return;
-}
-
- /* fname.c */
-static inline int fscrypt_notsupp_setup_filename(struct inode *dir,
-			const struct qstr *iname,
-			int lookup, struct fscrypt_name *fname)
-{
-	if (dir->i_sb->s_cop->is_encrypted(dir))
-		return -EOPNOTSUPP;
-
-	memset(fname, 0, sizeof(struct fscrypt_name));
-	fname->usr_fname = iname;
-	fname->disk_name.name = (unsigned char *)iname->name;
-	fname->disk_name.len = iname->len;
-	return 0;
-}
-
-static inline void fscrypt_notsupp_free_filename(struct fscrypt_name *fname)
-{
-	return;
-}
-
-static inline u32 fscrypt_notsupp_fname_encrypted_size(struct inode *i, u32 s)
-{
-	/* never happens */
-	WARN_ON(1);
-	return 0;
-}
-
-static inline int fscrypt_notsupp_fname_alloc_buffer(struct inode *inode,
-				u32 ilen, struct fscrypt_str *crypto_str)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline void fscrypt_notsupp_fname_free_buffer(struct fscrypt_str *c)
-{
-	return;
-}
-
-static inline int fscrypt_notsupp_fname_disk_to_usr(struct inode *inode,
-			u32 hash, u32 minor_hash,
-			const struct fscrypt_str *iname,
-			struct fscrypt_str *oname)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int fscrypt_notsupp_fname_usr_to_disk(struct inode *inode,
-			const struct qstr *iname,
-			struct fscrypt_str *oname)
-{
-	return -EOPNOTSUPP;
-}
-#endif	/* _LINUX_FSCRYPTO_H */
-- 
2.11.0.483.g087da7b7c-goog
