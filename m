Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:39538 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726261AbeJTPVf (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 20 Oct 2018 11:21:35 -0400
Date: Sat, 20 Oct 2018 00:12:07 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH v2 11/12] crypto: adiantum - add Adiantum support
Message-ID: <20181020071206.GE876@sol.localdomain>
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <20181015175424.97147-12-ebiggers@kernel.org>
 <CAKv+Gu9wrOOk-LGPYmxgLbv86uXzMeHN6th3mMEDT3Vg893HWw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAKv+Gu9wrOOk-LGPYmxgLbv86uXzMeHN6th3mMEDT3Vg893HWw@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ard,

On Sat, Oct 20, 2018 at 12:17:58PM +0800, Ard Biesheuvel wrote:
> On 16 October 2018 at 01:54, Eric Biggers <ebiggers@kernel.org> wrote:
> > From: Eric Biggers <ebiggers@google.com>
> >
> > Add support for the Adiantum encryption mode.  Adiantum was designed by
> > Paul Crowley and is specified by our paper:
> >
> >     Adiantum: length-preserving encryption for entry-level processors
> >     (https://eprint.iacr.org/2018/720.pdf)
> >
> > See our paper for full details; this patch only provides an overview.
> >
> > Adiantum is a tweakable, length-preserving encryption mode designed for
> > fast and secure disk encryption, especially on CPUs without dedicated
> > crypto instructions.  Adiantum encrypts each sector using the XChaCha12
> > stream cipher, two passes of an ε-almost-∆-universal (εA∆U) hash
> > function, and an invocation of the AES-256 block cipher on a single
> > 16-byte block.  On CPUs without AES instructions, Adiantum is much
> > faster than AES-XTS; for example, on ARM Cortex-A7, on 4096-byte sectors
> > Adiantum encryption is about 4 times faster than AES-256-XTS encryption,
> > and decryption about 5 times faster.
> >
> > Adiantum is a specialization of the more general HBSH construction.  Our
> > earlier proposal, HPolyC, was also a HBSH specialization, but it used a
> > different εA∆U hash function, one based on Poly1305 only.  Adiantum's
> > εA∆U hash function, which is based primarily on the "NH" hash function
> > like that used in UMAC (RFC4418), is about twice as fast as HPolyC's;
> > consequently, Adiantum is about 20% faster than HPolyC.
> >
> > This speed comes with no loss of security: Adiantum is provably just as
> > secure as HPolyC, in fact slightly *more* secure.  Like HPolyC,
> > Adiantum's security is reducible to that of XChaCha12 and AES-256,
> > subject to a security bound.  XChaCha12 itself has a security reduction
> > to ChaCha12.  Therefore, one need not "trust" Adiantum; one need only
> > trust ChaCha12 and AES-256.  Note that the εA∆U hash function is only
> > used for its proven combinatorical properties so cannot be "broken".
> >
> 
> So what happens if the part of the input covered by the block cipher
> is identical between different generations of the same disk block
> (whose sector count is used as the 'outer' IV). How are we not in the
> same boat as before when using stream ciphers for disk encryption?
> 

This is the point of the hash step.  The value encrypted with the block cipher
to produce the intermediate value C_M (used as the stream cipher nonce) is
H(T, P_L) + P_R.  (T is the tweak a.k.a the IV, P_L is the plaintext except the
last 16 bytes, P_R is the last 16 bytes.)  A collision in this value occurs iff:

	H(T1, P1_L) + P1_R = H(T2, P2_L) + P2_R
i.e.
	H(T1, P1_L) - H(T2, P2_L) = P2_R - P1_R
	
If (T1, P1_L) = (T2, P2_L) then P1_R != P2_R so the equation has no solutions
(since we don't consider queries where the whole input is the same; those
unavoidably produce the same ciphertext).  Otherwise (T1, P1_L) != (T2, P2_L),
and since the hash function H is ε-almost-∆-universal over integers mod 2^128,
the equation is true for at most a very small proportion 'ε' of hash keys.
But, the hash key is chosen at random and is unknown to the attacker.

The same applies in the other direction, for chosen ciphertext attacks.

Basically, it's very difficult for an attacker to cause the intermediate value
C_M to be reused, and the outputs will appear random until they do.

Of course, all this is explained much more precisely and comprehensively in our
paper.  See section 5, "Security reduction".

- Eric
