Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A77CEC6FA86
	for <linux-fscrypt@archiver.kernel.org>; Tue,  6 Sep 2022 00:36:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236123AbiIFAgL (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 5 Sep 2022 20:36:11 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40092 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236207AbiIFAgH (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 5 Sep 2022 20:36:07 -0400
Received: from box.fidei.email (box.fidei.email [IPv6:2605:2700:0:2:a800:ff:feba:dc44])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3E6EA6AA30;
        Mon,  5 Sep 2022 17:36:06 -0700 (PDT)
Received: from authenticated-user (box.fidei.email [71.19.144.250])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
        (No client certificate requested)
        by box.fidei.email (Postfix) with ESMTPSA id 8BC8381041;
        Mon,  5 Sep 2022 20:36:05 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=dorminy.me; s=mail;
        t=1662424565; bh=AgDYp0BiOtfI423w4RuFeYp4IwenEY64iE6iTJOoayc=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=ZJih04pUi6+UyQZ8VDKfOrftp/6XNoA1VuMA1kVLZvZRb6GSKxGdh3ytzPZGOtcc8
         iGBwxFz+9RgKrbMnl+Ug06k57ZsmqVZUqXxfptnAHUJg1ttSHOzlBQnWbP+HwKoCw8
         LvKz1XZ5oYT9XArOM4Q2H34jWseocSSDHj1tC2/ZO3yH6IWs7uA0eh0NsSrUPPBkAj
         EFYEFJ3NAnQlBp/I+Eu3GEpMCAeTJ8IRyS1zP1paHdIC3PKuOBZZw09KWaseURugo1
         5S2AziW3Tqny+QaOQrD0p/amh0VLKjhY+S/2+G7l97dvv8akkuOL6/Lonbxrsq2Brj
         zYmVoX5qHtmqA==
From:   Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
To:     "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Eric Biggers <ebiggers@kernel.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <josef@toxicpanda.com>,
        David Sterba <dsterba@suse.com>, linux-fscrypt@vger.kernel.org,
        linux-btrfs@vger.kernel.org, kernel-team@fb.com
Cc:     Omar Sandoval <osandov@osandov.com>,
        Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: [PATCH v2 14/20] btrfs: translate btrfs encryption flags and encrypted inode flag.
Date:   Mon,  5 Sep 2022 20:35:29 -0400
Message-Id: <d0cc8d176673ffd5d63587ff2340a969ea0c8d72.1662420176.git.sweettea-kernel@dorminy.me>
In-Reply-To: <cover.1662420176.git.sweettea-kernel@dorminy.me>
References: <cover.1662420176.git.sweettea-kernel@dorminy.me>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Omar Sandoval <osandov@osandov.com>

In btrfs, a file can be encrypted either if its directory is encrypted
or its root subvolume is encrypted, so translate both to the standard
flags.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
---
 fs/btrfs/ioctl.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 8f5b65c43c8d..708e514aca25 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -7,6 +7,7 @@
 #include <linux/bio.h>
 #include <linux/file.h>
 #include <linux/fs.h>
+#include <linux/fscrypt.h>
 #include <linux/fsnotify.h>
 #include <linux/pagemap.h>
 #include <linux/highmem.h>
@@ -147,6 +148,10 @@ static unsigned int btrfs_inode_flags_to_fsflags(struct btrfs_inode *binode)
 		iflags |= FS_NOCOW_FL;
 	if (ro_flags & BTRFS_INODE_RO_VERITY)
 		iflags |= FS_VERITY_FL;
+	if ((binode->flags & BTRFS_INODE_FSCRYPT_CONTEXT) ||
+	    (btrfs_root_flags(&binode->root->root_item) &
+	     BTRFS_ROOT_SUBVOL_FSCRYPT))
+		iflags |= FS_ENCRYPT_FL;
 
 	if (flags & BTRFS_INODE_NOCOMPRESS)
 		iflags |= FS_NOCOMP_FL;
@@ -176,10 +181,14 @@ void btrfs_sync_inode_flags_to_i_flags(struct inode *inode)
 		new_fl |= S_DIRSYNC;
 	if (binode->ro_flags & BTRFS_INODE_RO_VERITY)
 		new_fl |= S_VERITY;
+	if ((binode->flags & BTRFS_INODE_FSCRYPT_CONTEXT) ||
+	    (btrfs_root_flags(&binode->root->root_item) &
+	     BTRFS_ROOT_SUBVOL_FSCRYPT))
+		new_fl |= S_ENCRYPTED;
 
 	set_mask_bits(&inode->i_flags,
 		      S_SYNC | S_APPEND | S_IMMUTABLE | S_NOATIME | S_DIRSYNC |
-		      S_VERITY, new_fl);
+		      S_VERITY | S_ENCRYPTED, new_fl);
 }
 
 /*
@@ -192,7 +201,7 @@ static int check_fsflags(unsigned int old_flags, unsigned int flags)
 		      FS_NOATIME_FL | FS_NODUMP_FL | \
 		      FS_SYNC_FL | FS_DIRSYNC_FL | \
 		      FS_NOCOMP_FL | FS_COMPR_FL |
-		      FS_NOCOW_FL))
+		      FS_NOCOW_FL | FS_ENCRYPT_FL))
 		return -EOPNOTSUPP;
 
 	/* COMPR and NOCOMP on new/old are valid */
-- 
2.35.1

