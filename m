Return-Path: <ebiggers3@gmail.com>
Date: Tue, 23 May 2017 09:13:54 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] ext4: remove redundant check for encrypted file on dio
 write path
Message-ID: <20170523161354.GB106748@gmail.com>
References: <20170523005316.18996-1-ebiggers3@gmail.com>
 <20170523082410.GD1230@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170523082410.GD1230@quack2.suse.cz>
To: Jan Kara <jack@suse.cz>
Cc: linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Jan,

On Tue, May 23, 2017 at 10:24:10AM +0200, Jan Kara wrote:
> On Mon 22-05-17 17:53:16, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Currently we don't allow direct I/O on encrypted regular files, so in
> > such cases we return 0 early in ext4_direct_IO().  There was also an
> > additional BUG_ON() check in ext4_direct_IO_write(), but it can never be
> > hit because of the earlier check for the exact same condition in
> > ext4_direct_IO().  There was also no matching check on the read path,
> > which made the write path specific check seem very ad-hoc.
> > 
> > Just remove the unnecessary BUG_ON().
> > 
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> 
> Yeah, the check is rather before the BUG_ON so I guess that there's no big
> point in the BUG_ON. When looking at this code I have one question though:
> 
> So when you mount the filesystem with 'dioread_nolock', do overwriting
> direct write to the file, and just after we do inode_unlock() in
> ext4_direct_IO_write() someone calls EXT4_IOC_SET_ENCRYPTION_POLICY ioctl
> on the file, the BUG_ON could actually trigger. So I think you need 
> to wait for outstanding direct IO for the file when setting encryption
> policy. Likely in ext4_set_context() or maybe in the generic fscrypt code
> (you need to wait after acquiring inode_lock), I'm not sure how other
> filesystems using fscrypt handle this and whether it would make more sense
> in the generic code or in ext4 specific one.
> 

That's not possible because the ioctl can only set an encryption policy on a
directory, and specifically an empty one.  Other files can only acquire an
encryption policy through inheritance.  There have been thoughts about
implementing "in-place" encryption but it's not something we currently support.

Eric
