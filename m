Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9A63C433F5
	for <linux-fscrypt@archiver.kernel.org>; Wed,  8 Sep 2021 21:51:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D178C61166
	for <linux-fscrypt@archiver.kernel.org>; Wed,  8 Sep 2021 21:51:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235588AbhIHVwi (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 8 Sep 2021 17:52:38 -0400
Received: from mail.kernel.org ([198.145.29.99]:38270 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S234144AbhIHVwg (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 8 Sep 2021 17:52:36 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 5F27A610FF;
        Wed,  8 Sep 2021 21:51:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1631137888;
        bh=AXEwcqG3tA0z2Pq2CtpORf9Ep9Dl9pqblNnUmHoDhjQ=;
        h=From:To:Cc:Subject:Date:From;
        b=fdmiZxK8ekMOjOCM6rBVyxzrcFHIcCLOdVoQ3mAnT+m5ceEppiXu/2lrEa7c8RzD2
         hNqe+pQBotx+3L9wWQxIzYJRsllAaqTEV5EzpYVjQ0uQ2WIbO5SA0rrkAEJHVOfhx7
         VKQAO5/mqnwHzMUplqvyMrtTOWdjukY29mBNQGzzTohu9hceIQe/zjqU1T+flZcaDQ
         uAAZudkSVSmLk3BKHCyRxn087bIKIK3HtpXoAUWmIUxqQEeD8YhoPpcEaWwBK4nE34
         aB+XN81vV7v+p2u3DuKwIKvv5pLsGislHlkZ7JkrYF3KTaI0pnjtYKTxi+CX35RV92
         lIss4pNBPmkpg==
From:   Eric Biggers <ebiggers@kernel.org>
To:     stable@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org
Subject: [PATCH 0/4] backport fscrypt symlink fixes to 4.19
Date:   Wed,  8 Sep 2021 14:50:29 -0700
Message-Id: <20210908215033.1122580-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.33.0.153.gba50c8fa24-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

This series backports some patches that failed to apply to 4.19-stable
due to the prototype of inode_operations::getattr having changed in
v5.12, as well as several other conflicts.  Please apply to 4.19-stable.

Eric Biggers (4):
  fscrypt: add fscrypt_symlink_getattr() for computing st_size
  ext4: report correct st_size for encrypted symlinks
  f2fs: report correct st_size for encrypted symlinks
  ubifs: report correct st_size for encrypted symlinks

 fs/crypto/hooks.c               | 44 +++++++++++++++++++++++++++++++++
 fs/ext4/symlink.c               | 11 ++++++++-
 fs/f2fs/namei.c                 | 11 ++++++++-
 fs/ubifs/file.c                 | 12 ++++++++-
 include/linux/fscrypt_notsupp.h |  6 +++++
 include/linux/fscrypt_supp.h    |  1 +
 6 files changed, 82 insertions(+), 3 deletions(-)

-- 
2.33.0.153.gba50c8fa24-goog

