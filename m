Return-Path: <martin@strongswan.org>
Message-ID: <1512977925.28078.12.camel@strongswan.org>
Subject: Re: [RFC PATCH] crypto: chacha20 - add implementation using 96-bit
 nonce
From: Martin Willi <martin@strongswan.org>
Date: Mon, 11 Dec 2017 08:38:45 +0100
In-Reply-To: <20171208221716.GB104193@gmail.com>
References: <20171208115502.21775-1-ard.biesheuvel@linaro.org>
	 <20171208221716.GB104193@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers3@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, herbert@gondor.apana.org.au, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Paul Crowley <paulcrowley@google.com>, David Gstir <david@sigma-star.at>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Stephan Mueller <smueller@chronox.de>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi,

> Anyway, I actually thought it was intentional that the ChaCha
> implementations in the Linux kernel allowed specifying the block
> counter, and therefore allowed seeking to any point in the keystream,
> exposing the full functionality of the cipher.

If I remember correctly, it was indeed intentional. When building the
chacha20poly1305 AEAD both in [1] and [2], a block counter of 0 is used
to generate the Poly1305 key. For the ChaCha20 encryption, an explicit
initial block counter of 1 is used to avoid reusing the same counter.

Maybe it would be possible to implement this with implicit counters,
but doing this explicitly looked much clearer to me. So I guess there
are use cases for explicit block counters in ChaCha20.

Best regards
Martin

[1] https://tools.ietf.org/html/rfc7539#section-2.8
[2] https://tools.ietf.org/html/rfc7634#section-2
