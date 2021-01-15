Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0163BC433E0
	for <linux-fscrypt@archiver.kernel.org>; Fri, 15 Jan 2021 18:31:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C249D23A9C
	for <linux-fscrypt@archiver.kernel.org>; Fri, 15 Jan 2021 18:31:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732212AbhAOSbA (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 15 Jan 2021 13:31:00 -0500
Received: from mail.kernel.org ([198.145.29.99]:49314 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728784AbhAOSbA (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 15 Jan 2021 13:31:00 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id 87D5923359;
        Fri, 15 Jan 2021 18:30:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1610735419;
        bh=gbwHQXXZKxRoHuz77f1Py7JkaZk+PrkkEL4SXZfN1k8=;
        h=From:To:Cc:Subject:Date:From;
        b=VrPYc/2WCxMzwABozjzRrG5k8JEnW1j2pOZmztZuqSio4PBIwXpGmH8Uq3rDXUK+8
         3V1wGv0S4+HAEGvjlJHq5k90//6jK3taGRi3allFMFHPYqmO2TnwgiIEq37upbkQAx
         ugLQ3flBdoxZvMVgtj0PNpxRl54HYBax+xEcNbpCDj7sYid5V96QZNt/3ZYn4Smziu
         b2Zh3lGcKal8fnrtljbUXYQ1PAkHfaKz9R+nse0u9470GGVCvSe+U1Nj+wIkWrYeEq
         zB0mYu7cPrhhCK+1FV6i2L5IuTeRRTcT0A9z4LmTiZkq45e3c64rziL4TwSKfvtxi4
         qKj5eeI4WTq8Q==
From:   Eric Biggers <ebiggers@kernel.org>
To:     fstests@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        Theodore Ts'o <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Victor Hsieh <victorhsieh@google.com>
Subject: [xfstests RFC PATCH 0/4] Test the FS_IOC_READ_VERITY_METADATA ioctl
Date:   Fri, 15 Jan 2021 10:28:33 -0800
Message-Id: <20210115182837.36333-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.30.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

This RFC patchset adds tests for the FS_IOC_READ_VERITY_METADATA ioctl
which I've proposed at
https://lkml.kernel.org/linux-fscrypt/20210115181819.34732-1-ebiggers@kernel.org/T/#u.

It relies on a new 'dump_metadata' subcommand for the 'fsverity' program
from fsverity-utils, which I've proposed at
https://lkml.kernel.org/linux-fscrypt/20210115182402.35691-1-ebiggers@kernel.org/T/#u.

The tests run on ext4 and f2fs (the filesystems that support fs-verity).

Eric Biggers (4):
  generic: factor out helpers for fs-verity built-in signatures
  generic: add helpers for dumping fs-verity metadata
  generic: test retrieving verity Merkle tree and descriptor
  generic: test retrieving verity signature

 common/verity         | 73 ++++++++++++++++++++++++++++++++++++++-
 tests/generic/577     | 15 ++------
 tests/generic/901     | 79 +++++++++++++++++++++++++++++++++++++++++++
 tests/generic/901.out | 16 +++++++++
 tests/generic/902     | 66 ++++++++++++++++++++++++++++++++++++
 tests/generic/902.out |  7 ++++
 tests/generic/group   |  2 ++
 7 files changed, 245 insertions(+), 13 deletions(-)
 create mode 100755 tests/generic/901
 create mode 100644 tests/generic/901.out
 create mode 100644 tests/generic/902
 create mode 100644 tests/generic/902.out

-- 
2.30.0

