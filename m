Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.7 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D860DC4361B
	for <linux-fscrypt@archiver.kernel.org>; Thu, 17 Dec 2020 14:48:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 91A6B21534
	for <linux-fscrypt@archiver.kernel.org>; Thu, 17 Dec 2020 14:48:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726012AbgLQOsv (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 17 Dec 2020 09:48:51 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39214 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725468AbgLQOsv (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 17 Dec 2020 09:48:51 -0500
Received: from mail-wr1-x42a.google.com (mail-wr1-x42a.google.com [IPv6:2a00:1450:4864:20::42a])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A7EC9C061794
        for <linux-fscrypt@vger.kernel.org>; Thu, 17 Dec 2020 06:48:10 -0800 (PST)
Received: by mail-wr1-x42a.google.com with SMTP id d13so8611706wrc.13
        for <linux-fscrypt@vger.kernel.org>; Thu, 17 Dec 2020 06:48:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Fa9qT/pKkw/u/yVwCkGC3Mjio8P5+Oq6XKmyiCUuGOk=;
        b=n7uFZE2GYBtORWS9/lat3iorMlnJifNe4eS5mceKLe58SAp3NRXjhFgk4sG5B3YFWn
         xVVWnCxe8xNAGqEAbBBGFiUhIkxFY5pZXw7BcQ049Pi8CDOSzWLbBCYYFU0p5xsDOoJ/
         rRqVpbuac3xizkcPbGgC79FZQyKWvVMqiv7JLMC+LCTBTONAWQAcpx9YZ0NoblTjYcMz
         yRQ7XF3lmkzV0pDOMagwTVhJ/volAP6XKhh7b8/0zs9mUpNuVDH9m0dY3Fg4MlqMOPdm
         WEfhfflZ4UKUxRMOooyDDGeJL6ZOT/Q7NfftKCh3mQ2xyOGlxTZCcp2nWgoEOgdUSU8/
         P8+w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=Fa9qT/pKkw/u/yVwCkGC3Mjio8P5+Oq6XKmyiCUuGOk=;
        b=G7fI9Cy7rYoGQyRIsaXwwMSQy2Uslz2T0pcg8erUZFw3DeFQoybRn9DFZN+mNqk9nF
         jQFDHNWbl7tuDiRLws9iIjrI0TAmoBSRBkKEgiN9kfVw5xavPRgPp0gX1yuinNQISi+4
         JOgk19+FMGhGAUG9RLXk9HBwGRoOFlOlvQFbcfURT0E8+wB6lAKg255VpS7HdbZpryLN
         aOkMjbHHmBlMD6Pg3RckC2dezDyWoTy2Noa0LTS0uKb6JfW9PYoyfmLfW+yyy1a4LH3D
         ebO626KHD/8ch33MwrvlzgCW7tSMksxHCuIUYowjoRzcfdeF+E6zx5owr/tcPTSUlH63
         4hvQ==
X-Gm-Message-State: AOAM532ttsxT6su5ju8QfMbquFf9oNVu0yVns5mkTvcfw7akJ3eGmqEo
        FSq9chibetUv9aPsSBxTBi5B6F2jB5BHJg==
X-Google-Smtp-Source: ABdhPJwyM2dJcd3YtgjSiW0UUlE5xXdU7TlqYlsZhB/ncogAVHM/3J6R1HhHEig+H2A7kLaHg6bPww==
X-Received: by 2002:a5d:51cc:: with SMTP id n12mr36626880wrv.375.1608216488986;
        Thu, 17 Dec 2020 06:48:08 -0800 (PST)
Received: from localhost ([88.98.246.218])
        by smtp.gmail.com with ESMTPSA id o83sm8241761wme.21.2020.12.17.06.48.07
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 17 Dec 2020 06:48:07 -0800 (PST)
From:   luca.boccassi@gmail.com
To:     linux-fscrypt@vger.kernel.org
Cc:     ebiggers@google.com
Subject: [fsverity-utils PATCH v2 1/2] Remove unneeded includes
Date:   Thu, 17 Dec 2020 14:47:48 +0000
Message-Id: <20201217144749.647533-1-luca.boccassi@gmail.com>
X-Mailer: git-send-email 2.29.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Luca Boccassi <luca.boccassi@microsoft.com>

Signed-off-by: Luca Boccassi <luca.boccassi@microsoft.com>
---
v2: do not remove includes from fsverity_uapi.h, actually needed

 programs/cmd_enable.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/programs/cmd_enable.c b/programs/cmd_enable.c
index fdf26c7..14c3c17 100644
--- a/programs/cmd_enable.c
+++ b/programs/cmd_enable.c
@@ -14,7 +14,6 @@
 #include <fcntl.h>
 #include <getopt.h>
 #include <limits.h>
-#include <sys/ioctl.h>
 
 static bool read_signature(const char *filename, u8 **sig_ret,
 			   u32 *sig_size_ret)
-- 
2.29.2

