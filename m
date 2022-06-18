Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1983CCA47C
	for <linux-fscrypt@archiver.kernel.org>; Sat, 18 Jun 2022 13:52:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234117AbiFRNwl (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 18 Jun 2022 09:52:41 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47654 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233710AbiFRNwa (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 18 Jun 2022 09:52:30 -0400
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 858901D328
        for <linux-fscrypt@vger.kernel.org>; Sat, 18 Jun 2022 06:52:28 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
        by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0807813CD;
        Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
        id F34B2100388; Sat, 18 Jun 2022 09:52:13 -0400 (EDT)
From:   James Simmons <jsimmons@infradead.org>
To:     Eric Biggers <ebiggers@google.com>,
        Andreas Dilger <adilger@whamcloud.com>,
        NeilBrown <neilb@suse.de>
Cc:     linux-fscrypt@vger.kernel.org,
        Alexander Boyko <alexander.boyko@hpe.com>,
        James Simmons <jsimmons@infradead.org>
Subject: [PATCH 07/28] lustre: lmv: try another MDT if statfs failed
Date:   Sat, 18 Jun 2022 09:51:49 -0400
Message-Id: <1655560330-30743-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
References: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Alexander Boyko <alexander.boyko@hpe.com>

With lazystatfs option statfs could fail if MDT0 is offline.
This leads to MPICH->IOR fail during FOFB tests. A client
could get statfs data from different MDT at DNE setup.

HPE-bug-id: LUS-10581
WC-bug-id: https://jira.whamcloud.com/browse/LU-15788
Lustre-commit: 57f3262baa7d89311 ("LU-15788 lmv: try another MDT if statfs failed")
Signed-off-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/47152
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index d83ba41ff..3af7a53 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1233,6 +1233,7 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 	u32 i;
 	u32 idx;
 	int rc = 0;
+	int err = 0;
 
 	temp = kzalloc(sizeof(*temp), GFP_NOFS);
 	if (!temp)
@@ -1252,6 +1253,10 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 		if (rc) {
 			CERROR("%s: can't stat MDS #%d: rc = %d\n",
 			       tgt->ltd_exp->exp_obd->obd_name, i, rc);
+			err = rc;
+			/* Try another MDT */
+			if (flags & OBD_STATFS_SUM)
+				continue;
 			goto out_free_temp;
 		}
 
@@ -1266,7 +1271,7 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 			 * service
 			 */
 			*osfs = *temp;
-			break;
+			goto out_free_temp;
 		}
 
 		if (i == 0) {
@@ -1279,7 +1284,9 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 			osfs->os_granted += temp->os_granted;
 		}
 	}
-
+	/* There is no stats from some MDTs, data incomplete */
+	if (err)
+		rc = err;
 out_free_temp:
 	kfree(temp);
 	return rc;
-- 
1.8.3.1

