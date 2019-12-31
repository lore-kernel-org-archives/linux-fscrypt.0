Return-Path: <SRS0=WoLH=2V=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39876C2D0C2
	for <linux-fscrypt@archiver.kernel.org>; Tue, 31 Dec 2019 18:15:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0CDBD206E4
	for <linux-fscrypt@archiver.kernel.org>; Tue, 31 Dec 2019 18:15:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1577816118;
	bh=R7F0k84TKiRuXBbh08JjpWu+dILQdgBWUuwJnRPVITs=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=bc1gaFvyhA/CMzX+kBo1ISDsHyAKysJgUAd5CcqqLlr7gAc0JMW1c/C9jaYDECSd2
	 x8DRQahihgSD3ui4EsPncIZ9b8asDZLxioH9Kz5REqVyI5PTaiZgkGo0PmQOR0ZvMv
	 L0YoRyzliDVDC9RQ95fEZmEy3GH9NTjTJLWWr7xY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727079AbfLaSPR (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 31 Dec 2019 13:15:17 -0500
Received: from mail.kernel.org ([198.145.29.99]:52152 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726720AbfLaSPR (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 31 Dec 2019 13:15:17 -0500
Received: from zzz.tds (h75-100-12-111.burkwi.broadband.dynamic.tds.net [75.100.12.111])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id E9F58206E0;
        Tue, 31 Dec 2019 18:15:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1577816117;
        bh=R7F0k84TKiRuXBbh08JjpWu+dILQdgBWUuwJnRPVITs=;
        h=From:To:Cc:Subject:Date:From;
        b=VvBZ6DKLJT67FOwaf2TjKTfeJkQtxdwc1JKZLSGwK7uxvTFC0Yen37Bm4uySTPGit
         8Iq+XBuHVNxJN9Z0/rGmLuz31TE7TdPcRtlOrOYjFeoZuect9/f2tFsFXhla5wgpv4
         +NKXpZwcV8tBvHd2cqOsJWT9qDan88gnaAgejH8Q=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-f2fs-devel@lists.sourceforge.net
Cc:     linux-fscrypt@vger.kernel.org
Subject: [PATCH] f2fs: remove unneeded check for error allocating bio_post_read_ctx
Date:   Tue, 31 Dec 2019 12:14:56 -0600
Message-Id: <20191231181456.47957-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.24.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Since allocating an object from a mempool never fails when
__GFP_DIRECT_RECLAIM (which is included in GFP_NOFS) is set, the check
for failure to allocate a bio_post_read_ctx is unnecessary.  Remove it.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/data.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 618a05bf356e..b52e1512f82e 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -939,11 +939,8 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
 		post_read_steps |= 1 << STEP_VERITY;
 
 	if (post_read_steps) {
+		/* Due to the mempool, this never fails. */
 		ctx = mempool_alloc(bio_post_read_ctx_pool, GFP_NOFS);
-		if (!ctx) {
-			bio_put(bio);
-			return ERR_PTR(-ENOMEM);
-		}
 		ctx->bio = bio;
 		ctx->sbi = sbi;
 		ctx->enabled_steps = post_read_steps;
-- 
2.24.1

