Return-Path: <ebiggers3@gmail.com>
Date: Thu, 31 Aug 2017 11:14:42 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
Message-ID: <20170831181442.GD5023@gmail.com>
References: <20170818194730.61575-1-ebiggers3@gmail.com>
 <9dcef6c6-a758-ea57-0d51-55f33e365931@oracle.com>
 <20170821230821.GB8847@gmail.com>
 <7a34337d-3214-0a8a-5521-7727364cceb4@oracle.com>
 <20170822030730.GB3577@zzz.localdomain>
 <a84707f9-b9b9-fe7e-b2f5-d5edfcb9c91a@oracle.com>
 <20170822173600.GB9587@gmail.com>
 <94e45437-c71c-1d45-ffcb-2cf2447261b8@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <94e45437-c71c-1d45-ffcb-2cf2447261b8@oracle.com>
To: Anand Jain <anand.jain@oracle.com>
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 28, 2017 at 08:18:55PM +0800, Anand Jain wrote:
> 
> 
> On 08/23/2017 01:36 AM, Eric Biggers wrote:
> >On Tue, Aug 22, 2017 at 11:35:20PM +0800, Anand Jain wrote:
> >>>>
> >>>>   I think AE is the only good solution for this, File-name encryption at
> >>>>this stage won't solve any kind of Evil Maid attack, (as it was quoted
> >>>>somewhere else in ML).
> >>>>
> >>>>
> >>>>  Further, below,  is define but not used.
> >>>>-----
> >>>>  #define FS_AES_256_GCM_KEY_SIZE		32
> >>>>-----
> >>>>
> >>>
> >>>Yes, authenticated encryption with AES-256-GCM was in an older version of the
> >>>ext4 encryption design document.  But unfortunately it was never really thought
> >>>through. The primary problem, even ignoring rollback protection, is that there
> >>>is nowhere to store the per-block metadata (GCM authentication tag and IV) *and*
> >>>have it updated atomicly with the block contents.  Recently, dm-integrity solves
> >>>this at the block device layer, but it uses data journaling which is very
> >>>inefficient.  This maybe could be implemented more efficiently on a COW
> >>>filesystem like BTRFS.  But even after that, another problem is that
> >>>authenticated encryption of file contents only would not stop an attacker from
> >>>swapping around blocks, files, directories, or creating links, etc.
> >>
> >>
> >>  Some of the problems to be solved in this area are quite
> >>interesting and challenging and IMO BTRFS fits nicely. Per extent AE
> >>for BTRFS is drafted, it needs scrutiny and constructive feedback.
> >>
> >>Thanks, Anand
> >>
> >>
> >>>Eric
> >>>
> >
> >Where is the code?  Is there a design document, and it is it readable by people
> >not as familiar with btrfs?  Is the API compatible with ext4, f2fs, and ubifs?
> >
> >Eric
> 
>  (sorry for the delay in replay due to my vacation).
> 
>  Eric, No code yet, proposed encryption method is seeking review.
> Link sent to you.
> 
> Thanks, Anand

Thanks, I'll review it when I have time.  Can you please consider sending out a
public link to linux-fscrypt, linux-fsdevel, linux-btrfs, etc. so that other
people can review it too?

Eric
