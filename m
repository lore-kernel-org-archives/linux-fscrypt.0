Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEF60CCA480
	for <linux-fscrypt@archiver.kernel.org>; Sat, 18 Jun 2022 14:02:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229768AbiFROBK (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 18 Jun 2022 10:01:10 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48462 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234319AbiFRNxH (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 18 Jun 2022 09:53:07 -0400
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DAEB110F3
        for <linux-fscrypt@vger.kernel.org>; Sat, 18 Jun 2022 06:53:04 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
        by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 274B413F7;
        Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
        id 24B2DFD3BF; Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
From:   James Simmons <jsimmons@infradead.org>
To:     Eric Biggers <ebiggers@google.com>,
        Andreas Dilger <adilger@whamcloud.com>,
        NeilBrown <neilb@suse.de>
Cc:     linux-fscrypt@vger.kernel.org,
        Patrick Farrell <pfarrell@whamcloud.com>,
        James Simmons <jsimmons@infradead.org>
Subject: [PATCH 16/28] lustre: llite: Add strided readahead to iotrace
Date:   Sat, 18 Jun 2022 09:51:58 -0400
Message-Id: <1655560330-30743-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
References: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Patrick Farrell <pfarrell@whamcloud.com>

We need to capture some additional parameters to correctly
understand the behavior of strided readahead.  Add these
parameters to the existing iotrace message.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15317
Lustre-commit: 5ed185955985b099b ("LU-15317 llite: Add strided readahead to iotrace")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45888
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 239f78b..1c2f027 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1696,9 +1696,11 @@ int ll_io_read_page(const struct lu_env *env, struct cl_io *io,
 		 * read pages
 		 */
 		CDEBUG(D_READA | (rc2 ? D_IOTRACE : 0),
-		       DFID " %d pages read ahead at %lu, triggered by user read at %lu\n",
+		       DFID " %d pages read ahead at %lu, triggered by user read at %lu, stride offset %lld, stride length %lld, stride bytes %lld\n",
 		       PFID(ll_inode2fid(inode)), rc2, ra_start_index,
-		       vvp_index(vpg));
+		       vvp_index(vpg), ras->ras_stride_offset,
+		       ras->ras_stride_length, ras->ras_stride_bytes);
+
 	} else if (vvp_index(vpg) == io_start_index &&
 		   io_end_index - io_start_index > 0) {
 		rc2 = ll_readpages(env, io, &queue->c2_qin, io_start_index + 1,
-- 
1.8.3.1

