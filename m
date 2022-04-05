Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE1C3C4707F
	for <linux-fscrypt@archiver.kernel.org>; Wed,  6 Apr 2022 05:19:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1446496AbiDFFTR (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 6 Apr 2022 01:19:17 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:38258 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1573599AbiDETXS (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Apr 2022 15:23:18 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DBD254FC42;
        Tue,  5 Apr 2022 12:21:19 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 7787A617EE;
        Tue,  5 Apr 2022 19:21:19 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3969DC385A0;
        Tue,  5 Apr 2022 19:21:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1649186478;
        bh=wNbrR0kMy5CjuXO377tAi8kaHSrkxQZLX+CwiBwZIn8=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=buHJBAvpQVbNR5sdtUe3WDquSf5XOnCge4HUUepr6yH3XluOPD6iLItil3DElv6XV
         0pa7PyLtdjgwftcXxbomXqUm+1B7aNAm6YzUnJA04BiO256/TvYB2Jo6diCYxSgK+9
         wyTMxEuOgVx4BZ7zaxMUCV4hVS4KqdUg2aq1qNSa7ahzOEBdqVnBageJUDdCGvmryc
         SXMjAV+Ftk4H+ORGeEvZxYv7rPCnlxuOENyArB8cYd8VScSzlsaYNxj+J2362jGuBO
         VYfRc/+PTLMulviro8dTuJwzm7P2oTCSm8fGbWJOwEdD68jpEMGcAqWC5nhWqHnVgq
         VDqSrlTRgNDUA==
From:   Jeff Layton <jlayton@kernel.org>
To:     idryomov@gmail.com, xiubli@redhat.com
Cc:     ceph-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
        lhenriques@suse.de
Subject: [PATCH v13 51/59] ceph: disable copy offload on encrypted inodes
Date:   Tue,  5 Apr 2022 15:20:22 -0400
Message-Id: <20220405192030.178326-52-jlayton@kernel.org>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220405192030.178326-1-jlayton@kernel.org>
References: <20220405192030.178326-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

If we have an encrypted inode, then the client will need to re-encrypt
the contents of the new object. Disable copy offload to or from
encrypted inodes.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/ceph/file.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index f74563e11058..f9e775d6cdf0 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -2526,6 +2526,10 @@ static ssize_t __ceph_copy_file_range(struct file *src_file, loff_t src_off,
 		return -EOPNOTSUPP;
 	}
 
+	/* Every encrypted inode gets its own key, so we can't offload them */
+	if (IS_ENCRYPTED(src_inode) || IS_ENCRYPTED(dst_inode))
+		return -EOPNOTSUPP;
+
 	if (len < src_ci->i_layout.object_size)
 		return -EOPNOTSUPP; /* no remote copy will be done */
 
-- 
2.35.1

