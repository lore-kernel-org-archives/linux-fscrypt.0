Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA723C433F5
	for <linux-fscrypt@archiver.kernel.org>; Mon,  6 Sep 2021 12:56:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A571761050
	for <linux-fscrypt@archiver.kernel.org>; Mon,  6 Sep 2021 12:56:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S242661AbhIFM6A (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 6 Sep 2021 08:58:00 -0400
Received: from mail.kernel.org ([198.145.29.99]:34088 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S242321AbhIFM5n (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 6 Sep 2021 08:57:43 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id E10CB60F92;
        Mon,  6 Sep 2021 12:56:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
        s=korg; t=1630932999;
        bh=OgYCzNSAmHAJIMchHWHi3CWoRBsZ0US8dQMiggFdiMU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=MKPYxcgD/zyD5jrJrHsLOWzgoGn13nZiOYuBOZ+qvA6dfIoYU1dfU3q4xHd7rb0l/
         fdPlCN/UyMllR3anI3KzcncoUMGseh5QZlp024XoqZvpJuS8GlexqFOFIHS3rRyS+h
         YxT8WSlEd7L5uHZpe7cT8CsjvMP30mFXSXwnvJjY=
From:   Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>
Subject: [PATCH 5.10 03/29] ext4: report correct st_size for encrypted symlinks
Date:   Mon,  6 Sep 2021 14:55:18 +0200
Message-Id: <20210906125449.877712012@linuxfoundation.org>
X-Mailer: git-send-email 2.33.0
In-Reply-To: <20210906125449.756437409@linuxfoundation.org>
References: <20210906125449.756437409@linuxfoundation.org>
User-Agent: quilt/0.66
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

commit 8c4bca10ceafc43b1ca0a9fab5fa27e13cbce99e upstream.

The stat() family of syscalls report the wrong size for encrypted
symlinks, which has caused breakage in several userspace programs.

Fix this by calling fscrypt_symlink_getattr() after ext4_getattr() for
encrypted symlinks.  This function computes the correct size by reading
and decrypting the symlink target (if it's not already cached).

For more details, see the commit which added fscrypt_symlink_getattr().

Fixes: f348c252320b ("ext4 crypto: add symlink encryption")
Cc: stable@vger.kernel.org
Link: https://lore.kernel.org/r/20210702065350.209646-3-ebiggers@kernel.org
Signed-off-by: Eric Biggers <ebiggers@google.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 fs/ext4/symlink.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

--- a/fs/ext4/symlink.c
+++ b/fs/ext4/symlink.c
@@ -52,10 +52,19 @@ static const char *ext4_encrypted_get_li
 	return paddr;
 }
 
+static int ext4_encrypted_symlink_getattr(const struct path *path,
+					  struct kstat *stat, u32 request_mask,
+					  unsigned int query_flags)
+{
+	ext4_getattr(path, stat, request_mask, query_flags);
+
+	return fscrypt_symlink_getattr(path, stat);
+}
+
 const struct inode_operations ext4_encrypted_symlink_inode_operations = {
 	.get_link	= ext4_encrypted_get_link,
 	.setattr	= ext4_setattr,
-	.getattr	= ext4_getattr,
+	.getattr	= ext4_encrypted_symlink_getattr,
 	.listxattr	= ext4_listxattr,
 };
 


