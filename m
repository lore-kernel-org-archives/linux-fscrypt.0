Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Wed, 10 Apr 2019 13:21:14 -0700
Message-Id: <20190410202115.64501-2-ebiggers@kernel.org>
In-Reply-To: <20190410202115.64501-1-ebiggers@kernel.org>
References: <20190410202115.64501-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH v2 1/2] vfs: use READ_ONCE() to access ->i_link
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Al Viro <viro@zeniv.linux.org.uk>, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Use 'READ_ONCE(inode->i_link)' to explicitly support filesystems caching
the symlink target in ->i_link later if it was unavailable at iget()
time, or wasn't easily available.  I'll be doing this in fscrypt, to
improve the performance of encrypted symlinks on ext4, f2fs, and ubifs.

->i_link will start NULL and may later be set to a non-NULL value by a
smp_store_release() or cmpxchg_release().  READ_ONCE() is needed on the
read side.  smp_load_acquire() is unnecessary because only a data
dependency barrier is required.  (Thanks to Al for pointing this out.)

Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/namei.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index dede0147b3f6e..2855de004c1a9 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1066,7 +1066,7 @@ const char *get_link(struct nameidata *nd)
 		return ERR_PTR(error);
 
 	nd->last_type = LAST_BIND;
-	res = inode->i_link;
+	res = READ_ONCE(inode->i_link);
 	if (!res) {
 		const char * (*get)(struct dentry *, struct inode *,
 				struct delayed_call *);
@@ -4729,7 +4729,7 @@ int vfs_readlink(struct dentry *dentry, char __user *buffer, int buflen)
 		spin_unlock(&inode->i_lock);
 	}
 
-	link = inode->i_link;
+	link = READ_ONCE(inode->i_link);
 	if (!link) {
 		link = inode->i_op->get_link(dentry, inode, &done);
 		if (IS_ERR(link))
-- 
2.21.0.392.gf8f6787159e-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
