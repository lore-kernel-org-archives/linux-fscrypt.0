Return-Path: <SRS0=4aov=Z7=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 224AFC43603
	for <linux-fscrypt@archiver.kernel.org>; Mon,  9 Dec 2019 20:39:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DBBF720637
	for <linux-fscrypt@archiver.kernel.org>; Mon,  9 Dec 2019 20:39:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1575923992;
	bh=PWojAHPmGcKcWkmOjQcUlaEKojs4KD6FZuGAVQa3Plw=;
	h=From:To:Subject:Date:List-ID:From;
	b=ML2J8Lv/k67xiom9ek6DSDVgEVnqDvOGPW+66W4M9lgpn1f3e3yJD4B7/45uettSK
	 7pxffpxpC7QKk/TcZdO+2J0FHIEVxcjALBTSYPvkB5iKQGKajYJqCwQ9wZzE0VoGL6
	 z+odzFniY8LKKYV2jciY7/cjng3bgZXkEXkBmbx0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726502AbfLIUjv (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 9 Dec 2019 15:39:51 -0500
Received: from mail.kernel.org ([198.145.29.99]:43138 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726354AbfLIUjv (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 9 Dec 2019 15:39:51 -0500
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id F0D0820637
        for <linux-fscrypt@vger.kernel.org>; Mon,  9 Dec 2019 20:39:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1575923991;
        bh=PWojAHPmGcKcWkmOjQcUlaEKojs4KD6FZuGAVQa3Plw=;
        h=From:To:Subject:Date:From;
        b=ZUDQU6eyj8EacHH1rG6u/Zlg0qyMmdZGzFg1MFbVC5vq3tdvBCiFyaLdTLVcxBSqo
         6OA0tH9cETIwWY/+au6AOA5nVf1IeI6z3V9kXTUkfB9aluhCKViTW+4rah20yYzvQz
         SiD6wrfG8x4vkNavy+4ekMLtdJjFQ4JzSSO7vf9g=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Subject: [PATCH] fscrypt: verify that the crypto_skcipher has the correct ivsize
Date:   Mon,  9 Dec 2019 12:39:18 -0800
Message-Id: <20191209203918.225691-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.24.0.393.g34dc348eaf-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

As a sanity check, verify that the allocated crypto_skcipher actually
has the ivsize that fscrypt is assuming it has.  This will always be the
case unless there's a bug.  But if there ever is such a bug (e.g. like
there was in earlier versions of the ESSIV conversion patch [1]) it's
preferable for it to be immediately obvious, and not rely on the
ciphertext verification tests failing due to uninitialized IV bytes.

[1] https://lkml.kernel.org/linux-crypto/20190702215517.GA69157@gmail.com/

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/keysetup.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index c9f4fe955971f..39fdea79e912f 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -91,6 +91,10 @@ struct crypto_skcipher *fscrypt_allocate_skcipher(struct fscrypt_mode *mode,
 		pr_info("fscrypt: %s using implementation \"%s\"\n",
 			mode->friendly_name, crypto_skcipher_driver_name(tfm));
 	}
+	if (WARN_ON(crypto_skcipher_ivsize(tfm) != mode->ivsize)) {
+		err = -EINVAL;
+		goto err_free_tfm;
+	}
 	crypto_skcipher_set_flags(tfm, CRYPTO_TFM_REQ_FORBID_WEAK_KEYS);
 	err = crypto_skcipher_setkey(tfm, raw_key, mode->keysize);
 	if (err)
-- 
2.24.0.393.g34dc348eaf-goog

