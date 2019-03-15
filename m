Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33964 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726653AbfCOUy6 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 15 Mar 2019 16:54:58 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] ubifs: remove unnecessary calls to set up directory key
Date: Fri, 15 Mar 2019 13:54:32 -0700
Message-Id: <20190315205432.195263-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-mtd@lists.infradead.org
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

In ubifs_unlink() and ubifs_rmdir(), remove the call to
fscrypt_get_encryption_info() that precedes fscrypt_setup_filename().
This call was unnecessary, because fscrypt_setup_filename() already
tries to set up the directory's encryption key.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ubifs/dir.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 5767b373a8ff..c3311ea68fe5 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -792,12 +792,6 @@ static int ubifs_unlink(struct inode *dir, struct dentry *dentry)
 		dentry, inode->i_ino,
 		inode->i_nlink, dir->i_ino);
 
-	if (ubifs_crypt_is_encrypted(dir)) {
-		err = fscrypt_get_encryption_info(dir);
-		if (err && err != -ENOKEY)
-			return err;
-	}
-
 	err = fscrypt_setup_filename(dir, &dentry->d_name, 1, &nm);
 	if (err)
 		return err;
@@ -902,12 +896,6 @@ static int ubifs_rmdir(struct inode *dir, struct dentry *dentry)
 	if (err)
 		return err;
 
-	if (ubifs_crypt_is_encrypted(dir)) {
-		err = fscrypt_get_encryption_info(dir);
-		if (err && err != -ENOKEY)
-			return err;
-	}
-
 	err = fscrypt_setup_filename(dir, &dentry->d_name, 1, &nm);
 	if (err)
 		return err;
-- 
2.21.0.360.g471c308f928-goog
