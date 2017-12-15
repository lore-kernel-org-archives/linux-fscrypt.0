Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 21/24] fscrypt: calculate NUL-padding length in one place only
Date: Fri, 15 Dec 2017 09:42:22 -0800
Message-Id: <20171215174225.31583-22-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Currently, when encrypting a filename (either a real filename or a
symlink target) we calculate the amount of NUL-padding twice: once
before encryption and once during encryption in fname_encrypt().  It is
needed before encryption to allocate the needed buffer size as well as
calculate the size the symlink target will take up on-disk before
creating the symlink inode.  Calculating the size during encryption as
well is redundant.

Remove this redundancy by always calculating the exact size beforehand,
and making fname_encrypt() just add as much NUL padding as is needed to
fill the output buffer.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c           | 53 ++++++++++++++++++++++-----------------------
 fs/crypto/fscrypt_private.h |  4 ++--
 fs/crypto/hooks.c           |  7 +-----
 3 files changed, 29 insertions(+), 35 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index cae7d1bcc8c5..65424b89a1d1 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -30,39 +30,29 @@ static inline bool fscrypt_is_dot_dotdot(const struct qstr *str)
 /**
  * fname_encrypt() - encrypt a filename
  *
- * The caller must have allocated sufficient memory for the @oname string.
+ * The output buffer must be at least as large as the input buffer.
+ * Any extra space is filled with NUL padding before encryption.
  *
  * Return: 0 on success, -errno on failure
  */
-int fname_encrypt(struct inode *inode,
-		  const struct qstr *iname, struct fscrypt_str *oname)
+int fname_encrypt(struct inode *inode, const struct qstr *iname,
+		  u8 *out, unsigned int olen)
 {
 	struct skcipher_request *req = NULL;
 	DECLARE_CRYPTO_WAIT(wait);
-	struct fscrypt_info *ci = inode->i_crypt_info;
-	struct crypto_skcipher *tfm = ci->ci_ctfm;
+	struct crypto_skcipher *tfm = inode->i_crypt_info->ci_ctfm;
 	int res = 0;
 	char iv[FS_CRYPTO_BLOCK_SIZE];
 	struct scatterlist sg;
-	int padding = 4 << (ci->ci_flags & FS_POLICY_FLAGS_PAD_MASK);
-	unsigned int lim;
-	unsigned int cryptlen;
-
-	lim = inode->i_sb->s_cop->max_namelen(inode);
-	if (iname->len <= 0 || iname->len > lim)
-		return -EIO;
 
 	/*
 	 * Copy the filename to the output buffer for encrypting in-place and
 	 * pad it with the needed number of NUL bytes.
 	 */
-	if (WARN_ON(oname->len < iname->len))
+	if (WARN_ON(olen < iname->len))
 		return -ENOBUFS;
-	cryptlen = max_t(unsigned int, iname->len, FS_CRYPTO_BLOCK_SIZE);
-	cryptlen = round_up(cryptlen, padding);
-	cryptlen = min3(cryptlen, lim, oname->len);
-	memcpy(oname->name, iname->name, iname->len);
-	memset(oname->name + iname->len, 0, cryptlen - iname->len);
+	memcpy(out, iname->name, iname->len);
+	memset(out + iname->len, 0, olen - iname->len);
 
 	/* Initialize the IV */
 	memset(iv, 0, FS_CRYPTO_BLOCK_SIZE);
@@ -77,8 +67,8 @@ int fname_encrypt(struct inode *inode,
 	skcipher_request_set_callback(req,
 			CRYPTO_TFM_REQ_MAY_BACKLOG | CRYPTO_TFM_REQ_MAY_SLEEP,
 			crypto_req_done, &wait);
-	sg_init_one(&sg, oname->name, cryptlen);
-	skcipher_request_set_crypt(req, &sg, &sg, cryptlen, iv);
+	sg_init_one(&sg, out, olen);
+	skcipher_request_set_crypt(req, &sg, &sg, olen, iv);
 
 	/* Do the encryption */
 	res = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
@@ -89,7 +79,6 @@ int fname_encrypt(struct inode *inode,
 		return res;
 	}
 
-	oname->len = cryptlen;
 	return 0;
 }
 
@@ -354,11 +343,21 @@ int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
 		return ret;
 
 	if (dir->i_crypt_info) {
-		ret = fscrypt_fname_alloc_buffer(dir, iname->len,
-							&fname->crypto_buf);
-		if (ret)
-			return ret;
-		ret = fname_encrypt(dir, iname, &fname->crypto_buf);
+		unsigned int max_len = dir->i_sb->s_cop->max_namelen(dir);
+
+		if (iname->len > max_len)
+			return -ENAMETOOLONG;
+
+		fname->crypto_buf.len =
+			min(fscrypt_fname_encrypted_size(dir, iname->len),
+			    max_len);
+		fname->crypto_buf.name = kmalloc(fname->crypto_buf.len,
+						 GFP_NOFS);
+		if (!fname->crypto_buf.name)
+			return -ENOMEM;
+
+		ret = fname_encrypt(dir, iname, fname->crypto_buf.name,
+				    fname->crypto_buf.len);
 		if (ret)
 			goto errout;
 		fname->disk_name.name = fname->crypto_buf.name;
@@ -410,7 +409,7 @@ int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
 	return 0;
 
 errout:
-	fscrypt_fname_free_buffer(&fname->crypto_buf);
+	kfree(fname->crypto_buf.name);
 	return ret;
 }
 EXPORT_SYMBOL(fscrypt_setup_filename);
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index cec9ce309f41..053917587200 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -108,8 +108,8 @@ extern struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
 					      gfp_t gfp_flags);
 
 /* fname.c */
-extern int fname_encrypt(struct inode *inode,
-			 const struct qstr *iname, struct fscrypt_str *oname);
+extern int fname_encrypt(struct inode *inode, const struct qstr *iname,
+			 u8 *out, unsigned int olen);
 
 /* keyinfo.c */
 extern void __exit fscrypt_essiv_cleanup(void);
diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index 0f103a5cb1aa..ff20cacdea94 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -157,7 +157,6 @@ int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
 	struct qstr iname = { .name = target, .len = len };
 	struct fscrypt_symlink_data *sd;
 	unsigned int ciphertext_len;
-	struct fscrypt_str oname;
 
 	err = fscrypt_require_key(inode);
 	if (err)
@@ -174,16 +173,12 @@ int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
 	ciphertext_len = disk_link->len - sizeof(*sd);
 	sd->len = cpu_to_le16(ciphertext_len);
 
-	oname.name = sd->encrypted_path;
-	oname.len = ciphertext_len;
-	err = fname_encrypt(inode, &iname, &oname);
+	err = fname_encrypt(inode, &iname, sd->encrypted_path, ciphertext_len);
 	if (err) {
 		if (!disk_link->name)
 			kfree(sd);
 		return err;
 	}
-	BUG_ON(oname.len != ciphertext_len);
-
 	/*
 	 * Null-terminating the ciphertext doesn't make sense, but we still
 	 * count the null terminator in the length, so we might as well
-- 
2.15.1
