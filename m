Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Wed, 25 Apr 2018 12:49:19 -0700
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH v2 0/5] crypto: Speck support
Message-ID: <20180425194919.GA79662@google.com>
References: <20180212235209.117393-1-ebiggers@google.com>
 <CAHmME9oA4j=iGrrBYME92JfUsyi5r42PnAvzWiuXzGCRXMnXtA@mail.gmail.com>
 <20180424181623.GA174675@google.com>
 <CAHmME9qG+nPmj5c7hU4+STUsmWmwSBsKe-0mOLEXH+hJ1z4z=g@mail.gmail.com>
 <20180424224734.GA109345@google.com>
 <CAEX_ruHB7=zUuAWvbC9f6pDNhA4B32PGEkHi3QnPjRmRknrJ7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEX_ruHB7=zUuAWvbC9f6pDNhA4B32PGEkHi3QnPjRmRknrJ7w@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Samuel Neves <samuel.c.p.neves@gmail.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tashur@esat.kuleuven.be
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Samuel,

On Wed, Apr 25, 2018 at 03:33:16PM +0100, Samuel Neves wrote:
> Let's put the provenance of Speck aside for a moment, and suppose that
> it is an ideal block cipher. There are still some issues with this
> patch as it stands.
> 
>  - The rationale seems off. Consider this bit from the commit message:
> 
> > Other AES alternatives such as Twofish, Threefish, Camellia, CAST6, and Serpent aren't
> > fast enough either; it seems that only a modern ARX cipher can provide sufficient performance
> > on these devices.
> 
> One of these things is very much not like the others. Threefish _is_ a
> modern ARX cipher---a tweakable block cipher in fact, precluding the
> need for XEX-style masking. Is it too slow? Does it not have the
> correct block size?
> 
> > We've also considered a novel length-preserving encryption mode based on
> > ChaCha20 and Poly1305.
> 
> I'm very curious about this, namely as to what the role of Poly1305
> would be here. ChaCha20's underlying permutation could, of course, be
> transformed into a 512-bit tweakable block cipher relatively
> painlessly, retaining the performance of regular ChaCha20 with
> marginal additional overhead. This would not be a standard
> construction, but clearly that is not an issue.
> 
> But the biggest problem here, in my mind, is that for all the talk of
> using 128-bit block Speck, this patch tacks on the 64-bit block
> variant of Speck into the kernel, and speck64-xts as well! As far as I
> can tell, this is the _only_ instance of a 64-bit XTS instance in the
> entire codebase. Now, if you wanted a fast 64-bit ARX block cipher,
> the kernel already had XTEA. Instead, this is adding yet another
> 64-bit block cipher into the crypto API, in a disk-encryption mode no
> less, so that it can be misused later. In the disk encryption setting,
> it's particularly concerning to be using such a small block size, as
> data volumes can quickly add up to the birthday bound.
> 
> > It's easy to say that, but do you have an actual suggestion?
> 
> I don't know how seriously you are actually asking this, but some
> 128-bit software-friendly block ciphers could be SPARX, LEA, RC5, or
> RC6. SPARX, in particular, has similarities to Speck but has some
> further AES-like design guarantees that other prior ARX block ciphers
> did not. Some other bitsliced designs, such as Noekeon or SKINNY, may
> also work well with NEON, but I don't know much about their
> performance there.
> 

I agree that my explanation should have been better, and should have considered
more crypto algorithms.  The main difficulty is that we have extreme performance
requirements -- it needs to be 50 MB/s at the very least on even low-end ARM
devices like smartwatches.  And even with the NEON-accelerated Speck128-XTS
performance exceeding that after much optimization, we've been getting a lot of
pushback as people want closer to 100 MB/s.

That's why I also included Speck64-XTS in the patches, since it was
straightforward to include, and some devices may really need that last 20-30% of
performance for encryption to be feasible at all.  (And when the choice is
between unencrypted and a 64-bit block cipher, used in a context where the
weakest points in the cryptosystem are actually elsewhere such as the user's
low-entropy PIN and the flash storage doing wear-leveling, I'd certainly take
the 64-bit block cipher.)  So far we haven't had to use Speck64 though, and if
that continues to be the case I'd be fine with Speck64 being removed, leaving
just Speck128.

