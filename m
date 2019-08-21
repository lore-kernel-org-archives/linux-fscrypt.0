Return-Path: <SRS0=A8Az=WR=samsung.com=boojin.kim@kernel.org>
From: "boojin.kim" <boojin.kim@samsung.com>
Subject: [PATCH 7/9] fscrypt: support diskcipher
Date: Wed, 21 Aug 2019 15:42:36 +0900
Message-ID: <004301d557eb$9ef2c8e0$dcd85aa0$@samsung.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Language: ko
Content-Type: text/plain; charset="utf-8"
References: <CGME20190821064237epcas2p4d8bc4858fda55be213eb51b19e52fc71@epcas2p4.samsung.com>
To: "'Theodore Y. Ts'o'" <tytso@mit.edu>, 'Jaegeuk Kim' <jaegeuk@kernel.org>, 'Eric Biggers' <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: 'Herbert Xu' <herbert@gondor.apana.org.au>, "'David S. Miller'" <davem@davemloft.net>, 'Andreas Dilger' <adilger.kernel@dilger.ca>, dm-devel@redhat.com, 'Mike Snitzer' <snitzer@redhat.com>, 'Alasdair Kergon' <agk@redhat.com>, 'Jens Axboe' <axboe@kernel.dk>, 'Krzysztof Kozlowski' <krzk@kernel.org>, 'Kukjin Kim' <kgene@kernel.org>, 'Jaehoon Chung' <jh80.chung@samsung.com>, linux-mmc@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.netlinux-samsung-soc, linux-arm-kernel@lists.infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

This patch support fscrypt to use diskcipher in a specific crypto mode
(FSCRYPT_MODE_PRIVATE).
Fscrypt allocates diskcipher and sets the key on diskcipher.
Fscrypt doesn't handle additional data encryption when using diskcipher.

Cc: Theodore Y. Ts'o <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Eric Biggers <ebiggers@kernel.org>
Signed-off-by: Boojin Kim <boojin.kim@samsung.com>
---
 fs/buffer.c                   |  2 ++
 fs/crypto/bio.c               | 43 ++++++++++++++++++++++++++-----
 fs/crypto/fscrypt_private.h   | 28 +++++++++++++++++++-
 fs/crypto/keysetup.c          | 60
+++++++++++++++++++++++++++++++++++++++++--
 fs/crypto/keysetup_v1.c       |  2 +-
 include/linux/fscrypt.h       | 19 ++++++++++++++
 include/uapi/linux/fscrypt.h  |  2 ++
 tools/include/uapi/linux/fs.h |  1 +
 8 files changed, 147 insertions(+), 10 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 131d39e..a7de079 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3129,6 +3129,8 @@ static int submit_bh_wbc(int op, int op_flags, struct
buffer_head *bh,
 		wbc_account_cgroup_owner(wbc, bh->b_page, bh->b_size);
 	}
 
+	if (bio->bi_opf & REQ_CRYPT)
+		bio->bi_aux_private = bh->b_private;
 	submit_bio(bio);
 	return 0;
 }
diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 82da251..9e4bf9b 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -24,6 +24,7 @@
 #include <linux/module.h>
 #include <linux/bio.h>
 #include <linux/namei.h>
+#include <crypto/diskcipher.h>
 #include "fscrypt_private.h"
 
 static void __fscrypt_decrypt_bio(struct bio *bio, bool done)
