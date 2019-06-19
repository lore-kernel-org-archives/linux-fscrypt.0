Return-Path: <SRS0=91WR=US=linaro.org=ard.biesheuvel@kernel.org>
MIME-Version: 1.0
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
 <20190619162921.12509-7-ard.biesheuvel@linaro.org> <20190619223710.GC33328@gmail.com>
In-Reply-To: <20190619223710.GC33328@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 20 Jun 2019 00:43:50 +0200
Message-ID: <CAKv+Gu8_iPOA58xP+y-UvF7SPt86uYZZRb0Z9jEHo3d3Q6PhCg@mail.gmail.com>
Subject: Re: [PATCH v3 6/6] crypto: arm64/aes - implement accelerated
 ESSIV/CBC mode
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers@kernel.org>
Cc: "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, device-mapper development <dm-devel@redhat.com>, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, 20 Jun 2019 at 00:37, Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Wed, Jun 19, 2019 at 06:29:21PM +0200, Ard Biesheuvel wrote:
> > Add an accelerated version of the 'essiv(cbc(aes),aes,sha256)'
> > skcipher, which is used by fscrypt, and in some cases, by dm-crypt.
> > This avoids a separate call into the AES cipher for every invocation.
> >
> > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>
> I'm not sure we should bother with this, since fscrypt normally uses AES-256-XTS
> for contents encryption.  AES-128-CBC-ESSIV support was only added because
> people wanted something that is fast on low-powered embedded devices with crypto
> accelerators such as CAAM or CESA that don't support XTS.
>
> In the case of Android, the CDD doesn't even allow AES-128-CBC-ESSIV with
> file-based encryption (fscrypt).  It's still the default for "full disk
> encryption" (which uses dm-crypt), but that's being deprecated.
>
> So maybe dm-crypt users will want this, but I don't think it's very useful for
> fscrypt.
>

If nobody cares, we can drop it. I don't feel too strongly about this,
and since it is on the mailinglist now, people will be able to find it
and ask for it to be merged if they have a convincing use case.
