Return-Path: <ebiggers3@gmail.com>
Date: Fri, 8 Dec 2017 14:17:16 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [RFC PATCH] crypto: chacha20 - add implementation using 96-bit
 nonce
Message-ID: <20171208221716.GB104193@gmail.com>
References: <20171208115502.21775-1-ard.biesheuvel@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208115502.21775-1-ard.biesheuvel@linaro.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-crypto@vger.kernel.org, herbert@gondor.apana.org.au, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Paul Crowley <paulcrowley@google.com>, Martin Willi <martin@strongswan.org>, David Gstir <david@sigma-star.at>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Stephan Mueller <smueller@chronox.de>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Dec 08, 2017 at 11:55:02AM +0000, Ard Biesheuvel wrote:
> As pointed out by Eric [0], the way RFC7539 was interpreted when creating
> our implementation of ChaCha20 creates a risk of IV reuse when using a
> little endian counter as the IV generator. The reason is that the low end
> bits of the counter get mapped onto the ChaCha20 block counter, which
> advances every 64 bytes. This means that the counter value that gets
> selected as IV for the next input block will collide with the ChaCha20
> block counter of the previous block, basically recreating the same
> keystream but shifted by 64 bytes.
> 
> RFC7539 describes the inputs of the algorithm as follows:
> 
>   The inputs to ChaCha20 are:
> 
>      o  A 256-bit key
> 
>      o  A 32-bit initial counter.  This can be set to any number, but will
>         usually be zero or one.  It makes sense to use one if we use the
>         zero block for something else, such as generating a one-time
>         authenticator key as part of an AEAD algorithm.
> 
>      o  A 96-bit nonce.  In some protocols, this is known as the
>         Initialization Vector.
> 
>      o  An arbitrary-length plaintext
> 
> The solution is to use a fixed value of 0 for the initial counter, and
> only expose a 96-bit IV to the upper layers of the crypto API.
> 
> So introduce a new ChaCha20 flavor called chacha20-iv96, which takes the
> above into account, and should become the preferred ChaCha20
> implementation going forward for general use.

Note that there are two conflicting conventions for what inputs ChaCha takes.
The original paper by Daniel Bernstein
(https://cr.yp.to/chacha/chacha-20080128.pdf) says that the block counter is
64-bit and the nonce is 64-bit, thereby expanding the key into 2^64 randomly
accessible streams, each containing 2^64 randomly accessible 64-byte blocks.

The RFC 7539 convention is equivalent to seeking to a large offset (determined
by the first 32 bits of the 96-bit nonce) in the keystream defined by the djb
convention, but only if the 32-bit portion of the block counter never overflows.

Maybe it is only RFC 7539 that matters because that is what is being
standardized by the IETF; I don't know.  But it confused me.

Anyway, I actually thought it was intentional that the ChaCha implementations in
the Linux kernel allowed specifying the block counter, and therefore allowed
seeking to any point in the keystream, exposing the full functionality of the
cipher.  It's true that it's easily misused though, so there may nevertheless be
value in providing a nonce-only variant.

Eric