Note that in practice, to have any chance at meeting the performance requirement
the cipher needed to be NEON accelerated.  That made benchmarking really hard
and time-consuming, since to definitely know how an algorithm performs it can
take upwards of a week to implement a NEON version.  It needs to be very well
optimized too, to compare the algorithms fairly -- e.g. with Speck I got a 20%
performance improvement on some CPUs just by changing the NEON instructions used
to implement the 8-bit rotates, an optimization that is not possible with
ciphers that don't use rotate amounts that are multiples of 8.  (This was an
intentional design choice by the Speck designers; they do know what they're
doing, actually.)

Thus, we had to be pretty aggressive about dropping algorithms from
consideration if there were preliminary indications that they wouldn't perform
well, or had too little cryptanalysis, or had other issues such as an unclear
patent situation.  Threefish for example I did test the C implementation at
https://github.com/wernerd/Skein3Fish, but on ARM32 it was over 4 times slower
than my NEON implementation of Speck128/256-XTS.  And I did not see a clear way
that it could be improved over 4x with NEON, if at all, so I did not take the
long time it would have taken to write an optimized NEON implementation to
benchmark it properly.  Perhaps that was a mistake.  But, time is not unlimited.

RC5 and RC6 use data-dependent rotates which won't perform too well on NEON,
also historically those algorithms have been patented.  It sounds like the last
patents expired last year, but we'd need to double check and be very sure that's
really the case.

As for the wide-block mode using ChaCha20 and Poly1305, you'd have to ask Paul
Crowley to explain it properly, but briefly it's actually a pseudorandom
permutation over an arbitrarily-sized message.  So with dm-crypt for example, it
would operate on a whole 512-byte sector, and if any bit of the 512-byte
plaintext is changed, then every bit in the 512-byte ciphertext would change
with 50% probability.  To make this possible, the construction uses a polynomial
evalution in GF(2^130-5) as a universal hash function, similar to the Poly1305
mode.

Using ChaCha20's underlying 512-bit permutation to build a tweakable block
cipher is an interesting idea.  But maybe in my crypto-naivety, it is not
obvious to me how to do so.  Do you have references to any relevant papers?
Remember that we strongly prefer a published cipher to a custom one -- even if
the core is reused, a mistake may be made in the way it is used.  Thus,
similarly to Paul's wide-block mode, I'd be concerned that we'd have to
self-publish a new construction, then use it with no outside crypto review.
*Maybe* it would be straightforward enough to be okay, but to know I'd need to
see the details of how it would actually work.

But in the end, Speck seemed like the clear choice because it had multiple NEON
implementations available already which showed it could be implemented very
efficiently in NEON; it has over 70 cryptanalysis papers (far more than most
ciphers) yet the security margin is still similar to AES; it has no intellectual
property concerns; there is a paper clearly explaining the design decisions; it
is naturally resistant to timing attacks; it supports a 128-bit block size, so
it can be easily used in XTS mode; it supports the same key sizes as AES; and it
has a simple and understandable design with no "magic numbers" besides 8 and 3
(compare to an actual backdoored algorithm like Dual_EC_DRGB, which basically
had a public key embedded in the algorithm).  Also as Paul mentioned he is
confident in the construction, and he has published cryptanalysis on Salsa20, so
his opinion is probably more significant than mine :-)

But I will definitely take a closer look at SPARX and some of the other ciphers
you mentioned in case I missed something.  I really do appreciate the
suggestions, by the way, and in any case we do need to be very well prepared to
justify our choices.  I just hope that people can understand that we are
implementing real-world crypto which must operate under *very* tight performance
constraints on ARM processors, and it must be compatible with dm-crypt and
fscrypt with no room for ciphertext expansion.  Thus, many algorithms which may
at first seem reasonable choices had to (unfortunately) be excluded.

Thanks!

Eric
