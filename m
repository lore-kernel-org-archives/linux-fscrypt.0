Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D90B6C4332F
	for <linux-fscrypt@archiver.kernel.org>; Fri,  4 Nov 2022 23:13:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229750AbiKDXNE (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 4 Nov 2022 19:13:04 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45240 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229489AbiKDXM7 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 4 Nov 2022 19:12:59 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6BAAB3FB86;
        Fri,  4 Nov 2022 16:12:58 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 0A19362363;
        Fri,  4 Nov 2022 23:12:58 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4EDAAC433D6;
        Fri,  4 Nov 2022 23:12:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1667603577;
        bh=E4ikimrya+m5cv6KWofiUFI7CTon7/XJhPELM6MbJDc=;
        h=From:To:Cc:Subject:Date:From;
        b=k8LgdwQfHycWoGetMa6IDAl/qigAriR/k+BfPpOQ0Wbkhe1ZKk3+8CM24MW0uefK+
         iF2+bs8RXGcubF743rgWl+Z2NTyjBoLn21M6xxJjUV9K7Urbie3h9ZV3oF/tXNS7ru
         /HmsbPaZmRT4+H0mzO4VxAwax266FKm70XID/OJ69YhLDMxZZQlrAt1ilWiRxIOD1g
         AmPIHs3yvMogTtFVDeSpuYTnUBdaboqV56NLXm4xyKaqyHRxPUQmcYJlXLggpYaGrX
         xy9oYiC1N5gbB2j1k8RFdBkGnAFuTgTV40PlGAoVtk+6R851FT4z9r16Xs6NXVvTz7
         JdMp3y1dtNiFQ==
From:   Eric Biggers <ebiggers@kernel.org>
To:     stable@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org
Subject: [PATCH 5.15 0/2] fscrypt fixes for stable
Date:   Fri,  4 Nov 2022 16:12:43 -0700
Message-Id: <20221104231245.377347-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.38.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Please apply these to 5.15-stable.

Eric Biggers (2):
  fscrypt: stop using keyrings subsystem for fscrypt_master_key
  fscrypt: fix keyring memory leak on mount failure

 fs/crypto/fscrypt_private.h |  71 ++++--
 fs/crypto/hooks.c           |  10 +-
 fs/crypto/keyring.c         | 491 +++++++++++++++++++-----------------
 fs/crypto/keysetup.c        |  81 +++---
 fs/crypto/policy.c          |   8 +-
 fs/super.c                  |   3 +-
 include/linux/fs.h          |   2 +-
 include/linux/fscrypt.h     |   4 +-
 8 files changed, 359 insertions(+), 311 deletions(-)


base-commit: 793d8378b74ac283a4dd7cef1b304553c8a42260
-- 
2.38.1

