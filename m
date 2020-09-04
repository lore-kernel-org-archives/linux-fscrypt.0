Return-Path: <SRS0=XUw6=CN=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B88DC43461
	for <linux-fscrypt@archiver.kernel.org>; Fri,  4 Sep 2020 16:05:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 408C42087C
	for <linux-fscrypt@archiver.kernel.org>; Fri,  4 Sep 2020 16:05:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1599235549;
	bh=eeVIwFgO+VNOF1usKGKm0cHRrFvMQpe9/gLIBmEAGYQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=P6QFP/Lt9wPN/Dst8b0FfmVXMZmtU1basf062w1zef99003KTGyA+d3/CNtWVj/9j
	 z32oZYgRypqIG1K+Wl9NHfRMLEmzusfLCZJd6LIqPY+/QPAN+VAEG3+UejfvU8QHNZ
	 jo6BBS0SeYLchPXtH6ofw7bEiw8hv6PJkUP5+Yfs=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727915AbgIDQFq (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 4 Sep 2020 12:05:46 -0400
Received: from mail.kernel.org ([198.145.29.99]:51308 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727860AbgIDQFp (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 4 Sep 2020 12:05:45 -0400
Received: from tleilax.com (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4BC6F20772;
        Fri,  4 Sep 2020 16:05:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1599235544;
        bh=eeVIwFgO+VNOF1usKGKm0cHRrFvMQpe9/gLIBmEAGYQ=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=Ff1agbT8YRFctJmRaA+Sfc3svzYX7QF5AYckLVlUCJ7YTR+q3BQwSRT286hByemDa
         yQiesApj8ZYxvCKd6GPueD3QWFL/vyzS4O2YGkm8FTcxPuqzEa2X6hYrNZn1KVXn4H
         N+/LtLeJMQYH0k7sJ0qT2T4JPNbC0SXqSALKKb8I=
From:   Jeff Layton <jlayton@kernel.org>
To:     ceph-devel@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        ebiggers@kernel.org
Subject: [RFC PATCH v2 05/18] fscrypt: don't balk when inode is already marked encrypted
Date:   Fri,  4 Sep 2020 12:05:24 -0400
Message-Id: <20200904160537.76663-6-jlayton@kernel.org>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <20200904160537.76663-1-jlayton@kernel.org>
References: <20200904160537.76663-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Cephfs (currently) sets this flag early and only fetches the context
later. Eventually we may not need this, but for now it prevents this
warning from popping.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/crypto/keysetup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index ad64525ec680..3b4ec16fc528 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -567,7 +567,7 @@ int fscrypt_get_encryption_info(struct inode *inode)
 		const union fscrypt_context *dummy_ctx =
 			fscrypt_get_dummy_context(inode->i_sb);
 
-		if (IS_ENCRYPTED(inode) || !dummy_ctx) {
+		if (!dummy_ctx) {
 			fscrypt_warn(inode,
 				     "Error %d getting encryption context",
 				     res);
-- 
2.26.2

