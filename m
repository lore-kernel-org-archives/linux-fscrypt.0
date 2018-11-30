Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:35182 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725754AbeLAFIK (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 1 Dec 2018 00:08:10 -0500
Date: Fri, 30 Nov 2018 09:58:03 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v4 00/14] crypto: Adiantum support
Message-ID: <20181130175802.GB135453@gmail.com>
References: <20181117012631.23528-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181117012631.23528-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-crypto@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
Cc: linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, "Jason A . Donenfeld" <Jason@zx2c4.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Nov 16, 2018 at 05:26:17PM -0800, Eric Biggers wrote:
> 
> Therefore, we (well, Paul Crowley did the real work) designed a new
> encryption mode, Adiantum.  In essence, Adiantum makes it secure to use
> the ChaCha stream cipher for disk encryption.  Adiantum is specified by
> our paper here: https://eprint.iacr.org/2018/720.pdf ("Adiantum:
> length-preserving encryption for entry-level processors").  Reference
> code and test vectors are here: https://github.com/google/adiantum.
> Most of the high-level concepts of Adiantum are not new; similar
> existing modes include XCB, HCTR, and HCH.  Adiantum and these modes are
> true wide-block modes (tweakable super-pseudorandom permutations), so
> they actually provide a stronger notion of security than XTS.
> 

In case anyone is interested: Paul and I have made some improvements to the
Adiantum paper and have updated the preprint at the above link.  The algorithm
is still the same, but explanations have been improved and the proof has been
redone using a different technique that is easier to follow.  It also matches
the version that will be published in IACR Transactions on Symmetric Cryptology
(ToSC) Volume 2018 Issue 4.

All versions of our paper can be found at https://eprint.iacr.org/2018/720, and
the .tex source is at https://github.com/google/adiantum/tree/master/specification.

- Eric
