Return-Path: <tytso@thunk.org>
Date: Wed, 15 Mar 2017 14:41:40 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] ext4: mark inode dirty after converting inline directory
Message-ID: <20170315184139.ranpl7cxfc4edlrz@thunk.org>
References: <20170222212246.60931-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170222212246.60931-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-ext4@vger.kernel.org, Andreas Dilger <adilger.kernel@dilger.ca>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Feb 22, 2017 at 01:22:46PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> If ext4_convert_inline_data() was called on a directory with inline
> data, the filesystem was left in an inconsistent state (as considered by
> e2fsck) because the file size was not increased to cover the new block.
> This happened because the inode was not marked dirty after i_disksize
> was updated.  Fix this by marking the inode dirty at the end of
> ext4_finish_convert_inline_dir().
> 
> This bug was probably not noticed before because most users mark the
> inode dirty afterwards for other reasons.  But if userspace executed
> FS_IOC_SET_ENCRYPTION_POLICY with invalid parameters, as exercised by
> 'kvm-xfstests -c adv generic/396', then the inode was never marked dirty
> after updating i_disksize.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied, thanks.

					- Ted
