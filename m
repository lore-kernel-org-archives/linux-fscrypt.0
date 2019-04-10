Date: Tue, 9 Apr 2019 19:58:08 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] fscrypt: cache decrypted symlink target in ->i_link
Message-ID: <20190410025808.GA7140@sol.localdomain>
References: <20190409233544.156665-1-ebiggers@kernel.org>
 <20190410003346.GT2217@ZenIV.linux.org.uk>
 <20190410004553.GA2454@sol.localdomain>
 <20190410010425.GU2217@ZenIV.linux.org.uk>
 <20190410012247.GB2454@sol.localdomain>
 <20190410013934.GV2217@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190410013934.GV2217@ZenIV.linux.org.uk>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Apr 10, 2019 at 02:39:34AM +0100, Al Viro wrote:
> On Tue, Apr 09, 2019 at 06:22:49PM -0700, Eric Biggers wrote:
> 
> > > Non-NULL ->get_link() => DCACHE_SYMLINK_TYPE in ->d_flags =>
> > > d_is_symlink() true => step_into() progresses to pick_link().
> > > 
> > > IOW, non-NULL ->get_link() is what tells you that we have
> > > a symlink there.
> > 
> > I think that's pretty unintuitive.  The fact that multiple filesystems including
> > ext4 set ->i_link on fast symlinks, then set ->get_link() to a function that
> > returns ->i_link, made me assume that's the mechanism by which such symlink
> > targets are returned to the VFS.  When in fact fs/namei.c just uses ->i_link,
> > and never calls ->get_link().
> > 
> > Is there any reason why d_flags_for_inode() doesn't check S_ISLNK() instead, and
> > then fs/namei.c would call ->get_link() if non-NULL, otherwise use ->i_link?
> 
> Extra check and dereference on hot path with no visible benefits of doing it
> that way, for starters.  Really, what _is_ the benefit of pessimizing that?  
> Most of the symlinks we run into will have ->i_link set; checking ->i_op->get_link
> first is extra work for no good reason...
> 
> What's more, ->get_link is visible in inode_operations; ->i_link (let alone ->i_mode)
> isn't.  As it is, we can easily tell symlink inode_operations from everything else
> on the source level.  With your scheme we won't.

It could check a flag IOP_GET_LINK in ->i_opflags instead, so it would be the
same number of checks.  See patch below.

Benefits are that we get code that isn't actively misleading (via
simple_get_link() existing but actually never being called), and filesystems can
cache a symlink target in ->i_link if it becomes available later, i.e. if it's
not immediately available at iget() time.  Otherwise a filesystem-private field
has to be used instead.  (For fscrypt, I'd probably use fscrypt_info::ci_link.)

Anyway, if we're going to stick with the current approach we should at least add
a comment to simple_get_link() explaining what it's really for...

diff --git a/fs/dcache.c b/fs/dcache.c
index aac41adf47433..df0e2f092a481 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1820,12 +1820,11 @@ static unsigned d_flags_for_inode(struct inode *inode)
 		goto type_determined;
 	}
 
-	if (unlikely(!(inode->i_opflags & IOP_NOFOLLOW))) {
-		if (unlikely(inode->i_op->get_link)) {
-			add_flags = DCACHE_SYMLINK_TYPE;
-			goto type_determined;
-		}
-		inode->i_opflags |= IOP_NOFOLLOW;
+	if (unlikely(S_ISLNK(inode->i_mode))) {
+		add_flags = DCACHE_SYMLINK_TYPE;
+		if (inode->i_op->get_link)
+			inode->i_opflags |= IOP_GET_LINK;
+		goto type_determined;
 	}
 
 	if (unlikely(!S_ISREG(inode->i_mode)))
diff --git a/fs/ext4/symlink.c b/fs/ext4/symlink.c
index dd05af983092d..315e4622db3d2 100644
--- a/fs/ext4/symlink.c
+++ b/fs/ext4/symlink.c
@@ -67,7 +67,6 @@ const struct inode_operations ext4_symlink_inode_operations = {
 };
 
 const struct inode_operations ext4_fast_symlink_inode_operations = {
-	.get_link	= simple_get_link,
 	.setattr	= ext4_setattr,
 	.getattr	= ext4_getattr,
 	.listxattr	= ext4_listxattr,
diff --git a/fs/namei.c b/fs/namei.c
index dede0147b3f6e..d99275f0cd3d7 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1067,7 +1067,7 @@ const char *get_link(struct nameidata *nd)
 
 	nd->last_type = LAST_BIND;
 	res = inode->i_link;
-	if (!res) {
+	if (inode->i_opflags & IOP_GET_LINK) {
 		const char * (*get)(struct dentry *, struct inode *,
 				struct delayed_call *);
 		get = inode->i_op->get_link;
@@ -4730,7 +4730,7 @@ int vfs_readlink(struct dentry *dentry, char __user *buffer, int buflen)
 	}
 
 	link = inode->i_link;
-	if (!link) {
+	if (inode->i_opflags & IOP_GET_LINK) {
 		link = inode->i_op->get_link(dentry, inode, &done);
 		if (IS_ERR(link))
 			return PTR_ERR(link);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index dd28e76790891..f6353aa40355b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -604,7 +604,7 @@ is_uncached_acl(struct posix_acl *acl)
 
 #define IOP_FASTPERM	0x0001
 #define IOP_LOOKUP	0x0002
-#define IOP_NOFOLLOW	0x0004
+#define IOP_GET_LINK	0x0004
 #define IOP_XATTR	0x0008
 #define IOP_DEFAULT_READLINK	0x0010
 

- Eric
