Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:39548 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752166AbeFEWMv (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 5 Jun 2018 18:12:51 -0400
Date: Tue, 5 Jun 2018 18:12:49 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [GIT PULL] fscrypt updates for 4.18
Message-ID: <20180605221249.GA1368@thunk.org>
References: <20180605150751.GA9436@thunk.org>
 <CA+55aFxt4968GaU_q+e+D5KhGLGOjvHoZwRF0FKn_mHe4zx=Wg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxt4968GaU_q+e+D5KhGLGOjvHoZwRF0FKn_mHe4zx=Wg@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Jun 05, 2018 at 01:22:41PM -0700, Linus Torvalds wrote:
> 
> You have the tag *message* for fscrypt, but then the commit it points
> to has nothing to do with fscrypt.
> 
> I think you tagged the wrong branch.

Yeah, sorry.  I used git shortlog when I was examining the branch to
compose the tag message, and then I have a semi-automated script which
generates the pull request.  And I failed to check the arguments to
the script, as well as the output of the script.   :-(

Trying again, here you go.....

The following changes since commit 75bc37fefc4471e718ba8e651aa74673d4e0a9eb:

  Linux 4.17-rc4 (2018-05-06 16:57:38 -1000)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt_for_linus

for you to fetch changes up to e1cc40e5d42acb1d99652babb17e6a5ee4247409:

  fscrypt: log the crypto algorithm implementations (2018-05-20 16:36:00 -0400)

----------------------------------------------------------------
Add bunch of cleanups, and add support for the Speck128/256
algorithms.  Yes, Speck is contrversial, but the intention is to use
them only for the lowest end Android devices, where the alternative
*really* is no encryption at all for data stored at rest.

----------------------------------------------------------------
Eric Biggers (18):
      fscrypt: use unbound workqueue for decryption
      fs, fscrypt: only define ->s_cop when FS_ENCRYPTION is enabled
      fscrypt: clean up after fscrypt_prepare_lookup() conversions
      fscrypt: remove unnecessary NULL check when allocating skcipher
      fscrypt: remove error messages for skcipher_request_alloc() failure
      fscrypt: remove stale comment from fscrypt_d_revalidate()
      fscrypt: don't clear flags on crypto transform
      fscrypt: don't special-case EOPNOTSUPP from fscrypt_get_encryption_info()
      fscrypt: drop max_namelen check from fname_decrypt()
      fscrypt: drop empty name check from fname_decrypt()
      fscrypt: make fscrypt_operations.max_namelen an integer
      fscrypt: remove unnecessary check for non-logon key type
      fscrypt: remove internal key size constants
      fscrypt: use a common logging function
      fscrypt: separate key lookup from key derivation
      fscrypt: only derive the needed portion of the key
      fscrypt: add Speck128/256 support
      fscrypt: log the crypto algorithm implementations

 Documentation/filesystems/fscrypt.rst |  10 ++
 fs/crypto/crypto.c                    |  47 +++++--
 fs/crypto/fname.c                     |  32 ++---
 fs/crypto/fscrypt_private.h           |  23 ++--
 fs/crypto/hooks.c                     |   5 +-
 fs/crypto/keyinfo.c                   | 286 ++++++++++++++++++++++++-----------------
 fs/ext4/super.c                       |   8 +-
 fs/f2fs/super.c                       |   8 +-
 fs/ubifs/crypto.c                     |  10 +-
 include/linux/fs.h                    |   4 +-
 include/linux/fscrypt_notsupp.h       |  10 --
 include/linux/fscrypt_supp.h          |  16 +--
 include/uapi/linux/fs.h               |   2 +
 13 files changed, 248 insertions(+), 213 deletions(-)


