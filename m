Return-Path: <SRS0=3vtv=KW=thunk.org=tytso@kernel.org>
Date: Mon, 6 Aug 2018 23:15:26 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] crypto: remove speck
Message-ID: <20180807031526.GD5048@thunk.org>
References: <20180806223300.113891-1-ebiggers@kernel.org>
 <20180806230437.21431-1-Jason@zx2c4.com>
 <20180807011937.GA133621@gmail.com>
 <CAHmME9oTApV-zHD60QPryaoQf45ODpG25Da5FgB8c+LO162gWQ@mail.gmail.com>
 <20180807031237.GA779@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180807031237.GA779@sol.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Aug 06, 2018 at 08:12:38PM -0700, Eric Biggers wrote:
> I mention this because people are naturally going to be curious about that, e.g.
> speculating that Google found a "backdoor" -- remember that we do have some good
> cryptographers!  I'm just stating what we know, out of honesty and openness; I
> don't really intend to be arguing for Speck with this statement, and in any case
> we already made the decision to not use Speck.

Let's be clear --- the arguments about whether or not to use Speck,
and whether or not to remove Speck from the kernel, are purely
political --- not techinical.

						- Ted
