Return-Path: <SRS0=HejS=6Z=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1F6BC47255
	for <linux-fscrypt@archiver.kernel.org>; Mon, 11 May 2020 19:22:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 85C992098B
	for <linux-fscrypt@archiver.kernel.org>; Mon, 11 May 2020 19:22:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1589224941;
	bh=K94kZ3diPmckwEqrJ3ZSvaBTuE3MNfY2oXesZrNVmgQ=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=VmvMgiDqEqfVv/HvQhQOUodZRAp0uvf7Ywo1JXUlD3u/NNWyirb3FdQvVb57pLUMg
	 WmgELCDVkMaayVWbnhKPfrcuHM5XgDHyvcvoFKqOTzMIIzmMT2i3zEpzk6QL7Q6sFB
	 AIRb5s4z3GdjD67xq2vC2o9mw83mHgaSNOT7Bb8g=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731422AbgEKTWV (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 11 May 2020 15:22:21 -0400
Received: from mail.kernel.org ([198.145.29.99]:39740 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731435AbgEKTWU (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 11 May 2020 15:22:20 -0400
Received: from sol.hsd1.ca.comcast.net (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A6E9D20A8B;
        Mon, 11 May 2020 19:22:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1589224939;
        bh=K94kZ3diPmckwEqrJ3ZSvaBTuE3MNfY2oXesZrNVmgQ=;
        h=From:To:Cc:Subject:Date:From;
        b=yzw6SnUVTExM8HMczF7o9Tf8Pei1C/5E/pUrlKOxogcVi2V0vFyukBHDoTHxpsjth
         Y7YakELytlsVfNYinqo5R3sDQPBc/fLtc8tvvaQuOyEIRKPaztk1siqxorTITFbxQp
         tZgt8I0DLqIoWiUOb6XMxyNBc30jl23XhH+ZXaug=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Subject: [PATCH 0/2] fs-verity: misc cleanups
Date:   Mon, 11 May 2020 12:21:16 -0700
Message-Id: <20200511192118.71427-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.26.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

In fs/verity/ and fsverity.h, fix all kerneldoc warnings, and fix some
coding style inconsistencies in function declarations.

Eric Biggers (2):
  fs-verity: fix all kerneldoc warnings
  fs-verity: remove unnecessary extern keywords

 fs/verity/enable.c           |  2 ++
 fs/verity/fsverity_private.h |  4 ++--
 fs/verity/measure.c          |  2 ++
 fs/verity/open.c             |  1 +
 fs/verity/signature.c        |  3 +++
 fs/verity/verify.c           |  3 +++
 include/linux/fsverity.h     | 19 +++++++++++--------
 7 files changed, 24 insertions(+), 10 deletions(-)

-- 
2.26.2

