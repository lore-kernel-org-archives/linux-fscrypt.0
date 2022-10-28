Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0801DC38A02
	for <linux-fscrypt@archiver.kernel.org>; Fri, 28 Oct 2022 22:47:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229916AbiJ1Wrs (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 28 Oct 2022 18:47:48 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54804 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229501AbiJ1Wrs (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 28 Oct 2022 18:47:48 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 618DB199F45;
        Fri, 28 Oct 2022 15:47:47 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id E53F062A9A;
        Fri, 28 Oct 2022 22:47:46 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2D9EEC43470;
        Fri, 28 Oct 2022 22:47:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1666997266;
        bh=bqK81I/T6k3G4i3s/QXoplbiUG5b/2q9qN47fUeLeWQ=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=iw9YE3wb75BUEOFeFHw5T2uj6gkdp+UdqpvS6EZgDy36esM9mRbr6PCr9iHEOp1yy
         EcNOS70sj+GbP1Coa89lWAZsPe7RubuqyUm37SNUfCiQtTCwaw1OTs493O4AxwlW2u
         7ANrvU1NFT3nO6/TiQDMlRZ4EtiZvNfLBI8rIT6y4ADKJRJycR3DKWLtD+Ongrpes3
         vBXcQMu8t5B/k5SHqyr3KxngyzSBzqhOk7Sb2qAh6CJf5ua1uVSxp8i8nE4Ea/UEuI
         XLWPs0uSmdY6a8BxGO5Iz6XFwo+5VkXnIUEhpwOIfy3TzZUvmM4cASyjOIPh+3navN
         UIT4TNd6qrKUw==
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-btrfs@vger.kernel.org
Subject: [PATCH 3/6] ext4: simplify ext4_readpage_limit()
Date:   Fri, 28 Oct 2022 15:45:36 -0700
Message-Id: <20221028224539.171818-4-ebiggers@kernel.org>
X-Mailer: git-send-email 2.38.0
In-Reply-To: <20221028224539.171818-1-ebiggers@kernel.org>
References: <20221028224539.171818-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Now that the implementation of FS_IOC_ENABLE_VERITY has changed to not
involve reading back Merkle tree blocks that were previously written,
there is no need for ext4_readpage_limit() to allow for this case.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/readpage.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index e604ea4e102b7..babaa7160c556 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -211,8 +211,7 @@ static void ext4_set_bio_post_read_ctx(struct bio *bio,
 
 static inline loff_t ext4_readpage_limit(struct inode *inode)
 {
-	if (IS_ENABLED(CONFIG_FS_VERITY) &&
-	    (IS_VERITY(inode) || ext4_verity_in_progress(inode)))
+	if (IS_ENABLED(CONFIG_FS_VERITY) && IS_VERITY(inode))
 		return inode->i_sb->s_maxbytes;
 
 	return i_size_read(inode);
-- 
2.38.0

