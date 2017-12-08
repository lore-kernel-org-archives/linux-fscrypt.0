Return-Path: <ard.biesheuvel@linaro.org>
MIME-Version: 1.0
In-Reply-To: <20171208231156.GC104193@gmail.com>
References: <20171208115502.21775-1-ard.biesheuvel@linaro.org>
 <20171208221716.GB104193@gmail.com> <CAKv+Gu9VJ3X6A+WBiKyTmapOMA-r_pKCoiWkDSJJi3okXDeyEA@mail.gmail.com>
 <CAKv+Gu9uO_qsTLdqF4unkwjBC+niDbueAK5a4TbusqL+P5aXKg@mail.gmail.com> <20171208231156.GC104193@gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 8 Dec 2017 23:27:47 +0000
Message-ID: <CAKv+Gu9SXhsZsSrBLX8U8DpX8WH6FGiWXd10n52SU+E9BEfWEg@mail.gmail.com>
Subject: Re: [RFC PATCH] crypto: chacha20 - add implementation using 96-bit nonce
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers3@gmail.com>
Cc: "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Paul Crowley <paulcrowley@google.com>, Martin Willi <martin@strongswan.org>, David Gstir <david@sigma-star.at>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Stephan Mueller <smueller@chronox.de>
List-ID: <linux-fscrypt@vger.kernel.org>

On 8 December 2017 at 23:11, Eric Biggers <ebiggers3@gmail.com> wrote:
> On Fri, Dec 08, 2017 at 10:54:24PM +0000, Ard Biesheuvel wrote:
>> >> Note that there are two conflicting conventions for what inputs ChaCha takes.
>> >> The original paper by Daniel Bernstein
>> >> (https://cr.yp.to/chacha/chacha-20080128.pdf) says that the block counter is
>> >> 64-bit and the nonce is 64-bit, thereby expanding the key into 2^64 randomly
>> >> accessible streams, each containing 2^64 randomly accessible 64-byte blocks.
>> >>
>> >> The RFC 7539 convention is equivalent to seeking to a large offset (determined
>> >> by the first 32 bits of the 96-bit nonce) in the keystream defined by the djb
>> >> convention, but only if the 32-bit portion of the block counter never overflows.
>> >>
>> >> Maybe it is only RFC 7539 that matters because that is what is being
>> >> standardized by the IETF; I don't know.  But it confused me.
>> >>
>> >
>> > The distinction only matters if you start the counter at zero (or
>> > one), because you 'lose' 32 bits of IV that will never be != 0 in
>> > practice if you use a 64-bit counter.
>> >
>> > So that argues for not exposing the block counter as part of the API,
>> > given that it should start at zero anyway, and that you should take
>> > care not to put colliding values in it.
>> >
>> >> Anyway, I actually thought it was intentional that the ChaCha implementations in
>> >> the Linux kernel allowed specifying the block counter, and therefore allowed
>> >> seeking to any point in the keystream, exposing the full functionality of the
>> >> cipher.  It's true that it's easily misused though, so there may nevertheless be
>> >> value in providing a nonce-only variant.
>> >>
>> >
>> > Currently, the skcipher API does not allow such random access, so
>> > while I can see how that could be a useful feature, we can't really
>> > make use of it today. But more importantly, it still does not mean the
>> > block counter should be exposed to the /users/ of the skcipher API
>> > which typically encrypt/decrypt blocks that are much larger than 64
>> > bytes.
>>
>> ... but now that I think of it, how is this any different from, say,
>> AES in CTR mode? The counter is big endian, but apart from that, using
>> IVs derived from a counter will result in the exact same issue, only
>> with a shift of 16 bytes.
>>
>> That means using file block numbers as IV is simply inappropriate, and
>> you should encrypt them first like is done for AES-CBC
>
> The problem with using a stream cipher --- whether that is ChaCha20, AES-CTR, or
> something else --- for disk/file encryption is that by necessity of file/disk
> encryption, each time the "same" block is written to, the IV is the same, which
> is really bad for stream ciphers (but not as bad for AES-XTS, AES-CBC, etc.).
> It's irrelevant whether you do ESSIV or otherwise encrypt the IVs.  ESSIV does
> make the IV for each offset unpredictable by an attacker, which is desirable for
> AES-CBC, but it doesn't stop the IV from being repeated for each overwrite.
>

I'm not suggesting using an encrypted IV to fix the stream cipher
issue, I'm well aware that that is impossible. What I am saying is
that the counter collision can be mitigated by encrypting the IV.

> And just to clarify, you definitely *can* seek to any position in the ChaCha20
> stream using the existing ChaCha20 implementations and the existing skcipher
> API, simply by providing the appropriate IV.  Maybe it was unintentional, but it
> does work.  chacha20poly1305.c even uses it to start at block 1 instead of block
> 0.  I don't know whether there are other users, though.
>

Well, I understand that that's how ChaCha20 works, and that you can
manipulate the IV directly to start at another point in the keystream.
AES-CTR can do exactly the same, for the same reason. What I am saying
is that the skcipher API does not allow you to decrypt an arbitrary
part of a block, which could benefit from the ability of not having to
generate the entire key stream.

So the more we discuss this, the more I think there is actually no
difference with AES-CTR (apart from the block size), and there a
similar enhancement in RFC3686 where the IV does not cover the AES
block level counter, making it safe to use another counter to generate
the IVs.

Of course, this is essentially what you did for the fscrypt code, I
just don't like seeing that kind of reasoning being implement in the
crypto API client.
