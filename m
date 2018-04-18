Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pl0-f49.google.com ([209.85.160.49]:42532 "EHLO
        mail-pl0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752658AbeDRSMw (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 18 Apr 2018 14:12:52 -0400
Received: by mail-pl0-f49.google.com with SMTP id t20-v6so1588515ply.9
        for <linux-fscrypt@vger.kernel.org>; Wed, 18 Apr 2018 11:12:52 -0700 (PDT)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH v2 0/2] fscrypt / f2fs: prepare I/O path for fs-verity
Date: Wed, 18 Apr 2018 11:09:46 -0700
Message-Id: <20180418180948.152031-1-ebiggers@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-f2fs-devel@lists.sourceforge.net, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hello,

These two patches restructure f2fs's read path to allow the data to go
through multiple postprocessing steps, rather than just decryption as is
implemented currently.  This is mainly in preparation for doing
authenticity verification of data via fs-verity, though this change
might also be useful for other future f2fs features, e.g. compression.

These patches don't yet add the fs-verity work, however, as it depends
on the rest of the fs-verity patchset.  I'm planning to send the full
patchset out as an RFC, but some parts need further investigation first.
(The work-in-progress version can be found at
 git://git.kernel.org/pub/scm/linux/kernel/git/mhalcrow/linux.git,
 branch "fs-verity-dev".)

Changed since v1:
	
	- Define NUM_PREALLOC_POST_READ_CTXS

Eric Biggers (2):
  fscrypt: allow synchronous bio decryption
  f2fs: refactor read path to allow multiple postprocessing steps

 fs/crypto/bio.c                 |  35 ++++---
 fs/crypto/crypto.c              |   8 +-
 fs/crypto/fscrypt_private.h     |   1 -
 fs/ext4/readpage.c              |   2 +-
 fs/f2fs/data.c                  | 166 ++++++++++++++++++++++++--------
 fs/f2fs/f2fs.h                  |  12 ++-
 fs/f2fs/file.c                  |   4 +-
 fs/f2fs/gc.c                    |   6 +-
 fs/f2fs/inline.c                |   2 +-
 fs/f2fs/super.c                 |   6 ++
 include/linux/fscrypt_notsupp.h |  13 ++-
 include/linux/fscrypt_supp.h    |   5 +-
 12 files changed, 191 insertions(+), 69 deletions(-)

-- 
2.17.0.484.g0c8726318c-goog

