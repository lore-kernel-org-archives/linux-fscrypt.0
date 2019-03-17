Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:56074 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727276AbfCQUHO (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 17 Mar 2019 16:07:14 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 3/5] fs, fscrypt: clear DCACHE_ENCRYPTED_NAME when unaliasing directory
Date: Sun, 17 Mar 2019 13:04:42 -0700
Message-Id: <20190317200444.5967-4-ebiggers@kernel.org>
In-Reply-To: <20190317200444.5967-1-ebiggers@kernel.org>
References: <20190317200444.5967-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-unionfs@vger.kernel.org, Sarthak Kukreti <sarthakkukreti@chromium.org>, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Make __d_move() clear DCACHE_ENCRYPTED_NAME on the source dentry.  This
is needed for when d_splice_alias() moves a directory's encrypted alias
to its decrypted alias as a result of the encryption key being added.

Otherwise, the decrypted alias will incorrectly be invalidated on the
next lookup, causing problems such as unmounting a mount the user just
mount()ed there.

Note that we don't have to support arbitrary moves of this flag because
fscrypt doesn't allow dentries with DCACHE_ENCRYPTED_NAME to be the
source or target of a rename().

Fixes: 28b4c263961c ("ext4 crypto: revalidate dentry after adding or removing the key")
Reported-by: Sarthak Kukreti <sarthakkukreti@chromium.org>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/dcache.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index aac41adf4743..e27d11151d0e 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2718,6 +2718,20 @@ static void copy_name(struct dentry *dentry, struct dentry *target)
 		kfree_rcu(old_name, u.head);
 }
 
+static void fscrypt_update_flags(struct dentry *dentry)
+{
+#ifdef CONFIG_FS_ENCRYPTION
+	/*
+	 * When d_splice_alias() moves a directory's encrypted alias to its
+	 * decrypted alias as a result of the encryption key being added,
+	 * DCACHE_ENCRYPTED_NAME must be cleared.  Note that we don't have to
+	 * support arbitrary moves of this flag because fscrypt doesn't allow
+	 * encrypted aliases to be the source or target of a rename().
+	 */
+	dentry->d_flags &= ~DCACHE_ENCRYPTED_NAME;
+#endif
+}
+
 /*
  * __d_move - move a dentry
  * @dentry: entry to move
@@ -2795,6 +2809,7 @@ static void __d_move(struct dentry *dentry, struct dentry *target,
 	list_move(&dentry->d_child, &dentry->d_parent->d_subdirs);
 	__d_rehash(dentry);
 	fsnotify_update_flags(dentry);
+	fscrypt_update_flags(dentry);
 
 	write_seqcount_end(&target->d_seq);
 	write_seqcount_end(&dentry->d_seq);
-- 
2.21.0
