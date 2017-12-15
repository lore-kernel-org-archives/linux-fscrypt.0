Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 08/24] fscrypt: move fscrypt_is_dot_dotdot() to fs/crypto/fname.c
Date: Fri, 15 Dec 2017 09:42:09 -0800
Message-Id: <20171215174225.31583-9-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Only fs/crypto/fname.c cares about treating the "." and ".." filenames
specially with regards to encryption, so move fscrypt_is_dot_dotdot()
from fscrypt.h to there.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c       | 11 +++++++++++
 include/linux/fscrypt.h | 11 -----------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 305541bcd108..b8c5061553b1 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -15,6 +15,17 @@
 #include <linux/ratelimit.h>
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
  * fname_encrypt() - encrypt a filename
  *
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 2e4dce0365cf..3045fc49d3ca 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -57,17 +57,6 @@ struct fscrypt_name {
 /* Maximum value for the third parameter of fscrypt_operations.set_context(). */
 #define FSCRYPT_SET_CONTEXT_MAX_SIZE	28
 
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
 #if __FS_HAS_ENCRYPTION
 #include <linux/fscrypt_supp.h>
 #else
-- 
2.15.1
