Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF34CC43334
	for <linux-fscrypt@archiver.kernel.org>; Sat, 18 Jun 2022 14:01:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234392AbiFRNxM (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 18 Jun 2022 09:53:12 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48358 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234228AbiFRNxE (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 18 Jun 2022 09:53:04 -0400
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 76A4610F3
        for <linux-fscrypt@vger.kernel.org>; Sat, 18 Jun 2022 06:53:01 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
        by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 258EF13F6;
        Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
        id 21556E9152; Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
From:   James Simmons <jsimmons@infradead.org>
To:     Eric Biggers <ebiggers@google.com>,
        Andreas Dilger <adilger@whamcloud.com>,
        NeilBrown <neilb@suse.de>
Cc:     linux-fscrypt@vger.kernel.org,
        Patrick Farrell <pfarrell@whamcloud.com>,
        James Simmons <jsimmons@infradead.org>
Subject: [PATCH 15/28] lustre: llite: Make iotrace logging quieter
Date:   Sat, 18 Jun 2022 09:51:57 -0400
Message-Id: <1655560330-30743-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
References: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Patrick Farrell <pfarrell@whamcloud.com>

Most of the time, we don't read any pages with readahead,
since we're moving through the window and aren't ready to
read more yet.  That's important for readahead debug, but
there's no need to log it for iotrace.  (This matters
because without this change, this message is the large
majority of iotrace messages.)

WC-bug-id: https://jira.whamcloud.com/browse/LU-15317
Lustre-commit: a91b5d4a990c6a870 ("LU-15317 llite: Make iotrace logging quieter")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45887
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index bd02a28..239f78b 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1692,7 +1692,10 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		rc2 = ll_readahead(env, io, &queue->c2_qin, ras,
 				   uptodate, file, skip_index,
 				   &ra_start_index);
-		CDEBUG(D_READA|D_IOTRACE,
+		/* to keep iotrace clean, we only print here if we actually
+		 * read pages
+		 */
+		CDEBUG(D_READA | (rc2 ? D_IOTRACE : 0),
 		       DFID " %d pages read ahead at %lu, triggered by user read at %lu\n",
 		       PFID(ll_inode2fid(inode)), rc2, ra_start_index,
 		       vvp_index(vpg));
-- 
1.8.3.1

