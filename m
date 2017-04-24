Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 3/6] fscrypt: introduce helper function for filename matching
Date: Mon, 24 Apr 2017 10:00:10 -0700
Message-Id: <20170424170013.85175-4-ebiggers3@gmail.com>
In-Reply-To: <20170424170013.85175-1-ebiggers3@gmail.com>
References: <20170424170013.85175-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Introduce a helper function fscrypt_match_name() which tests whether a
fscrypt_name matches a directory entry.  Also clean up the magic numbers
and document things properly.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c               | 90 ++++++++++++++++++++++++++++++++---------
 fs/crypto/fscrypt_private.h     |  2 -
 include/linux/fscrypt_notsupp.h |  9 +++++
 include/linux/fscrypt_supp.h    | 78 +++++++++++++++++++++++++++++++++++
 4 files changed, 157 insertions(+), 22 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 932881f27f2f..b697c0cb8036 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -159,6 +159,8 @@ static int fname_decrypt(struct inode *inode,
 static const char *lookup_table =
 	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+,";
 
+#define BASE64_CHARS(nbytes)	DIV_ROUND_UP((nbytes) * 4, 3)
+
 /**
  * digest_encode() -
  *
@@ -230,11 +232,14 @@ EXPORT_SYMBOL(fscrypt_fname_encrypted_size);
 int fscrypt_fname_alloc_buffer(const struct inode *inode,
 				u32 ilen, struct fscrypt_str *crypto_str)
 {
-	unsigned int olen = fscrypt_fname_encrypted_size(inode, ilen);
+	u32 olen = fscrypt_fname_encrypted_size(inode, ilen);
+	const u32 max_encoded_len =
+		max_t(u32, BASE64_CHARS(FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE),
+		      1 + BASE64_CHARS(sizeof(struct fscrypt_digested_name)));
 
 	crypto_str->len = olen;
-	if (olen < FS_FNAME_CRYPTO_DIGEST_SIZE * 2)
-		olen = FS_FNAME_CRYPTO_DIGEST_SIZE * 2;
+	olen = max(olen, max_encoded_len);
+
 	/*
 	 * Allocated buffer can hold one more character to null-terminate the
 	 * string
@@ -266,6 +271,10 @@ EXPORT_SYMBOL(fscrypt_fname_free_buffer);
  *
  * The caller must have allocated sufficient memory for the @oname string.
  *
+ * If the key is available, we'll decrypt the disk name; otherwise, we'll encode
+ * it for presentation.  Short names are directly base64-encoded, while long
+ * names are encoded in fscrypt_digested_name format.
+ *
  * Return: 0 on success, -errno on failure
  */
 int fscrypt_fname_disk_to_usr(struct inode *inode,
@@ -274,7 +283,7 @@ int fscrypt_fname_disk_to_usr(struct inode *inode,
 			struct fscrypt_str *oname)
 {
 	const struct qstr qname = FSTR_TO_QSTR(iname);
-	char buf[24];
+	struct fscrypt_digested_name digested_name;
 
 	if (fscrypt_is_dot_dotdot(&qname)) {
 		oname->name[0] = '.';
@@ -289,20 +298,24 @@ int fscrypt_fname_disk_to_usr(struct inode *inode,
 	if (inode->i_crypt_info)
 		return fname_decrypt(inode, iname, oname);
 
-	if (iname->len <= FS_FNAME_CRYPTO_DIGEST_SIZE) {
+	if (iname->len <= FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE) {
 		oname->len = digest_encode(iname->name, iname->len,
 					   oname->name);
 		return 0;
 	}
 	if (hash) {
-		memcpy(buf, &hash, 4);
-		memcpy(buf + 4, &minor_hash, 4);
+		digested_name.hash = hash;
+		digested_name.minor_hash = minor_hash;
 	} else {
-		memset(buf, 0, 8);
+		digested_name.hash = 0;
+		digested_name.minor_hash = 0;
 	}
-	memcpy(buf + 8, iname->name + ((iname->len - 17) & ~15), 16);
+	memcpy(digested_name.digest,
+	       FSCRYPT_FNAME_DIGEST(iname->name, iname->len),
+	       FSCRYPT_FNAME_DIGEST_SIZE);
 	oname->name[0] = '_';
-	oname->len = 1 + digest_encode(buf, 24, oname->name + 1);
+	oname->len = 1 + digest_encode((const char *)&digested_name,
+				       sizeof(digested_name), oname->name + 1);
 	return 0;
 }
 EXPORT_SYMBOL(fscrypt_fname_disk_to_usr);
@@ -336,10 +349,35 @@ int fscrypt_fname_usr_to_disk(struct inode *inode,
 }
 EXPORT_SYMBOL(fscrypt_fname_usr_to_disk);
 
+/**
+ * fscrypt_setup_filename() - prepare to search a possibly encrypted directory
+ * @dir: the directory that will be searched
+ * @iname: the user-provided filename being searched for
+ * @lookup: 1 if we're allowed to proceed without the key because it's
+ *	->lookup() or we're finding the dir_entry for deletion; 0 if we cannot
+ *	proceed without the key because we're going to create the dir_entry.
+ * @fname: the filename information to be filled in
+ *
+ * Given a user-provided filename @iname, this function sets @fname->disk_name
+ * to the name that would be stored in the on-disk directory entry, if possible.
+ * If the directory is unencrypted this is simply @iname.  Else, if we have the
+ * directory's encryption key, then @iname is the plaintext, so we encrypt it to
+ * get the disk_name.
+ *
+ * Else, for keyless @lookup operations, @iname is the presented ciphertext, so
+ * we decode it to get either the ciphertext disk_name (for short names) or the
+ * fscrypt_digested_name (for long names).  Non-@lookup operations will be
+ * impossible in this case, so we fail them with ENOKEY.
+ *
+ * If successful, fscrypt_free_filename() must be called later to clean up.
+ *
+ * Return: 0 on success, -errno on failure
+ */
 int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
 			      int lookup, struct fscrypt_name *fname)
 {
-	int ret = 0, bigname = 0;
+	int ret;
+	int digested;
 
 	memset(fname, 0, sizeof(struct fscrypt_name));
 	fname->usr_fname = iname;
@@ -373,25 +411,37 @@ int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
 	 * We don't have the key and we are doing a lookup; decode the
 	 * user-supplied name
 	 */
-	if (iname->name[0] == '_')
-		bigname = 1;
-	if ((bigname && (iname->len != 33)) || (!bigname && (iname->len > 43)))
-		return -ENOENT;
+	if (iname->name[0] == '_') {
+		if (iname->len !=
+		    1 + BASE64_CHARS(sizeof(struct fscrypt_digested_name)))
+			return -ENOENT;
+		digested = 1;
+	} else {
+		if (iname->len >
+		    BASE64_CHARS(FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE))
+			return -ENOENT;
+		digested = 0;
+	}
 
-	fname->crypto_buf.name = kmalloc(32, GFP_KERNEL);
+	fname->crypto_buf.name =
+		kmalloc(max_t(size_t, FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE,
+			      sizeof(struct fscrypt_digested_name)),
+			GFP_KERNEL);
 	if (fname->crypto_buf.name == NULL)
 		return -ENOMEM;
 
-	ret = digest_decode(iname->name + bigname, iname->len - bigname,
+	ret = digest_decode(iname->name + digested, iname->len - digested,
 				fname->crypto_buf.name);
 	if (ret < 0) {
 		ret = -ENOENT;
 		goto errout;
 	}
 	fname->crypto_buf.len = ret;
-	if (bigname) {
-		memcpy(&fname->hash, fname->crypto_buf.name, 4);
-		memcpy(&fname->minor_hash, fname->crypto_buf.name + 4, 4);
+	if (digested) {
+		const struct fscrypt_digested_name *n =
+			(const void *)fname->crypto_buf.name;
+		fname->hash = n->hash;
+		fname->minor_hash = n->minor_hash;
 	} else {
 		fname->disk_name.name = fname->crypto_buf.name;
 		fname->disk_name.len = fname->crypto_buf.len;
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index fdbb8af32eaf..b1fa2a0b08e9 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -13,8 +13,6 @@
 
 #include <linux/fscrypt_supp.h>
 
-#define FS_FNAME_CRYPTO_DIGEST_SIZE	32
-
 /* Encryption parameters */
 #define FS_XTS_TWEAK_SIZE		16
 #define FS_AES_128_ECB_KEY_SIZE		16
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 3511ca798804..ec406aed2f2f 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -147,6 +147,15 @@ static inline int fscrypt_fname_usr_to_disk(struct inode *inode,
 	return -EOPNOTSUPP;
 }
 
+static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
+				      const u8 *de_name, u32 de_name_len)
+{
+	/* Encryption support disabled; use standard comparison */
+	if (de_name_len != fname->disk_name.len)
+		return false;
+	return !memcmp(de_name, fname->disk_name.name, fname->disk_name.len);
+}
+
 /* bio.c */
 static inline void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *ctx,
 					     struct bio *bio)
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index a140f47e9b27..e12c224a0d1e 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -57,6 +57,84 @@ extern int fscrypt_fname_disk_to_usr(struct inode *, u32, u32,
 extern int fscrypt_fname_usr_to_disk(struct inode *, const struct qstr *,
 			struct fscrypt_str *);
 
+#define FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE	32
+
+/* Extracts the second-to-last ciphertext block; see explanation below */
+#define FSCRYPT_FNAME_DIGEST(name, len)	\
+	((name) + round_down((len) - FS_CRYPTO_BLOCK_SIZE - 1, \
+			     FS_CRYPTO_BLOCK_SIZE))
+
+#define FSCRYPT_FNAME_DIGEST_SIZE	FS_CRYPTO_BLOCK_SIZE
+
+/**
+ * fscrypt_digested_name - alternate identifier for an on-disk filename
+ *
+ * When userspace lists an encrypted directory without access to the key,
+ * filenames whose ciphertext is longer than FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE
+ * bytes are shown in this abbreviated form (base64-encoded) rather than as the
+ * full ciphertext (base64-encoded).  This is necessary to allow supporting
+ * filenames up to NAME_MAX bytes, since base64 encoding expands the length.
+ *
+ * To make it possible for filesystems to still find the correct directory entry
+ * despite not knowing the full on-disk name, we encode any filesystem-specific
+ * 'hash' and/or 'minor_hash' which the filesystem may need for its lookups,
+ * followed by the second-to-last ciphertext block of the filename.  Due to the
+ * use of the CBC-CTS encryption mode, the second-to-last ciphertext block
+ * depends on the full plaintext.  (Note that ciphertext stealing causes the
+ * last two blocks to appear "flipped".)  This makes collisions very unlikely:
+ * just a 1 in 2^128 chance for two filenames to collide even if they share the
+ * same filesystem-specific hashes.
+ *
+ * This scheme isn't strictly immune to intentional collisions because it's
+ * basically like a CBC-MAC, which isn't secure on variable-length inputs.
+ * However, generating a CBC-MAC collision requires the ability to choose
+ * arbitrary ciphertext, which won't normally be possible with filename
+ * encryption since it would require write access to the raw disk.
+ *
+ * Taking a real cryptographic hash like SHA-256 over the full ciphertext would
+ * be better in theory but would be less efficient and more complicated to
+ * implement, especially since the filesystem would need to calculate it for
+ * each directory entry examined during a search.
+ */
+struct fscrypt_digested_name {
+	u32 hash;
+	u32 minor_hash;
+	u8 digest[FSCRYPT_FNAME_DIGEST_SIZE];
+};
+
+/**
+ * fscrypt_match_name() - test whether the given name matches a directory entry
+ * @fname: the name being searched for
+ * @de_name: the name from the directory entry
+ * @de_name_len: the length of @de_name in bytes
+ *
+ * Normally @fname->disk_name will be set, and in that case we simply compare
+ * that to the name stored in the directory entry.  The only exception is that
+ * if we don't have the key for an encrypted directory and a filename in it is
+ * very long, then we won't have the full disk_name and we'll instead need to
+ * match against the fscrypt_digested_name.
+ *
+ * Return: %true if the name matches, otherwise %false.
+ */
+static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
+				      const u8 *de_name, u32 de_name_len)
+{
+	if (unlikely(!fname->disk_name.name)) {
+		const struct fscrypt_digested_name *n =
+			(const void *)fname->crypto_buf.name;
+		if (WARN_ON_ONCE(fname->usr_fname->name[0] != '_'))
+			return false;
+		if (de_name_len <= FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE)
+			return false;
+		return !memcmp(FSCRYPT_FNAME_DIGEST(de_name, de_name_len),
+			       n->digest, FSCRYPT_FNAME_DIGEST_SIZE);
+	}
+
+	if (de_name_len != fname->disk_name.len)
+		return false;
+	return !memcmp(de_name, fname->disk_name.name, fname->disk_name.len);
+}
+
 /* bio.c */
 extern void fscrypt_decrypt_bio_pages(struct fscrypt_ctx *, struct bio *);
 extern void fscrypt_pullback_bio_page(struct page **, bool);
-- 
2.12.2.816.g2cccc81164-goog
