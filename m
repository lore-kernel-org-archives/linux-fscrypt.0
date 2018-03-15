Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:6239 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751600AbeCOKwD (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 15 Mar 2018 06:52:03 -0400
From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH v5 0/3] f2fs: introduce F2FS_FEATURE_LOST_FOUND feature
Date: Thu, 15 Mar 2018 18:51:40 +0800
Message-ID: <20180315105143.133050-1-shengyong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
To: jaegeuk@kernel.org, yuchao0@huawei.com, ebiggers@google.com, tytso@mit.edu
Cc: miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

v5->v4:
  * add doc for new mount option test_dummy_encryption
  * move test_dummy_encryption flag to f2fs_mount_info
  * move DUMMY_ENCRYPTION_ENABLED check to parse_option
  * remove readonly check since we don't enable encrypt feature forcely
v4->v3:
  * split f2fs patch into 2: one for LOST_FOUND feature, another for
    test_dummy_encryption
  * do not set enc_name if dir is not encrypted
  * do not allow mounting with test_dummy_encryption if encrypt feature
    is not set
v3->v2:
  * fix test_dummy_encryption
v2->v1:
  * introduce new mount option test_dummy_encryption
  * add sysfs entry for LOST_FOUND feature
---8<---

This patchset introduces LOST_FOUND feature in f2fs. If the feature is
enabled, f2fs should avoid to encrypt root directory.

A new mount option "test_dummy_encryption" is introduced, this is used by
xfstests.

Thanks,
Sheng

Sheng Yong (3):
  f2fs: introduce F2FS_FEATURE_LOST_FOUND feature
  f2fs: introduce a new mount option test_dummy_encryption
  ext4: do not allow mount with test_dummy_encryption if encrypt not set

 Documentation/filesystems/f2fs.txt |  2 ++
 fs/ext4/super.c                    |  7 +++----
 fs/f2fs/dir.c                      |  4 +++-
 fs/f2fs/f2fs.h                     | 10 ++++++++++
 fs/f2fs/namei.c                    |  9 ++++++---
 fs/f2fs/super.c                    | 40 ++++++++++++++++++++++++++++++++++++++
 fs/f2fs/sysfs.c                    |  7 +++++++
 7 files changed, 71 insertions(+), 8 deletions(-)

-- 
2.16.2

