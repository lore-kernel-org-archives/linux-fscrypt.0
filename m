Return-Path: <SRS0=Ifvv=KV=zx2c4.com=Jason@kernel.org>
MIME-Version: 1.0
References: <20180806223300.113891-1-ebiggers@kernel.org> <20180806223300.113891-4-ebiggers@kernel.org>
In-Reply-To: <20180806223300.113891-4-ebiggers@kernel.org>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Tue, 7 Aug 2018 01:16:18 +0200
Message-ID: <CAHmME9rbe6eT6dkUqKnp-GxcqGrp-tvMfTMr8kZtsn=S3cmP8A@mail.gmail.com>
Subject: Re: [RFC PATCH 3/9] crypto: chacha20-generic - refactor to allow
 varying number of rounds
Content-Type: text/plain; charset="UTF-8"
To: ebiggers@kernel.org
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, samuel.c.p.neves@gmail.com, tomer.ashur@esat.kuleuven.be, Eric Biggers <ebiggers@google.com>, "Daniel J . Bernstein" <djb@cr.yp.to>
List-ID: <linux-fscrypt@vger.kernel.org>

Hey Eric,

On Tue, Aug 7, 2018 at 12:35 AM Eric Biggers <ebiggers@kernel.org> wrote:
> In preparation for adding XChaCha12 support, rename/refactor
> chacha20-generic to support different numbers of rounds.

I'm interested in learning the motivation behind going with ChaCha12.
So far, the vast majority of users of ChaCha have been getting along
quite fine with ChaCha20 and enjoying the very large security margin
this provides. In some ways, introducing ChaCha12 into the ecosystem
feels like a bit of a step backwards, even if it probably still
provides adequate security (though ChaCha8 probably shouldn't be used
or included at all). I realize the simple answer is just, "because
it's faster." But I'm wondering specifically about the speed
requirements and on what hardware and in what circumstances you found
ChaCha20 was too slow, and if this is the kind of circumstance you
expect to persist into the future.

Jason
