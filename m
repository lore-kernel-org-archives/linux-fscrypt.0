Return-Path: <david@sigma-star.at>
From: David Gstir <david@sigma-star.at>
Subject: [PATCH v5] fscrypt: Add support for AES-128-CBC
Date: Mon, 19 Jun 2017 09:27:58 +0200
Message-Id: <20170619072758.8608-1-david@sigma-star.at>
In-Reply-To: <5565BD72-986F-4338-8562-6B5F9FB72110@sigma-star.at>
References: <5565BD72-986F-4338-8562-6B5F9FB72110@sigma-star.at>
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
there is more widespread hardware support. Using AES-CBC gives us the
acceptable performance while still providing a moderate level of security
for persistent storage.

Especially low-powered embedded devices with crypto accelerators such as
CAAM or CESA often only support AES-CBC. Since using AES-CBC over AES-XTS
is basically thought of a last resort, we use AES-128-CBC over AES-256-CBC
since it has less encryption rounds and yields noticeable better
performance starting from a file size of just a few kB.

Signed-off-by: Daniel Walter <dwalter@sigma-star.at>
[david@sigma-star.at: addressed review comments]
Signed-off-by: David Gstir <david@sigma-star.at>
Reviewed-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/Kconfig              |   1 +
 fs/crypto/crypto.c             |  23 ++++--
 fs/crypto/fscrypt_private.h    |   9 ++-
 fs/crypto/keyinfo.c            | 173 ++++++++++++++++++++++++++++++++---------
 fs/crypto/policy.c             |   8 +-
 include/linux/fscrypt_common.h |  16 ++--
 include/uapi/linux/fs.h        |   2 +
 7 files changed, 174 insertions(+), 58 deletions(-)

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
index 6d6eca394d4d..c7835df7e7b8 100644
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
@@ -477,6 +484,8 @@ static void __exit fscrypt_exit(void)
 		destroy_workqueue(fscrypt_read_workqueue);
 	kmem_cache_destroy(fscrypt_ctx_cachep);
 	kmem_cache_destroy(fscrypt_info_cachep);
+
+	fscrypt_essiv_cleanup();
 }
 module_exit(fscrypt_exit);
 
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 1e1f8a361b75..a1d5021c31ef 100644
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
+extern void __exit fscrypt_essiv_cleanup(void);
+
 #endif /* _FSCRYPT_PRIVATE_H */
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 179e578b875b..018c588c7ac3 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -10,8 +10,13 @@
 
 #include <keys/user-type.h>
 #include <linux/scatterlist.h>
+#include <linux/ratelimit.h>
+#include <crypto/aes.h>
+#include <crypto/sha.h>
 #include "fscrypt_private.h"
 
+static struct crypto_shash *essiv_hash_tfm;
+
 static void derive_crypt_complete(struct crypto_async_request *req, int rc)
 {
 	struct fscrypt_completion_result *ecr = req->data;
@@ -27,13 +32,13 @@ static void derive_crypt_complete(struct crypto_async_request *req, int rc)
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
@@ -60,10 +65,10 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
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
@@ -77,7 +82,7 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 
 static int validate_user_key(struct fscrypt_info *crypt_info,
 			struct fscrypt_context *ctx, u8 *raw_key,
-			const char *prefix)
+			const char *prefix, int min_keysize)
 {
 	char *description;
 	struct key *keyring_key;
@@ -111,50 +116,60 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
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
 	return res;
 }
 
+static const struct {
+	const char *cipher_str;
+	int keysize;
+} available_modes[] = {
+	[FS_ENCRYPTION_MODE_AES_256_XTS] = { "xts(aes)",
+					     FS_AES_256_XTS_KEY_SIZE },
+	[FS_ENCRYPTION_MODE_AES_256_CTS] = { "cts(cbc(aes))",
+					     FS_AES_256_CTS_KEY_SIZE },
+	[FS_ENCRYPTION_MODE_AES_128_CBC] = { "cbc(aes)",
+					     FS_AES_128_CBC_KEY_SIZE },
+	[FS_ENCRYPTION_MODE_AES_128_CTS] = { "cts(cbc(aes))",
+					     FS_AES_128_CTS_KEY_SIZE },
+};
+
 static int determine_cipher_type(struct fscrypt_info *ci, struct inode *inode,
 				 const char **cipher_str_ret, int *keysize_ret)
 {
-	if (S_ISREG(inode->i_mode)) {
-		if (ci->ci_data_mode == FS_ENCRYPTION_MODE_AES_256_XTS) {
-			*cipher_str_ret = "xts(aes)";
-			*keysize_ret = FS_AES_256_XTS_KEY_SIZE;
-			return 0;
-		}
-		pr_warn_once("fscrypto: unsupported contents encryption mode "
-			     "%d for inode %lu\n",
-			     ci->ci_data_mode, inode->i_ino);
-		return -ENOKEY;
+	u32 mode;
+
+	if (!fscrypt_valid_enc_modes(ci->ci_data_mode, ci->ci_filename_mode)) {
+		pr_warn_ratelimited("fscrypt: inode %lu uses unsupported encryption modes (contents mode %d, filenames mode %d)\n",
+				    inode->i_ino,
+				    ci->ci_data_mode, ci->ci_filename_mode);
+		return -EINVAL;
 	}
 
-	if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) {
-		if (ci->ci_filename_mode == FS_ENCRYPTION_MODE_AES_256_CTS) {
-			*cipher_str_ret = "cts(cbc(aes))";
-			*keysize_ret = FS_AES_256_CTS_KEY_SIZE;
-			return 0;
-		}
-		pr_warn_once("fscrypto: unsupported filenames encryption mode "
-			     "%d for inode %lu\n",
-			     ci->ci_filename_mode, inode->i_ino);
-		return -ENOKEY;
+	if (S_ISREG(inode->i_mode)) {
+		mode = ci->ci_data_mode;
+	} else if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) {
+		mode = ci->ci_filename_mode;
+	} else {
+		WARN_ONCE(1, "fscrypt: filesystem tried to load encryption info for inode %lu, which is not encryptable (file type %d)\n",
+			  inode->i_ino, (inode->i_mode & S_IFMT));
+		return -EINVAL;
 	}
 
-	pr_warn_once("fscrypto: unsupported file type %d for inode %lu\n",
-		     (inode->i_mode & S_IFMT), inode->i_ino);
-	return -ENOKEY;
+	*cipher_str_ret = available_modes[mode].cipher_str;
+	*keysize_ret = available_modes[mode].keysize;
+	return 0;
 }
 
 static void put_crypt_info(struct fscrypt_info *ci)
