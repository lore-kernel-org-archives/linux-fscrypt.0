Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 17/25] f2fs: switch to fscrypt_prepare_link()
Date: Wed, 20 Sep 2017 15:45:57 -0700
Message-Id: <20170920224605.22030-18-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/namei.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index a4dab98c4b7b..cf4e4294e450 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -221,9 +221,9 @@ static int f2fs_link(struct dentry *old_dentry, struct inode *dir,
 	struct f2fs_sb_info *sbi = F2FS_I_SB(dir);
 	int err;
 
-	if (f2fs_encrypted_inode(dir) &&
-			!fscrypt_has_permitted_context(dir, inode))
-		return -EPERM;
+	err = fscrypt_prepare_link(old_dentry, dir, dentry);
+	if (err)
+		return err;
 
 	if (is_inode_flag_set(dir, FI_PROJ_INHERIT) &&
 			(!projid_eq(F2FS_I(dir)->i_projid,
-- 
2.14.1.821.g8fa685d3b7-goog
