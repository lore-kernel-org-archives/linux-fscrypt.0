Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:58834 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750733AbdGHFJE (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 8 Jul 2017 01:09:04 -0400
Date: Sat, 8 Jul 2017 01:09:00 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 2/2] ext4: fix __ext4_new_inode() journal credits
 calculation
Message-ID: <20170708050900.afuwwia7c4izliir@thunk.org>
References: <20170706023819.32272-1-tahsin@google.com>
 <20170706023819.32272-2-tahsin@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170706023819.32272-2-tahsin@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Tahsin Erdogan <tahsin@google.com>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, Andreas Dilger <adilger@dilger.ca>, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jul 05, 2017 at 07:38:19PM -0700, Tahsin Erdogan wrote:
> ea_inode feature allows creating extended attributes that are up to
> 64k in size. Update __ext4_new_inode() to pick increased credit limits.
> 
> To avoid overallocating too many journal credits, update
> __ext4_xattr_set_credits() to make a distinction between xattr create
> vs update. This helps __ext4_new_inode() because all attributes are
> known to be new, so we can save credits that are normally needed to
> delete old values.
> 
> Also, have fscrypt specify its maximum context size so that we don't
> end up allocating credits for 64k size.
> 
> Signed-off-by: Tahsin Erdogan <tahsin@google.com>

I've applied the following change to this patch in order to better
calculate the credits needed by ext4_new_inode.  The problem is that
it was estimating a worse case of 287 blocks for ext4_new_inode() on a
10MB file system using the default 1024 block size.  And on such a
file system, the typical size of the journal is 1024 blocks, and the
maximum number of credits that are allowed by a handle is 1024 / 4 =
256 blocks.  This cases a number of regression tests to blow up.

In reality the SElinux label and EVM/integrity xattrs are never going
to be 64k, so calculating the credits assuming that as the worst case
is not productive.  And normally the Posix ACL is never going to be a
worst case of 64k long, either...

					- Ted

diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index 21a2538afcc2..507bfb3344d4 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -784,12 +784,38 @@ struct inode *__ext4_new_inode(handle_t *handle, struct inode *dir,
 	}
 
 	if (!handle && sbi->s_journal && !(i_flags & EXT4_EA_INODE_FL)) {
-		/*
-		 * 2 ea entries for ext4_init_acl(), 2 for ext4_init_security().
-		 */
-		nblocks += 4 * __ext4_xattr_set_credits(sb, NULL /* inode */,
-					NULL /* block_bh */, XATTR_SIZE_MAX,
+#ifdef CONFIG_EXT4_FS_POSIX_ACL
+		struct posix_acl *p = get_acl(dir, ACL_TYPE_DEFAULT);
+
+		if (p) {
+			int acl_size = p->a_count * sizeof(ext4_acl_entry);
+
+			nblocks += (S_ISDIR(mode) ? 2 : 1) *
+				__ext4_xattr_set_credits(sb, NULL /* inode */,
+					NULL /* block_bh */, acl_size,
+					true /* is_create */);
+			posix_acl_release(p);
+		}
+#endif
+
+#ifdef CONFIG_SECURITY
+		{
+			int num_security_xattrs = 1;
+
+#ifdef CONFIG_INTEGRITY
+			num_security_xattrs++;
+#endif
+			/*
+			 * We assume that security xattrs are never
+			 * more than 1k.  In practice they are under
+			 * 128 bytes.
+			 */
+			nblocks += num_security_xattrs *
+				__ext4_xattr_set_credits(sb, NULL /* inode */,
+					NULL /* block_bh */, 1024,
 					true /* is_create */);
+		}
+#endif
 		if (encrypt)
 			nblocks += __ext4_xattr_set_credits(sb,
 					NULL /* inode */, NULL /* block_bh */,
