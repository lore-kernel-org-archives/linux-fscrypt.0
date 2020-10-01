Return-Path: <SRS0=0etf=DI=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5295C47429
	for <linux-fscrypt@archiver.kernel.org>; Thu,  1 Oct 2020 00:25:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 795442184D
	for <linux-fscrypt@archiver.kernel.org>; Thu,  1 Oct 2020 00:25:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1601511933;
	bh=pB9+XDQedKRY2rzT9jphCHX3wT7Ws8YKXXmwKKr3fqI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=aGxvghI95mhkRB1jDtetEVNtjnfqbjsIC61rSAeSMQ5LM281Eg7wYLIpiBOKjadOc
	 vdqO9h29OxDpkB51PLvp14nYK8munorf7WoYWwAuXuYcro1tlpMtoL3mq3GiVqrObD
	 gU3YQozCbggXl1n8gt0g76faJFAtkDKT1b7R80sg=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730031AbgJAAZd (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 30 Sep 2020 20:25:33 -0400
Received: from mail.kernel.org ([198.145.29.99]:54480 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730258AbgJAAZc (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 30 Sep 2020 20:25:32 -0400
Received: from sol.attlocal.net (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id F408021D41;
        Thu,  1 Oct 2020 00:25:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1601511932;
        bh=pB9+XDQedKRY2rzT9jphCHX3wT7Ws8YKXXmwKKr3fqI=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=yfKcrQRXtoPbngq70GQzXwip6neeb4NWmPs8QuC2hGTDqQ8YKwt4vguf8qcZPeguP
         Y7qwwXqMqq6u7RH+CxurGR6yDQQNEt2L6ej9h6y9vDW+ng6xFBeFNbg2k49d+0W6rS
         +PsEMNKbwf0p0xH6Fsv0lw2cYVYATsS+j3e2clb8=
From:   Eric Biggers <ebiggers@kernel.org>
To:     fstests@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>,
        Daeho Jeong <daeho43@gmail.com>
Subject: [PATCH 4/5] common/f2fs: add _require_scratch_f2fs_compression()
Date:   Wed, 30 Sep 2020 17:25:06 -0700
Message-Id: <20201001002508.328866-5-ebiggers@kernel.org>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201001002508.328866-1-ebiggers@kernel.org>
References: <20201001002508.328866-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Create the file common/f2fs, which will contain f2fs-specific utilities.

Then add a function _require_scratch_f2fs_compression(), which checks
for f2fs compression support on the scratch filesystem.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 common/f2fs | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)
 create mode 100644 common/f2fs

diff --git a/common/f2fs b/common/f2fs
new file mode 100644
index 00000000..1b39d8ce
--- /dev/null
+++ b/common/f2fs
@@ -0,0 +1,27 @@
+#!/bin/bash
+# SPDX-License-Identifier: GPL-2.0-only
+# Copyright 2020 Google LLC
+
+# Require f2fs compression support on the scratch filesystem.
+# Optionally, check for support for a specific compression algorithm.
+_require_scratch_f2fs_compression()
+{
+	local algorithm=$1
+
+	_require_scratch
+
+	if [ ! -e /sys/fs/f2fs/features/compression ]; then
+		_notrun "Kernel doesn't support f2fs compression"
+	fi
+	# Note: '-O compression' is only accepted when used in
+	# combination with extra_attr.
+	if ! _scratch_mkfs -O compression,extra_attr >> $seqres.full; then
+		_notrun "f2fs-tools doesn't support compression"
+	fi
+	if [ -n "$algorithm" ]; then
+		if ! _scratch_mount "-o compress_algorithm=$algorithm"; then
+			_notrun "Kernel doesn't support $algorithm compression algorithm for f2fs"
+		fi
+		_scratch_unmount
+	fi
+}
-- 
2.28.0

