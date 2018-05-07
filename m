Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Mon, 7 May 2018 16:20:00 -0700
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH v2 0/5] crypto: Speck support
Message-ID: <20180507232000.GA194688@google.com>
References: <20180212235209.117393-1-ebiggers@google.com>
 <CAHmME9oA4j=iGrrBYME92JfUsyi5r42PnAvzWiuXzGCRXMnXtA@mail.gmail.com>
 <20180424181623.GA174675@google.com>
 <CAHmME9qG+nPmj5c7hU4+STUsmWmwSBsKe-0mOLEXH+hJ1z4z=g@mail.gmail.com>
 <20180424224734.GA109345@google.com>
 <CAEX_ruHB7=zUuAWvbC9f6pDNhA4B32PGEkHi3QnPjRmRknrJ7w@mail.gmail.com>
 <20180425194919.GA79662@google.com>
 <CAEX_ruHoVRnBPazLhi6c+ps52yjb_SW=VfwxjiAW8izjvs24uQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEX_ruHoVRnBPazLhi6c+ps52yjb_SW=VfwxjiAW8izjvs24uQ@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Samuel Neves <samuel.c.p.neves@gmail.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, tashur@esat.kuleuven.be
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Samuel,

On Thu, Apr 26, 2018 at 03:05:44AM +0100, Samuel Neves wrote:
> On Wed, Apr 25, 2018 at 8:49 PM, Eric Biggers <ebiggers@google.com> wrote:
> > I agree that my explanation should have been better, and should have considered
> > more crypto algorithms.  The main difficulty is that we have extreme performance
> > requirements -- it needs to be 50 MB/s at the very least on even low-end ARM
> > devices like smartwatches.  And even with the NEON-accelerated Speck128-XTS
> > performance exceeding that after much optimization, we've been getting a lot of
> > pushback as people want closer to 100 MB/s.
> >
> 
> I couldn't find any NEON-capable ARMv7 chip below 800 MHz, so this
> would put the performance upper bound around 15 cycles per byte, with
> the comfortable number being ~7. That's indeed tough, though not
> impossible.
> 
> >
> > That's why I also included Speck64-XTS in the patches, since it was
> > straightforward to include, and some devices may really need that last 20-30% of
> > performance for encryption to be feasible at all.  (And when the choice is
> > between unencrypted and a 64-bit block cipher, used in a context where the
> > weakest points in the cryptosystem are actually elsewhere such as the user's
> > low-entropy PIN and the flash storage doing wear-leveling, I'd certainly take
> > the 64-bit block cipher.)  So far we haven't had to use Speck64 though, and if
> > that continues to be the case I'd be fine with Speck64 being removed, leaving
> > just Speck128.
> >
> 
> I would very much prefer that to be the case. As many of us know,
> "it's better than nothing" has been often used to justify other bad
> choices, like RC4, that end up preventing better ones from being
> adopted. At a time where we're trying to get rid of 64-bit ciphers in
> TLS, where data volumes per session are comparatively low, it would be
> unfortunate if the opposite starts happening on encryption at rest.
> 
> >
> > Note that in practice, to have any chance at meeting the performance requirement
> > the cipher needed to be NEON accelerated.  That made benchmarking really hard
> > and time-consuming, since to definitely know how an algorithm performs it can
> > take upwards of a week to implement a NEON version.  It needs to be very well
> > optimized too, to compare the algorithms fairly -- e.g. with Speck I got a 20%
> > performance improvement on some CPUs just by changing the NEON instructions used
> > to implement the 8-bit rotates, an optimization that is not possible with
> > ciphers that don't use rotate amounts that are multiples of 8.  (This was an
> > intentional design choice by the Speck designers; they do know what they're
> > doing, actually.)
> >
> > Thus, we had to be pretty aggressive about dropping algorithms from
> > consideration if there were preliminary indications that they wouldn't perform
> > well, or had too little cryptanalysis, or had other issues such as an unclear
> > patent situation.  Threefish for example I did test the C implementation at
> > https://github.com/wernerd/Skein3Fish, but on ARM32 it was over 4 times slower
> > than my NEON implementation of Speck128/256-XTS.  And I did not see a clear way
> > that it could be improved over 4x with NEON, if at all, so I did not take the
> > long time it would have taken to write an optimized NEON implementation to
> > benchmark it properly.  Perhaps that was a mistake.  But, time is not unlimited.
> >
> 
> In my limited experience with NEON and 64-bit ARX, there's usually a
> ~2x speedup solely from NEON's native 64-bit operations on ARMv7-A.
> The extra speedup from encrypting 2 block in parallel is then
> somewhere between 1x and 2x, depending on various details. Getting
> near 4x might be feasible, but it is indeed time-consuming to get
> there.
> 
> >
> > As for the wide-block mode using ChaCha20 and Poly1305, you'd have to ask Paul
> > Crowley to explain it properly, but briefly it's actually a pseudorandom
> > permutation over an arbitrarily-sized message.  So with dm-crypt for example, it
> > would operate on a whole 512-byte sector, and if any bit of the 512-byte
> > plaintext is changed, then every bit in the 512-byte ciphertext would change
> > with 50% probability.  To make this possible, the construction uses a polynomial
> > evalution in GF(2^130-5) as a universal hash function, similar to the Poly1305
> > mode.
> >
> 
> Oh, OK, that sounds like something resembling Naor-Reingold or its
> relatives. That would work, but with 3 or 4 passes I guess it wouldn't
> be very fast.
> 
> >
> > Using ChaCha20's underlying 512-bit permutation to build a tweakable block
> > cipher is an interesting idea.  But maybe in my crypto-naivety, it is not
> > obvious to me how to do so.  Do you have references to any relevant papers?
> > Remember that we strongly prefer a published cipher to a custom one -- even if
> > the core is reused, a mistake may be made in the way it is used.  Thus,
> > similarly to Paul's wide-block mode, I'd be concerned that we'd have to
> > self-publish a new construction, then use it with no outside crypto review.
> > *Maybe* it would be straightforward enough to be okay, but to know I'd need to
> > see the details of how it would actually work.
> >
> 
> This would be the 'tweakable Even-Mansour' construction and its
> variants. The variant I'm most familiar with would be MEM [1],
> focusing on software friendliness, but there is other provable
> security work in the same vein, including [3, 4, 5]. It's very similar
> to how the XEX mode turns a block cipher into a tweakable block
> cipher.
> 
> In [1, 2] we used a 1024-bit permutation out of BLAKE2 instead of
> ChaCha20's, but everything translates easily from one to the other. We
> also included cheap masks for 512-bit permutations, just in case.
> 
> [1] https://eprint.iacr.org/2015/999
> [2] https://github.com/MEM-AEAD/mem-aead
> [3] https://eprint.iacr.org/2015/539
> [4] https://eprint.iacr.org/2015/476
> [5] https://competitions.cr.yp.to/round2/minalpherv11.pdf
> 
> >
> > But in the end, Speck seemed like the clear choice because it had multiple NEON
> > implementations available already which showed it could be implemented very
> > efficiently in NEON; it has over 70 cryptanalysis papers (far more than most
> > ciphers) yet the security margin is still similar to AES; it has no intellectual
> > property concerns; there is a paper clearly explaining the design decisions; it
> > is naturally resistant to timing attacks; it supports a 128-bit block size, so
> > it can be easily used in XTS mode; it supports the same key sizes as AES; and it
> > has a simple and understandable design with no "magic numbers" besides 8 and 3
> > (compare to an actual backdoored algorithm like Dual_EC_DRGB, which basically
> > had a public key embedded in the algorithm).  Also as Paul mentioned he is
> > confident in the construction, and he has published cryptanalysis on Salsa20, so
> > his opinion is probably more significant than mine :-)
> >
> > But I will definitely take a closer look at SPARX and some of the other ciphers
> > you mentioned in case I missed something.  I really do appreciate the
> > suggestions, by the way, and in any case we do need to be very well prepared to
> > justify our choices.  I just hope that people can understand that we are
> > implementing real-world crypto which must operate under *very* tight performance
> > constraints on ARM processors, and it must be compatible with dm-crypt and
> > fscrypt with no room for ciphertext expansion.  Thus, many algorithms which may
> > at first seem reasonable choices had to (unfortunately) be excluded.
> >
> 
> I understand it is a tough choice, and it's unfortunate that many of
> the algorithms we have cater mostly to either the
> high-hardware-accelerated-end or the extremely low-end, without a lot
> of good options at the middle-end.
> 

