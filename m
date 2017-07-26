Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 1/7] fscrypt: add v2 encryption context and policy
Date: Wed, 26 Jul 2017 11:19:23 -0700
Message-Id: <20170726181929.99880-2-ebiggers3@gmail.com>
In-Reply-To: <20170726181929.99880-1-ebiggers3@gmail.com>
References: <20170726181929.99880-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Currently, the fscrypt_context (i.e. the encryption xattr) does not
contain a cryptographically secure identifier for the master key's
payload.  Therefore it's not possible to verify that the correct key was
supplied, which is problematic in multi-user scenarios.  To make this
possible, define a new fscrypt_context version (v2) which includes a
key_hash field, and allow userspace to opt-in to it when setting an
encryption policy by setting fscrypt_policy.version to 2.  For now just
zero the new field; a later patch will start setting it for real.

Even though we aren't changing the layout of struct fscrypt_policy (i.e.
the struct used by the ioctls), the new context version still has to be
"opt-in" because old kernels will not recognize it, and the keyring key
will now need to be available when setting an encryption policy, which
is an API change.  We'll also be taking the opportunity to make another
API change (dropping support for the filesystem-specific key prefixes).

Previously, the version numbers were 0 in the fscrypt_policy and 1 in
the fscrypt_context.  Rather than incrementing them to 1 and 2, make
them both 2 to be consistent with each other.  It's not required that
these numbers match, but it should make things less confusing.

An alternative to adding a key_hash field would have been to reuse
master_key_descriptor.  However, master_key_descriptor is only 8 bytes,
which is too short to be a cryptographically secure hash.  Thus,
master_key_descriptor would have needed to be lengthened to 16+ bytes,
which would have required defining a fscrypt_policy_v2 structure and
adding a FS_IOC_GET_ENCRYPTION_POLICY_V2 ioctl.  It also would have
required userspace to start using a specific hash algorithm to create
the key descriptors, which would have made the API harder to use.
Perhaps it should have been done that way originally, but at this point
it seems better to keep the API simpler.

Acked-by: Michael Halcrow <mhalcrow@google.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fscrypt_private.h    | 84 ++++++++++++++++++++++++++++++++++--------
 fs/crypto/keyinfo.c            | 14 +++----
 fs/crypto/policy.c             | 73 ++++++++++++++++++++++++++----------
 include/linux/fscrypt_common.h |  2 +-
 include/uapi/linux/fs.h        |  6 +++
 5 files changed, 135 insertions(+), 44 deletions(-)

diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index a1d5021c31ef..8329fb905ac6 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -24,40 +24,92 @@
 #define FS_AES_256_CTS_KEY_SIZE		32
 #define FS_AES_256_XTS_KEY_SIZE		64
 
-#define FS_KEY_DERIVATION_NONCE_SIZE		16
+#define FS_KEY_DERIVATION_NONCE_SIZE	16
+#define FSCRYPT_KEY_HASH_SIZE		16
 
 /**
- * Encryption context for inode
+ * fscrypt_context - the encryption context for an inode
  *
- * Protector format:
- *  1 byte: Protector format (1 = this version)
- *  1 byte: File contents encryption mode
- *  1 byte: File names encryption mode
- *  1 byte: Flags
- *  8 bytes: Master Key descriptor
- *  16 bytes: Encryption Key derivation nonce
+ * Filesystems usually store this in an extended attribute.  It identifies the
+ * encryption algorithm and key with which the file is encrypted.
+ *
+ * Since this is stored on-disk, be careful not to reorder fields or add any
+ * implicit padding bytes!
  */
 struct fscrypt_context {
-	u8 format;
+	/* v1+ */
+
+	/* Version of this structure */
+	u8 version;
+
+	/* Encryption mode for the contents of regular files */
 	u8 contents_encryption_mode;
+
+	/* Encryption mode for filenames in directories and symlink targets */
 	u8 filenames_encryption_mode;
+
+	/* Options that affect how encryption is done (e.g. padding amount) */
 	u8 flags;
+
+	/* Descriptor for this file's master key in the keyring */
 	u8 master_key_descriptor[FS_KEY_DESCRIPTOR_SIZE];
+
+	/*
+	 * A unique value used in combination with the master key to derive the
+	 * file's actual encryption key
+	 */
 	u8 nonce[FS_KEY_DERIVATION_NONCE_SIZE];
-} __packed;
 
