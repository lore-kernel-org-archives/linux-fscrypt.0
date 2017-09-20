Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 12/25] ext4: switch to fscrypt_prepare_link()
Date: Wed, 20 Sep 2017 15:45:52 -0700
Message-Id: <20170920224605.22030-13-ebiggers3@gmail.com>
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/namei.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index c1cf020d1889..b2058500f1dc 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -3221,9 +3221,10 @@ static int ext4_link(struct dentry *old_dentry,
 
 	if (inode->i_nlink >= EXT4_LINK_MAX)
 		return -EMLINK;
-	if (ext4_encrypted_inode(dir) &&
-			!fscrypt_has_permitted_context(dir, inode))
-		return -EPERM;
+
+	err = fscrypt_prepare_link(old_dentry, dir, dentry);
+	if (err)
+		return err;
 
        if ((ext4_test_inode_flag(dir, EXT4_INODE_PROJINHERIT)) &&
 	   (!projid_eq(EXT4_I(dir)->i_projid,
-- 
2.14.1.821.g8fa685d3b7-goog
