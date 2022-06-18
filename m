Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CDB0C433EF
	for <linux-fscrypt@archiver.kernel.org>; Sat, 18 Jun 2022 13:52:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233973AbiFRNwk (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 18 Jun 2022 09:52:40 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47628 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229542AbiFRNwZ (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 18 Jun 2022 09:52:25 -0400
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BB1941D328
        for <linux-fscrypt@vger.kernel.org>; Sat, 18 Jun 2022 06:52:24 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
        by smtp3.ccs.ornl.gov (Postfix) with ESMTP id F1DF113C6;
        Sat, 18 Jun 2022 09:52:13 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
        id E7D5A1002C9; Sat, 18 Jun 2022 09:52:13 -0400 (EDT)
From:   James Simmons <jsimmons@infradead.org>
To:     Eric Biggers <ebiggers@google.com>,
        Andreas Dilger <adilger@whamcloud.com>,
        NeilBrown <neilb@suse.de>
Cc:     linux-fscrypt@vger.kernel.org,
        Sergey Gorenko <sergeygo@mellanox.com>,
        James Simmons <jsimmons@infradead.org>
Subject: [PATCH 04/28] lnet: o2ib: Fix compilation with Linux 5.8
Date:   Sat, 18 Jun 2022 09:51:46 -0400
Message-Id: <1655560330-30743-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
References: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Sergey Gorenko <sergeygo@mellanox.com>

A new argument was added to rdma_reject() in Linux 5.8

WC-bug-id: https://jira.whamcloud.com/browse/LU-13761
Lustre-commit: 956deb0fe8195c7a0 ("LU-13761 o2ib: Fix compilation with MOFED 5.1")
Signed-off-by: Sergey Gorenko <sergeygo@mellanox.com>
Reviewed-on: https://review.whamcloud.com/39323
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index a88939e7..cb96282 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2323,8 +2323,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 {
 	int rc;
 
-	rc = rdma_reject(cmid, rej, sizeof(*rej));
-
+	rc = rdma_reject(cmid, rej, sizeof(*rej), IB_CM_REJ_CONSUMER_DEFINED);
 	if (rc)
 		CWARN("Error %d sending reject\n", rc);
 }
-- 
1.8.3.1

