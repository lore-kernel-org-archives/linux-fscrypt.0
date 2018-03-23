Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 12/14] fscrypt: use a common logging function
Date: Fri, 23 Mar 2018 12:23:56 -0700
Message-Id: <20180323192358.95691-13-ebiggers3@gmail.com>
In-Reply-To: <20180323192358.95691-1-ebiggers3@gmail.com>
References: <20180323192358.95691-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Use a common function for fscrypt warning and error messages so that all
the messages are consistently ratelimited, include the "fscrypt:"
prefix, and include the filesystem name if applicable.

Also fix up a few of the log messages to be more descriptive.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/crypto.c          | 28 +++++++++++++++++++++++++---
 fs/crypto/fname.c           | 10 ++++++----
 fs/crypto/fscrypt_private.h |  8 ++++++++
 fs/crypto/hooks.c           |  5 +++--
 fs/crypto/keyinfo.c         | 27 +++++++++++++++------------
 5 files changed, 57 insertions(+), 21 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index d22887f689ad..a40d7d73b633 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -174,9 +174,10 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 		res = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
 	skcipher_request_free(req);
 	if (res) {
-		printk_ratelimited(KERN_ERR
-			"%s: crypto_skcipher_encrypt() returned %d\n",
-			__func__, res);
+		fscrypt_err(inode->i_sb,
+			    "%scryption failed for inode %lu, block %llu: %d",
+			    (rw == FS_DECRYPT ? "de" : "en"),
+			    inode->i_ino, lblk_num, res);
 		return res;
 	}
 	return 0;
@@ -416,6 +417,27 @@ int fscrypt_initialize(unsigned int cop_flags)
 	return res;
 }
 
+void fscrypt_msg(struct super_block *sb, const char *level,
+		 const char *fmt, ...)
+{
+	static DEFINE_RATELIMIT_STATE(rs, DEFAULT_RATELIMIT_INTERVAL,
+				      DEFAULT_RATELIMIT_BURST);
+	struct va_format vaf;
+	va_list args;
+
+	if (!__ratelimit(&rs))
+		return;
+
+	va_start(args, fmt);
+	vaf.fmt = fmt;
+	vaf.va = &args;
+	if (sb)
+		printk("%sfscrypt (%s): %pV\n", level, sb->s_id, &vaf);
+	else
+		printk("%sfscrypt: %pV\n", level, &vaf);
+	va_end(args);
+}
+
 /**
  * fscrypt_init() - Set up for fs encryption.
  */
diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 39091fc31e98..d7a0f682ca12 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -71,8 +71,9 @@ int fname_encrypt(struct inode *inode, const struct qstr *iname,
 	res = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
 	skcipher_request_free(req);
 	if (res < 0) {
-		printk_ratelimited(KERN_ERR
-				"%s: Error (error code %d)\n", __func__, res);
+		fscrypt_err(inode->i_sb,
+			    "Filename encryption failed for inode %lu: %d",
+			    inode->i_ino, res);
 		return res;
 	}
 
@@ -115,8 +116,9 @@ static int fname_decrypt(struct inode *inode,
 	res = crypto_wait_req(crypto_skcipher_decrypt(req), &wait);
 	skcipher_request_free(req);
 	if (res < 0) {
-		printk_ratelimited(KERN_ERR
-				"%s: Error (error code %d)\n", __func__, res);
+		fscrypt_err(inode->i_sb,
+			    "Filename decryption failed for inode %lu: %d",
+			    inode->i_ino, res);
 		return res;
 	}
 
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index a3697397e190..37562394c5de 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -104,6 +104,14 @@ extern struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
 					      gfp_t gfp_flags);
 extern const struct dentry_operations fscrypt_d_ops;
 
+extern void __printf(3, 4) __cold
+fscrypt_msg(struct super_block *sb, const char *level, const char *fmt, ...);
+
+#define fscrypt_warn(sb, fmt, ...)		\
+	fscrypt_msg(sb, KERN_WARNING, fmt, ##__VA_ARGS__)
+#define fscrypt_err(sb, fmt, ...)		\
+	fscrypt_msg(sb, KERN_ERR, fmt, ##__VA_ARGS__)
+
 /* fname.c */
 extern int fname_encrypt(struct inode *inode, const struct qstr *iname,
 			 u8 *out, unsigned int olen);
diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index bec06490fb13..926e5df20ec3 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -39,8 +39,9 @@ int fscrypt_file_open(struct inode *inode, struct file *filp)
 	dir = dget_parent(file_dentry(filp));
 	if (IS_ENCRYPTED(d_inode(dir)) &&
 	    !fscrypt_has_permitted_context(d_inode(dir), inode)) {
-		pr_warn_ratelimited("fscrypt: inconsistent encryption contexts: %lu/%lu",
-				    d_inode(dir)->i_ino, inode->i_ino);
+		fscrypt_warn(inode->i_sb,
+			     "inconsistent encryption contexts: %lu/%lu",
+			     d_inode(dir)->i_ino, inode->i_ino);
 		err = -EPERM;
 	}
 	dput(dir);
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 0a134f985681..477e2d1fa04e 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -103,9 +103,8 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
 
 	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
 	    || master_key->size % AES_BLOCK_SIZE != 0) {
-		printk_once(KERN_WARNING
-				"%s: key size incorrect: %d\n",
-				__func__, master_key->size);
+		fscrypt_warn(NULL, "key size incorrect: %u",
+			     master_key->size);
 		res = -ENOKEY;
 		goto out;
 	}
@@ -134,9 +133,10 @@ static int determine_cipher_type(struct fscrypt_info *ci, struct inode *inode,
 	u32 mode;
 
 	if (!fscrypt_valid_enc_modes(ci->ci_data_mode, ci->ci_filename_mode)) {
-		pr_warn_ratelimited("fscrypt: inode %lu uses unsupported encryption modes (contents mode %d, filenames mode %d)\n",
-				    inode->i_ino,
-				    ci->ci_data_mode, ci->ci_filename_mode);
+		fscrypt_warn(inode->i_sb,
+			     "inode %lu uses unsupported encryption modes (contents mode %d, filenames mode %d)",
+			     inode->i_ino, ci->ci_data_mode,
+			     ci->ci_filename_mode);
 		return -EINVAL;
 	}
 
@@ -175,8 +175,9 @@ static int derive_essiv_salt(const u8 *key, int keysize, u8 *salt)
 
 		tfm = crypto_alloc_shash("sha256", 0, 0);
 		if (IS_ERR(tfm)) {
-			pr_warn_ratelimited("fscrypt: error allocating SHA-256 transform: %ld\n",
-					    PTR_ERR(tfm));
+			fscrypt_warn(NULL,
+				     "error allocating SHA-256 transform: %ld",
+				     PTR_ERR(tfm));
 			return PTR_ERR(tfm);
 		}
 		prev_tfm = cmpxchg(&essiv_hash_tfm, NULL, tfm);
@@ -311,8 +312,9 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	ctfm = crypto_alloc_skcipher(cipher_str, 0, 0);
 	if (IS_ERR(ctfm)) {
 		res = PTR_ERR(ctfm);
-		pr_debug("%s: error %d (inode %lu) allocating crypto tfm\n",
-			 __func__, res, inode->i_ino);
+		fscrypt_warn(inode->i_sb,
+			     "error allocating '%s' transform for inode %lu: %d",
+			     cipher_str, inode->i_ino, res);
 		goto out;
 	}
 	crypt_info->ci_ctfm = ctfm;
@@ -329,8 +331,9 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	    crypt_info->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
 		res = init_essiv_generator(crypt_info, raw_key, keysize);
 		if (res) {
-			pr_debug("%s: error %d (inode %lu) allocating essiv tfm\n",
-				 __func__, res, inode->i_ino);
+			fscrypt_warn(inode->i_sb,
+				     "error initializing ESSIV generator for inode %lu: %d",
+				     inode->i_ino, res);
 			goto out;
 		}
 	}
-- 
2.17.0.rc0.231.g781580f067-goog
