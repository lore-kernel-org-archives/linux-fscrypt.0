Return-Path: <tytso@thunk.org>
Date: Fri, 23 Jun 2017 00:27:20 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v2] ext4: forbid encrypting root directory
Message-ID: <20170623042720.r6bhmp7ru5vfcrfx@thunk.org>
References: <20170616183411.31587-1-ebiggers3@gmail.com>
 <CFA0E924-C86A-4B01-8104-4B89FDCDF10E@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CFA0E924-C86A-4B01-8104-4B89FDCDF10E@dilger.ca>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fscrypt@vger.kernel.org, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Jun 19, 2017 at 03:18:24PM -0600, Andreas Dilger wrote:
> On Jun 16, 2017, at 12:34 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> > 
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Currently it's possible to encrypt all files and directories on an ext4
> > filesystem by deleting everything, including lost+found, then setting an
> > encryption policy on the root directory.  However, this is incompatible
> > with e2fsck because e2fsck expects to find, create, and/or write to
> > lost+found and does not have access to any encryption keys.  Especially
> > problematic is that if e2fsck can't find lost+found, it will create it
> > without regard for whether the root directory is encrypted.  This is
> > wrong for obvious reasons, and it causes a later run of e2fsck to
> > consider the lost+found directory entry to be corrupted.
> > 
> > Encrypting the root directory may also be of limited use because it is
> > the "all-or-nothing" use case, for which dm-crypt can be used instead.
> > (By design, encryption policies are inherited and cannot be overridden;
> > so the root directory having an encryption policy implies that all files
> > and directories on the filesystem have that same encryption policy.)
> > 
> > In any case, encrypting the root directory is broken currently and must
> > not be allowed; so start returning an error if userspace requests it.
> > For now only do this in ext4, because f2fs and ubifs do not appear to
> > have the lost+found requirement.  We could move it into
> > fscrypt_ioctl_set_policy() later if desired, though.
> > 
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> 
> Reviewed-by: Andreas Dilger <adilger@dilger.ca>

Thanks, applied.

						- Ted
