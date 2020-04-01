Return-Path: <SRS0=6ldQ=5R=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85AD5C2D0F3
	for <linux-fscrypt@archiver.kernel.org>; Wed,  1 Apr 2020 20:35:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 515CC20CC7
	for <linux-fscrypt@archiver.kernel.org>; Wed,  1 Apr 2020 20:35:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1585773312;
	bh=lULBR8F0SU6L1eL9eCxVWhUwtdadVqkQZEXiE+fSBDg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=N6phZr0/ygBfSIX9hUKeG033i0laf45hC3F+/8bAPhnQPhYPZ2E93vUwiXv7tUec6
	 plBCpNPopZoWr6XY3Dj2XXDqax+LXT4ueEP0/yoCXUOvDsYftIEVB082XxGy1s/IA6
	 +FvlJ84e6ne8QBuGSt94lypB/6Ew7ihegY6/vfqk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733021AbgDAUe6 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 1 Apr 2020 16:34:58 -0400
Received: from mail.kernel.org ([198.145.29.99]:54404 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732786AbgDAUe4 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 1 Apr 2020 16:34:56 -0400
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.76])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 2571920B1F;
        Wed,  1 Apr 2020 20:34:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1585773296;
        bh=lULBR8F0SU6L1eL9eCxVWhUwtdadVqkQZEXiE+fSBDg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=LG9xQxSpDvgM5C/4tfXsZaQVf7bcZTBuaqmrlaAkHfkkaRxIqcP8UleAOy5gEF0U6
         8jUqGj7rDE/o2uunhqjLEg0duip2YOZgEziQYH18PlNUgTHXYDadQYvCG+B8LR7fba
         aI/GRP0n1aZSplg3ulxPWSeULykq6P/bt+65PTTU=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-ext4@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org
Subject: [PATCH 2/4] tune2fs: prevent stable_inodes feature from being cleared
Date:   Wed,  1 Apr 2020 13:32:37 -0700
Message-Id: <20200401203239.163679-3-ebiggers@kernel.org>
X-Mailer: git-send-email 2.26.0.rc2.310.g2932bb562d-goog
In-Reply-To: <20200401203239.163679-1-ebiggers@kernel.org>
References: <20200401203239.163679-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Similar to encrypt and verity, once the stable_inodes feature has been
enabled there may be files anywhere on the filesystem that require this
feature.  Therefore, in general it's unsafe to allow clearing it.  Don't
allow tune2fs to do so.  Like encrypt and verity, it can still be
cleared with debugfs if someone really knows what they're doing.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 misc/tune2fs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/misc/tune2fs.c b/misc/tune2fs.c
index ca06c98b..81f90cbf 100644
--- a/misc/tune2fs.c
+++ b/misc/tune2fs.c
@@ -181,8 +181,7 @@ static __u32 clear_ok_features[3] = {
 	EXT3_FEATURE_COMPAT_HAS_JOURNAL |
 		EXT2_FEATURE_COMPAT_RESIZE_INODE |
 		EXT2_FEATURE_COMPAT_DIR_INDEX |
-		EXT4_FEATURE_COMPAT_FAST_COMMIT |
-		EXT4_FEATURE_COMPAT_STABLE_INODES,
+		EXT4_FEATURE_COMPAT_FAST_COMMIT,
 	/* Incompat */
 	EXT2_FEATURE_INCOMPAT_FILETYPE |
 		EXT4_FEATURE_INCOMPAT_FLEX_BG |
-- 
2.26.0.rc2.310.g2932bb562d-goog

