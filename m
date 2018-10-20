Return-Path: <SRS0=q1Ic=NA=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
In-Reply-To: <CA+_SqcDszvqfH7qvEyi8QW2RqkA1kpV6L7VWxhtw5Ogzeovhbg@mail.gmail.com>
References: <20181015175424.97147-1-ebiggers@kernel.org> <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <CA+_SqcDszvqfH7qvEyi8QW2RqkA1kpV6L7VWxhtw5Ogzeovhbg@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Sat, 20 Oct 2018 11:24:05 +0800
Message-ID: <CAKv+Gu9be0LDSzkinzwJ50LN+g7Omdjh5Z7xUmpoQc+oCzxZ_Q@mail.gmail.com>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
Content-Type: text/plain; charset="UTF-8"
To: Paul Crowley <paulcrowley@google.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On 20 October 2018 at 02:19, Paul Crowley <paulcrowley@google.com> wrote:
> On Fri, 19 Oct 2018 at 08:58, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>> Before merging this into the kernel, do you want to wait until you've
>> received some public review from academia?
>
> I would prefer not to wait. Unlike a new primitive whose strength can
> only be known through attempts at cryptanalysis, Adiantum is a
> construction based on
> well-understood and trusted primitives; it is secure if the proof
> accompanying it is correct. Given that (outside competitions or
> standardization efforts) no-one ever issues public statements that
> they think algorithms or proofs are good, what I'm expecting from
> academia is silence :) The most we could hope for would be getting the
> paper accepted at a conference, and we're pursuing that but there's a
> good chance that won't happen simply because it's not very novel. It
> basically takes existing ideas and applies them using a stream cipher
> instead of a block cipher, and a faster hashing mode; it's also a
> small update from HPolyC. I've had some private feedback that the
> proof seems correct, and that's all I'm expecting to get.

Hi Paul, Eric,

The Adiantum paper claims

"On an ARM Cortex-A7 processor, Adiantum decrypts 4096-byte messages
at 11 cycles per byte, five times faster than AES-256-XTS, with a
constant-time implementation."

which is surprising to me. The bit slicing NEON AES core runs at ~14
cycle per byte on a Cortex-A15 (when encrypting), so 55 cycles per
byte on A7 sounds rather high. Is it really that bad?

Also, the paper mentions that the second hash pass and the stream
cipher en/decryption pass could be executed in parallel, while your
implementation performs three distinct passes. Do you have any
estimates on the potential performance gain of implementing that? In
my experience (which is mostly A53 rather than A7 based, mind you),
removing memory accesses can help tremendously to speed up the
execution on low end cores.
