Return-Path: <ebiggers3@gmail.com>
Date: Wed, 26 Apr 2017 15:52:12 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] ubifs: Return -ENOKEY from rename if encryption keys are
 missing
Message-ID: <20170426225212.GB104929@gmail.com>
References: <1493070381-20075-1-git-send-email-richard@nod.at>
 <20170425175442.GB41477@google.com>
 <1f759fee-337f-903a-0eb0-5b364cd35e6f@sigma-star.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1f759fee-337f-903a-0eb0-5b364cd35e6f@sigma-star.at>
To: David Oberhollenzer <david.oberhollenzer@sigma-star.at>
Cc: Eric Biggers <ebiggers@google.com>, Richard Weinberger <richard@nod.at>, linux-mtd@lists.infradead.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, david@sigma-star.at
List-ID: <linux-fscrypt@vger.kernel.org>

Hi David,

On Wed, Apr 26, 2017 at 01:48:10PM +0200, David Oberhollenzer wrote:
> On 04/25/2017 07:54 PM, Eric Biggers wrote:
> > Did you test that this change actually does anything?  Unlike ext4 and f2fs,
> > ubifs calls fscrypt_setup_filename() from its rename methods rather than through
> > a helper function ${FS}_find_entry().  Therefore it's able to pass in lookup=0,
> > which means that the key is required.  So it should already be failing with
> > ENOKEY.  You can verify this by running xfstests generic/419.
> 
> Actually, running xfstests was how this cropped up in the first place.
> 
> The UBIFS rename and xrename functions allready call
> fscrypt_setup_filename with lookup=0, however there are other tests
> before that call and moving them around causes generic/419 to fail
> at a different place where EPERM was expected.
> 
> Therefore I concluded that the safest way to fix this might be to
> simply copy the way the checks are handled in ext4.
> 
> With recent xfstests + UBIFS support patch, after applying this patch,
> generic/419 passes.

Are you sure?  I just tried rebasing my ubifs support patches for xfstests and
xfstests-bld onto the latest xfstests and xfstests-bld respectively, then
building a new kvm-xfstests appliance and the latest kernel from Linus's tree.
These are the failures I see with ubifs in the "encrypt" group:

$ kvm-xfstests -c ubifs -g encrypt
 [15:39:00] - output mismatch (see /results/ubifs/results-default/generic/397.out.bad)
    --- tests/generic/397.out	2017-04-26 14:37:27.000000000 -0700
    +++ /results/ubifs/results-default/generic/397.out.bad	2017-04-26 15:39:00.807418574 -0700
    @@ -10,4 +10,12 @@
     mkdir: cannot create directory 'SCRATCH_MNT/edir/0123456789abcdef': Required key not available
     ln: failed to create symbolic link 'SCRATCH_MNT/edir/newlink': Required key not available
     ln: failed to create symbolic link 'SCRATCH_MNT/edir/0123456789abcdef': Required key not available
    -stat: cannot stat 'SCRATCH_MNT/edir': No such file or directory
    +rm: cannot remove '/vdc/edir': Directory not empty
    +  File: 'SCRATCH_MNT/edir'
    +  Size: 632       	Blocks: 0          IO Block: 4096   directory
    ...
    (Run 'diff -u tests/generic/397.out /results/ubifs/results-default/generic/397.out.bad'  to see the entire diff)
...
 [15:39:03] - output mismatch (see /results/ubifs/results-default/generic/398.out.bad)
    --- tests/generic/398.out	2017-04-26 14:37:24.000000000 -0700
    +++ /results/ubifs/results-default/generic/398.out.bad	2017-04-26 15:39:03.114085240 -0700
    @@ -42,4 +42,4 @@
     Required key not available
     
     *** Exchange encrypted <=> unencrypted without key ***
    -Required key not available
    +Operation not permitted
    ...
    (Run 'diff -u tests/generic/398.out /results/ubifs/results-default/generic/398.out.bad'  to see the entire diff)


generic/397 is failing (I don't know why), and generic/398 is failing.  But
generic/419 is *not* failing.

What's happening with generic/398 is that it's trying cross-rename to exchange
an unencrypted file with an encrypted one.  The tests expects ENOKEY, but there
are actually two separate reasons why this operation is expected to fail:

(1) It's trying to link a file into an encrypted directory with the directory's
    key being available (ENOKEY)
(2) It's trying to place an unencrypted file into an encrypted directory, which
    violates the policy that all files in an encrypted directory have the same
    encryption policy (EPERM)

Personally I think that maybe the generic/398 test should just be updated to
accept either error code, given that there are two valid reasons for the
operation to fail.

- Eric