-#define FS_ENCRYPTION_CONTEXT_FORMAT_V1		1
+	/* v2+ */
+
+	/* Cryptographically secure hash of the master key */
+	u8 key_hash[FSCRYPT_KEY_HASH_SIZE];
+};
+
+#define FSCRYPT_CONTEXT_V1	1
+#define FSCRYPT_CONTEXT_V1_SIZE	offsetof(struct fscrypt_context, key_hash)
+
+#define FSCRYPT_CONTEXT_V2	2
+#define FSCRYPT_CONTEXT_V2_SIZE	sizeof(struct fscrypt_context)
+
+static inline int fscrypt_context_size(const struct fscrypt_context *ctx)
+{
+	switch (ctx->version) {
+	case FSCRYPT_CONTEXT_V1:
+		return FSCRYPT_CONTEXT_V1_SIZE;
+	case FSCRYPT_CONTEXT_V2:
+		return FSCRYPT_CONTEXT_V2_SIZE;
+	}
+	return 0;
+}
+
+static inline bool
+fscrypt_valid_context_format(const struct fscrypt_context *ctx, int size)
+{
+	return size >= 1 && size == fscrypt_context_size(ctx);
+}
 
 /*
- * A pointer to this structure is stored in the file system's in-core
- * representation of an inode.
+ * fscrypt_info - the "encryption key" for an inode
+ *
+ * When an encrypted file's key is made available, an instance of this struct is
+ * allocated and stored in ->i_crypt_info.  Once created, it remains until the
+ * inode is evicted.
  */
 struct fscrypt_info {
+
+	/* The actual crypto transforms needed for encryption and decryption */
+	struct crypto_skcipher *ci_ctfm;
+	struct crypto_cipher *ci_essiv_tfm;
+
+	/*
+	 * Cached fields from the fscrypt_context needed for encryption policy
+	 * inheritance and enforcement
+	 */
+	u8 ci_context_version;
 	u8 ci_data_mode;
 	u8 ci_filename_mode;
 	u8 ci_flags;
-	struct crypto_skcipher *ci_ctfm;
-	struct crypto_cipher *ci_essiv_tfm;
 	u8 ci_master_key[FS_KEY_DESCRIPTOR_SIZE];
 };
 
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 018c588c7ac3..7e664a11340a 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -272,29 +272,27 @@ int fscrypt_get_encryption_info(struct inode *inode)
 			return res;
 		/* Fake up a context for an unencrypted directory */
 		memset(&ctx, 0, sizeof(ctx));
-		ctx.format = FS_ENCRYPTION_CONTEXT_FORMAT_V1;
+		ctx.version = FSCRYPT_CONTEXT_V1;
 		ctx.contents_encryption_mode = FS_ENCRYPTION_MODE_AES_256_XTS;
 		ctx.filenames_encryption_mode = FS_ENCRYPTION_MODE_AES_256_CTS;
 		memset(ctx.master_key_descriptor, 0x42, FS_KEY_DESCRIPTOR_SIZE);
-	} else if (res != sizeof(ctx)) {
-		return -EINVAL;
+		res = FSCRYPT_CONTEXT_V1_SIZE;
 	}
 
-	if (ctx.format != FS_ENCRYPTION_CONTEXT_FORMAT_V1)
+	if (!fscrypt_valid_context_format(&ctx, res))
 		return -EINVAL;
 
 	if (ctx.flags & ~FS_POLICY_FLAGS_VALID)
 		return -EINVAL;
 
-	crypt_info = kmem_cache_alloc(fscrypt_info_cachep, GFP_NOFS);
+	crypt_info = kmem_cache_zalloc(fscrypt_info_cachep, GFP_NOFS);
 	if (!crypt_info)
 		return -ENOMEM;
 
-	crypt_info->ci_flags = ctx.flags;
+	crypt_info->ci_context_version = ctx.version;
 	crypt_info->ci_data_mode = ctx.contents_encryption_mode;
 	crypt_info->ci_filename_mode = ctx.filenames_encryption_mode;
-	crypt_info->ci_ctfm = NULL;
-	crypt_info->ci_essiv_tfm = NULL;
+	crypt_info->ci_flags = ctx.flags;
 	memcpy(crypt_info->ci_master_key, ctx.master_key_descriptor,
 				sizeof(crypt_info->ci_master_key));
 
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index ce07a86200f3..d6beb48f08fc 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -13,6 +13,30 @@
 #include <linux/mount.h>
 #include "fscrypt_private.h"
 
