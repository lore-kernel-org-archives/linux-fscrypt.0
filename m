Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 629A9C678D5
	for <linux-fscrypt@archiver.kernel.org>; Wed,  8 Mar 2023 18:22:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229958AbjCHSWG (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 8 Mar 2023 13:22:06 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41548 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230098AbjCHSWC (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 8 Mar 2023 13:22:02 -0500
Received: from sin.source.kernel.org (sin.source.kernel.org [145.40.73.55])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BB5BDB9CBF;
        Wed,  8 Mar 2023 10:21:54 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by sin.source.kernel.org (Postfix) with ESMTPS id 7183ECE2147;
        Wed,  8 Mar 2023 18:21:52 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4BB6AC433EF;
        Wed,  8 Mar 2023 18:21:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1678299710;
        bh=jMv2R5Obp9uwwiBKE/QM/GrVHve4hwkTVFE/Im7E5wg=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=KuFUndf35Vch/eBf7sgB8ZGiWj1rXlYXjDi32AguRr6Z6JOsJ0HlXCoYf2ErycJxc
         /7qltuCv+3Rk1AUTwAM3XZHiThO9cQce0JNZvUMOGoo6t13gDAuPGRZveM1LOHMVI1
         /Iy5JPKNDICZShf62/t3Nj7KMG/BEb4gihrrAkELfz3eTfVXDyYjL46AGrxH5IFizR
         6pNt2r6O3vhRyL7wF0xN+sSEhclJC8ckyjVHgLvy8nz+c2GGJw12flwVKF2fjwavN8
         uw+HAdXLV3WG0YS0CX1cFN9ib3l69VCp05+qY3YALTHKrLMo4Wh4Q+Gao56b6c4D9y
         5meaxw112ik3A==
Date:   Wed, 8 Mar 2023 10:21:48 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-block@vger.kernel.org, Jens Axboe <axboe@kernel.dk>
Cc:     linux-fscrypt@vger.kernel.org,
        Nathan Huckleberry <nhuck@google.com>, stable@vger.kernel.org
Subject: Re: [PATCH 1/3] blk-mq: release crypto keyslot before reporting I/O
 complete
Message-ID: <ZAjSPAs5DJSm0ls8@sol.localdomain>
References: <20230303071959.144604-1-ebiggers@kernel.org>
 <20230303071959.144604-2-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230303071959.144604-2-ebiggers@kernel.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, Mar 02, 2023 at 11:19:57PM -0800, Eric Biggers wrote:
> +void __blk_crypto_free_request(struct request *rq)
> +{
>  	mempool_free(rq->crypt_ctx, bio_crypt_ctx_pool);
> -	blk_crypto_rq_set_defaults(rq);
> +	rq->crypt_ctx = NULL;
> +
> +	/* The keyslot, if one was needed, should have been released earlier. */
> +	if (WARN_ON_ONCE(rq->crypt_keyslot))
> +		__blk_crypto_rq_put_keyslot(rq);
>  }

I received a report that this WARN_ON_ONCE can be hit.

To fix this, attempt_merge() will need to release the keyslot too.

- Eric
