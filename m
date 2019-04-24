Return-Path: <SRS0=har8=S2=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH V1 00/14] Consolidate Post read processing code
Date: Wed, 24 Apr 2019 10:07:16 +0530
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190424043730.13683-1-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com
List-ID: <linux-fscrypt@vger.kernel.org>

This patchset moves the "post read processing" code into a file of its
own (i.e. fs/post_read_process.c) and modifies the generic
do_mpage_readpge() to make use of the functionality provided.

"Post read processing" implements code to track the state machine that
needs to be executed after reading data from files that are encrypted
and/or have verity metadata associated with them.

With these changes in place, the patchset changes Ext4 to use
mpage_readpage[s] instead of its own custom ext4_readpage[s]()
functions. This is done to reduce duplicity of code across
filesystems. Also, Post read processing source files will be built
only if one of CONFIG_FS_ENCRYPTION and CONFIG_FS_VERITY is enabled.

The patchset also modifies fs/buffer.c and fscrypt functionality to
get file encryption/decryption to work with subpage-sized blocks.

The following fixes from Eric Biggers are prerequisites for this
patchset,
  fscrypt: fix race where ->lookup() marks plaintext dentry as ciphertext
  fscrypt: only set dentry_operations on ciphertext dentries
  fscrypt: clear DCACHE_ENCRYPTED_NAME when unaliasing directory
  fscrypt: fix race allowing rename() and link() of ciphertext dentries
  fscrypt: clean up and improve dentry revalidation

The patches can also be obtained from,
"https://github.com/chandanr/linux.git subpage-encryption"

Changelog:
RFC V2 -> V1:
1. Test and verify FS_CFLG_OWN_PAGES subset of fscrypt_encrypt_page()
   code by executing fstests on UBIFS.
2. Implement F2fs function call back to check if the contents of a
   page holding a verity file's data needs to be verified.

RFC V1 -> RFC V2:
1. Describe the purpose of "Post processing code" in the cover letter.
2. Fix build errors when CONFIG_FS_VERITY is enabled.

Chandan Rajendra (14):
  ext4: Clear BH_Uptodate flag on decryption error
  Consolidate "post read processing" into a new file
  fsverity: Add call back to decide if verity check has to be performed
  fsverity: Add call back to determine readpage limit
  fs/mpage.c: Integrate post read processing
  ext4: Wire up ext4_readpage[s] to use mpage_readpage[s]
  Remove the term "bio" from post read processing
  Add decryption support for sub-pagesized blocks
  ext4: Decrypt all boundary blocks when doing buffered write
  ext4: Decrypt the block that needs to be partially zeroed
  fscrypt_encrypt_page: Loop across all blocks mapped by a page range
  ext4: Compute logical block and the page range to be encrypted
  fscrypt_zeroout_range: Encrypt all zeroed out blocks of a page
  ext4: Enable encryption for subpage-sized blocks

 Documentation/filesystems/fscrypt.rst |   4 +-
 fs/Makefile                           |   4 +
 fs/buffer.c                           |  83 +++--
 fs/crypto/bio.c                       | 111 ++++---
 fs/crypto/crypto.c                    |  73 +++--
 fs/crypto/fscrypt_private.h           |   3 +
 fs/ext4/Makefile                      |   2 +-
 fs/ext4/ext4.h                        |   2 -
 fs/ext4/inode.c                       |  47 ++-
 fs/ext4/page-io.c                     |   9 +-
 fs/ext4/readpage.c                    | 445 --------------------------
 fs/ext4/super.c                       |  39 ++-
 fs/f2fs/data.c                        | 148 ++-------
 fs/f2fs/super.c                       |  15 +-
 fs/mpage.c                            |  51 ++-
 fs/post_read_process.c                | 155 +++++++++
 fs/verity/verify.c                    |  12 +
 include/linux/buffer_head.h           |   1 +
 include/linux/fscrypt.h               |  20 +-
 include/linux/fsverity.h              |   2 +
 include/linux/post_read_process.h     |  22 ++
 21 files changed, 516 insertions(+), 732 deletions(-)
 delete mode 100644 fs/ext4/readpage.c
 create mode 100644 fs/post_read_process.c
 create mode 100644 include/linux/post_read_process.h

-- 
2.19.1
