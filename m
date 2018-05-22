Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 12/12] ext4: Enable encryption for blocksize less than page size
Date: Tue, 22 May 2018 21:31:10 +0530
In-Reply-To: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
References: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
Message-Id: <20180522160110.1161-13-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Now that we have all the code to support encryption for block size less
than page size scenario, this commit removes the conditional check in
filesystem mount code.

The commit also changes the support statement in
Documentation/filesystems/fscrypt.rst to reflect the fact that
encryption of filesystems with blocksize less than page size now works.

Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>
---
 Documentation/filesystems/fscrypt.rst | 14 +++++++-------
 fs/ext4/super.c                       |  7 -------
 2 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index cfbc18f..6f0827c 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -202,13 +202,13 @@ modes are not currently supported because of the difficulty of dealing
 with ciphertext expansion.
 
 For file contents, each filesystem block is encrypted independently.
-Currently, only the case where the filesystem block size is equal to
-the system's page size (usually 4096 bytes) is supported.  With the
-XTS mode of operation (recommended), the logical block number within
-the file is used as the IV.  With the CBC mode of operation (not
-recommended), ESSIV is used; specifically, the IV for CBC is the
-logical block number encrypted with AES-256, where the AES-256 key is
-the SHA-256 hash of the inode's data encryption key.
+Starting from Linux kernel 4.18, encryption of filesystems with block
+size less than system's page size is supported.  With the XTS mode of
+operation (recommended), the logical block number within the file is
+used as the IV.  With the CBC mode of operation (not recommended),
+ESSIV is used; specifically, the IV for CBC is the logical block
+number encrypted with AES-256, where the AES-256 key is the SHA-256
+hash of the inode's data encryption key.
 
 For filenames, the full filename is encrypted at once.  Because of the
 requirements to retain support for efficient directory lookups and
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index c40dda6..ebfbeea 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -4161,13 +4161,6 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 		}
 	}
 
-	if ((DUMMY_ENCRYPTION_ENABLED(sbi) || ext4_has_feature_encrypt(sb)) &&
-	    (blocksize != PAGE_SIZE)) {
-		ext4_msg(sb, KERN_ERR,
-			 "Unsupported blocksize for fs encryption");
-		goto failed_mount_wq;
-	}
-
 	if (DUMMY_ENCRYPTION_ENABLED(sbi) && !sb_rdonly(sb) &&
 	    !ext4_has_feature_encrypt(sb)) {
 		ext4_set_feature_encrypt(sb);
-- 
2.9.5
