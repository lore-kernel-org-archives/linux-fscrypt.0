Return-Path: <SRS0=b6rW=2Q=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB961C2D0DA
	for <linux-fscrypt@archiver.kernel.org>; Thu, 26 Dec 2019 16:11:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AE648206CB
	for <linux-fscrypt@archiver.kernel.org>; Thu, 26 Dec 2019 16:11:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1577376700;
	bh=eIQ2GXEdslJ7L4LC+4Jz1YODyvsdHBOfk70hJwoxkH8=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=xBNNrZtMD9sadiIHNjSnnyZFJsJ4eI/bc1nUjqqXn/K2BY3eOfS5sYFbxKV1Yhsg8
	 g8d9Kvn9n+VoWX2V88P9N8x2ASNMaM12nAdlHRbNBaziyEFxv9Ct9jr+RRB7uxCakN
	 QC6I5g63x32Km407CpciH/mlNMAt8vWsJdf2cZG4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726480AbfLZQLk (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 26 Dec 2019 11:11:40 -0500
Received: from mail.kernel.org ([198.145.29.99]:39470 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726236AbfLZQLk (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 26 Dec 2019 11:11:40 -0500
Received: from zzz.tds (h75-100-12-111.burkwi.broadband.dynamic.tds.net [75.100.12.111])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4A8BF206CB;
        Thu, 26 Dec 2019 16:11:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1577376699;
        bh=eIQ2GXEdslJ7L4LC+4Jz1YODyvsdHBOfk70hJwoxkH8=;
        h=From:To:Cc:Subject:Date:From;
        b=rmaTmp27/3j9854wLtx36wYMteKO7I/zrVD+DtQDoOlZp6t9hvYNs1x8aeiJvhvKk
         2L+OnIcRQefB6E6VNA6opb/v1vMG+VGIMaGeDg3vXG6nrr75mmdvUWT13F4FBV+Q4q
         k3kV+KGpK3OmAnZS8egDixTPY7FP66Rmh1oL3EI8=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-ext4@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org
Subject: [PATCH] ext4: re-enable extent zeroout optimization on encrypted files
Date:   Thu, 26 Dec 2019 10:11:14 -0600
Message-Id: <20191226161114.53606-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.24.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

For encrypted files, commit 36086d43f657 ("ext4 crypto: fix bugs in
ext4_encrypted_zeroout()") disabled the optimization where when a write
occurs to the middle of an unwritten extent, the head and/or tail of the
extent (when they aren't too large) are zeroed out, turned into an
initialized extent, and merged with the part being written to.  This
optimization helps prevent fragmentation of the extent tree.

However, disabling this optimization also made fscrypt_zeroout_range()
nearly impossible to test, as now it's only reachable via the very rare
case in ext4_split_extent_at() where allocating a new extent tree block
fails due to ENOSPC.  'gce-xfstests -c ext4/encrypt -g auto' doesn't
even hit this at all.

It's preferable to avoid really rare cases that are hard to test.

That commit also cited data corruption in xfstest generic/127 as a
reason to disable the extent zeroout optimization, but that's no longer
reproducible anymore.  It also cited fscrypt_zeroout_range() having poor
performance, but I've written a patch to fix that.

Therefore, re-enable the extent zeroout optimization on encrypted files.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/extents.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/ext4/extents.c b/fs/ext4/extents.c
index dae66e8f0c3a..fee19c9f5fe3 100644
--- a/fs/ext4/extents.c
+++ b/fs/ext4/extents.c
@@ -3718,9 +3718,6 @@ static int ext4_ext_convert_to_initialized(handle_t *handle,
 		max_zeroout = sbi->s_extent_max_zeroout_kb >>
 			(inode->i_sb->s_blocksize_bits - 10);
 
-	if (IS_ENCRYPTED(inode))
-		max_zeroout = 0;
-
 	/*
 	 * five cases:
 	 * 1. split the extent into three extents.
-- 
2.24.1

