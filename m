Return-Path: <linux-crypto-owner@vger.kernel.org>
Message-ID: <757b2f06657d68929ce14d2bac3eb111bb06e6ab.camel@strongswan.org>
Subject: Re: [RFC PATCH v3 00/15] crypto: Adiantum support
From: Martin Willi <martin@strongswan.org>
Date: Thu, 08 Nov 2018 07:47:23 +0100
In-Reply-To: <20181105232526.173947-1-ebiggers@kernel.org>
References: <20181105232526.173947-1-ebiggers@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-crypto-owner@vger.kernel.org
To: Eric Biggers <ebiggers@kernel.org>, linux-crypto@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

> This patchset adds Adiantum to Linux's crypto API, focusing on
> generic and ARM32 implementations.  Patches 1-9 add support for
> XChaCha20 and XChaCha12.  Patches 10-13 add NHPoly1305 support,
> needed for Adiantum hashing. Patch 14 adds Adiantum support as a
> skcipher template.

Nice work. I did a quick review only, but you may add my

  Acked-by: Martin Willi <martin@strongswan.org>

for patches 1-5, 10 and 11.

Thanks,
Martin
