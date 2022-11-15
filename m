Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 459BCC433FE
	for <linux-fscrypt@archiver.kernel.org>; Tue, 15 Nov 2022 09:06:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233081AbiKOJGR (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 15 Nov 2022 04:06:17 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36994 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231700AbiKOJGQ (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 15 Nov 2022 04:06:16 -0500
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8938C18393;
        Tue, 15 Nov 2022 01:06:15 -0800 (PST)
Received: by verein.lst.de (Postfix, from userid 2407)
        id 6240367373; Tue, 15 Nov 2022 10:06:12 +0100 (CET)
Date:   Tue, 15 Nov 2022 10:06:12 +0100
From:   Christoph Hellwig <hch@lst.de>
To:     Jens Axboe <axboe@kernel.dk>
Cc:     linux-block@vger.kernel.org, "Theodore Y. Ts'o" <tytso@mit.edu>,
        Mike Snitzer <snitzer@kernel.org>,
        linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@kernel.org>,
        dm-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [dm-devel] [PATCH 3/3] blk-crypto: move internal only
 declarations to blk-crypto-internal.h
Message-ID: <20221115090612.GA22190@lst.de>
References: <20221114042944.1009870-1-hch@lst.de> <20221114042944.1009870-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221114042944.1009870-4-hch@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Nov 14, 2022 at 05:29:44AM +0100, Christoph Hellwig wrote:
>  blk_crypto_get_keyslot, blk_crypto_put_keyslot, __blk_crypto_evict_key
> and __blk_crypto_cfg_supported are only used internally by the
> blk-crypto code, so move the out of blk-crypto-profile.h, which is
> included by drivers that supply blk-crypto functionality.

The buildbot complained that blk-crypto-profile.c now needs a
blk-crypto-internal.h include, which can be done by folding this in:

diff --git a/block/blk-crypto-profile.c b/block/blk-crypto-profile.c
index 96c511967386d..0307fb0d95d34 100644
--- a/block/blk-crypto-profile.c
+++ b/block/blk-crypto-profile.c
@@ -32,6 +32,7 @@
 #include <linux/wait.h>
 #include <linux/blkdev.h>
 #include <linux/blk-integrity.h>
+#include "blk-crypto-internal.h"
 
 struct blk_crypto_keyslot {
 	atomic_t slot_refs;
