Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:6211 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751356AbeCIHxc (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 9 Mar 2018 02:53:32 -0500
From: Sheng Yong <shengyong1@huawei.com>
Subject: [RFC PATCH v4 0/3] f2fs: introduce F2FS_FEATURE_LOST_FOUND feature
Date: Fri, 9 Mar 2018 15:53:09 +0800
Message-ID: <20180309075312.62357-1-shengyong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
To: jaegeuk@kernel.org, yuchao0@huawei.com, ebiggers@google.com, tytso@mit.edu
Cc: miaoxie@huawei.com, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

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

 fs/ext4/super.c |  5 +++--
 fs/f2fs/dir.c   |  4 +++-
 fs/f2fs/f2fs.h  | 13 +++++++++++++
 fs/f2fs/namei.c |  9 ++++++---
 fs/f2fs/super.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 fs/f2fs/sysfs.c |  7 +++++++
 6 files changed, 75 insertions(+), 6 deletions(-)

-- 
2.14.1

