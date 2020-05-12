Return-Path: <SRS0=XG5P=62=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4045C2D0FA
	for <linux-fscrypt@archiver.kernel.org>; Tue, 12 May 2020 23:36:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BB9A520784
	for <linux-fscrypt@archiver.kernel.org>; Tue, 12 May 2020 23:36:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1589326571;
	bh=BMIktPcgJbdPblvIseR4lM4hwfbtMoRDGR8MWk2qSuA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=K+yBnWtF+Y4K+LIk0korfiyhXBOS/Zk3lXFYnF5CsN/MT6rV8rvIWyjl6ixuvBndq
	 1bO4TpIydjptDAcJ95uEhY1AF2501/ylHUoMz3OeZWS000HuyMdDwsEUIRS02gkb0r
	 CUcpqf6flpiXurVASRN2jSPFkbQaktsZlSWCMYz4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731660AbgELXgL (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 12 May 2020 19:36:11 -0400
Received: from mail.kernel.org ([198.145.29.99]:33990 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725938AbgELXgL (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 12 May 2020 19:36:11 -0400
Received: from sol.hsd1.ca.comcast.net (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 8CF1723129;
        Tue, 12 May 2020 23:36:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1589326570;
        bh=BMIktPcgJbdPblvIseR4lM4hwfbtMoRDGR8MWk2qSuA=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=JZUdY+nHskjaq8Rsyn8OOMyKPHfjHj9JfV6Acwi+Pma0bvRssHQzAdfIvl+EIT/Dy
         +psLT83lyG4cNCQ7eI5/F4O3Yasm/+j3M7hxHcDOmv+55sx1xtHVwfWgMmbYPEx7/v
         zAV3sSEE8wyJr+mJq0JhLATesRFun5o3llaIdmxc=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        "Theodore Y . Ts'o" <tytso@mit.edu>,
        Daniel Rosenberg <drosen@google.com>
Subject: [PATCH 4/4] fscrypt: make test_dummy_encryption use v2 by default
Date:   Tue, 12 May 2020 16:32:51 -0700
Message-Id: <20200512233251.118314-5-ebiggers@kernel.org>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <20200512233251.118314-1-ebiggers@kernel.org>
References: <20200512233251.118314-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Since v1 encryption policies are deprecated, make test_dummy_encryption
test v2 policies by default.

Note that this causes ext4/023 and ext4/028 to start failing due to
known bugs in those tests (see previous commit).

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/policy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index ca0ee337c9627f..cb7fd8f7f0eca1 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -632,7 +632,7 @@ int fscrypt_set_test_dummy_encryption(struct super_block *sb,
 				      const substring_t *arg,
 				      struct fscrypt_dummy_context *dummy_ctx)
 {
-	const char *argstr = "v1";
+	const char *argstr = "v2";
 	const char *argstr_to_free = NULL;
 	struct fscrypt_key_specifier key_spec = { 0 };
 	int version;
-- 
2.26.2

