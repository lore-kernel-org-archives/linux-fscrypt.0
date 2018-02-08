Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:34551 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752054AbeBHVBL (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 8 Feb 2018 16:01:11 -0500
Received: by mail-it0-f54.google.com with SMTP id j21so806169ita.1
        for <linux-fscrypt@vger.kernel.org>; Thu, 08 Feb 2018 13:01:11 -0800 (PST)
Date: Thu, 8 Feb 2018 13:01:07 -0800
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH 0/5] crypto: Speck support
Message-ID: <20180208210107.GA6720@google.com>
References: <20180208001001.19180-1-ebiggers@google.com>
 <CAH8yC8m4F9SWum9D5ZV2wzVAsJaDxnkc1L6eSeEOV-cOdkcg6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH8yC8m4F9SWum9D5ZV2wzVAsJaDxnkc1L6eSeEOV-cOdkcg6Q@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Jeffrey Walton <noloader@gmail.com>
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Feb 07, 2018 at 08:47:05PM -0500, Jeffrey Walton wrote:
> On Wed, Feb 7, 2018 at 7:09 PM, Eric Biggers <ebiggers@google.com> wrote:
> > Hello,
> >
> > This series adds Speck support to the crypto API, including the Speck128
> > and Speck64 variants.  Speck is a lightweight block cipher that can be
> > much faster than AES on processors that don't have AES instructions.
> >
> > We are planning to offer Speck-XTS (probably Speck128/256-XTS) as an
> > option for dm-crypt and fscrypt on Android, for low-end mobile devices
> > with older CPUs such as ARMv7 which don't have the Cryptography
> > Extensions.  Currently, such devices are unencrypted because AES is not
> > fast enough, even when the NEON bit-sliced implementation of AES is
> > used.  Other AES alternatives such as Blowfish, Twofish, Camellia,
> > Cast6, and Serpent aren't fast enough either; it seems that only a
> > modern ARX cipher can provide sufficient performance on these devices.
> >
> > This is a replacement for our original proposal
> > (https://patchwork.kernel.org/patch/10101451/) which was to offer
> > ChaCha20 for these devices.  However, the use of a stream cipher for
> > disk/file encryption with no space to store nonces would have been much
> > more insecure than we thought initially, given that it would be used on
> > top of flash storage as well as potentially on top of F2FS, neither of
> > which is guaranteed to overwrite data in-place.
> >
> > Speck has been somewhat controversial due to its origin.  Nevertheless,
> > it has a straightforward design (it's an ARX cipher), and it appears to
> > be the leading software-optimized lightweight block cipher currently,
> > with the most cryptanalysis.  It's also easy to implement without side
> > channels, unlike AES.  Moreover, we only intend Speck to be used when
> > the status quo is no encryption, due to AES not being fast enough.
> >
> > We've also considered a novel length-preserving encryption mode based on
> > ChaCha20 and Poly1305.  While theoretically attractive, such a mode
> > would be a brand new crypto construction and would be more complicated
> > and difficult to implement efficiently in comparison to Speck-XTS.
> >
> > Thus, patch 1 adds a generic implementation of Speck, and the following
> > patches add a 32-bit ARM NEON implementation of Speck-XTS.  The
> > NEON-accelerated implementation is much faster than the generic
> > implementation and therefore is the implementation that would primarily
> > be used in practice on the devices we are targeting.
> >
> > There is no AArch64 implementation added, since such CPUs are likely to
> > have the Cryptography Extensions, allowing the use of AES.
> 
> +1 on SPECK.
> 
> Its a nice cipher that runs fast. It is nice because the security
> engineering and parameter selection is well specified, and you can
> push the margins as low as you like. It does not guess at security
> parameters like some of the other ciphers used in dm-crypt.
> 
> On a modern Core-i5 6th gen I've seen numbers as low as ...
> SPECK-64/128 runs around 2.1 cpb, and SPECK-128/256 runs around 2.4
> cpb.
> 
> I've already done some work for a US contractor who wanted/needed
> SPECK for a possible NASA contract. NASA is looking at SPECK for some
> satellite comms.
> 

Hi Jeffrey,

I see you wrote the SPECK implementation in Crypto++, and you are treating the
words as big endian.

Do you have a reference for this being the "correct" order?  Unfortunately the
authors of the cipher failed to mention the byte order in their paper.  And they
gave the test vectors as words, so the test vectors don't clarify it either.

I had assumed little endian words, but now I am having second thoughts...  And
to confuse things further, it seems that some implementations (including the
authors own implementation for the SUPERCOP benchmark toolkit [1]) even consider
the words themselves in the order (y, x) rather than the more intuitive (x, y).

[1] https://github.com/iadgov/simon-speck-supercop/blob/master/crypto_stream/speck128128ctr/ref/stream.c

In fact, even the reference code from the paper treats pt[0] as y and pt[1] as
x, where 'pt' is a u64 array -- although that being said, it's not shown how the
actual bytes should be translated to/from those u64 arrays.

I'd really like to avoid people having to add additional versions of SPECK later
for the different byte and word orders...

- Eric
