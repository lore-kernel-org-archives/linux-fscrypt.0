Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9496AC61DA4
	for <linux-fscrypt@archiver.kernel.org>; Wed, 15 Mar 2023 16:24:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230018AbjCOQYH (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 15 Mar 2023 12:24:07 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48766 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231290AbjCOQYF (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 15 Mar 2023 12:24:05 -0400
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C91DF1BAC8;
        Wed, 15 Mar 2023 09:24:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=MzL2E4kJRGo52zqlVIEvWwX2giv4pHoxhBGFe7cmoo8=; b=yWQG9MsGwG8mPqiXekRL/30U9F
        PeecthtpB1b79LuGMRq7ZCS1zoE3S16DcCw8VqZtmg59HEP1zfYDB4s0v9FO/ZmfHFJtY4edm3Cra
        8pOt4QDYvuPoaNM+BArSI8IsU7D25RXO1LyVZklOAERtLQs0hPeScRM9kL+CL4PPg4jKEnt1YKMtP
        t7ydft5o0qp39m4ASFsLXPtdzVbUir9UkPuqP7A7a7qkhe3mTQzT4zKndQG3ypiDr+8yCKrqDg3oE
        vRZd8KbGAZWOENkvlZ0XcBAOqCc7ZLy/gftY6RSQ+KT5cG2pANH/4sjvZ3OBcpbOUqW4D3WVFJUpe
        vl1OvaPA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.96 #2 (Red Hat Linux))
        id 1pcTv2-00E39A-2F;
        Wed, 15 Mar 2023 16:24:04 +0000
Date:   Wed, 15 Mar 2023 09:24:04 -0700
From:   Christoph Hellwig <hch@infradead.org>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     linux-block@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
        linux-fscrypt@vger.kernel.org,
        Nathan Huckleberry <nhuck@google.com>
Subject: Re: [PATCH v2 3/4] blk-crypto: remove
 blk_crypto_insert_cloned_request()
Message-ID: <ZBHxJK+MAGIBmHOU@infradead.org>
References: <20230308193645.114069-1-ebiggers@kernel.org>
 <20230308193645.114069-4-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230308193645.114069-4-ebiggers@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

> -	if (blk_crypto_insert_cloned_request(rq))
> +	if (blk_crypto_rq_get_keyslot(rq))
>  		return BLK_STS_IOERR;

Wouldn't it be better to propagate the actual error from
blk_crypto_rq_get_keyslot?

