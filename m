Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5B13C433DB
	for <linux-fscrypt@archiver.kernel.org>; Wed,  3 Mar 2021 04:45:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 86F7364EBA
	for <linux-fscrypt@archiver.kernel.org>; Wed,  3 Mar 2021 04:45:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233622AbhCCEeg (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 2 Mar 2021 23:34:36 -0500
Received: from mail.kernel.org ([198.145.29.99]:57760 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1349212AbhCBUGA (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 2 Mar 2021 15:06:00 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id D4D1064F2C;
        Tue,  2 Mar 2021 20:05:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1614715504;
        bh=R0uWWdo55T3Y2P3LKpd1Ma1UuCXVZi07erMDI9ljXRg=;
        h=From:To:Cc:Subject:Date:From;
        b=Oz98igqXh+9c0+eqzJYbO7IcceScj37KATh8VUDVq814CVm02xIfdSrgZs7ItY89X
         lyGILhbaenhs1nXMRlAuJTNj8FTljQqIvO6DDGEN5ylJINfpO5m2hxjZngi29Rnyw0
         zL95MaD/DhnWLLybAB2QzchHr91meBG9YfRNbG6N0jSz+P6aDqXAKt0J2tj3oWH4Zk
         DxlIgkc/qbPdvIexTwIXXbmPaN14zq++fZ7+7VBS71U7IzSdEwEhsXCgDxcNI85kjn
         5tVB/Xhd6SJvV0qiAoS+b/jGmJGyo9MBbWZX2yQLuLbhK7YJ5t6BLBruBIyiwgkW5t
         c5POEGAMRQjyw==
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc:     linux-fscrypt@vger.kernel.org, Yunlei He <heyunlei@hihonor.com>,
        bintian.wang@hihonor.com
Subject: [PATCH 0/2] fs-verity: fix error handling in ->end_enable_verity()
Date:   Tue,  2 Mar 2021 12:04:18 -0800
Message-Id: <20210302200420.137977-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.30.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Fix some bugs in how ext4_end_enable_verity() and
f2fs_end_enable_verity() handle failure to enable verity on the file.

This is intended to supersede the f2fs patch from Yunlei He
(https://lore.kernel.org/r/20210302113850.17011-1-heyunlei@hihonor.com,
 https://lore.kernel.org/r/20210301141506.6410-1-heyunlei@hihonor.com,
 https://lore.kernel.org/r/c1ce1421-2576-5b48-322c-fa682c7510d7@kernel.org).
I fixed the same bugs in ext4 too, reworked the functions to cleanly
separate the success and error paths, and improved the commit message.

These patches can be taken independently via the ext4 and f2fs trees.
I've just sent them out together since they're similar.

Eric Biggers (2):
  ext4: fix error handling in ext4_end_enable_verity()
  f2fs: fix error handling in f2fs_end_enable_verity()

 fs/ext4/verity.c | 90 ++++++++++++++++++++++++++++++------------------
 fs/f2fs/verity.c | 61 +++++++++++++++++++++-----------
 2 files changed, 97 insertions(+), 54 deletions(-)

-- 
2.30.1

