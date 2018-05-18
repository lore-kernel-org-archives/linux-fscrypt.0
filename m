Return-Path: <linux-crypto-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH v2] fscrypt: log the crypto algorithm implementations
Date: Fri, 18 May 2018 10:58:14 -0700
Message-Id: <20180518175814.84006-1-ebiggers@google.com>
Sender: linux-crypto-owner@vger.kernel.org
To: "Theodore Y . Ts'o" <tytso@mit.edu>, linux-fscrypt@vger.kernel.org
Cc: linux-crypto@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Paul Crowley <paulcrowley@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Log the crypto algorithm driver name for each fscrypt encryption mode on
its first use, also showing a friendly name for the mode.

This will help people determine whether the expected implementations are
being used.  In some cases we've seen people do benchmarks and reject
using encryption for performance reasons, when in fact they used a much
slower implementation of AES-XTS than was possible on the hardware.  It
can make an enormous difference; e.g., AES-XTS on ARM is about 10x
faster with the crypto extensions (AES instructions) than without.

This also makes it more obvious which modes are being used, now that
fscrypt supports multiple combinations of modes.

Example messages (with default modes, on x86_64):

[   35.492057] fscrypt: AES-256-CTS-CBC using implementation "cts(cbc-aes-aesni)"
[   35.492171] fscrypt: AES-256-XTS using implementation "xts-aes-aesni"

Note: algorithms can be dynamically added to the crypto API, which can
result in different implementations being used at different times.  But
this is rare; for most users, showing the first will be good enough.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---

Changed since v1:
	- Added missing "\n" (oops)

Note: this patch is on top of the other fscrypt patches I've sent out for 4.18.

 fs/crypto/keyinfo.c | 102 +++++++++++++++++++++++++++++---------------
 1 file changed, 68 insertions(+), 34 deletions(-)

diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 41f6025d5d7a..e997ca51192f 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -148,44 +148,64 @@ static int find_and_derive_key(const struct inode *inode,
 	return err;
 }
 
-static const struct {
+static struct fscrypt_mode {
+	const char *friendly_name;
 	const char *cipher_str;
 	int keysize;
+	bool logged_impl_name;
 } available_modes[] = {
-	[FS_ENCRYPTION_MODE_AES_256_XTS]      = { "xts(aes)",		64 },
-	[FS_ENCRYPTION_MODE_AES_256_CTS]      = { "cts(cbc(aes))",	32 },
-	[FS_ENCRYPTION_MODE_AES_128_CBC]      = { "cbc(aes)",		16 },
-	[FS_ENCRYPTION_MODE_AES_128_CTS]      = { "cts(cbc(aes))",	16 },
-	[FS_ENCRYPTION_MODE_SPECK128_256_XTS] = { "xts(speck128)",	64 },
-	[FS_ENCRYPTION_MODE_SPECK128_256_CTS] = { "cts(cbc(speck128))",	32 },
+	[FS_ENCRYPTION_MODE_AES_256_XTS] = {
+		.friendly_name = "AES-256-XTS",
+		.cipher_str = "xts(aes)",
+		.keysize = 64,
+	},
+	[FS_ENCRYPTION_MODE_AES_256_CTS] = {
+		.friendly_name = "AES-256-CTS-CBC",
+		.cipher_str = "cts(cbc(aes))",
+		.keysize = 32,
+	},
+	[FS_ENCRYPTION_MODE_AES_128_CBC] = {
+		.friendly_name = "AES-128-CBC",
+		.cipher_str = "cbc(aes)",
+		.keysize = 16,
+	},
+	[FS_ENCRYPTION_MODE_AES_128_CTS] = {
+		.friendly_name = "AES-128-CTS-CBC",
+		.cipher_str = "cts(cbc(aes))",
+		.keysize = 16,
+	},
+	[FS_ENCRYPTION_MODE_SPECK128_256_XTS] = {
+		.friendly_name = "Speck128/256-XTS",
+		.cipher_str = "xts(speck128)",
+		.keysize = 64,
+	},
+	[FS_ENCRYPTION_MODE_SPECK128_256_CTS] = {
+		.friendly_name = "Speck128/256-CTS-CBC",
+		.cipher_str = "cts(cbc(speck128))",
+		.keysize = 32,
+	},
 };
 
-static int determine_cipher_type(struct fscrypt_info *ci, struct inode *inode,
-				 const char **cipher_str_ret, int *keysize_ret)
+static struct fscrypt_mode *
+select_encryption_mode(const struct fscrypt_info *ci, const struct inode *inode)
 {
-	u32 mode;
-
 	if (!fscrypt_valid_enc_modes(ci->ci_data_mode, ci->ci_filename_mode)) {
 		fscrypt_warn(inode->i_sb,
 			     "inode %lu uses unsupported encryption modes (contents mode %d, filenames mode %d)",
 			     inode->i_ino, ci->ci_data_mode,
 			     ci->ci_filename_mode);
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 	}
 
-	if (S_ISREG(inode->i_mode)) {
-		mode = ci->ci_data_mode;
-	} else if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode)) {
-		mode = ci->ci_filename_mode;
-	} else {
-		WARN_ONCE(1, "fscrypt: filesystem tried to load encryption info for inode %lu, which is not encryptable (file type %d)\n",
-			  inode->i_ino, (inode->i_mode & S_IFMT));
-		return -EINVAL;
-	}
+	if (S_ISREG(inode->i_mode))
+		return &available_modes[ci->ci_data_mode];
+
+	if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode))
+		return &available_modes[ci->ci_filename_mode];
 
