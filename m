Return-Path: <noloader@gmail.com>
MIME-Version: 1.0
Reply-To: noloader@gmail.com
In-Reply-To: <20170712210035.51534-5-ebiggers3@gmail.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com> <20170712210035.51534-5-ebiggers3@gmail.com>
From: Jeffrey Walton <noloader@gmail.com>
Date: Fri, 14 Jul 2017 13:34:48 -0400
Message-ID: <CAH8yC8naCiyXKeaYbyw=B1DgM3vvBtUSmDCZ+B7VVqZ6QD1uhg@mail.gmail.com>
Subject: Re: [PATCH 4/6] fscrypt: verify that the correct master key was supplied
Content-Type: text/plain; charset="UTF-8"
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jul 12, 2017 at 5:00 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> From: Eric Biggers <ebiggers@google.com>
>
>....
> Solve the problem for v2 encryption policies by storing a "hash" of the
> master encryption key in the encryption xattr and verifying it before
> accepting the user-provided key.
> ...

Forgive my ignorance... Doesn't that setup an oracle so an attacker
can query keys?

It seems like the problem is deeper into the design. Namely, the
caching and sharing of keys.

Jeff
