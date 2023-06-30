Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D57FEB64DA
	for <linux-fscrypt@archiver.kernel.org>; Fri, 30 Jun 2023 06:49:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230436AbjF3GtE (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 30 Jun 2023 02:49:04 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39146 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229545AbjF3Gs7 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 30 Jun 2023 02:48:59 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 646613582;
        Thu, 29 Jun 2023 23:48:57 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id ED5F5616D7;
        Fri, 30 Jun 2023 06:48:56 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3FD5CC433CA;
        Fri, 30 Jun 2023 06:48:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1688107736;
        bh=SdK8Jx7ZeCSSRNnAfBP2bIbNyUBe/k14Bu7s+8phFXY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=MwSG6oy+qo3aQcrqjyYTFH0JvZw7AVhNcR+qQeTpz7l+64cex3pEclDd3Y0QYS8pC
         x1kVCBusFIsH9f+ZhZ45JYvv6G36GtG97PEdi3BQhpbka3RZk2CWbE6HeAetls7PkG
         yJ21yyYt8pU+PnRJGTzm3N0Rz2oNwyPC98apTVOIoOCpgmAea7l+Wc+i9bSUnmyOtR
         0wkJaP9/cAiVQN9ABWtMW6g7EMI+immvA+zOHl8LvkePHP0njiHr/FbwmuFOpF/OdI
         b+jHJcj5BMq+kudJFdcQr++EhgjFYT/9fboiB5aMt98/omDdFGSdzIt6+FNQZdXKy5
         jqucdFK9F8HdQ==
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-crypto@vger.kernel.org, Dongsoo Lee <letrhee@nsr.re.kr>
Subject: [PATCH 2/2] fscrypt: document the LEA support
Date:   Thu, 29 Jun 2023 23:48:11 -0700
Message-ID: <20230630064811.22569-3-ebiggers@kernel.org>
X-Mailer: git-send-email 2.41.0
In-Reply-To: <20230630064811.22569-1-ebiggers@kernel.org>
References: <20230630064811.22569-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Document the LEA encryption support in fscrypt.rst.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 Documentation/filesystems/fscrypt.rst | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index a624e92f2687f..84fbda668191e 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -343,6 +343,7 @@ Currently, the following pairs of encryption modes are supported:
 - Adiantum for both contents and filenames
 - AES-128-CBC-ESSIV for contents and AES-128-CTS-CBC for filenames
 - SM4-XTS for contents and SM4-CTS-CBC for filenames
+- LEA-256-XTS for contents and LEA-256-CTS-CBC for filenames
 
 Authenticated encryption modes are not currently supported because of
 the difficulty of dealing with ciphertext expansion.  Therefore,
@@ -382,6 +383,7 @@ accelerator such as CAAM or CESA that does not support XTS.
 The remaining mode pairs are the "national pride ciphers":
 
 - (SM4-XTS, SM4-CTS-CBC)
+- (LEA-256-XTS, LEA-256-CTS-CBC)
 
 Generally speaking, these ciphers aren't "bad" per se, but they
 receive limited security review compared to the usual choices such as
-- 
2.41.0

