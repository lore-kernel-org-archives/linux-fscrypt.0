Return-Path: <david@sigma-star.at>
From: David Gstir <david@sigma-star.at>
Subject: [PATCH v3] fscrypt: Add support for AES-128-CBC
Date: Wed, 17 May 2017 13:21:04 +0200
Message-Id: <20170517112104.61106-1-david@sigma-star.at>
In-Reply-To: <20170426215616.GA104929@gmail.com>
References: <20170426215616.GA104929@gmail.com>
To: tytso@mit.edu, jaegeuk@kernel.org
Cc: ebiggers3@gmail.com, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Daniel Walter <dwalter@sigma-star.at>, David Gstir <david@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Daniel Walter <dwalter@sigma-star.at>

fscrypt provides facilities to use different encryption algorithms which
are selectable by userspace when setting the encryption policy. Currently,
only AES-256-XTS for file contents and AES-256-CBC-CTS for file names are
implemented. This is a clear case of kernel offers the mechanism and
userspace selects a policy. Similar to what dm-crypt and ecryptfs have.

This patch adds support for using AES-128-CBC for file contents and
AES-128-CBC-CTS for file name encryption. To mitigate watermarking
attacks, IVs are generated using the ESSIV algorithm. While AES-CBC is
actually slightly less secure than AES-XTS from a security point of view,
there is more widespread hardware support. Especially low-powered embedded
devices with crypto accelerators such as CAAM or CESA support only
AES-CBC-128 with an acceptable speed. Using AES-CBC gives us the acceptable
performance while still providing a moderate level of security for
persistent storage.

Signed-off-by: Daniel Walter <dwalter@sigma-star.at>
[david@sigma-star.at: addressed review comments]
Signed-off-by: David Gstir <david@sigma-star.at>
---
 fs/crypto/Kconfig              |   1 +
 fs/crypto/crypto.c             |  23 +++++--
 fs/crypto/fscrypt_private.h    |   9 ++-
 fs/crypto/keyinfo.c            | 147 ++++++++++++++++++++++++++++++++++-------
 fs/crypto/policy.c             |   8 +--
 include/linux/fscrypt_common.h |  13 ++--
 include/uapi/linux/fs.h        |   2 +
 7 files changed, 157 insertions(+), 46 deletions(-)

diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
index 08b46e6e3995..02b7d91c9231 100644
--- a/fs/crypto/Kconfig
+++ b/fs/crypto/Kconfig
@@ -7,6 +7,7 @@ config FS_ENCRYPTION
 	select CRYPTO_XTS
 	select CRYPTO_CTS
 	select CRYPTO_CTR
+	select CRYPTO_SHA256
 	select KEYS
 	help
 	  Enable encryption of files and directories.  This
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 6d6eca394d4d..0d4582c3aef1 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -26,6 +26,7 @@
 #include <linux/ratelimit.h>
 #include <linux/dcache.h>
 #include <linux/namei.h>
+#include <crypto/aes.h>
 #include "fscrypt_private.h"
 
 static unsigned int num_prealloc_crypto_pages = 32;
@@ -147,8 +148,8 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 {
 	struct {
 		__le64 index;
-		u8 padding[FS_XTS_TWEAK_SIZE - sizeof(__le64)];
-	} xts_tweak;
+		u8 padding[FS_IV_SIZE - sizeof(__le64)];
+	} iv;
 	struct skcipher_request *req = NULL;
 	DECLARE_FS_COMPLETION_RESULT(ecr);
 	struct scatterlist dst, src;
@@ -158,6 +159,16 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 
 	BUG_ON(len == 0);
 
