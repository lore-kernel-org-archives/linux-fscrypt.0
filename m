Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34943 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751274AbeDZCGZ (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 25 Apr 2018 22:06:25 -0400
MIME-Version: 1.0
In-Reply-To: <20180425194919.GA79662@google.com>
References: <20180212235209.117393-1-ebiggers@google.com> <CAHmME9oA4j=iGrrBYME92JfUsyi5r42PnAvzWiuXzGCRXMnXtA@mail.gmail.com>
 <20180424181623.GA174675@google.com> <CAHmME9qG+nPmj5c7hU4+STUsmWmwSBsKe-0mOLEXH+hJ1z4z=g@mail.gmail.com>
 <20180424224734.GA109345@google.com> <CAEX_ruHB7=zUuAWvbC9f6pDNhA4B32PGEkHi3QnPjRmRknrJ7w@mail.gmail.com>
 <20180425194919.GA79662@google.com>
From: Samuel Neves <samuel.c.p.neves@gmail.com>
Date: Thu, 26 Apr 2018 03:05:44 +0100
Message-ID: <CAEX_ruHoVRnBPazLhi6c+ps52yjb_SW=VfwxjiAW8izjvs24uQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] crypto: Speck support
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers@google.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tashur@esat.kuleuven.be
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Apr 25, 2018 at 8:49 PM, Eric Biggers <ebiggers@google.com> wrote:
> I agree that my explanation should have been better, and should have considered
> more crypto algorithms.  The main difficulty is that we have extreme performance
> requirements -- it needs to be 50 MB/s at the very least on even low-end ARM
> devices like smartwatches.  And even with the NEON-accelerated Speck128-XTS
> performance exceeding that after much optimization, we've been getting a lot of
> pushback as people want closer to 100 MB/s.
>

I couldn't find any NEON-capable ARMv7 chip below 800 MHz, so this
would put the performance upper bound around 15 cycles per byte, with
the comfortable number being ~7. That's indeed tough, though not
impossible.

>
> That's why I also included Speck64-XTS in the patches, since it was
> straightforward to include, and some devices may really need that last 20-30% of
> performance for encryption to be feasible at all.  (And when the choice is
> between unencrypted and a 64-bit block cipher, used in a context where the
> weakest points in the cryptosystem are actually elsewhere such as the user's
> low-entropy PIN and the flash storage doing wear-leveling, I'd certainly take
> the 64-bit block cipher.)  So far we haven't had to use Speck64 though, and if
> that continues to be the case I'd be fine with Speck64 being removed, leaving
> just Speck128.
>

I would very much prefer that to be the case. As many of us know,
"it's better than nothing" has been often used to justify other bad
choices, like RC4, that end up preventing better ones from being
adopted. At a time where we're trying to get rid of 64-bit ciphers in
TLS, where data volumes per session are comparatively low, it would be
unfortunate if the opposite starts happening on encryption at rest.

>
> Note that in practice, to have any chance at meeting the performance requirement
> the cipher needed to be NEON accelerated.  That made benchmarking really hard
> and time-consuming, since to definitely know how an algorithm performs it can
> take upwards of a week to implement a NEON version.  It needs to be very well
> optimized too, to compare the algorithms fairly -- e.g. with Speck I got a 20%
> performance improvement on some CPUs just by changing the NEON instructions used
> to implement the 8-bit rotates, an optimization that is not possible with
> ciphers that don't use rotate amounts that are multiples of 8.  (This was an
> intentional design choice by the Speck designers; they do know what they're
> doing, actually.)
>
> Thus, we had to be pretty aggressive about dropping algorithms from
> consideration if there were preliminary indications that they wouldn't perform
> well, or had too little cryptanalysis, or had other issues such as an unclear
> patent situation.  Threefish for example I did test the C implementation at
> https://github.com/wernerd/Skein3Fish, but on ARM32 it was over 4 times slower
> than my NEON implementation of Speck128/256-XTS.  And I did not see a clear way
> that it could be improved over 4x with NEON, if at all, so I did not take the
> long time it would have taken to write an optimized NEON implementation to
> benchmark it properly.  Perhaps that was a mistake.  But, time is not unlimited.
>