First, we're planning a publication which explains our choices in more detail,
so please treat this as some more preliminary notes.

To make sure we've exhausted as many alternatives as possible, I wrote NEON
implementations of all the block ciphers you suggested with the exception of
SKINNY (which looked very hardware-oriented and not efficient in software), as
well as some that others have suggested.  (It was tough, but after doing a
couple, it got much easier...)  The following shows the decryption performance
I'm getting on an ARMv7 platform.  Encryption speeds were usually similar, but
in our use case we care much more about decryption, as that affects the most
critical metrics such as the time to launch applications.

	ChaCha8-MEM: 183256 KB/s
	ChaCha12-MEM: 134833 KB/s
	Chaskey-LTS-XTS: 99097 KB/s
	ChaCha20-MEM: 87875 KB/s
	Speck64/128-XTS: 85332 KB/s
	Speck128/128-XTS: 73404 KB/s
	RC5-128/12/256-XTS: 69887 KB/s
	Speck128/256-XTS: 69597 KB/s
	RC5-64/12/128-XTS: 69267 KB/s
	LEA-128-XTS: 67986 KB/s
	CHAM128/128-XTS: 52982 KB/s
	LEA-256-XTS: 50429 KB/s
	Threefish-256: 48349 KB/s
	RC6-XTS: 46855 KB/s
	RC5-128/20/256-XTS: 44291 KB/s
	RC5-64/20/128-XTS: 43924 KB/s
	NOEKEON-XTS: 40705 KB/s
	Sparx128/128-XTS: 39191 KB/s
	XTEA-XTS: 38239 KB/s
	AES-128-XTS: 25549 KB/s
	AES-256-XTS: 18640 KB/s

