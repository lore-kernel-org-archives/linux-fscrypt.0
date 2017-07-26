Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 4/7] fscrypt: validate modes and flags earlier when setting policy
Date: Wed, 26 Jul 2017 11:19:26 -0700
Message-Id: <20170726181929.99880-5-ebiggers3@gmail.com>
In-Reply-To: <20170726181929.99880-1-ebiggers3@gmail.com>
References: <20170726181929.99880-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

For FS_IOC_SET_ENCRYPTION_POLICY, currently the encryption modes and
flags are only validated when a new encryption policy is being set, not
when an existing policy is being compared to the one specified.
However, we're going to start needing to compute the key_hash in both
cases, and for this it's helpful to validate that the master key has the
minimum length required by the specified encryption modes.  Therefore,
move the modes and flags validation earlier in the ioctl, next to where
we validate the policy version.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/policy.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index fe525da9e79c..d1e58798da3c 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -60,13 +60,6 @@ static int create_encryption_context_from_policy(struct inode *inode,
 {
 	struct fscrypt_context ctx;
 
-	if (!fscrypt_valid_enc_modes(policy->contents_encryption_mode,
-				     policy->filenames_encryption_mode))
-		return -EINVAL;
-
-	if (policy->flags & ~FS_POLICY_FLAGS_VALID)
-		return -EINVAL;
-
 	ctx.version = context_version_for_policy(policy);
 	ctx.contents_encryption_mode = policy->contents_encryption_mode;
 	ctx.filenames_encryption_mode = policy->filenames_encryption_mode;
@@ -100,6 +93,13 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 	    policy.version != FS_POLICY_VERSION_HKDF)
 		return -EINVAL;
 
+	if (!fscrypt_valid_enc_modes(policy.contents_encryption_mode,
+				     policy.filenames_encryption_mode))
+		return -EINVAL;
+
+	if (policy.flags & ~FS_POLICY_FLAGS_VALID)
+		return -EINVAL;
+
 	ret = mnt_want_write_file(filp);
 	if (ret)
 		return ret;
-- 
2.14.0.rc0.400.g1c36432dff-goog
