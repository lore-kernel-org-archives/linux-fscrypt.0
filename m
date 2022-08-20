Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAFC4C25B08
	for <linux-fscrypt@archiver.kernel.org>; Sat, 20 Aug 2022 19:10:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229675AbiHTTKy (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 20 Aug 2022 15:10:54 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57008 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229462AbiHTTKx (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 20 Aug 2022 15:10:53 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5E53C26AF7;
        Sat, 20 Aug 2022 12:10:50 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id E0F2B60F9D;
        Sat, 20 Aug 2022 19:10:49 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 202FAC433C1;
        Sat, 20 Aug 2022 19:10:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1661022649;
        bh=uNUb1M7CCQXGOxGrsYBQxCVkKEk2ADvQo+VwUlJ9jHQ=;
        h=From:To:Cc:Subject:Date:From;
        b=KzQ/lWHqSAiLkeoOQivxT89bOTDFv6C+41BHNiWuwaeSsE3Wsmfr4ybvTY+i7MKm6
         kIC5kqNNUqyXGGprcbKIiXbJA51rNHvFYmRwj4qRXACUqb63yhId9WPe1l3A2aI/Fj
         sTOTyORCQFdc61zxLhl3CHOBrdMjqJweKKfqlcbUA0pUebdKH7hswnkUEkzN/VhDnT
         a0gZ5Rh713lZrWZPzgqDnTB1CW8g0CpwwPGx6zZS7HaQv5e9gsg/f9GFOmpm6UwJJJ
         uVzRE8d4PvzS2DgzPHFMeAIUrbsZhZE1+hmQ1uXMh7dS2CSQr/xM9+y5I5FFL8GnGX
         dbb8hI9LPdRAA==
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH v2 0/2] fscrypt: rework filesystem-level keyring
Date:   Sat, 20 Aug 2022 12:02:08 -0700
Message-Id: <20220820190210.169734-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.37.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

This series reworks the filesystem-level keyring to not use the keyrings
subsystem as part of its internal implementation (except for ->mk_users,
which remains unchanged for now).  This fixes several issues, described
in the first patch.  This is also a prerequisite for removing the direct
use of struct request_queue from filesystem code, as discussed at
https://lore.kernel.org/linux-fscrypt/20220721125929.1866403-1-hch@lst.de/T/#u

Changed v1 => v2:
    - Don't compare uninitialized bytes of struct fscrypt_key_specifier
    - Don't use refcount_dec_and_lock() unnecessarily
    - Other minor cleanups

Eric Biggers (2):
  fscrypt: stop using keyrings subsystem for fscrypt_master_key
  fscrypt: stop holding extra request_queue references

 fs/crypto/fscrypt_private.h |  74 ++++--
 fs/crypto/hooks.c           |  10 +-
 fs/crypto/inline_crypt.c    |  83 +++---
 fs/crypto/keyring.c         | 495 +++++++++++++++++++-----------------
 fs/crypto/keysetup.c        |  89 +++----
 fs/crypto/keysetup_v1.c     |   4 +-
 fs/crypto/policy.c          |   8 +-
 fs/super.c                  |   2 +-
 include/linux/fs.h          |   2 +-
 include/linux/fscrypt.h     |   4 +-
 10 files changed, 406 insertions(+), 365 deletions(-)


base-commit: 568035b01cfb107af8d2e4bd2fb9aea22cf5b868
-- 
2.37.1

