Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42694 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731103AbfJIXrZ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 9 Oct 2019 19:47:25 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] docs: ioctl-number: document fscrypt ioctl numbers
Date: Wed,  9 Oct 2019 16:45:55 -0700
Message-Id: <20191009234555.226282-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

The 'f' ioctls with numbers 19-26 decimal are currently used for fscrypt
(a.k.a. ext4/f2fs/ubifs encryption), and up to 39 decimal is reserved
for future fscrypt use, as per the comment in fs/ext4/ext4.h.  So the
reserved range is 13-27 hex.

Document this in ioctl-number.rst.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 Documentation/ioctl/ioctl-number.rst | 1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/ioctl/ioctl-number.rst b/Documentation/ioctl/ioctl-number.rst
index bef79cd4c6b4d..4ef86433bd677 100644
--- a/Documentation/ioctl/ioctl-number.rst
+++ b/Documentation/ioctl/ioctl-number.rst
@@ -233,6 +233,7 @@ Code  Seq#    Include File                                           Comments
 'f'   00-0F  fs/ext4/ext4.h                                          conflict!
 'f'   00-0F  linux/fs.h                                              conflict!
 'f'   00-0F  fs/ocfs2/ocfs2_fs.h                                     conflict!
+'f'   13-27  linux/fscrypt.h
 'f'   81-8F  linux/fsverity.h
 'g'   00-0F  linux/usb/gadgetfs.h
 'g'   20-2F  linux/usb/g_printer.h
-- 
2.23.0.581.g78d2f28ef7-goog
