Return-Path: <SRS0=L+OM=NK=gondor.apana.org.au=herbert@kernel.org>
Date: Tue, 30 Oct 2018 19:17:24 +1100
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v2 11/12] crypto: adiantum - add Adiantum support
Message-ID: <20181030081724.GA2730@gondor.apana.org.au>
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <20181015175424.97147-12-ebiggers@kernel.org>
 <CAKv+Gu9wrOOk-LGPYmxgLbv86uXzMeHN6th3mMEDT3Vg893HWw@mail.gmail.com>
 <20181020071206.GE876@sol.localdomain>
 <CAKv+Gu9zBKK7ughbBAKkHdfgX2KrBXkF6MhH3xrSdLegrjjYJQ@mail.gmail.com>
 <20181024220614.GA13497@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024220614.GA13497@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Oct 24, 2018 at 03:06:17PM -0700, Eric Biggers wrote:
>
> The patch I've been using just exposes a file /proc/cryptobench (note: it maybe
> should be made into a char device instead) to which you can write commands like:
> 
> 	algtype=skcipher algname=adiantum(xchacha12,aes) keysize=32 bufsize=4096 niter=1000
> 
> Then userspace reads back the result:
> 
> 	SUCCESS algname=adiantum(xchacha12,aes) driver_name=adiantum(xchacha12-software,aes-aesni,nhpoly1305-generic) measurement=0x30a5abd5776e0af enc_time=44831104 dec_time=38303077
> 
> It's then pretty straightforward to wrap this API in a userspace script that
> does all the benchmarks you need, and formats the results nicely.
> 
> For correctness testing there's also an option 'sgl_fuzz' that randomizes the
> scatterlist division.
> 
> Currently the patch is missing some features such as AEAD support, but at some
> point I'd like to get it into a state where it can be included upstream.

I completely agree that a new interface would be much better for
tcrypt.

However, we're trying to avoid using /proc for new APIs.  So perhaps
netlink would be a better choice given the existing configuration and
stats APIs that already exist for it.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