+/* Note: requires a valid context version! */
+static u8 policy_version_for_context(const struct fscrypt_context *ctx)
+{
+	switch (ctx->version) {
+	case FSCRYPT_CONTEXT_V1:
+		return FS_POLICY_VERSION_ORIGINAL;
+	case FSCRYPT_CONTEXT_V2:
+		return FS_POLICY_VERSION_HKDF;
+	}
+	BUG();
+}
+
+/* Note: requires a valid policy version! */
+static u8 context_version_for_policy(const struct fscrypt_policy *policy)
+{
+	switch (policy->version) {
+	case FS_POLICY_VERSION_ORIGINAL:
+		return FSCRYPT_CONTEXT_V1;
+	case FS_POLICY_VERSION_HKDF:
+		return FSCRYPT_CONTEXT_V2;
+	}
+	BUG();
+}
+
 /*
  * check whether an encryption policy is consistent with an encryption context
  */
@@ -20,8 +44,10 @@ static bool is_encryption_context_consistent_with_policy(
 				const struct fscrypt_context *ctx,
 				const struct fscrypt_policy *policy)
 {
-	return memcmp(ctx->master_key_descriptor, policy->master_key_descriptor,
-		      FS_KEY_DESCRIPTOR_SIZE) == 0 &&
+	return (ctx->version == context_version_for_policy(policy)) &&
+		(memcmp(ctx->master_key_descriptor,
+			policy->master_key_descriptor,
+			FS_KEY_DESCRIPTOR_SIZE) == 0) &&
 		(ctx->flags == policy->flags) &&
 		(ctx->contents_encryption_mode ==
 		 policy->contents_encryption_mode) &&
@@ -34,10 +60,6 @@ static int create_encryption_context_from_policy(struct inode *inode,
 {
 	struct fscrypt_context ctx;
 
-	ctx.format = FS_ENCRYPTION_CONTEXT_FORMAT_V1;
-	memcpy(ctx.master_key_descriptor, policy->master_key_descriptor,
-					FS_KEY_DESCRIPTOR_SIZE);
-
 	if (!fscrypt_valid_enc_modes(policy->contents_encryption_mode,
 				     policy->filenames_encryption_mode))
 		return -EINVAL;
@@ -45,13 +67,20 @@ static int create_encryption_context_from_policy(struct inode *inode,
 	if (policy->flags & ~FS_POLICY_FLAGS_VALID)
 		return -EINVAL;
 
+	ctx.version = context_version_for_policy(policy);
 	ctx.contents_encryption_mode = policy->contents_encryption_mode;
 	ctx.filenames_encryption_mode = policy->filenames_encryption_mode;
 	ctx.flags = policy->flags;
+	memcpy(ctx.master_key_descriptor, policy->master_key_descriptor,
+	       FS_KEY_DESCRIPTOR_SIZE);
 	BUILD_BUG_ON(sizeof(ctx.nonce) != FS_KEY_DERIVATION_NONCE_SIZE);
 	get_random_bytes(ctx.nonce, FS_KEY_DERIVATION_NONCE_SIZE);
+	if (ctx.version != FSCRYPT_CONTEXT_V1)
+		memset(ctx.key_hash, 0, FSCRYPT_KEY_HASH_SIZE);
 
-	return inode->i_sb->s_cop->set_context(inode, &ctx, sizeof(ctx), NULL);
+	return inode->i_sb->s_cop->set_context(inode, &ctx,
+					       fscrypt_context_size(&ctx),
+					       NULL);
 }
 
 int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
@@ -67,7 +96,8 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 	if (!inode_owner_or_capable(inode))
 		return -EACCES;
 
-	if (policy.version != 0)
+	if (policy.version != FS_POLICY_VERSION_ORIGINAL &&
+	    policy.version != FS_POLICY_VERSION_HKDF)
 		return -EINVAL;
 
 	ret = mnt_want_write_file(filp);
@@ -85,7 +115,7 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 		else
 			ret = create_encryption_context_from_policy(inode,
 								    &policy);
-	} else if (ret == sizeof(ctx) &&
+	} else if (ret >= 0 && fscrypt_valid_context_format(&ctx, ret) &&
 		   is_encryption_context_consistent_with_policy(&ctx,
 								&policy)) {
 		/* The file already uses the same encryption policy. */
@@ -113,14 +143,12 @@ int fscrypt_ioctl_get_policy(struct file *filp, void __user *arg)
 		return -ENODATA;
 
 	res = inode->i_sb->s_cop->get_context(inode, &ctx, sizeof(ctx));
-	if (res < 0 && res != -ERANGE)
-		return res;
-	if (res != sizeof(ctx))
-		return -EINVAL;
-	if (ctx.format != FS_ENCRYPTION_CONTEXT_FORMAT_V1)
+	if (res < 0)
+		return (res == -ERANGE) ? -EINVAL : res;
+	if (!fscrypt_valid_context_format(&ctx, res))
 		return -EINVAL;
 
-	policy.version = 0;
+	policy.version = policy_version_for_context(&ctx);
 	policy.contents_encryption_mode = ctx.contents_encryption_mode;
 	policy.filenames_encryption_mode = ctx.filenames_encryption_mode;
 	policy.flags = ctx.flags;
@@ -200,6 +228,8 @@ int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
 	if (parent_ci && child_ci) {
 		return memcmp(parent_ci->ci_master_key, child_ci->ci_master_key,
 			      FS_KEY_DESCRIPTOR_SIZE) == 0 &&
+			(parent_ci->ci_context_version ==
+			 child_ci->ci_context_version) &&
 			(parent_ci->ci_data_mode == child_ci->ci_data_mode) &&
 			(parent_ci->ci_filename_mode ==
 			 child_ci->ci_filename_mode) &&
@@ -207,16 +237,17 @@ int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
 	}
 
 	res = cops->get_context(parent, &parent_ctx, sizeof(parent_ctx));
-	if (res != sizeof(parent_ctx))
+	if (res < 0 || !fscrypt_valid_context_format(&parent_ctx, res))
 		return 0;
 
 	res = cops->get_context(child, &child_ctx, sizeof(child_ctx));
-	if (res != sizeof(child_ctx))
+	if (res < 0 || !fscrypt_valid_context_format(&child_ctx, res))
 		return 0;
 
 	return memcmp(parent_ctx.master_key_descriptor,
 		      child_ctx.master_key_descriptor,
 		      FS_KEY_DESCRIPTOR_SIZE) == 0 &&
+		(parent_ctx.version == child_ctx.version) &&
 		(parent_ctx.contents_encryption_mode ==
 		 child_ctx.contents_encryption_mode) &&
 		(parent_ctx.filenames_encryption_mode ==
@@ -249,16 +280,20 @@ int fscrypt_inherit_context(struct inode *parent, struct inode *child,
 	if (ci == NULL)
 		return -ENOKEY;
 
-	ctx.format = FS_ENCRYPTION_CONTEXT_FORMAT_V1;
+	ctx.version = ci->ci_context_version;
 	ctx.contents_encryption_mode = ci->ci_data_mode;
 	ctx.filenames_encryption_mode = ci->ci_filename_mode;
 	ctx.flags = ci->ci_flags;
 	memcpy(ctx.master_key_descriptor, ci->ci_master_key,
 	       FS_KEY_DESCRIPTOR_SIZE);
 	get_random_bytes(ctx.nonce, FS_KEY_DERIVATION_NONCE_SIZE);
+	if (ctx.version != FSCRYPT_CONTEXT_V1)
+		memset(ctx.key_hash, 0, FSCRYPT_KEY_HASH_SIZE);
+
 	BUILD_BUG_ON(sizeof(ctx) != FSCRYPT_SET_CONTEXT_MAX_SIZE);
 	res = parent->i_sb->s_cop->set_context(child, &ctx,
-						sizeof(ctx), fs_data);
+					       fscrypt_context_size(&ctx),
+					       fs_data);
 	if (res)
 		return res;
 	return preload ? fscrypt_get_encryption_info(child): 0;
diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt_common.h
index 97f738628b36..c08e8ae63a02 100644
--- a/include/linux/fscrypt_common.h
+++ b/include/linux/fscrypt_common.h
@@ -84,7 +84,7 @@ struct fscrypt_operations {
 };
 
 /* Maximum value for the third parameter of fscrypt_operations.set_context(). */
-#define FSCRYPT_SET_CONTEXT_MAX_SIZE	28
+#define FSCRYPT_SET_CONTEXT_MAX_SIZE	44
 
 static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
 {
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index b7495d05e8de..a5423ddd3b67 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -257,6 +257,12 @@ struct fsxattr {
  * File system encryption support
  */
 /* Policy provided via an ioctl on the topmost directory */
+
+/* original policy version, no key verification (potentially insecure) */
+#define FS_POLICY_VERSION_ORIGINAL	0
+/* new version w/ HKDF and key verification (recommended) */
+#define FS_POLICY_VERSION_HKDF		2
+
 #define FS_KEY_DESCRIPTOR_SIZE	8
 
 #define FS_POLICY_FLAGS_PAD_4		0x00
-- 
2.14.0.rc0.400.g1c36432dff-goog
