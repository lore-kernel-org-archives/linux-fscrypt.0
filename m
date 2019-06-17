Return-Path: <SRS0=5CCC=UQ=gmail.com=gmazyland@kernel.org>
Subject: Re: [RFC PATCH 0/3] crypto: switch to shash for ESSIV generation
References: <20190614083404.20514-1-ard.biesheuvel@linaro.org>
 <20190616204419.GE923@sol.localdomain>
 <CAOtvUMf86_TGYLoAHWuRW0Jz2=cXbHHJnAsZhEvy6SpSp_xgOQ@mail.gmail.com>
 <CAKv+Gu_r_WXf2y=FVYHL-T8gFSV6e4TmGkLNJ-cw6UjK_s=A=g@mail.gmail.com>
 <8e58230a-cf0e-5a81-886b-6aa72a8e5265@gmail.com>
 <CAKv+Gu9sb0t6EC=MwVfqTw5TKtatK-c8k3ryNUhV8O0876NV7g@mail.gmail.com>
 <CAKv+Gu-LFShLW-Tt7hwBpni1vQRvv7k+L_bpP-wU86x88v+eRg@mail.gmail.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <90214c3d-55ef-cc3a-3a04-f200d6f96cfd@gmail.com>
Date: Mon, 17 Jun 2019 16:35:18 +0200
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu-LFShLW-Tt7hwBpni1vQRvv7k+L_bpP-wU86x88v+eRg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Eric Biggers <ebiggers@kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>
List-ID: <linux-fscrypt@vger.kernel.org>

On 17/06/2019 15:59, Ard Biesheuvel wrote:
> 
> So my main question/showstopper at the moment is: which modes do we
> need to support for ESSIV? Only CBC? Any skcipher? Or both skciphers
> and AEADs?

Support, or cover by internal test? I think you nee to support everything
what dmcrypt currently allows, if you want to port dmcrypt to new API.

I know of many systems that use aes-xts-essiv:sha256 (it does not make sense
much but people just use it).

Some people use serpent and twofish, but we allow any cipher that fits...

For the start, run this
https://gitlab.com/cryptsetup/cryptsetup/blob/master/tests/mode-test

In other words, if you add some additional limit, we are breaking backward compatibility.
(Despite the configuration is "wrong" from the security point of view.)

Milan