@@ -163,9 +178,76 @@ static void put_crypt_info(struct fscrypt_info *ci)
 		return;
 
 	crypto_free_skcipher(ci->ci_ctfm);
+	crypto_free_cipher(ci->ci_essiv_tfm);
 	kmem_cache_free(fscrypt_info_cachep, ci);
 }
 
+static int derive_essiv_salt(const u8 *key, int keysize, u8 *salt)
+{
+	struct crypto_shash *tfm = READ_ONCE(essiv_hash_tfm);
+
+	/* init hash transform on demand */
+	if (unlikely(!tfm)) {
+		struct crypto_shash *prev_tfm;
+
+		tfm = crypto_alloc_shash("sha256", 0, 0);
+		if (IS_ERR(tfm)) {
+			pr_warn_ratelimited("fscrypt: error allocating SHA-256 transform: %ld\n",
+					    PTR_ERR(tfm));
+			return PTR_ERR(tfm);
+		}
+		prev_tfm = cmpxchg(&essiv_hash_tfm, NULL, tfm);
+		if (prev_tfm) {
+			crypto_free_shash(tfm);
+			tfm = prev_tfm;
+		}
+	}
+
+	{
+		SHASH_DESC_ON_STACK(desc, tfm);
+		desc->tfm = tfm;
+		desc->flags = 0;
+
+		return crypto_shash_digest(desc, key, keysize, salt);
+	}
+}
+
+static int init_essiv_generator(struct fscrypt_info *ci, const u8 *raw_key,
+				int keysize)
+{
+	int err;
+	struct crypto_cipher *essiv_tfm;
+	u8 salt[SHA256_DIGEST_SIZE];
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
+	/*
+	 * Using SHA256 to derive the salt/key will result in AES-256 being
+	 * used for IV generation. File contents encryption will still use the
+	 * configured keysize (AES-128) nevertheless.
+	 */
+	err = crypto_cipher_setkey(essiv_tfm, salt, sizeof(salt));
+	if (err)
+		goto out;
+
+out:
+	memzero_explicit(salt, sizeof(salt));
+	return err;
+}
+
+void __exit fscrypt_essiv_cleanup(void)
+{
+	crypto_free_shash(essiv_hash_tfm);
+}
+
 int fscrypt_get_encryption_info(struct inode *inode)
 {
 	struct fscrypt_info *crypt_info;
@@ -212,6 +294,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	crypt_info->ci_data_mode = ctx.contents_encryption_mode;
 	crypt_info->ci_filename_mode = ctx.filenames_encryption_mode;
 	crypt_info->ci_ctfm = NULL;
+	crypt_info->ci_essiv_tfm = NULL;
 	memcpy(crypt_info->ci_master_key, ctx.master_key_descriptor,
 				sizeof(crypt_info->ci_master_key));
 
@@ -228,10 +311,12 @@ int fscrypt_get_encryption_info(struct inode *inode)
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
@@ -243,18 +328,30 @@ int fscrypt_get_encryption_info(struct inode *inode)
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
 	crypto_skcipher_clear_flags(ctfm, ~0);
 	crypto_skcipher_set_flags(ctfm, CRYPTO_TFM_REQ_WEAK_KEY);
+	/*
+	 * if the provided key is longer than keysize, we use the first
+	 * keysize bytes of the derived key only
+	 */
 	res = crypto_skcipher_setkey(ctfm, raw_key, keysize);
 	if (res)
 		goto out;
 
+	if (S_ISREG(inode->i_mode) &&
+	    crypt_info->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
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
index 0a30c106c1e5..4022c61f7e9b 100644
--- a/include/linux/fscrypt_common.h
+++ b/include/linux/fscrypt_common.h
@@ -91,14 +91,18 @@ static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
 	return false;
 }
 
-static inline bool fscrypt_valid_contents_enc_mode(u32 mode)
+static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
+					u32 filenames_mode)
 {
-	return (mode == FS_ENCRYPTION_MODE_AES_256_XTS);
-}
+	if (contents_mode == FS_ENCRYPTION_MODE_AES_128_CBC &&
+	    filenames_mode == FS_ENCRYPTION_MODE_AES_128_CTS)
+		return true;
 
-static inline bool fscrypt_valid_filenames_enc_mode(u32 mode)
-{
-	return (mode == FS_ENCRYPTION_MODE_AES_256_CTS);
+	if (contents_mode == FS_ENCRYPTION_MODE_AES_256_XTS &&
+	    filenames_mode == FS_ENCRYPTION_MODE_AES_256_CTS)
+		return true;
+
+	return false;
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
2.12.3
