Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B754C56202
	for <linux-fscrypt@archiver.kernel.org>; Wed, 18 Nov 2020 07:57:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 95D6F246B1
	for <linux-fscrypt@archiver.kernel.org>; Wed, 18 Nov 2020 07:57:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="A+6dqvcT"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727164AbgKRH5k (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 18 Nov 2020 02:57:40 -0500
Received: from mail.kernel.org ([198.145.29.99]:35612 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726299AbgKRH5k (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 18 Nov 2020 02:57:40 -0500
Received: from sol.attlocal.net (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 3F55E2080A;
        Wed, 18 Nov 2020 07:57:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1605686259;
        bh=RIC5mu+TPEgksMKT+f1TM2ePCUTrxlaadfpm5VMsKc8=;
        h=From:To:Cc:Subject:Date:From;
        b=A+6dqvcTRZ0pE0gw4wXXN7TtjV668JBEprEGLRRtaSe1TUym2p46zV8cyYiudUEHp
         eL2GK9KCkRG7AtMzZZ0NWXHxhG842DV39eUgIk1EyM/F/3uDDg2hd6ex1aLRM+K8DD
         qaaZ8Xz/2laZctKUbSMDbJkN6K4gTVZZ6U9x2dgo=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 0/5] fscrypt: prevent creating duplicate encrypted filenames
Date:   Tue, 17 Nov 2020 23:56:04 -0800
Message-Id: <20201118075609.120337-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.29.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

This series fixes a longstanding race condition where a duplicate
filename can be created in an encrypted directory if a syscall that
creates a new filename (e.g. open() or mkdir()) races with the
directory's encryption key being added.

To close this race, we need to prevent creating files if the dentry is
still marked as a no-key name.  I.e. we need to fail the ->create() (or
other operation that creates a new filename) if the key wasn't available
when doing the dentry lookup earlier in the syscall, even if the key was
concurrently added between the dentry lookup and ->create().

See patch 1 for a more detailed explanation.

Patch 1 introduces a helper function required for the fix.  Patches 2-4
fix the bug on ext4, f2fs, and ubifs.  Patch 5 is a cleanup.

This fixes xfstest generic/595 on ubifs, but that test was hitting this
bug only accidentally.  I've also written a new xfstest which reproduces
this bug on both ext4 and ubifs.

Eric Biggers (5):
  fscrypt: add fscrypt_is_nokey_name()
  ext4: prevent creating duplicate encrypted filenames
  f2fs: prevent creating duplicate encrypted filenames
  ubifs: prevent creating duplicate encrypted filenames
  fscrypt: remove unnecessary calls to fscrypt_require_key()

 fs/crypto/hooks.c       | 31 +++++++++++--------------------
 fs/ext4/namei.c         |  3 +++
 fs/f2fs/f2fs.h          |  2 ++
 fs/ubifs/dir.c          | 17 +++++++++++++----
 include/linux/fscrypt.h | 37 +++++++++++++++++++++++++++++++++++--
 5 files changed, 64 insertions(+), 26 deletions(-)


base-commit: 3ceb6543e9cf6ed87cc1fbc6f23ca2db903564cd
-- 
2.29.2

