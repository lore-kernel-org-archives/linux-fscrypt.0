Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BD04C64E7A
	for <linux-fscrypt@archiver.kernel.org>; Wed, 25 Nov 2020 00:24:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id AE37921D1A
	for <linux-fscrypt@archiver.kernel.org>; Wed, 25 Nov 2020 00:24:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="K69+GBBX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727364AbgKYAYr (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 24 Nov 2020 19:24:47 -0500
Received: from mail.kernel.org ([198.145.29.99]:35430 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727331AbgKYAYr (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 24 Nov 2020 19:24:47 -0500
Received: from sol.attlocal.net (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id BD4682168B;
        Wed, 25 Nov 2020 00:24:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1606263886;
        bh=sW9kCpHg/sDmA6ymdn9CX3KA5XvEp3ayB2EpWqKWKAU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=K69+GBBXBn4aXkvDANL2m4C3Uwm2MG/DwglSUIEvtrVbRom0kW3lKn/v51W6I0AZp
         EvfWZAt+vU9ps1TyC4Wvoe5R3WKuIPEKEhV1Vzt5W5ypvumvcCCi1wlnBF2IXXMHGW
         NihS0BQPZCcwny3n3ocL9m7Mvn5puvL49h16c83w=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 4/9] ext4: don't call fscrypt_get_encryption_info() from dx_show_leaf()
Date:   Tue, 24 Nov 2020 16:23:31 -0800
Message-Id: <20201125002336.274045-5-ebiggers@kernel.org>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201125002336.274045-1-ebiggers@kernel.org>
References: <20201125002336.274045-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

The call to fscrypt_get_encryption_info() in dx_show_leaf() is too low
in the call tree; fscrypt_get_encryption_info() should have already been
called when starting the directory operation.  And indeed, it already
is.  Moreover, the encryption key is guaranteed to already be available
because dx_show_leaf() is only called when adding a new directory entry.

And even if the key wasn't available, dx_show_leaf() uses
fscrypt_fname_disk_to_usr() which knows how to create a no-key name.

So for the above reasons, and because it would be desirable to stop
exporting fscrypt_get_encryption_info() directly to filesystems, remove
the call to fscrypt_get_encryption_info() from dx_show_leaf().

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/ext4/namei.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 793fc7db9d28..7b31aea3e025 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -643,13 +643,7 @@ static struct stats dx_show_leaf(struct inode *dir,
 
 				name  = de->name;
 				len = de->name_len;
-				if (IS_ENCRYPTED(dir))
-					res = fscrypt_get_encryption_info(dir);
-				if (res) {
-					printk(KERN_WARNING "Error setting up"
-					       " fname crypto: %d\n", res);
-				}
-				if (!fscrypt_has_encryption_key(dir)) {
+				if (!IS_ENCRYPTED(dir)) {
 					/* Directory is not encrypted */
 					ext4fs_dirhash(dir, de->name,
 						de->name_len, &h);
-- 
2.29.2

