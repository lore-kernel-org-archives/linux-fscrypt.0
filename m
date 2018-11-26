Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:50582 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725884AbeK0GZC (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 27 Nov 2018 01:25:02 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v4] fscrypt: add Adiantum support
Date: Mon, 26 Nov 2018 11:27:37 -0800
Message-Id: <20181126192737.129355-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Hi Ted, please consider applying this patch to the fscrypt tree for
v4.21.  Note: there isn't a build-time dependency on Adiantum support in
the crypto API, so it isn't required to wait for that to reach mainline
first (currently it's in cryptodev).

Changed since v3:

  - For Adiantum using derived keys, use the same IV generation method
    as AES-XTS, i.e. don't include the per-file nonce in the IVs.  The
    nonce is only included in "direct key" mode.  Either way is secure,
    but I think this way is slightly more logical.

  - Renamed FS_POLICY_FLAGS_DIRECT to FS_POLICY_FLAG_DIRECT_KEY.

  - Various other cleanups.

>8------------------------------------------------------8<

Add support for the Adiantum encryption mode to fscrypt.  Adiantum is a
tweakable, length-preserving encryption mode with security provably
reducible to that of XChaCha12 and AES-256, subject to a security bound.
It's also a true wide-block mode, unlike XTS.  See the paper
"Adiantum: length-preserving encryption for entry-level processors"
(https://eprint.iacr.org/2018/720.pdf) for more details.  Also see
commit 059c2a4d8e16 ("crypto: adiantum - add Adiantum support").

On sufficiently long messages, Adiantum's bottlenecks are XChaCha12 and
the NH hash function.  These algorithms are fast even on processors
without dedicated crypto instructions.  Adiantum makes it feasible to
enable storage encryption on low-end mobile devices that lack AES
instructions; currently such devices are unencrypted.  On ARM Cortex-A7,
on 4096-byte messages Adiantum encryption is about 4 times faster than
AES-256-XTS encryption; decryption is about 5 times faster.

In fscrypt, Adiantum is suitable for encrypting both file contents and
names.  With filenames, it fixes a known weakness: when two filenames in
a directory share a common prefix of >= 16 bytes, with CTS-CBC their
encrypted filenames share a common prefix too, leaking information.
Adiantum does not have this problem.

Since Adiantum also accepts long tweaks (IVs), it's also safe to use the
master key directly for Adiantum encryption rather than deriving
per-file keys, provided that the per-file nonce is included in the IVs
and the master key isn't used for any other encryption mode.  This
configuration saves memory and improves performance.  A new fscrypt
policy flag is added to allow users to opt-in to this configuration.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---

 Documentation/filesystems/fscrypt.rst | 179 +++++++------
 fs/crypto/crypto.c                    |  28 +-
 fs/crypto/fname.c                     |  22 +-
 fs/crypto/fscrypt_private.h           |  67 ++++-
 fs/crypto/keyinfo.c                   | 351 ++++++++++++++++++++------
 fs/crypto/policy.c                    |   5 +-
 include/uapi/linux/fs.h               |   4 +-
 7 files changed, 468 insertions(+), 188 deletions(-)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index cfbc18f0d9c9..3a7b60521b94 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -132,47 +132,28 @@ designed for this purpose be used, such as scrypt, PBKDF2, or Argon2.
 Per-file keys
 -------------
 
-Master keys are not used to encrypt file contents or names directly.
-Instead, a unique key is derived for each encrypted file, including
-each regular file, directory, and symbolic link.  This has several
-advantages:
-
-- In cryptosystems, the same key material should never be used for
-  different purposes.  Using the master key as both an XTS key for
-  contents encryption and as a CTS-CBC key for filenames encryption
-  would violate this rule.
-- Per-file keys simplify the choice of IVs (Initialization Vectors)
-  for contents encryption.  Without per-file keys, to ensure IV
-  uniqueness both the inode and logical block number would need to be
-  encoded in the IVs.  This would make it impossible to renumber
-  inodes, which e.g. ``resize2fs`` can do when resizing an ext4
-  filesystem.  With per-file keys, it is sufficient to encode just the
-  logical block number in the IVs.
-- Per-file keys strengthen the encryption of filenames, where IVs are
-  reused out of necessity.  With a unique key per directory, IV reuse
-  is limited to within a single directory.
-- Per-file keys allow individual files to be securely erased simply by
-  securely erasing their keys.  (Not yet implemented.)
-
-A KDF (Key Derivation Function) is used to derive per-file keys from
-the master key.  This is done instead of wrapping a randomly-generated
-key for each file because it reduces the size of the encryption xattr,
-which for some filesystems makes the xattr more likely to fit in-line
-in the filesystem's inode table.  With a KDF, only a 16-byte nonce is
-required --- long enough to make key reuse extremely unlikely.  A
-wrapped key, on the other hand, would need to be up to 64 bytes ---
-the length of an AES-256-XTS key.  Furthermore, currently there is no
-requirement to support unlocking a file with multiple alternative
-master keys or to support rotating master keys.  Instead, the master
-keys may be wrapped in userspace, e.g. as done by the `fscrypt
-<https://github.com/google/fscrypt>`_ tool.
-
-The current KDF encrypts the master key using the 16-byte nonce as an
-AES-128-ECB key.  The output is used as the derived key.  If the
-output is longer than needed, then it is truncated to the needed
-length.  Truncation is the norm for directories and symlinks, since
-those use the CTS-CBC encryption mode which requires a key half as
-long as that required by the XTS encryption mode.
+Since each master key can protect many files, it is necessary to
+"tweak" the encryption of each file so that the same plaintext in two
+files doesn't map to the same ciphertext, or vice versa.  In most
+cases, fscrypt does this by deriving per-file keys.  When a new
+encrypted inode (regular file, directory, or symlink) is created,
+fscrypt randomly generates a 16-byte nonce and stores it in the
+inode's encryption xattr.  Then, it uses a KDF (Key Derivation
+Function) to derive the file's key from the master key and nonce.
+
+The Adiantum encryption mode (see `Encryption modes and usage`_) is
+special, since it accepts longer IVs and is suitable for both contents
+and filenames encryption.  For it, a "direct key" option is offered
+where the file's nonce is included in the IVs and the master key is
+used for encryption directly.  This improves performance; however,
+users must not use the same master key for any other encryption mode.
+
+Below, the KDF and design considerations are described in more detail.
+
+The current KDF works by encrypting the master key with AES-128-ECB,
+using the file's nonce as the AES key.  The output is used as the
+derived key.  If the output is longer than needed, then it is
+truncated to the needed length.
 
 Note: this KDF meets the primary security requirement, which is to
 produce unique derived keys that preserve the entropy of the master
@@ -181,6 +162,20 @@ However, it is nonstandard and has some problems such as being
 reversible, so it is generally considered to be a mistake!  It may be
 replaced with HKDF or another more standard KDF in the future.
 
+Key derivation was chosen over key wrapping because wrapped keys would
+require larger xattrs which would be less likely to fit in-line in the
+filesystem's inode table, and there didn't appear to be any
+significant advantages to key wrapping.  In particular, currently
+there is no requirement to support unlocking a file with multiple
+alternative master keys or to support rotating master keys.  Instead,
+the master keys may be wrapped in userspace, e.g. as is done by the
+`fscrypt <https://github.com/google/fscrypt>`_ tool.
+
+Including the inode number in the IVs was considered.  However, it was
+rejected as it would have prevented ext4 filesystems from being
+resized, and by itself still wouldn't have been sufficient to prevent
+the same key from being directly reused for both XTS and CTS-CBC.
+
 Encryption modes and usage
 ==========================
 
@@ -191,54 +186,80 @@ Currently, the following pairs of encryption modes are supported:
 
 - AES-256-XTS for contents and AES-256-CTS-CBC for filenames
 - AES-128-CBC for contents and AES-128-CTS-CBC for filenames
+- Adiantum for both contents and filenames
+
+If unsure, you should use the (AES-256-XTS, AES-256-CTS-CBC) pair.
 
-It is strongly recommended to use AES-256-XTS for contents encryption.
 AES-128-CBC was added only for low-powered embedded devices with
 crypto accelerators such as CAAM or CESA that do not support XTS.
 
+Adiantum is a (primarily) stream cipher-based mode that is fast even
+on CPUs without dedicated crypto instructions.  It's also a true
+wide-block mode, unlike XTS.  It can also eliminate the need to derive
+per-file keys.  However, it depends on the security of two primitives,
+XChaCha12 and AES-256, rather than just one.  See the paper
+"Adiantum: length-preserving encryption for entry-level processors"
+(https://eprint.iacr.org/2018/720.pdf) for more details.  To use
+Adiantum, CONFIG_CRYPTO_ADIANTUM must be enabled.  Also, fast
+implementations of ChaCha and NHPoly1305 should be enabled, e.g.
+CONFIG_CRYPTO_CHACHA20_NEON and CONFIG_CRYPTO_NHPOLY1305_NEON for ARM.
+
 New encryption modes can be added relatively easily, without changes
 to individual filesystems.  However, authenticated encryption (AE)
 modes are not currently supported because of the difficulty of dealing
 with ciphertext expansion.
 
+Contents encryption
+-------------------
+
 For file contents, each filesystem block is encrypted independently.
 Currently, only the case where the filesystem block size is equal to
-the system's page size (usually 4096 bytes) is supported.  With the
-XTS mode of operation (recommended), the logical block number within
-the file is used as the IV.  With the CBC mode of operation (not
-recommended), ESSIV is used; specifically, the IV for CBC is the
-logical block number encrypted with AES-256, where the AES-256 key is
-the SHA-256 hash of the inode's data encryption key.
-
-For filenames, the full filename is encrypted at once.  Because of the
-requirements to retain support for efficient directory lookups and
-filenames of up to 255 bytes, a constant initialization vector (IV) is
-used.  However, each encrypted directory uses a unique key, which
-limits IV reuse to within a single directory.  Note that IV reuse in
-the context of CTS-CBC encryption means that when the original
-filenames share a common prefix at least as long as the cipher block
-size (16 bytes for AES), the corresponding encrypted filenames will
-also share a common prefix.  This is undesirable; it may be fixed in
-the future by switching to an encryption mode that is a strong
-pseudorandom permutation on arbitrary-length messages, e.g. the HEH
-(Hash-Encrypt-Hash) mode.
-
-Since filenames are encrypted with the CTS-CBC mode of operation, the
-plaintext and ciphertext filenames need not be multiples of the AES
-block size, i.e. 16 bytes.  However, the minimum size that can be
-encrypted is 16 bytes, so shorter filenames are NUL-padded to 16 bytes
-before being encrypted.  In addition, to reduce leakage of filename
-lengths via their ciphertexts, all filenames are NUL-padded to the
-next 4, 8, 16, or 32-byte boundary (configurable).  32 is recommended
-since this provides the best confidentiality, at the cost of making
-directory entries consume slightly more space.  Note that since NUL
-(``\0``) is not otherwise a valid character in filenames, the padding
-will never produce duplicate plaintexts.
+the system's page size (usually 4096 bytes) is supported.
+
+Each block's IV is set to the logical block number within the file as
+a little endian number, except that:
+
+- With CBC mode encryption, ESSIV is also used.  Specifically, each IV
+  is encrypted with AES-256 where the AES-256 key is the SHA-256 hash
+  of the file's data encryption key.
+
+- In the "direct key" configuration (FS_POLICY_FLAG_DIRECT_KEY set in
+  the fscrypt_policy), the file's nonce is also appended to the IV.
+  Currently this is only allowed with the Adiantum encryption mode.
+
+Filenames encryption
+--------------------
+
+For filenames, each full filename is encrypted at once.  Because of
+the requirements to retain support for efficient directory lookups and
+filenames of up to 255 bytes, the same IV is used for every filename
+in a directory.
+
+However, each encrypted directory still uses a unique key; or
+alternatively (for the "direct key" configuration) has the file's
+nonce included in the IVs.  Thus, IV reuse is limited to within a
+single directory.
+
+With CTS-CBC, the IV reuse means that when the plaintext filenames
+share a common prefix at least as long as the cipher block size (16
+bytes for AES), the corresponding encrypted filenames will also share
+a common prefix.  This is undesirable.  Adiantum does not have this
+weakness, as it is a wide-block encryption mode.
+
+All supported filenames encryption modes accept any plaintext length
+>= 16 bytes; cipher block alignment is not required.  However,
+filenames shorter than 16 bytes are NUL-padded to 16 bytes before
+being encrypted.  In addition, to reduce leakage of filename lengths
+via their ciphertexts, all filenames are NUL-padded to the next 4, 8,
+16, or 32-byte boundary (configurable).  32 is recommended since this
+provides the best confidentiality, at the cost of making directory
+entries consume slightly more space.  Note that since NUL (``\0``) is
+not otherwise a valid character in filenames, the padding will never
+produce duplicate plaintexts.
 
 Symbolic link targets are considered a type of filename and are
-encrypted in the same way as filenames in directory entries.  Each
-symlink also uses a unique key; hence, the hardcoded IV is not a
-problem for symlinks.
+encrypted in the same way as filenames in directory entries, except
+that IV reuse is not a problem as each symlink has its own inode.
 
 User API
 ========
@@ -272,9 +293,13 @@ This structure must be initialized as follows:
   and FS_ENCRYPTION_MODE_AES_256_CTS (4) for
   ``filenames_encryption_mode``.
 
-- ``flags`` must be set to a value from ``<linux/fs.h>`` which
+- ``flags`` must contain a value from ``<linux/fs.h>`` which
   identifies the amount of NUL-padding to use when encrypting
   filenames.  If unsure, use FS_POLICY_FLAGS_PAD_32 (0x3).
+  In addition, if the chosen encryption modes are both
+  FS_ENCRYPTION_MODE_ADIANTUM, this can contain
+  FS_POLICY_FLAG_DIRECT_KEY to specify that the master key should be
+  used directly, without key derivation.
 
 - ``master_key_descriptor`` specifies how to find the master key in
   the keyring; see `Adding keys`_.  It is up to userspace to choose a
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 0f46cf550907..4dc788e3bc96 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -133,15 +133,25 @@ struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode, gfp_t gfp_flags)
 }
 EXPORT_SYMBOL(fscrypt_get_ctx);
 
