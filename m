Return-Path: <SRS0=8uHw=N6=gmail.com=gmazyland@kernel.org>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <20181019190411.GB246441@gmail.com>
 <1f65ce09-93b3-f43e-49d5-9d9d6c0bb9e0@gmail.com>
 <20181116215249.GA27149@gmail.com>
 <56883f08-26cb-ecef-5698-1c2948714773@gmail.com>
 <20181119192821.GA258711@gmail.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <1e9ec59a-6a2c-3536-0722-c6d96d6714b2@gmail.com>
Date: Mon, 19 Nov 2018 21:05:18 +0100
MIME-Version: 1.0
In-Reply-To: <20181119192821.GA258711@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

On 19/11/2018 20:28, Eric Biggers wrote:
> Note that Adiantum benchmarks on x86 are misleading at the moment, since the
> initial kernel patchset doesn't include SSE2 and AVX2 optimized XChaCha and
> NHPoly1305.  To start, only C and arm32 NEON implementations are included.
> Hence, on x86 Adiantum will appear much slower than it should be.  But I'm
> planning to add the x86 and arm64 implementations, so it will get much faster.

The posted benchmark was just an example (it was 32bit virtual machine on my
old laptop so numbers are misleading).

If Adiantum is going to be merged, I expect it can be used as an alternative
even on x86, so I expect more optimizations.

...
> I think that when using AF_ALG, cryptsetup should get the IV size from
> /proc/crypto, or else have it hardcoded that "adiantum" uses 32-byte IVs.
> (Actually Adiantum can formally can use any size IV, but we had to choose a
> fixed size for Linux's crypto API.)

I do not want to parse /proc/crypto (it needs to load the module first anyway)
and proper API was not yet here when I wrote this code (I think we were the first
real user of userspace crypto api...)

> Getting the IV size via CRYPTO_MSG_GETALG via NETLINK_CRYPTO is also an option,
> but that requires the kconfig option CONFIG_CRYPTO_USER which isn't guaranteed
> to be enabled even if CONFIG_CRYPTO_USER_API_SKCIPHER is.

Yes. For now, I hardcode Adiantum IV size in cryptsetup and later we will try to
find a more generic way.

> Also: why is cryptsetup's default keyslot encryption AES-128-XTS instead of
> AES-256-XTS?  People can choose a cipher with a 256-bit key strength such as
> AES-256-XTS or Adiantum, so the keyslots should use at least that strength too.

It was inherited from 256bit default key (so 2xAES-128 in XTS).
It is still the default for LUKS1, but we should perhaps change it to double key
it for XTS mode (at least for fallback keyslot encryption).

Anyway, we will release cryptsetup 2.0.6 very soon to fix one problem
in LUKS2, so I'll add the Adiantum IV size there as well so people can play with it.

Thanks,
Milan

p.s.
Reading the discussion about Zinc/Adiantum - I would perhaps prefer to merge
Adiantum first (if it is ready).
It is a new feature, I see it as useful cipher alternative for dm-crypt and it can be
esily backported without Zinc to older kernels (I am testing it actually this way).
