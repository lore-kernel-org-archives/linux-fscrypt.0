Return-Path: <SRS0=4aov=Z7=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E97C4C3F68F
	for <linux-fscrypt@archiver.kernel.org>; Mon,  9 Dec 2019 21:19:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B0F0E207FF
	for <linux-fscrypt@archiver.kernel.org>; Mon,  9 Dec 2019 21:19:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1575926364;
	bh=6FVkRlG5KKy/tpIJ9gSiELJuRX721e3LnTCgXc1GdLE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=0rAmrc1wNDppD7yZWSNJQbYrk4xVNrO4cGt9BS/2ID+A87Jna5CPChX7dX2yJv1us
	 LrBDGa5ET7ZnPHM43UN51QTpj8/ZJ/ZH6J8uJvvMzjVEoJ0uU1hqP55msjxQKsYnp9
	 BldmjpkuVs55LiHUTuQhdUpp1MvQQ9/BC0igqOKY=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726538AbfLIVTY (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 9 Dec 2019 16:19:24 -0500
Received: from mail.kernel.org ([198.145.29.99]:53428 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726968AbfLIVTY (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 9 Dec 2019 16:19:24 -0500
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 995622077B;
        Mon,  9 Dec 2019 21:19:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1575926363;
        bh=6FVkRlG5KKy/tpIJ9gSiELJuRX721e3LnTCgXc1GdLE=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=yKEId9lsGHiN+vn2h3RzDh15xpn4kSvDmGyu/1pTr2/lJvkb/E8K0ddDF8ZPQ7bke
         pkaEYo4j0GxCKjl5Z48EavOgLnafmZ0q3vZjqG0MDv+kFQKYx3CR39cNSA47C0y7ow
         YDhG2vKi81iS2dkIwBDFAHmUmy2aNnDjbX/QFxCk=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     Daniel Rosenberg <drosen@google.com>
Subject: [PATCH 4/4] fscrypt: remove fscrypt_is_direct_key_policy()
Date:   Mon,  9 Dec 2019 13:18:29 -0800
Message-Id: <20191209211829.239800-5-ebiggers@kernel.org>
X-Mailer: git-send-email 2.24.0.393.g34dc348eaf-goog
In-Reply-To: <20191209211829.239800-1-ebiggers@kernel.org>
References: <20191209211829.239800-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

fscrypt_is_direct_key_policy() is no longer used, so remove it.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/fscrypt_private.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 71f496fe71732..b22e8decebedd 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -136,12 +136,6 @@ fscrypt_policy_flags(const union fscrypt_policy *policy)
 	BUG();
 }
 
-static inline bool
-fscrypt_is_direct_key_policy(const union fscrypt_policy *policy)
-{
-	return fscrypt_policy_flags(policy) & FSCRYPT_POLICY_FLAG_DIRECT_KEY;
-}
-
 /**
  * For encrypted symlinks, the ciphertext length is stored at the beginning
  * of the string in little-endian format.
-- 
2.24.0.393.g34dc348eaf-goog

