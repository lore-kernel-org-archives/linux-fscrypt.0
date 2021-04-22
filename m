Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EFE9C433ED
	for <linux-fscrypt@archiver.kernel.org>; Thu, 22 Apr 2021 00:01:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7372961448
	for <linux-fscrypt@archiver.kernel.org>; Thu, 22 Apr 2021 00:01:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240903AbhDVAB7 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 21 Apr 2021 20:01:59 -0400
Received: from helcar.hmeau.com ([216.24.177.18]:45800 "EHLO fornost.hmeau.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S234886AbhDVAB6 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 21 Apr 2021 20:01:58 -0400
Received: from gwarestrin.arnor.me.apana.org.au ([192.168.103.7])
        by fornost.hmeau.com with smtp (Exim 4.92 #5 (Debian))
        id 1lZMmW-0006CR-Ik; Thu, 22 Apr 2021 10:01:21 +1000
Received: by gwarestrin.arnor.me.apana.org.au (sSMTP sendmail emulation); Thu, 22 Apr 2021 10:01:20 +1000
Date:   Thu, 22 Apr 2021 10:01:20 +1000
From:   Herbert Xu <herbert@gondor.apana.org.au>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Ard Biesheuvel <ardb@kernel.org>
Subject: Re: [PATCH v2 1/2] fscrypt: relax Kconfig dependencies for crypto
 API algorithms
Message-ID: <20210422000120.GA4039@gondor.apana.org.au>
References: <20210421075511.45321-1-ardb@kernel.org>
 <20210421075511.45321-2-ardb@kernel.org>
 <YIBsXY5QOcEjnZ6I@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <YIBsXY5QOcEjnZ6I@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Apr 21, 2021 at 11:18:05AM -0700, Eric Biggers wrote:
>
> Herbert, is there still time for you to take these two patches through the
> crypto tree for 5.13?  There aren't any other fscrypt or fsverity patches for
> 5.13, so that would be easiest for me.

Sure, I can take these patches.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
