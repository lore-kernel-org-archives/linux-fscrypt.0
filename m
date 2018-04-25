Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36973 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753327AbeDYOd6 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 25 Apr 2018 10:33:58 -0400
MIME-Version: 1.0
In-Reply-To: <20180424224734.GA109345@google.com>
References: <20180212235209.117393-1-ebiggers@google.com> <CAHmME9oA4j=iGrrBYME92JfUsyi5r42PnAvzWiuXzGCRXMnXtA@mail.gmail.com>
 <20180424181623.GA174675@google.com> <CAHmME9qG+nPmj5c7hU4+STUsmWmwSBsKe-0mOLEXH+hJ1z4z=g@mail.gmail.com>
 <20180424224734.GA109345@google.com>
From: Samuel Neves <samuel.c.p.neves@gmail.com>
Date: Wed, 25 Apr 2018 15:33:16 +0100
Message-ID: <CAEX_ruHB7=zUuAWvbC9f6pDNhA4B32PGEkHi3QnPjRmRknrJ7w@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] crypto: Speck support
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tashur@esat.kuleuven.be
List-ID: <linux-fscrypt@vger.kernel.org>

Let's put the provenance of Speck aside for a moment, and suppose that
it is an ideal block cipher. There are still some issues with this
patch as it stands.

 - The rationale seems off. Consider this bit from the commit message:

> Other AES alternatives such as Twofish, Threefish, Camellia, CAST6, and Serpent aren't
> fast enough either; it seems that only a modern ARX cipher can provide sufficient performance
> on these devices.

One of these things is very much not like the others. Threefish _is_ a
modern ARX cipher---a tweakable block cipher in fact, precluding the
need for XEX-style masking. Is it too slow? Does it not have the
correct block size?

> We've also considered a novel length-preserving encryption mode based on
> ChaCha20 and Poly1305.

I'm very curious about this, namely as to what the role of Poly1305
would be here. ChaCha20's underlying permutation could, of course, be
transformed into a 512-bit tweakable block cipher relatively
painlessly, retaining the performance of regular ChaCha20 with
marginal additional overhead. This would not be a standard
construction, but clearly that is not an issue.

But the biggest problem here, in my mind, is that for all the talk of
using 128-bit block Speck, this patch tacks on the 64-bit block
variant of Speck into the kernel, and speck64-xts as well! As far as I
can tell, this is the _only_ instance of a 64-bit XTS instance in the
entire codebase. Now, if you wanted a fast 64-bit ARX block cipher,
the kernel already had XTEA. Instead, this is adding yet another
64-bit block cipher into the crypto API, in a disk-encryption mode no
less, so that it can be misused later. In the disk encryption setting,
it's particularly concerning to be using such a small block size, as
data volumes can quickly add up to the birthday bound.

> It's easy to say that, but do you have an actual suggestion?

I don't know how seriously you are actually asking this, but some
128-bit software-friendly block ciphers could be SPARX, LEA, RC5, or
RC6. SPARX, in particular, has similarities to Speck but has some
further AES-like design guarantees that other prior ARX block ciphers
did not. Some other bitsliced designs, such as Noekeon or SKINNY, may
also work well with NEON, but I don't know much about their
performance there.

Best regards,
Samuel Neves
