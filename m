Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:47056 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726680AbfDJU0K (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 10 Apr 2019 16:26:10 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v2 2/2] fscrypt: cache decrypted symlink target in ->i_link
Date: Wed, 10 Apr 2019 13:21:15 -0700
Message-Id: <20190410202115.64501-3-ebiggers@kernel.org>
In-Reply-To: <20190410202115.64501-1-ebiggers@kernel.org>
References: <20190410202115.64501-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Al Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Path lookups that traverse encrypted symlink(s) are very slow because
each encrypted symlink needs to be decrypted each time it's followed.
This also involves dropping out of rcu-walk mode.

Make encrypted symlinks faster by caching the decrypted symlink target
in ->i_link.  The first call to fscrypt_get_symlink() sets it.  Then,
the existing VFS path lookup code uses the non-NULL ->i_link to take the
fast path where ->get_link() isn't called, and lookups in rcu-walk mode
remain in rcu-walk mode.

Also set ->i_link immediately when a new encrypted symlink is created.

To safely free the symlink target after an RCU grace period has elapsed,
introduce a new function fscrypt_free_inode(), and make the relevant
filesystems call it just before actually freeing the inode.

Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/hooks.c       | 40 +++++++++++++++++++++++++++++++++-------
 fs/crypto/keyinfo.c     | 21 +++++++++++++++++++++
 fs/ext4/super.c         |  3 +++
 fs/f2fs/super.c         |  3 +++
 fs/ubifs/super.c        |  3 +++
 include/linux/fscrypt.h |  5 +++++
 6 files changed, 68 insertions(+), 7 deletions(-)

diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index 56debb1fcf5eb..0bbe88a4d4b3f 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -179,11 +179,9 @@ int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
 	sd->len = cpu_to_le16(ciphertext_len);
 
 	err = fname_encrypt(inode, &iname, sd->encrypted_path, ciphertext_len);
-	if (err) {
-		if (!disk_link->name)
-			kfree(sd);
-		return err;
-	}
+	if (err)
+		goto err_free_sd;
+
 	/*
 	 * Null-terminating the ciphertext doesn't make sense, but we still
 	 * count the null terminator in the length, so we might as well
@@ -191,9 +189,20 @@ int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
 	 */
 	sd->encrypted_path[ciphertext_len] = '\0';
 
+	/* Cache the plaintext symlink target for later use by get_link() */
+	err = -ENOMEM;
+	inode->i_link = kmemdup(target, len + 1, GFP_NOFS);
+	if (!inode->i_link)
+		goto err_free_sd;
+
 	if (!disk_link->name)
 		disk_link->name = (unsigned char *)sd;
 	return 0;
+
+err_free_sd:
+	if (!disk_link->name)
+		kfree(sd);
+	return err;
 }
 EXPORT_SYMBOL_GPL(__fscrypt_encrypt_symlink);
 
@@ -202,7 +211,7 @@ EXPORT_SYMBOL_GPL(__fscrypt_encrypt_symlink);
  * @inode: the symlink inode
  * @caddr: the on-disk contents of the symlink
  * @max_size: size of @caddr buffer
- * @done: if successful, will be set up to free the returned target
+ * @done: if successful, will be set up to free the returned target if needed
  *
  * If the symlink's encryption key is available, we decrypt its target.
  * Otherwise, we encode its target for presentation.
