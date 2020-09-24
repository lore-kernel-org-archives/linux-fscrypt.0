Return-Path: <SRS0=1m1K=DB=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07A12C4346E
	for <linux-fscrypt@archiver.kernel.org>; Thu, 24 Sep 2020 04:29:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BAA9C2395A
	for <linux-fscrypt@archiver.kernel.org>; Thu, 24 Sep 2020 04:29:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600921741;
	bh=rO/bNcZHwLT9QTBkuyjZ4ahgv+SZFROlqsq/52bymt0=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=YIP4AxtK0rD1XTjlFm05rm8rlzXIbCpz2jpe9t6+FKSyEsLjF+YbZWjJ3xIfvxxw/
	 sC9HbJfEWILd84/8VzwJyV51QMSn8hLLUwJmNZrtRsQ7fii/2wWSb1ZzlcCZjfJtMg
	 it6NvLWPlHJRJNcFKOdxNVQeVsH92/971tOdqW5U=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726504AbgIXE3B (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 24 Sep 2020 00:29:01 -0400
Received: from mail.kernel.org ([198.145.29.99]:48564 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726466AbgIXE3B (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 24 Sep 2020 00:29:01 -0400
Received: from sol.attlocal.net (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id C260E20888;
        Thu, 24 Sep 2020 04:29:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600921741;
        bh=rO/bNcZHwLT9QTBkuyjZ4ahgv+SZFROlqsq/52bymt0=;
        h=From:To:Cc:Subject:Date:From;
        b=Rs5Fnpx1+kMOIPp6FrLcwizUYAmnr1trqn6z58T4WhfCNzSfjwSkIuvmrCLNNKuYV
         h83JFF9l8jBLk1oFYxyaFvH/LUHYjCSMon4nXUxTY7K8bQM01kFjKU3t49ioWLBDsM
         ZJzba7PzU5Ino48o+muguuzoP2FYvRDOSDaHNrdQ=
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        Daniel Rosenberg <drosen@google.com>,
        Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/2] fscrypt: avoid ambiguous terms for "no-key name"
Date:   Wed, 23 Sep 2020 21:26:22 -0700
Message-Id: <20200924042624.98439-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.28.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

This series fixes overloading of the terms "ciphertext name" and
"encrypted name" to also sometimes mean "no-key name".
The overloading of these terms has caused some confusion.

No change in behavior.

Eric Biggers (2):
  fscrypt: don't call no-key names "ciphertext names"
  fscrypt: rename DCACHE_ENCRYPTED_NAME to DCACHE_NOKEY_NAME

 fs/crypto/fname.c       | 16 ++++++++--------
 fs/crypto/hooks.c       | 13 ++++++-------
 fs/f2fs/dir.c           |  2 +-
 include/linux/dcache.h  |  2 +-
 include/linux/fscrypt.h | 25 ++++++++++++-------------
 5 files changed, 28 insertions(+), 30 deletions(-)

-- 
2.28.0

