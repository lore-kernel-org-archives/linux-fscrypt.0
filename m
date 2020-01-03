Return-Path: <SRS0=g9fr=2Y=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F2BFC2D0C2
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 16:57:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DD13F206DB
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 16:57:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1578070678;
	bh=AiMy+cGsJPfl2j2VH9PKNQJIZ8a8yUVfvB0W4HsnXjw=;
	h=Date:From:To:Subject:References:In-Reply-To:List-ID:From;
	b=QQf7V9AWvj/fvruFZopmBYO1gkb14GxHwJMCkJgpTctzu7X0sAZ0Ch1+gihb2fDDv
	 AtqbLmOTNAX8+eo4ysxu8vlTR4uZ79T5YzYQhu5wa0LGgZWFe3MD/aG9TccXtpMkvi
	 UadJw1U9wXWV25qkTHHxDdFSoMvLn//Tz8z8yV2g=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728035AbgACQ55 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 3 Jan 2020 11:57:57 -0500
Received: from mail.kernel.org ([198.145.29.99]:51076 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727969AbgACQ55 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 3 Jan 2020 11:57:57 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id EACF3206DB
        for <linux-fscrypt@vger.kernel.org>; Fri,  3 Jan 2020 16:57:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1578070677;
        bh=AiMy+cGsJPfl2j2VH9PKNQJIZ8a8yUVfvB0W4HsnXjw=;
        h=Date:From:To:Subject:References:In-Reply-To:From;
        b=uAyP88dHqynK5Vqe52uJ4qc4QRZ5srTjyA/99QuIt50gUor5GtsDp4tQ7MjHRWmMh
         bTozmTRU9FbzQsOidiUiHKZ9v8K8IEVz4C8/gfWepkq7vU2/GDG2kZMQvij7/ye+3a
         9WM5aOxkr9jU5EaNAM6UxhwyK/bK8rvcA2kHmJJI=
Date:   Fri, 3 Jan 2020 08:57:55 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH] fscrypt: use crypto_skcipher_driver_name()
Message-ID: <20200103165755.GC19521@gmail.com>
References: <20191209203810.225302-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191209203810.225302-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Dec 09, 2019 at 12:38:10PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Crypto API users shouldn't really be accessing struct skcipher_alg
> directly.  <crypto/skcipher.h> already has a function
> crypto_skcipher_driver_name(), so use that instead.
> 
> No change in behavior.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/crypto/keysetup.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
> index f577bb6613f93..c9f4fe955971f 100644
> --- a/fs/crypto/keysetup.c
> +++ b/fs/crypto/keysetup.c
> @@ -89,8 +89,7 @@ struct crypto_skcipher *fscrypt_allocate_skcipher(struct fscrypt_mode *mode,
>  		 * first time a mode is used.
>  		 */
>  		pr_info("fscrypt: %s using implementation \"%s\"\n",
> -			mode->friendly_name,
> -			crypto_skcipher_alg(tfm)->base.cra_driver_name);
> +			mode->friendly_name, crypto_skcipher_driver_name(tfm));
>  	}
>  	crypto_skcipher_set_flags(tfm, CRYPTO_TFM_REQ_FORBID_WEAK_KEYS);
>  	err = crypto_skcipher_setkey(tfm, raw_key, mode->keysize);
> -- 
> 2.24.0.393.g34dc348eaf-goog
> 

Applied to fscrypt.git#master for 5.6.

- Eric
