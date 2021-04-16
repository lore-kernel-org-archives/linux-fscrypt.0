Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C661CC433ED
	for <linux-fscrypt@archiver.kernel.org>; Fri, 16 Apr 2021 16:06:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A331E610CE
	for <linux-fscrypt@archiver.kernel.org>; Fri, 16 Apr 2021 16:06:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236004AbhDPQHS (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 16 Apr 2021 12:07:18 -0400
Received: from mail.kernel.org ([198.145.29.99]:37386 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S239183AbhDPQHQ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 16 Apr 2021 12:07:16 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id D17BB610CE;
        Fri, 16 Apr 2021 16:06:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1618589211;
        bh=QhhTe94UVXIibH2YT5/uSfIRE2SEU5NWxlBL3mp1hV4=;
        h=From:To:Cc:Subject:Date:From;
        b=C3kkRIi49HfTy4AUZDL1kWyukCikVlY7+skcTGYcfGhTy7G+67MQMTvHw0QU2E2f2
         zb4xMg8rw4J4qy1aN/viJfnW6p75DFn9b1zGitVcCiCq8uVW4ORYj9dY3J8FUDeZnj
         fTjjdPFLYbX6goMwsO8WZMxRHwTI+Ewfi5AWQDfr1NlG0XRJr7DCy05qXfMZP9Pjx4
         KX8XbcqbGtBRf9yrgQ8fvCWzgpvLMopgk07nXpBI/an3Vfjyc8+3KcclZHonJkip/m
         rHaaE7WW+RAkcEOrGWs9+M01BQXcsnNkNpI55adglXA952F84/na7DUdEbUPSfXXgg
         Wy6qMtQ/dKHoQ==
From:   Ard Biesheuvel <ardb@kernel.org>
To:     linux-crypto@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org, Ard Biesheuvel <ardb@kernel.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 0/2] relax crypto Kconfig dependencies for fsverity/fscrypt
Date:   Fri, 16 Apr 2021 18:06:40 +0200
Message-Id: <20210416160642.85387-1-ardb@kernel.org>
X-Mailer: git-send-email 2.30.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Relax 'select' dependencies to 'imply' for crypto algorithms that are
fulfilled only at runtime, and which may be implemented by other drivers
than the generic ones implemented in C. This permits, e.g., arm64 builds
to omit the generic CRYPTO_SHA256 and CRYPTO_AES drivers, both of which
are superseded by optimized scalar versions at the very least,

Cc: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Eric Biggers <ebiggers@kernel.org>

Ard Biesheuvel (2):
  fscrypt: relax Kconfig dependencies for crypto API algorithms
  fsverity: relax build time dependency on CRYPTO_SHA256

 fs/crypto/Kconfig | 23 ++++++++++++++------
 fs/verity/Kconfig |  8 +++++--
 2 files changed, 22 insertions(+), 9 deletions(-)

-- 
2.30.2

