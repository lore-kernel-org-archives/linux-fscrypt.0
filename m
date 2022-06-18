Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2487BCCA482
	for <linux-fscrypt@archiver.kernel.org>; Sat, 18 Jun 2022 14:01:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234268AbiFROAv (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 18 Jun 2022 10:00:51 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48920 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235992AbiFRNx2 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 18 Jun 2022 09:53:28 -0400
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D7688DFB6
        for <linux-fscrypt@vger.kernel.org>; Sat, 18 Jun 2022 06:53:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
        by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 4ED7C1E88;
        Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
        id 4D03ADC803; Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
From:   James Simmons <jsimmons@infradead.org>
To:     Eric Biggers <ebiggers@google.com>,
        Andreas Dilger <adilger@whamcloud.com>,
        NeilBrown <neilb@suse.de>
Cc:     linux-fscrypt@vger.kernel.org, Chris Horn <chris.horn@hpe.com>,
        James Simmons <jsimmons@infradead.org>
Subject: [PATCH 25/28] lnet: Return ESHUTDOWN in lnet_parse()
Date:   Sat, 18 Jun 2022 09:52:07 -0400
Message-Id: <1655560330-30743-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
References: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Chris Horn <chris.horn@hpe.com>

If the peer NI lookup in lnet_parse() fails with ESHUTDOWN then we
should return that value back to the LNDs so that they can treat the
failed call the same way as other lnet_parse() failures.

Returning zero results in at least one bug in socklnd where a
reference on a ksock_conn can be leaked which prevents socklnd from
shutting down.

Fixes: e426f0d24e ("staging: lustre: lnet: Do not drop message when shutting down LNet")
HPE-bug-id: LUS-15794
WC-bug-id: https://jira.whamcloud.com/browse/LU-15618
Lustre-commit: 4fbd0705a3d25bbc8 ("LU-15618 lnet: Return ESHUTDOWN in lnet_parse()")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/46711
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 9ee1075..0c5bf82 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4425,7 +4425,7 @@ void lnet_monitor_thr_stop(void)
 		kfree(msg);
 		if (rc == -ESHUTDOWN)
 			/* We are shutting down. Don't do anything more */
-			return 0;
+			return rc;
 		goto drop;
 	}
 
-- 
1.8.3.1