@@ -217,12 +226,18 @@ const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
 {
 	const struct fscrypt_symlink_data *sd;
 	struct fscrypt_str cstr, pstr;
+	bool has_key;
 	int err;
 
 	/* This is for encrypted symlinks only */
 	if (WARN_ON(!IS_ENCRYPTED(inode)))
 		return ERR_PTR(-EINVAL);
 
+	/* If the decrypted target is already cached, just return it. */
+	pstr.name = READ_ONCE(inode->i_link);
+	if (pstr.name)
+		return pstr.name;
+
 	/*
 	 * Try to set up the symlink's encryption key, but we can continue
 	 * regardless of whether the key is available or not.
@@ -230,6 +245,7 @@ const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
 	err = fscrypt_get_encryption_info(inode);
 	if (err)
 		return ERR_PTR(err);
+	has_key = fscrypt_has_encryption_key(inode);
 
 	/*
 	 * For historical reasons, encrypted symlink targets are prefixed with
@@ -261,7 +277,17 @@ const char *fscrypt_get_symlink(struct inode *inode, const void *caddr,
 		goto err_kfree;
 
 	pstr.name[pstr.len] = '\0';
-	set_delayed_call(done, kfree_link, pstr.name);
+
+	/*
+	 * Cache decrypted symlink targets in i_link for later use.  Don't cache
+	 * symlink targets encoded without the key, since those become outdated
+	 * once the key is added.  This pairs with the READ_ONCE() above and in
+	 * the VFS path lookup code.
+	 */
+	if (!has_key ||
+	    cmpxchg_release(&inode->i_link, NULL, pstr.name) != NULL)
+		set_delayed_call(done, kfree_link, pstr.name);
+
 	return pstr.name;
 
 err_kfree:
diff --git a/fs/crypto/keyinfo.c b/fs/crypto/keyinfo.c
index 322ce9686bdba..34c4682f23bee 100644
--- a/fs/crypto/keyinfo.c
+++ b/fs/crypto/keyinfo.c
@@ -584,9 +584,30 @@ int fscrypt_get_encryption_info(struct inode *inode)
 }
 EXPORT_SYMBOL(fscrypt_get_encryption_info);
 
+/**
+ * fscrypt_put_encryption_info - free most of an inode's fscrypt data
+ *
+ * Free the inode's fscrypt_info.  Filesystems must call this when the inode is
+ * being evicted.  An RCU grace period need not have elapsed yet.
+ */
 void fscrypt_put_encryption_info(struct inode *inode)
 {
 	put_crypt_info(inode->i_crypt_info);
 	inode->i_crypt_info = NULL;
 }
 EXPORT_SYMBOL(fscrypt_put_encryption_info);
+
+/**
+ * fscrypt_free_inode - free an inode's fscrypt data requiring RCU delay
+ *
+ * Free the inode's cached decrypted symlink target, if any.  Filesystems must
+ * call this after an RCU grace period, just before they free the inode.
+ */
+void fscrypt_free_inode(struct inode *inode)
+{
+	if (IS_ENCRYPTED(inode) && S_ISLNK(inode->i_mode)) {
+		kfree(inode->i_link);
+		inode->i_link = NULL;
+	}
+}
+EXPORT_SYMBOL(fscrypt_free_inode);
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 6ed4eb81e6743..5b92054bf8ea0 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1110,6 +1110,9 @@ static int ext4_drop_inode(struct inode *inode)
 static void ext4_i_callback(struct rcu_head *head)
 {
 	struct inode *inode = container_of(head, struct inode, i_rcu);
+
+	fscrypt_free_inode(inode);
+
 	kmem_cache_free(ext4_inode_cachep, EXT4_I(inode));
 }
 
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index f2aaa2cc6b3e0..11b3a039a1881 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1003,6 +1003,9 @@ static void f2fs_dirty_inode(struct inode *inode, int flags)
 static void f2fs_i_callback(struct rcu_head *head)
 {
 	struct inode *inode = container_of(head, struct inode, i_rcu);
+
+	fscrypt_free_inode(inode);
+
 	kmem_cache_free(f2fs_inode_cachep, F2FS_I(inode));
 }
 
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 12628184772c0..19fd210987457 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -276,7 +276,10 @@ static void ubifs_i_callback(struct rcu_head *head)
 {
 	struct inode *inode = container_of(head, struct inode, i_rcu);
 	struct ubifs_inode *ui = ubifs_inode(inode);
+
 	kfree(ui->data);
+	fscrypt_free_inode(inode);
+
 	kmem_cache_free(ubifs_inode_slab, ui);
 }
 
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index e5194fc3983e9..9215fca9fd835 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -114,6 +114,7 @@ extern int fscrypt_inherit_context(struct inode *, struct inode *,
 /* keyinfo.c */
 extern int fscrypt_get_encryption_info(struct inode *);
 extern void fscrypt_put_encryption_info(struct inode *);
+extern void fscrypt_free_inode(struct inode *);
 
 /* fname.c */
 extern int fscrypt_setup_filename(struct inode *, const struct qstr *,
@@ -322,6 +323,10 @@ static inline void fscrypt_put_encryption_info(struct inode *inode)
 	return;
 }
 
+static inline void fscrypt_free_inode(struct inode *inode)
+{
+}
+
  /* fname.c */
 static inline int fscrypt_setup_filename(struct inode *dir,
 					 const struct qstr *iname,
-- 
2.21.0.392.gf8f6787159e-goog
