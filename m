Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50057C433FE
	for <linux-fscrypt@archiver.kernel.org>; Tue, 22 Nov 2022 07:06:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232241AbiKVHGl (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 22 Nov 2022 02:06:41 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59494 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229750AbiKVHGk (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 22 Nov 2022 02:06:40 -0500
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com [115.124.30.133])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5D5862A97E;
        Mon, 21 Nov 2022 23:06:38 -0800 (PST)
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R351e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=ay29a033018045176;MF=tianjia.zhang@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0VVR3ytI_1669100793;
Received: from localhost(mailfrom:tianjia.zhang@linux.alibaba.com fp:SMTPD_---0VVR3ytI_1669100793)
          by smtp.aliyun-inc.com;
          Tue, 22 Nov 2022 15:06:34 +0800
From:   Tianjia Zhang <tianjia.zhang@linux.alibaba.com>
To:     "Theodore Y. Ts o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Eric Biggers <ebiggers@kernel.org>,
        Jonathan Corbet <corbet@lwn.net>, Jens Axboe <axboe@kernel.dk>,
        Ard Biesheuvel <ardb@kernel.org>,
        linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-block@vger.kernel.org
Cc:     Tianjia Zhang <tianjia.zhang@linux.alibaba.com>
Subject: [PATCH v2 0/2] Add SM4 XTS symmetric algorithm for blk-crypto and fscrypt
Date:   Tue, 22 Nov 2022 15:06:30 +0800
Message-Id: <20221122070632.21910-1-tianjia.zhang@linux.alibaba.com>
X-Mailer: git-send-email 2.24.3 (Apple Git-128)
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

SM4 is widely used in China's data encryption software and hardware.
This serial of patches enables the SM4-XTS algorithm in blk-crypto and
enables the SM4-XTS/CTS algorithm in fscrypt to encrypt file content
and filename.

v2 change:
  - As Eric said, the new FSCRYPT_MODE is defined for the unused numbers 7 and 8

Tianjia Zhang (2):
  blk-crypto: Add support for SM4-XTS blk crypto mode
  fscrypt: Add SM4 XTS/CTS symmetric algorithm support

 Documentation/filesystems/fscrypt.rst |  1 +
 block/blk-crypto.c                    |  6 ++++++
 fs/crypto/keysetup.c                  | 15 +++++++++++++++
 fs/crypto/policy.c                    |  4 ++++
 include/linux/blk-crypto.h            |  1 +
 include/uapi/linux/fscrypt.h          |  2 ++
 6 files changed, 29 insertions(+)

-- 
2.24.3 (Apple Git-128)

