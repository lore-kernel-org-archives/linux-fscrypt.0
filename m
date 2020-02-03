Return-Path: <SRS0=8pqD=3X=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 053EAC35249
	for <linux-fscrypt@archiver.kernel.org>; Mon,  3 Feb 2020 18:19:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CBFF520CC7
	for <linux-fscrypt@archiver.kernel.org>; Mon,  3 Feb 2020 18:19:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1580753953;
	bh=WU7BsIvYhoveOrZ4wNAlFXzim8ittcmhupEoatpr+No=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=xFDe/qf/xKyYjG9TaDXRjugqEcPCMhVDERo3w8DLa+5UmGHH7kTV6iUvyuKu+8nZ4
	 p9o82sKQC0gJ6DdJcu9jTzNCDhis6pejtAKh5Lq+OB45vvKAhmQMmvERcCijUcyrLR
	 NXqSPpXdAxxXjEiM81SJr0FC6D1fXK221XTIbSlQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729594AbgBCSTN (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 3 Feb 2020 13:19:13 -0500
Received: from mail.kernel.org ([198.145.29.99]:33398 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728419AbgBCSTN (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 3 Feb 2020 13:19:13 -0500
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 8E8332086A;
        Mon,  3 Feb 2020 18:19:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1580753952;
        bh=WU7BsIvYhoveOrZ4wNAlFXzim8ittcmhupEoatpr+No=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=x+50PF8SM+1VXw8cU2ohpVfjODhnlPAdHFzanHMvXTG13QO1Xai0rUzyIEv0xk2Sf
         1DxpRqwYGmnbM64mEr68kcy86GS0ZmRmgh/xfcSBgkGQsWOeONhQGUTlIzH2kKIeP2
         rtY7E9UlR2clxsJCMJo1dxCIR8HDOvTaXNOGIQH4=
From:   Eric Biggers <ebiggers@kernel.org>
To:     fstests@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org, keyrings@vger.kernel.org
Subject: [PATCH v2 1/3] common/rc: handle option with argument in _require_xfs_io_command()
Date:   Mon,  3 Feb 2020 10:18:53 -0800
Message-Id: <20200203181855.42987-2-ebiggers@kernel.org>
X-Mailer: git-send-email 2.25.0.341.g760bfbb309-goog
In-Reply-To: <20200203181855.42987-1-ebiggers@kernel.org>
References: <20200203181855.42987-1-ebiggers@kernel.org>
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
index b4a77a21..0306e93c 100644
--- a/common/rc
+++ b/common/rc
@@ -2248,7 +2248,7 @@ _require_xfs_io_command()
 	[ -n "$param" ] || return
 
 	if [ -z "$param_checked" ]; then
-		$XFS_IO_PROG -c "help $command" | grep -q "^ $param --" || \
+		$XFS_IO_PROG -c "help $command" | grep -E -q "^ $param ([a-zA-Z_]+ )?--" || \
 			_notrun "xfs_io $command doesn't support $param"
 	else
 		# xfs_io could result in "command %c not supported" if it was
-- 
2.25.0.341.g760bfbb309-goog

