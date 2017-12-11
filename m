Return-Path: <david@sigma-star.at>
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] fscrypt: add support for ChaCha20 contents encryption
From: David Gstir <david@sigma-star.at>
In-Reply-To: <CAHmME9ob8eG1yS=jkGHFnYDq+FtiJCP38CKpzUs0Z33R8_0Msw@mail.gmail.com>
Date: Mon, 11 Dec 2017 17:11:41 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <899E2752-1AD9-4DF4-ABC7-E0D1582AF292@sigma-star.at>
References: <20171208013838.105034-1-ebiggers3@gmail.com>
 <CAHmME9ob8eG1yS=jkGHFnYDq+FtiJCP38CKpzUs0Z33R8_0Msw@mail.gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Paul Crowley <paulcrowley@google.com>, Martin Willi <martin@strongswan.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Eric Biggers <ebiggers@google.com>, Richard Weinberger <richard@nod.at>
List-ID: <linux-fscrypt@vger.kernel.org>


> On 08.12.2017, at 03:51, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>=20
> Hi Eric,
>=20
> Nice to see more use of ChaCha20. However...
>=20
> Can we skip over the "sort of worse than XTS, but not having _real_
> authentication sucks anyway in either case, so whatever" and move
> directly to, "linux finally supports authenticated encryption for disk
> encryption!"? This would be a big deal and would actually be a
> noticeable security improvement, instead of a potentially dubious step
> sidewaysbackish.

Out of curiosity, does anybody know of any specific attacks that =
authenticated
encryption for disk encryption would solve as opposed to just using =
encryption
with AES-XTS?

To my knowledge the XTS mode is frowned upon [1], but I don't know of =
any
serious flaws that would eg. allow an attacker to modify file contents
without a *serious* amount of effort. CBC is another story though [2].

Don't get me wrong, I'd like to have authenticated encryption too.
In fact we are currently working on a concept for adding authentication =
to
UBIFS (I'll share more details as soon as its in a presentable state).
However, the reason for this is mainly because UBIFS does *not* operate =
on
the block layer, so dm-integrity/dm-verity is not an option and fscrypt
only protects the confidentiality of file contents and filenames.
This means that the filesystem index is unprotected which makes it =
rather
easy to move files around - eg. replace /bin/bash with something =
completely
different without knowing the fscrypt master key or any derived key.

For the general use case though (eg. securing *really important* files =
on my desktop),
I'd use authenticated encryption at a higher layer to get more =
flexibility
to eg. easily use explicit IVs over implicit ones derived from =
block/sector
number. But maybe there are some uses cases I didn't think of just =
now... :)

David

[1] https://sockpuppet.org/blog/2014/04/30/you-dont-want-xts/
[2] =
http://www.jakoblell.com/blog/2013/12/22/practical-malleability-attack-aga=
inst-cbc-encrypted-luks-partitions/
