Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fscrypt: trim down fscrypt_common.h
Date: Mon, 17 Jul 2017 11:30:54 -0700
Message-Id: <20170717183054.114503-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fscrypt_common.h is only meant to include declarations that are exposed
to filesystems both with and without encryption enabled.  Trim it down a
bit by removing stuff that is only needed inside fs/crypto/ itself,
instead moving it into fscrypt_private.h or specific .c files.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/bio.c                |  1 -
 fs/crypto/crypto.c             |  1 +
 fs/crypto/fname.c              | 12 ++++++++++++
 fs/crypto/fscrypt_private.h    | 22 +++++++++++++++++++++-
 fs/crypto/keyinfo.c            |  2 ++
 fs/crypto/policy.c             |  1 +
 include/linux/fscrypt_common.h | 38 --------------------------------------
 include/linux/fscrypt_supp.h   |  1 +
 8 files changed, 38 insertions(+), 40 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 6181e9526860..8c76e3ee3953 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -22,7 +22,6 @@
 #include <linux/pagemap.h>
 #include <linux/module.h>
 #include <linux/bio.h>
-#include <linux/namei.h>
 #include "fscrypt_private.h"
 
 /*
diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index c7835df7e7b8..0d676838ec95 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -27,6 +27,7 @@
 #include <linux/dcache.h>
 #include <linux/namei.h>
 #include <crypto/aes.h>
+#include <crypto/skcipher.h>
 #include "fscrypt_private.h"
 
 static unsigned int num_prealloc_crypto_pages = 32;
diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index ad9f814fdead..d81108ea6d53 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -12,8 +12,20 @@
 
 #include <linux/scatterlist.h>
 #include <linux/ratelimit.h>
+#include <crypto/skcipher.h>
 #include "fscrypt_private.h"
 
+static inline bool fscrypt_is_dot_dotdot(const struct qstr *str)
+{
+	if (str->len == 1 && str->name[0] == '.')
+		return true;
+
+	if (str->len == 2 && str->name[0] == '.' && str->name[1] == '.')
+		return true;
+
+	return false;
+}
+
 /**
  * fname_crypt_complete() - completion callback for filename crypto
  * @req: The asynchronous cipher request context
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index a1d5021c31ef..5be27f37d065 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -12,7 +12,6 @@
 #define _FSCRYPT_PRIVATE_H
 
 #include <linux/fscrypt_supp.h>
-#include <crypto/hash.h>
 
 /* Encryption parameters */
 #define FS_IV_SIZE			16
@@ -78,6 +77,27 @@ struct fscrypt_completion_result {
 	struct fscrypt_completion_result ecr = { \
 		COMPLETION_INITIALIZER_ONSTACK((ecr).completion), 0 }
 
+static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
+{
+	if (inode->i_sb->s_cop->dummy_context &&
+				inode->i_sb->s_cop->dummy_context(inode))
+		return true;
+	return false;
+}
+
+static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
+					   u32 filenames_mode)
+{
+	if (contents_mode == FS_ENCRYPTION_MODE_AES_128_CBC &&
+	    filenames_mode == FS_ENCRYPTION_MODE_AES_128_CTS)
+		return true;
+
+	if (contents_mode == FS_ENCRYPTION_MODE_AES_256_XTS &&
+	    filenames_mode == FS_ENCRYPTION_MODE_AES_256_CTS)
+		return true;
+
+	return false;
+}
 
 /* crypto.c */
 extern int fscrypt_initialize(unsigned int cop_flags);
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 018c588c7ac3..f4e02f0d0762 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -12,7 +12,9 @@
 #include <linux/scatterlist.h>
 #include <linux/ratelimit.h>
 #include <crypto/aes.h>
+#include <crypto/hash.h>
 #include <crypto/sha.h>
+#include <crypto/skcipher.h>
 #include "fscrypt_private.h"
 
 static struct crypto_shash *essiv_hash_tfm;
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index ce07a86200f3..7bb02eabbf7a 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -11,6 +11,7 @@
 #include <linux/random.h>
 #include <linux/string.h>
 #include <linux/mount.h>
+#include <linux/uaccess.h>
 #include "fscrypt_private.h"
 
 /*
diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt_common.h
index 97f738628b36..050bb2294fd1 100644
--- a/include/linux/fscrypt_common.h
+++ b/include/linux/fscrypt_common.h
@@ -10,13 +10,8 @@
 #ifndef _LINUX_FSCRYPT_COMMON_H
 #define _LINUX_FSCRYPT_COMMON_H
 
-#include <linux/key.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
-#include <linux/bio.h>
-#include <linux/dcache.h>
-#include <crypto/skcipher.h>
-#include <uapi/linux/fs.h>
 
 #define FS_CRYPTO_BLOCK_SIZE		16
 
@@ -86,39 +81,6 @@ struct fscrypt_operations {
 /* Maximum value for the third parameter of fscrypt_operations.set_context(). */
 #define FSCRYPT_SET_CONTEXT_MAX_SIZE	28
 
-static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
-{
-	if (inode->i_sb->s_cop->dummy_context &&
-				inode->i_sb->s_cop->dummy_context(inode))
-		return true;
-	return false;
-}
-
-static inline bool fscrypt_valid_enc_modes(u32 contents_mode,
-					u32 filenames_mode)
-{
-	if (contents_mode == FS_ENCRYPTION_MODE_AES_128_CBC &&
-	    filenames_mode == FS_ENCRYPTION_MODE_AES_128_CTS)
-		return true;
-
-	if (contents_mode == FS_ENCRYPTION_MODE_AES_256_XTS &&
-	    filenames_mode == FS_ENCRYPTION_MODE_AES_256_CTS)
-		return true;
-
-	return false;
-}
-
-static inline bool fscrypt_is_dot_dotdot(const struct qstr *str)
-{
-	if (str->len == 1 && str->name[0] == '.')
-		return true;
-
-	if (str->len == 2 && str->name[0] == '.' && str->name[1] == '.')
-		return true;
-
-	return false;
-}
-
 static inline struct page *fscrypt_control_page(struct page *page)
 {
 #if IS_ENABLED(CONFIG_FS_ENCRYPTION)
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 32e2fcf13b01..d411407945b1 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -8,6 +8,7 @@
 #define _LINUX_FSCRYPT_SUPP_H
 
 #include <linux/fscrypt_common.h>
+#include <linux/slab.h>
 
 /* crypto.c */
 extern struct kmem_cache *fscrypt_info_cachep;
-- 
2.13.2.932.g7449e964c-goog
