Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:40512 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726338AbeLKWsI (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 11 Dec 2018 17:48:08 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 0/2] fs-verity: fix !CONFIG_FS_VERITY case
Date: Tue, 11 Dec 2018 14:46:49 -0800
Message-Id: <20181211224651.112510-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, Krzysztof Kozlowski <krzk@kernel.org>, linux-ext4@vger.kernel.org, Tony Lindgren <tony@atomide.com>, Kirill Tkhai <ktkhai@virtuozzo.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Replace the two patches that broken the !CONFIG_FS_VERITY case with
fixed verisons.

Chandan Rajendra (2):
  fsverity: Move verity status check to fsverity_file_open
  fsverity: Move verity status check to fsverity_prepare_setattr

 fs/ext4/file.c           |  8 +++----
 fs/ext4/inode.c          |  8 +++----
 fs/f2fs/file.c           | 16 +++++--------
 fs/verity/setup.c        | 32 ++++---------------------
 include/linux/fsverity.h | 50 ++++++++++++++++++++++++++++++++++++----
 5 files changed, 61 insertions(+), 53 deletions(-)

-- 
2.20.0.405.gbc1bbc6f85-goog
