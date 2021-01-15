Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C99F0C433DB
	for <linux-fscrypt@archiver.kernel.org>; Fri, 15 Jan 2021 18:25:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A4A6B23A59
	for <linux-fscrypt@archiver.kernel.org>; Fri, 15 Jan 2021 18:25:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387973AbhAOSZQ (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 15 Jan 2021 13:25:16 -0500
Received: from mail.kernel.org ([198.145.29.99]:46954 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387774AbhAOSZQ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 15 Jan 2021 13:25:16 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id 634A82313E;
        Fri, 15 Jan 2021 18:24:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1610735075;
        bh=JvwSrvlAR0FRVMmPnsm7OaEmCpo7wayISAk8qiI4LBU=;
        h=From:To:Cc:Subject:Date:From;
        b=Go8IrCO2QSStDmAWKolAVPcV3yRiWv+KRQST9tcks6dVPOiZXwNOTEE9NjzSxFd5G
         oJUmST3E8YS7T/lp3V+1Q3t6t7yL/dfkFHDV8mGeKAqnfQHR93hqIH8UM7MmL6gk8B
         CV2MiLas4mLbdJc/dPLcApu+L25YMI0La12iCe32RbX/Bd6dEn4fXPsWLuhb9tNIhU
         odYTbx8QYbBhrwe14kZ4+a9wo0LUZexRFOyUPKB5/Juasr5XIAnjQ8Qf5dm0Zo5SXc
         g8dQCZbnUhoDAZvWntn8HbxWPBo6O36o04tnfQYv3/ir5kBx3zlh5++ZbQZbT/KhZ3
         wH4r8FiHGLTTw==
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        Theodore Ts'o <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Victor Hsieh <victorhsieh@google.com>
Subject: [fsverity-utils RFC PATCH 0/2] Add dump_metadata subcommand
Date:   Fri, 15 Jan 2021 10:24:00 -0800
Message-Id: <20210115182402.35691-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.30.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Add new subcommand 'fsverity dump_metadata' which wraps the proposed
FS_IOC_READ_VERITY_METADATA ioctl
(https://lkml.kernel.org/linux-fscrypt/20210115181819.34732-1-ebiggers@kernel.org/T/#u).

This subcommand is useful for xfstests and for debugging.

Eric Biggers (2):
  Upgrade to latest fsverity_uapi.h
  programs/fsverity: Add dump_metadata subcommand

 Makefile                     |   1 +
 common/fsverity_uapi.h       |  14 +++
 programs/cmd_dump_metadata.c | 167 +++++++++++++++++++++++++++++++++++
 programs/fsverity.c          |   6 ++
 programs/fsverity.h          |   6 ++
 5 files changed, 194 insertions(+)
 create mode 100644 programs/cmd_dump_metadata.c

-- 
2.30.0

