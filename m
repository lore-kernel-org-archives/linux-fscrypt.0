Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 00/14] fscrypt: improved logging and other cleanups
Date: Fri, 23 Mar 2018 12:23:44 -0700
Message-Id: <20180323192358.95691-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Hi, here's yet another round of cleanups for fscrypt.  Please consider
for v4.17.

Patches 1-11 remove some unnecessary or redundant code from a number of
different places; nothing particularly noteworthy.

Patch 12 switches the existing warning and error messages in fscrypt
over to use a common logging function, which is ratelimited and includes
the filesystem name (->s_id) when available as well as a consistent
prefix of "fscrypt:".

Patches 13-14 are optimizations and cleanups for key lookup and key
derivation.  They are extracted from the patch "fscrypt: refactor
finding and deriving key" I had originally sent as part of the series
"fscrypt: filesystem-level keyring and v2 policy support".  But I think
they're useful changes by themselves, so no need to wait on them.

This series can also be retrieved from git at
https://github.com/ebiggers/linux, branch "fscrypt_2018-03-23".  Note
that it's on top of a few other fscrypt patches I've sent out this
cycle:

    fscrypt: clean up after fscrypt_prepare_lookup() conversions
    fs, fscrypt: only define ->s_cop when FS_ENCRYPTION is enabled
    fscrypt: add Speck128/256 support

Eric Biggers (14):
  fscrypt: remove unnecessary NULL check when allocating skcipher
  fscrypt: remove error messages for skcipher_request_alloc() failure
  fscrypt: remove WARN_ON_ONCE() when decryption fails
  fscrypt: remove stale comment from fscrypt_d_revalidate()
  fscrypt: don't clear flags on crypto transform
  fscrypt: don't special-case EOPNOTSUPP from
    fscrypt_get_encryption_info()
  fscrypt: drop max_namelen check from fname_decrypt()
  fscrypt: drop empty name check from fname_decrypt()
  fscrypt: make fscrypt_operations.max_namelen an integer
  fscrypt: remove unnecessary check for non-logon key type
  fscrypt: remove internal key size constants
  fscrypt: use a common logging function
  fscrypt: separate key lookup from key derivation
  fscrypt: only derive the needed portion of the key

 fs/crypto/bio.c              |   6 +-
 fs/crypto/crypto.c           |  35 ++++--
 fs/crypto/fname.c            |  32 ++----
 fs/crypto/fscrypt_private.h  |  18 ++--
 fs/crypto/hooks.c            |   5 +-
 fs/crypto/keyinfo.c          | 202 ++++++++++++++++++-----------------
 fs/ext4/super.c              |   8 +-
 fs/f2fs/super.c              |   8 +-
 fs/ubifs/crypto.c            |  10 +-
 include/linux/fscrypt_supp.h |   2 +-
 10 files changed, 161 insertions(+), 165 deletions(-)

-- 
2.17.0.rc0.231.g781580f067-goog
