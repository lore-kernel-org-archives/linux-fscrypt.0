Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:45557 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730724AbeHGC1W (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 6 Aug 2018 22:27:22 -0400
MIME-Version: 1.0
In-Reply-To: <CA+_SqcD+KpQ_X6iXUCpQh0N6pWzBorstBJDx7eBqcybY4Dvy8Q@mail.gmail.com>
References: <20180806223300.113891-1-ebiggers@kernel.org> <20180806223300.113891-4-ebiggers@kernel.org>
 <CAHmME9rbe6eT6dkUqKnp-GxcqGrp-tvMfTMr8kZtsn=S3cmP8A@mail.gmail.com> <CA+_SqcD+KpQ_X6iXUCpQh0N6pWzBorstBJDx7eBqcybY4Dvy8Q@mail.gmail.com>
From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 6 Aug 2018 20:15:43 -0400
Message-ID: <CAHmME9o6XQ+16d4b8+BiQViSiOOApi-J_ML2UOOBpTN8hV3iVA@mail.gmail.com>
Subject: Re: [RFC PATCH 3/9] crypto: chacha20-generic - refactor to allow
 varying number of rounds
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
To: Paul Crowley <paulcrowley@google.com>
Cc: ebiggers@kernel.org, linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, samuel.c.p.neves@gmail.com, tomer.ashur@esat.kuleuven.be, Eric Biggers <ebiggers@google.com>, djb@cr.yp.to
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Paul,

On 8/6/18, Paul Crowley <paulcrowley@google.com> wrote:
> Salsa20 was one of the earlier ARX proposals, and set a very
> conservative number of rounds as befits our state of knowledge at the
> time. Since then we've learned a lot more about cryptanalysis of such
> offerings, and I think we can be comfortable with fewer rounds. The
> best attack on ChaCha breaks 7 rounds, and that attack requires 2^248
> operations. Every round of ChaCha makes attacks vastly harder.

I'm well aware of that, which is why I mentioned that ChaCha12
_probably_ has an adequate security. My primary concerns are a bit
different actually from where you're going - that it breaks from
what's becoming a pretty widely accepted "norm" and, more importantly,
that it increases implementation complexity. These aren't really
drastic concerns, but I am in earnest wondering the type of hardware
analysis you did to determine that you really do need the 12-speedup.
What's the practical landscape out there look like? What disk speeds
were too low for which specific kind of Android usage on which
particular hardware? Did you hit the bottlenecks when paging for code
or when filling up caches when writing asynchronously? And for how
much longer do you foresee underpowered hardware like that being a not
insignificant part of the market? I'm especially curious to know
because ostensibly at Google you have all sorts metrics regarding that
kind of thing.

Jason
