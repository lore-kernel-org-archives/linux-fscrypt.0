Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 22/24] fscrypt: define fscrypt_fname_alloc_buffer() to be for presented names
Date: Fri, 15 Dec 2017 09:42:23 -0800
Message-Id: <20171215174225.31583-23-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Previously fscrypt_fname_alloc_buffer() was used to allocate buffers for
both presented (decrypted or encoded) and encrypted filenames.  That was
confusing, because it had to allocate the worst-case size for either,
e.g. including NUL-padding even when it was meaningless.

But now that fscrypt_setup_filename() no longer calls it, it is only
used in the ->get_link() and ->readdir() paths, which specifically want
a buffer for presented filenames.  Therefore, switch the behavior over
to allocating the buffer for presented filenames only.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c               | 29 ++++++++++++++---------------
 include/linux/fscrypt_notsupp.h |  2 +-
 2 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 65424b89a1d1..44ddd094b7c5 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -204,37 +204,36 @@ u32 fscrypt_fname_encrypted_size(const struct inode *inode, u32 ilen)
 EXPORT_SYMBOL(fscrypt_fname_encrypted_size);
 
 /**
- * fscrypt_fname_crypto_alloc_obuff() -
+ * fscrypt_fname_alloc_buffer - allocate a buffer for presented filenames
  *
- * Allocates an output buffer that is sufficient for the crypto operation
- * specified by the context and the direction.
+ * Allocate a buffer that is large enough to hold any decrypted or encoded
+ * filename (null-terminated), for the given maximum encrypted filename length.
+ *
+ * Return: 0 on success, -errno on failure
  */
 int fscrypt_fname_alloc_buffer(const struct inode *inode,
-				u32 ilen, struct fscrypt_str *crypto_str)
+			       u32 max_encrypted_len,
+			       struct fscrypt_str *crypto_str)
 {
-	u32 olen = fscrypt_fname_encrypted_size(inode, ilen);
 	const u32 max_encoded_len =
 		max_t(u32, BASE64_CHARS(FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE),
 		      1 + BASE64_CHARS(sizeof(struct fscrypt_digested_name)));
+	u32 max_presented_len;
 
-	crypto_str->len = olen;
-	olen = max(olen, max_encoded_len);
+	max_presented_len = max(max_encoded_len, max_encrypted_len);
 
-	/*
-	 * Allocated buffer can hold one more character to null-terminate the
-	 * string
-	 */
-	crypto_str->name = kmalloc(olen + 1, GFP_NOFS);
-	if (!(crypto_str->name))
+	crypto_str->name = kmalloc(max_presented_len + 1, GFP_NOFS);
+	if (!crypto_str->name)
 		return -ENOMEM;
+	crypto_str->len = max_presented_len;
 	return 0;
 }
 EXPORT_SYMBOL(fscrypt_fname_alloc_buffer);
 
 /**
- * fscrypt_fname_crypto_free_buffer() -
+ * fscrypt_fname_free_buffer - free the buffer for presented filenames
  *
- * Frees the buffer allocated for crypto operation.
+ * Free the buffer allocated by fscrypt_fname_alloc_buffer().
  */
 void fscrypt_fname_free_buffer(struct fscrypt_str *crypto_str)
 {
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index 0962f504aa91..c9592e307df5 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -140,7 +140,7 @@ static inline u32 fscrypt_fname_encrypted_size(const struct inode *inode,
 }
 
 static inline int fscrypt_fname_alloc_buffer(const struct inode *inode,
-					     u32 ilen,
+					     u32 max_encrypted_len,
 					     struct fscrypt_str *crypto_str)
 {
 	return -EOPNOTSUPP;
-- 
2.15.1
