Return-Path: <ebiggers3@gmail.com>
Date: Fri, 16 Jun 2017 10:54:57 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] ext4: forbid encrypting root directory
Message-ID: <20170616175457.GA20865@gmail.com>
References: <20170614231753.113206-1-ebiggers3@gmail.com>
 <350BEDC7-0307-4624-A1E7-301D29747159@dilger.ca>
 <20170615002453.GA30126@gmail.com>
 <F7BF6774-18AA-4A57-AF64-D7D125A7E73C@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F7BF6774-18AA-4A57-AF64-D7D125A7E73C@dilger.ca>
To: Andreas Dilger <adilger@dilger.ca>
Cc: linux-ext4 <linux-ext4@vger.kernel.org>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jun 14, 2017 at 08:02:05PM -0600, Andreas Dilger wrote:
> >> 
> >> What about a special case to handle an unencrypted lost+found inode?
> >> 
> >> There was also a patch series a while ago to explicitly add lost+found
> >> into the superblock so that it could be found even if the root directory
> >> was corrupted, and to allow flexibility in whether it is always shown in
> >> the root directory or not (e.g. allowing ".lost+found" or similar).
> > 
> > It could be done if the lost+found inode was not linked to from any directory
> > and instead had its inode number stored in the superblock so that e2fsck could
> > still find it.  However, if e2fsck put files in a lost+found directory that
> > doesn't exist in the filesystem directory structure, how would users retrieve
> > those files?  Would users be required to run a special e2fsprogs command to
> > list/read/delete the files in lost+found?
> 
> I was thinking that readdir on the root inode could insert the "lost+found"
> or ".lost+found" entry dynamically,

I think this is possible, but not trivial.  It's not just readdir; ->lookup()
would also have to special-case lookups of "lost+found", and we'd have to
override the fscrypt_permitted_context() check.  It would also have to be a
RO_COMPAT filesystem feature, lest an unaware ext4 driver or e2fsprogs create a
lost+found directory which would then be ambiguous with the "real" one.

> or (a bit less pleasant) is to add a
> special case that this entry is just never encrypted (could compare the
> inode number to the one stored in the superblock, instead of comparing names)?

I think that would be similarly difficult, as it would still require special
logic in readdir and ->lookup(), and would still require a RO_COMPAT filesystem
feature.

Either way, not all filesystems will have the implicit "lost+found" directory
feature, so we're still going to need to forbid encrypting the root directory on
some filesystems anyway.

Eric
