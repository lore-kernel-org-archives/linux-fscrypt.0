Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2109C433EF
	for <linux-fscrypt@archiver.kernel.org>; Sat, 18 Jun 2022 13:53:09 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230356AbiFRNw6 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 18 Jun 2022 09:52:58 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48032 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233293AbiFRNwu (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 18 Jun 2022 09:52:50 -0400
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 755E1206
        for <linux-fscrypt@vger.kernel.org>; Sat, 18 Jun 2022 06:52:40 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
        by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1327713D8;
        Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
        id 0C78FE9152; Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
From:   James Simmons <jsimmons@infradead.org>
To:     Eric Biggers <ebiggers@google.com>,
        Andreas Dilger <adilger@whamcloud.com>,
        NeilBrown <neilb@suse.de>
Cc:     linux-fscrypt@vger.kernel.org,
        Serguei Smirnov <ssmirnov@whamcloud.com>,
        James Simmons <jsimmons@infradead.org>
Subject: [PATCH 10/28] lnet: o2iblnd: clean up zombie connections on shutdown
Date:   Sat, 18 Jun 2022 09:51:52 -0400
Message-Id: <1655560330-30743-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
References: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Clean up zombie connections on net shutdown in o2iblnd
Wake up connd threads and wait for them to do the clean-up
before proceeding.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14503
Lustre-commit: 2a183829cdcc7008f ("LU-14503 o2iblnd: clean up zombie connections on shutdown")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/42068
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 8dce4179..65bc89b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2609,6 +2609,12 @@ static void kiblnd_shutdown(struct lnet_ni *ni)
 		list_del(&net->ibn_list);
 		write_unlock_irqrestore(g_lock, flags);
 
+		wake_up_all(&kiblnd_data.kib_connd_waitq);
+		wait_var_event_warning(&net->ibn_nconns,
+				       atomic_read(&net->ibn_nconns) == 0,
+				       "%s: waiting for %d conns to clean\n",
+				       libcfs_nidstr(&ni->ni_nid),
+				       atomic_read(&net->ibn_nconns));
 		/* fall through */
 
 	case IBLND_INIT_NOTHING:
-- 
1.8.3.1

