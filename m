Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 00/24] fscrypt: symlink helpers and fscrypt.h cleanup
Date: Fri, 15 Dec 2017 09:42:01 -0800
Message-Id: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers3@gmail.com>
List-ID: <linux-fscrypt@vger.kernel.org>

This series introduces helper functions in fscrypt that filesystems can
call to simplify handling of encrypted symlinks.  The helpers also fix a
couple subtle bugs, such as incorrectly rejecting symlinks that are very
close to the maximum length, and accidentally leaving the "." and ".."
symlink targets unencrypted (they need to be special in directory
entries, but not in symlink targets).

Patches 1-9 are mostly cleanup to trim down fscrypt.h, moving stuff into
more appropriate places depending on whether it is needed only
internally by fscrypt, or only by filesystems supporting encryption,
etc.  I was going to send these out as a separate series, but there is a
dependency because the symlink helpers depend on
fscrypt_dummy_context_enabled() having been fixed to work correctly in
the "notsupp" case.

Patch 10 introduces the helpers for ->symlink() and patch 11 introduces
a helper for ->get_link().

Patches 12-18 switch ext4, f2fs, and ubifs over to the symlink helpers,
and patches 19-24 clean things up in fscrypt as a consequence of all the
filesystems having been switched over to the symlink helpers.  Note that
as with the previous round of fscrypt helpers it may take an extra
development cycle to get the filesystem-specific patches in through the
filesystem-specific trees, so please consider patches 1-11 the ones that
may be applied right away, and the rest as the future plans.

Eric Biggers (24):
  fscrypt: move fscrypt_has_encryption_key() to supp/notsupp headers
  fscrypt: move fscrypt_control_page() to supp/notsupp headers
  fscrypt: move fscrypt_info_cachep declaration to fscrypt_private.h
  fscrypt: move fscrypt_ctx declaration to fscrypt_supp.h
  fscrypt: split fscrypt_dummy_context_enabled() into supp/notsupp
    versions
  fscrypt: move fscrypt_operations declaration to fscrypt_supp.h
  fscrypt: move fscrypt_valid_enc_modes() to fscrypt_private.h
  fscrypt: move fscrypt_is_dot_dotdot() to fs/crypto/fname.c
  fscrypt: trim down fscrypt.h includes
  fscrypt: new helper functions for ->symlink()
  fscrypt: new helper function - fscrypt_get_symlink()
  ext4: switch to fscrypt ->symlink() helper functions
  ext4: switch to fscrypt_get_symlink()
  f2fs: switch to fscrypt ->symlink() helper functions
  f2fs: switch to fscrypt_get_symlink()
  ubifs: free the encrypted symlink target
  ubifs: switch to fscrypt ->symlink() helper functions
  ubifs: switch to fscrypt_get_symlink()
  fscrypt: remove fscrypt_fname_usr_to_disk()
  fscrypt: move fscrypt_symlink_data to fscrypt_private.h
  fscrypt: calculate NUL-padding length in one place only
  fscrypt: define fscrypt_fname_alloc_buffer() to be for presented names
  fscrypt: fix up fscrypt_fname_encrypted_size() for internal use
  fscrypt: document symlink length restriction

 Documentation/filesystems/fscrypt.rst |  10 +-
 fs/crypto/crypto.c                    |   1 +
 fs/crypto/fname.c                     | 140 ++++++++++++---------------
 fs/crypto/fscrypt_private.h           |  31 ++++++
 fs/crypto/hooks.c                     | 154 ++++++++++++++++++++++++++++++
 fs/crypto/keyinfo.c                   |   1 +
 fs/ext4/namei.c                       |  58 +++---------
 fs/ext4/symlink.c                     |  43 ++-------
 fs/f2fs/namei.c                       | 132 +++++---------------------
 fs/ubifs/dir.c                        |  63 +++---------
 fs/ubifs/file.c                       |  36 +------
 include/linux/fscrypt.h               | 174 +++++++++++++---------------------
 include/linux/fscrypt_notsupp.h       |  56 +++++++----
 include/linux/fscrypt_supp.h          |  66 ++++++++++++-
 14 files changed, 488 insertions(+), 477 deletions(-)

-- 
2.15.1
