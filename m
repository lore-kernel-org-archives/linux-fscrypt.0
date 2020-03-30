Return-Path: <SRS0=TICy=5P=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PULL_REQUEST,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CA75C43331
	for <linux-fscrypt@archiver.kernel.org>; Mon, 30 Mar 2020 16:54:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0F6DC2073B
	for <linux-fscrypt@archiver.kernel.org>; Mon, 30 Mar 2020 16:54:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1585587242;
	bh=j/ppsQG0leh5vH+RTE+F7A3zvmhx3HDCWWopSVH2uDQ=;
	h=Date:From:To:Cc:Subject:List-ID:From;
	b=ElIa10C9vG1MagQrCeTz+W+Nok3GMPVuSvvMp0LDVgULbWZey6AM/t+1l+i65qeyO
	 DYe25cBTvnwiJqjxXIWM0eXgnLwSj6DDe1696Q36gXlSS7bTPV1pP41i8nCcGXkFWP
	 f/loTQxreAKDac+bgY6HJpeCCAOyP1mLbMogYMYw=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728075AbgC3QyB (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 30 Mar 2020 12:54:01 -0400
Received: from mail.kernel.org ([198.145.29.99]:37682 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727742AbgC3QyB (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 30 Mar 2020 12:54:01 -0400
Received: from sol.localdomain (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 7BEF82072E;
        Mon, 30 Mar 2020 16:54:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1585587240;
        bh=j/ppsQG0leh5vH+RTE+F7A3zvmhx3HDCWWopSVH2uDQ=;
        h=Date:From:To:Cc:Subject:From;
        b=M/wdnXbyHUTJv5ngtkxL30OP3/Kuj4H/2XLXZMGrhRmQHk4kBf8kUv4xIehJ2WNAi
         RYGO4xyaxQ0k6rkp1d/w6AkdnbU3iITZGeIBWDU4aBLtglq2LUaNtRCnK+4ktYJsaH
         Et7KNGgLmKcCwRBMlzckx0KzqoHRi1/YU5977jgo=
Date:   Mon, 30 Mar 2020 09:53:59 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>
Subject: [GIT PULL] fscrypt updates for 5.7
Message-ID: <20200330165359.GA1895@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

The following changes since commit 98d54f81e36ba3bf92172791eba5ca5bd813989b:

  Linux 5.6-rc4 (2020-03-01 16:38:46 -0600)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fscrypt-for-linus

for you to fetch changes up to 861261f2a9cc488c845fc214d9035f7a11094591:

  ubifs: wire up FS_IOC_GET_ENCRYPTION_NONCE (2020-03-19 21:57:06 -0700)

----------------------------------------------------------------

Add an ioctl FS_IOC_GET_ENCRYPTION_NONCE which retrieves a file's
encryption nonce.  This makes it easier to write automated tests which
verify that fscrypt is doing the encryption correctly.

----------------------------------------------------------------
Eric Biggers (4):
      fscrypt: add FS_IOC_GET_ENCRYPTION_NONCE ioctl
      ext4: wire up FS_IOC_GET_ENCRYPTION_NONCE
      f2fs: wire up FS_IOC_GET_ENCRYPTION_NONCE
      ubifs: wire up FS_IOC_GET_ENCRYPTION_NONCE

 Documentation/filesystems/fscrypt.rst | 11 +++++++++++
 fs/crypto/fscrypt_private.h           | 20 ++++++++++++++++++++
 fs/crypto/keysetup.c                  | 16 ++--------------
 fs/crypto/policy.c                    | 21 ++++++++++++++++++++-
 fs/ext4/ioctl.c                       |  6 ++++++
 fs/f2fs/file.c                        | 11 +++++++++++
 fs/ubifs/ioctl.c                      |  4 ++++
 include/linux/fscrypt.h               |  6 ++++++
 include/uapi/linux/fscrypt.h          |  1 +
 9 files changed, 81 insertions(+), 15 deletions(-)
