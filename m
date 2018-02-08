Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:46259 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750987AbeBHBrG (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 7 Feb 2018 20:47:06 -0500
MIME-Version: 1.0
Reply-To: noloader@gmail.com
In-Reply-To: <20180208001001.19180-1-ebiggers@google.com>
References: <20180208001001.19180-1-ebiggers@google.com>
From: Jeffrey Walton <noloader@gmail.com>
Date: Wed, 7 Feb 2018 20:47:05 -0500
Message-ID: <CAH8yC8m4F9SWum9D5ZV2wzVAsJaDxnkc1L6eSeEOV-cOdkcg6Q@mail.gmail.com>
Subject: Re: [PATCH 0/5] crypto: Speck support
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Feb 7, 2018 at 7:09 PM, Eric Biggers <ebiggers@google.com> wrote:
> Hello,
>
> This series adds Speck support to the crypto API, including the Speck128
> and Speck64 variants.  Speck is a lightweight block cipher that can be
> much faster than AES on processors that don't have AES instructions.
>
> We are planning to offer Speck-XTS (probably Speck128/256-XTS) as an
> option for dm-crypt and fscrypt on Android, for low-end mobile devices
> with older CPUs such as ARMv7 which don't have the Cryptography
> Extensions.  Currently, such devices are unencrypted because AES is not
> fast enough, even when the NEON bit-sliced implementation of AES is
> used.  Other AES alternatives such as Blowfish, Twofish, Camellia,
> Cast6, and Serpent aren't fast enough either; it seems that only a
> modern ARX cipher can provide sufficient performance on these devices.
>
> This is a replacement for our original proposal
> (https://patchwork.kernel.org/patch/10101451/) which was to offer
> ChaCha20 for these devices.  However, the use of a stream cipher for
> disk/file encryption with no space to store nonces would have been much
> more insecure than we thought initially, given that it would be used on
> top of flash storage as well as potentially on top of F2FS, neither of
> which is guaranteed to overwrite data in-place.
>
> Speck has been somewhat controversial due to its origin.  Nevertheless,
> it has a straightforward design (it's an ARX cipher), and it appears to
> be the leading software-optimized lightweight block cipher currently,
> with the most cryptanalysis.  It's also easy to implement without side
> channels, unlike AES.  Moreover, we only intend Speck to be used when
> the status quo is no encryption, due to AES not being fast enough.
>
> We've also considered a novel length-preserving encryption mode based on
> ChaCha20 and Poly1305.  While theoretically attractive, such a mode
> would be a brand new crypto construction and would be more complicated
> and difficult to implement efficiently in comparison to Speck-XTS.
>
> Thus, patch 1 adds a generic implementation of Speck, and the following
> patches add a 32-bit ARM NEON implementation of Speck-XTS.  The
> NEON-accelerated implementation is much faster than the generic
> implementation and therefore is the implementation that would primarily
> be used in practice on the devices we are targeting.
>
> There is no AArch64 implementation added, since such CPUs are likely to
> have the Cryptography Extensions, allowing the use of AES.

+1 on SPECK.

Its a nice cipher that runs fast. It is nice because the security
engineering and parameter selection is well specified, and you can
push the margins as low as you like. It does not guess at security
parameters like some of the other ciphers used in dm-crypt.

On a modern Core-i5 6th gen I've seen numbers as low as ...
SPECK-64/128 runs around 2.1 cpb, and SPECK-128/256 runs around 2.4
cpb.

I've already done some work for a US contractor who wanted/needed
SPECK for a possible NASA contract. NASA is looking at SPECK for some
satellite comms.

Jeff
