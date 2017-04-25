Return-Path: <david@sigma-star.at>
From: David Gstir <david@sigma-star.at>
Subject: [PATCH v2] fscrypt: Add support for AES-128-CBC
Date: Tue, 25 Apr 2017 16:41:00 +0200
Message-Id: <20170425144100.11484-1-david@sigma-star.at>
In-Reply-To: <20170330173840.72909-1-david@sigma-star.at>
References: <20170330173840.72909-1-david@sigma-star.at>
To: tytso@mit.edu, jaegeuk@kernel.org
Cc: ebiggers3@gmail.com, dwalter@sigma-star.at, richard@sigma-star.at, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
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
[david@sigma-star.at: massaged commit message]
Signed-off-by: David Gstir <david@sigma-star.at>
---
v2: Compute ESSIV salt using SHA256 instead of SHA1 and improve style
    as pointed out by Eric Biggers [1].

    [1] https://lkml.kernel.org/r/20170331062149.GA32409%20()%20zzz

 fs/crypto/crypto.c             |  22 ++++--
 fs/crypto/fscrypt_private.h    |   5 +-
 fs/crypto/keyinfo.c            | 165 ++++++++++++++++++++++++++++++++++-------
 fs/crypto/policy.c             |   7 +-
 include/linux/fscrypt_common.h |  13 ++--
 include/uapi/linux/fs.h        |   2 +
 6 files changed, 169 insertions(+), 45 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 6d6eca394d4d..9dd5f23a55a5 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -26,6 +26,7 @@
 #include <linux/ratelimit.h>
 #include <linux/dcache.h>
 #include <linux/namei.h>
+#include <crypto/aes.h>
 #include "fscrypt_private.h"
 
 static unsigned int num_prealloc_crypto_pages = 32;
@@ -147,17 +148,28 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 {
 	struct {
 		__le64 index;
-		u8 padding[FS_XTS_TWEAK_SIZE - sizeof(__le64)];
-	} xts_tweak;
+		u8 padding[FS_IV_SIZE - sizeof(__le64)];
+	} blk_desc;
 	struct skcipher_request *req = NULL;
 	DECLARE_FS_COMPLETION_RESULT(ecr);
 	struct scatterlist dst, src;
 	struct fscrypt_info *ci = inode->i_crypt_info;
 	struct crypto_skcipher *tfm = ci->ci_ctfm;
 	int res = 0;
+	u8 *iv = (u8 *)&blk_desc;
 
 	BUG_ON(len == 0);
 
