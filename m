Return-Path: <SRS0=H5uw=RZ=gondor.apana.org.au=herbert@kernel.org>
Date: Fri, 22 Mar 2019 14:27:41 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/17] Add zinc using existing algorithm implementations
Message-ID: <20190322062740.nrwfx2rvmt7lzotj@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
To: Linus Torvalds <torvalds@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, Martin Willi <martin@strongswan.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi:

In the interest of moving forward with wireguard, this patch
series adds the zinc interface as submitted in

https://patchwork.kernel.org/project/linux-crypto/list/?series=32507&state=*

with the change that existing implementations of chacha20 and
poly1305 are used instead of the new ones.  The use of the existing
chacha20/poly1305 implementations does not involve any use of the
crypto API or indirect function calls.  Only direct function calls
are made into the underlying implementation.

This should allow the wireguard code itself to proceed.  At the
same time we can also move forward with replacing the existing
implementations of chacha20 and/or poly1305 where appropriate.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
