Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 06/24] fscrypt: move fscrypt_operations declaration to fscrypt_supp.h
Date: Fri, 15 Dec 2017 09:42:07 -0800
Message-Id: <20171215174225.31583-7-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Filesystems now only define their fscrypt_operations when they are
compiled with encryption support, so move the fscrypt_operations
declaration from fscrypt.h to fscrypt_supp.h.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 include/linux/fscrypt.h      | 18 ------------------
 include/linux/fscrypt_supp.h | 18 ++++++++++++++++++
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index b671a4eef47f..33b95a91f720 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -54,24 +54,6 @@ struct fscrypt_name {
 #define fname_name(p)		((p)->disk_name.name)
 #define fname_len(p)		((p)->disk_name.len)
 
-/*
- * fscrypt superblock flags
- */
-#define FS_CFLG_OWN_PAGES (1U << 1)
-
-/*
- * crypto opertions for filesystems
- */
-struct fscrypt_operations {
-	unsigned int flags;
-	const char *key_prefix;
-	int (*get_context)(struct inode *, void *, size_t);
-	int (*set_context)(struct inode *, const void *, size_t, void *);
-	bool (*dummy_context)(struct inode *);
-	bool (*empty_dir)(struct inode *);
-	unsigned (*max_namelen)(struct inode *);
-};
-
 /* Maximum value for the third parameter of fscrypt_operations.set_context(). */
 #define FSCRYPT_SET_CONTEXT_MAX_SIZE	28
 
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index e7dfa2974906..ce61caf26f40 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -11,6 +11,24 @@
 #ifndef _LINUX_FSCRYPT_SUPP_H
 #define _LINUX_FSCRYPT_SUPP_H
 
+/*
+ * fscrypt superblock flags
+ */
+#define FS_CFLG_OWN_PAGES (1U << 1)
+
+/*
+ * crypto operations for filesystems
+ */
+struct fscrypt_operations {
+	unsigned int flags;
+	const char *key_prefix;
+	int (*get_context)(struct inode *, void *, size_t);
+	int (*set_context)(struct inode *, const void *, size_t, void *);
+	bool (*dummy_context)(struct inode *);
+	bool (*empty_dir)(struct inode *);
+	unsigned (*max_namelen)(struct inode *);
+};
+
 struct fscrypt_ctx {
 	union {
 		struct {
-- 
2.15.1
