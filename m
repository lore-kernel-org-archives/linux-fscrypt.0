Return-Path: <SRS0=I4Qa=WM=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: [PATCH V4 0/8] Consolidate FS read I/O callbacks code
Date: Fri, 16 Aug 2019 11:47:56 +0530
Message-Id: <20190816061804.14840-1-chandan@linux.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
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
functions. This is done to reduce duplication of code across
filesystems. Also, "FS read I/O callbacks" source files will be built
only if CONFIG_FS_ENCRYPTION is enabled.

The patchset also modifies fs/buffer.c to get file
encryption/decryption to work with subpage-sized blocks.

The patches can also be obtained from
https://github.com/chandanr/linux.git at branch subpage-encryption-v4.

Changelog:
V3 -> V4:
   1. A new buffer_head flag (i.e. BH_Read_Cb) is introduced to reliably
      check if a buffer head's content has to be decrypted.
   2. Fix layering violation. Now the code flow for decryption happens as shown below,
      FS => read callbacks => fscrypt
   3. Select FS_READ_CALLBACKS from FS specific kconfig file if FS_ENCRYPTION
      is enabled.
   4. Make 'struct read_callbacks_ctx' an opaque structure.
   5. Make use of FS' endio function rather than implementing one in read
      callbacks.
   6. Make read_callbacks.h self-contained.
   7. Split patchset to separate out ext4 and f2fs changes.
   
V2 -> V3:
1. Split the V2 patch "Consolidate 'read callbacks' into a new file" into
   three patches,
   - Introduce the read_callbacks functionality.
   - Convert encryption to use read_callbacks.
   - Remove union from struct fscrypt_context.
2. fs/Kconfig
   Do not explicitly set the default value of 'n' for FS_READ_CALLBACKS.
3. fs/crypto/Kconfig
   Select CONFIG_FS_READ_CALLBACKS only if CONFIG_BLOCK is selected.
4. Remove verity associated code in read_callbacks code.
5. Introduce a callback argument to read_callbacks_setup() function
   which gets invoked for each page for bio. F2FS uses this to perform
   custom operations like decrementing the value of f2fs_sb_info->nr_pages[].
6. Encapsulate the details of "read callbacks" (e.g. Usage of "struct
   read_callbacks *ctx") within its own functions. When CONFIG_FS_READ_CALLBACKS
   is set to 'n', the corresponding stub functions return approriate error
   values.
7. Split fscrypt_decrypt() function into fscrypt_decrypt_bio() and
   fscrypt_decrypt_bh().
8. Split end_read_callbacks() function into end_read_callbacks_bio() and
   end_read_callbacks_bh().

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

Chandan Rajendra (8):
  buffer_head: Introduce BH_Read_Cb flag
  FS: Introduce read callbacks
  fs/mpage.c: Integrate read callbacks
  fs/buffer.c: add decryption support via read_callbacks
  f2fs: Use read_callbacks for decrypting file data
  ext4: Wire up ext4_readpage[s] to use mpage_readpage[s]
  ext4: Enable encryption for subpage-sized blocks
  fscrypt: remove struct fscrypt_ctx

 Documentation/filesystems/fscrypt.rst |   4 +-
 fs/Kconfig                            |   3 +
 fs/Makefile                           |   1 +
 fs/buffer.c                           |  33 ++-
 fs/crypto/bio.c                       |  43 ----
 fs/crypto/crypto.c                    |  89 +-------
 fs/crypto/fscrypt_private.h           |   3 -
 fs/ext4/Kconfig                       |   1 +
 fs/ext4/Makefile                      |   2 +-
 fs/ext4/inode.c                       |   5 +-
 fs/ext4/readpage.c                    | 295 --------------------------
 fs/ext4/super.c                       |   7 -
 fs/f2fs/Kconfig                       |   1 +
 fs/f2fs/data.c                        | 109 +---------
 fs/f2fs/f2fs.h                        |   2 -
 fs/f2fs/super.c                       |   9 +-
 fs/mpage.c                            |  24 ++-
 fs/read_callbacks.c                   | 285 +++++++++++++++++++++++++
 include/linux/buffer_head.h           |   2 +
 include/linux/fscrypt.h               |  38 ----
 include/linux/read_callbacks.h        |  48 +++++
 21 files changed, 402 insertions(+), 602 deletions(-)
 delete mode 100644 fs/ext4/readpage.c
 create mode 100644 fs/read_callbacks.c
 create mode 100644 include/linux/read_callbacks.h

-- 
2.19.1
