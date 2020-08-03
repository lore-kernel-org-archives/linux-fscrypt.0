Return-Path: <SRS0=t9HX=BN=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E13B5C433E0
	for <linux-fscrypt@archiver.kernel.org>; Mon,  3 Aug 2020 04:08:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BE2432075A
	for <linux-fscrypt@archiver.kernel.org>; Mon,  3 Aug 2020 04:08:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725831AbgHCEIP (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 3 Aug 2020 00:08:15 -0400
Received: from youngberry.canonical.com ([91.189.89.112]:46893 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725268AbgHCEIO (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 3 Aug 2020 00:08:14 -0400
Received: from mail-pj1-f70.google.com ([209.85.216.70])
        by youngberry.canonical.com with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.86_2)
        (envelope-from <po-hsu.lin@canonical.com>)
        id 1k2Rlk-0001UH-Gz
        for linux-fscrypt@vger.kernel.org; Mon, 03 Aug 2020 04:08:12 +0000
Received: by mail-pj1-f70.google.com with SMTP id s4so15221829pjq.8
        for <linux-fscrypt@vger.kernel.org>; Sun, 02 Aug 2020 21:08:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=uwZVDkxnuGuDIYCWAzrsTjqsEVBiE5Gpzjpa5MQp+Zc=;
        b=TrULHomruagCvkQf4TKSwwHX5j0swtKWmFI7uWa73wIoxTpRxutxH8ssteJaFnmdwv
         7/knGe461JjyYcwejwNLzsKXtG5MYvrDCEEErFgK6O+RGc0S21kKxQ7yQqHAGE5mEFtP
         VMwWZqClbQrYaUd4h69eKmVgXrW1N/Y0Rmka1WLPTs5XkZWYOvBGwSEq36PO+oF23/02
         HCzOnd97mdv/VUynW6c7qFMh8FcIFexdv7+7qo7RTJJ7zfV9LGsXpz2Sd+Ozq/MDYbJL
         r+beOJqolvKgQgnG+DDfsYT9dN9NFChvC0BM790UW1nnuQqmun6X9v337XlZsEo8aYkr
         AzlA==
X-Gm-Message-State: AOAM532Y8q+zTQfy2bTDhUqSL+afNzqbteJBNWiOP3fLOMY2LFci2R1w
        0k0C8tqPkAfqSylSezYeq0QqWW5zxaKXOWrv2InKjlS1fTXslcgRh75bbH4WtxjYuV4nL8UuBtw
        zzyqpYGnhETuuyrIkiO4yT5WhnKzfg2vGTGaTAXrzYg==
X-Received: by 2002:a17:90a:2208:: with SMTP id c8mr5814153pje.123.1596427690916;
        Sun, 02 Aug 2020 21:08:10 -0700 (PDT)
X-Google-Smtp-Source: ABdhPJw8zBPVa+lbYaA6OfPvxLwil8UWaoJIvyXdFOIpITrHcVKGLUEDv/8X56UNkJC4Lz4EKBoWJQ==
X-Received: by 2002:a17:90a:2208:: with SMTP id c8mr5814130pje.123.1596427690604;
        Sun, 02 Aug 2020 21:08:10 -0700 (PDT)
Received: from Leggiero.taipei.internal (61-220-137-37.HINET-IP.hinet.net. [61.220.137.37])
        by smtp.gmail.com with ESMTPSA id o19sm11890636pjs.8.2020.08.02.21.08.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 02 Aug 2020 21:08:10 -0700 (PDT)
From:   Po-Hsu Lin <po-hsu.lin@canonical.com>
To:     linux-fscrypt@vger.kernel.org
Cc:     po-hsu.lin@canonical.com
Subject: [fsverity-utils PATCH] README.md: add subject tag to Contributing section
Date:   Mon,  3 Aug 2020 12:08:03 +0800
Message-Id: <20200803040803.10529-1-po-hsu.lin@canonical.com>
X-Mailer: git-send-email 2.17.1
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Add subject tag suggestion [fsverity-utils PATCH] to the Contributing
section, so that developer can follow this.

Signed-off-by: Po-Hsu Lin <po-hsu.lin@canonical.com>
---
 README.md | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/README.md b/README.md
index b11f6d5..5a76247 100644
--- a/README.md
+++ b/README.md
@@ -136,11 +136,12 @@ Send questions and bug reports to linux-fscrypt@vger.kernel.org.
 
 ## Contributing
 
-Send patches to linux-fscrypt@vger.kernel.org.  Patches should follow
-the Linux kernel's coding style.  A `.clang-format` file is provided
-to approximate this coding style; consider using `git clang-format`.
-Additionally, like the Linux kernel itself, patches require the
-following "sign-off" procedure:
+Send patches to linux-fscrypt@vger.kernel.org with the additional tag
+'fsverity-utils' in the subject, i.e. [fsverity-utils PATCH].  Patches
+should follow the Linux kernel's coding style.  A `.clang-format` file
+is provided to approximate this coding style; consider using
+ `git clang-format`.  Additionally, like the Linux kernel itself,
+patches require the following "sign-off" procedure:
 
 The sign-off is a simple line at the end of the explanation for the
 patch, which certifies that you wrote it or otherwise have the right
-- 
2.17.1

