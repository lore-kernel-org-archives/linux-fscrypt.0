Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B51EAC4742C
	for <linux-fscrypt@archiver.kernel.org>; Mon, 16 Nov 2020 16:34:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7909A222B9
	for <linux-fscrypt@archiver.kernel.org>; Mon, 16 Nov 2020 16:34:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="smzapFKc"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732126AbgKPQej (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 16 Nov 2020 11:34:39 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:35908 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730796AbgKPQei (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 16 Nov 2020 11:34:38 -0500
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BEFC6C0613CF;
        Mon, 16 Nov 2020 08:34:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Type:MIME-Version:
        References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description;
        bh=GCXoLOc8MpQmn8ikaTSjLpFrBJ22H9bazqhJ+XxfpWw=; b=smzapFKcJMTzYguzhtl3WcPBQo
        B3nASo14EP6YTdgx+Vx3/BGsHaL6jl8o7PsyntsU6RtfJFOVRVmgvC84DLDP8TOrpgOh18C7/wln7
        /O49fEKko5/qznyHNTv2vL+uF5d27yopKAkC7WbOch+LgeEOCoDYLVx5QTyxBoIr55/jFXxyU4k+R
        7rpuBJp+MgrbDe22JhqlXGavmHjr/2wEeFsCgywIOs0GLzYEts7jVRIyH/V2C3vCqiCOpZX+fXlB4
        g9fxJV4uJQBThS0+ks7eQXcWu+Z1qNYwXNkc4EFvMuQ6ki8VVYMN/jANpyj28fu/ojdWCMZBW7PeZ
        RbJDns+Q==;
Received: from hch by casper.infradead.org with local (Exim 4.92.3 #3 (Red Hat Linux))
        id 1kehSe-0004tZ-3Y; Mon, 16 Nov 2020 16:34:36 +0000
Date:   Mon, 16 Nov 2020 16:34:36 +0000
From:   Christoph Hellwig <hch@infradead.org>
To:     Satya Tangirala <satyat@google.com>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Eric Biggers <ebiggers@kernel.org>,
        linux-block@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
        linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH] block/keyslot-manager: prevent crash when num_slots=1
Message-ID: <20201116163436.GA18778@infradead.org>
References: <20201111021427.466349-1-ebiggers@kernel.org>
 <20201111092305.GA13004@infradead.org>
 <20201111094538.GA3907007@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20201111094538.GA3907007@google.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by casper.infradead.org. See http://www.infradead.org/rpr.html
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Nov 11, 2020 at 09:45:38AM +0000, Satya Tangirala wrote:
> On Wed, Nov 11, 2020 at 09:23:05AM +0000, Christoph Hellwig wrote:
> > On Tue, Nov 10, 2020 at 06:14:27PM -0800, Eric Biggers wrote:
> > > +	 * hash_ptr() assumes bits != 0, so ensure the hash table has at least 2
> > > +	 * buckets.  This only makes a difference when there is only 1 keyslot.
> > > +	 */
> > > +	slot_hashtable_size = max(slot_hashtable_size, 2U);
> > 
> > shouldn't this be a min()?
> I think it should be max(), since we want whichever is larger between 2
> and the original slot_hashtable_size :)

Yes, of course.  Sorry for the noise.
