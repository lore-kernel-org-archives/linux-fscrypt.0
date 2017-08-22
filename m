Return-Path: <tytso@thunk.org>
Date: Mon, 21 Aug 2017 23:07:57 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
Message-ID: <20170822030757.z5da7up5k7gnrfja@thunk.org>
References: <20170818194730.61575-1-ebiggers3@gmail.com>
 <9dcef6c6-a758-ea57-0d51-55f33e365931@oracle.com>
 <20170821230821.GB8847@gmail.com>
 <7a34337d-3214-0a8a-5521-7727364cceb4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7a34337d-3214-0a8a-5521-7727364cceb4@oracle.com>
To: Anand Jain <anand.jain@oracle.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Aug 22, 2017 at 10:22:13AM +0800, Anand Jain wrote:
> 
>   I think AE is the only good solution for this, File-name encryption at
> this stage won't solve any kind of Evil Maid attack, (as it was quoted
> somewhere else in ML).

AE doesn't help at all against the Evil Maid attack, since the Evil
Maid is trying get the user's keying material, and what kind of
encryption you are using is pretty much irrelevant.

The typical attack (where the user's keys are available to the host
CPU) involves compromising the system software --- and system software
is public (everyone can get a copy of the Android system image for a
particular device), so encryption is pointless.  That's why the system
image is protected using dm-verity, which provides data integrity, but
not confidentiality.

The bootloader will protect against installing a new system image
unless you have the private key of the handset manufacturer to sign
said system image.  But the Evil Maid can carry out a "chip off"
attack, where flash chip is desoldered and the system image, and the
dm-verity information can be written directly without the bootloader
being able to prevent it.

This is why using AE isn't going to help you.  Sure, the Evil Maid
could try to diddle directories and use complicated crypto attacks.
But why bother when they can just simply steal the user's keys, at
which point all the AE in the world doesn't help a whit.

Cheers,

						- Ted
