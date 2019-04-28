Return-Path: <SRS0=8usa=S6=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH V2 00/13] Consolidate FS read I/O callbacks code
Date: Sun, 28 Apr 2019 10:01:08 +0530
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <20190428043121.30925-1-chandan@linux.ibm.com>
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org
Cc: Chandan Rajendra <chandan@linux.ibm.com>, tytso@mit.edu, adilger.kernel@dilger.ca, ebiggers@kernel.org, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

This patchset moves the "FS read I/O callbacks" code into a file of its
own (i.e. fs/read_callbacks.c) and modifies the generic
do_mpage_readpge() to make use of the functionality provided.

"FS read I/O callbacks" code implements the state machine that needs
to be executed after reading data from files that are encrypted and/or
have verity metadata associated with them.

With these changes in place, the patchset changes Ext4 to use
mpage_readpage[s] instead of its own custom ext4_readpage[s]()
functions. This is done to reduce duplicity of code across
filesystems. Also, "FS read I/O callbacks" source files will be built
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
"https://github.com/chandanr/linux.git subpage-encryption-v2"

Changelog:
V1 -> V2:
1. Removed the phrase "post_read_process" from file names and
   functions. Instead we now use the phrase "read_callbacks" in its
   place.
2. When performing changes associated with (1), the changes made by
   the patch "Remove the term 'bio' from post read processing" are
   made in the earlier patch "Consolidate 'read callbacks' into a new
   file". Hence the patch "Remove the term 'bio' from post read
   processing" is removed from the patchset.

RFC V2 -> V1:
1. Test and verify FS_CFLG_OWN_PAGES subset of fscrypt_encrypt_page()
   code by executing fstests on UBIFS.
2. Implement F2fs function call back to check if the contents of a
   page holding a verity file's data needs to be verified.

RFC V1 -> RFC V2:
1. Describe the purpose of "Post processing code" in the cover letter.
2. Fix build errors when CONFIG_FS_VERITY is enabled.

Chandan Rajendra (13):
  ext4: Clear BH_Uptodate flag on decryption error
  Consolidate "read callbacks" into a new file
  fsverity: Add call back to decide if verity check has to be performed
  fsverity: Add call back to determine readpage limit
  fs/mpage.c: Integrate read callbacks
  ext4: Wire up ext4_readpage[s] to use mpage_readpage[s]
  Add decryption support for sub-pagesized blocks
  ext4: Decrypt all boundary blocks when doing buffered write
  ext4: Decrypt the block that needs to be partially zeroed
  fscrypt_encrypt_page: Loop across all blocks mapped by a page range
  ext4: Compute logical block and the page range to be encrypted
  fscrypt_zeroout_range: Encrypt all zeroed out blocks of a page
  ext4: Enable encryption for subpage-sized blocks

 Documentation/filesystems/fscrypt.rst |   4 +-
 fs/Kconfig                            |   4 +
 fs/Makefile                           |   4 +
 fs/buffer.c                           |  83 +++--
 fs/crypto/Kconfig                     |   1 +
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
 fs/read_callbacks.c                   | 155 +++++++++
 fs/verity/Kconfig                     |   1 +
 fs/verity/verify.c                    |  12 +
 include/linux/buffer_head.h           |   1 +
 include/linux/fscrypt.h               |  20 +-
 include/linux/fsverity.h              |   2 +
 include/linux/read_callbacks.h        |  22 ++
 24 files changed, 522 insertions(+), 732 deletions(-)
 delete mode 100644 fs/ext4/readpage.c
 create mode 100644 fs/read_callbacks.c
 create mode 100644 include/linux/read_callbacks.h

-- 
2.19.1
