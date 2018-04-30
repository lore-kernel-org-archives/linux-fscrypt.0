Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH v2 00/15] fscrypt: improved logging and other cleanups
Date: Mon, 30 Apr 2018 15:51:34 -0700
Message-Id: <20180430225149.183514-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Hello, here's yet another round of cleanups for fscrypt.  Please
consider for v4.18.  These are all patches I've sent out previously.
The series is based on v4.17-rc3.

Patches 1-12 mostly remove unnecessary or redundant code from a number
of different places; nothing particularly noteworthy.  Note: to avoid a
merge conflict with f2fs/dev, I've dropped the patch
"fscrypt: remove WARN_ON_ONCE() when decryption fails".

Patch 13 switches the existing warning and error messages in fscrypt
over to use a common logging function, which is ratelimited and includes
the filesystem name (->s_id) when available as well as a consistent
prefix of "fscrypt:".

Patches 14-15 are optimizations and cleanups for key lookup and key
derivation.  They are extracted from the patch "fscrypt: refactor
finding and deriving key" I had originally sent as part of the series
"fscrypt: filesystem-level keyring and v2 policy support".  But I think
they're useful changes by themselves, so no need to wait on them.

Eric Biggers (15):
  fs, fscrypt: only define ->s_cop when FS_ENCRYPTION is enabled
  fscrypt: clean up after fscrypt_prepare_lookup() conversions
  fscrypt: remove unnecessary NULL check when allocating skcipher
  fscrypt: remove error messages for skcipher_request_alloc() failure
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

 fs/crypto/crypto.c              |  36 ++++--
 fs/crypto/fname.c               |  32 ++---
 fs/crypto/fscrypt_private.h     |  19 +--
 fs/crypto/hooks.c               |   5 +-
 fs/crypto/keyinfo.c             | 200 +++++++++++++++++---------------
 fs/ext4/super.c                 |   8 +-
 fs/f2fs/super.c                 |   8 +-
 fs/ubifs/crypto.c               |  10 +-
 include/linux/fs.h              |   4 +-
 include/linux/fscrypt_notsupp.h |  10 --
 include/linux/fscrypt_supp.h    |  16 +--
 11 files changed, 161 insertions(+), 187 deletions(-)

-- 
2.17.0.441.gb46fe60e1d-goog
