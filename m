Return-Path: <chao@kernel.org>
Subject: Re: [f2fs-dev] [PATCH 00/25] fscrypt: add some higher-level helper
 functions
References: <20170920224605.22030-1-ebiggers3@gmail.com>
From: Chao Yu <chao@kernel.org>
Message-ID: <d7d91976-65b9-63d9-f34e-b322a9d0c472@kernel.org>
Date: Thu, 21 Sep 2017 22:19:49 +0800
MIME-Version: 1.0
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, Michael Halcrow <mhalcrow@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On 2017/9/21 6:45, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> This series reduces code duplication among ext4, f2fs, and ubifs by
> introducing a S_ENCRYPTED inode flag (so we don't have to call back into
> the filesystem to test the filesystem-specific inode flag), then
> introducing new helper functions that are called at the beginning of the
> open, link, rename, lookup, and setattr operations.
> 
> In the future we maybe should even call these new helpers from the VFS
> so that each individual filesystem doesn't have to do it.  But that's
> not possible currently because fs/crypto/ can be built as a module.
> 
> Making changes like this is a bit challenging due to interdependencies
> between fscrypt and the individual filesystems, all of which have
> different maintainers.  For now my intent is that patches 1-10 be taken
> through the fscrypt tree --- though it's not perfect since patches 1-4
> do make some changes to each filesystem, as everyone must set
> S_ENCRYPTED before we can use it everywhere in the shared code.  But
> afterwards, patches 11-25 can be picked up by the individual filesystems
> to switch to the new helpers.

For all patches touching f2fs, looks good to me, feel free to add:

Reviewed-by: Chao Yu <yuchao0@huawei.com>

> 
> Eric Biggers (25):
>   fs, fscrypt: add an S_ENCRYPTED inode flag
>   fscrypt: switch from ->is_encrypted() to IS_ENCRYPTED()
>   fscrypt: remove ->is_encrypted()
>   fscrypt: remove unneeded empty fscrypt_operations structs
>   fscrypt: new helper function - fscrypt_require_key()
>   fscrypt: new helper function - fscrypt_file_open()
>   fscrypt: new helper function - fscrypt_prepare_link()
>   fscrypt: new helper function - fscrypt_prepare_rename()
>   fscrypt: new helper function - fscrypt_prepare_lookup()
>   fscrypt: new helper function - fscrypt_prepare_setattr()
>   ext4: switch to fscrypt_file_open()
>   ext4: switch to fscrypt_prepare_link()
>   ext4: switch to fscrypt_prepare_rename()
>   ext4: switch to fscrypt_prepare_lookup()
>   ext4: switch to fscrypt_prepare_setattr()
>   f2fs: switch to fscrypt_file_open()
>   f2fs: switch to fscrypt_prepare_link()
>   f2fs: switch to fscrypt_prepare_rename()
>   f2fs: switch to fscrypt_prepare_lookup()
>   f2fs: switch to fscrypt_prepare_setattr()
>   ubifs: switch to fscrypt_file_open()
>   ubifs: switch to fscrypt_prepare_link()
>   ubifs: switch to fscrypt_prepare_rename()
>   ubifs: switch to fscrypt_prepare_lookup()
>   ubifs: switch to fscrypt_prepare_setattr()
> 
>  fs/crypto/Makefile              |   2 +-
>  fs/crypto/crypto.c              |   2 +-
>  fs/crypto/fname.c               |   3 +-
>  fs/crypto/hooks.c               | 112 +++++++++++++++++++++++++++++
>  fs/crypto/keyinfo.c             |   2 +-
>  fs/crypto/policy.c              |   6 +-
>  fs/ext4/file.c                  |  23 ++----
>  fs/ext4/inode.c                 |  19 +++--
>  fs/ext4/namei.c                 |  62 +++++-----------
>  fs/ext4/super.c                 |  15 ++--
>  fs/f2fs/f2fs.h                  |   1 +
>  fs/f2fs/file.c                  |  30 ++------
>  fs/f2fs/inode.c                 |   5 +-
>  fs/f2fs/namei.c                 |  54 ++++----------
>  fs/f2fs/super.c                 |   7 +-
>  fs/ubifs/crypto.c               |   1 -
>  fs/ubifs/dir.c                  |  43 ++++-------
>  fs/ubifs/file.c                 |  41 ++---------
>  fs/ubifs/ioctl.c                |   5 +-
>  fs/ubifs/super.c                |   8 +--
>  fs/ubifs/ubifs.h                |   9 +--
>  fs/ubifs/xattr.c                |   1 +
>  include/linux/fs.h              |   2 +
>  include/linux/fscrypt_common.h  |   1 -
>  include/linux/fscrypt_notsupp.h |  54 +++++++++++++-
>  include/linux/fscrypt_supp.h    | 153 ++++++++++++++++++++++++++++++++++++++++
>  26 files changed, 418 insertions(+), 243 deletions(-)
>  create mode 100644 fs/crypto/hooks.c
> 
