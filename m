Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.0 required=3.0 tests=BAYES_00,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 289DDC83014
	for <linux-fscrypt@archiver.kernel.org>; Thu,  3 Dec 2020 02:23:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D7A2922201
	for <linux-fscrypt@archiver.kernel.org>; Thu,  3 Dec 2020 02:23:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387893AbgLCCXb (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 2 Dec 2020 21:23:31 -0500
Received: from mail.kernel.org ([198.145.29.99]:48664 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729339AbgLCCX2 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 2 Dec 2020 21:23:28 -0500
From:   Eric Biggers <ebiggers@kernel.org>
Authentication-Results: mail.kernel.org; dkim=permerror (bad message/signature format)
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org,
        Chao Yu <yuchao0@huawei.com>
Subject: [PATCH v2 2/9] f2fs: remove f2fs_dir_open()
Date:   Wed,  2 Dec 2020 18:20:34 -0800
Message-Id: <20201203022041.230976-3-ebiggers@kernel.org>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201203022041.230976-1-ebiggers@kernel.org>
References: <20201203022041.230976-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Since encrypted directories can be opened and searched without their key
being available, and each readdir and ->lookup() tries to set up the
key, trying to set up the key in ->open() too isn't really useful.

Just remove it so that directories don't need an ->open() method
anymore, and so that we eliminate a use of fscrypt_get_encryption_info()
(which I'd like to stop exporting to filesystems).

Reviewed-by: Chao Yu <yuchao0@huawei.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/dir.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index 4b9ef8bbfa4a9..47bee953fc8d8 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -1081,19 +1081,11 @@ static int f2fs_readdir(struct file *file, struct dir_context *ctx)
 	return err < 0 ? err : 0;
 }
 
-static int f2fs_dir_open(struct inode *inode, struct file *filp)
-{
-	if (IS_ENCRYPTED(inode))
-		return fscrypt_get_encryption_info(inode) ? -EACCES : 0;
-	return 0;
-}
-
 const struct file_operations f2fs_dir_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= generic_read_dir,
 	.iterate_shared	= f2fs_readdir,
 	.fsync		= f2fs_sync_file,
-	.open		= f2fs_dir_open,
 	.unlocked_ioctl	= f2fs_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl   = f2fs_compat_ioctl,
-- 
2.29.2

