Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 01/25] fs, fscrypt: add an S_ENCRYPTED inode flag
Date: Wed, 20 Sep 2017 15:45:41 -0700
Message-Id: <20170920224605.22030-2-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Introduce a flag S_ENCRYPTED which can be set in ->i_flags to indicate
that the inode is encrypted using the fscrypt (fs/crypto/) mechanism.

Checking this flag will give the same information that
inode->i_sb->s_cop->is_encrypted(inode) currently does, but will be more
efficient.  This will be useful for adding higher-level helper functions
for filesystems to use.  For example we'll be able to replace this:

	if (ext4_encrypted_inode(inode)) {
		ret = fscrypt_get_encryption_info(inode);
		if (ret)
			return ret;
		if (!fscrypt_has_encryption_key(inode))
			return -ENOKEY;
	}

with this:

	ret = fscrypt_require_key(inode);
	if (ret)
		return ret;

... since we'll be able to retain the fast path for unencrypted files as
a single flag check, using an inline function.  This wasn't possible
before because we'd have had to frequently call through the
->i_sb->s_cop->is_encrypted function pointer, even when the encryption
support was disabled or not being used.

Note: we don't define S_ENCRYPTED to 0 if CONFIG_FS_ENCRYPTION is
disabled because we want to continue to return an error if an encrypted
file is accessed without encryption support, rather than pretending that
it is unencrypted.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/inode.c    | 7 +++++--
 fs/ext4/super.c    | 8 ++++++--
 fs/f2fs/f2fs.h     | 1 +
 fs/f2fs/inode.c    | 5 ++++-
 fs/ubifs/ioctl.c   | 5 ++++-
 fs/ubifs/xattr.c   | 1 +
 include/linux/fs.h | 2 ++
 7 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 31db875bc7a1..d5a471939fbc 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4589,10 +4589,13 @@ void ext4_set_inode_flags(struct inode *inode)
 		new_fl |= S_DIRSYNC;
 	if (test_opt(inode->i_sb, DAX) && S_ISREG(inode->i_mode) &&
 	    !ext4_should_journal_data(inode) && !ext4_has_inline_data(inode) &&
-	    !ext4_encrypted_inode(inode))
+	    !(flags & EXT4_ENCRYPT_FL))
 		new_fl |= S_DAX;
+	if (flags & EXT4_ENCRYPT_FL)
+		new_fl |= S_ENCRYPTED;
 	inode_set_flags(inode, new_fl,
-			S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC|S_DAX);
+			S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC|S_DAX|
+			S_ENCRYPTED);
 }
 
 static blkcnt_t ext4_inode_blocks(struct ext4_inode *raw_inode,
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index b104096fce9e..dcfb19539871 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1181,7 +1181,8 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 			ext4_clear_inode_state(inode,
 					EXT4_STATE_MAY_INLINE_DATA);
 			/*
-			 * Update inode->i_flags - e.g. S_DAX may get disabled
+			 * Update inode->i_flags - S_ENCRYPTED will be enabled,
+			 * S_DAX may be disabled
 			 */
 			ext4_set_inode_flags(inode);
 		}
@@ -1206,7 +1207,10 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 				    ctx, len, 0);
 	if (!res) {
 		ext4_set_inode_flag(inode, EXT4_INODE_ENCRYPT);
-		/* Update inode->i_flags - e.g. S_DAX may get disabled */
+		/*
+		 * Update inode->i_flags - S_ENCRYPTED will be enabled,
+		 * S_DAX may be disabled
+		 */
 		ext4_set_inode_flags(inode);
 		res = ext4_mark_inode_dirty(handle, inode);
 		if (res)
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 9a7c90386947..beaefddf2ff8 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -2949,6 +2949,7 @@ static inline void f2fs_set_encrypted_inode(struct inode *inode)
 {
 #ifdef CONFIG_F2FS_FS_ENCRYPTION
 	file_set_encrypt(inode);
+	inode->i_flags |= S_ENCRYPTED;
 #endif
 }
 
diff --git a/fs/f2fs/inode.c b/fs/f2fs/inode.c
index 50c88e37ed66..53fb08810ee9 100644
--- a/fs/f2fs/inode.c
+++ b/fs/f2fs/inode.c
@@ -43,8 +43,11 @@ void f2fs_set_inode_flags(struct inode *inode)
 		new_fl |= S_NOATIME;
 	if (flags & FS_DIRSYNC_FL)
 		new_fl |= S_DIRSYNC;
+	if (f2fs_encrypted_inode(inode))
+		new_fl |= S_ENCRYPTED;
 	inode_set_flags(inode, new_fl,
-			S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC);
+			S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC|
+			S_ENCRYPTED);
 }
 
 static void __get_inode_rdev(struct inode *inode, struct f2fs_inode *ri)
diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
index fdc311246807..0164bcc827f8 100644
--- a/fs/ubifs/ioctl.c
+++ b/fs/ubifs/ioctl.c
@@ -38,7 +38,8 @@ void ubifs_set_inode_flags(struct inode *inode)
 {
 	unsigned int flags = ubifs_inode(inode)->flags;
 
-	inode->i_flags &= ~(S_SYNC | S_APPEND | S_IMMUTABLE | S_DIRSYNC);
+	inode->i_flags &= ~(S_SYNC | S_APPEND | S_IMMUTABLE | S_DIRSYNC |
+			    S_ENCRYPTED);
 	if (flags & UBIFS_SYNC_FL)
 		inode->i_flags |= S_SYNC;
 	if (flags & UBIFS_APPEND_FL)
@@ -47,6 +48,8 @@ void ubifs_set_inode_flags(struct inode *inode)
 		inode->i_flags |= S_IMMUTABLE;
 	if (flags & UBIFS_DIRSYNC_FL)
 		inode->i_flags |= S_DIRSYNC;
+	if (flags & UBIFS_CRYPT_FL)
+		inode->i_flags |= S_ENCRYPTED;
 }
 
 /*
diff --git a/fs/ubifs/xattr.c b/fs/ubifs/xattr.c
index c13eae819cbc..5ddc89d564fd 100644
--- a/fs/ubifs/xattr.c
+++ b/fs/ubifs/xattr.c
@@ -170,6 +170,7 @@ static int create_xattr(struct ubifs_info *c, struct inode *host,
 	err = ubifs_jnl_update(c, host, nm, inode, 0, 1);
 	if (err)
 		goto out_cancel;
+	ubifs_set_inode_flags(host);
 	mutex_unlock(&host_ui->ui_mutex);
 
 	ubifs_release_budget(c, &req);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 339e73742e73..055d2fbf8eca 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1853,6 +1853,7 @@ struct super_operations {
 #else
 #define S_DAX		0	/* Make all the DAX code disappear */
 #endif
+#define S_ENCRYPTED	16384	/* Encrypted file (using fs/crypto/) */
 
 /*
  * Note that nosuid etc flags are inode-specific: setting some file-system
@@ -1892,6 +1893,7 @@ static inline bool sb_rdonly(const struct super_block *sb) { return sb->s_flags
 #define IS_AUTOMOUNT(inode)	((inode)->i_flags & S_AUTOMOUNT)
 #define IS_NOSEC(inode)		((inode)->i_flags & S_NOSEC)
 #define IS_DAX(inode)		((inode)->i_flags & S_DAX)
+#define IS_ENCRYPTED(inode)	((inode)->i_flags & S_ENCRYPTED)
 
 #define IS_WHITEOUT(inode)	(S_ISCHR(inode->i_mode) && \
 				 (inode)->i_rdev == WHITEOUT_DEV)
-- 
2.14.1.821.g8fa685d3b7-goog
