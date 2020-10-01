Return-Path: <SRS0=0etf=DI=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12E12C4363D
	for <linux-fscrypt@archiver.kernel.org>; Thu,  1 Oct 2020 00:25:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BF1D7206B2
	for <linux-fscrypt@archiver.kernel.org>; Thu,  1 Oct 2020 00:25:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1601511931;
	bh=0ZXQunnvSZDQ/e9Aytg6MPPYrB6sjkc8ANjRO0l0B4g=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=VViPMFnRpXcGL7Yyec8NVkvbhU+eFE4QYnjwlNTxbDIRO1BtrIfaA9IITnfDOiVXR
	 IyUBxZy7KrUhPOFt1K5rnuCxTeLw6w1q9lL9qZr1L9me4R+XP4sg7H2Xai4u5z3E2T
	 1YpxdxKwPtq1UjeKc5HH/8PWLNJZBjiwxuD8Sf0Q=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731940AbgJAAZb (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 30 Sep 2020 20:25:31 -0400
Received: from mail.kernel.org ([198.145.29.99]:54382 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730031AbgJAAZb (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 30 Sep 2020 20:25:31 -0400
Received: from sol.attlocal.net (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D37B7207C3;
        Thu,  1 Oct 2020 00:25:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1601511931;
        bh=0ZXQunnvSZDQ/e9Aytg6MPPYrB6sjkc8ANjRO0l0B4g=;
        h=From:To:Cc:Subject:Date:From;
        b=ssk904+Yq8tSueatsyQZWHUra5Qgs4eCILMidgS/OG8v6WQV5RwTqQTyOF/olOt+u
         ZsYeBsmujJ3CGM7eby3AtVa9ELEwbNP9sn74ye54P0SFMeQposLtwNawu5Nxb5tr3B
         GOOmgHpO/fGFgIsB2sq0vc3siwUnQO6cEvP0uTqw=
From:   Eric Biggers <ebiggers@kernel.org>
To:     fstests@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>,
        Daeho Jeong <daeho43@gmail.com>
Subject: [PATCH 0/5] xfstests: test f2fs compression+encryption
Date:   Wed, 30 Sep 2020 17:25:02 -0700
Message-Id: <20201001002508.328866-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.28.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Add a test which verifies that encryption is done correctly when a file
on f2fs uses both compression and encryption at the same time.

Patches 1-4 add prerequisites for the test, while patch 5 adds the
actual test.  Patch 2 also fixes a bug which could cause the existing
test generic/602 to fail in extremely rare cases.  See the commit
messages for details.

The new test passes both with and without the inlinecrypt mount option.
It requires CONFIG_F2FS_FS_COMPRESSION=y.

I'd appreciate the f2fs developers taking a look.

Note, there is a quirk where the IVs in compressed files are off by one
from the "natural" values.  It's still secure, though it made the test
slightly harder to write.  I'm not sure how intentional this quirk was.

Eric Biggers (5):
  fscrypt-crypt-util: clean up parsing --block-size and --inode-number
  fscrypt-crypt-util: fix IV incrementing for --iv-ino-lblk-32
  fscrypt-crypt-util: add --block-number option
  common/f2fs: add _require_scratch_f2fs_compression()
  f2fs: verify ciphertext of compressed+encrypted file

 common/config            |   1 +
 common/f2fs              |  27 +++++
 src/fscrypt-crypt-util.c |  98 ++++++++++++------
 tests/f2fs/002           | 217 +++++++++++++++++++++++++++++++++++++++
 tests/f2fs/002.out       |  21 ++++
 tests/f2fs/group         |   1 +
 6 files changed, 334 insertions(+), 31 deletions(-)
 create mode 100644 common/f2fs
 create mode 100755 tests/f2fs/002
 create mode 100644 tests/f2fs/002.out

-- 
2.28.0

