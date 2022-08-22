Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D99C6C28D13
	for <linux-fscrypt@archiver.kernel.org>; Mon, 22 Aug 2022 19:11:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S238294AbiHVTLq (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 22 Aug 2022 15:11:46 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33242 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S238302AbiHVTLL (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 22 Aug 2022 15:11:11 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E662213F0D;
        Mon, 22 Aug 2022 12:09:39 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 966EBB8105A;
        Mon, 22 Aug 2022 19:09:11 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0FDA6C433D7;
        Mon, 22 Aug 2022 19:09:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1661195350;
        bh=WWCjwf+JxkZw6WU1iL1hmp/k5Wm7uGOBx3r+Y2H6l1Y=;
        h=From:To:Cc:Subject:Date:From;
        b=mnLUtKYQ+K0xS88by5TxE4Sr1PYVXcwBR2AyrI6v3NsyYaqFjcCvaY2qPRMNd93EW
         CLNY3vCy+qq3Unkhhi1WLrbq94ni40doG9rjTPMRReXQOuo2+hjpjWU9QAUtkfu0pZ
         WQl4XcZ8U/uMRTJ4fxjjUY1KuwqrH8tghMr1kZUARVjknalAiLdEMMbGTn14oIhTsE
         GDYOuxv5G1modgBVW/a760YFTqaXKWzub0sBO/yBjPAMzO3YTm/lPJgDdquf3r51Cb
         8+VF6noBrzCVwHOaXI+HcjfIAvuJYMZP9rkTmPRHN+Fk93mqqR3lQaJpj/yoko0dWS
         S4eO1KMCDkLBg==
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH v3 0/3] fscrypt: rework keyring and stop using request_queue
Date:   Mon, 22 Aug 2022 12:08:09 -0700
Message-Id: <20220822190812.54581-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.37.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Patch 1 of this series reworks the fscrypt filesystem-level keyring to
not use the keyrings subsystem as part of its internal implementation
(except for ->mk_users, which remains unchanged for now).  This fixes
several issues, described in the patch itself.  This is also a
prerequisite for eliminating the direct use of struct request_queue from
filesystem code, as discussed at
https://lore.kernel.org/linux-fscrypt/20220721125929.1866403-1-hch@lst.de/T/#u

Patches 2-3 eliminate the direct uses of struct request_queue from
fs/crypto/ that don't require block layer changes.  (The remaining uses
will be eliminated later by changing some of the blk-crypto functions.)

Changed in v3:
    - Added patch "fscrypt: work on block_devices instead of request_queues"

Changed in v2:
    - Don't compare uninitialized bytes of struct fscrypt_key_specifier
    - Don't use refcount_dec_and_lock() unnecessarily
    - Other minor cleanups

Christoph Hellwig (1):
  fscrypt: work on block_devices instead of request_queues

Eric Biggers (2):
  fscrypt: stop using keyrings subsystem for fscrypt_master_key
  fscrypt: stop holding extra request_queue references

 fs/crypto/fscrypt_private.h |  74 ++++--
 fs/crypto/hooks.c           |  10 +-
 fs/crypto/inline_crypt.c    | 150 ++++++-----
 fs/crypto/keyring.c         | 495 +++++++++++++++++++-----------------
 fs/crypto/keysetup.c        |  89 +++----
 fs/crypto/keysetup_v1.c     |   4 +-
 fs/crypto/policy.c          |   8 +-
 fs/f2fs/super.c             |  24 +-
 fs/super.c                  |   2 +-
 include/linux/fs.h          |   2 +-
 include/linux/fscrypt.h     |  25 +-
 11 files changed, 462 insertions(+), 421 deletions(-)


base-commit: 1c23f9e627a7b412978b4e852793c5e3c3efc555
-- 
2.37.2

