Return-Path: <SRS0=hU7U=KV=google.com=paulcrowley@kernel.org>
MIME-Version: 1.0
References: <20180806223300.113891-1-ebiggers@kernel.org> <20180806223300.113891-4-ebiggers@kernel.org>
 <CAHmME9rbe6eT6dkUqKnp-GxcqGrp-tvMfTMr8kZtsn=S3cmP8A@mail.gmail.com>
In-Reply-To: <CAHmME9rbe6eT6dkUqKnp-GxcqGrp-tvMfTMr8kZtsn=S3cmP8A@mail.gmail.com>
From: Paul Crowley <paulcrowley@google.com>
Date: Mon, 6 Aug 2018 16:48:41 -0700
Message-ID: <CA+_SqcD+KpQ_X6iXUCpQh0N6pWzBorstBJDx7eBqcybY4Dvy8Q@mail.gmail.com>
Subject: Re: [RFC PATCH 3/9] crypto: chacha20-generic - refactor to allow
 varying number of rounds
Content-Type: text/plain; charset="UTF-8"
To: Jason@zx2c4.com
Cc: ebiggers@kernel.org, linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, samuel.c.p.neves@gmail.com, tomer.ashur@esat.kuleuven.be, Eric Biggers <ebiggers@google.com>, djb@cr.yp.to
List-ID: <linux-fscrypt@vger.kernel.org>

Salsa20 was one of the earlier ARX proposals, and set a very
conservative number of rounds as befits our state of knowledge at the
time. Since then we've learned a lot more about cryptanalysis of such
offerings, and I think we can be comfortable with fewer rounds. The
best attack on ChaCha breaks 7 rounds, and that attack requires 2^248
operations. Every round of ChaCha makes attacks vastly harder.

Performance is absolutely crucial when it comes to disk encryption;
users and vendors will push back hard against encryption that degrades
the user experience. So we're always going to choose the fastest
option that gives us a solid margin of security, and here that's
ChaCha12.

I'd like to turn the question around. Why 20? DJB's 20 round proposal
predates his 12 round proposal, but I don't think that's a reason to
choose it when all cryptanalysis has considered reduced-round
variants. The 20 round variant is more widely used, but again I think
that's informative more about the historical order of things than the
security. If 20 is better than 12, is 24 better than 20? What is it
that draws you to 20 rounds specifically?

(apologies for reposting, I forgot to set Plain Text Mode.)

On Mon, 6 Aug 2018 at 16:16, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>
> Hey Eric,
>
> On Tue, Aug 7, 2018 at 12:35 AM Eric Biggers <ebiggers@kernel.org> wrote:
> > In preparation for adding XChaCha12 support, rename/refactor
> > chacha20-generic to support different numbers of rounds.
>
> I'm interested in learning the motivation behind going with ChaCha12.
> So far, the vast majority of users of ChaCha have been getting along
> quite fine with ChaCha20 and enjoying the very large security margin
> this provides. In some ways, introducing ChaCha12 into the ecosystem
> feels like a bit of a step backwards, even if it probably still
> provides adequate security (though ChaCha8 probably shouldn't be used
> or included at all). I realize the simple answer is just, "because
> it's faster." But I'm wondering specifically about the speed
> requirements and on what hardware and in what circumstances you found
> ChaCha20 was too slow, and if this is the kind of circumstance you
> expect to persist into the future.
>
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fscrypt" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
