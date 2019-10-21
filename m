Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:36736 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730069AbfJUXHX (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 21 Oct 2019 19:07:23 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 0/3] fscrypt: support for inline-encryption-optimized policies
Date: Mon, 21 Oct 2019 16:03:52 -0700
Message-Id: <20191021230355.23136-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, Satya Tangirala <satyat@google.com>, Paul Crowley <paulcrowley@google.com>, Paul Lawrence <paullawrence@google.com>, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hello,

In preparation for adding inline encryption support to fscrypt, this
patchset adds a new fscrypt policy flag which modifies the encryption to
be optimized for inline encryption hardware compliant with the UFS
standard --- specifically, to use a smaller number of keys while still
using at most 64 IV bits.  This required adding the inode number to the
IVs.  For ext4, this precludes filesystem shrinking, so I've also added
a compat feature which will prevent the filesystem from being shrunk.

I've separated this from the full "Inline Encryption Support" patchset
(https://lkml.kernel.org/linux-fsdevel/20190821075714.65140-1-satyat@google.com/)
to avoid conflating an implementation (inline encryption) with a new
on-disk format (INLINE_CRYPT_OPTIMIZED).  This patchset purely adds
support for INLINE_CRYPT_OPTIMIZED policies to fscrypt, but implements
them using the existing filesystem layer crypto.

We're planning to make the *implementation* (filesystem layer or inline
crypto) be controlled by a mount option '-o inlinecrypt'.

This patchset applies to fscrypt.git#master and can also be retrieved from
https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/linux.git/log/?h=inline-crypt-optimized-v1

A ciphertext verification test for INLINE_CRYPT_OPTIMIZED policies can
be found at
https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/xfstests-dev.git/log/?h=inline-encryption

Work-in-progress patches for the inline encryption implementation of
both INLINE_CRYPT_OPTIMIZED and regular policies can be found at
https://git.kernel.org/pub/scm/linux/kernel/git/ebiggers/linux.git/log/?h=inline-encryption-wip

Eric Biggers (3):
  fscrypt: add support for inline-encryption-optimized policies
  ext4: add support for INLINE_CRYPT_OPTIMIZED encryption policies
  f2fs: add support for INLINE_CRYPT_OPTIMIZED encryption policies

 Documentation/filesystems/fscrypt.rst | 53 +++++++++++++++++++--------
 fs/crypto/crypto.c                    | 11 +++++-
 fs/crypto/fscrypt_private.h           | 20 +++++++---
 fs/crypto/keyring.c                   |  6 ++-
 fs/crypto/keysetup.c                  | 47 +++++++++++++++++++-----
 fs/crypto/policy.c                    | 42 ++++++++++++++++++++-
 fs/ext4/ext4.h                        |  2 +
 fs/ext4/super.c                       | 14 +++++++
 fs/f2fs/super.c                       | 26 ++++++++++---
 include/linux/fscrypt.h               |  3 ++
 include/uapi/linux/fscrypt.h          | 15 ++++----
 11 files changed, 191 insertions(+), 48 deletions(-)

-- 
2.23.0.866.gb869b98d4c-goog
