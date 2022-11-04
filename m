Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 655F3C4332F
	for <linux-fscrypt@archiver.kernel.org>; Fri,  4 Nov 2022 07:32:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231425AbiKDHc2 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 4 Nov 2022 03:32:28 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58964 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231518AbiKDHcY (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 4 Nov 2022 03:32:24 -0400
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8F9001CB19;
        Fri,  4 Nov 2022 00:32:20 -0700 (PDT)
Received: by verein.lst.de (Postfix, from userid 2407)
        id 64F2968B05; Fri,  4 Nov 2022 08:32:16 +0100 (CET)
Date:   Fri, 4 Nov 2022 08:32:16 +0100
From:   Christoph Hellwig <hch@lst.de>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
        Mike Snitzer <snitzer@kernel.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>, dm-devel@redhat.com,
        linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH 1/2] blk-crypto: don't use struct request_queue for
 public interfaces
Message-ID: <20221104073216.GA18231@lst.de>
References: <20221104054621.628369-1-hch@lst.de> <20221104054621.628369-2-hch@lst.de> <Y2S/DfZTr90t6QXv@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Y2S/DfZTr90t6QXv@sol.localdomain>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Fri, Nov 04, 2022 at 12:28:13AM -0700, Eric Biggers wrote:
> Shouldn't the three places above still say request_queue, not block_device?
> They're talking about the driver.

Yes, probably.
