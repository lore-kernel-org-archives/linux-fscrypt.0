Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:46238 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753249AbeC1SPP (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 28 Mar 2018 14:15:15 -0400
Received: by mail-pg0-f66.google.com with SMTP id t12so1278381pgp.13
        for <linux-fscrypt@vger.kernel.org>; Wed, 28 Mar 2018 11:15:15 -0700 (PDT)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH] f2fs: reserve bits for fs-verity
Date: Wed, 28 Mar 2018 11:15:09 -0700
Message-Id: <20180328181509.199870-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>
Cc: linux-fscrypt@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>, Michael Halcrow <mhalcrow@google.com>, Theodore Ts'o <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Reserve an F2FS feature flag and inode flag for fs-verity.  This is an
in-development feature that is planned be discussed at LSF/MM 2018 [1].
It will provide file-based integrity and authenticity for read-only
files.  Most code will be in a filesystem-independent module, with
smaller changes needed to individual filesystems that opt-in to
supporting the feature.  An early prototype supporting F2FS is available
[2].  Reserving the F2FS on-disk bits for fs-verity will prevent users
of the prototype from conflicting with other new F2FS features.

Note that we're reserving the inode flag in f2fs_inode.i_advise, which
isn't really appropriate since it's not a hint or advice.  But
->i_advise is already being used to hold the 'encrypt' flag; and F2FS's
->i_flags uses the generic FS_* values, so it seems ->i_flags can't be
used for an F2FS-specific flag without additional work to remove the
assumption that ->i_flags uses the generic flags namespace.

[1] https://marc.info/?l=linux-fsdevel&m=151690752225644
[2] https://git.kernel.org/pub/scm/linux/kernel/git/mhalcrow/linux.git/log/?h=fs-verity-dev

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/f2fs.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index ae69dc358401..96d7809c4541 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -146,6 +146,7 @@ struct f2fs_mount_info {
 #define F2FS_FEATURE_QUOTA_INO		0x0080
 #define F2FS_FEATURE_INODE_CRTIME	0x0100
 #define F2FS_FEATURE_LOST_FOUND		0x0200
+#define F2FS_FEATURE_VERITY		0x0400	/* reserved */
 
 #define F2FS_HAS_FEATURE(sb, mask)					\
 	((F2FS_SB(sb)->raw_super->feature & cpu_to_le32(mask)) != 0)
@@ -598,6 +599,7 @@ enum {
 #define FADVISE_ENC_NAME_BIT	0x08
 #define FADVISE_KEEP_SIZE_BIT	0x10
 #define FADVISE_HOT_BIT		0x20
+#define FADVISE_VERITY_BIT	0x40	/* reserved */
 
 #define file_is_cold(inode)	is_file(inode, FADVISE_COLD_BIT)
 #define file_wrong_pino(inode)	is_file(inode, FADVISE_LOST_PINO_BIT)
-- 
2.17.0.rc1.321.gba9d0f2565-goog