+	BUILD_BUG_ON(sizeof(blk_desc) != FS_IV_SIZE);
+	BUILD_BUG_ON(AES_BLOCK_SIZE != FS_IV_SIZE);
+	blk_desc.index = cpu_to_le64(lblk_num);
+	memset(blk_desc.padding, 0, sizeof(blk_desc.padding));
+
+	if (ci->ci_essiv_tfm != NULL) {
+		memset(iv, 0, sizeof(blk_desc));
+		crypto_cipher_encrypt_one(ci->ci_essiv_tfm, iv, iv);
+	}
+
 	req = skcipher_request_alloc(tfm, gfp_flags);
 	if (!req) {
 		printk_ratelimited(KERN_ERR
@@ -170,15 +182,11 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
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
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index e39696e64494..81ce9af449cb 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -16,8 +16,10 @@
 #define FS_FNAME_CRYPTO_DIGEST_SIZE	32
 
 /* Encryption parameters */
-#define FS_XTS_TWEAK_SIZE		16
+#define FS_IV_SIZE			16
 #define FS_AES_128_ECB_KEY_SIZE		16
+#define FS_AES_128_CBC_KEY_SIZE		16
+#define FS_AES_128_CTS_KEY_SIZE		16
 #define FS_AES_256_GCM_KEY_SIZE		32
 #define FS_AES_256_CBC_KEY_SIZE		32
 #define FS_AES_256_CTS_KEY_SIZE		32
@@ -67,6 +69,7 @@ struct fscrypt_info {
 	u8 ci_filename_mode;
 	u8 ci_flags;
 	struct crypto_skcipher *ci_ctfm;
+	struct crypto_cipher *ci_essiv_tfm;
 	u8 ci_master_key[FS_KEY_DESCRIPTOR_SIZE];
 };
 
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 8cdfddce2b34..590efb0a891d 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -10,6 +10,8 @@
 
 #include <keys/user-type.h>
 #include <linux/scatterlist.h>
+#include <crypto/aes.h>
+#include <crypto/hash.h>
 #include "fscrypt_private.h"
 
 static void derive_crypt_complete(struct crypto_async_request *req, int rc)
@@ -27,13 +29,13 @@ static void derive_crypt_complete(struct crypto_async_request *req, int rc)
  * derive_key_aes() - Derive a key using AES-128-ECB
  * @deriving_key: Encryption key used for derivation.
  * @source_key:   Source key to which to apply derivation.
- * @derived_key:  Derived key.
+ * @derived_key_raw:  Derived raw key.
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
@@ -60,10 +62,10 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 	if (res < 0)
 		goto out;
 
-	sg_init_one(&src_sg, source_key, FS_AES_256_XTS_KEY_SIZE);
-	sg_init_one(&dst_sg, derived_key, FS_AES_256_XTS_KEY_SIZE);
-	skcipher_request_set_crypt(req, &src_sg, &dst_sg,
-					FS_AES_256_XTS_KEY_SIZE, NULL);
+	sg_init_one(&src_sg, source_key->raw, source_key->size);
+	sg_init_one(&dst_sg, derived_raw_key, source_key->size);
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg, source_key->size,
+			NULL);
 	res = crypto_skcipher_encrypt(req);
 	if (res == -EINPROGRESS || res == -EBUSY) {
 		wait_for_completion(&ecr.completion);
@@ -77,7 +79,7 @@ static int derive_key_aes(u8 deriving_key[FS_AES_128_ECB_KEY_SIZE],
 
 static int validate_user_key(struct fscrypt_info *crypt_info,
 			struct fscrypt_context *ctx, u8 *raw_key,
-			const char *prefix)
+			const char *prefix, int min_keysize)
 {
 	char *description;
 	struct key *keyring_key;
@@ -111,14 +113,15 @@ static int validate_user_key(struct fscrypt_info *crypt_info,
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
@@ -129,27 +132,37 @@ static int determine_cipher_type(struct fscrypt_info *ci, struct inode *inode,
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
@@ -163,14 +176,100 @@ static void put_crypt_info(struct fscrypt_info *ci)
 		return;
 
 	crypto_free_skcipher(ci->ci_ctfm);
+	crypto_free_cipher(ci->ci_essiv_tfm);
 	kmem_cache_free(fscrypt_info_cachep, ci);
 }
 
+static int derive_essiv_salt(u8 *raw_key, int keysize, u8 **salt_out,
+			unsigned int *saltsize)
+{
+	int res;
+	struct crypto_ahash *hash_tfm;
+	unsigned int digestsize;
+	u8 *salt = NULL;
+	struct scatterlist sg;
+	struct ahash_request *req = NULL;
+
+	hash_tfm = crypto_alloc_ahash("sha256", 0, 0);
+	if (IS_ERR(hash_tfm))
+		return PTR_ERR(hash_tfm);
+
+	digestsize = crypto_ahash_digestsize(hash_tfm);
+	salt = kzalloc(digestsize, GFP_NOFS);
+	if (!salt) {
+		res = -ENOMEM;
+		goto out;
+	}
+
+	req = ahash_request_alloc(hash_tfm, GFP_NOFS);
+	if (!req) {
+		kfree(salt);
+		res = -ENOMEM;
+		goto out;
+	}
+
+	sg_init_one(&sg, raw_key, keysize);
+	ahash_request_set_callback(req,
+			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
+			NULL, NULL);
+	ahash_request_set_crypt(req, &sg, salt, keysize);
+
+	res = crypto_ahash_digest(req);
+	if (res) {
+		kfree(salt);
+		goto out;
+	}
+
+	*salt_out = salt;
+	*saltsize = digestsize;
+
+out:
+	crypto_free_ahash(hash_tfm);
+	ahash_request_free(req);
+	return res;
+}
+
+static int init_essiv_generator(struct fscrypt_info *ci, u8 *raw_key,
+				int keysize)
+{
+	int res;
+	struct crypto_cipher *essiv_tfm;
+	u8 *salt = NULL;
+	unsigned int saltsize;
+
+	/* init ESSIV generator */
+	essiv_tfm = crypto_alloc_cipher("aes", 0, 0);
+	if (!essiv_tfm || IS_ERR(essiv_tfm)) {
+		res = essiv_tfm ? PTR_ERR(essiv_tfm) : -ENOMEM;
+		goto err;
+	}
+
+	res = derive_essiv_salt(raw_key, keysize, &salt, &saltsize);
+	if (res)
+		goto err;
+
+	res = crypto_cipher_setkey(essiv_tfm, salt, saltsize);
+	if (res)
+		goto err;
+
+	ci->ci_essiv_tfm = essiv_tfm;
+
+	return 0;
+
+err:
+	if (essiv_tfm && !IS_ERR(essiv_tfm))
+		crypto_free_cipher(essiv_tfm);
+
+	kzfree(salt);
+	return res;
+}
+
 int fscrypt_get_encryption_info(struct inode *inode)
 {
 	struct fscrypt_info *crypt_info;
 	struct fscrypt_context ctx;
 	struct crypto_skcipher *ctfm;
+
 	const char *cipher_str;
 	int keysize;
 	u8 *raw_key = NULL;
@@ -207,6 +306,10 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (ctx.flags & ~FS_POLICY_FLAGS_VALID)
 		return -EINVAL;
 
+	if (!fscrypt_valid_enc_modes(ctx.contents_encryption_mode,
+				ctx.filenames_encryption_mode))
+		return -EINVAL;
+
 	crypt_info = kmem_cache_alloc(fscrypt_info_cachep, GFP_NOFS);
 	if (!crypt_info)
 		return -ENOMEM;
@@ -215,6 +318,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	crypt_info->ci_data_mode = ctx.contents_encryption_mode;
 	crypt_info->ci_filename_mode = ctx.filenames_encryption_mode;
 	crypt_info->ci_ctfm = NULL;
+	crypt_info->ci_essiv_tfm = NULL;
 	memcpy(crypt_info->ci_master_key, ctx.master_key_descriptor,
 				sizeof(crypt_info->ci_master_key));
 
@@ -231,10 +335,12 @@ int fscrypt_get_encryption_info(struct inode *inode)
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
@@ -246,9 +352,9 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	ctfm = crypto_alloc_skcipher(cipher_str, 0, 0);
 	if (!ctfm || IS_ERR(ctfm)) {
 		res = ctfm ? PTR_ERR(ctfm) : -ENOMEM;
-		printk(KERN_DEBUG
-		       "%s: error %d (inode %u) allocating crypto tfm\n",
-		       __func__, res, (unsigned) inode->i_ino);
+		pr_debug(
+		      "%s: error %d (inode %u) allocating crypto tfm\n",
+		      __func__, res, (unsigned int) inode->i_ino);
 		goto out;
 	}
 	crypt_info->ci_ctfm = ctfm;
@@ -258,6 +364,15 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (res)
 		goto out;
 
+	if (crypt_info->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
+		res = init_essiv_generator(crypt_info, raw_key, keysize);
+		if (res) {
+			pr_debug(
+			     "%s: error %d (inode %u) allocating essiv tfm\n",
+			     __func__, res, (unsigned int) inode->i_ino);
+			goto out;
+		}
+	}
 	if (cmpxchg(&inode->i_crypt_info, NULL, crypt_info) == NULL)
 		crypt_info = NULL;
 out:
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index 4908906d54d5..bac8009245f2 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -41,11 +41,8 @@ static int create_encryption_context_from_policy(struct inode *inode,
 	memcpy(ctx.master_key_descriptor, policy->master_key_descriptor,
 					FS_KEY_DESCRIPTOR_SIZE);
 
-	if (!fscrypt_valid_contents_enc_mode(
-				policy->contents_encryption_mode))
-		return -EINVAL;
-
-	if (!fscrypt_valid_filenames_enc_mode(
+	if (!fscrypt_valid_enc_modes(
+				policy->contents_encryption_mode,
 				policy->filenames_encryption_mode))
 		return -EINVAL;
 
diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt_common.h
index 10c1abfbac6c..a91ce99f6e19 100644
--- a/include/linux/fscrypt_common.h
+++ b/include/linux/fscrypt_common.h
@@ -102,14 +102,13 @@ static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
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
index 048a85e9f017..231b15d4a90e 100644
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
