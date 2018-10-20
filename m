Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Fri, 19 Oct 2018 22:22:16 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
Message-ID: <20181020052215.GA876@sol.localdomain>
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <CA+_SqcDszvqfH7qvEyi8QW2RqkA1kpV6L7VWxhtw5Ogzeovhbg@mail.gmail.com>
 <CAKv+Gu9be0LDSzkinzwJ50LN+g7Omdjh5Z7xUmpoQc+oCzxZ_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu9be0LDSzkinzwJ50LN+g7Omdjh5Z7xUmpoQc+oCzxZ_Q@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Paul Crowley <paulcrowley@google.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Ard,

On Sat, Oct 20, 2018 at 11:24:05AM +0800, Ard Biesheuvel wrote:
> On 20 October 2018 at 02:19, Paul Crowley <paulcrowley@google.com> wrote:
> > On Fri, 19 Oct 2018 at 08:58, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> >> Before merging this into the kernel, do you want to wait until you've
> >> received some public review from academia?
> >
> > I would prefer not to wait. Unlike a new primitive whose strength can
> > only be known through attempts at cryptanalysis, Adiantum is a
> > construction based on
> > well-understood and trusted primitives; it is secure if the proof
> > accompanying it is correct. Given that (outside competitions or
> > standardization efforts) no-one ever issues public statements that
> > they think algorithms or proofs are good, what I'm expecting from
> > academia is silence :) The most we could hope for would be getting the
> > paper accepted at a conference, and we're pursuing that but there's a
> > good chance that won't happen simply because it's not very novel. It
> > basically takes existing ideas and applies them using a stream cipher
> > instead of a block cipher, and a faster hashing mode; it's also a
> > small update from HPolyC. I've had some private feedback that the
> > proof seems correct, and that's all I'm expecting to get.
> 
> Hi Paul, Eric,
> 
> The Adiantum paper claims
> 
> "On an ARM Cortex-A7 processor, Adiantum decrypts 4096-byte messages
> at 11 cycles per byte, five times faster than AES-256-XTS, with a
> constant-time implementation."
> 
> which is surprising to me. The bit slicing NEON AES core runs at ~14
> cycle per byte on a Cortex-A15 (when encrypting), so 55 cycles per
> byte on A7 sounds rather high. Is it really that bad?

Yes, it's really that slow, maybe because the NEON unit on Cortex-A7 isn't very
good.  Our figures are shown in the performance table in section 4.  Note that
the abstract is talking about AES-256-XTS.  AES-128-XTS is ~27% faster.  You can
also reproduce our performance results using our userspace benchmark program
from https://github.com/google/adiantum/tree/master/benchmark.  It uses a copy
of aes-neonbs-core.S from the kernel source tree.

> 
> Also, the paper mentions that the second hash pass and the stream
> cipher en/decryption pass could be executed in parallel, while your
> implementation performs three distinct passes. Do you have any
> estimates on the potential performance gain of implementing that? In
> my experience (which is mostly A53 rather than A7 based, mind you),
> removing memory accesses can help tremendously to speed up the
> execution on low end cores.

As a quick hack, on Cortex-A7 I timed "NH" without loading the message words.
It became about 10% faster.  My NEON-accelerated NH is already only about 1.3
cpb, so that means in theory not having to reload the message words would save
~0.13 cpb...  But Adiantum as a whole is ~11 cpb, so that suggests the
improvement would be only a bit over 1%.

Maybe it could actually be better (for example, not having to map the pages
again could save a lot), but in practice considering the increased complexity as
well as that probably there wouldn't actually be enough registers to do
everything efficiently, it seemed it would cause far too much trouble to bother
yet (at least for the Linux kernel implementation; a two-pass implementation
could still be useful elsewhere, of course).

- Eric
