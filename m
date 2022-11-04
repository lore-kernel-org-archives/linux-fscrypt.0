Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7DF2C433FE
	for <linux-fscrypt@archiver.kernel.org>; Fri,  4 Nov 2022 07:32:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231379AbiKDHc4 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 4 Nov 2022 03:32:56 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59230 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231296AbiKDHcx (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 4 Nov 2022 03:32:53 -0400
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C796560FF;
        Fri,  4 Nov 2022 00:32:52 -0700 (PDT)
Received: by verein.lst.de (Postfix, from userid 2407)
        id A135F68BFE; Fri,  4 Nov 2022 08:32:49 +0100 (CET)
Date:   Fri, 4 Nov 2022 08:32:49 +0100
From:   Christoph Hellwig <hch@lst.de>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
        Mike Snitzer <snitzer@kernel.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>, dm-devel@redhat.com,
        linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH 2/2] blk-crypto: add a blk_crypto_cfg_supported helper
Message-ID: <20221104073249.GB18231@lst.de>
References: <20221104054621.628369-1-hch@lst.de> <20221104054621.628369-3-hch@lst.de> <Y2S927PXuEYM7xwJ@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Y2S927PXuEYM7xwJ@sol.localdomain>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Fri, Nov 04, 2022 at 12:23:07AM -0700, Eric Biggers wrote:
> > +bool blk_crypto_cfg_supported(struct block_device *bdev,
> > +			      const struct blk_crypto_config *cfg)
> > +{
> > +	return __blk_crypto_cfg_supported(bdev_get_queue(bdev)->crypto_profile,
> > +					  cfg);
> > +}
> 
> I think this part is too confusing, because there's already a function
> blk_crypto_config_supported() which does something slightly different.
> 
> How about calling this blk_crypto_config_supported_natively() instead?  It's
> kind of long, but it's much clearer.

Fine with me.

> Also, it should be defined in blk-crypto.c, next to
> blk_crypto_config_supported(), and not in blk-crypto-profile.c.
> (And declared in blk-crypto.h, not blk-crypto-profile.h.)

Ok.
