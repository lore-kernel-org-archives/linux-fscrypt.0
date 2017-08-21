Return-Path: <tytso@thunk.org>
Date: Mon, 21 Aug 2017 17:02:14 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
Message-ID: <20170821210214.34ksroseab4mjgph@thunk.org>
References: <20170818194730.61575-1-ebiggers3@gmail.com>
 <9dcef6c6-a758-ea57-0d51-55f33e365931@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9dcef6c6-a758-ea57-0d51-55f33e365931@oracle.com>
To: Anand Jain <anand.jain@oracle.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 21, 2017 at 09:44:11PM +0800, Anand Jain wrote:
> 
> 
> > +fscrypt is not guaranteed to protect confidentiality or authenticity
> > +if an attacker is able to manipulate the filesystem offline prior to
> > +an authorized user later accessing the filesystem.
> 
>  How does fscrypt / Android protect against Evil Maid attack. ?

In order to answer that question it's important to be specific about
threat model is like; exactly what powers does the Evil Maid actually
have?

One of the stronger form of the Evil Maid attack posits that the Evil
Made can remove the device from your hotel room, modify the hardware
undetectably (up to and including desoldering the flash chip so it can
be read and write directly), then replace it back to your hotel room,
wait for you to login, and then later on, steal your phone and
desolder the flash chip again.

This sort of attack is going to require a combination of hardware and
software features.  Without talking about future product features on
any specific future device being shipped by Google or any other
company --- theoretically, if the keys are stored a hardware device
which only disgorges the keys sends them directly to the in-line
crypto engine without letting the keys be visible to the Linux kernel
(or the Host CPU in any way at all), then it makes these sorts of Evil
Maid much more difficult.

Of course, if the Evil Maid can somehow insert something to tap the
communications channel between the key storage device and the
inline-crypto engine, then all bets are off.  Presumably, though, this
could be made harder; for example, by putting them on the
system-on-a-chip.

					- Ted
					
