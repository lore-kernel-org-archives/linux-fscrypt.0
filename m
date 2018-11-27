Date: Mon, 26 Nov 2018 16:45:30 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 7/7] fsverity: Remove filesystem specific build config
 option
Message-ID: <20181127004530.GF11663@gmail.com>
References: <20181119052324.31456-1-chandan@linux.vnet.ibm.com>
 <20181119052324.31456-8-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119052324.31456-8-chandan@linux.vnet.ibm.com>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chandan,

On Mon, Nov 19, 2018 at 10:53:24AM +0530, Chandan Rajendra wrote:
> In order to have a common code base for fsverity "post read" processing
> for all filesystems which support per-file verity, this commit removes
> filesystem specific build config option (e.g. CONFIG_EXT4_FS_VERITY) and
> replaces it with a build option (i.e. CONFIG_FS_VERITY) whose value
> affects all the filesystems making use of fsverity.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>

Like the corresponding fscrypt patch, this is missing changing

#if IS_ENABLED(CONFIG_FS_VERITY)

in include/linux/fs.h to

#ifdef CONFIG_FS_VERITY

There are also references to the filesystem-specific config options in
Documentation/filesystems/fsverity.rst that need to be updated.

I also suggest updating the Kconfig help text for CONFIG_FS_VERITY and
CONFIG_FS_ENCRYPTION to mention the supported filesystems, similar to how
CONFIG_QUOTA lists the filesystems it supports.

Thanks!

- Eric

