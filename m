Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 738FFEB64D7
	for <linux-fscrypt@archiver.kernel.org>; Thu, 29 Jun 2023 00:35:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231163AbjF2Afb (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 28 Jun 2023 20:35:31 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58566 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230113AbjF2AfU (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 28 Jun 2023 20:35:20 -0400
Received: from box.fidei.email (box.fidei.email [IPv6:2605:2700:0:2:a800:ff:feba:dc44])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6CA4B1FC2;
        Wed, 28 Jun 2023 17:35:19 -0700 (PDT)
Received: from authenticated-user (box.fidei.email [71.19.144.250])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
        (No client certificate requested)
        by box.fidei.email (Postfix) with ESMTPSA id 3B15880794;
        Wed, 28 Jun 2023 20:29:06 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=dorminy.me; s=mail;
        t=1687998546; bh=GzaYwd0AxJW0UW1DtZV1Eax0QEQMBhwbng6S7N1e4RE=;
        h=From:To:Cc:Subject:Date:From;
        b=L3BbLlKbYQyg76i6WPnpjGutXfK6W4QhvtFed9heC6y8pF4wqcaJLptsQU1PudEWM
         7Lzn51E3UIwK0FW05ZQ7Fn165fYhN08bipeWr+FOSp/JMw1Gr5iBWzVYMN+oS8QLd4
         KRb3i997ws34ff49b3NmbVezxW7hCmfkQ4Cdp74Jw53bct+QVpae2iyjyLYEzddtOE
         R/KVSB7VgjA5X5yVUwuE4MYsvrz9CAZM7EcASMC3MrSn+SfNjiCZLfpQ/z+rzFbFNU
         3v+SQ8B1XF2x1Kg2I9LgrcyzX+gWFPywMvah/yP8+eW571KfjtebHgc8f8buPdGYQv
         szaRja/4BwPBg==
From:   Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
To:     Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
        David Sterba <dsterba@suse.com>,
        Eric Biggers <ebiggers@kernel.org>,
        "Theodore Y. Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>, kernel-team@meta.com,
        linux-btrfs@vger.kernel.org, linux-fscrypt@vger.kernel.org
Cc:     Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: [PATCH v4 0/8] fscrypt: some rearrangements of key setup
Date:   Wed, 28 Jun 2023 20:28:50 -0400
Message-Id: <cover.1687988119.git.sweettea-kernel@dorminy.me>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

This is a patchset designed to make key setup slightly clearer to me
ahead of rearranging it to add extent-based encryption. It is basically
a subset of my prior changeset [1] for elegance. The subsequent changes
have minor dependencies on it; I can drop this changeset if it's
preferable, although I do think it makes everything cleaner.

Patchset is built on kdave/misc-next as per base commit and needs a tiny
fixup to apply to fscrypt/for-next. It passes ext4/f2fs tests for me.

[1] https://lore.kernel.org/linux-fscrypt/cover.1681837335.git.sweettea-kernel@dorminy.me/


Sweet Tea Dorminy (8):
  fscrypt: move inline crypt decision to info setup
  fscrypt: split and rename setup_file_encryption_key()
  fscrypt: split setup_per_mode_enc_key()
  fscrypt: move dirhash key setup away from IO key setup
  fscrypt: reduce special-casing of IV_INO_LBLK_32
  fscrypt: move all the shared mode key setup deeper
  fscrypt: make infos have a pointer to prepared keys
  fscrypt: make prepared keys record their type

 fs/crypto/crypto.c          |   2 +-
 fs/crypto/fname.c           |   4 +-
 fs/crypto/fscrypt_private.h |  33 +++-
 fs/crypto/inline_crypt.c    |   4 +-
 fs/crypto/keysetup.c        | 375 +++++++++++++++++++++++-------------
 fs/crypto/keysetup_v1.c     |   9 +-
 6 files changed, 274 insertions(+), 153 deletions(-)


base-commit: 00bc86ea26ac88043f48916c273afc9fbb40c73f
-- 
2.40.1

