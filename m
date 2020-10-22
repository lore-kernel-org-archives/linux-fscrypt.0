Return-Path: <SRS0=mk+/=D5=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E6FB1C388F7
	for <linux-fscrypt@archiver.kernel.org>; Thu, 22 Oct 2020 21:22:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 914CB24654
	for <linux-fscrypt@archiver.kernel.org>; Thu, 22 Oct 2020 21:22:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LQlgaypn"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S372275AbgJVVWe (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 22 Oct 2020 17:22:34 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40966 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2897384AbgJVVWc (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 22 Oct 2020 17:22:32 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 19180C0613CF;
        Thu, 22 Oct 2020 14:22:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
        Content-Type:Content-ID:Content-Description;
        bh=RSNjd1RLqIQkhcEbGUovOOxZITaIfVGPNuDnxyQq0O0=; b=LQlgaypn3igScLoea4+gSyLtDO
        NgxFuTmVDAvbUR6Mi/cmnLGwkbNlYBerd7Gbv68PgnB8LalSSsm5yt3lrlZBIkqoMzT/zwFGJvwPq
        byTgnZ+leAHcuntvPibg2KNXOVolHVRb6RjhrEP7nq7uhkTxK0z9ETsIm+DLM/11LSuydqYTmNMKY
        lt3UumJ1VjKVBpDrrNiLz49FQuFC1ZYUk4avMBZx6vUMxN66LcJB4czs4QOs5J93fgXDlBy79YLXf
        ot5e7sFA3vU/NAb8jz5nYTdWwb36BbwVl/BI8BpL12pxOj8lEIFt18SAJMesVRRzreEY2PIfy0ngd
        AhfcjQzA==;
Received: from willy by casper.infradead.org with local (Exim 4.92.3 #3 (Red Hat Linux))
        id 1kVi2Y-00046K-Gc; Thu, 22 Oct 2020 21:22:30 +0000
From:   "Matthew Wilcox (Oracle)" <willy@infradead.org>
To:     linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org
Cc:     "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 2/6] fs: Return error from block_read_full_page
Date:   Thu, 22 Oct 2020 22:22:24 +0100
Message-Id: <20201022212228.15703-3-willy@infradead.org>
X-Mailer: git-send-email 2.21.3
In-Reply-To: <20201022212228.15703-1-willy@infradead.org>
References: <20201022212228.15703-1-willy@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

If the filesystem returns an error from get_block, report it
instead of ineffectually setting PageError.  Don't bother starting
any I/Os in this case since they won't bring the page Uptodate.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 fs/buffer.c | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 1d5337517dcd..1b0ba1d59966 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2262,7 +2262,7 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 	sector_t iblock, lblock;
 	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
 	unsigned int blocksize, bbits;
-	int nr, i;
+	int nr, i, err = 0;
 	int fully_mapped = 1;
 
 	head = create_page_buffers(page, inode, 0);
@@ -2280,19 +2280,16 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 			continue;
 
 		if (!buffer_mapped(bh)) {
-			int err = 0;
-
 			fully_mapped = 0;
 			if (iblock < lblock) {
 				WARN_ON(bh->b_size != blocksize);
 				err = get_block(inode, iblock, bh, 0);
 				if (err)
-					SetPageError(page);
+					break;
 			}
 			if (!buffer_mapped(bh)) {
 				zero_user(page, i * blocksize, blocksize);
-				if (!err)
-					set_buffer_uptodate(bh);
+				set_buffer_uptodate(bh);
 				continue;
 			}
 			/*
@@ -2305,18 +2302,17 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 		arr[nr++] = bh;
 	} while (i++, iblock++, (bh = bh->b_this_page) != head);
 
+	if (err) {
+		unlock_page(page);
+		return err;
+	}
 	if (fully_mapped)
 		SetPageMappedToDisk(page);
 
 	if (!nr) {
-		/*
-		 * All buffers are uptodate - we can set the page uptodate
-		 * as well. But not if get_block() returned an error.
-		 */
-		if (!PageError(page))
-			SetPageUptodate(page);
-		unlock_page(page);
-		return 0;
+		/* All buffers are uptodate - we can set the page uptodate */
+		SetPageUptodate(page);
+		return AOP_UPDATED_PAGE;
 	}
 
 	/* Stage two: lock the buffers */
-- 
2.28.0

