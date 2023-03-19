Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 688B5C6FD1F
	for <linux-fscrypt@archiver.kernel.org>; Sun, 19 Mar 2023 19:39:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229832AbjCSTje (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sun, 19 Mar 2023 15:39:34 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49240 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229767AbjCSTj3 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 19 Mar 2023 15:39:29 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 573DD11E96;
        Sun, 19 Mar 2023 12:39:04 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 8F26461179;
        Sun, 19 Mar 2023 19:39:04 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D8C72C4339C;
        Sun, 19 Mar 2023 19:39:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1679254743;
        bh=XBZDmxFeSpqtrCWRREzzaete3GA1/5ivnYhQM9sc2To=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=XjsAAjt0smsHGFtXoThmukbzqKa6Qvx3KeiZiCsRZwUDadGwGAKATY8a9wG2Fwgzq
         RONShGcRaG3RrSuuh7CH+GwGcTfzrT2zvz8EqjjAoC9/ltBnQKY0LoWRo4Rb3kL+ky
         UVwTdun3QWGdnn/3iz9adupHAgQdX0Vl7cj2m9ZCnhepGe7VfcC7U9hdgPUhZfPGtY
         sA6x51edtuVhZrktypybILkuh509TDbzd9DOOBMfdRaIfxj4PnmTfz04zECVINPoOl
         RIOnD+um9kuMetTQPDstwcHIZ8L/kZT8wEj6wKeU4iZwarobXoO8yiqqrR7PGqrYBJ
         aVUH3dlOJjmlw==
From:   Eric Biggers <ebiggers@kernel.org>
To:     fstests@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org
Subject: [PATCH 3/3] fscrypt-crypt-util: fix XTS self-test with latest OpenSSL
Date:   Sun, 19 Mar 2023 12:38:47 -0700
Message-Id: <20230319193847.106872-4-ebiggers@kernel.org>
X-Mailer: git-send-email 2.40.0
In-Reply-To: <20230319193847.106872-1-ebiggers@kernel.org>
References: <20230319193847.106872-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

In OpenSSL 3.0, XTS encryption fails if the message is zero-length.
Therefore, update test_aes_256_xts() to not test this case.

This only affects the algorithm self-tests within fscrypt-crypt-util,
which are not compiled by default.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 src/fscrypt-crypt-util.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/src/fscrypt-crypt-util.c b/src/fscrypt-crypt-util.c
index 040b80c0..6edf0047 100644
--- a/src/fscrypt-crypt-util.c
+++ b/src/fscrypt-crypt-util.c
@@ -1107,12 +1107,16 @@ static void test_aes_256_xts(void)
 	while (num_tests--) {
 		u8 key[2 * AES_256_KEY_SIZE];
 		u8 iv[AES_BLOCK_SIZE];
-		u8 ptext[512];
+		u8 ptext[32 * AES_BLOCK_SIZE];
 		u8 ctext[sizeof(ptext)];
 		u8 ref_ctext[sizeof(ptext)];
 		u8 decrypted[sizeof(ptext)];
-		const size_t datalen = ROUND_DOWN(rand() % (1 + sizeof(ptext)),
-						  AES_BLOCK_SIZE);
+		// Don't test message lengths that aren't a multiple of the AES
+		// block size, since support for that is not implemented here.
+		// Also don't test zero-length messages, since OpenSSL 3.0 and
+		// later returns an error for those.
+		const size_t datalen = AES_BLOCK_SIZE *
+			(1 + rand() % (sizeof(ptext) / AES_BLOCK_SIZE));
 		int outl, res;
 
 		rand_bytes(key, sizeof(key));
-- 
2.40.0

