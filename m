Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Mon, 22 Oct 2018 15:40:10 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH v2 09/12] crypto: nhpoly1305 - add NHPoly1305 support
Message-ID: <20181022224008.GB59695@gmail.com>
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <20181015175424.97147-10-ebiggers@kernel.org>
 <CAKv+Gu-5WM19g5HguDheAADbigKNxokDCFMekkt4OYdEEa8Avw@mail.gmail.com>
 <20181020053834.GC876@sol.localdomain>
 <CAKv+Gu-A_EhMBXq_nqzBzpgN36foo6hA3Ba3=j+WVM-jph=mrw@mail.gmail.com>
 <20181022184236.GA59695@gmail.com>
 <CAKv+Gu_vXmfNQT8j=G_Zz5C3-zDPPEQ2ne6ZZQw8mD0rifO8qA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu_vXmfNQT8j=G_Zz5C3-zDPPEQ2ne6ZZQw8mD0rifO8qA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ard,

On Mon, Oct 22, 2018 at 07:25:27PM -0300, Ard Biesheuvel wrote:
> >
> > Hmm, I'm actually leaning towards the following instead.  Unrolling multiple
> > strides to try to reduce loads of the keys doesn't seem worthwhile in the C
> > implementation; for one, it bloats the code size a lot
> > (412 => 2332 bytes on arm32).
> >
> > static void nh_generic(const u32 *key, const u8 *message, size_t message_len,
> >                        __le64 hash[NH_NUM_PASSES])
> > {
> >         u64 sums[4] = { 0, 0, 0, 0 };
> >
> >         BUILD_BUG_ON(NH_PAIR_STRIDE != 2);
> >         BUILD_BUG_ON(NH_NUM_PASSES != 4);
> >
> >         while (message_len) {
> >                 u32 m0 = get_unaligned_le32(message + 0);
> >                 u32 m1 = get_unaligned_le32(message + 4);
> >                 u32 m2 = get_unaligned_le32(message + 8);
> >                 u32 m3 = get_unaligned_le32(message + 12);
> >
> >                 sums[0] += (u64)(u32)(m0 + key[ 0]) * (u32)(m2 + key[ 2]);
> >                 sums[1] += (u64)(u32)(m0 + key[ 4]) * (u32)(m2 + key[ 6]);
> >                 sums[2] += (u64)(u32)(m0 + key[ 8]) * (u32)(m2 + key[10]);
> >                 sums[3] += (u64)(u32)(m0 + key[12]) * (u32)(m2 + key[14]);
> >                 sums[0] += (u64)(u32)(m1 + key[ 1]) * (u32)(m3 + key[ 3]);
> >                 sums[1] += (u64)(u32)(m1 + key[ 5]) * (u32)(m3 + key[ 7]);
> >                 sums[2] += (u64)(u32)(m1 + key[ 9]) * (u32)(m3 + key[11]);
> >                 sums[3] += (u64)(u32)(m1 + key[13]) * (u32)(m3 + key[15]);
> 
> Are these (u32) casts really necessary? All the addends are u32 types,
> so I'd expect each (x + y) subexpression to have a u32 type already as
> well. Or am I missing something?
> 

The (u32) casts are only necessary when sizeof(int) > sizeof(u32), as then the
addends will be promoted to 'int'.  Of course, that's never the case for the
Linux kernel.  But I prefer it to be as robust and well-defined as possible,
since people might use this as a reference when coding other implementations,
which could end up finding their way into unusual and/or future platforms.

- Eric
