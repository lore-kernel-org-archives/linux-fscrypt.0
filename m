Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Tue, 24 Apr 2018 11:24:29 -0700
From: Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH] crypto: remove Speck
Message-ID: <20180424182429.GB174675@google.com>
References: <20180424161826.31211-1-Jason@zx2c4.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180424161826.31211-1-Jason@zx2c4.com>
Sender: linux-crypto-owner@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Jason,

On Tue, Apr 24, 2018 at 06:18:26PM +0200, Jason A. Donenfeld wrote:
> This NSA-designed cipher was rejected for inclusion in international
> standards by ISO/IEC. Before anyone actually starts using it by
> accident, let's just not ship it at all.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> ---
>  arch/arm/crypto/Kconfig             |    6 -
>  arch/arm/crypto/Makefile            |    2 -
>  arch/arm/crypto/speck-neon-core.S   |  432 --------
>  arch/arm/crypto/speck-neon-glue.c   |  288 ------
>  arch/arm64/crypto/Kconfig           |    6 -
>  arch/arm64/crypto/Makefile          |    3 -
>  arch/arm64/crypto/speck-neon-core.S |  352 -------
>  arch/arm64/crypto/speck-neon-glue.c |  282 -----
>  arch/s390/defconfig                 |    1 -
>  crypto/Kconfig                      |   14 -
>  crypto/Makefile                     |    1 -
>  crypto/speck.c                      |  307 ------
>  crypto/testmgr.c                    |   36 -
>  crypto/testmgr.h                    | 1486 ---------------------------
>  include/crypto/speck.h              |   62 --
>  15 files changed, 3278 deletions(-)
>  delete mode 100644 arch/arm/crypto/speck-neon-core.S
>  delete mode 100644 arch/arm/crypto/speck-neon-glue.c
>  delete mode 100644 arch/arm64/crypto/speck-neon-core.S
>  delete mode 100644 arch/arm64/crypto/speck-neon-glue.c
>  delete mode 100644 crypto/speck.c
>  delete mode 100644 include/crypto/speck.h
> 

Please see my response on the other thread ("[PATCH v2 0/5] crypto: Speck support"):

https://marc.info/?l=linux-crypto-vger&m=152459378914647

Thanks,

- Eric
