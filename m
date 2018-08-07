Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:43078 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731982AbeHGDb0 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 6 Aug 2018 23:31:26 -0400
Date: Mon, 6 Aug 2018 18:19:37 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] crypto: remove speck
Message-ID: <20180807011937.GA133621@gmail.com>
References: <20180806223300.113891-1-ebiggers@kernel.org>
 <20180806230437.21431-1-Jason@zx2c4.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806230437.21431-1-Jason@zx2c4.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Paul Crowley <paulcrowley@google.com>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, Samuel Neves <samuel.c.p.neves@gmail.com>, Tomer Ashur <tomer.ashur@esat.kuleuven.be>, stable@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Jason,

On Tue, Aug 07, 2018 at 01:04:37AM +0200, Jason A. Donenfeld wrote:
> These are unused, undesired, and have never actually been used by
> anybody. The original authors of this code have changed their mind about
> its inclusion. Therefore, this patch removes it.
> 
> Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
> Cc: stable@vger.kernel.org

For context, in your commit message can you include a link to my email
mentioning Android's Speck decision
(https://marc.info/?l=linux-crypto-vger&m=153359499015659)?

Also: "speck" => "Speck".

Also I think the fscrypt code points should be reserved so they don't
get reused for something else:

#define FS_ENCRYPTION_MODE_SPECK128_256_XTS    7	/* removed */
#define FS_ENCRYPTION_MODE_SPECK128_256_CTS    8	/* removed */

Otherwise:

	Acked-by: Eric Biggers <ebiggers@google.com>

For the record, I think the statements Paul and I have made evaluating
Speck from a technical perspective remain substantially accurate.
However, clearly today there are more than just technical considerations
when choosing cryptographic primitives.  So ultimately, enough people
didn't *want* Speck that we weren't able to offer it, even though it was
only meant to replace no encryption.  We've also designed and proposed
an alternative solution for the ARMv7 disk encryption use case, HPolyC.

So given the above, and that I no longer know of any specific users of
the Speck code (so in principle it can still be removed without breaking
userspace), and that it's possible that similar considerations will make
Speck difficult for others to use, and that some people heavily object
to Speck being optionally supported in the kernel at all, I'm okay with
it being removed...

Thanks,

- Eric
