Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from orcrist.hmeau.com ([104.223.48.154]:40510 "EHLO
        deadmen.hmeau.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751179AbdGSE7U (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 19 Jul 2017 00:59:20 -0400
Date: Wed, 19 Jul 2017 12:58:52 +0800
From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: fscrypt request_module() deadlock
Message-ID: <20170719045852.GA8653@gondor.apana.org.au>
References: <3450b67a-6766-d24e-5a84-18fff64d1b73@nod.at>
 <20170718061351.GD4764@gondor.apana.org.au>
 <20170718231747.GA51535@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170718231747.GA51535@gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Richard Weinberger <richard@nod.at>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, David Gstir <david@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Jul 18, 2017 at 04:17:47PM -0700, Eric Biggers wrote:
> 
> While that should solve the problem, isn't it possible to actually have a module
> which supplies an algorithm like "xts(aes)"?  In that case it wouldn't be
> desirable to instantiate the generic "xts" template.

Well, in the case where only xts and aes are built into the kernel
I think we have to use that instead of going to request_module as
otherwise we cannot avoid the dead-lock that is the subject of this
discussion.

If you want accelerated xts(aes) to work while building generic xts
and aes into the kernel then you should also build the accelerated
xts(aes) into the kernel (or load the manually once modules can be
loaded).

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
