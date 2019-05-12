Return-Path: <SRS0=6ZyK=TM=gmail.com=guaneryu@kernel.org>
Date: Sun, 12 May 2019 20:58:16 +0800
From: Eryu Guan <guaneryu@gmail.com>
Subject: Re: [RFC PATCH 0/7] xfstests: verify fscrypt-encrypted contents and
 filenames
Message-ID: <20190512125816.GK15846@desktop>
References: <20190426204153.101861-1-ebiggers@kernel.org>
 <20190506155721.GB661@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190506155721.GB661@sol.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, May 06, 2019 at 08:57:22AM -0700, Eric Biggers wrote:
> On Fri, Apr 26, 2019 at 01:41:46PM -0700, Eric Biggers wrote:
> > Hello,
> > 
> > This series adds xfstests which verify that encrypted contents and
> > filenames on ext4 and f2fs are actually correct, i.e. that the
> > encryption uses the correct algorithms, keys, IVs, and padding amounts.
> > The new tests work by creating encrypted files, unmounting the
> > filesystem, reading the ciphertext from disk using dd and debugfs or
> > dump.f2fs, and then comparing it against ciphertext computed
> > independently by a new test program that implements the same algorithms.
> > 
> > These tests are important because:
> > 
> > - The whole point of file encryption is that the files are actually
> >   encrypted correctly on-disk.  Except for generic/399, current xfstests
> >   only tests the filesystem semantics, not the actual encryption.
> >   generic/399 only tests for incompressibility of encrypted file
> >   contents using one particular encryption setting, which isn't much.
> > 
> > - fscrypt now supports 4 main combinations of encryption settings,
> >   rather than 1 as it did originally.  This may be doubled to 8 soon
> >   (https://patchwork.kernel.org/patch/10908153/).  We should test all
> >   settings.  And without tests, even if the initial implementation is
> >   correct, breakage in one specific setting could go undetected.
> > 
> > - Though Linux's crypto API has self-tests, these only test the
> >   algorithms themselves, not how they are used, e.g. by fscrypt.
> > 
> > Patch 1 is a cleanup patch.  Patches 2-4 add the common helpers for
> > ciphertext verification tests.  Patches 5-7 add the actual tests.
> > 
> > These tests require e2fsprogs and f2fs-tools patches I recently sent out
> > to fix printing encrypted filenames.  So, this series might not be
> > suitable for merging into mainline xfstests until those patches are
> > applied.  Regardless, comments are appreciated.  The needed patches are:
> > 
> > 	debugfs: avoid ambiguity when printing filenames (https://marc.info/?l=linux-ext4&m=155596495624232&w=2)
> > 	f2fs-tools: improve filename printing (https://sourceforge.net/p/linux-f2fs/mailman/message/36648641/)
> > 
> > This series can also be retrieved from git at
> > https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/xfstests-dev.git
> > branch "ciphertext-verification".
> > 
> > I also have patches on top of this series which verify the ciphertext
> > produced from v2 encryption policies, which are proposed by my kernel
> > patch series "fscrypt: key management improvements"
> > (https://patchwork.kernel.org/cover/10908107/).  v2 encryption policies
> > will use a different key derivation function, and thus their ciphertext
> > will be different.  These additional patches can be found at branch
> > "fscrypt-key-mgmt-improvements" of my git repo above.  But I've arranged
> > things such that this shorter series can potentially be applied earlier,
> > to test what's in the kernel now.
> > 
> > Eric Biggers (7):
> >   common/encrypt: introduce helpers for set_encpolicy and get_encpolicy
> >   fscrypt-crypt-util: add utility for reproducing fscrypt encrypted data
> >   common/encrypt: support requiring other encryption settings
> >   common/encrypt: add helper for ciphertext verification tests
> >   generic: verify ciphertext of v1 encryption policies with AES-256
> >   generic: verify ciphertext of v1 encryption policies with AES-128
> >   generic: verify ciphertext of v1 encryption policies with Adiantum
> > 
> >  .gitignore               |    1 +
> >  common/encrypt           |  482 ++++++++++-
> >  src/Makefile             |    3 +-
> >  src/fscrypt-crypt-util.c | 1645 ++++++++++++++++++++++++++++++++++++++
> >  tests/ext4/024           |    3 +-
> >  tests/generic/395        |   28 +-
> >  tests/generic/395.out    |    2 +-
> >  tests/generic/396        |   15 +-
> >  tests/generic/397        |    3 +-
> >  tests/generic/398        |    5 +-
> >  tests/generic/399        |    3 +-
> >  tests/generic/419        |    3 +-
> >  tests/generic/421        |    3 +-
> >  tests/generic/429        |    3 +-
> >  tests/generic/435        |    3 +-
> >  tests/generic/440        |    5 +-
> >  tests/generic/700        |   41 +
> >  tests/generic/700.out    |    5 +
> >  tests/generic/701        |   41 +
> >  tests/generic/701.out    |    5 +
> >  tests/generic/702        |   43 +
> >  tests/generic/702.out    |   10 +
> >  tests/generic/group      |    3 +
> >  23 files changed, 2308 insertions(+), 47 deletions(-)
> >  create mode 100644 src/fscrypt-crypt-util.c
> >  create mode 100755 tests/generic/700
> >  create mode 100644 tests/generic/700.out
> >  create mode 100755 tests/generic/701
> >  create mode 100644 tests/generic/701.out
> >  create mode 100755 tests/generic/702
> >  create mode 100644 tests/generic/702.out
> > 
> > -- 
> > 2.21.0.593.g511ec345e18-goog
> > 
> 
> Any comments on this?

Sorry for the late review, I went through the patches and they look fine
to me over all from fstests perspective, I replied a few minor issues to
individual patches.

It'd be great if ext4 and/or f2fs folks could help review the tests as
well.

Thanks,
Eryu

> 
> FYI, the e2fsprogs patch that these tests need was applied.
> 
> I'm still waiting for the f2fs-tools patch.
> 
> - Eric