Remember that for dm-crypt or fscrypt over flash storage and/or f2fs, a stream
cipher is insecure.  Moreover, on these (low-end) devices the status quo is no
encryption, and we need every bit of performance available.  Anything below
50 MB/s is definitely unacceptable.  But even at that speed we get many
complaints, so in practice we need something faster.  That means that the
algorithms close to 50 MB/s, such as Threefish, still aren't fast enough.

ChaCha-MEM (based roughly on your paper: https://eprint.iacr.org/2015/999), has
the best performance, especially if we allow for the 12 or 8-round variants.  My
code for it is based roughly on the existing
arch/arm/crypto/chacha20-neon-core.S, but updated to support the inverse
permutation (on 4 blocks at a time, using all 16 NEON registers) and do the
masking required by MEM.  However, ChaCha-MEM would be a pretty bleeding-edge
and customized construction, and Paul Crowley and I have concerns about its
security.  The problem is that the MEM security proof assumes that the
underlying permutation has no more detectable structural properties than a
randomly selected permutation.  However, the ChaCha permutation is known to have
certain symmetries, e.g. if the sixteen 32-bit words are (a, a, a, a, b, b, b,
b, c, c, c, c, d, d, d, d), then they always map to some (e, e, e, e, f, f, f,
f, g, g, g, g, h, h, h, h).

For the MEM mask generation, we can use the "expand 32-byte k" constant to break
the symmetry, like is done in the ChaCha stream cipher.  However, that's not
possible for the inner application of the permutation.  So, we'd be using the
ChaCha permutation in a manner in which it wasn't intended, and the security of
the ChaCha stream cipher wouldn't directly carry over.  Granted, it's not
impossible that it would be secure, but at the present time it doesn't seem like
a good choice to actually field.

Chaskey-LTS is faster than Speck, but unfortunately it's not really a viable
option because it has only a 64-bit security level, due to its use of the
Even-Mansour construction with a 128-bit key.  Of course, it would still be
better than nothing, but we prefer a cipher that has a security level in line
with what is accepted for modern crypto.

RC5 with the traditional 12 rounds is about as fast as Speck, but there is a
known differential attack on that number of rounds.  So if we choose RC5 we'd
almost certainly have to use the 20-round variant, which is much slower.

That leaves LEA-128-XTS as the only other algorithm that might meet the
performance requirement, as it is only slightly slower than Speck128-XTS.  It
may be the most viable alternative, but beyond the slight performance loss it
still has some disadvantages compared to Speck:

- Importantly, the LEA authors forgot to include test vectors, so I'm not yet
  100% sure I implemented it correctly.  (The Speck authors unfortunately didn't
  make the endianness of their test vectors clear in their initial publication,
  but at least they actually provided test vectors!)
- LEA has received some cryptanalysis, but not nearly as much as Speck.
- It took some very heavy optimization to get good LEA performance, much more
  than I had to do for Speck.  My final LEA code has separate code paths for
  128-bit and 256-bit keys, and has reordered and preprocessed the round keys,
  and reordered the operations.  As a result, it's harder to see how it maps to
  the original paper.  In contrast, my Speck code is more straightforward and
  maintainable.
- LEA-256 (256-bit key) is much slower than LEA-128 (128-bit key), as it has
  33% more rounds.  LEA-256 would not be fast enough, so we would have to use
  LEA-128.  In contrast, with Speck we can use Speck128/256 (256-bit key).
  We're willing to accept a 128-bit security level, but 256-bit is preferable.
  (I think the Speck designers took a more informed approach to setting
  appropriate security margins for a lightweight cipher; it seems that other
  designers often choose too few or too many rounds, especially as the key
  length is varied.)
- LEA encryption is also a bit slower than decryption, while with Speck
  encryption and decryption are almost exactly the same speed.

Note that like Speck, LEA doesn't appear to be approved by a standards
organization either; it's just specified in a research paper.

Thus, from a technical perspective, and given the current state of the art in
lightweight cryptography, currently Speck128-XTS seems to be the best choice for
the problem domain.  It's unfortunate that there are so few good options and
that the field is so politicized, but it is what it is.

Still, we don't want to abandon HPolyC (Paul's new ChaCha and Poly1305-based
wide-block mode), and eventually we hope to offer it as an option as well.  But
it's not yet published, and it's a more complex algorithm that is harder to
implement so I haven't yet had a chance to implement and benchmark it.  And we
don't want to continue to leave users unprotected while we spend a long time
coming up with the perfect algorithm, or for hardware AES support to arrive to
all low-end CPUs when it's unclear if/when that will happen.

Again, we're planning a publication which will explain all this in more detail.

Thanks!

Eric
