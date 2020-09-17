Return-Path: <SRS0=nfbZ=C2=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0419C433E2
	for <linux-fscrypt@archiver.kernel.org>; Thu, 17 Sep 2020 04:20:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 981DA20770
	for <linux-fscrypt@archiver.kernel.org>; Thu, 17 Sep 2020 04:20:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600316436;
	bh=pcuDTH9STD/mcWVjY9xk4V3olh0O7QdLKYJXVZYhQo8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=uwz4xreGLOMGPUWdb0phk6/635btlVhOQ6Ya/8L8m6MnT4BszxyOwIS7wCvxzbsz9
	 KBhqUMJdTkGjTR01VHlQgIpQXjTnEUaRvmbH8xweJW7B4vIwMP/a/hA41aKmj2XIEN
	 rnxDBgW0k1D+TfnoVT/BEOl8jyTIGsjMGnM8AvHU=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726185AbgIQEUf (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 17 Sep 2020 00:20:35 -0400
Received: from mail.kernel.org ([198.145.29.99]:33818 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726115AbgIQEUd (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 17 Sep 2020 00:20:33 -0400
Received: from sol.attlocal.net (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 9750121D41;
        Thu, 17 Sep 2020 04:13:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600315989;
        bh=pcuDTH9STD/mcWVjY9xk4V3olh0O7QdLKYJXVZYhQo8=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=WjOZn/iFKAnidcOCFe+ysawmOaq+wZI9ahIoTC+JpTCuGheF3T5BHxOwXh1kL3zCZ
         3bymu2kDogYINSoFHUgY+sOPCKrKs0XS/Hi5wozjy5gL6kj6NUPkMa8IZcCNDveVRT
         WvDDwm829kBpdreaI9WfPgzWgY3w2UuXhMRU3Kk4=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, ceph-devel@vger.kernel.org,
        Jeff Layton <jlayton@kernel.org>,
        Daniel Rosenberg <drosen@google.com>
Subject: [PATCH v3 06/13] fscrypt: adjust logging for in-creation inodes
Date:   Wed, 16 Sep 2020 21:11:29 -0700
Message-Id: <20200917041136.178600-7-ebiggers@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20200917041136.178600-1-ebiggers@kernel.org>
References: <20200917041136.178600-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Now that a fscrypt_info may be set up for inodes that are currently
being created and haven't yet had an inode number assigned, avoid
logging confusing messages about "inode 0".

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/crypto.c  | 4 +++-
 fs/crypto/keyring.c | 9 +++++++--
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 9212325763b0f..4ef3f714046aa 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -343,9 +343,11 @@ void fscrypt_msg(const struct inode *inode, const char *level,
 	va_start(args, fmt);
 	vaf.fmt = fmt;
 	vaf.va = &args;
-	if (inode)
+	if (inode && inode->i_ino)
 		printk("%sfscrypt (%s, inode %lu): %pV\n",
 		       level, inode->i_sb->s_id, inode->i_ino, &vaf);
+	else if (inode)
+		printk("%sfscrypt (%s): %pV\n", level, inode->i_sb->s_id, &vaf);
 	else
 		printk("%sfscrypt: %pV\n", level, &vaf);
 	va_end(args);
diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index e74f239c44280..53cc552a7b8fd 100644
--- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -817,6 +817,7 @@ static int check_for_busy_inodes(struct super_block *sb,
 	struct list_head *pos;
 	size_t busy_count = 0;
 	unsigned long ino;
+	char ino_str[50] = "";
 
 	spin_lock(&mk->mk_decrypted_inodes_lock);
 
@@ -838,11 +839,15 @@ static int check_for_busy_inodes(struct super_block *sb,
 	}
 	spin_unlock(&mk->mk_decrypted_inodes_lock);
 
+	/* If the inode is currently being created, ino may still be 0. */
+	if (ino)
+		snprintf(ino_str, sizeof(ino_str), ", including ino %lu", ino);
+
 	fscrypt_warn(NULL,
-		     "%s: %zu inode(s) still busy after removing key with %s %*phN, including ino %lu",
+		     "%s: %zu inode(s) still busy after removing key with %s %*phN%s",
 		     sb->s_id, busy_count, master_key_spec_type(&mk->mk_spec),
 		     master_key_spec_len(&mk->mk_spec), (u8 *)&mk->mk_spec.u,
-		     ino);
+		     ino_str);
 	return -EBUSY;
 }
 
-- 
2.28.0

