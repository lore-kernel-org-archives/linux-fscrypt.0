Return-Path: <david.oberhollenzer@sigma-star.at>
Subject: Re: [PATCH] fscrypt: use 32 bytes of encrypted filename
References: <20170418210642.6039-1-gwendal@chromium.org>
 <CAFLxGvz+kODD+8s9aPw_DeYtf3Gjv0aQBC=UfoBFx3Wn2b=wxQ@mail.gmail.com>
 <20170419170940.GA89688@gmail.com>
 <bdda413c-1452-9e55-53ff-34eb17ef4c3b@nod.at>
From: David Oberhollenzer <david.oberhollenzer@sigma-star.at>
Message-ID: <39a844e5-5718-3a63-1f8d-9f6d3568ca51@sigma-star.at>
Date: Thu, 20 Apr 2017 13:24:04 +0200
MIME-Version: 1.0
In-Reply-To: <bdda413c-1452-9e55-53ff-34eb17ef4c3b@nod.at>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Richard Weinberger <richard@nod.at>, Eric Biggers <ebiggers3@gmail.com>
Cc: Gwendal Grignou <gwendal@chromium.org>, Theodore Ts'o <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, kinaba@chromium.org, hashimoto@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>

On 04/19/2017 07:12 PM, Richard Weinberger wrote:
> Eric,
> 
> Am 19.04.2017 um 19:09 schrieb Eric Biggers:
>> Hi Richard,
>>
>> On Wed, Apr 19, 2017 at 03:37:42PM +0200, Richard Weinberger wrote:
>>>>
>>>> Tested only on ext4.
>>>
>>> I hope you classify this patch as RFC then.
>>> We'll have problems when you just develop and test for ext4. :-)
>>>
>>
>> It's a little difficult for people to test stuff on UBIFS without a turn-key
>> solution like kvm-xfstests where they can just run something like
>> 'kvm-xfstests -c ext4,f2fs,ubifs -g encrypt'.
>>
>> I did post patches to add UBIFS support to xfstests and kvm-xfstests a few
>> months ago; maybe you're interested in taking them over and working to get them
>> merged?
> 
> I assigned this talk already to David.
> He can tell what the status is.
> 
What I have right now is mostly similar to the previous patch for
xfstests-dev that was submitted to the mailing list. I haven't looked
into the xfstests-bld patch yet.


To sumarize what happend so far:

A while ago, I took a look at Erics xfstest patches and the similar
patch series from Dongsheng Yang. Based on those, I got the xfstests
running with UBIFS on nandsim inside a VM with fairly little changes.
AFAIR there were two tests failing, one of them being generic/129,
apparently because it exhausts the space on one of the UBI volumes, and
another one for which a fix was provided.

My work on the xfstests-dev patch was preempted by other projects, but I
briefly got back to it when an O_TMPFILE regression was reported on the
mtd mailing list. This should have been caught by generic/004 but
wasn't because the UBIFS error message didn't match the grep pattern
run on dmesg.

Other such cases may exist.

Today, after rebasing/porting my local changes to upstream xfstets-dev,
I ran the tests against on both Richards UBIFS tree and Linus' tree. On
both kernels I'm now getting 5 failing tests out of 94 (with one of
them being generic/129 again).


Further work on some of the test scripts is required.


David