+void fscrypt_generate_iv(union fscrypt_iv *iv, u64 lblk_num,
+			 const struct fscrypt_info *ci)
+{
+	memset(iv, 0, ci->ci_mode->ivsize);
+	iv->lblk_num = cpu_to_le64(lblk_num);
+
+	if (ci->ci_flags & FS_POLICY_FLAG_DIRECT_KEY)
+		memcpy(iv->nonce, ci->ci_nonce, FS_KEY_DERIVATION_NONCE_SIZE);
+
+	if (ci->ci_essiv_tfm != NULL)
+		crypto_cipher_encrypt_one(ci->ci_essiv_tfm, iv->raw, iv->raw);
+}
+
 int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 			   u64 lblk_num, struct page *src_page,
 			   struct page *dest_page, unsigned int len,
 			   unsigned int offs, gfp_t gfp_flags)
 {
-	struct {
-		__le64 index;
-		u8 padding[FS_IV_SIZE - sizeof(__le64)];
-	} iv;
+	union fscrypt_iv iv;
 	struct skcipher_request *req = NULL;
 	DECLARE_CRYPTO_WAIT(wait);
 	struct scatterlist dst, src;
@@ -151,15 +161,7 @@ int fscrypt_do_page_crypto(const struct inode *inode, fscrypt_direction_t rw,
 
 	BUG_ON(len == 0);
 
-	BUILD_BUG_ON(sizeof(iv) != FS_IV_SIZE);
-	BUILD_BUG_ON(AES_BLOCK_SIZE != FS_IV_SIZE);
-	iv.index = cpu_to_le64(lblk_num);
-	memset(iv.padding, 0, sizeof(iv.padding));
-
-	if (ci->ci_essiv_tfm != NULL) {
-		crypto_cipher_encrypt_one(ci->ci_essiv_tfm, (u8 *)&iv,
-					  (u8 *)&iv);
-	}
+	fscrypt_generate_iv(&iv, lblk_num, ci);
 
 	req = skcipher_request_alloc(tfm, gfp_flags);
 	if (!req)
diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index d7a0f682ca12..7ff40a73dbec 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -40,10 +40,11 @@ int fname_encrypt(struct inode *inode, const struct qstr *iname,
 {
 	struct skcipher_request *req = NULL;
 	DECLARE_CRYPTO_WAIT(wait);
-	struct crypto_skcipher *tfm = inode->i_crypt_info->ci_ctfm;
-	int res = 0;
-	char iv[FS_CRYPTO_BLOCK_SIZE];
+	struct fscrypt_info *ci = inode->i_crypt_info;
+	struct crypto_skcipher *tfm = ci->ci_ctfm;
+	union fscrypt_iv iv;
 	struct scatterlist sg;
+	int res;
 
 	/*
 	 * Copy the filename to the output buffer for encrypting in-place and
@@ -55,7 +56,7 @@ int fname_encrypt(struct inode *inode, const struct qstr *iname,
 	memset(out + iname->len, 0, olen - iname->len);
 
 	/* Initialize the IV */
-	memset(iv, 0, FS_CRYPTO_BLOCK_SIZE);
+	fscrypt_generate_iv(&iv, 0, ci);
 
 	/* Set up the encryption request */
 	req = skcipher_request_alloc(tfm, GFP_NOFS);
@@ -65,7 +66,7 @@ int fname_encrypt(struct inode *inode, const struct qstr *iname,
 			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 			crypto_req_done, &wait);
 	sg_init_one(&sg, out, olen);
-	skcipher_request_set_crypt(req, &sg, &sg, olen, iv);
+	skcipher_request_set_crypt(req, &sg, &sg, olen, &iv);
 
 	/* Do the encryption */
 	res = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
@@ -94,9 +95,10 @@ static int fname_decrypt(struct inode *inode,
 	struct skcipher_request *req = NULL;
 	DECLARE_CRYPTO_WAIT(wait);
 	struct scatterlist src_sg, dst_sg;
-	struct crypto_skcipher *tfm = inode->i_crypt_info->ci_ctfm;
-	int res = 0;
-	char iv[FS_CRYPTO_BLOCK_SIZE];
+	struct fscrypt_info *ci = inode->i_crypt_info;
+	struct crypto_skcipher *tfm = ci->ci_ctfm;
+	union fscrypt_iv iv;
+	int res;
 
 	/* Allocate request */
 	req = skcipher_request_alloc(tfm, GFP_NOFS);
@@ -107,12 +109,12 @@ static int fname_decrypt(struct inode *inode,
 		crypto_req_done, &wait);
 
 	/* Initialize IV */
-	memset(iv, 0, FS_CRYPTO_BLOCK_SIZE);
+	fscrypt_generate_iv(&iv, 0, ci);
 
 	/* Create decryption request */
 	sg_init_one(&src_sg, iname->name, iname->len);
 	sg_init_one(&dst_sg, oname->name, oname->len);
-	skcipher_request_set_crypt(req, &src_sg, &dst_sg, iname->len, iv);
+	skcipher_request_set_crypt(req, &src_sg, &dst_sg, iname->len, &iv);
 	res = crypto_wait_req(crypto_skcipher_decrypt(req), &wait);
 	skcipher_request_free(req);
 	if (res < 0) {
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 79debfc9cef9..7424f851eb5c 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -17,7 +17,6 @@
 #include <crypto/hash.h>
 
 /* Encryption parameters */
-#define FS_IV_SIZE			16
 #define FS_KEY_DERIVATION_NONCE_SIZE	16
 
 /**
@@ -52,16 +51,42 @@ struct fscrypt_symlink_data {
 } __packed;
 
 /*
- * A pointer to this structure is stored in the file system's in-core
- * representation of an inode.
+ * fscrypt_info - the "encryption key" for an inode
+ *
+ * When an encrypted file's key is made available, an instance of this struct is
+ * allocated and stored in ->i_crypt_info.  Once created, it remains until the
+ * inode is evicted.
  */
 struct fscrypt_info {
+
+	/* The actual crypto transform used for encryption and decryption */
+	struct crypto_skcipher *ci_ctfm;
+
+	/*
+	 * Cipher for ESSIV IV generation.  Only set for CBC contents
+	 * encryption, otherwise is NULL.
+	 */
+	struct crypto_cipher *ci_essiv_tfm;
+
+	/*
+	 * Encryption mode used for this inode.  It corresponds to either
+	 * ci_data_mode or ci_filename_mode, depending on the inode type.
+	 */
+	struct fscrypt_mode *ci_mode;
+
+	/*
+	 * If non-NULL, then this inode uses a master key directly rather than a
+	 * derived key, and ci_ctfm will equal ci_master_key->mk_ctfm.
+	 * Otherwise, this inode uses a derived key.
+	 */
+	struct fscrypt_master_key *ci_master_key;
+
+	/* fields from the fscrypt_context */
 	u8 ci_data_mode;
 	u8 ci_filename_mode;
 	u8 ci_flags;
-	struct crypto_skcipher *ci_ctfm;
-	struct crypto_cipher *ci_essiv_tfm;
-	u8 ci_master_key[FS_KEY_DESCRIPTOR_SIZE];
+	u8 ci_master_key_descriptor[FS_KEY_DESCRIPTOR_SIZE];
+	u8 ci_nonce[FS_KEY_DERIVATION_NONCE_SIZE];
 };
 
 typedef enum {
@@ -83,6 +108,10 @@ static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
 	    filenames_mode == FS_ENCRYPTION_MODE_AES_256_CTS)
 		return true;
 
+	if (contents_mode == FS_ENCRYPTION_MODE_ADIANTUM &&
+	    filenames_mode == FS_ENCRYPTION_MODE_ADIANTUM)
+		return true;
+
 	return false;
 }
 
@@ -107,6 +136,22 @@ fscrypt_msg(struct super_block *sb, const char *level, const char *fmt, ...);
 #define fscrypt_err(sb, fmt, ...)		\
 	fscrypt_msg(sb, KERN_ERR, fmt, ##__VA_ARGS__)
 
+#define FSCRYPT_MAX_IV_SIZE	32
+
+union fscrypt_iv {
+	struct {
+		/* logical block number within the file */
+		__le64 lblk_num;
+
+		/* per-file nonce; only set in DIRECT_KEY mode */
+		u8 nonce[FS_KEY_DERIVATION_NONCE_SIZE];
+	};
+	u8 raw[FSCRYPT_MAX_IV_SIZE];
+};
+
+void fscrypt_generate_iv(union fscrypt_iv *iv, u64 lblk_num,
+			 const struct fscrypt_info *ci);
+
 /* fname.c */
 extern int fname_encrypt(struct inode *inode, const struct qstr *iname,
 			 u8 *out, unsigned int olen);
@@ -115,6 +160,16 @@ extern bool fscrypt_fname_encrypted_size(const struct inode *inode,
 					 u32 *encrypted_len_ret);
 
 /* keyinfo.c */
+
+struct fscrypt_mode {
+	const char *friendly_name;
+	const char *cipher_str;
+	int keysize;
+	int ivsize;
+	bool logged_impl_name;
+	bool needs_essiv;
+};
+
 extern void __exit fscrypt_essiv_cleanup(void);
 
 #endif /* _FSCRYPT_PRIVATE_H */
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 7874c9bb2fc5..1e11a683f63d 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -10,15 +10,21 @@
  */
 
 #include <keys/user-type.h>
+#include <linux/hashtable.h>
 #include <linux/scatterlist.h>
 #include <linux/ratelimit.h>
 #include <crypto/aes.h>
+#include <crypto/algapi.h>
 #include <crypto/sha.h>
 #include <crypto/skcipher.h>
 #include "fscrypt_private.h"
 
 static struct crypto_shash *essiv_hash_tfm;
 
+/* Table of keys referenced by FS_POLICY_FLAG_DIRECT_KEY policies */
+static DEFINE_HASHTABLE(fscrypt_master_keys, 6); /* 6 bits = 64 buckets */
+static DEFINE_SPINLOCK(fscrypt_master_keys_lock);
+
 /*
  * Key derivation function.  This generates the derived key by encrypting the
  * master key with AES-128-ECB using the inode's nonce as the AES key.
@@ -123,56 +129,37 @@ find_and_lock_process_key(const char *prefix,
 	return ERR_PTR(-ENOKEY);
 }
 
-/* Find the master key, then derive the inode's actual encryption key */
-static int find_and_derive_key(const struct inode *inode,
-			       const struct fscrypt_context *ctx,
-			       u8 *derived_key, unsigned int derived_keysize)
-{
-	struct key *key;
-	const struct fscrypt_key *payload;
-	int err;
-
-	key = find_and_lock_process_key(FS_KEY_DESC_PREFIX,
-					ctx->master_key_descriptor,
-					derived_keysize, &payload);
-	if (key == ERR_PTR(-ENOKEY) && inode->i_sb->s_cop->key_prefix) {
-		key = find_and_lock_process_key(inode->i_sb->s_cop->key_prefix,
-						ctx->master_key_descriptor,
-						derived_keysize, &payload);
-	}
-	if (IS_ERR(key))
-		return PTR_ERR(key);
-	err = derive_key_aes(payload->raw, ctx, derived_key, derived_keysize);
-	up_read(&key->sem);
-	key_put(key);
-	return err;
-}
-
-static struct fscrypt_mode {
-	const char *friendly_name;
-	const char *cipher_str;
-	int keysize;
-	bool logged_impl_name;
-} available_modes[] = {
+static struct fscrypt_mode available_modes[] = {
 	[FS_ENCRYPTION_MODE_AES_256_XTS] = {
 		.friendly_name = "AES-256-XTS",
 		.cipher_str = "xts(aes)",
 		.keysize = 64,
+		.ivsize = 16,
 	},
 	[FS_ENCRYPTION_MODE_AES_256_CTS] = {
 		.friendly_name = "AES-256-CTS-CBC",
 		.cipher_str = "cts(cbc(aes))",
 		.keysize = 32,
+		.ivsize = 16,
 	},
 	[FS_ENCRYPTION_MODE_AES_128_CBC] = {
 		.friendly_name = "AES-128-CBC",
 		.cipher_str = "cbc(aes)",
 		.keysize = 16,
+		.ivsize = 16,
+		.needs_essiv = true,
 	},
 	[FS_ENCRYPTION_MODE_AES_128_CTS] = {
 		.friendly_name = "AES-128-CTS-CBC",
 		.cipher_str = "cts(cbc(aes))",
 		.keysize = 16,
+		.ivsize = 16,
+	},
+	[FS_ENCRYPTION_MODE_ADIANTUM] = {
+		.friendly_name = "Adiantum",
+		.cipher_str = "adiantum(xchacha12,aes)",
+		.keysize = 32,
+		.ivsize = 32,
 	},
 };
 
@@ -198,14 +185,196 @@ select_encryption_mode(const struct fscrypt_info *ci, const struct inode *inode)
 	return ERR_PTR(-EINVAL);
 }
 
-static void put_crypt_info(struct fscrypt_info *ci)
+/* Find the master key, then derive the inode's actual encryption key */
+static int find_and_derive_key(const struct inode *inode,
+			       const struct fscrypt_context *ctx,
+			       u8 *derived_key, const struct fscrypt_mode *mode)
 {
-	if (!ci)
+	struct key *key;
+	const struct fscrypt_key *payload;
+	int err;
+
+	key = find_and_lock_process_key(FS_KEY_DESC_PREFIX,
+					ctx->master_key_descriptor,
+					mode->keysize, &payload);
+	if (key == ERR_PTR(-ENOKEY) && inode->i_sb->s_cop->key_prefix) {
+		key = find_and_lock_process_key(inode->i_sb->s_cop->key_prefix,
+						ctx->master_key_descriptor,
+						mode->keysize, &payload);
+	}
+	if (IS_ERR(key))
+		return PTR_ERR(key);
+
+	if (ctx->flags & FS_POLICY_FLAG_DIRECT_KEY) {
+		if (mode->ivsize < offsetofend(union fscrypt_iv, nonce)) {
+			fscrypt_warn(inode->i_sb,
+				     "direct key mode not allowed with %s",
+				     mode->friendly_name);
+			err = -EINVAL;
+		} else if (ctx->contents_encryption_mode !=
+			   ctx->filenames_encryption_mode) {
+			fscrypt_warn(inode->i_sb,
+				     "direct key mode not allowed with different contents and filenames modes");
+			err = -EINVAL;
+		} else {
+			memcpy(derived_key, payload->raw, mode->keysize);
+			err = 0;
+		}
+	} else {
+		err = derive_key_aes(payload->raw, ctx, derived_key,
+				     mode->keysize);
+	}
+	up_read(&key->sem);
+	key_put(key);
+	return err;
+}
+
+/* Allocate and key a symmetric cipher object for the given encryption mode */
+static struct crypto_skcipher *
+allocate_skcipher_for_mode(struct fscrypt_mode *mode, const u8 *raw_key,
+			   const struct inode *inode)
+{
+	struct crypto_skcipher *tfm;
+	int err;
+
+	tfm = crypto_alloc_skcipher(mode->cipher_str, 0, 0);
+	if (IS_ERR(tfm)) {
+		fscrypt_warn(inode->i_sb,
+			     "error allocating '%s' transform for inode %lu: %ld",
+			     mode->cipher_str, inode->i_ino, PTR_ERR(tfm));
+		return tfm;
+	}
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
+			crypto_skcipher_alg(tfm)->base.cra_driver_name);
+	}
+	crypto_skcipher_set_flags(tfm, CRYPTO_TFM_REQ_WEAK_KEY);
+	err = crypto_skcipher_setkey(tfm, raw_key, mode->keysize);
+	if (err)
+		goto err_free_tfm;
+
+	return tfm;
+
+err_free_tfm:
+	crypto_free_skcipher(tfm);
+	return ERR_PTR(err);
+}
+
+/* Master key referenced by FS_POLICY_FLAG_DIRECT_KEY policy */
+struct fscrypt_master_key {
+	struct hlist_node mk_node;
+	refcount_t mk_refcount;
+	const struct fscrypt_mode *mk_mode;
+	struct crypto_skcipher *mk_ctfm;
+	u8 mk_descriptor[FS_KEY_DESCRIPTOR_SIZE];
+	u8 mk_raw[FS_MAX_KEY_SIZE];
+};
+
+static void free_master_key(struct fscrypt_master_key *mk)
+{
+	if (mk) {
+		crypto_free_skcipher(mk->mk_ctfm);
+		kzfree(mk);
+	}
+}
+
+static void put_master_key(struct fscrypt_master_key *mk)
+{
+	if (!refcount_dec_and_lock(&mk->mk_refcount, &fscrypt_master_keys_lock))
 		return;
+	hash_del(&mk->mk_node);
+	spin_unlock(&fscrypt_master_keys_lock);
 
-	crypto_free_skcipher(ci->ci_ctfm);
-	crypto_free_cipher(ci->ci_essiv_tfm);
-	kmem_cache_free(fscrypt_info_cachep, ci);
+	free_master_key(mk);
+}
+
+/*
+ * Find/insert the given master key into the fscrypt_master_keys table.  If
+ * found, it is returned with elevated refcount, and 'to_insert' is freed if
+ * non-NULL.  If not found, 'to_insert' is inserted and returned if it's
+ * non-NULL; otherwise NULL is returned.
+ */
+static struct fscrypt_master_key *
+find_or_insert_master_key(struct fscrypt_master_key *to_insert,
+			  const u8 *raw_key, const struct fscrypt_mode *mode,
+			  const struct fscrypt_info *ci)
+{
+	unsigned long hash_key;
+	struct fscrypt_master_key *mk;
+
+	/*
+	 * Careful: to avoid potentially leaking secret key bytes via timing
+	 * information, we must key the hash table by descriptor rather than by
+	 * raw key, and use crypto_memneq() when comparing raw keys.
+	 */
+
+	BUILD_BUG_ON(sizeof(hash_key) > FS_KEY_DESCRIPTOR_SIZE);
+	memcpy(&hash_key, ci->ci_master_key_descriptor, sizeof(hash_key));
+
+	spin_lock(&fscrypt_master_keys_lock);
+	hash_for_each_possible(fscrypt_master_keys, mk, mk_node, hash_key) {
+		if (memcmp(ci->ci_master_key_descriptor, mk->mk_descriptor,
+			   FS_KEY_DESCRIPTOR_SIZE) != 0)
+			continue;
+		if (mode != mk->mk_mode)
+			continue;
+		if (crypto_memneq(raw_key, mk->mk_raw, mode->keysize))
+			continue;
+		/* using existing tfm with same (descriptor, mode, raw_key) */
+		refcount_inc(&mk->mk_refcount);
+		spin_unlock(&fscrypt_master_keys_lock);
+		free_master_key(to_insert);
+		return mk;
+	}
+	if (to_insert)
+		hash_add(fscrypt_master_keys, &to_insert->mk_node, hash_key);
+	spin_unlock(&fscrypt_master_keys_lock);
+	return to_insert;
+}
+
+/* Prepare to encrypt directly using the master key in the given mode */
+static struct fscrypt_master_key *
+fscrypt_get_master_key(const struct fscrypt_info *ci, struct fscrypt_mode *mode,
+		       const u8 *raw_key, const struct inode *inode)
+{
+	struct fscrypt_master_key *mk;
+	int err;
+
+	/* Is there already a tfm for this key? */
+	mk = find_or_insert_master_key(NULL, raw_key, mode, ci);
+	if (mk)
+		return mk;
+
+	/* Nope, allocate one. */
+	mk = kzalloc(sizeof(*mk), GFP_NOFS);
+	if (!mk)
+		return ERR_PTR(-ENOMEM);
+	refcount_set(&mk->mk_refcount, 1);
+	mk->mk_mode = mode;
+	mk->mk_ctfm = allocate_skcipher_for_mode(mode, raw_key, inode);
+	if (IS_ERR(mk->mk_ctfm)) {
+		err = PTR_ERR(mk->mk_ctfm);
+		mk->mk_ctfm = NULL;
+		goto err_free_mk;
+	}
+	memcpy(mk->mk_descriptor, ci->ci_master_key_descriptor,
+	       FS_KEY_DESCRIPTOR_SIZE);
+	memcpy(mk->mk_raw, raw_key, mode->keysize);
+
+	return find_or_insert_master_key(mk, raw_key, mode, ci);
+
+err_free_mk:
+	free_master_key(mk);
+	return ERR_PTR(err);
 }
 
 static int derive_essiv_salt(const u8 *key, int keysize, u8 *salt)
@@ -275,11 +444,67 @@ void __exit fscrypt_essiv_cleanup(void)
 	crypto_free_shash(essiv_hash_tfm);
 }
 
+/*
+ * Given the encryption mode and key (normally the derived key, but for
+ * FS_POLICY_FLAG_DIRECT_KEY mode it's the master key), set up the inode's
+ * symmetric cipher transform object(s).
+ */
+static int setup_crypto_transform(struct fscrypt_info *ci,
+				  struct fscrypt_mode *mode,
+				  const u8 *raw_key, const struct inode *inode)
+{
+	struct fscrypt_master_key *mk;
+	struct crypto_skcipher *ctfm;
+	int err;
+
+	if (ci->ci_flags & FS_POLICY_FLAG_DIRECT_KEY) {
+		mk = fscrypt_get_master_key(ci, mode, raw_key, inode);
+		if (IS_ERR(mk))
+			return PTR_ERR(mk);
+		ctfm = mk->mk_ctfm;
+	} else {
+		mk = NULL;
+		ctfm = allocate_skcipher_for_mode(mode, raw_key, inode);
+		if (IS_ERR(ctfm))
+			return PTR_ERR(ctfm);
+	}
+	ci->ci_master_key = mk;
+	ci->ci_ctfm = ctfm;
+
+	if (mode->needs_essiv) {
+		/* ESSIV implies 16-byte IVs which implies !DIRECT_KEY */
+		WARN_ON(mode->ivsize != AES_BLOCK_SIZE);
+		WARN_ON(ci->ci_flags & FS_POLICY_FLAG_DIRECT_KEY);
+
+		err = init_essiv_generator(ci, raw_key, mode->keysize);
+		if (err) {
+			fscrypt_warn(inode->i_sb,
+				     "error initializing ESSIV generator for inode %lu: %d",
+				     inode->i_ino, err);
+			return err;
+		}
+	}
+	return 0;
+}
+
+static void put_crypt_info(struct fscrypt_info *ci)
+{
+	if (!ci)
+		return;
+
+	if (ci->ci_master_key) {
+		put_master_key(ci->ci_master_key);
+	} else {
+		crypto_free_skcipher(ci->ci_ctfm);
+		crypto_free_cipher(ci->ci_essiv_tfm);
+	}
+	kmem_cache_free(fscrypt_info_cachep, ci);
+}
+
 int fscrypt_get_encryption_info(struct inode *inode)
 {
 	struct fscrypt_info *crypt_info;
 	struct fscrypt_context ctx;
-	struct crypto_skcipher *ctfm;
 	struct fscrypt_mode *mode;
 	u8 *raw_key = NULL;
 	int res;
@@ -312,74 +537,42 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (ctx.flags & ~FS_POLICY_FLAGS_VALID)
 		return -EINVAL;
 
-	crypt_info = kmem_cache_alloc(fscrypt_info_cachep, GFP_NOFS);
+	crypt_info = kmem_cache_zalloc(fscrypt_info_cachep, GFP_NOFS);
 	if (!crypt_info)
 		return -ENOMEM;
 
 	crypt_info->ci_flags = ctx.flags;
 	crypt_info->ci_data_mode = ctx.contents_encryption_mode;
 	crypt_info->ci_filename_mode = ctx.filenames_encryption_mode;
-	crypt_info->ci_ctfm = NULL;
-	crypt_info->ci_essiv_tfm = NULL;
-	memcpy(crypt_info->ci_master_key, ctx.master_key_descriptor,
-				sizeof(crypt_info->ci_master_key));
+	memcpy(crypt_info->ci_master_key_descriptor, ctx.master_key_descriptor,
+	       FS_KEY_DESCRIPTOR_SIZE);
+	memcpy(crypt_info->ci_nonce, ctx.nonce, FS_KEY_DERIVATION_NONCE_SIZE);
 
 	mode = select_encryption_mode(crypt_info, inode);
 	if (IS_ERR(mode)) {
 		res = PTR_ERR(mode);
 		goto out;
 	}
+	WARN_ON(mode->ivsize > FSCRYPT_MAX_IV_SIZE);
+	crypt_info->ci_mode = mode;
 
 	/*
-	 * This cannot be a stack buffer because it is passed to the scatterlist
-	 * crypto API as part of key derivation.
+	 * This cannot be a stack buffer because it may be passed to the
+	 * scatterlist crypto API as part of key derivation.
 	 */
 	res = -ENOMEM;
 	raw_key = kmalloc(mode->keysize, GFP_NOFS);
 	if (!raw_key)
 		goto out;
 
-	res = find_and_derive_key(inode, &ctx, raw_key, mode->keysize);
+	res = find_and_derive_key(inode, &ctx, raw_key, mode);
 	if (res)
 		goto out;
 
-	ctfm = crypto_alloc_skcipher(mode->cipher_str, 0, 0);
-	if (IS_ERR(ctfm)) {
-		res = PTR_ERR(ctfm);
-		fscrypt_warn(inode->i_sb,
-			     "error allocating '%s' transform for inode %lu: %d",
-			     mode->cipher_str, inode->i_ino, res);
-		goto out;
-	}
-	if (unlikely(!mode->logged_impl_name)) {
-		/*
-		 * fscrypt performance can vary greatly depending on which
-		 * crypto algorithm implementation is used.  Help people debug
-		 * performance problems by logging the ->cra_driver_name the
-		 * first time a mode is used.  Note that multiple threads can
-		 * race here, but it doesn't really matter.
-		 */
-		mode->logged_impl_name = true;
-		pr_info("fscrypt: %s using implementation \"%s\"\n",
-			mode->friendly_name,
-			crypto_skcipher_alg(ctfm)->base.cra_driver_name);
-	}
-	crypt_info->ci_ctfm = ctfm;
-	crypto_skcipher_set_flags(ctfm, CRYPTO_TFM_REQ_WEAK_KEY);
-	res = crypto_skcipher_setkey(ctfm, raw_key, mode->keysize);
+	res = setup_crypto_transform(crypt_info, mode, raw_key, inode);
 	if (res)
 		goto out;
 
-	if (S_ISREG(inode->i_mode) &&
-	    crypt_info->ci_data_mode == FS_ENCRYPTION_MODE_AES_128_CBC) {
-		res = init_essiv_generator(crypt_info, raw_key, mode->keysize);
-		if (res) {
-			fscrypt_warn(inode->i_sb,
-				     "error initializing ESSIV generator for inode %lu: %d",
-				     inode->i_ino, res);
-			goto out;
-		}
-	}
 	if (cmpxchg(&inode->i_crypt_info, NULL, crypt_info) == NULL)
 		crypt_info = NULL;
 out:
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index c6d431a5cce9..f490de921ce8 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -199,7 +199,8 @@ int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
 	child_ci = child->i_crypt_info;
 
 	if (parent_ci && child_ci) {
-		return memcmp(parent_ci->ci_master_key, child_ci->ci_master_key,
+		return memcmp(parent_ci->ci_master_key_descriptor,
+			      child_ci->ci_master_key_descriptor,
 			      FS_KEY_DESCRIPTOR_SIZE) == 0 &&
 			(parent_ci->ci_data_mode == child_ci->ci_data_mode) &&
 			(parent_ci->ci_filename_mode ==
@@ -254,7 +255,7 @@ int fscrypt_inherit_context(struct inode *parent, struct inode *child,
 	ctx.contents_encryption_mode = ci->ci_data_mode;
 	ctx.filenames_encryption_mode = ci->ci_filename_mode;
 	ctx.flags = ci->ci_flags;
-	memcpy(ctx.master_key_descriptor, ci->ci_master_key,
+	memcpy(ctx.master_key_descriptor, ci->ci_master_key_descriptor,
 	       FS_KEY_DESCRIPTOR_SIZE);
 	get_random_bytes(ctx.nonce, FS_KEY_DERIVATION_NONCE_SIZE);
 	BUILD_BUG_ON(sizeof(ctx) != FSCRYPT_SET_CONTEXT_MAX_SIZE);
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index a441ea1bfe6d..086e7ee550df 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -269,7 +269,8 @@ struct fsxattr {
 #define FS_POLICY_FLAGS_PAD_16		0x02
 #define FS_POLICY_FLAGS_PAD_32		0x03
 #define FS_POLICY_FLAGS_PAD_MASK	0x03
-#define FS_POLICY_FLAGS_VALID		0x03
+#define FS_POLICY_FLAG_DIRECT_KEY	0x04	/* use master key directly */
+#define FS_POLICY_FLAGS_VALID		0x07
 
 /* Encryption algorithms */
 #define FS_ENCRYPTION_MODE_INVALID		0
@@ -281,6 +282,7 @@ struct fsxattr {
 #define FS_ENCRYPTION_MODE_AES_128_CTS		6
 #define FS_ENCRYPTION_MODE_SPECK128_256_XTS	7 /* Removed, do not use. */
 #define FS_ENCRYPTION_MODE_SPECK128_256_CTS	8 /* Removed, do not use. */
+#define FS_ENCRYPTION_MODE_ADIANTUM		9
 
 struct fscrypt_policy {
 	__u8 version;
-- 
2.20.0.rc0.387.gc7a69e6b6c-goog