@@ -81,13 +82,19 @@ int fscrypt_zeroout_range(const struct inode *inode,
pgoff_t lblk,
 	if (!ciphertext_page)
 		return -ENOMEM;
 
-	while (len--) {
-		err = fscrypt_crypt_block(inode, FS_ENCRYPT, lblk,
-					  ZERO_PAGE(0), ciphertext_page,
-					  blocksize, 0, GFP_NOFS);
-		if (err)
-			goto errout;
+	if (__fscrypt_disk_encrypted(inode)) {
+		memset(page_address(ciphertext_page), 0, PAGE_SIZE);
+		ciphertext_page->mapping = inode->i_mapping;
+	}
 
+	while (len--) {
+		if (!__fscrypt_disk_encrypted(inode))  {
+			err = fscrypt_crypt_block(inode, FS_ENCRYPT, lblk,
+						  ZERO_PAGE(0),
ciphertext_page,
+						  blocksize, 0, GFP_NOFS);
+			if (err)
+				goto errout;
+		}
 		bio = bio_alloc(GFP_NOWAIT, 1);
 		if (!bio) {
 			err = -ENOMEM;
@@ -103,6 +110,7 @@ int fscrypt_zeroout_range(const struct inode *inode,
pgoff_t lblk,
 			err = -EIO;
 			goto errout;
 		}
+		fscrypt_set_bio(inode, bio, 0);
 		err = submit_bio_wait(bio);
 		if (err == 0 && bio->bi_status)
 			err = -EIO;
@@ -118,3 +126,26 @@ int fscrypt_zeroout_range(const struct inode *inode,
pgoff_t lblk,
 	return err;
 }
 EXPORT_SYMBOL(fscrypt_zeroout_range);
+
+int fscrypt_disk_encrypted(const struct inode *inode)
+{
+	return __fscrypt_disk_encrypted(inode);
+}
+
+void fscrypt_set_bio(const struct inode *inode, struct bio *bio, u64 dun)
+{
+#ifdef CONFIG_CRYPTO_DISKCIPHER
+	if (__fscrypt_disk_encrypted(inode))
+		crypto_diskcipher_set(bio, inode->i_crypt_info->ci_dtfm,
+					inode, dun);
+#endif
+}
+
+void *fscrypt_get_diskcipher(const struct inode *inode)
+{
+#ifdef CONFIG_CRYPTO_DISKCIPHER
+	if (fscrypt_has_encryption_key(inode))
+		return inode->i_crypt_info->ci_dtfm;
+#endif
+	return NULL;
+}
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index e84efc0..d2b5fb6 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -163,6 +163,10 @@ struct fscrypt_info {
 	/* The actual crypto transform used for encryption and decryption */
 	struct crypto_skcipher *ci_ctfm;
 
+	/* Cipher for inline encryption engine */
+#ifdef CONFIG_CRYPTO_DISKCIPHER
+	struct crypto_diskcipher *ci_dtfm;
+#endif
 	/*
 	 * Cipher for ESSIV IV generation.  Only set for CBC contents
 	 * encryption, otherwise is NULL.
@@ -226,6 +230,10 @@ static inline bool fscrypt_valid_enc_modes(u32
contents_mode,
 	    filenames_mode == FSCRYPT_MODE_ADIANTUM)
 		return true;
 
+	if (contents_mode == FSCRYPT_MODE_PRIVATE &&
+		filenames_mode == FSCRYPT_MODE_AES_256_CTS)
+		return true;
+
 	return false;
 }
 
@@ -438,13 +446,19 @@ extern int __init fscrypt_init_keyring(void);
 
 /* keysetup.c */
 
+enum cipher_flags {
+	CRYPT_MODE_SKCIPHER,
+	CRYPT_MODE_ESSIV,
+	CRYPT_MODE_DISKCIPHER,
+};
+
 struct fscrypt_mode {
 	const char *friendly_name;
 	const char *cipher_str;
 	int keysize;
 	int ivsize;
 	bool logged_impl_name;
-	bool needs_essiv;
+	enum cipher_flags flags;
 };
 
 static inline bool
@@ -453,6 +467,18 @@ fscrypt_mode_supports_direct_key(const struct
fscrypt_mode *mode)
 	return mode->ivsize >= offsetofend(union fscrypt_iv, nonce);
 }
 
+static inline int __fscrypt_disk_encrypted(const struct inode *inode)
+{
+#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
+#if IS_ENABLED(CONFIG_CRYPTO_DISKCIPHER)
+	if (inode && inode->i_crypt_info)
+		return S_ISREG(inode->i_mode) &&
+			(inode->i_crypt_info->ci_dtfm != NULL);
+#endif
+#endif
+	return 0;
+}
+
 extern struct crypto_skcipher *
 fscrypt_allocate_skcipher(struct fscrypt_mode *mode, const u8 *raw_key,
 			  const struct inode *inode);
diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index d71c2d6..06d9609 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -11,6 +11,7 @@
 #include <crypto/aes.h>
 #include <crypto/sha.h>
 #include <crypto/skcipher.h>
+#include <crypto/diskcipher.h>
 #include <linux/key.h>
 
 #include "fscrypt_private.h"
@@ -35,7 +36,7 @@ static struct fscrypt_mode available_modes[] = {
 		.cipher_str = "cbc(aes)",
 		.keysize = 16,
 		.ivsize = 16,
-		.needs_essiv = true,
+		.flags = CRYPT_MODE_ESSIV,
 	},
 	[FSCRYPT_MODE_AES_128_CTS] = {
 		.friendly_name = "AES-128-CTS-CBC",
@@ -49,6 +50,13 @@ static struct fscrypt_mode available_modes[] = {
 		.keysize = 32,
 		.ivsize = 32,
 	},
+	[FSCRYPT_MODE_PRIVATE] = {
+		.friendly_name = "AES-256-XTS-DISK",
+		.cipher_str = "xts(aes)-disk",
+		.keysize = 64,
+		.ivsize = 16,
+		.flags = CRYPT_MODE_DISKCIPHER,
+	},
 };
 
 static struct fscrypt_mode *
@@ -111,6 +119,35 @@ struct crypto_skcipher
*fscrypt_allocate_skcipher(struct fscrypt_mode *mode,
 	return ERR_PTR(err);
 }
 
+#if defined(CONFIG_CRYPTO_DISKCIPHER)
+/* Create a diskcipher cipher object for the given encryption mode and key
*/
+static struct crypto_diskcipher *fscrypt_allocate_diskcipher(
+		struct fscrypt_mode *mode, const u8 *raw_key,
+			   const struct inode *inode)
+{
+	struct crypto_diskcipher *tfm;
+	int err;
+	bool force = (mode->flags == CRYPT_MODE_DISKCIPHER) ? 0 : 1;
+
+	tfm = crypto_alloc_diskcipher(mode->cipher_str, 0, 0, force);
+	if (IS_ERR(tfm)) {
+		fscrypt_warn(inode->i_sb,
+				 "error allocating '%s' transform for inode
%lu: %ld",
+				 mode->cipher_str, inode->i_ino,
PTR_ERR(tfm));
+		return tfm;
+	}
+	err = crypto_diskcipher_setkey(tfm, raw_key, mode->keysize, 0);
+	if (err)
+		goto err_free_dtfm;
+
+	return tfm;
+
+err_free_dtfm:
+	crypto_free_diskcipher(tfm);
+	return ERR_PTR(err);
+}
+#endif
+
 static int derive_essiv_salt(const u8 *key, int keysize, u8 *salt)
 {
 	struct crypto_shash *tfm = READ_ONCE(essiv_hash_tfm);
@@ -187,13 +224,29 @@ int fscrypt_set_derived_key(struct fscrypt_info *ci,
const u8 *derived_key)
 	struct crypto_skcipher *ctfm;
 	int err;
 
+#if defined(CONFIG_CRYPTO_DISKCIPHER)
+	if (S_ISREG(ci->ci_inode->i_mode) &&
+		(mode->flags == CRYPT_MODE_DISKCIPHER)) {
+		ci->ci_dtfm = fscrypt_allocate_diskcipher(mode, derived_key,
+
ci->ci_inode);
+		if (IS_ERR(ci->ci_dtfm)) {
+			fscrypt_warn(ci->ci_inode,
+				     "Error allocating Diskcipher: %p",
+				     PTR_ERR(ci->ci_dtfm));
+			ci->ci_dtfm = NULL;
+			return -EINVAL;
+		}
+		return 0;
+	}
+#endif
+
 	ctfm = fscrypt_allocate_skcipher(mode, derived_key, ci->ci_inode);
 	if (IS_ERR(ctfm))
 		return PTR_ERR(ctfm);
 
 	ci->ci_ctfm = ctfm;
 
-	if (mode->needs_essiv) {
+	if (mode->flags == CRYPT_MODE_ESSIV) {
 		err = init_essiv_generator(ci, derived_key, mode->keysize);
 		if (err) {
 			fscrypt_warn(ci->ci_inode,
@@ -394,6 +447,9 @@ static void put_crypt_info(struct fscrypt_info *ci)
 		   !fscrypt_is_direct_key_policy(&ci->ci_policy)) {
 		crypto_free_skcipher(ci->ci_ctfm);
 		crypto_free_cipher(ci->ci_essiv_tfm);
+#if defined(CONFIG_CRYPTO_DISKCIPHER)
+		crypto_free_diskcipher(ci->ci_dtfm);
+#endif
 	}
 
 	key = ci->ci_master_key;
diff --git a/fs/crypto/keysetup_v1.c b/fs/crypto/keysetup_v1.c
index 0727251..22d0330 100644
--- a/fs/crypto/keysetup_v1.c
+++ b/fs/crypto/keysetup_v1.c
@@ -271,7 +271,7 @@ static int setup_v1_file_key_direct(struct fscrypt_info
*ci,
 	}
 
 	/* ESSIV implies 16-byte IVs which implies !DIRECT_KEY */
-	if (WARN_ON(mode->needs_essiv))
+	if (WARN_ON(mode->flags == CRYPT_MODE_ESSIV))
 		return -EINVAL;
 
 	dk = fscrypt_get_direct_key(ci, raw_master_key);
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index f622f74..e0f99db 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -274,6 +274,11 @@ static inline void fscrypt_set_ops(struct super_block
*sb,
 {
 	sb->s_cop = s_cop;
 }
+
+void fscrypt_set_bio(const struct inode *inode, struct bio *bio, u64 dun);
+void *fscrypt_get_diskcipher(const struct inode *inode);
+int fscrypt_disk_encrypted(const struct inode *inode);
+
 #else  /* !CONFIG_FS_ENCRYPTION */
 
 static inline bool fscrypt_has_encryption_key(const struct inode *inode)
@@ -556,6 +561,20 @@ static inline void fscrypt_set_ops(struct super_block
*sb,
 {
 }
 
+static inline int fscrypt_disk_encrypted(const struct inode *inode)
+{
+	return 0;
+}
+
+static inline void fscrypt_set_bio(const struct inode *inode,
+					struct bio *bio, u64 dun)
+{
+}
+
+static inline void *fscrypt_get_diskcipher(const struct inode *inode)
+{
+	return NULL;
+}
 #endif	/* !CONFIG_FS_ENCRYPTION */
 
 /**
diff --git a/include/uapi/linux/fscrypt.h b/include/uapi/linux/fscrypt.h
index 39ccfe9..b9978c4 100644
--- a/include/uapi/linux/fscrypt.h
+++ b/include/uapi/linux/fscrypt.h
@@ -25,6 +25,7 @@
 #define FSCRYPT_MODE_AES_128_CBC		5
 #define FSCRYPT_MODE_AES_128_CTS		6
 #define FSCRYPT_MODE_ADIANTUM			9
+#define FSCRYPT_MODE_PRIVATE			127
 #define __FSCRYPT_MODE_MAX			9
 
 /*
@@ -173,6 +174,7 @@ struct fscrypt_get_key_status_arg {
 #define FS_ENCRYPTION_MODE_SPECK128_256_XTS	7	/* removed */
 #define FS_ENCRYPTION_MODE_SPECK128_256_CTS	8	/* removed */
 #define FS_ENCRYPTION_MODE_ADIANTUM	FSCRYPT_MODE_ADIANTUM
+#define FS_ENCRYPTION_MODE_PRIVATE	FSCRYPT_MODE_PRIVATE
 #define FS_KEY_DESC_PREFIX		FSCRYPT_KEY_DESC_PREFIX
 #define FS_KEY_DESC_PREFIX_SIZE		FSCRYPT_KEY_DESC_PREFIX_SIZE
 #define FS_MAX_KEY_SIZE			FSCRYPT_MAX_KEY_SIZE
diff --git a/tools/include/uapi/linux/fs.h b/tools/include/uapi/linux/fs.h
index 2a616aa..dd3566a 100644
--- a/tools/include/uapi/linux/fs.h
+++ b/tools/include/uapi/linux/fs.h
@@ -237,6 +237,7 @@ struct fsxattr {
 #define FS_ENCRYPTION_MODE_SPECK128_256_XTS	7 /* Removed, do not use. */
 #define FS_ENCRYPTION_MODE_SPECK128_256_CTS	8 /* Removed, do not use. */
 #define FS_ENCRYPTION_MODE_ADIANTUM		9
+#define FS_ENCRYPTION_MODE_PRIVATE		127
 
 struct fscrypt_policy {
 	__u8 version;
-- 
2.7.4
