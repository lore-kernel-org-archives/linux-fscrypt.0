Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B76CEC433EF
	for <linux-fscrypt@archiver.kernel.org>; Sat, 18 Jun 2022 14:00:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234158AbiFRNxM (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 18 Jun 2022 09:53:12 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48250 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234185AbiFRNw7 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 18 Jun 2022 09:52:59 -0400
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 289E01104
        for <linux-fscrypt@vger.kernel.org>; Sat, 18 Jun 2022 06:52:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
        by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1E4BE13F5;
        Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
        id 1CBADE4F1D; Sat, 18 Jun 2022 09:52:14 -0400 (EDT)
From:   James Simmons <jsimmons@infradead.org>
To:     Eric Biggers <ebiggers@google.com>,
        Andreas Dilger <adilger@whamcloud.com>,
        NeilBrown <neilb@suse.de>
Cc:     linux-fscrypt@vger.kernel.org, Alex Zhuravlev <bzzz@whamcloud.com>,
        James Simmons <jsimmons@infradead.org>
Subject: [PATCH 14/28] lnet: libcfs: reset hs_rehash_bits
Date:   Sat, 18 Jun 2022 09:51:56 -0400
Message-Id: <1655560330-30743-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
References: <1655560330-30743-1-git-send-email-jsimmons@infradead.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

if rehash work is cancelled, then nobody resets
hs_rehash_bits and the first iterator asserts
at LASSERT(!cfs_hash_is_rehashing(hs)) in
cfs_hash_for_each_relax().

WC-bug-id: https://jira.whamcloud.com/browse/LU-15207
Lustre-commit: 9257f24dfdf9f0a68 ("LU-15207 libcfs: reset hs_rehash_bits")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45533
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/hash.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/lnet/libcfs/hash.c b/net/lnet/libcfs/hash.c
index d060eaa..c9ff92d 100644
--- a/net/lnet/libcfs/hash.c
+++ b/net/lnet/libcfs/hash.c
@@ -1765,8 +1765,15 @@ struct cfs_hash_cond_arg {
 void
 cfs_hash_rehash_cancel(struct cfs_hash *hs)
 {
-	LASSERT(cfs_hash_with_rehash(hs));
-	cancel_work_sync(&hs->hs_rehash_work);
+	LASSERT(hs->hs_iterators > 0 || hs->hs_exiting);
+	while (cfs_hash_is_rehashing(hs)) {
+		if (cancel_work_sync(&hs->hs_rehash_work)) {
+			cfs_hash_lock(hs, 1);
+			hs->hs_rehash_bits = 0;
+			cfs_hash_unlock(hs, 1);
+		}
+		cond_resched();
+	}
 }
 
 void
-- 
1.8.3.1