> ---
>  fs/ext4/Kconfig          | 20 --------------------
>  fs/ext4/ext4.h           |  2 --
>  fs/ext4/readpage.c       |  4 ++--
>  fs/ext4/super.c          |  6 +++---
>  fs/ext4/sysfs.c          |  4 ++--
>  fs/f2fs/Kconfig          | 20 --------------------
>  fs/f2fs/data.c           |  2 +-
>  fs/f2fs/f2fs.h           |  2 --
>  fs/f2fs/super.c          |  6 +++---
>  fs/f2fs/sysfs.c          |  4 ++--
>  fs/verity/Kconfig        |  2 +-
>  include/linux/fsverity.h |  3 +--
>  12 files changed, 15 insertions(+), 60 deletions(-)
> 
> diff --git a/fs/ext4/Kconfig b/fs/ext4/Kconfig
> index e1002bbf35bf..031e5a82d556 100644
> --- a/fs/ext4/Kconfig
> +++ b/fs/ext4/Kconfig
> @@ -96,26 +96,6 @@ config EXT4_FS_SECURITY
>  	  If you are not using a security module that requires using
>  	  extended attributes for file security labels, say N.
>  
> -config EXT4_FS_VERITY
> -	bool "Ext4 Verity"
> -	depends on EXT4_FS
> -	select FS_VERITY
> -	help
> -	  This option enables fs-verity for ext4.  fs-verity is the
> -	  dm-verity mechanism implemented at the file level.  Userspace
> -	  can append a Merkle tree (hash tree) to a file, then enable
> -	  fs-verity on the file.  ext4 will then transparently verify
> -	  any data read from the file against the Merkle tree.  The file
> -	  is also made read-only.
> -
> -	  This serves as an integrity check, but the availability of the
> -	  Merkle tree root hash also allows efficiently supporting
> -	  various use cases where normally the whole file would need to
> -	  be hashed at once, such as auditing and authenticity
> -	  verification (appraisal).
> -
> -	  If unsure, say N.
> -
>  config EXT4_DEBUG
>  	bool "EXT4 debugging support"
>  	depends on EXT4_FS
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index 64bf9fb7ef18..bff8d639dd0c 100644
> --- a/fs/ext4/ext4.h
> +++ b/fs/ext4/ext4.h
> @@ -41,8 +41,6 @@
>  #endif
>  
>  #include <linux/fscrypt.h>
> -
> -#define __FS_HAS_VERITY IS_ENABLED(CONFIG_EXT4_FS_VERITY)
>  #include <linux/fsverity.h>
>  
>  #include <linux/compiler.h>
> diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
> index 2c037df629dd..8717ac0a5bb2 100644
> --- a/fs/ext4/readpage.c
> +++ b/fs/ext4/readpage.c
> @@ -158,7 +158,7 @@ static struct bio_post_read_ctx *get_bio_post_read_ctx(struct inode *inode,
>  
>  	if (IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode))
>  		post_read_steps |= 1 << STEP_DECRYPT;
> -#ifdef CONFIG_EXT4_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  	if (inode->i_verity_info != NULL &&
>  	    (index < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT)))
>  		post_read_steps |= 1 << STEP_VERITY;
> @@ -205,7 +205,7 @@ static void mpage_end_io(struct bio *bio)
>  
>  static inline loff_t ext4_readpage_limit(struct inode *inode)
>  {
> -#ifdef CONFIG_EXT4_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  	if (IS_VERITY(inode)) {
>  		if (inode->i_verity_info)
>  			/* limit to end of metadata region */
> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
> index 16fb483a6f4a..472338c7cd03 100644
> --- a/fs/ext4/super.c
> +++ b/fs/ext4/super.c
> @@ -1316,7 +1316,7 @@ static const struct fscrypt_operations ext4_cryptops = {
>  };
>  #endif
>  
> -#ifdef CONFIG_EXT4_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  static int ext4_set_verity(struct inode *inode, loff_t data_i_size)
>  {
>  	int err;
> @@ -1401,7 +1401,7 @@ static const struct fsverity_operations ext4_verityops = {
>  	.set_verity		= ext4_set_verity,
>  	.get_metadata_end	= ext4_get_metadata_end,
>  };
> -#endif /* CONFIG_EXT4_FS_VERITY */
> +#endif /* CONFIG_FS_VERITY */
>  
>  #ifdef CONFIG_QUOTA
>  static const char * const quotatypes[] = INITQFNAMES;
> @@ -4234,7 +4234,7 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
>  #ifdef CONFIG_FS_ENCRYPTION
>  	sb->s_cop = &ext4_cryptops;
>  #endif
> -#ifdef CONFIG_EXT4_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  	sb->s_vop = &ext4_verityops;
>  #endif
>  #ifdef CONFIG_QUOTA
> diff --git a/fs/ext4/sysfs.c b/fs/ext4/sysfs.c
> index 8bc915452a38..6fa0f47c3180 100644
> --- a/fs/ext4/sysfs.c
> +++ b/fs/ext4/sysfs.c
> @@ -227,7 +227,7 @@ EXT4_ATTR_FEATURE(meta_bg_resize);
>  #ifdef CONFIG_FS_ENCRYPTION
>  EXT4_ATTR_FEATURE(encryption);
>  #endif
> -#ifdef CONFIG_EXT4_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  EXT4_ATTR_FEATURE(verity);
>  #endif
>  EXT4_ATTR_FEATURE(metadata_csum_seed);
> @@ -239,7 +239,7 @@ static struct attribute *ext4_feat_attrs[] = {
>  #ifdef CONFIG_FS_ENCRYPTION
>  	ATTR_LIST(encryption),
>  #endif
> -#ifdef CONFIG_EXT4_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  	ATTR_LIST(verity),
>  #endif
>  	ATTR_LIST(metadata_csum_seed),
> diff --git a/fs/f2fs/Kconfig b/fs/f2fs/Kconfig
> index ce60e480fec1..708e23816575 100644
> --- a/fs/f2fs/Kconfig
> +++ b/fs/f2fs/Kconfig
> @@ -70,26 +70,6 @@ config F2FS_CHECK_FS
>  
>  	  If you want to improve the performance, say N.
>  
> -config F2FS_FS_VERITY
> -	bool "F2FS Verity"
> -	depends on F2FS_FS
> -	select FS_VERITY
> -	help
> -	  This option enables fs-verity for f2fs.  fs-verity is the
> -	  dm-verity mechanism implemented at the file level.  Userspace
> -	  can append a Merkle tree (hash tree) to a file, then enable
> -	  fs-verity on the file.  f2fs will then transparently verify
> -	  any data read from the file against the Merkle tree.  The file
> -	  is also made read-only.
> -
> -	  This serves as an integrity check, but the availability of the
> -	  Merkle tree root hash also allows efficiently supporting
> -	  various use cases where normally the whole file would need to
> -	  be hashed at once, such as auditing and authenticity
> -	  verification (appraisal).
> -
> -	  If unsure, say N.
> -
>  config F2FS_IO_TRACE
>  	bool "F2FS IO tracer"
>  	depends on F2FS_FS
> diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
> index 844ec573263e..83b59b985894 100644
> --- a/fs/f2fs/data.c
> +++ b/fs/f2fs/data.c
> @@ -610,7 +610,7 @@ static struct bio *f2fs_grab_read_bio(struct inode *inode, block_t blkaddr,
>  
>  	if (f2fs_encrypted_file(inode))
>  		post_read_steps |= 1 << STEP_DECRYPT;
> -#ifdef CONFIG_F2FS_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  	if (inode->i_verity_info != NULL &&
>  	    (first_idx < ((i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT)))
>  		post_read_steps |= 1 << STEP_VERITY;
> diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
> index ea8a5ffc4f1f..dc999af932f2 100644
> --- a/fs/f2fs/f2fs.h
> +++ b/fs/f2fs/f2fs.h
> @@ -25,8 +25,6 @@
>  #include <crypto/hash.h>
>  
>  #include <linux/fscrypt.h>
> -
> -#define __FS_HAS_VERITY IS_ENABLED(CONFIG_F2FS_FS_VERITY)
>  #include <linux/fsverity.h>
>  
>  #ifdef CONFIG_F2FS_CHECK_FS
> diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
> index 4287cf348d3c..60d5338280fb 100644
> --- a/fs/f2fs/super.c
> +++ b/fs/f2fs/super.c
> @@ -2197,7 +2197,7 @@ static const struct fscrypt_operations f2fs_cryptops = {
>  };
>  #endif
>  
> -#ifdef CONFIG_F2FS_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  static int f2fs_set_verity(struct inode *inode, loff_t data_i_size)
>  {
>  	int err;
> @@ -2222,7 +2222,7 @@ static const struct fsverity_operations f2fs_verityops = {
>  	.set_verity		= f2fs_set_verity,
>  	.get_metadata_end	= f2fs_get_metadata_end,
>  };
> -#endif /* CONFIG_F2FS_FS_VERITY */
> +#endif /* CONFIG_FS_VERITY */
>  
>  static struct inode *f2fs_nfs_get_inode(struct super_block *sb,
>  		u64 ino, u32 generation)
> @@ -3146,7 +3146,7 @@ static int f2fs_fill_super(struct super_block *sb, void *data, int silent)
>  #ifdef CONFIG_FS_ENCRYPTION
>  	sb->s_cop = &f2fs_cryptops;
>  #endif
> -#ifdef CONFIG_F2FS_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  	sb->s_vop = &f2fs_verityops;
>  #endif
>  	sb->s_xattr = f2fs_xattr_handlers;
> diff --git a/fs/f2fs/sysfs.c b/fs/f2fs/sysfs.c
> index 737677655bc0..949e6d87f4e3 100644
> --- a/fs/f2fs/sysfs.c
> +++ b/fs/f2fs/sysfs.c
> @@ -444,7 +444,7 @@ F2FS_FEATURE_RO_ATTR(flexible_inline_xattr, FEAT_FLEXIBLE_INLINE_XATTR);
>  F2FS_FEATURE_RO_ATTR(quota_ino, FEAT_QUOTA_INO);
>  F2FS_FEATURE_RO_ATTR(inode_crtime, FEAT_INODE_CRTIME);
>  F2FS_FEATURE_RO_ATTR(lost_found, FEAT_LOST_FOUND);
> -#ifdef CONFIG_F2FS_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  F2FS_FEATURE_RO_ATTR(verity, FEAT_VERITY);
>  #endif
>  F2FS_FEATURE_RO_ATTR(sb_checksum, FEAT_SB_CHECKSUM);
> @@ -507,7 +507,7 @@ static struct attribute *f2fs_feat_attrs[] = {
>  	ATTR_LIST(quota_ino),
>  	ATTR_LIST(inode_crtime),
>  	ATTR_LIST(lost_found),
> -#ifdef CONFIG_F2FS_FS_VERITY
> +#ifdef CONFIG_FS_VERITY
>  	ATTR_LIST(verity),
>  #endif
>  	ATTR_LIST(sb_checksum),
> diff --git a/fs/verity/Kconfig b/fs/verity/Kconfig
> index a7470a2e4892..b5a48a9ef0ca 100644
> --- a/fs/verity/Kconfig
> +++ b/fs/verity/Kconfig
> @@ -1,5 +1,5 @@
>  config FS_VERITY
> -	tristate "FS Verity (read-only file-based authenticity protection)"
> +	bool "FS Verity (read-only file-based authenticity protection)"
>  	select CRYPTO
>  	# SHA-256 is selected as it's intended to be the default hash algorithm.
>  	# To avoid bloat, other wanted algorithms must be selected explicitly.
> diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
> index c30c4f6ed411..f37132c640ee 100644
> --- a/include/linux/fsverity.h
> +++ b/include/linux/fsverity.h
> @@ -19,8 +19,7 @@ struct fsverity_operations {
>  	int (*get_metadata_end)(struct inode *inode, loff_t *metadata_end_ret);
>  };
>  
> -#if __FS_HAS_VERITY
> -
> +#ifdef CONFIG_FS_VERITY
>  /* ioctl.c */
>  extern int fsverity_ioctl_enable(struct file *filp, const void __user *arg);
>  extern int fsverity_ioctl_measure(struct file *filp, void __user *arg);
> -- 
> 2.19.1
> 
