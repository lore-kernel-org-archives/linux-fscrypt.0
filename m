Return-Path: <SRS0=jwQZ=W4=gmail.com=guaneryu@kernel.org>
Date: Sun, 1 Sep 2019 20:29:29 +0800
From: Eryu Guan <guaneryu@gmail.com>
Subject: Re: [RFC PATCH 0/9] xfstests: add tests for fscrypt key management
 improvements
Message-ID: <20190901122926.GF2622@desktop>
References: <20190812175809.34810-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812175809.34810-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 12, 2019 at 10:58:00AM -0700, Eric Biggers wrote:
> Hello,
> 
> This patchset adds xfstests for the kernel patchset
> "[PATCH v8 00/20] fscrypt: key management improvements"
> https://lkml.kernel.org/linux-fsdevel/20190805162521.90882-1-ebiggers@kernel.org/T/#u
> 
> These tests test the new ioctls for managing filesystem encryption keys,
> and they test the new encryption policy version.
> 
> These tests depend on new xfs_io commands, for which I've sent a
> separate patchset for xfsprogs.
> 
> Note: currently only ext4, f2fs, and ubifs support encryption.  But I
> was told previously that since the fscrypt API is generic and may be
> supported by XFS in the future, the command-line wrappers for the
> fscrypt ioctls should be in xfs_io rather than in fstests directly
> (https://marc.info/?l=fstests&m=147976255831951&w=2).
> 
> We'll want to wait for the kernel patches to be mainlined before merging
> this, but I'm making it available now for any early feedback.
> 
> This version of the xfstests patchset can also be retrieved from tag
> "fscrypt-key-mgmt-improvements_2019-08-12" of
> https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/xfstests-dev.git

Sorry for getting so long to review this patchset. The patches all look
in a good shape to me, thanks a lot! Please see the reply to patch "3/9"
for the only minor issues I noticed.

But it'd be really helpful if other fscrypt folks could help review the
new tests!

Thanks,
Eryu

> 
> Eric Biggers (9):
>   common/encrypt: disambiguate session encryption keys
>   common/encrypt: add helper functions that wrap new xfs_io commands
>   common/encrypt: support checking for v2 encryption policy support
>   common/encrypt: support verifying ciphertext of v2 encryption policies
>   generic: add basic test for fscrypt API additions
>   generic: add test for non-root use of fscrypt API additions
>   generic: verify ciphertext of v2 encryption policies with AES-256
>   generic: verify ciphertext of v2 encryption policies with AES-128
>   generic: verify ciphertext of v2 encryption policies with Adiantum
> 
>  common/encrypt           | 180 +++++++++++++++++++----
>  src/fscrypt-crypt-util.c | 304 ++++++++++++++++++++++++++++++++++-----
>  tests/ext4/024           |   2 +-
>  tests/generic/397        |   4 +-
>  tests/generic/398        |   8 +-
>  tests/generic/399        |   4 +-
>  tests/generic/419        |   4 +-
>  tests/generic/421        |   4 +-
>  tests/generic/429        |   8 +-
>  tests/generic/435        |   4 +-
>  tests/generic/440        |   8 +-
>  tests/generic/800        | 127 ++++++++++++++++
>  tests/generic/800.out    |  91 ++++++++++++
>  tests/generic/801        | 136 ++++++++++++++++++
>  tests/generic/801.out    |  62 ++++++++
>  tests/generic/802        |  43 ++++++
>  tests/generic/802.out    |   6 +
>  tests/generic/803        |  43 ++++++
>  tests/generic/803.out    |   6 +
>  tests/generic/804        |  45 ++++++
>  tests/generic/804.out    |  11 ++
>  tests/generic/group      |   5 +
>  22 files changed, 1018 insertions(+), 87 deletions(-)
>  create mode 100755 tests/generic/800
>  create mode 100644 tests/generic/800.out
>  create mode 100755 tests/generic/801
>  create mode 100644 tests/generic/801.out
>  create mode 100755 tests/generic/802
>  create mode 100644 tests/generic/802.out
>  create mode 100755 tests/generic/803
>  create mode 100644 tests/generic/803.out
>  create mode 100755 tests/generic/804
>  create mode 100644 tests/generic/804.out
> 
> -- 
> 2.23.0.rc1.153.gdeed80330f-goog
> 
