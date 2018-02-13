Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pl0-f66.google.com ([209.85.160.66]:45088 "EHLO
        mail-pl0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965509AbeBMS5i (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 13 Feb 2018 13:57:38 -0500
Received: by mail-pl0-f66.google.com with SMTP id p5so7060242plo.12
        for <linux-fscrypt@vger.kernel.org>; Tue, 13 Feb 2018 10:57:38 -0800 (PST)
Date: Tue, 13 Feb 2018 10:57:35 -0800
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH v2 3/5] crypto: arm/speck - add NEON-accelerated
 implementation of Speck-XTS
Message-ID: <20180213185735.GA243817@google.com>
References: <20180212235209.117393-1-ebiggers@google.com>
 <20180212235209.117393-4-ebiggers@google.com>
 <CAKv+Gu83C_AsxrL_PzJowTUeE=ba8PBHT6NmiWjVghtJM7p_nw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu83C_AsxrL_PzJowTUeE=ba8PBHT6NmiWjVghtJM7p_nw@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ard,

On Tue, Feb 13, 2018 at 11:34:36AM +0000, Ard Biesheuvel wrote:
> Hi Eric,
> 
> On 12 February 2018 at 23:52, Eric Biggers <ebiggers@google.com> wrote:
> > Add an ARM NEON-accelerated implementation of Speck-XTS.  It operates on
> > 128-byte chunks at a time, i.e. 8 blocks for Speck128 or 16 blocks for
> > Speck64.  Each 128-byte chunk goes through XTS preprocessing, then is
> > encrypted/decrypted (doing one cipher round for all the blocks, then the
> > next round, etc.), then goes through XTS postprocessing.
> >
> > The performance depends on the processor but can be about 3 times faster
> > than the generic code.  For example, on an ARMv7 processor we observe
> > the following performance with Speck128/256-XTS:
> >
> >     xts-speck128-neon:     Encryption 107.9 MB/s, Decryption 108.1 MB/s
> >     xts(speck128-generic): Encryption  32.1 MB/s, Decryption  36.6 MB/s
> >
> > In comparison to AES-256-XTS without the Cryptography Extensions:
> >
> >     xts-aes-neonbs:        Encryption  41.2 MB/s, Decryption  36.7 MB/s
> >     xts(aes-asm):          Encryption  31.7 MB/s, Decryption  30.8 MB/s
> >     xts(aes-generic):      Encryption  21.2 MB/s, Decryption  20.9 MB/s
> >
> > Speck64/128-XTS is even faster:
> >
> >     xts-speck64-neon:      Encryption 138.6 MB/s, Decryption 139.1 MB/s
> >
> > Note that as with the generic code, only the Speck128 and Speck64
> > variants are supported.  Also, for now only the XTS mode of operation is
> > supported, to target the disk and file encryption use cases.  The NEON
> > code also only handles the portion of the data that is evenly divisible
> > into 128-byte chunks, with any remainder handled by a C fallback.  Of
> > course, other modes of operation could be added later if needed, and/or
> > the NEON code could be updated to handle other buffer sizes.
> >
> > The XTS specification is only defined for AES which has a 128-bit block
> > size, so for the GF(2^64) math needed for Speck64-XTS we use the
> > reducing polynomial 'x^64 + x^4 + x^3 + x + 1' given by the original XEX
> > paper.  Of course, when possible users should use Speck128-XTS, but even
> > that may be too slow on some processors; Speck64-XTS can be faster.
> >
> 
> I think this is excellent work. Speck seems an appropriate solution to
> this problem, and I'm glad we are not ending up with a stream cipher
> for block encryption.
> 
> Also, I think an arm64 port would be nice. I may take a stab at this
> if nobody else beats me to it.

We don't really want to encourage people to use Speck over AES with the
Cryptography Extensions, so that's why I didn't include an arm64 port.  That
being said, I suppose we can't stop people from adding an arm64 port if they
really do prefer Speck, or maybe for use on arm64 CPUs that don't have the
Cryptography Extensions (though I thought that almost all do).

> 
> I did run into an issue with this code though: On big-endian, I get
> 
> [    0.272381] alg: skcipher: Test 1 failed (invalid result) on
> encryption for xts-speck64-neon
> [    0.276151] 00000000: 84 af 54 07 19 d4 7c a6 9c 8a ac f6 c2 14 04 d8
> [    0.278541] 00000010: 7f 18 6c 43 56 ed 0b b3 92 21 a2 d9 17 59 e4 3b
> 
> so there may be a byte order corner case you missed in the rewrite (or
> the issue existed before, as I did not test your v1)
> 

To be honest I haven't tested either version on a big endian ARM CPU yet.  I
don't really know how to do that currently; maybe it's possible with QEMU.

But assuming I haven't missed anything, in the assembly code everything is
treated as byte arrays with the exception of the round keys which are 32-bit or
64-bit numbers in CPU endianness.  The byte arrays are loaded and stored with
vld1.8 and vst1.8 while the round keys are loaded with vld1.32 or vld1.64, so
the assembly code *should* work correctly on a big endian CPU.

However, looking over it now, I think there is a bug in the glue code for
Speck64-XTS when it handles buffers not evenly divisible into 128 bytes.
Namely, the tweak is treated as CPU endian when it should be little endian.
Could you try the following patch?

diff --git a/arch/arm/crypto/speck-neon-glue.c b/arch/arm/crypto/speck-neon-glue.c
index 3987dd6e063e..960cc634b36f 100644
--- a/arch/arm/crypto/speck-neon-glue.c
+++ b/arch/arm/crypto/speck-neon-glue.c
@@ -157,7 +157,7 @@ __speck64_xts_crypt(struct skcipher_request *req, speck64_crypt_one_t crypt_one,
 	struct crypto_skcipher *tfm = crypto_skcipher_reqtfm(req);
 	const struct speck64_xts_tfm_ctx *ctx = crypto_skcipher_ctx(tfm);
 	struct skcipher_walk walk;
-	u64 tweak;
+	__le64 tweak;
 	int err;
 
 	err = skcipher_walk_virt(&walk, req, true);
@@ -184,16 +184,16 @@ __speck64_xts_crypt(struct skcipher_request *req, speck64_crypt_one_t crypt_one,
 		}
 
 		/* Handle any remainder with generic code */
-		while (nbytes >= sizeof(u64)) {
-			*(u64 *)dst = *(u64 *)src ^ tweak;
+		while (nbytes >= sizeof(__le64)) {
+			*(__le64 *)dst = *(__le64 *)src ^ tweak;
 			(*crypt_one)(&ctx->main_key, dst, dst);
-			*(u64 *)dst ^= tweak;
-			tweak = (tweak << 1) ^
-				((tweak & (1ULL << 63)) ? 0x1B : 0);
-
-			dst += sizeof(u64);
-			src += sizeof(u64);
-			nbytes -= sizeof(u64);
+			*(__le64 *)dst ^= tweak;
+			tweak = cpu_to_le64((le64_to_cpu(tweak) << 1) ^
+					    ((tweak & cpu_to_le64(1ULL << 63)) ?
+					     0x1B : 0));
+			dst += sizeof(__le64);
+			src += sizeof(__le64);
+			nbytes -= sizeof(__le64);
 		}
 		err = skcipher_walk_done(&walk, nbytes);
 	}
