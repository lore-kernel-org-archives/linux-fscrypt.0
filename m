Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:38952 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725881AbeHGWe2 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 7 Aug 2018 18:34:28 -0400
Date: Tue, 7 Aug 2018 13:18:19 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] crypto: remove speck
Message-ID: <20180807201819.GA25300@gmail.com>
References: <20180806223300.113891-1-ebiggers@kernel.org>
 <20180806230437.21431-1-Jason@zx2c4.com>
 <CAH8yC8kKet=fx0rYF8QEWK+TzyBgwHrLabWE72znBY=QLZVWkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH8yC8kKet=fx0rYF8QEWK+TzyBgwHrLabWE72znBY=QLZVWkA@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Jeffrey Walton <noloader@gmail.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Jeffrey,

On Mon, Aug 06, 2018 at 09:03:27PM -0400, Jeffrey Walton wrote:
> On Mon, Aug 6, 2018 at 7:04 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> > These are unused, undesired, and have never actually been used by
> > anybody. The original authors of this code have changed their mind about
> > its inclusion. Therefore, this patch removes it.
> 
> I think it may be unwise to completely discard Speck for several
> reasons. The two biggest pain points for me are:
> 
>   - political concerns addressed by other ciphers
>   - high quality lightweight block cipher implementation
>   - some regulated industries will need it for their problem domains
> 
> It seems to me the political concerns were addressed by not using
> Speck for Android. I don't believe HPolyC and Speck are orthogonal.
> Instead they provide the user with a choice which is usually a good
> thing.
> 
> I also think allowing politics a heavy hand endangers other ciphers
> like SM3 and SM4. I would advise against removing them just because
> they are Chinese ciphers. I suppose the same could be argued for North
> Korea and Jipsam and Pilsung (if North Korea ever offers their
> ciphers).
> 
> I think Eric, Ard and other contributions lead to a high quality
> implementation of Speck. High quality implementations that "just
> works" everywhere on multiple platforms are rather hard to come by.
> The kernel's unified implementation ensures lots of folks don't go
> making lots of mistakes when rolling their own.
> 
> There are verticals that will need a choice or alternative like Speck.
> US Aerospace, US Automotive and US Hoteliers come to mind. US
> Financial my use them too (they having some trading platforms with
> absurd requirements that make Simon and Speck appear bloated and
> overweight).  Some of the verticals are going to need an alternative
> that meets technical and security goals and pass the audits.
> 
> Choice is a good thing. Users need choices for technical, regulatory
> and legal reasons.
> 

This is about the Linux kernel, though.  The purpose of the Linux kernel's
crypto API is to allow kernel code to do crypto, and also sometimes to allow
access to crypto accelerator hardware.  It's *not* to provide a comprehensive
collection of algorithms for userspace programs to use, or to provide reference
implementations for crypto algorithms.  Before our change in plans, we needed
Speck-XTS in the kernel so that it could be used in dm-crypt and fscrypt, which
are kernel features and therefore require in-kernel implementations.  And of
course, our proposed new solution, HPolyC, will need to be supported in the
kernel too for the same reason.  It's just the way transparent disk and file
encryption works; the crypto needs to be done in the kernel.  But do your other
mentioned use cases actually need Speck to be in the Linux kernel?

I doubt it, in general.  Userspace applications of Speck seem likely to use
their own implementation.  Remember, Speck is extraordinarily simple, and the
original paper has example C code.  So if someone really wanted to use Speck in
a userspace application, they're likely to just add an implementation directly
to their application, rather than coding up a Linux-specific thing using AF_ALG.
Or they'd use a Speck implementation from a library like Crypto++.

And while I think it's clear that the reasons why a significant number of people
don't want to *use* Speck (even in legitimate use cases) are heavily political,
that doesn't necessarily mean that the reason for removing Speck from Linux
needs to be as political.  If there's code in the kernel with no known users
anymore, whether it's a crypto algorithm or something like an obsolete CPU
architecture, then it's eligible to be removed so that it doesn't need to be
maintained -- potentially even if it breaks the userspace ABI (since it's not
really broken if no one cares)...  Note that Skein is another example of a
crypto algorithm that was recently removed from the kernel because no one was
using it, though to be fair it was in the staging directory too.  It's still a
bit of a double standard as there are likely other ciphers in the kernel that
actually no one is using either, but it's a valid argument...

Thanks,

- Eric
