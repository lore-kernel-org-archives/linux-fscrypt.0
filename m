Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57004 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726664AbfDKVdE (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 11 Apr 2019 17:33:04 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v2] fscrypt: use READ_ONCE() to access ->i_crypt_info
Date: Thu, 11 Apr 2019 14:32:15 -0700
Message-Id: <20190411213215.163929-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

->i_crypt_info starts out NULL and may later be locklessly set to a
non-NULL value by the cmpxchg() in fscrypt_get_encryption_info().

But ->i_crypt_info is used directly, which technically is incorrect.
It's a data race, and it doesn't include the data dependency barrier
needed to safely dereference the pointer on at least one architecture.

Fix this by using READ_ONCE() instead.  Note: we don't need to use
smp_load_acquire(), since dereferencing the pointer only requires a data
dependency barrier, which is already included in READ_ONCE().  We also
don't need READ_ONCE() in places where ->i_crypt_info is unconditionally
dereferenced, since it must have already been checked.

Also downgrade the cmpxchg() to cmpxchg_release(), since RELEASE
semantics are sufficient on the write side.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---

This supersedes my earlier patch:

	"fscrypt: use proper memory barriers for ->i_crypt_info"
	https://patchwork.kernel.org/patch/10858269/

 fs/crypto/crypto.c      | 2 +-
 fs/crypto/fname.c       | 4 ++--
 fs/crypto/keyinfo.c     | 4 ++--
 fs/crypto/policy.c      | 6 +++---
 include/linux/fscrypt.h | 3 ++-
 5 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 5efc494a4e38f..0988077882574 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -328,7 +328,7 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 	spin_lock(&dentry->d_lock);
 	cached_with_key = dentry->d_flags & DCACHE_ENCRYPTED_WITH_KEY;
 	spin_unlock(&dentry->d_lock);
-	dir_has_key = (d_inode(dir)->i_crypt_info != NULL);
+	dir_has_key = fscrypt_has_encryption_key(d_inode(dir));
 	dput(dir);
 
 	/*
diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 7ff40a73dbece..050384c79f40e 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -269,7 +269,7 @@ int fscrypt_fname_disk_to_usr(struct inode *inode,
 	if (iname->len < FS_CRYPTO_BLOCK_SIZE)
 		return -EUCLEAN;
 
-	if (inode->i_crypt_info)
+	if (fscrypt_has_encryption_key(inode))
 		return fname_decrypt(inode, iname, oname);
 
 	if (iname->len <= FSCRYPT_FNAME_MAX_UNDIGESTED_SIZE) {
@@ -336,7 +336,7 @@ int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
 	if (ret)
 		return ret;
 
-	if (dir->i_crypt_info) {
+	if (fscrypt_has_encryption_key(dir)) {
 		if (!fscrypt_fname_encrypted_size(dir, iname->len,
 						  dir->i_sb->s_cop->max_namelen,
 						  &fname->crypto_buf.len))
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 34c4682f23bee..82989098b2fc9 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -509,7 +509,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	u8 *raw_key = NULL;
 	int res;
 
-	if (inode->i_crypt_info)
+	if (fscrypt_has_encryption_key(inode))
 		return 0;
 
 	res = fscrypt_initialize(inode->i_sb->s_cop->flags);
@@ -573,7 +573,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (res)
 		goto out;
 
-	if (cmpxchg(&inode->i_crypt_info, NULL, crypt_info) == NULL)
+	if (cmpxchg_release(&inode->i_crypt_info, NULL, crypt_info) == NULL)
 		crypt_info = NULL;
 out:
 	if (res == -ENOKEY)
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index bd7eaf9b3f003..d536889ac31bf 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -194,8 +194,8 @@ int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
 	res = fscrypt_get_encryption_info(child);
 	if (res)
 		return 0;
-	parent_ci = parent->i_crypt_info;
-	child_ci = child->i_crypt_info;
+	parent_ci = READ_ONCE(parent->i_crypt_info);
+	child_ci = READ_ONCE(child->i_crypt_info);
 
 	if (parent_ci && child_ci) {
 		return memcmp(parent_ci->ci_master_key_descriptor,
@@ -246,7 +246,7 @@ int fscrypt_inherit_context(struct inode *parent, struct inode *child,
 	if (res < 0)
 		return res;
 
-	ci = parent->i_crypt_info;
+	ci = READ_ONCE(parent->i_crypt_info);
 	if (ci == NULL)
 		return -ENOKEY;
 
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 02c3e320f5b3f..48145beedaa7f 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -79,7 +79,8 @@ struct fscrypt_ctx {
 
 static inline bool fscrypt_has_encryption_key(const struct inode *inode)
 {
-	return (inode->i_crypt_info != NULL);
+	/* pairs with cmpxchg_release() in fscrypt_get_encryption_info() */
+	return READ_ONCE(inode->i_crypt_info) != NULL;
 }
 
 static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
-- 
2.21.0.392.gf8f6787159e-goog
