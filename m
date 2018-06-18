Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pl0-f67.google.com ([209.85.160.67]:35007 "EHLO
        mail-pl0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755326AbeFRV5B (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 18 Jun 2018 17:57:01 -0400
Received: by mail-pl0-f67.google.com with SMTP id k1-v6so9773074plt.2
        for <linux-fscrypt@vger.kernel.org>; Mon, 18 Jun 2018 14:57:01 -0700 (PDT)
Date: Mon, 18 Jun 2018 14:56:57 -0700
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH v3 3/5] crypto: arm/speck - add NEON-accelerated
 implementation of Speck-XTS
Message-ID: <20180618215657.GB8022@google.com>
References: <20180214184223.254359-1-ebiggers@google.com>
 <20180214184223.254359-4-ebiggers@google.com>
 <bf0d6851c95b40ca970949229e6e6a00@agner.ch>
 <CAKv+Gu_VLcp7gxH-8OY-XoHyB=SKVRYRG5D3KV_fNQ4zn4hgFQ@mail.gmail.com>
 <CAKv+Gu-J9Ho8GY4EC7k_K3Wg4W_aC2kPryMD0e0SKY+biJOdDw@mail.gmail.com>
 <8396d433caf1155f9ca422c6bad3200b@agner.ch>
 <CAKv+Gu8OnTY7ezbkU5-EzVHp3vvPr_okkOoWfOjkdxhSqSqhBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu8OnTY7ezbkU5-EzVHp3vvPr_okkOoWfOjkdxhSqSqhBg@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Stefan Agner <stefan@agner.ch>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Jeffrey Walton <noloader@gmail.com>, Paul Crowley <paulcrowley@google.com>, Patrik Torstensson <totte@google.com>, Greg Kaiser <gkaiser@google.com>, Paul Lawrence <paullawrence@google.com>, Michael Halcrow <mhalcrow@google.com>, Alex Cope <alexcope@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-crypto-owner@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Jun 17, 2018 at 01:10:41PM +0200, Ard Biesheuvel wrote:
> >>>>> +
> >>>>> +     // One-time XTS preparation
> >>>>> +
> >>>>> +     /*
> >>>>> +      * Allocate stack space to store 128 bytes worth of tweaks.  For
> >>>>> +      * performance, this space is aligned to a 16-byte boundary so that we
> >>>>> +      * can use the load/store instructions that declare 16-byte alignment.
> >>>>> +      */
> >>>>> +     sub             sp, #128
> >>>>> +     bic             sp, #0xf
> >>>>
> >>>>
> >>>> This fails here when building with CONFIG_THUMB2_KERNEL=y
> >>>>
> >>>>   AS      arch/arm/crypto/speck-neon-core.o
> >>>>
> >>>> arch/arm/crypto/speck-neon-core.S: Assembler messages:
> >>>>
> >>>> arch/arm/crypto/speck-neon-core.S:419: Error: r13 not allowed here --
> >>>> `bic sp,#0xf'
> >>>> arch/arm/crypto/speck-neon-core.S:423: Error: r13 not allowed here --
> >>>> `bic sp,#0xf'
> >>>> arch/arm/crypto/speck-neon-core.S:427: Error: r13 not allowed here --
> >>>> `bic sp,#0xf'
> >>>> arch/arm/crypto/speck-neon-core.S:431: Error: r13 not allowed here --
> >>>> `bic sp,#0xf'
> >>>>
> >>>> In a quick hack this change seems to address it:
> >>>>
> >>>>
> >>>> -       sub             sp, #128
> >>>> -       bic             sp, #0xf
> >>>> +       mov             r6, sp
> >>>> +       sub             r6, #128
> >>>> +       bic             r6, #0xf
> >>>> +       mov             sp, r6
> >>>>
> >>>> But there is probably a better solution to address this.
> >>>>
> >>>
> >>> Given that there is no NEON on M class cores, I recommend we put something like
> >>>
> >>> THUMB(bx pc)
> >>> THUMB(nop.w)
> >>> THUMB(.arm)
> >>>
> >>> at the beginning and be done with it.
> >>
> >> I mean nop.n or just nop, of course, and we may need a '.align 2' at
> >> the beginning as well.
> >
> > Wouldn't it be preferable to have it assemble it in Thumb2 too? It seems
> > that bic sp,#0xf is the only issue...
> >
> 
> Well, in general, yes. In the case of NEON code, not really, since the
> resulting code will not be smaller anyway, because the Thumb2 NEON
> opcodes are all 4 bytes. Also, Thumb2-only cores don't have NEON
> units, so all cores that this code can run on will be able to run in
> ARM mode.
> 
> So from a maintainability pov, having code that only assembles in one
> way is better than having code that must compile both to ARM and to
> Thumb2 opcodes.
> 
> Just my 2 cents, anyway.

I don't have too much of a preference, though Stefan's suggested 4 instructions
can be reduced to 3, which also matches what aes-neonbs-core.S does:

        sub             r12, sp, #128
        bic             r12, #0xf
        mov             sp, r12

Ard, is the following what you're suggesting instead?

diff --git a/arch/arm/crypto/speck-neon-core.S b/arch/arm/crypto/speck-neon-core.S
index 3c1e203e53b9..c989ce3dc057 100644
--- a/arch/arm/crypto/speck-neon-core.S
+++ b/arch/arm/crypto/speck-neon-core.S
@@ -8,6 +8,7 @@
  */
 
 #include <linux/linkage.h>
+#include <asm/assembler.h>
 
 	.text
 	.fpu		neon
@@ -233,6 +234,12 @@
  * nonzero multiple of 128.
  */
 .macro _speck_xts_crypt	n, decrypting
+
+	.align		2
+	THUMB(bx pc)
+	THUMB(nop)
+	THUMB(.arm)
+
 	push		{r4-r7}
 	mov		r7, sp
 
@@ -413,6 +420,8 @@
 	mov		sp, r7
 	pop		{r4-r7}
 	bx		lr
+
+	THUMB(.thumb)
 .endm
 
 ENTRY(speck128_xts_encrypt_neon)
