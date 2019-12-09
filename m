Return-Path: <SRS0=4aov=Z7=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDE06C43603
	for <linux-fscrypt@archiver.kernel.org>; Mon,  9 Dec 2019 22:24:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B266A2077B
	for <linux-fscrypt@archiver.kernel.org>; Mon,  9 Dec 2019 22:24:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1575930260;
	bh=NFF6oeKHFTNzJKOukLVQn69hTShkEDvr4AVzVzeQaDU=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=pAYuyFCMuqcrARl88Q5HLLxzzqB2GgFvx77kVVHTEAEi1spIqnHPe3jUOc3lrbkXU
	 YU8D6a+EJvdHbPDAKOH9oAkomJpuI2Hs8PrzNIG8O9gmytm8+TJMf9+YrFR8U5LxOR
	 9AQ/2YBPvcQ8qfldmQDTrDvM25oIVmLrjIZ9fFZ8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727059AbfLIWYU (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 9 Dec 2019 17:24:20 -0500
Received: from mail.kernel.org ([198.145.29.99]:40904 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726522AbfLIWYU (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 9 Dec 2019 17:24:20 -0500
Received: from ebiggers-linuxstation.mtv.corp.google.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 7E02020637;
        Mon,  9 Dec 2019 22:24:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1575930259;
        bh=NFF6oeKHFTNzJKOukLVQn69hTShkEDvr4AVzVzeQaDU=;
        h=From:To:Cc:Subject:Date:From;
        b=Zox1hieAUcZrvzfyYghZIP0Z6K4YjW1mC+/7n6hFnQr9bvWvnGUI/3jVvDjuOrQ8g
         Hb48ODsQ23EzxSNrsmmJ3rpOWyhKN6N9qFPAlBBQq95tLDUNQUFRyg+3S6Xy8h1IYc
         5wswW23CKtooqMNUHX18kpdImxEMoAGUAUcmN9DM=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-mtd@lists.infradead.org, Richard Weinberger <richard@nod.at>
Cc:     linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 0/2] ubifs: fixes for FS_IOC_GETFLAGS and FS_IOC_SETFLAGS
Date:   Mon,  9 Dec 2019 14:23:23 -0800
Message-Id: <20191209222325.95656-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.24.0.393.g34dc348eaf-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On ubifs, fix FS_IOC_SETFLAGS to not clear the encrypt flag, and update
FS_IOC_GETFLAGS to return the encrypt flag like ext4 and f2fs do.

Eric Biggers (2):
  ubifs: fix FS_IOC_SETFLAGS unexpectedly clearing encrypt flag
  ubifs: add support for FS_ENCRYPT_FL

 fs/ubifs/ioctl.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

-- 
2.24.0.393.g34dc348eaf-goog