-	*cipher_str_ret = available_modes[mode].cipher_str;
-	*keysize_ret = available_modes[mode].keysize;
-	return 0;
+	WARN_ONCE(1, "fscrypt: filesystem tried to load encryption info for inode %lu, which is not encryptable (file type %d)\n",
+		  inode->i_ino, (inode->i_mode & S_IFMT));
+	return ERR_PTR(-EINVAL);
 }
 
 static void put_crypt_info(struct fscrypt_info *ci)
@@ -270,8 +290,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	struct fscrypt_info *crypt_info;
 	struct fscrypt_context ctx;
 	struct crypto_skcipher *ctfm;
-	const char *cipher_str;
-	int keysize;
+	struct fscrypt_mode *mode;
 	u8 *raw_key = NULL;
 	int res;
 
@@ -315,40 +334,55 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	memcpy(crypt_info->ci_master_key, ctx.master_key_descriptor,
 				sizeof(crypt_info->ci_master_key));
 
-	res = determine_cipher_type(crypt_info, inode, &cipher_str, &keysize);
-	if (res)
+	mode = select_encryption_mode(crypt_info, inode);
+	if (IS_ERR(mode)) {
+		res = PTR_ERR(mode);
 		goto out;
+	}
 
 	/*
 	 * This cannot be a stack buffer because it is passed to the scatterlist
 	 * crypto API as part of key derivation.
 	 */
 	res = -ENOMEM;
-	raw_key = kmalloc(keysize, GFP_NOFS);
+	raw_key = kmalloc(mode->keysize, GFP_NOFS);
 	if (!raw_key)
 		goto out;
 
-	res = find_and_derive_key(inode, &ctx, raw_key, keysize);
+	res = find_and_derive_key(inode, &ctx, raw_key, mode->keysize);
 	if (res)
 		goto out;
 
-	ctfm = crypto_alloc_skcipher(cipher_str, 0, 0);
+	ctfm = crypto_alloc_skcipher(mode->cipher_str, 0, 0);
 	if (IS_ERR(ctfm)) {
 		res = PTR_ERR(ctfm);
 		fscrypt_warn(inode->i_sb,
 			     "error allocating '%s' transform for inode %lu: %d",
-			     cipher_str, inode->i_ino, res);
+			     mode->cipher_str, inode->i_ino, res);
 		goto out;
 	}
+	if (unlikely(!mode->logged_impl_name)) {
+		/*
+		 * fscrypt performance can vary greatly depending on which
+		 * crypto algorithm implementation is used.  Help people debug
+		 * performance problems by logging the ->cra_driver_name the
+		 * first time a mode is used.  Note that multiple threads can
+		 * race here, but it doesn't really matter.
+		 */
+		mode->logged_impl_name = true;
+		pr_info("fscrypt: %s using implementation \"%s\"\n",
+			mode->friendly_name,
+			crypto_skcipher_alg(ctfm)->base.cra_driver_name);
+	}
 	crypt_info->ci_ctfm = ctfm;
 	crypto_skcipher_set_flags(ctfm, CRYPTO_TFM_REQ_WEAK_KEY);
-	res = crypto_skcipher_setkey(ctfm, raw_key, keysize);
+	res = crypto_skcipher_setkey(ctfm, raw_key, mode->keysize);
 	if (res)
 		goto out;
 
 	if (S_ISREG(inode->i_mode) &&
 	    crypt_info->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
-		res = init_essiv_generator(crypt_info, raw_key, keysize);
+		res = init_essiv_generator(crypt_info, raw_key, mode->keysize);
 		if (res) {
 			fscrypt_warn(inode->i_sb,
 				     "error initializing ESSIV generator for inode %lu: %d",
-- 
2.17.0.441.gb46fe60e1d-goog
