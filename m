Return-Path: <SRS0=eEUB=CC=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47BADC43445
	for <linux-fscrypt@archiver.kernel.org>; Mon, 24 Aug 2020 06:35:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5AC5A22BEA
	for <linux-fscrypt@archiver.kernel.org>; Mon, 24 Aug 2020 06:18:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1598249923;
	bh=pIJmvup/1NleSfxl2m1+2qODicItN3VVq+lhGxjetoU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=qdG3woxWjqRid5mGnvNCt83nyTL3ZvSoRaZ5ubkM/sUGbY3GzpSNYYWGecowNgVrn
	 xQcI9sWA346nlFHYm5HpVbhW3vzlDJUiixZ21VfkbXH2nkpjJp6FvaEMA9eV3ToRjV
	 fHfjirXoq5K7S3Rirz1Zq8Mg7v3nu1UU8eihX20Q=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726086AbgHXGSf (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 24 Aug 2020 02:18:35 -0400
Received: from mail.kernel.org ([198.145.29.99]:49810 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726056AbgHXGSU (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 24 Aug 2020 02:18:20 -0400
Received: from sol.hsd1.ca.comcast.net (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id E52FA22B3F;
        Mon, 24 Aug 2020 06:18:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1598249900;
        bh=pIJmvup/1NleSfxl2m1+2qODicItN3VVq+lhGxjetoU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=s1qf4bw7OzIhw2/GHG8djl8PDMxSjLTOyniDndG+OavXM3SB413ffm3u+jx22B71h
         cvDSDtULDtHOJuHzs25NU0a4oxzPGs1bm7o4WXxd46oeti/Bc2CJIcXuWk/FwxpDD+
         se+eF27vWpLQ3Zxk5GkkVvP14wSVYw+0gacJdnnY=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, ceph-devel@vger.kernel.org,
        Jeff Layton <jlayton@kernel.org>
Subject: [RFC PATCH 6/8] ubifs: use fscrypt_prepare_new_inode() and fscrypt_set_context()
Date:   Sun, 23 Aug 2020 23:17:10 -0700
Message-Id: <20200824061712.195654-7-ebiggers@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20200824061712.195654-1-ebiggers@kernel.org>
References: <20200824061712.195654-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Convert ubifs to use the new functions fscrypt_prepare_new_inode() and
fscrypt_set_context().

Unlike ext4 and f2fs, this doesn't appear to fix any deadlock bug.  But
it does shorten the code slightly and get all filesystems using the same
helper functions, so that fscrypt_inherit_context() can be removed.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ubifs/dir.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 9d042942d8b29..26739ae3ffee7 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -81,19 +81,6 @@ struct inode *ubifs_new_inode(struct ubifs_info *c, struct inode *dir,
 	struct ubifs_inode *ui;
 	bool encrypted = false;
 
-	if (IS_ENCRYPTED(dir)) {
-		err = fscrypt_get_encryption_info(dir);
-		if (err) {
-			ubifs_err(c, "fscrypt_get_encryption_info failed: %i", err);
-			return ERR_PTR(err);
-		}
-
-		if (!fscrypt_has_encryption_key(dir))
-			return ERR_PTR(-EPERM);
-
-		encrypted = true;
-	}
-
 	inode = new_inode(c->vfs_sb);
 	ui = ubifs_inode(inode);
 	if (!inode)
@@ -112,6 +99,14 @@ struct inode *ubifs_new_inode(struct ubifs_info *c, struct inode *dir,
 			 current_time(inode);
 	inode->i_mapping->nrpages = 0;
 
+	err = fscrypt_prepare_new_inode(dir, inode, &encrypted);
+	if (err) {
+		ubifs_err(c, "fscrypt_prepare_new_inode failed: %i", err);
+		make_bad_inode(inode);
+		iput(inode);
+		return ERR_PTR(err);
+	}
+
 	switch (mode & S_IFMT) {
 	case S_IFREG:
 		inode->i_mapping->a_ops = &ubifs_file_address_operations;
@@ -131,7 +126,6 @@ struct inode *ubifs_new_inode(struct ubifs_info *c, struct inode *dir,
 	case S_IFBLK:
 	case S_IFCHR:
 		inode->i_op  = &ubifs_file_inode_operations;
-		encrypted = false;
 		break;
 	default:
 		BUG();
@@ -171,9 +165,9 @@ struct inode *ubifs_new_inode(struct ubifs_info *c, struct inode *dir,
 	spin_unlock(&c->cnt_lock);
 
 	if (encrypted) {
-		err = fscrypt_inherit_context(dir, inode, &encrypted, true);
+		err = fscrypt_set_context(inode, NULL);
 		if (err) {
-			ubifs_err(c, "fscrypt_inherit_context failed: %i", err);
+			ubifs_err(c, "fscrypt_set_context failed: %i", err);
 			make_bad_inode(inode);
 			iput(inode);
 			return ERR_PTR(err);
-- 
2.28.0

