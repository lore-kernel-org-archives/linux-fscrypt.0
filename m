Return-Path: <SRS0=J/yO=ZL=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABEA7C432C3
	for <linux-fscrypt@archiver.kernel.org>; Tue, 19 Nov 2019 22:32:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7FB5522459
	for <linux-fscrypt@archiver.kernel.org>; Tue, 19 Nov 2019 22:32:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1574202756;
	bh=jGkgOHwjYn49iNvx9nypYCXSDYBQdiX85lA20cImo+Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=d1IXQqmPorfKYjvjsZEfirz9glsmSc/DmF+UT8hgQui3WnJQxt1GK146wh8et0Umn
	 iYy5rg3Et1xiP7tg5hD9FPSP8XwPDYWn9jlwBM7eUW02NiJnLB1RNVmX2HS6sQL+ZO
	 dsRYvpxXWU9laWwi5z4P9PuYys+HtjObf4W0wPTQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726948AbfKSWcg (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 19 Nov 2019 17:32:36 -0500
Received: from mail.kernel.org ([198.145.29.99]:42680 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726346AbfKSWcg (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 19 Nov 2019 17:32:36 -0500
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 7A60A22459;
        Tue, 19 Nov 2019 22:32:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1574202755;
        bh=jGkgOHwjYn49iNvx9nypYCXSDYBQdiX85lA20cImo+Q=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=n2mVGahSU2sMJ1ewRLM827y2N4x6tPIMVhLVqF03roequ7yUPEHx2iw8z1oegzP+8
         RkZYFb11trZc70QQ1QNQayreZwgyaBb9uzAHm1GdMToxZjUK8yBLPlaQIJVXcbuEL7
         GaPJsq85qP1/Gala31kx8vyoIybzLPmkUawWXflA=
From:   Eric Biggers <ebiggers@kernel.org>
To:     fstests@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org, keyrings@vger.kernel.org,
        Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>
Subject: [RFC PATCH 1/3] common/rc: handle option with argument in _require_xfs_io_command()
Date:   Tue, 19 Nov 2019 14:31:28 -0800
Message-Id: <20191119223130.228341-2-ebiggers@kernel.org>
X-Mailer: git-send-email 2.24.0.432.g9d3f5f5b63-goog
In-Reply-To: <20191119223130.228341-1-ebiggers@kernel.org>
References: <20191119223130.228341-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Fix _require_xfs_io_command() to handle options that take arguments when
the argument is shown in the help text.  E.g., it didn't work to run:

	_require_xfs_io_command "add_enckey" "-k"

because the relevant line of the help text is:

	-k KEY_ID -- ID of fscrypt-provisioning key containing the raw key

... but the grep command only matched "-k --", not "-k KEY_ID --".

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 common/rc | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/common/rc b/common/rc
index b988e912..8d9479c0 100644
--- a/common/rc
+++ b/common/rc
@@ -2216,7 +2216,7 @@ _require_xfs_io_command()
 	[ -n "$param" ] || return
 
 	if [ -z "$param_checked" ]; then
-		$XFS_IO_PROG -c "help $command" | grep -q "^ $param --" || \
+		$XFS_IO_PROG -c "help $command" | grep -E -q "^ $param ([a-zA-Z_]+ )?--" || \
 			_notrun "xfs_io $command doesn't support $param"
 	else
 		# xfs_io could result in "command %c not supported" if it was
-- 
2.24.0.432.g9d3f5f5b63-goog

