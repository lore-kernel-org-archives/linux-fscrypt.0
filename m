Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 19/24] fscrypt: remove fscrypt_fname_usr_to_disk()
Date: Fri, 15 Dec 2017 09:42:20 -0800
Message-Id: <20171215174225.31583-20-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fscrypt_fname_usr_to_disk() sounded very generic but was actually only
used to encrypt symlinks.  Remove it now that all filesystems have been
switched over to fscrypt_encrypt_symlink().

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c               | 29 -----------------------------
 include/linux/fscrypt_notsupp.h |  7 -------
 include/linux/fscrypt_supp.h    |  2 --
 3 files changed, 38 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 62f13d533439..cae7d1bcc8c5 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -311,35 +311,6 @@ int fscrypt_fname_disk_to_usr(struct inode *inode,
 }
 EXPORT_SYMBOL(fscrypt_fname_disk_to_usr);
 
-/**
- * fscrypt_fname_usr_to_disk() - converts a filename from user space to disk
- * space
- *
- * The caller must have allocated sufficient memory for the @oname string.
- *
- * Return: 0 on success, -errno on failure
- */
-int fscrypt_fname_usr_to_disk(struct inode *inode,
-			const struct qstr *iname,
-			struct fscrypt_str *oname)
-{
-	if (fscrypt_is_dot_dotdot(iname)) {
-		oname->name[0] = '.';
-		oname->name[iname->len - 1] = '.';
-		oname->len = iname->len;
-		return 0;
-	}
-	if (inode->i_crypt_info)
-		return fname_encrypt(inode, iname, oname);
-	/*
-	 * Without a proper key, a user is not allowed to modify the filenames
-	 * in a directory. Consequently, a user space name cannot be mapped to
-	 * a disk-space name
-	 */
-	return -ENOKEY;
-}
-EXPORT_SYMBOL(fscrypt_fname_usr_to_disk);
-
 /**
  * fscrypt_setup_filename() - prepare to search a possibly encrypted directory
  * @dir: the directory that will be searched
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index dd106640c6ea..0962f504aa91 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -159,13 +159,6 @@ static inline int fscrypt_fname_disk_to_usr(struct inode *inode,
 	return -EOPNOTSUPP;
 }
 
-static inline int fscrypt_fname_usr_to_disk(struct inode *inode,
-					    const struct qstr *iname,
-					    struct fscrypt_str *oname)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline bool fscrypt_match_name(const struct fscrypt_name *fname,
 				      const u8 *de_name, u32 de_name_len)
 {
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index dc2babf3f7d3..e00191deb0d6 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -113,8 +113,6 @@ extern int fscrypt_fname_alloc_buffer(const struct inode *, u32,
 extern void fscrypt_fname_free_buffer(struct fscrypt_str *);
 extern int fscrypt_fname_disk_to_usr(struct inode *, u32, u32,
 			const struct fscrypt_str *, struct fscrypt_str *);
-extern int fscrypt_fname_usr_to_disk(struct inode *, const struct qstr *,
-			struct fscrypt_str *);
 
 #define FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE	32
 
-- 
2.15.1
