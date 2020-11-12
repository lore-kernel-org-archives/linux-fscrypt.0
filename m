Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PULL_REQUEST,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4E80C2D0E4
	for <linux-fscrypt@archiver.kernel.org>; Thu, 12 Nov 2020 23:16:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 69B0E216FD
	for <linux-fscrypt@archiver.kernel.org>; Thu, 12 Nov 2020 23:16:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="t7JqnwPq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726083AbgKLXQd (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 12 Nov 2020 18:16:33 -0500
Received: from mail.kernel.org ([198.145.29.99]:57576 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725929AbgKLXQd (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 12 Nov 2020 18:16:33 -0500
Received: from sol.localdomain (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 349C020B80;
        Thu, 12 Nov 2020 23:16:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1605222992;
        bh=5CBboKzeplTZn92nfZnKQYbgmTlfqZIgtii4GyCvwZc=;
        h=Date:From:To:Cc:Subject:From;
        b=t7JqnwPqchlO+5f9VjAw6RLfBHPrw0zW7UgTwGnOMuzsXDLy/93klQV8HPwI+fEkB
         jJxiPUcdw27MGZvGx/R23U/+OavrojB30phAEedYNPIeODkK30Zw67JkHSGuRiCRlo
         jqW61uJnn1R7e+c+MlwDJvIIr6orzAKFgr4I0lx0=
Date:   Thu, 12 Nov 2020 15:16:30 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Satya Tangirala <satyat@google.com>
Subject: [GIT PULL] another fscrypt fix for 5.10-rc4
Message-ID: <X63CTrVsH3WD+xcE@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org


The following changes since commit 92cfcd030e4b1de11a6b1edb0840e55c26332d31:

  fscrypt: remove reachable WARN in fscrypt_setup_iv_ino_lblk_32_key() (2020-11-06 09:48:55 -0800)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fscrypt-for-linus

for you to fetch changes up to d19d8d345eecd9247cbe6cbf27aef271bd88aba7:

  fscrypt: fix inline encryption not used on new files (2020-11-11 20:59:07 -0800)

----------------------------------------------------------------

Fix a regression where new files weren't using inline encryption when
they should be.

----------------------------------------------------------------
Eric Biggers (1):
      fscrypt: fix inline encryption not used on new files

 fs/crypto/inline_crypt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