In my limited experience with NEON and 64-bit ARX, there's usually a
~2x speedup solely from NEON's native 64-bit operations on ARMv7-A.
The extra speedup from encrypting 2 block in parallel is then
somewhere between 1x and 2x, depending on various details. Getting
near 4x might be feasible, but it is indeed time-consuming to get
there.

>
> As for the wide-block mode using ChaCha20 and Poly1305, you'd have to ask Paul
> Crowley to explain it properly, but briefly it's actually a pseudorandom
> permutation over an arbitrarily-sized message.  So with dm-crypt for example, it
> would operate on a whole 512-byte sector, and if any bit of the 512-byte
> plaintext is changed, then every bit in the 512-byte ciphertext would change
> with 50% probability.  To make this possible, the construction uses a polynomial
> evalution in GF(2^130-5) as a universal hash function, similar to the Poly1305
> mode.
>

Oh, OK, that sounds like something resembling Naor-Reingold or its
relatives. That would work, but with 3 or 4 passes I guess it wouldn't
be very fast.

>
> Using ChaCha20's underlying 512-bit permutation to build a tweakable block
> cipher is an interesting idea.  But maybe in my crypto-naivety, it is not
> obvious to me how to do so.  Do you have references to any relevant papers?
> Remember that we strongly prefer a published cipher to a custom one -- even if
> the core is reused, a mistake may be made in the way it is used.  Thus,
> similarly to Paul's wide-block mode, I'd be concerned that we'd have to
> self-publish a new construction, then use it with no outside crypto review.
> *Maybe* it would be straightforward enough to be okay, but to know I'd need to
> see the details of how it would actually work.
>

This would be the 'tweakable Even-Mansour' construction and its
variants. The variant I'm most familiar with would be MEM [1],
focusing on software friendliness, but there is other provable
security work in the same vein, including [3, 4, 5]. It's very similar
to how the XEX mode turns a block cipher into a tweakable block
cipher.

In [1, 2] we used a 1024-bit permutation out of BLAKE2 instead of
ChaCha20's, but everything translates easily from one to the other. We
also included cheap masks for 512-bit permutations, just in case.

[1] https://eprint.iacr.org/2015/999
[2] https://github.com/MEM-AEAD/mem-aead
[3] https://eprint.iacr.org/2015/539
[4] https://eprint.iacr.org/2015/476
[5] https://competitions.cr.yp.to/round2/minalpherv11.pdf

>
> But in the end, Speck seemed like the clear choice because it had multiple NEON
> implementations available already which showed it could be implemented very
> efficiently in NEON; it has over 70 cryptanalysis papers (far more than most
> ciphers) yet the security margin is still similar to AES; it has no intellectual
> property concerns; there is a paper clearly explaining the design decisions; it
> is naturally resistant to timing attacks; it supports a 128-bit block size, so
> it can be easily used in XTS mode; it supports the same key sizes as AES; and it
> has a simple and understandable design with no "magic numbers" besides 8 and 3
> (compare to an actual backdoored algorithm like Dual_EC_DRGB, which basically
> had a public key embedded in the algorithm).  Also as Paul mentioned he is
> confident in the construction, and he has published cryptanalysis on Salsa20, so
> his opinion is probably more significant than mine :-)
>
> But I will definitely take a closer look at SPARX and some of the other ciphers
> you mentioned in case I missed something.  I really do appreciate the
> suggestions, by the way, and in any case we do need to be very well prepared to
> justify our choices.  I just hope that people can understand that we are
> implementing real-world crypto which must operate under *very* tight performance
> constraints on ARM processors, and it must be compatible with dm-crypt and
> fscrypt with no room for ciphertext expansion.  Thus, many algorithms which may
> at first seem reasonable choices had to (unfortunately) be excluded.
>

I understand it is a tough choice, and it's unfortunate that many of
the algorithms we have cater mostly to either the
high-hardware-accelerated-end or the extremely low-end, without a lot
of good options at the middle-end.

Best regards,
Samuel Neves
