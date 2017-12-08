Return-Path: <ard.biesheuvel@linaro.org>
MIME-Version: 1.0
In-Reply-To: <CAHmME9ob8eG1yS=jkGHFnYDq+FtiJCP38CKpzUs0Z33R8_0Msw@mail.gmail.com>
References: <20171208013838.105034-1-ebiggers3@gmail.com> <CAHmME9ob8eG1yS=jkGHFnYDq+FtiJCP38CKpzUs0Z33R8_0Msw@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 8 Dec 2017 07:20:43 +0000
Message-ID: <CAKv+Gu85X5OZWhwQxNrc8RonPL3XdRhzK=JeWcWXLu=8KUsQAg@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: add support for ChaCha20 contents encryption
Content-Type: text/plain; charset="UTF-8"
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Paul Crowley <paulcrowley@google.com>, Martin Willi <martin@strongswan.org>, David Gstir <david@sigma-star.at>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On 8 December 2017 at 02:51, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> Hi Eric,
>
> Nice to see more use of ChaCha20. However...
>
> Can we skip over the "sort of worse than XTS, but not having _real_
> authentication sucks anyway in either case, so whatever" and move
> directly to, "linux finally supports authenticated encryption for disk
> encryption!"?

Ehm, it doesn't? This is plain ChaCha20, not any AEAD variant.

> This would be a big deal and would actually be a
> noticeable security improvement, instead of a potentially dubious step
> sidewaysbackish.
>

It is actually dubious, given the large scale reuse of IVs with a
stream cipher. I do suppose though that using an AEAD variant would at
least catch any attacks involving flipping ciphertext bits resulting
in plaintext bits being flipped at the same offset (but file updates
would still be visible in the clear)

> Bcachefs supports ChaCha20Poly1305, which is pretty neat. From what
> I've read, performance is acceptable too.
> http://bcachefs.org/Encryption/
>
> Jason
