Return-Path: <SRS0=XUw6=CN=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABEBDC433E2
	for <linux-fscrypt@archiver.kernel.org>; Fri,  4 Sep 2020 16:06:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8021920797
	for <linux-fscrypt@archiver.kernel.org>; Fri,  4 Sep 2020 16:06:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1599235593;
	bh=L2/V/5hUAv0dQLRJb7AhQdxLOxUodIGz52r4rMuTRRs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=rHBro/C49o4+UJqrranZ+f6jXTazvM/tZtHd4XonvLm/c89c6eRiaBZmCyHVEfPX+
	 EeiHakinxQS10rsXEWNQ4KhIBJPiHCEr+4IELqfQYy1B40ow5yq6h5fxL9G4i1CQYO
	 NkRmd60wVAa6HS1casSs0/CqHfXjOmgCj53xOVvQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728039AbgIDQGd (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 4 Sep 2020 12:06:33 -0400
Received: from mail.kernel.org ([198.145.29.99]:51326 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727952AbgIDQFv (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 4 Sep 2020 12:05:51 -0400
Received: from tleilax.com (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id DDA3B20772;
        Fri,  4 Sep 2020 16:05:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1599235551;
        bh=L2/V/5hUAv0dQLRJb7AhQdxLOxUodIGz52r4rMuTRRs=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=EEgtSJ3jSaTR88quYfZvTQY3HQnGwwZan9OlEFXbWDgDoKH7NemLL0fWOU8QHrwXH
         /ELlAZY0oh8F/580vZbcXSccObbqQjhBGAYNSF5WVPo3+tsk7CbBJox3fObwexGNwc
         dIB+ldrAG1pEfrecoIp3CGdedDMwHtM1+l+mmNP0=
From:   Jeff Layton <jlayton@kernel.org>
To:     ceph-devel@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        ebiggers@kernel.org
Subject: [RFC PATCH v2 15/18] ceph: make d_revalidate call fscrypt revalidator for encrypted dentries
Date:   Fri,  4 Sep 2020 12:05:34 -0400
Message-Id: <20200904160537.76663-16-jlayton@kernel.org>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <20200904160537.76663-1-jlayton@kernel.org>
References: <20200904160537.76663-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

If we have an encrypted dentry, then we need to test whether a new key
might have been established or removed. Do that before we test anything
else about the dentry.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/ceph/dir.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/ceph/dir.c b/fs/ceph/dir.c
index b3f2741becdb..cc85933413b9 100644
--- a/fs/ceph/dir.c
+++ b/fs/ceph/dir.c
@@ -1695,6 +1695,12 @@ static int ceph_d_revalidate(struct dentry *dentry, unsigned int flags)
 	dout("d_revalidate %p '%pd' inode %p offset 0x%llx\n", dentry,
 	     dentry, inode, ceph_dentry(dentry)->offset);
 
+	if (IS_ENCRYPTED(dir)) {
+		valid = fscrypt_d_revalidate(dentry, flags);
+		if (valid <= 0)
+			return valid;
+	}
+
 	mdsc = ceph_sb_to_client(dir->i_sb)->mdsc;
 
 	/* always trust cached snapped dentries, snapdir dentry */
-- 
2.26.2

