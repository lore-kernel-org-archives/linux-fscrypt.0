Return-Path: <SRS0=mk+/=D5=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 831F5C5DF9D
	for <linux-fscrypt@archiver.kernel.org>; Thu, 22 Oct 2020 21:22:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2A09B24641
	for <linux-fscrypt@archiver.kernel.org>; Thu, 22 Oct 2020 21:22:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="o06/f9Qv"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S372259AbgJVVWd (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 22 Oct 2020 17:22:33 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40968 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2897748AbgJVVWc (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 22 Oct 2020 17:22:32 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1E405C0613D2;
        Thu, 22 Oct 2020 14:22:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:Content-ID:
        Content-Description:In-Reply-To:References;
        bh=/G6plsTDuLLi41lWwfSKsVW5KJYWwk8QiIuvJmYW4EE=; b=o06/f9QvYVKSEgEE6eVUb3zkXe
        95w1+d+U9YL2cmW3VGydPZjeh1XGu7Bex8YVd11m7tNBge/S6CH6MF0XuWCpj4fOocm4ZQTgJPz9v
        U1hRS4O2yA4PbvlxaqvC9Qb+UmIGsvsRUdfq/xh1gbn3znx5S2FnyOTTpwdWsuA3LuKUXoehYOjNg
        CP7fowiv+vy2jJ/cCV4b2RKVYZnUucdYwr94XC2VtORxS5Yw7g4g0/9MZWj5GzIf+GN9ZDEO+t97X
        h0jN9egTDojBTvM0xogn2XcPj8y/bdo2p6t/46W9HbvYI11K1DY2y7X4PJBPXQ6PWelUtyYfzpbbr
        82bSsL/w==;
Received: from willy by casper.infradead.org with local (Exim 4.92.3 #3 (Red Hat Linux))
        id 1kVi2X-00046C-Bg; Thu, 22 Oct 2020 21:22:30 +0000
From:   "Matthew Wilcox (Oracle)" <willy@infradead.org>
To:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org
Cc:     "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 0/6] Make block_read_full_page synchronous
Date:   Thu, 22 Oct 2020 22:22:22 +0100
Message-Id: <20201022212228.15703-1-willy@infradead.org>
X-Mailer: git-send-email 2.21.3
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

This patchset does I/Os in larger chunks, if the blocks are adjacent.
More importantly, it returns the actual error from ->readpage for
filesystems which use block_read_full_page().  Unless fscrypt returns
an error, in which case it turns into EIO because it has to roundtrip
through bi_status.

I don't have a system with fscrypt enabled, so I'd appreciate some
testing from the fscrypt people.

Matthew Wilcox (Oracle) (6):
  block: Add blk_completion
  fs: Return error from block_read_full_page
  fs: Convert block_read_full_page to be synchronous
  fs: Hoist fscrypt decryption to bio completion handler
  fs: Turn decrypt_bh into decrypt_bio
  fs: Convert block_read_full_page to be synchronous with fscrypt
    enabled

 block/blk-core.c    |  61 +++++++++
 fs/buffer.c         | 304 ++++++++++++++++++++++----------------------
 include/linux/bio.h |  11 ++
 3 files changed, 226 insertions(+), 150 deletions(-)

-- 
2.28.0

