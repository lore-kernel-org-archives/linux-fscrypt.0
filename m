Return-Path: <linux-crypto-owner@vger.kernel.org>
Date: Mon, 11 Dec 2017 17:55:35 +1100
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] crypto: chacha20 - add implementation using 96-bit
 nonce
Message-ID: <20171211065535.GA8457@gondor.apana.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208115502.21775-1-ard.biesheuvel@linaro.org>
Sender: linux-crypto-owner@vger.kernel.org
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, ebiggers@google.com, linux-fscrypt@vger.kernel.org, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, jaegeuk@kernel.org, mhalcrow@google.com, paulcrowley@google.com, martin@strongswan.org, david@sigma-star.at, Jason@zx2c4.com, smueller@chronox.de
List-ID: <linux-fscrypt@vger.kernel.org>

Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> As pointed out by Eric [0], the way RFC7539 was interpreted when creating
> our implementation of ChaCha20 creates a risk of IV reuse when using a
> little endian counter as the IV generator. The reason is that the low end
> bits of the counter get mapped onto the ChaCha20 block counter, which
> advances every 64 bytes. This means that the counter value that gets
> selected as IV for the next input block will collide with the ChaCha20
> block counter of the previous block, basically recreating the same
> keystream but shifted by 64 bytes.

As Eric pointed out for steram ciphers such as chacha20 our policy
is to expose the raw IV in the base algorithm, and then layer
more restrictive implementations on top that can then be used
in different scenarios such as IPsec or disk encryption.

For example, with CTR, ctr(aes) is the base algorithm and places
no restrictions on the IV, while rfc3686(ctr(aes)) is the more
restrictive version that's used by IPsec.

Within the kernel I don't really see an issue with abuse because
all users are hopefully reviewed by the community.  If you're
worried about incorrect use in user-space we could think about
restricting access to these base implementations.

For chacha20 we did not add a restrictive template because the
primary user IPsec uses it only through AEAD where the IV restriction
is in place.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
