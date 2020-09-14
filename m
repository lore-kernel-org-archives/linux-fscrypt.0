Return-Path: <SRS0=4qF/=CX=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17162C43461
	for <linux-fscrypt@archiver.kernel.org>; Mon, 14 Sep 2020 19:19:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D1D7C208E4
	for <linux-fscrypt@archiver.kernel.org>; Mon, 14 Sep 2020 19:19:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600111148;
	bh=gM6sCpb5yU4vQNbnGfPapdqAJL/5qq1Q4OJTc+Ei+eM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=gfp0eMDflrCwJZpS29gv1tXUsxNPKPp9pi+ZihOYeSCxrv+F8YWOYXDVJBL9b6xpg
	 2QdZjA5fmRNwLHgh5VhCv/1DClbLrxfX31X2amyT5bOls83OjrRcoIWf572E0MNZgp
	 DXLud7UUBqFd38rai6y9141RBvlgVw9l5ABVpWhU=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726114AbgINTTG (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 14 Sep 2020 15:19:06 -0400
Received: from mail.kernel.org ([198.145.29.99]:38950 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725964AbgINTRN (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 14 Sep 2020 15:17:13 -0400
Received: from tleilax.com (68-20-15-154.lightspeed.rlghnc.sbcglobal.net [68.20.15.154])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 26FAC21974;
        Mon, 14 Sep 2020 19:17:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600111032;
        bh=gM6sCpb5yU4vQNbnGfPapdqAJL/5qq1Q4OJTc+Ei+eM=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=EZ5oiRLwCH3xwkNGVtwTv6eCr+aNRI14JF44rWDpGU2I4q05noFrDS8cR4IGkTq1f
         qLvYJdpM7rEi7wnBBsXCaYdpllWmq1ew67s9LJ4kTd6cItjDGjhSCl8sm/rJUCYFgs
         Q/vmEtBsPfXli40LcCllmeTns7GTpC81QRb2e+cQ=
From:   Jeff Layton <jlayton@kernel.org>
To:     ceph-devel@vger.kernel.org, linux-fscrypt@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org
Subject: [RFC PATCH v3 03/16] fscrypt: export fscrypt_d_revalidate
Date:   Mon, 14 Sep 2020 15:16:54 -0400
Message-Id: <20200914191707.380444-4-jlayton@kernel.org>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <20200914191707.380444-1-jlayton@kernel.org>
References: <20200914191707.380444-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

ceph already has its own d_revalidate op so we can't rely on fscrypt
using that directly. Export this symbol so filesystems can call it
from their own d_revalidate op.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/crypto/fname.c       | 3 ++-
 include/linux/fscrypt.h | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index a1cb6c2c50c4..0d41eb4a5493 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -578,7 +578,7 @@ EXPORT_SYMBOL_GPL(fscrypt_fname_siphash);
  * Validate dentries in encrypted directories to make sure we aren't potentially
  * caching stale dentries after a key has been added.
  */
-static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
+int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 {
 	struct dentry *dir;
 	int err;
@@ -617,6 +617,7 @@ static int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags)
 
 	return valid;
 }
+EXPORT_SYMBOL_GPL(fscrypt_d_revalidate);
 
 const struct dentry_operations fscrypt_d_ops = {
 	.d_revalidate = fscrypt_d_revalidate,
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 95dddba3ed00..b547e1aabb00 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -204,6 +204,7 @@ int fscrypt_fname_disk_to_usr(const struct inode *inode,
 bool fscrypt_match_name(const struct fscrypt_name *fname,
 			const u8 *de_name, u32 de_name_len);
 u64 fscrypt_fname_siphash(const struct inode *dir, const struct qstr *name);
+int fscrypt_d_revalidate(struct dentry *dentry, unsigned int flags);
 
 /* bio.c */
 void fscrypt_decrypt_bio(struct bio *bio);
-- 
2.26.2

