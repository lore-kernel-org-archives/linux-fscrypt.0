Return-Path: <SRS0=3REu=LF=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20180807231941.GC25300@gmail.com>
References: <20180806223300.113891-1-ebiggers@kernel.org> <20180806223300.113891-9-ebiggers@kernel.org>
 <CAKv+Gu_T+f=isb_dBF7icfTHApG+E8Y5njSQ=NmtyTHEN2VMgg@mail.gmail.com> <20180807231941.GC25300@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Wed, 22 Aug 2018 12:00:05 +0200
Message-ID: <CAKv+Gu8svYM+YdaJF+z2Q=ZYhfnLDybsiidz9UvevEaa=4U8TA@mail.gmail.com>
Subject: Re: [RFC PATCH 8/9] crypto: arm/poly1305 - add NEON accelerated
 Poly1305 implementation
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 8 August 2018 at 01:19, Eric Biggers <ebiggers@kernel.org> wrote:
> Hi Ard,
>
> On Tue, Aug 07, 2018 at 02:09:05PM +0200, Ard Biesheuvel wrote:
>> On 7 August 2018 at 00:32, Eric Biggers <ebiggers@kernel.org> wrote:
>> > From: Eric Biggers <ebiggers@google.com>
>> >
>> > Add the Poly1305 code from OpenSSL, which was written by Andy Polyakov.
>> > I took the .S file from WireGuard, whose author has made the needed
>> > tweaks for Linux kernel integration and verified that Andy had given
>> > permission for GPLv2 distribution.  I didn't make any additional changes
>> > to the .S file.
>> >
>> > Note, for HPolyC I'd eventually like a Poly1305 implementation that
>> > allows precomputing powers of the key.  But for now this implementation
>> > just provides the existing semantics where the key and nonce are treated
>> > as a "one-time key" that must be provided for every message.
>> >
>> > Signed-off-by: Eric Biggers <ebiggers@google.com>
>>
>> Hi Eric,
>>
>> In the past, I worked with Andy on several occasions to get my kernel
>> changes incorporated into the upstream OpenSSL version of the
>> 'perlasm' .pl file.
>>
>> This achieves a number of things:
>> - we get a readable version of the code in the kernel tree,
>> - our changes are reviewed upstream
>> - upgrading involves grabbing the latest .pl file rather than merging
>> generated code (which requires careful review)
>> - GPLv2 permission is made explicit, rather than something someone
>> claims to have reached agreement on,
>> - no legal ambiguity whether the output of the perl script is covered
>> by the license (which is what we incorporate here)
>>
>> Note that the 'available under GPL depending on where you obtained the
>> code' in the CRYPTOGAMS license likely conflicts with the GPL itself,
>> but I am not a lawyer so I'd much prefer having the upstream copy
>> mention this explicitly.
>
> First, note that Jason is proposing adding this exact same .S file as part of
> his new "zinc" cryptography library, along with 7 other OpenSSL .S files.  So it
> may really be him you need to convince.
>

Interesting choice of wording :-) I thought it was usually the other
way around, i.e., it is the submitter who needs to convince the
reviewers/maintainers.

> But yes, I don't really like the approach of just including the .S output of the
> .pl script either, as it loses semantic information that was in the .pl script.
> Ideally the source should either be the .pl script, or else a real hand written
> .S file with the proper comments and macros to make it readable -- not something
> in-between.
>
> Getting the license clarification and possibly other changes upstream is a good
> idea too.  I noticed, though, that the actual wording used in some files
> upstream ("Permission to use under GPLv2 terms is granted") apparently still
> isn't considered sufficient by some, so a separate clarification from Andy was
> apparently still needed: see kernel commit c2e415fe75bbc83c1...
>

Yeah. In any case, I don't think we should consider an intermediate
solution of merging a chunk of generated asm now and work out these
details later. This should be done right from the start.
