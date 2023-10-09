Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35C0FE95A8D
	for <linux-fscrypt@archiver.kernel.org>; Mon,  9 Oct 2023 03:44:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1345004AbjJIDoV (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sun, 8 Oct 2023 23:44:21 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54182 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1344883AbjJIDoU (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 8 Oct 2023 23:44:20 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2B2E4A6;
        Sun,  8 Oct 2023 20:44:19 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 81930C433C8;
        Mon,  9 Oct 2023 03:44:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1696823058;
        bh=qVDrf/trx8sq31i+yhHFC8rDIRV+sneM9PcsiTpytoY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=TSQ+Vig+v4Be77+/Dfu8Mh3kqpObFlaQ/ZPgqxjGOAxc3E2jiBYrs08M0w2bKE2p9
         YDFlSt0CDwHbPUmBojFAcB0DMm1yyMkDom3HnuVlSAFekexQCpzSDGX0Yryb2Y5WVB
         OUuLktWWM282XMBdlwvtfVODR8xwUdTyfKAqkWLQ6OYbBOXgWTUtxnZK8zYXeLDQpz
         ZrD4lSEDOwGo/BnWwcWTlF4aPT5BTte+/xrZIO50QvBGJ80+R3Q0fgTxSKOMtIwwLu
         rdm1yYeFS9PYip5hnatBwKZ8/BHqgpAfknxjMPxOOisOlmiKijVOdObD0aNwNfxRNc
         R4tCqGRJeCIdQ==
Date:   Sun, 8 Oct 2023 20:44:16 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Neal Gompa <neal@gompa.dev>
Cc:     linux-fscrypt@vger.kernel.org, linux-btrfs@vger.kernel.org,
        Sweet Tea Dorminy <sweettea-kernel@dorminy.me>,
        Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH] fscrypt: rename fscrypt_info => fscrypt_inode_info
Message-ID: <20231009034416.GA279961@sol.localdomain>
References: <20231005025757.33521-1-ebiggers@kernel.org>
 <CAEg-Je9giOLBVwuXAQ+F6do7sTBcCpP_ARbGA6TowTT+6GBc4g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEg-Je9giOLBVwuXAQ+F6do7sTBcCpP_ARbGA6TowTT+6GBc4g@mail.gmail.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Sun, Oct 08, 2023 at 02:11:36AM -0400, Neal Gompa wrote:
> 
> Looks reasonable to me.
> 
> Reviewed-by: Neal Gompa <neal@gompa.dev>
> 

Thanks.  BTW, please only quote the part that you're replying to.

- Eric
