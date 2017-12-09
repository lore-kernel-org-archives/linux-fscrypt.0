Return-Path: <noloader@gmail.com>
MIME-Version: 1.0
Reply-To: noloader@gmail.com
In-Reply-To: <20171208013838.105034-1-ebiggers3@gmail.com>
References: <20171208013838.105034-1-ebiggers3@gmail.com>
From: Jeffrey Walton <noloader@gmail.com>
Date: Fri, 8 Dec 2017 19:48:54 -0500
Message-ID: <CAH8yC8knEBwum3Ka3x+8sT3qhtHT2FLb4Bo6DzjPKFC0hw4KQA@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: add support for ChaCha20 contents encryption
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Paul Crowley <paulcrowley@google.com>, Martin Willi <martin@strongswan.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, David Gstir <david@sigma-star.at>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

> Still, a stream cipher is sufficient to protect data confidentiality in
> the event of a single point-in-time permanent offline compromise of the
> disk, which currently is the primary threat model for fscrypt.  Thus,
> when the alternative is quite literally *no encryption*, we might as
> well use a stream cipher.

The "single point in time" requirement is kind of interesting. I
believe you are saying the scheme lacks semantic security.

Forgive my ignorance... Does that mean this cipher should not be used
when backups are in effect; or sync'ing to <insert favorite cloud
provider> happens?

Jeff

On Thu, Dec 7, 2017 at 8:38 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> From: Eric Biggers <ebiggers@google.com>
>
> fscrypt currently only supports AES encryption.  However, many low-end
> mobile devices still use older CPUs such as ARMv7, which do not support
> the AES instructions (the ARMv8 Cryptography Extensions).  This results
> in very poor AES performance, even if the NEON bit-sliced implementation
> is used.  Roughly 20-40 MB/s is a typical number, in comparison to
> 300-800 MB/s on CPUs that support the AES instructions.  Switching from
> AES-256 to AES-128 only helps by about 30%.
>
> The result is that vendors don't enable encryption on these devices,
> leaving users unprotected.
>
> A performance difference of similar magnitude can also be observed on
> x86, between CPUs with and without the AES-NI instruction set.
>
> This patch provides an alternative to AES by updating fscrypt to support
> the ChaCha20 stream cipher (RFC7539) for contents encryption.  ChaCha20
> was designed to have a large security margin, to be efficient on
> general-purpose CPUs without dedicated instructions, and to be
> vectorizable.  It is already supported by the Linux crypto API,
> including a vectorized implementation for ARM using NEON instructions,
> and vectorized implementations for x86 using SSSE3 or AVX2 instructions.
>
> On 32-bit ARM processors with NEON support, ChaCha20 is about 3.2 times
> faster than AES-128-XTS (chacha20-neon vs. xts-aes-neonbs).  Without
> NEON support, ChaCha20 is about 1.5 times as fast (chacha20-generic vs.
> xts(aes-asm)).  The improvement over AES-256-XTS is even greater.
>
> Note that stream ciphers are not an ideal choice for disk encryption,
> since each data block has to be encrypted with the same IV each time it
> is overwritten.  Consequently, an adversary who observes the ciphertext
> both before and after a write can trivially recover the keystream if
> they can guess one of the plaintexts.  Moreover, an adversary who can
> write to the ciphertext can flip arbitrary bits in the plaintext, merely
> by flipping the corresponding bits in the ciphertext.  A block cipher
> operating in the XTS or CBC-ESSIV mode provides some protection against
> these types of attacks -- albeit not full protection, which would at
> minimum require the use an authenticated encryption mode with nonces.
>
> Unfortunately, we are unaware of any block cipher which performs as well
> as ChaCha20, has a similar or greater security margin, and has been
> subject to as much public security analysis.  We do not consider Speck
> to be a viable alternative at this time.
>
> Still, a stream cipher is sufficient to protect data confidentiality in
> the event of a single point-in-time permanent offline compromise of the
> disk, which currently is the primary threat model for fscrypt.  Thus,
> when the alternative is quite literally *no encryption*, we might as
> well use a stream cipher.
>
> We offer ChaCha20 rather than the reduced-round variants ChaCha8 or
> ChaCha12 because ChaCha20 has a much higher security margin, and we are
> primarily targeting CPUs where ChaCha20 is fast enough, in particular
> CPUs that have vector instructions such as NEON or SSSE3.  Also, the
> crypto API currently only supports ChaCha20.  Still, if ChaCha8 and/or
> ChaCha12 support were to be added to the crypto API, it would be
> straightforward to support them in fscrypt too.
>
> Currently, stream ciphers cannot be used for filenames encryption with
> fscrypt because all filenames in a directory have to be encrypted with
> the same IV.  Therefore, we offer ChaCha20 for contents encryption only.
> Filenames encryption still must use AES-256-CTS-CBC.  This is acceptable
> because filenames encryption is not as performance-critical as contents
> encryption.
>
> ...
