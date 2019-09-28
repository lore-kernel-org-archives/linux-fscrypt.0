Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:49210 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726033AbfI1ADo (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 27 Sep 2019 20:03:44 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v3 0/9] xfsprogs: support fscrypt API additions in xfs_io
Date: Fri, 27 Sep 2019 17:02:34 -0700
Message-Id: <20190928000243.77634-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-xfs@vger.kernel.org
Cc: fstests@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hello,

This patchset updates xfs_io to support the new fscrypt ioctls that were
merged for 5.4 (https://git.kernel.org/torvalds/c/734d1ed83e1f9b7b).

New commands are added to wrap the new ioctls to manage filesystem
encryption keys: 'add_enckey', 'rm_enckey', and 'enckey_status'.  Also,
the existing 'get_encpolicy' and 'set_encpolicy' commands are updated to
support getting/setting v2 encryption policies.

The purpose of all this is to allow xfstests to test these new APIs.

Note: currently only ext4, f2fs, and ubifs support encryption.  But I
was told previously that since the fscrypt API is generic and may be
supported by XFS in the future, the command-line wrappers for the
fscrypt ioctls should be in xfs_io rather than in xfstests directly
(https://marc.info/?l=fstests&m=147976255831951&w=2).

This patchset applies to the latest "for-next" branch of xfsprogs
(commit ac8b6c380865).  It can also be retrieved from tag
"fscrypt-key-mgmt-improvements_2019-09-27" of
https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/xfsprogs-dev.git

Changes v2 => v3:
- Generate the encryption modes for 'help set_encpolicy'.
- Mention '-a' in all relevant places in the help for rm_enckey.
- Mark strings for translation.

No changes v1 => v2.

Eric Biggers (9):
  xfs_io/encrypt: remove unimplemented encryption modes
  xfs_io/encrypt: update to UAPI definitions from Linux v5.4
  xfs_io/encrypt: generate encryption modes for 'help set_encpolicy'
  xfs_io/encrypt: add new encryption modes
  xfs_io/encrypt: extend 'get_encpolicy' to support v2 policies
  xfs_io/encrypt: extend 'set_encpolicy' to support v2 policies
  xfs_io/encrypt: add 'add_enckey' command
  xfs_io/encrypt: add 'rm_enckey' command
  xfs_io/encrypt: add 'enckey_status' command

 io/encrypt.c      | 816 ++++++++++++++++++++++++++++++++++++++++------
 man/man8/xfs_io.8 |  70 +++-
 2 files changed, 771 insertions(+), 115 deletions(-)

-- 
2.23.0.444.g18eeb5a265-goog
