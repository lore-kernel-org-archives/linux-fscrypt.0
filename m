Return-Path: <SRS0=ZitF=2J=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C458C43603
	for <linux-fscrypt@archiver.kernel.org>; Thu, 19 Dec 2019 18:58:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E7FA1206EC
	for <linux-fscrypt@archiver.kernel.org>; Thu, 19 Dec 2019 18:58:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1576781900;
	bh=GkdpWOFOCOgR90KM9oZFkRYoPZgyma6BK0szesnYoFE=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=xVzZtLND7GjVJdpx/vmpuYdsAUH8jIgmMwkCKvJ1o307VAPKlb3kwZ54wjHzwooZ9
	 4thzXR5PhSJQzId1w/5S7iRxB5z9y4FfVcfe1HpHH7N0UErkR7k4mlpnGYNmn0hIjK
	 IHOUI8kzjHSHnCGRh/TLQBw+XJLTUy9nDsnGKl00=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729236AbfLSS6S (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 19 Dec 2019 13:58:18 -0500
Received: from mail.kernel.org ([198.145.29.99]:54574 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728433AbfLSS6S (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 19 Dec 2019 13:58:18 -0500
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 7E111206EC;
        Thu, 19 Dec 2019 18:58:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1576781897;
        bh=GkdpWOFOCOgR90KM9oZFkRYoPZgyma6BK0szesnYoFE=;
        h=From:To:Cc:Subject:Date:From;
        b=wQ6IjdeH1IdVkr5XBcCMRY3diuu8SDCzvw3YYCumvE07BUAtSK07MFd0nuNmBgN6V
         3Dbiko4viw9Zo0aeImCeoLhiRO61P0C8MsoMe9aLbwut4KoPTCfyHtSHvK1Bit4Jqs
         UFcdNwaf+LEygZXZfhJwvSfodqCkVRWOqccWTnaI=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org
Subject: [PATCH] fscrypt: include <linux/ioctl.h> in UAPI header
Date:   Thu, 19 Dec 2019 10:56:24 -0800
Message-Id: <20191219185624.21251-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.24.1.735.g03f4e72817-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

<linux/fscrypt.h> defines ioctl numbers using the macros like _IORW()
which are defined in <linux/ioctl.h>, so <linux/ioctl.h> should be
included as a prerequisite, like it is in many other kernel headers.

In practice this doesn't really matter since anyone referencing these
ioctl numbers will almost certainly include <sys/ioctl.h> too in order
to actually call ioctl().  But we might as well fix this.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 include/uapi/linux/fscrypt.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/fscrypt.h b/include/uapi/linux/fscrypt.h
index d5112a24e8b9f..0d8a6f47711c3 100644
--- a/include/uapi/linux/fscrypt.h
+++ b/include/uapi/linux/fscrypt.h
@@ -8,6 +8,7 @@
 #ifndef _UAPI_LINUX_FSCRYPT_H
 #define _UAPI_LINUX_FSCRYPT_H
 
+#include <linux/ioctl.h>
 #include <linux/types.h>
 
 /* Encryption policy flags */
-- 
2.24.1.735.g03f4e72817-goog

