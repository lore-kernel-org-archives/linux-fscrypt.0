Return-Path: <geokozey@mailfence.com>
From: Geo Kozey <geokozey@mailfence.com>
Reply-To: Geo Kozey <geokozey@mailfence.com>
Message-ID: <483722360.123210.1512834056036@ichabod.co-bxl>
In-Reply-To: <20171208214213.GA104193@gmail.com>
References: <20171208013838.105034-1-ebiggers3@gmail.com> <CAHmME9ob8eG1yS=jkGHFnYDq+FtiJCP38CKpzUs0Z33R8_0Msw@mail.gmail.com> <CAKv+Gu85X5OZWhwQxNrc8RonPL3XdRhzK=JeWcWXLu=8KUsQAg@mail.gmail.com> <20171208214213.GA104193@gmail.com>
Subject: Re: [PATCH] fscrypt: add support for ChaCha20 contents encryption
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Date: Sat, 9 Dec 2017 16:40:56 +0100 (CET)
To: Eric Biggers <ebiggers3@gmail.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, linux-fscrypt@vger.kernel.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, ebiggers@google.com
List-ID: <linux-fscrypt@vger.kernel.org>

> From: Eric Biggers <ebiggers3@gmail.com>
> Sent: Fri Dec 08 22:42:13 CET 2017
> Subject: Re: [PATCH] fscrypt: add support for ChaCha20 contents encryption
> 
> We can't use authenticated encryption for the same reason we can't use random or
> sequential nonces: there is nowhere to store the additional metadata
> (authentication tag and nonce) per filesystem block *and* have it updated
> atomically with respect to the contents of said block. 

I saw that LUKS/dm-crypt guys are able to do AE regardless of the same issues[1].
Is it really impossible for fscrypt?

[1] http://www.saout.de/pipermail/dm-crypt/2017-November/005745.html

Yours sincerely

G. K.
