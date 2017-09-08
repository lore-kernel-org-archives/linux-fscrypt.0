Return-Path: <ebiggers3@gmail.com>
Date: Fri, 8 Sep 2017 16:12:23 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 0/3] fscrypto: Return -EXDEV for link, rename, and
 cross-rename between incompat contexts
Message-ID: <20170908231223.GA71686@gmail.com>
References: <20170908001204.18174-1-mhalcrow@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170908001204.18174-1-mhalcrow@google.com>
To: Michael Halcrow <mhalcrow@google.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Michael,

On Thu, Sep 07, 2017 at 05:12:01PM -0700, Michael Halcrow wrote:
> Currently file systems support fscrypto will return -EPERM when the
> user attempts to link, rename, or cross-rename between two directories
> that have incompatible encryption policy contexts.  User space tools
> will fail the operation when receiving this errno.  With -EXDEV, user
> space tools will typically fall back to copy-and-delete instead.

Mention 'mv' as an example to make it more concrete?

> Our original motivation for returning -EPERM was to force users to try
> harder when doing these operations, hopefully making them think more
> carefully about whether what they're doing is secure.  One security
> concern is that when moving files between unencrypted locations into
> encrypted locations, the data in the unencrypted location will remain
> in the clear on the storage device until the freed blocks are
> overwritten at some arbitrary point in the future (if ever).  Moving
> files from encrypted locations into unencrypted locations is also
> (perhaps more obviously) problematic.
> 
> Whether making things fail will have the intended effect on users is
> up for debate.  Meanwhile I've had at least one person tell me their
> userspace tools are failing and that they would prefer seeing the same
> sort of behavior that they see when (for example) moving files from
> one project quota hierarchy to another (ext4 returns -EXDEV).

There are arguments in favor of this, but I'm worried that people will think
they can encrypt their files by "moving" them into an encrypted directory.  In
fact, the unencrypted data will still be on-disk in the free blocks.  When
people say they want 'mv' to work, do they actually understand that it usually
defeats the purpose of encryption?  Or are they naively assuming that deleting a
file means its data is gone forever?

In any case, if we actually do this we'd need to document that mv-ing files into
an encrypted directory is a bad idea, although it would be of limited use since
users rarely read documentation.

> Michael Halcrow (3):
>   ext4 crypto: Return -EXDEV for link, rename, and cross-rename between
>     incompat contexts
>   F2FS crypto: Return -EXDEV for link, rename, and cross-rename between
>     incompat contexts
>   UBIFS crypto: Return -EXDEV for link, rename, and cross-rename between
>     incompat contexts

Nits for if we do end up doing this: remove "cross-rename" from the subjects to
shorten them a bit (cross-rename is a type of rename), then add more detail to
the patch descriptions, even if that requires duplicating some text.  The cover
letter doesn't get recorded in the commit history, only the actual commits do.

Note: I'm also working on a patchset which adds helper functions
fscrypt_prepare_link() and fscrypt_prepare_rename().  After that, this error
will be chosen by the shared code, rather than individual filesystems.

Eric