+	BUILD_BUG_ON(sizeof(iv) != FS_IV_SIZE);
+	BUILD_BUG_ON(AES_BLOCK_SIZE != FS_IV_SIZE);
+	iv.index = cpu_to_le64(lblk_num);
+	memset(iv.padding, 0, sizeof(iv.padding));
+
+	if (ci->ci_essiv_tfm != NULL) {
+		crypto_cipher_encrypt_one(ci->ci_essiv_tfm, (u8 *)&iv,
+					  (u8 *)&iv);
+	}
+
 	req = skcipher_request_alloc(tfm, gfp_flags);
 	if (!req) {
 		printk_ratelimited(KERN_ERR
@@ -170,15 +181,11 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 		req, CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 		page_crypt_complete, &ecr);
 
-	BUILD_BUG_ON(sizeof(xts_tweak) != FS_XTS_TWEAK_SIZE);
-	xts_tweak.index = cpu_to_le64(lblk_num);
-	memset(xts_tweak.padding, 0, sizeof(xts_tweak.padding));
-
 	sg_init_table(&dst, 1);
 	sg_set_page(&dst, dest_page, len, offs);
 	sg_init_table(&src, 1);
 	sg_set_page(&src, src_page, len, offs);
-	skcipher_request_set_crypt(req, &src, &dst, len, &xts_tweak);
+	skcipher_request_set_crypt(req, &src, &dst, len, &iv);
 	if (rw == FS_DECRYPT)
 		res = crypto_skcipher_decrypt(req);
 	else
@@ -388,6 +395,8 @@ static void fscrypt_destroy(void)
 	INIT_LIST_HEAD(&fscrypt_free_ctxs);
 	mempool_destroy(fscrypt_bounce_page_pool);
 	fscrypt_bounce_page_pool = NULL;
+
+	fscrypt_essiv_cleanup();
 }
 
 /**
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 1e1f8a361b75..68e605613352 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -12,10 +12,13 @@
 #define _FSCRYPT_PRIVATE_H
 
 #include <linux/fscrypt_supp.h>
+#include <crypto/hash.h>
 
 /* Encryption parameters */
-#define FS_XTS_TWEAK_SIZE		16
+#define FS_IV_SIZE			16
 #define FS_AES_128_ECB_KEY_SIZE		16
+#define FS_AES_128_CBC_KEY_SIZE		16
+#define FS_AES_128_CTS_KEY_SIZE		16
 #define FS_AES_256_GCM_KEY_SIZE		32
 #define FS_AES_256_CBC_KEY_SIZE		32
 #define FS_AES_256_CTS_KEY_SIZE		32
@@ -54,6 +57,7 @@ struct fscrypt_info {
 	u8 ci_filename_mode;
 	u8 ci_flags;
 	struct crypto_skcipher *ci_ctfm;
+	struct crypto_cipher *ci_essiv_tfm;
 	u8 ci_master_key[FS_KEY_DESCRIPTOR_SIZE];
 };
 
@@ -87,4 +91,7 @@ extern int fscrypt_do_page_crypto(const struct inode *inode,
 extern struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
 					      gfp_t gfp_flags);
 
+/* keyinfo.c */
+extern void fscrypt_essiv_cleanup(void);
+
 #endif /* _FSCRYPT_PRIVATE_H */
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 179e578b875b..a09a4fa5ed52 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -10,8 +10,14 @@
 
 #include <keys/user-type.h>
 #include <linux/scatterlist.h>
+#include <linux/ratelimit.h>
+#include <crypto/aes.h>
+#include <crypto/sha.h>
 #include "fscrypt_private.h"
 
