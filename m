Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:55118 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726027AbeHHAHs (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 7 Aug 2018 20:07:48 -0400
Date: Tue, 7 Aug 2018 14:51:21 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 3/9] crypto: chacha20-generic - refactor to allow
 varying number of rounds
Message-ID: <20180807215121.GB25300@gmail.com>
References: <20180806223300.113891-1-ebiggers@kernel.org>
 <20180806223300.113891-4-ebiggers@kernel.org>
 <CAHmME9rbe6eT6dkUqKnp-GxcqGrp-tvMfTMr8kZtsn=S3cmP8A@mail.gmail.com>
 <CA+_SqcD+KpQ_X6iXUCpQh0N6pWzBorstBJDx7eBqcybY4Dvy8Q@mail.gmail.com>
 <CAEX_ruFp0KddnZyetZt997OvRzKDuN7U95MF_N9AgTh+mTcD7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEX_ruFp0KddnZyetZt997OvRzKDuN7U95MF_N9AgTh+mTcD7Q@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Samuel Neves <samuel.c.p.neves@gmail.com>
Cc: Paul Crowley <paulcrowley@google.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, tomer.ashur@esat.kuleuven.be, Eric Biggers <ebiggers@google.com>, "D. J. Bernstein" <djb@cr.yp.to>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Aug 07, 2018 at 11:21:04AM +0100, Samuel Neves wrote:
> > The best attack on ChaCha breaks 7 rounds, and that attack requires 2^248 operations.
> 
> This number, as far as I can tell, comes from the "New features of
> Latin dances" paper. There have been some minor improvements in the
> intervening 10 years, e.g., [1, 2, 3, 4], which pull back the
> complexity of breaking ChaCha7 down to 2^235. In any case, every
> attack so far appears to hit a wall at 8 rounds, with 12 rounds---the
> recommended eSTREAM round number for Salsa20---seeming to offer a
> reasonable security margin, still somewhat better than that of the
> AES.
> 
> Best regards,
> Samuel Neves
> 
> [1] https://eprint.iacr.org/2015/698
> [2] https://eprint.iacr.org/2015/217
> [3] https://eprint.iacr.org/2016/1034
> [4] https://doi.org/10.1016/j.dam.2017.04.034

Thanks Samuel, I'll fix that number in the next iteration of the patchset.

- Eric
