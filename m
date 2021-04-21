Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DA66C433B4
	for <linux-fscrypt@archiver.kernel.org>; Wed, 21 Apr 2021 07:55:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C5A3461430
	for <linux-fscrypt@archiver.kernel.org>; Wed, 21 Apr 2021 07:55:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237504AbhDUHz5 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 21 Apr 2021 03:55:57 -0400
Received: from mail.kernel.org ([198.145.29.99]:54736 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231463AbhDUHzu (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 21 Apr 2021 03:55:50 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 17E5F61430;
        Wed, 21 Apr 2021 07:55:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1618991717;
        bh=oodqUZZOMefgCXlr4EtGXlSqgSCFj8nnYrSus5BEwsI=;
        h=From:To:Cc:Subject:Date:From;
        b=X5d3T7gwaNuQppwUMzz1tGrE8WKdBdFEDWtCG7PICQA410/+6YKROGQNMQjorGd6e
         gc5G+FMv+oWjkC2EULl+VXekZb285kQcdn/2/jW5P2cknRCbg7GG9jZDXRYCWcjtmG
         1rlIyZxBsq/5xfMQSh3kWAsR5QwMDLRMoHqoheswUygD2whLwGI+mDfdUjXWxDNbIw
         nN2qOEJo5y/SAFtnVMxBVkE77vCDJ10w/5sYGpc7zXX1d/IVj3GwBcF8Ksj+xlLRtH
         aoDMRIFfJc3pyNPrQOsQ+4pptcLWJWst91whdgeZaqT0jlnwgCoM3CXsxaZ+UOCbNA
         s/i58dReb2EkQ==
From:   Ard Biesheuvel <ardb@kernel.org>
To:     linux-crypto@vger.kernel.org
Cc:     linux-fscrypt@vger.kernel.org, Ard Biesheuvel <ardb@kernel.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v2 0/2] relax crypto Kconfig dependencies for fsverity/fscrypt
Date:   Wed, 21 Apr 2021 09:55:09 +0200
Message-Id: <20210421075511.45321-1-ardb@kernel.org>
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

Changes since v1:
- use Eric's suggested comment text in patch #1
- add Eric's ack to partch #2

Cc: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Eric Biggers <ebiggers@kernel.org>

Ard Biesheuvel (2):
  fscrypt: relax Kconfig dependencies for crypto API algorithms
  fsverity: relax build time dependency on CRYPTO_SHA256

 fs/crypto/Kconfig | 30 ++++++++++++++------
 fs/verity/Kconfig |  8 ++++--
 2 files changed, 28 insertions(+), 10 deletions(-)

-- 
2.30.2

