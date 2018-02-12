Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V2 00/11] Ext4 encryption support for blocksize < pagesize
Date: Mon, 12 Feb 2018 15:13:36 +0530
Message-Id: <20180212094347.22071-1-chandan@linux.vnet.ibm.com>
To: linux-ext4@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, linux-fsdevel@vger.kernel.org, ebiggers3@gmail.com, linux-fscrypt@vger.kernel.org, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

This patchset implements code to support encryption of Ext4 filesystem
instances that have blocksize less than pagesize. The patchset has
been tested on both ppc64 and x86_64 machines.

Eric, fscrypt_mpage_readpages() (originally, ext4_mpage_readpages())
still retains the ability to read non-encrypted file data. Please let
me know if the code has to be changed such that
fscrypt_mpage_readpages() makes it mandatory for the file's data to be
encrypted.

TODO:
F2FS and UBIFS code needs to be updated to make use of the newly added
fscrypt functions. I will do that in the next version of the patchset.

Changelog:
"RFC V1" -> "RFC V2":
1. Ext4's "encryption aware" functionality in fs/ext4/readpage.c has
   been moved to fs/crypto/.
2. fscrypt functions have now been renamed to indicate that they work
   on blocks rather than pages.
   Eric, I have renamed completion_pages() to fscrypt_complete_pages()
   rather than to fscrypt_complete_blocks(). This is because we have a
   new function fscrypt_complete_block() (which operates on a single
   block) and IMHO having the identifier fscrypt_complete_blocks()
   which differs from it by just one letter would confuse the reader.
3. ext4_block_write_begin() now clears BH_Uptodate flag when
   decryption of boundary blocks fail.
4. fscrypt_encrypt_page() (now renamed to fscrypt_encrypt_block()) is
   now split into two functions. fscrypt_prep_ciphertext_page()
   allocates and initializes the fscrypt context and the bounce
   page. fscrypt_encrypt_block() is limited to encrypting the
   filesystem's block.
5. fscrypt_zeroout_range() has been updated to work on blocksize <
   pagesize scenario.
6. Documentation/filesystems/fscrypt.rst has been updated to indicate
   encryption support for blocksize < pagesize.

Thanks to Eric Biggers for providing review comments for "RFC V1".

Chandan Rajendra (11):
  ext4: Clear BH_Uptodate flag on decryption error
  fs/buffer.c: Export end_buffer_async_read and create_page_buffers
  fs/crypto/: Rename functions to indicate that they operate on FS
    blocks
  completion_pages: Decrypt all contiguous blocks in a page
  ext4: Decrypt all boundary blocks when doing buffered write
  ext4: Decrypt the block that needs to be partially zeroed
  fscrypt_zeroout_range: Encrypt all zeroed out blocks of a page
  Enable reading encrypted files in blocksize less than pagesize setup
  fscrypt: Move completion_pages to crypto/readpage.c
  Enable writing encrypted files in blocksize less than pagesize setup
  ext4: Enable encryption for blocksize less than page size

 Documentation/filesystems/fscrypt.rst |  14 +-
 fs/buffer.c                           |   6 +-
 fs/crypto/Makefile                    |   2 +-
 fs/crypto/bio.c                       |  77 +++---
 fs/crypto/crypto.c                    |  91 +++---
 fs/crypto/fscrypt_private.h           |   5 +-
 fs/crypto/readpage.c                  | 506 ++++++++++++++++++++++++++++++++++
 fs/ext4/Makefile                      |   2 +-
 fs/ext4/ext4.h                        |   5 -
 fs/ext4/inode.c                       |  53 +++-
 fs/ext4/page-io.c                     |  34 ++-
 fs/ext4/readpage.c                    | 294 --------------------
 fs/ext4/super.c                       |   7 -
 include/linux/buffer_head.h           |   3 +
 include/linux/fscrypt.h               |   1 +
 include/linux/fscrypt_notsupp.h       |  23 +-
 include/linux/fscrypt_supp.h          |  20 +-
 17 files changed, 700 insertions(+), 443 deletions(-)
 create mode 100644 fs/crypto/readpage.c
 delete mode 100644 fs/ext4/readpage.c

-- 
2.9.5
