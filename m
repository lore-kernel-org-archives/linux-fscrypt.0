Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 0/6] fscrypt: key verification and KDF improvement
Date: Wed, 12 Jul 2017 14:00:29 -0700
Message-Id: <20170712210035.51534-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This patch series solves two major problems which filesystem-level
encryption has currently.  First, the user-supplied master keys are not
verified, which means a malicious user can provide the wrong key for
another user's file and cause a DOS attack or worse.  This flaw has been
criticized in the past [1].  Second, the KDF (Key Derivation Function)
used to derive per-file keys is ad-hoc and nonstandard.  While it meets
the primary security requirement, it's inflexible and is missing some
useful properties such as non-reversibility, which is important under
some threat models.  This weakness was noted by Unterluggauer and
Mangard (2016) [2] who also demonstrated an EM attack against the
current AES-based KDF.

These problems are solved together by introducing a new encryption
policy version where the KDF is changed to HKDF-SHA512, i.e. RFC-5869
[3] with SHA-512 as the underlying hash function.  HKDF is used to
derive the per-file keys as well as to generate a "key hash" which is
stored on-disk to allow key verification.  The HMAC transform for each
master key is pre-keyed and cached, which in practice makes the new KDF
about as fast or even faster than the old one which did not use the
crypto API efficiently.

Please give special consideration to the choice and usage of crypto
algorithms and any other on-disk format and API changes, since we will
be locked into these once merged.

All these changes are independent of filesystem and encryption mode,
i.e. the "v2" encryption policies can be used on any fscrypt-capable
filesystem (ext4, f2fs, or ubifs currently) and with any of the
supported encryption modes.

References:
  [1] https://blog.quarkslab.com/a-glimpse-of-ext4-filesystem-level-encryption.html

  [2] Unterluggauer and Mangard (2016).  "Exploiting the Physical
      Disparity: Side-Channel Attacks on Memory Encryption".
      https://eprint.iacr.org/2016/473.pdf

  [3] RFC 5869. "HMAC-based Extract-and-Expand Key Derivation Function
      (HKDF)".  https://tools.ietf.org/html/rfc5869

Eric Biggers (6):
  fscrypt: add v2 encryption context and policy
  fscrypt: rename ->ci_master_key to ->ci_master_key_descriptor
  fscrypt: use HKDF-SHA512 to derive the per-inode encryption keys
  fscrypt: verify that the correct master key was supplied
  fscrypt: cache the HMAC transform for each master key
  fscrypt: for v2 policies, support "fscrypt:" key prefix only

 fs/crypto/Kconfig              |   2 +
 fs/crypto/fscrypt_private.h    | 109 ++++++-
 fs/crypto/keyinfo.c            | 669 ++++++++++++++++++++++++++++++++++-------
 fs/crypto/policy.c             | 118 ++++++--
 fs/super.c                     |   4 +
 include/linux/fs.h             |   5 +
 include/linux/fscrypt_common.h |   2 +-
 include/uapi/linux/fs.h        |   6 +
 8 files changed, 766 insertions(+), 149 deletions(-)

-- 
2.13.2.932.g7449e964c-goog
