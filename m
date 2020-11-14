Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 167CCC4742C
	for <linux-fscrypt@archiver.kernel.org>; Sat, 14 Nov 2020 00:16:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B94A22222F
	for <linux-fscrypt@archiver.kernel.org>; Sat, 14 Nov 2020 00:16:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="cRIqT+Ti"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726429AbgKNAQL (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 13 Nov 2020 19:16:11 -0500
Received: from mail.kernel.org ([198.145.29.99]:59102 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726340AbgKNAQK (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 13 Nov 2020 19:16:10 -0500
Received: from sol.attlocal.net (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4AA83221EB;
        Sat, 14 Nov 2020 00:16:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1605312969;
        bh=nj762/qVHoD3sAB5Mw3g6VacqvJcG8wSb7RyFtrY77c=;
        h=From:To:Cc:Subject:Date:From;
        b=cRIqT+TiklJfMhUUiPctjkPOnuLV4mdCFqGxtC9zrygNicL3m5Ny77xuoUfVdXqym
         KAfr7tkZp/8QjeFZ7QHJ7lEKGy/UJ1ZBRhhwOXV/pNjZgb7OI2qu1lumFGUaxjSyAR
         8wfQFyqJwEggNXxDRAanbV8oIuIeqSSQQ3ZryIm0=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     Luca Boccassi <luca.boccassi@gmail.com>,
        Jes Sorensen <Jes.Sorensen@gmail.com>
Subject: [fsverity-utils PATCH 0/2] Add libfsverity_enable() API
Date:   Fri, 13 Nov 2020 16:15:27 -0800
Message-Id: <20201114001529.185751-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.29.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

This patchset adds wrappers around FS_IOC_ENABLE_VERITY to the library
API, and makes the fsverity commands share code to parse the
libfsverity_merkle_tree_params.

This is my proposed alternative to Luca's patch
https://lkml.kernel.org/linux-fscrypt/20201113143527.1097499-1-luca.boccassi@gmail.com

Eric Biggers (2):
  lib: add libfsverity_enable() and libfsverity_enable_with_sig()
  programs/fsverity: share code to parse tree parameters

 include/libfsverity.h | 36 ++++++++++++++++++++++++++++++++++
 lib/enable.c          | 45 +++++++++++++++++++++++++++++++++++++++++++
 programs/cmd_digest.c | 31 ++++-------------------------
 programs/cmd_enable.c | 34 ++++++++------------------------
 programs/cmd_sign.c   | 31 ++++-------------------------
 programs/fsverity.c   | 42 ++++++++++++++++++++++++++++++++++++----
 programs/fsverity.h   | 19 ++++++++++++++----
 7 files changed, 150 insertions(+), 88 deletions(-)
 create mode 100644 lib/enable.c

-- 
2.29.2

