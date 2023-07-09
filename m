Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFAF8C001B0
	for <linux-fscrypt@archiver.kernel.org>; Sun,  9 Jul 2023 19:11:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229840AbjGITL1 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sun, 9 Jul 2023 15:11:27 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:35136 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229769AbjGITL0 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 9 Jul 2023 15:11:26 -0400
Received: from box.fidei.email (box.fidei.email [71.19.144.250])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A4A1A128;
        Sun,  9 Jul 2023 12:11:25 -0700 (PDT)
Received: from authenticated-user (box.fidei.email [71.19.144.250])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
        (No client certificate requested)
        by box.fidei.email (Postfix) with ESMTPSA id 1E6BA804AA;
        Sun,  9 Jul 2023 15:11:25 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=dorminy.me; s=mail;
        t=1688929885; bh=KsB5sQbySYMhE+PMRxhIhPEsjLq+a0xS6NkFqRAT2JM=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=GrVV2ygHXfrPEAvwjwESW1iGJxVvF34RFPfntSSyvRw8RwRZavJgrSjAkRHNeKCHA
         dmmN3ug6kd2vuAJkTFR4nN/bzhCYArGL5O43yqT0e116RpFAh9+M2bN0dBLNT+nS4O
         X0AyWZ1jIrVhCRR+ObhgfvALkQwRH0w9Gu0V/rMuB59sewphBQqjOoRzLi1WHhISqu
         1l3CD1jUKINhVMyjGYg7MfIZ32Jn/LuyPfefHYvZF2+qZHA+QJy0H3GsA9QSnNH4sb
         dmY0PPfRUuiE9rNqggU8OOQ+/JtThT9c3PCNscb1VwAz6vr1vNi0bYAv7v4KPHQxqX
         6zSxLVdNxdr/A==
From:   Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
To:     linux-btrfs@vger.kernel.org, fstests@vger.kernel.org,
        kernel-team@meta.com, ebiggers@google.com, anand.jain@oracle.com,
        fdmanana@suse.com, linux-fscrypt@vger.kernel.org,
        fsverity@lists.linux.dev, zlang@kernel.org
Cc:     Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: [RFC PATCH v2 7/8] common/verity: explicitly don't allow btrfs encryption
Date:   Sun,  9 Jul 2023 15:11:10 -0400
Message-Id: <d8fd17f15e6b94b3d2fe2a73f0a9bd8f6b181be9.1688929294.git.sweettea-kernel@dorminy.me>
In-Reply-To: <cover.1688929294.git.sweettea-kernel@dorminy.me>
References: <cover.1688929294.git.sweettea-kernel@dorminy.me>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Currently btrfs encryption doesn't support verity, but it is planned to
one day. To be explicit about the lack of support, add a custom error
message to the combination.

Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
---
 common/verity | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/common/verity b/common/verity
index 77c257d3..5002dd71 100644
--- a/common/verity
+++ b/common/verity
@@ -218,6 +218,10 @@ _scratch_mkfs_encrypted_verity()
 		# features with -O.  Instead -O must be supplied multiple times.
 		_scratch_mkfs -O encrypt -O verity
 		;;
+	btrfs)
+		# currently verity + encryption is not supported
+		_notrun "btrfs doesn't currently support verity + encryption"
+		;;
 	*)
 		_notrun "$FSTYP not supported in _scratch_mkfs_encrypted_verity"
 		;;
-- 
2.40.1

