Return-Path: <chao@kernel.org>
From: Chao Yu <chao@kernel.org>
Subject: [PATCH] ext4 crypto: fix to check feature status before get policy
Date: Sun,  4 Aug 2019 17:56:43 +0800
Message-Id: <20190804095643.7393-1-chao@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
To: tytso@mit.edu, adilger.kernel@dilger.ca
Cc: linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org, ebiggers@kernel.org, linux-fscrypt@vger.kernel.org, chao@kernel.org, Chao Yu <yuchao0@huawei.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Chao Yu <yuchao0@huawei.com>

When getting fscrypto policy via EXT4_IOC_GET_ENCRYPTION_POLICY, if
encryption feature is off, it's better to return EOPNOTSUPP instead
of ENODATA, so let's add ext4_has_feature_encrypt() to do the check
for that.

Signed-off-by: Chao Yu <yuchao0@huawei.com>
---
 fs/ext4/ioctl.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c
index 442f7ef873fc..bf87835c1237 100644
--- a/fs/ext4/ioctl.c
+++ b/fs/ext4/ioctl.c
@@ -1112,9 +1112,11 @@ long ext4_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 		return -EOPNOTSUPP;
 #endif
 	}
-	case EXT4_IOC_GET_ENCRYPTION_POLICY:
+	case EXT4_IOC_GET_ENCRYPTION_POLICY: {
+		if (!ext4_has_feature_encrypt(sb))
+			return -EOPNOTSUPP;
 		return fscrypt_ioctl_get_policy(filp, (void __user *)arg);
-
+	}
 	case EXT4_IOC_FSGETXATTR:
 	{
 		struct fsxattr fa;
-- 
2.22.0
