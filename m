Return-Path: <SRS0=gi0w=UQ=gondor.apana.org.au=herbert@kernel.org>
Date: Mon, 17 Jun 2019 17:20:13 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/3] crypto: switch to shash for ESSIV generation
Message-ID: <20190617092012.gk7wrazxh7bwfmjk@gondor.apana.org.au>
References: <20190614083404.20514-1-ard.biesheuvel@linaro.org>
 <20190616204419.GE923@sol.localdomain>
 <CAOtvUMf86_TGYLoAHWuRW0Jz2=cXbHHJnAsZhEvy6SpSp_xgOQ@mail.gmail.com>
 <CAKv+Gu_r_WXf2y=FVYHL-T8gFSV6e4TmGkLNJ-cw6UjK_s=A=g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu_r_WXf2y=FVYHL-T8gFSV6e4TmGkLNJ-cw6UjK_s=A=g@mail.gmail.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Eric Biggers <ebiggers@kernel.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Jun 17, 2019 at 11:15:01AM +0200, Ard Biesheuvel wrote:
>
> Ah yes, thanks for reminding me. There was some debate in the past
> about this, but I don't remember the details.

I think there were some controversy regarding whether the resulting
code lived in drivers/md or crypto.  I think as long as drivers/md
is the only user of the said code then having it in drivers/md should
be fine.

However, if we end up using/reusing the same code for others such as
fs/crypto then it might make more sense to have them in crypto.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
