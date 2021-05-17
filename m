Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 486C3C433B4
	for <linux-fscrypt@archiver.kernel.org>; Mon, 17 May 2021 21:43:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 216A261285
	for <linux-fscrypt@archiver.kernel.org>; Mon, 17 May 2021 21:43:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236682AbhEQVoR (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 17 May 2021 17:44:17 -0400
Received: from mx2.suse.de ([195.135.220.15]:51994 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S245462AbhEQVoO (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 17 May 2021 17:44:14 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
        by mx2.suse.de (Postfix) with ESMTP id 44144ACFD;
        Mon, 17 May 2021 21:42:56 +0000 (UTC)
Received: by ds.suse.cz (Postfix, from userid 10065)
        id A4045DB228; Mon, 17 May 2021 23:40:23 +0200 (CEST)
Date:   Mon, 17 May 2021 23:40:23 +0200
From:   David Sterba <dsterba@suse.cz>
To:     Boris Burkov <boris@bur.io>
Cc:     dsterba@suse.cz, linux-btrfs@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, kernel-team@fb.com
Subject: Re: [PATCH v4 2/5] btrfs: initial fsverity support
Message-ID: <20210517214023.GR7604@twin.jikos.cz>
Reply-To: dsterba@suse.cz
Mail-Followup-To: dsterba@suse.cz, Boris Burkov <boris@bur.io>,
        linux-btrfs@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        kernel-team@fb.com
References: <cover.1620240133.git.boris@bur.io>
 <dd0cfc38c6de927de63f34f96499dc8f80398754.1620241221.git.boris@bur.io>
 <20210511203143.GN7604@twin.jikos.cz>
 <YJ17yjaMwJTH+GtU@zen>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <YJ17yjaMwJTH+GtU@zen>
User-Agent: Mutt/1.5.23.1-rc1 (2014-03-12)
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, May 13, 2021 at 12:19:38PM -0700, Boris Burkov wrote:
> On Tue, May 11, 2021 at 10:31:43PM +0200, David Sterba wrote:
> > On Wed, May 05, 2021 at 12:20:40PM -0700, Boris Burkov wrote:
> > > +	/* zero fill any bytes we didn't write into the page */
> > > +	if (ret < PAGE_SIZE) {
> > > +		char *kaddr = kmap_atomic(p);
> > > +
> > > +		memset(kaddr + ret, 0, PAGE_SIZE - ret);
> > > +		kunmap_atomic(kaddr);
> > 
> > There's helper memzero_page wrapping the kmap
> 
> FWIW, that helper uses kmap_atomic, not kmap_local_page. Would you
> prefer I use the helper or not introduce new uses of kmap_atomic?

Please use the memzero_page helper, see d048b9c2a737eb791a5e9 "btrfs:
use memzero_page() instead of open coded kmap pattern" for more details.
