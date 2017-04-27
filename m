Return-Path: <david.oberhollenzer@sigma-star.at>
Subject: Re: [PATCH] ubifs: Return -ENOKEY from rename if encryption keys are
 missing
References: <1493070381-20075-1-git-send-email-richard@nod.at>
 <20170425175442.GB41477@google.com>
 <1f759fee-337f-903a-0eb0-5b364cd35e6f@sigma-star.at>
 <20170426225212.GB104929@gmail.com>
From: David Oberhollenzer <david.oberhollenzer@sigma-star.at>
Message-ID: <99c58fc3-fd4f-e3cf-c05b-e25e6dd0d79e@sigma-star.at>
Date: Thu, 27 Apr 2017 10:59:15 +0200
MIME-Version: 1.0
In-Reply-To: <20170426225212.GB104929@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Eric Biggers <ebiggers@google.com>, Richard Weinberger <richard@nod.at>, linux-mtd@lists.infradead.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, david@sigma-star.at
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

On 04/27/2017 12:52 AM, Eric Biggers wrote:
> Hi David,
> 
> On Wed, Apr 26, 2017 at 01:48:10PM +0200, David Oberhollenzer wrote:
>> On 04/25/2017 07:54 PM, Eric Biggers wrote:
>>> Did you test that this change actually does anything?  Unlike ext4 and f2fs,
>>> ubifs calls fscrypt_setup_filename() from its rename methods rather than through
>>> a helper function ${FS}_find_entry().  Therefore it's able to pass in lookup=0,
>>> which means that the key is required.  So it should already be failing with
>>> ENOKEY.  You can verify this by running xfstests generic/419.
>>
>> Actually, running xfstests was how this cropped up in the first place.
>>
>> The UBIFS rename and xrename functions allready call
>> fscrypt_setup_filename with lookup=0, however there are other tests
>> before that call and moving them around causes generic/419 to fail
>> at a different place where EPERM was expected.

Sorry, I perhaps replied a little to hastily and mixed up the
test numbers.

I just double checked and read up on the IRC backlog,
it actually _was_ 398 (see below).


> Are you sure?  I just tried rebasing my ubifs support patches for xfstests and
> xfstests-bld onto the latest xfstests and xfstests-bld respectively, then
> building a new kvm-xfstests appliance and the latest kernel from Linus's tree.

I used this kernel tree: git://git.infradead.org/linux-ubifs.git

Plus the following patches: https://lkml.org/lkml/2017/2/9/675

Using xfstests-dev: git://git.kernel.org/pub/scm/fs/xfs/xfstests-dev.git

Inside a Debian VM with scratch and test UBI volumes on nandsim.


> $ kvm-xfstests -c ubifs -g encrypt
>  [15:39:00] - output mismatch (see /results/ubifs/results-default/generic/397.out.bad)
>     --- tests/generic/397.out	2017-04-26 14:37:27.000000000 -0700
>     +++ /results/ubifs/results-default/generic/397.out.bad	2017-04-26 15:39:00.807418574 -0700
>     @@ -10,4 +10,12 @@
>      mkdir: cannot create directory 'SCRATCH_MNT/edir/0123456789abcdef': Required key not available
>      ln: failed to create symbolic link 'SCRATCH_MNT/edir/newlink': Required key not available
>      ln: failed to create symbolic link 'SCRATCH_MNT/edir/0123456789abcdef': Required key not available
>     -stat: cannot stat 'SCRATCH_MNT/edir': No such file or directory
>     +rm: cannot remove '/vdc/edir': Directory not empty
>     +  File: 'SCRATCH_MNT/edir'
>     +  Size: 632       	Blocks: 0          IO Block: 4096   directory
>     ...
>     (Run 'diff -u tests/generic/397.out /results/ubifs/results-default/generic/397.out.bad'  to see the entire diff)
> ...

This is fixed by the first patch in https://lkml.org/lkml/2017/2/9/675


> What's happening with generic/398 is that it's trying cross-rename to exchange
> an unencrypted file with an encrypted one.  The tests expects ENOKEY, but there
> are actually two separate reasons why this operation is expected to fail:
> 
> (1) It's trying to link a file into an encrypted directory with the directory's
>     key being available (ENOKEY)
> (2) It's trying to place an unencrypted file into an encrypted directory, which
>     violates the policy that all files in an encrypted directory have the same
>     encryption policy (EPERM)

Sorry again for the mix up. This is specifically what this patch is
trying to address.


> Personally I think that maybe the generic/398 test should just be updated to
> accept either error code, given that there are two valid reasons for the
> operation to fail.

But if there are different error codes with clearly outlined reasons
for returning each, wouldn't it be preferable to test that instead of
allowing an implementation to return arbitrary error codes?

To my understanding, that is what the test is trying to do there and at
least the ext4 rename and cross rename functions seem to care about
properly distinguishing between those cases.


David
