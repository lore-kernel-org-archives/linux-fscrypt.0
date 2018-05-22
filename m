Return-Path: <chandan@linux.vnet.ibm.com>
From: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Subject: [RFC PATCH V3 00/12] Ext4 encryption support for blocksize < pagesize
Date: Tue, 22 May 2018 21:30:58 +0530
Message-Id: <20180522160110.1161-1-chandan@linux.vnet.ibm.com>
To: linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.vnet.ibm.com>, ebiggers3@gmail.com, tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

This patchset implements code to support encryption of Ext4 filesystem
instances that have blocksize less than pagesize. Ext4 code with this
patchset has been tested on both ppc64 and x86_64 machines. F2FS and
UBIFS were tested on x86_64.

TODO:
1. generic/233 fails with bigalloc mkfs option. This will be fixed in
   the next version of the patchset.

Changelog:
"RFC V2" -> "RFC V3":
1. mpage_readpage[s]() now has arguments to function pointers which
   decrypt the data after the read I/O operation gets completed. Due
   to these changes the code in fs/ext4/readpage.c isn't required
   anymore. Hence this patchset deletes that file.
2. Revert fscrypt_{encrypt,decrypt}_block functions back to
   fscrypt_{encrypt,decrypt}_page i.e. These functions now accept a
   complete memory page as an argument. But internally these functions
   now iterate over all the blocks mapped by the page. Since there
   were no changes in prototypes of these fscrypt APIs, there were no
   changes made to either F2FS or UBIFS code.
3. Address all the review comments provided by Eric Biggers.

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
   
Chandan Rajendra (12):
  ext4: Clear BH_Uptodate flag on decryption error
  Rename fscrypt_do_page_crypto to fscrypt_do_block_crypto
  fscrypt_decrypt_page: Decrypt all blocks in a page
  __fscrypt_decrypt_bio: Fix page offset and len args to
    fscrypt_decrypt_page
  ext4: Decrypt all boundary blocks when doing buffered write
  ext4: Decrypt the block that needs to be partially zeroed
  mpage_readpage[s]: Introduce post process callback parameters
  fscrypt_zeroout_range: Encrypt all zeroed out blocks of a page
  fscrypt_encrypt_page: Encrypt all blocks mapped by a page
  ext4: Fix block number passed to fscrypt_encrypt_page
  ext4: Move encryption code into its own function
  ext4: Enable encryption for blocksize less than page size

 Documentation/filesystems/fscrypt.rst |  14 +-
 fs/block_dev.c                        |   5 +-
 fs/buffer.c                           | 298 ++++++++++++++++++++--------------
 fs/crypto/bio.c                       | 141 ++++++++++++++--
 fs/crypto/crypto.c                    |  44 +++--
 fs/crypto/fscrypt_private.h           |   2 +-
 fs/ext2/inode.c                       |   4 +-
 fs/ext4/Makefile                      |   2 +-
 fs/ext4/inode.c                       |  55 +++++--
 fs/ext4/page-io.c                     |  43 +++--
 fs/ext4/readpage.c                    | 294 ---------------------------------
 fs/ext4/super.c                       |   7 -
 fs/fat/inode.c                        |   4 +-
 fs/isofs/inode.c                      |   5 +-
 fs/mpage.c                            |  48 +++++-
 fs/xfs/xfs_aops.c                     |   4 +-
 include/linux/buffer_head.h           |   2 +-
 include/linux/fs.h                    |   4 +
 include/linux/fscrypt_notsupp.h       |  37 ++++-
 include/linux/fscrypt_supp.h          |  13 +-
 include/linux/mpage.h                 |   6 +-
 21 files changed, 522 insertions(+), 510 deletions(-)
 delete mode 100644 fs/ext4/readpage.c

-- 
2.9.5
