Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3576C28B2B
	for <linux-fscrypt@archiver.kernel.org>; Fri, 19 Aug 2022 18:29:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1349888AbiHSS3g (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 19 Aug 2022 14:29:36 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49220 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1349836AbiHSS3f (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 19 Aug 2022 14:29:35 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id F0237B9FAA;
        Fri, 19 Aug 2022 11:29:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=In-Reply-To:Content-Transfer-Encoding:
        Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
        Sender:Reply-To:Content-ID:Content-Description;
        bh=tRmulA9MYitS9V7mq6tp/E2s8wqbaq1BnhDYkrBdwQ8=; b=OnHpY95+82flCzCoLXpUuAH1cy
        GRKLwKV1XlKXIH8FUN0CWnVsrrBckCchGW/AJv/VXovgjAUSCQsRbcmucPufPJ/QAnt+021O9pvy0
        zUG83HHWb3Zz4ViVYznQRrURlv6X5VrAqxUqR6SYPMl7VNtuAr1bCaYWa6Iw4tlAo4oAX2gQ1P/Xt
        4UWELuu8U4e2j5Dg1ZG4QtTz03mJ+gzwyMYLuMt0Xx1A5q3qjv8C4WcQkHXkSc86EeFSx415RhfQ2
        38iH/L5yg8dSNxuSC8DsjQidbY2r6dLl1YxRjYygCJIVI1BH3lR2b38VdzdKVvU9QyLyFNU0LlXmX
        f8uOBXyQ==;
Received: from willy by casper.infradead.org with local (Exim 4.94.2 #2 (Red Hat Linux))
        id 1oP6kN-00BT8E-Iy; Fri, 19 Aug 2022 18:29:31 +0000
Date:   Fri, 19 Aug 2022 19:29:31 +0100
From:   Matthew Wilcox <willy@infradead.org>
To:     "Fabio M. De Francesco" <fmdefrancesco@gmail.com>
Cc:     linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] fs-verity: use kmap_local_page() instead of kmap()
Message-ID: <Yv/Wi/2IH/bY05zG@casper.infradead.org>
References: <20220818224010.43778-1-ebiggers@kernel.org>
 <44912540.fMDQidcC6G@opensuse>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <44912540.fMDQidcC6G@opensuse>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Fri, Aug 19, 2022 at 09:50:37AM +0200, Fabio M. De Francesco wrote:
> On venerdì 19 agosto 2022 00:40:10 CEST Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Convert the use of kmap() to its recommended replacement
> > kmap_local_page().  This avoids the overhead of doing a non-local
> > mapping, which is unnecessary in this case.
> > 
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > ---
> >  fs/verity/read_metadata.c | 6 +++---
> >  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> It looks good to me...
> 
> > -		virt = kmap(page);
> > +		virt = kmap_local_page(page);
> >  		if (copy_to_user(buf, virt + offs_in_page, bytes_to_copy)) 
> {
> > -			kunmap(page);
> > +			kunmap_local(virt);
> >  			put_page(page);
> >  			err = -EFAULT;
> >  			break;
> >  		}
> > -		kunmap(page);
> > +		kunmap_local(virt);

Is this a common pattern?  eg do we want something like:

static inline int copy_user_page(void __user *dst, struct page *page,
		size_t offset, size_t len)
{
	char *src = kmap_local_page(page) + offset;
	int err = 0;

	VM_BUG_ON(offset + len > PAGE_SIZE);
	if (copy_to_user(dst, src, len))
		err = -EFAULT;

	kunmap_local(src);
	return err;
}

in highmem.h?
