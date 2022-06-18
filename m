Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8452CCA473
	for <linux-fscrypt@archiver.kernel.org>; Sat, 18 Jun 2022 14:00:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234449AbiFRNxN (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 18 Jun 2022 09:53:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48508 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234351AbiFRNxI (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 18 Jun 2022 09:53:08 -0400
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0236655AD
        for <linux-fscrypt@vger.kernel.org>; Sat, 18 Jun 2022 06:53:07 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
        by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2B6F113F8;
        Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
        id 29F56DC803; Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
From:   James Simmons <jsimmons@infradead.org>
To:     Eric Biggers <ebiggers@google.com>,
        Andreas Dilger <adilger@whamcloud.com>,
        NeilBrown <neilb@suse.de>
Cc:     linux-fscrypt@vger.kernel.org,
        Patrick Farrell <pfarrell@whamcloud.com>,
        James Simmons <jsimmons@infradead.org>
Subject: [PATCH 17/28] lustre: llite: Add FID to async ra iotrace
Date:   Sat, 18 Jun 2022 09:51:59 -0400
Message-Id: <1655560330-30743-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
References: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Patrick Farrell <pfarrell@whamcloud.com>

IOtrace log entries need to include the FID of the file
concerned.  Add this to async readahead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15317
Lustre-commit: 1f3ecfdbb4c765808 ("LU-15317 llite: Add FID to async ra iotrace")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45912
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 1c2f027..c807217 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -596,9 +596,9 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 	sbi = ll_i2sbi(inode);
 
 	CDEBUG(D_READA|D_IOTRACE,
-	       "%s: async ra from %lu to %lu triggered by user pid %d\n",
-	       file_dentry(file)->d_name.name, work->lrw_start_idx,
-	       work->lrw_end_idx, work->lrw_user_pid);
+	       "%s:"DFID": async ra from %lu to %lu triggered by user pid %d\n",
+	       file_dentry(file)->d_name.name, PFID(ll_inode2fid(inode)),
+	       work->lrw_start_idx, work->lrw_end_idx, work->lrw_user_pid);
 
 	env = cl_env_alloc(&refcheck, LCT_NOREF);
 	if (IS_ERR(env)) {
-- 
1.8.3.1

