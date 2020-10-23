Return-Path: <SRS0=liMg=D6=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6964C388F9
	for <linux-fscrypt@archiver.kernel.org>; Fri, 23 Oct 2020 20:42:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0673620882
	for <linux-fscrypt@archiver.kernel.org>; Fri, 23 Oct 2020 20:42:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nLRKQF5K"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1756268AbgJWUmN (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 23 Oct 2020 16:42:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59416 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756266AbgJWUmN (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 23 Oct 2020 16:42:13 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E6515C0613CE;
        Fri, 23 Oct 2020 13:42:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=HPNK4arnkW2Dq4M58HcOUzaclycvISxal8U4KN3Txio=; b=nLRKQF5KgnrgPpI/VAe1RNljYQ
        9W/uDSWFLEg+5sW/8dsvxg6gb26oN31X4825l5eV4eGhF7lPXdsPJDBOZgt3a4sifk3QmEsqtC5uH
        H2WInmO64irZy4SFAMbTGh/1JnBSJnIP5NqQltd/AKW38wZQPSQ59VXL0ydC41YfgsZaLasND1tWr
        JKZPlh3sSqkp7EWd1zbc9un46BWjRYQ2VGC8xti1T61Z7fNLF92WLYxq+iP/7tgSwu3b2hu6FkgoN
        JYUkcHubvHmvYwUALsxmMMfX4e/du/jDZ2AHt1ZK3OQTuhVuIgu9TwJfSxUewAwzDyhYPYtw+cDxW
        HMfvMtfA==;
Received: from willy by casper.infradead.org with local (Exim 4.92.3 #3 (Red Hat Linux))
        id 1kW3t4-0000TQ-MJ; Fri, 23 Oct 2020 20:42:11 +0000
Date:   Fri, 23 Oct 2020 21:42:10 +0100
From:   Matthew Wilcox <willy@infradead.org>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH 3/6] fs: Convert block_read_full_page to be synchronous
Message-ID: <20201023204210.GF20115@casper.infradead.org>
References: <20201022212228.15703-1-willy@infradead.org>
 <20201022212228.15703-4-willy@infradead.org>
 <20201022234011.GD3613750@gmail.com>
 <20201023132138.GB20115@casper.infradead.org>
 <20201023161335.GB3908702@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20201023161335.GB3908702@gmail.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Fri, Oct 23, 2020 at 09:13:35AM -0700, Eric Biggers wrote:
> On Fri, Oct 23, 2020 at 02:21:38PM +0100, Matthew Wilcox wrote:
> > I wonder about allocating bios that can accommodate more bvecs.  Not sure
> > how often filesystems have adjacent blocks which go into non-adjacent
> > sub-page blocks.  It's certainly possible that a filesystem might have
> > a page consisting of DDhhDDDD ('D' for Data, 'h' for hole), but how
> > likely is it to have written the two data chunks next to each other?
> > Maybe with O_SYNC?
> 
> I think that's a rare case that's not very important to optimize.  And there's
> already a lot of code where filesystems *could* submit a single bio in that case
> but don't.  For example, both fs/direct-io.c and fs/iomap/direct-io.c only
> submit bios that contain logically contiguous data.

True.  iomap/buffered-io.c will do it though.

> If you do implement this optimization, note that it wouldn't work when a
> bio_crypt_ctx is set, since the data must be logically contiguous in that case.
> To handle that you'd need to call fscrypt_mergeable_bio_bh() when adding each
> block, and submit the bio if it returns false.  (In contrast, with your current
> proposal, calling fscrypt_mergeable_bio_bh() isn't necessary because each bio
> only contains logically contiguous data within one page.)

Oh, that's disappointing.  I had assumed that you'd set up the dun for
the logical block corresponding to the start of the page and then you'd
be able to decrypt any range in the page.
