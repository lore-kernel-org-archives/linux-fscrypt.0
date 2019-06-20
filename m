Return-Path: <SRS0=hJx/=UT=gmail.com=gmazyland@kernel.org>
Subject: Re: [PATCH v3 6/6] crypto: arm64/aes - implement accelerated
 ESSIV/CBC mode
References: <20190619162921.12509-1-ard.biesheuvel@linaro.org>
 <20190619162921.12509-7-ard.biesheuvel@linaro.org>
 <20190619223710.GC33328@gmail.com>
From: Milan Broz <gmazyland@gmail.com>
Message-ID: <ed3113fb-8f5f-7045-75ba-b63e4ed669ff@gmail.com>
Date: Thu, 20 Jun 2019 13:29:59 +0200
MIME-Version: 1.0
In-Reply-To: <20190619223710.GC33328@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, dm-devel@redhat.com, linux-fscrypt@vger.kernel.org, Gilad Ben-Yossef <gilad@benyossef.com>, Milan Broz <gmazyland@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>


On 20/06/2019 00:37, Eric Biggers wrote:
> On Wed, Jun 19, 2019 at 06:29:21PM +0200, Ard Biesheuvel wrote:
>> Add an accelerated version of the 'essiv(cbc(aes),aes,sha256)'
>> skcipher, which is used by fscrypt, and in some cases, by dm-crypt.
>> This avoids a separate call into the AES cipher for every invocation.
>>
>> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
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

The aes-cbc-essiv:sha256 is still default for plain cryptsetup devices
(LUKS uses XTS for several years as a default already).

The reason is compatibility with older distros (if there is no cipher mode
specification in crypttab for plain device, switching default could cause data corruption).

But I think initscripts now enforce cipher and keysize crypttab options for some time,
so I can probably switch the default to XTS for plain devices soon.
(We have already compile time option for it anyway.)

IOW intention for dm-crypt is to slightly deprecate CBC mode use for all types of devices.

Milan