+static struct crypto_shash *essiv_hash_tfm;
+static DEFINE_MUTEX(essiv_hash_lock);
+
 static void derive_crypt_complete(struct crypto_async_request *req, int rc)
 {
 	struct fscrypt_completion_result *ecr = req->data;
@@ -27,13 +33,13 @@ static void derive_crypt_complete(struct crypto_async_request *req, int rc)
  * derive_key_aes() - Derive a key using AES-128-ECB
  * @deriving_key: Encryption key used for derivation.
  * @source_key:   Source key to which to apply derivation.
- * @derived_key:  Derived key.
+ * @derived_raw_key:  Derived raw key.
  *
  * Return: Zero on success; non-zero otherwise.
  */
 static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
-				u8 source_key[FS_AES_256_XTS_KEY_SIZE],
-				u8 derived_key[FS_AES_256_XTS_KEY_SIZE])
+				const struct fscrypt_key *source_key,
+				u8 derived_raw_key[FS_MAX_KEY_SIZE])
 {
 	int res = 0;
 	struct skcipher_request *req = NULL;
@@ -60,10 +66,10 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 	if (res < 0)
 		goto out;
 
-	sg_init_one(&src_sg, source_key, FS_AES_256_XTS_KEY_SIZE);
-	sg_init_one(&dst_sg, derived_key, FS_AES_256_XTS_KEY_SIZE);
-	skcipher_request_set_crypt(req, &src_sg, &dst_sg,
-					FS_AES_256_XTS_KEY_SIZE, NULL);
+	sg_init_one(&src_sg, source_key->raw, source_key->size);
+	sg_init_one(&dst_sg, derived_raw_key, source_key->size);
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg, source_key->size,
+				   NULL);
 	res = crypto_skcipher_encrypt(req);
 	if (res == -EINPROGRESS || res == -EBUSY) {
 		wait_for_completion(&ecr.completion);
@@ -77,7 +83,7 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 
 static int validate_user_key(struct fscrypt_info *crypt_info,
 			struct fscrypt_context *ctx, u8 *raw_key,
-			const char *prefix)
+			const char *prefix, int min_keysize)
 {
 	char *description;
 	struct key *keyring_key;
@@ -111,14 +117,15 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
 	master_key = (struct fscrypt_key *)ukp->data;
 	BUILD_BUG_ON(FS_AES_128_ECB_KEY_SIZE != FS_KEY_DERIVATION_NONCE_SIZE);
 
-	if (master_key->size != FS_AES_256_XTS_KEY_SIZE) {
+	if (master_key->size < min_keysize || master_key->size > FS_MAX_KEY_SIZE
+	    || master_key->size % AES_BLOCK_SIZE != 0) {
 		printk_once(KERN_WARNING
 				"%s: key size incorrect: %d\n",
 				__func__, master_key->size);
 		res = -ENOKEY;
 		goto out;
 	}
-	res = derive_key_aes(ctx->nonce, master_key->raw, raw_key);
+	res = derive_key_aes(ctx->nonce, master_key, raw_key);
 out:
 	up_read(&keyring_key->sem);
 	key_put(keyring_key);
@@ -129,27 +136,37 @@ static int determine_cipher_type(struct fscrypt_info *ci, struct inode *inode,
 				 const char **cipher_str_ret, int *keysize_ret)
 {
 	if (S_ISREG(inode->i_mode)) {
-		if (ci->ci_data_mode == FS_ENCRYPTION_MODE_AES_256_XTS) {
+		switch (ci->ci_data_mode) {
+		case FS_ENCRYPTION_MODE_AES_256_XTS:
 			*cipher_str_ret = "xts(aes)";
 			*keysize_ret = FS_AES_256_XTS_KEY_SIZE;
 			return 0;
+		case FS_ENCRYPTION_MODE_AES_128_CBC:
+			*cipher_str_ret = "cbc(aes)";
+			*keysize_ret = FS_AES_128_CBC_KEY_SIZE;
+			return 0;
+		default:
+			pr_warn_once("fscrypto: unsupported contents encryption mode %d for inode %lu\n",
+				     ci->ci_data_mode, inode->i_ino);
+			return -ENOKEY;
 		}
-		pr_warn_once("fscrypto: unsupported contents encryption mode "
-			     "%d for inode %lu\n",
-			     ci->ci_data_mode, inode->i_ino);
-		return -ENOKEY;
 	}
 
 	if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) {
-		if (ci->ci_filename_mode == FS_ENCRYPTION_MODE_AES_256_CTS) {
+		switch (ci->ci_filename_mode) {
+		case FS_ENCRYPTION_MODE_AES_256_CTS:
 			*cipher_str_ret = "cts(cbc(aes))";
 			*keysize_ret = FS_AES_256_CTS_KEY_SIZE;
 			return 0;
+		case FS_ENCRYPTION_MODE_AES_128_CTS:
+			*cipher_str_ret = "cts(cbc(aes))";
+			*keysize_ret = FS_AES_128_CTS_KEY_SIZE;
+			return 0;
+		default:
+			pr_warn_once("fscrypto: unsupported filenames encryption mode %d for inode %lu\n",
+				     ci->ci_filename_mode, inode->i_ino);
+			return -ENOKEY;
 		}
-		pr_warn_once("fscrypto: unsupported filenames encryption mode "
-			     "%d for inode %lu\n",
-			     ci->ci_filename_mode, inode->i_ino);
-		return -ENOKEY;
 	}
 
 	pr_warn_once("fscrypto: unsupported file type %d for inode %lu\n",
@@ -163,9 +180,75 @@ static void put_crypt_info(struct fscrypt_info *ci)
 		return;
 
 	crypto_free_skcipher(ci->ci_ctfm);
+	crypto_free_cipher(ci->ci_essiv_tfm);
 	kmem_cache_free(fscrypt_info_cachep, ci);
 }
 
+static int derive_essiv_salt(u8 *key, int keysize, u8 *salt)
+{
+	int err;
+
+	/* init hash transform on demand */
+	if (unlikely(essiv_hash_tfm == NULL)) {
+		mutex_lock(&essiv_hash_lock);
+		if (essiv_hash_tfm == NULL) {
+			essiv_hash_tfm = crypto_alloc_shash("sha256", 0, 0);
+			if (IS_ERR(essiv_hash_tfm)) {
+				pr_warn_ratelimited("fscrypt: error allocating SHA-256 transform: %ld\n",
+						    PTR_ERR(essiv_hash_tfm));
+				err = PTR_ERR(essiv_hash_tfm);
+				essiv_hash_tfm = NULL;
+				mutex_unlock(&essiv_hash_lock);
+				return err;
+			}
+		}
+		mutex_unlock(&essiv_hash_lock);
+	}
+
+	{
+		SHASH_DESC_ON_STACK(desc, essiv_hash_tfm);
+		desc->tfm = essiv_hash_tfm;
+		desc->flags = 0;
+
+		return crypto_shash_digest(desc, key, keysize, salt);
+	}
+}
+
+static int init_essiv_generator(struct fscrypt_info *ci, u8 *raw_key,
+				int keysize)
+{
+	int err;
+	struct crypto_cipher *essiv_tfm;
+	u8 salt[SHA256_DIGEST_SIZE];
+
+	if (WARN_ON_ONCE(keysize > sizeof(salt)))
+		return -EINVAL;
+
+	essiv_tfm = crypto_alloc_cipher("aes", 0, 0);
+	if (IS_ERR(essiv_tfm))
+		return PTR_ERR(essiv_tfm);
+
+	ci->ci_essiv_tfm = essiv_tfm;
+
+	err = derive_essiv_salt(raw_key, keysize, salt);
+	if (err)
+		goto out;
+
+	err = crypto_cipher_setkey(essiv_tfm, salt, SHA256_DIGEST_SIZE);
+	if (err)
+		goto out;
+
+out:
+	memzero_explicit(salt, sizeof(salt));
+	return err;
+}
+
+void fscrypt_essiv_cleanup(void)
+{
+	crypto_free_shash(essiv_hash_tfm);
+	essiv_hash_tfm = NULL;
+}
+
 int fscrypt_get_encryption_info(struct inode *inode)
 {
 	struct fscrypt_info *crypt_info;
@@ -204,6 +287,10 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (ctx.flags & ~FS_POLICY_FLAGS_VALID)
 		return -EINVAL;
 
+	if (!fscrypt_valid_enc_modes(ctx.contents_encryption_mode,
+				     ctx.filenames_encryption_mode))
+		return -EINVAL;
+
 	crypt_info = kmem_cache_alloc(fscrypt_info_cachep, GFP_NOFS);
 	if (!crypt_info)
 		return -ENOMEM;
@@ -212,6 +299,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	crypt_info->ci_data_mode = ctx.contents_encryption_mode;
 	crypt_info->ci_filename_mode = ctx.filenames_encryption_mode;
 	crypt_info->ci_ctfm = NULL;
+	crypt_info->ci_essiv_tfm = NULL;
 	memcpy(crypt_info->ci_master_key, ctx.master_key_descriptor,
 				sizeof(crypt_info->ci_master_key));
 
@@ -228,10 +316,12 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (!raw_key)
 		goto out;
 
-	res = validate_user_key(crypt_info, &ctx, raw_key, FS_KEY_DESC_PREFIX);
+	res = validate_user_key(crypt_info, &ctx, raw_key, FS_KEY_DESC_PREFIX,
+				keysize);
 	if (res && inode->i_sb->s_cop->key_prefix) {
 		int res2 = validate_user_key(crypt_info, &ctx, raw_key,
-					     inode->i_sb->s_cop->key_prefix);
+					     inode->i_sb->s_cop->key_prefix,
+					     keysize);
 		if (res2) {
 			if (res2 == -ENOKEY)
 				res = -ENOKEY;
@@ -243,9 +333,8 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	ctfm = crypto_alloc_skcipher(cipher_str, 0, 0);
 	if (!ctfm || IS_ERR(ctfm)) {
 		res = ctfm ? PTR_ERR(ctfm) : -ENOMEM;
-		printk(KERN_DEBUG
-		       "%s: error %d (inode %u) allocating crypto tfm\n",
-		       __func__, res, (unsigned) inode->i_ino);
+		pr_debug("%s: error %d (inode %lu) allocating crypto tfm\n",
+			 __func__, res, inode->i_ino);
 		goto out;
 	}
 	crypt_info->ci_ctfm = ctfm;
@@ -255,6 +344,14 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (res)
 		goto out;
 
+	if (crypt_info->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
+		res = init_essiv_generator(crypt_info, raw_key, keysize);
+		if (res) {
+			pr_debug("%s: error %d (inode %lu) allocating essiv tfm\n",
+				 __func__, res, inode->i_ino);
+			goto out;
+		}
+	}
 	if (cmpxchg(&inode->i_crypt_info, NULL, crypt_info) == NULL)
 		crypt_info = NULL;
 out:
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index 210976e7a269..9914d51dff86 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -38,12 +38,8 @@ static int create_encryption_context_from_policy(struct inode *inode,
 	memcpy(ctx.master_key_descriptor, policy->master_key_descriptor,
 					FS_KEY_DESCRIPTOR_SIZE);
 
-	if (!fscrypt_valid_contents_enc_mode(
-				policy->contents_encryption_mode))
-		return -EINVAL;
-
-	if (!fscrypt_valid_filenames_enc_mode(
-				policy->filenames_encryption_mode))
+	if (!fscrypt_valid_enc_modes(policy->contents_encryption_mode,
+				     policy->filenames_encryption_mode))
 		return -EINVAL;
 
 	if (policy->flags & ~FS_POLICY_FLAGS_VALID)
diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt_common.h
index 0a30c106c1e5..982c08c4f2ac 100644
--- a/include/linux/fscrypt_common.h
+++ b/include/linux/fscrypt_common.h
@@ -91,14 +91,13 @@ static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
 	return false;
 }
 
-static inline bool fscrypt_valid_contents_enc_mode(u32 mode)
+static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
+					u32 filenames_mode)
 {
-	return (mode == FS_ENCRYPTION_MODE_AES_256_XTS);
-}
-
-static inline bool fscrypt_valid_filenames_enc_mode(u32 mode)
-{
-	return (mode == FS_ENCRYPTION_MODE_AES_256_CTS);
+	return ((contents_mode == FS_ENCRYPTION_MODE_AES_128_CBC &&
+		 filenames_mode == FS_ENCRYPTION_MODE_AES_128_CTS) ||
+		(contents_mode == FS_ENCRYPTION_MODE_AES_256_XTS &&
+		 filenames_mode == FS_ENCRYPTION_MODE_AES_256_CTS));
 }
 
 static inline bool fscrypt_is_dot_dotdot(const struct qstr *str)
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index 24e61a54feaa..a2a3ffb06038 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -272,6 +272,8 @@ struct fsxattr {
 #define FS_ENCRYPTION_MODE_AES_256_GCM		2
 #define FS_ENCRYPTION_MODE_AES_256_CBC		3
 #define FS_ENCRYPTION_MODE_AES_256_CTS		4
+#define FS_ENCRYPTION_MODE_AES_128_CBC		5
+#define FS_ENCRYPTION_MODE_AES_128_CTS		6
 
 struct fscrypt_policy {
 	__u8 version;
-- 
2.12.0
