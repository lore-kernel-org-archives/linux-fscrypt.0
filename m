Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:44658 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726704AbfCRRYu (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 18 Mar 2019 13:24:50 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: use proper memory barriers for ->i_crypt_info
Date: Mon, 18 Mar 2019 10:24:19 -0700
Message-Id: <20190318172419.240265-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

->i_crypt_info starts out NULL and is locklessly set to a non-NULL value
by the cmpxchg() in fscrypt_get_encryption_info().  But various places
load it without a read memory barrier.  Thus, the struct fscrypt_info
can (in theory) be used before it's seen as fully initialized.

Fix this by loading ->i_crypt_info using smp_load_acquire() in the
appropriate places, i.e. everywhere we check whether it's non-NULL with
the intention of dereferencing it.

Also downgrade the cmpxchg() to cmpxchg_release(), since RELEASE
semantics are sufficient to pair with ACQUIRE.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fname.c       | 4 ++--
 fs/crypto/keyinfo.c     | 2 +-
 fs/crypto/policy.c      | 6 +++---
 include/linux/fscrypt.h | 3 ++-
 4 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 7ff40a73dbec..050384c79f40 100644
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
index 322ce9686bdb..ba74dafa18a3 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -573,7 +573,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 	if (res)
 		goto out;
 
-	if (cmpxchg(&inode->i_crypt_info, NULL, crypt_info) == NULL)
+	if (cmpxchg_release(&inode->i_crypt_info, NULL, crypt_info) == NULL)
 		crypt_info = NULL;
 out:
 	if (res == -ENOKEY)
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index bd7eaf9b3f00..57ba4f63819a 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -194,8 +194,8 @@ int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
 	res = fscrypt_get_encryption_info(child);
 	if (res)
 		return 0;
-	parent_ci = parent->i_crypt_info;
-	child_ci = child->i_crypt_info;
+	parent_ci = smp_load_acquire(&parent->i_crypt_info);
+	child_ci = smp_load_acquire(&child->i_crypt_info);
 
 	if (parent_ci && child_ci) {
 		return memcmp(parent_ci->ci_master_key_descriptor,
@@ -246,7 +246,7 @@ int fscrypt_inherit_context(struct inode *parent, struct inode *child,
 	if (res < 0)
 		return res;
 
-	ci = parent->i_crypt_info;
+	ci = smp_load_acquire(&parent->i_crypt_info);
 	if (ci == NULL)
 		return -ENOKEY;
 
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 6cf8a34523ff..13c907214a76 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -79,7 +79,8 @@ struct fscrypt_ctx {
 
 static inline bool fscrypt_has_encryption_key(const struct inode *inode)
 {
-	return (inode->i_crypt_info != NULL);
+	/* pairs with cmpxchg_release() in fscrypt_get_encryption_info() */
+	return smp_load_acquire(&inode->i_crypt_info) != NULL;
 }
 
 static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
-- 
2.21.0.225.g810b269d1ac-goog
