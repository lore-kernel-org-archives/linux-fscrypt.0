Return-Path: <ebiggers3@gmail.com>
Date: Mon, 27 Feb 2017 13:36:37 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] ext4: inherit encryption xattr before other xattrs
Message-ID: <20170227213637.GA123733@gmail.com>
References: <20170217233321.108637-1-ebiggers3@gmail.com>
 <2F4F7FA9-37C2-4FF1-9365-EF38D57FE7CA@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2F4F7FA9-37C2-4FF1-9365-EF38D57FE7CA@dilger.ca>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Feb 27, 2017 at 01:28:28PM -0700, Andreas Dilger wrote:
> On Feb 17, 2017, at 4:33 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> > 
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > When using both encryption and SELinux (or another feature that requires
> > an xattr per file) on a filesystem with 256-byte inodes, each file's
> > xattrs usually spill into an external xattr block.  Currently, the
> > xattrs are inherited in the order ACL, security, then encryption.
> > Therefore, if spillage occurs, the encryption xattr will always end up
> > in the external block.  This is not ideal because the encryption xattrs
> > contain a nonce, so they will always be unique and will prevent the
> > external xattr blocks from being deduplicated.
> > 
> > To improve the situation, change the inheritance order to encryption,
> > ACL, then security.  This gives the encryption xattr a better chance to
> > be stored in-inode, allowing the other xattr(s) to be deduplicated.
> > 
> > Note that it may be better for userspace to format the filesystem with
> > 512-byte inodes in this case.  However, it's not the default.
> > 
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> 
> Reviewed-by: Andreas Dilger <adilger@dilger.ca>
> 
> Note that we've been using 512-byte xattrs for Lustre metadata servers
> for ages.  We may want to consider enabling this by default when the
> filesystem features are set (e.g. crypto, inline data, etc).
> 
> Having a general mechanism to bias xattrs to in-inode or external xattr
> storage would be nice also, but I don't know any way to do this beyond
> just having a list of xattr names and then prioritizing the ones that
> go into the in-inode space.
> 

I think it's a good idea to have mke2fs default to 512-byte inodes if
'-O inline_data' is specified.  But with '-O encrypt' it may be more debatable
because there is no guarantee as to how many files userspace will actually
choose to encrypt.  It could be almost the whole filesystem, or just a few
files, or even nothing at all.

Regardless, I think adjusting the xattr inheritance order (as this patch does)
has advantages but no real disadvantages, so it might as well be done too.

Eric
