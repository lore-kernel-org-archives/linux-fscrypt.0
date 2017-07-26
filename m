Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 7/7] fscrypt: for v2 policies, support "fscrypt:" key prefix only
Date: Wed, 26 Jul 2017 11:19:29 -0700
Message-Id: <20170726181929.99880-8-ebiggers3@gmail.com>
In-Reply-To: <20170726181929.99880-1-ebiggers3@gmail.com>
References: <20170726181929.99880-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Since v2 encryption policies are opt-in, take the opportunity to also
drop support for the legacy filesystem-specific key description prefixes
"ext4:", "f2fs:", and "ubifs:", instead requiring the generic prefix
"fscrypt:".  The generic prefix is preferred since it works for all
filesystems.  Also there is a performance benefit from not having to
search the keyrings twice.

The old prefixes remain supported for v1 encryption policies.

Reviewed-by: Michael Halcrow <mhalcrow@google.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fscrypt_private.h |  3 +--
 fs/crypto/keyinfo.c         | 16 ++++------------
 fs/crypto/policy.c          |  2 +-
 3 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 4221c5b23882..c9de15d4b5b0 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -169,8 +169,7 @@ extern struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
 					      gfp_t gfp_flags);
 
 /* keyinfo.c */
-extern int fscrypt_compute_key_hash(const struct inode *inode,
-				    const struct fscrypt_policy *policy,
+extern int fscrypt_compute_key_hash(const struct fscrypt_policy *policy,
 				    u8 hash[FSCRYPT_KEY_HASH_SIZE]);
 extern void __exit fscrypt_essiv_cleanup(void);
 
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 2fca72826768..81b08d4a7efe 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -384,8 +384,7 @@ find_and_lock_keyring_key(const char *prefix,
 }
 
 static struct fscrypt_master_key *
-load_master_key_from_keyring(const struct inode *inode,
-			     const u8 descriptor[FS_KEY_DESCRIPTOR_SIZE],
+load_master_key_from_keyring(const u8 descriptor[FS_KEY_DESCRIPTOR_SIZE],
 			     unsigned int min_keysize)
 {
 	struct key *keyring_key;
@@ -394,11 +393,6 @@ load_master_key_from_keyring(const struct inode *inode,
 
 	keyring_key = find_and_lock_keyring_key(FS_KEY_DESC_PREFIX, descriptor,
 						min_keysize, &payload);
-	if (keyring_key == ERR_PTR(-ENOKEY) && inode->i_sb->s_cop->key_prefix) {
-		keyring_key = find_and_lock_keyring_key(
-					inode->i_sb->s_cop->key_prefix,
-					descriptor, min_keysize, &payload);
-	}
 	if (IS_ERR(keyring_key))
 		return ERR_CAST(keyring_key);
 
@@ -440,8 +434,7 @@ find_or_create_master_key(const struct inode *inode,
 	/*
 	 * The needed master key isn't in memory yet.  Load it from the keyring.
 	 */
-	master_key = load_master_key_from_keyring(inode,
-						  ctx->master_key_descriptor,
+	master_key = load_master_key_from_keyring(ctx->master_key_descriptor,
 						  min_keysize);
 	if (IS_ERR(master_key))
 		return master_key;
@@ -675,8 +668,7 @@ void __exit fscrypt_essiv_cleanup(void)
 	crypto_free_shash(essiv_hash_tfm);
 }
 
-int fscrypt_compute_key_hash(const struct inode *inode,
-			     const struct fscrypt_policy *policy,
+int fscrypt_compute_key_hash(const struct fscrypt_policy *policy,
 			     u8 hash[FSCRYPT_KEY_HASH_SIZE])
 {
 	struct fscrypt_master_key *k;
@@ -690,7 +682,7 @@ int fscrypt_compute_key_hash(const struct inode *inode,
 		max(available_modes[policy->contents_encryption_mode].keysize,
 		    available_modes[policy->filenames_encryption_mode].keysize);
 
-	k = load_master_key_from_keyring(inode, policy->master_key_descriptor,
+	k = load_master_key_from_keyring(policy->master_key_descriptor,
 					 min_keysize);
 	if (IS_ERR(k))
 		return PTR_ERR(k);
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index ece55350cee8..fa5599005a72 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -119,7 +119,7 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 		pr_warn_once("%s (pid %d) is setting less secure v0 encryption policy; recommend upgrading to v2.\n",
 			     current->comm, current->pid);
 	} else {
-		ret = fscrypt_compute_key_hash(inode, &policy, key_hash);
+		ret = fscrypt_compute_key_hash(&policy, key_hash);
 		if (ret)
 			return ret;
 	}
-- 
2.14.0.rc0.400.g1c36432dff-goog
