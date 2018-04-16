Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:46605 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752934AbeDPTd1 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 16 Apr 2018 15:33:27 -0400
Received: by mail-pg0-f48.google.com with SMTP id t12so4286053pgp.13
        for <linux-fscrypt@vger.kernel.org>; Mon, 16 Apr 2018 12:33:26 -0700 (PDT)
From: Eric Biggers <ebiggers@google.com>
Subject: [PATCH 0/2] fscrypt / f2fs: prepare I/O path for fs-verity
Date: Mon, 16 Apr 2018 12:31:45 -0700
Message-Id: <20180416193147.104555-1-ebiggers@google.com>
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

Eric Biggers (2):
  fscrypt: allow synchronous bio decryption
  f2fs: refactor read path to allow multiple postprocessing steps

 fs/crypto/bio.c                 |  35 ++++---
 fs/crypto/crypto.c              |   8 +-
 fs/crypto/fscrypt_private.h     |   1 -
 fs/ext4/readpage.c              |   2 +-
 fs/f2fs/data.c                  | 163 ++++++++++++++++++++++++--------
 fs/f2fs/f2fs.h                  |  12 ++-
 fs/f2fs/file.c                  |   4 +-
 fs/f2fs/gc.c                    |   6 +-
 fs/f2fs/inline.c                |   2 +-
 fs/f2fs/super.c                 |   6 ++
 include/linux/fscrypt_notsupp.h |  13 ++-
 include/linux/fscrypt_supp.h    |   5 +-
 12 files changed, 188 insertions(+), 69 deletions(-)

-- 
2.17.0.484.g0c8726318c-goog

