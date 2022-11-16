Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13FE9C433FE
	for <linux-fscrypt@archiver.kernel.org>; Wed, 16 Nov 2022 03:12:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230244AbiKPDMn (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 15 Nov 2022 22:12:43 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38058 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231913AbiKPDMm (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 15 Nov 2022 22:12:42 -0500
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D94B426127;
        Tue, 15 Nov 2022 19:12:41 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 5433661874;
        Wed, 16 Nov 2022 03:12:41 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6FCB8C433D7;
        Wed, 16 Nov 2022 03:12:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1668568360;
        bh=4zIONx84uJ4Smf53vWQeOyaNKDGVIR7gaI+D4iv0VL8=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=aHslP9bRf4+uO86mjPWeocs5TIR7SX5cIfGHvnzbI3INakyPBvA+vfpNTcFGey8o9
         +OFJQyHXiiytU4g0zDAwIGERM1Z3zYMWZwQLfUtuTPLdfhDX0A+XD+1scDDc9/rZ1M
         ypO120iEe1aAsPPlVZhNZmv4NIepngjE559hK41G26YLTVgXD8C+DTxQG8XxPvzcsz
         Nvh82YpUThZBdMYI7FDZiAjzRrhrTXQfWVjkUCW/VJDo5EFiPsv1UyUx+c8Yqo5fCr
         jLyc4Cv4dvPhw9Adxb2GO6+qnqWviI2VGjNKaPgLwKqU2/Tuhd8y8gYtKVL3QjxP5B
         lo3nmkdNnFX0w==
Date:   Tue, 15 Nov 2022 19:12:38 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     Christoph Hellwig <hch@lst.de>
Cc:     Jens Axboe <axboe@kernel.dk>, Mike Snitzer <snitzer@kernel.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>, dm-devel@redhat.com,
        linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH 2/3] blk-crypto: add a
 blk_crypto_config_supported_natively helper
Message-ID: <Y3RVJkcagipPquny@sol.localdomain>
References: <20221114042944.1009870-1-hch@lst.de>
 <20221114042944.1009870-3-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221114042944.1009870-3-hch@lst.de>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Nov 14, 2022 at 05:29:43AM +0100, Christoph Hellwig wrote:
> Add a blk_crypto_config_supported_natively helper that wraps
> __blk_crypto_cfg_supported to retrieve the crypto_profile from the
> request queue.  With this fscrypt can stop including
> blk-crypto-profile.h and rely on the public consumer interface in
> blk-crypto.h.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Eric Biggers <ebiggers@google.com>

- Eric
