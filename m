Return-Path: <SRS0=4aov=Z7=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC2BFC43603
	for <linux-fscrypt@archiver.kernel.org>; Mon,  9 Dec 2019 21:19:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9A6AA207FF
	for <linux-fscrypt@archiver.kernel.org>; Mon,  9 Dec 2019 21:19:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1575926363;
	bh=LJsoVyW+LNDhyFsdqc2Dv90UEe68PUeoTl1LBUwnuiE=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=EsJZQWG6ph7H9byLO3Mal5+gbFm+ukA8GvgjHunL++H3FvtunjJOF9RYNkOOt84Ih
	 obtHOu3sULDaOlel4gZbLJF0JD0dSTjCdK/X03k9yO8ttSfJ9UGjMFxZ+/HdHM5zoC
	 BAhGUYHozBOgWLRcifOsS5NxZ1F43lXA51Gk4Wh0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726647AbfLIVTX (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 9 Dec 2019 16:19:23 -0500
Received: from mail.kernel.org ([198.145.29.99]:53388 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726522AbfLIVTX (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 9 Dec 2019 16:19:23 -0500
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id B55BA206D5;
        Mon,  9 Dec 2019 21:19:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1575926362;
        bh=LJsoVyW+LNDhyFsdqc2Dv90UEe68PUeoTl1LBUwnuiE=;
        h=From:To:Cc:Subject:Date:From;
        b=HbHGcKXBuu0nFC2NqXwOgJiU/LSSxsevIrK/g4lyS/3sWpgFz/WijN2k1Lxj/W5Mo
         B53gkEQbLYiA5092N8pz69543q83LPJx4+BWGwFUrGFz/1RrBpJqHIySm5EQCqXs0g
         tab4HzAZFXLkuyqTXcv81foav4W9yN3dYGeUw8ok=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     Daniel Rosenberg <drosen@google.com>
Subject: [PATCH 0/4] fscrypt: fscrypt_supported_policy() fixes and cleanups
Date:   Mon,  9 Dec 2019 13:18:25 -0800
Message-Id: <20191209211829.239800-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.24.0.393.g34dc348eaf-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Make FS_IOC_SET_ENCRYPTION_POLICY start rejecting the DIRECT_KEY flag
when it's incompatible with the selected encryption modes, instead of
delaying this check until later when actually trying to set up the
directory's key.

Also make some related cleanups, such as splitting
fscrypt_supported_policy() into a separate function for each encryption
policy version.

Eric Biggers (4):
  fscrypt: split up fscrypt_supported_policy() by policy version
  fscrypt: check for appropriate use of DIRECT_KEY flag earlier
  fscrypt: move fscrypt_valid_enc_modes() to policy.c
  fscrypt: remove fscrypt_is_direct_key_policy()

 fs/crypto/fscrypt_private.h |  30 +------
 fs/crypto/keysetup.c        |  14 +---
 fs/crypto/keysetup_v1.c     |  15 ----
 fs/crypto/policy.c          | 163 +++++++++++++++++++++++-------------
 4 files changed, 111 insertions(+), 111 deletions(-)

-- 
2.24.0.393.g34dc348eaf-goog

