Return-Path: <Jason@zx2c4.com>
MIME-Version: 1.0
In-Reply-To: <20171208013838.105034-1-ebiggers3@gmail.com>
References: <20171208013838.105034-1-ebiggers3@gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Fri, 8 Dec 2017 03:51:28 +0100
Message-ID: <CAHmME9ob8eG1yS=jkGHFnYDq+FtiJCP38CKpzUs0Z33R8_0Msw@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: add support for ChaCha20 contents encryption
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Paul Crowley <paulcrowley@google.com>, Martin Willi <martin@strongswan.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, David Gstir <david@sigma-star.at>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

Nice to see more use of ChaCha20. However...

Can we skip over the "sort of worse than XTS, but not having _real_
authentication sucks anyway in either case, so whatever" and move
directly to, "linux finally supports authenticated encryption for disk
encryption!"? This would be a big deal and would actually be a
noticeable security improvement, instead of a potentially dubious step
sidewaysbackish.

Bcachefs supports ChaCha20Poly1305, which is pretty neat. From what
I've read, performance is acceptable too.
http://bcachefs.org/Encryption/

Jason
