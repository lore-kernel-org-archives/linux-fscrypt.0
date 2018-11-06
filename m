Date: Mon, 5 Nov 2018 17:25:03 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v2 10/12] ext4: add basic fs-verity support
Message-ID: <20181106012503.GB28490@gmail.com>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-11-ebiggers@kernel.org>
 <2168901.PE78DCQIza@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2168901.PE78DCQIza@localhost.localdomain>
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chandan,

On Fri, Nov 02, 2018 at 03:13:14PM +0530, Chandan Rajendra wrote:
> On Friday, November 2, 2018 4:22:28 AM IST Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Add basic fs-verity support to ext4.  fs-verity is a filesystem feature
> > that enables transparent integrity protection and authentication of
> > read-only files.  It uses a dm-verity like mechanism at the file level:
> > a Merkle tree is used to verify any block in the file in log(filesize)
> > time.  It is implemented mainly by helper functions in fs/verity/.
> > See Documentation/filesystems/fsverity.rst for details.
> > 
> > This patch adds everything except the data verification hooks that will
> > needed in ->readpages().
> > 
> > On ext4, enabling fs-verity on a file requires that the filesystem has
> > the 'verity' feature, e.g. that it was formatted with
> > 'mkfs.ext4 -O verity' or had 'tune2fs -O verity' run on it.
> > This requires e2fsprogs 1.44.4-2 or later.
> > 
> > In ext4, we choose to retain the fs-verity metadata past the end of the
> > file rather than trying to move it into an external inode xattr, since
> > in practice keeping the metadata in-line actually results in the
> > simplest and most efficient implementation.  One non-obvious advantage
> > of keeping the verity metadata in-line is that when fs-verity is
> > combined with fscrypt, the verity metadata naturally gets encrypted too;
> > this is actually necessary because it contains hashes of the plaintext.
> > 
> > We also choose to keep the on-disk i_size equal to the original file
> > size, in order to make the 'verity' feature a RO_COMPAT feature.  Thus,
> > ext4 has to find the fsverity_footer by looking in the last extent.
> > 
> > Co-developed-by: Theodore Ts'o <tytso@mit.edu>
> > Signed-off-by: Theodore Ts'o <tytso@mit.edu>
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > ---
> >  fs/ext4/Kconfig | 20 +++++++++++
> >  fs/ext4/ext4.h  | 20 ++++++++++-
> >  fs/ext4/file.c  |  6 ++++
> >  fs/ext4/inode.c |  8 +++++
> >  fs/ext4/ioctl.c | 12 +++++++
> >  fs/ext4/super.c | 91 +++++++++++++++++++++++++++++++++++++++++++++++++
> >  fs/ext4/sysfs.c |  6 ++++
> >  7 files changed, 162 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/ext4/Kconfig b/fs/ext4/Kconfig
> > index a453cc87082b5..5a76125ac0f8a 100644
> > --- a/fs/ext4/Kconfig
> > +++ b/fs/ext4/Kconfig
> > @@ -111,6 +111,26 @@ config EXT4_FS_ENCRYPTION
> >  	default y
> >  	depends on EXT4_ENCRYPTION
> > 
> > +config EXT4_FS_VERITY
> > +	bool "Ext4 Verity"
> > +	depends on EXT4_FS
> > +	select FS_VERITY
> > +	help
> > +	  This option enables fs-verity for ext4.  fs-verity is the
> > +	  dm-verity mechanism implemented at the file level.  Userspace
> > +	  can append a Merkle tree (hash tree) to a file, then enable
> > +	  fs-verity on the file.  ext4 will then transparently verify
> > +	  any data read from the file against the Merkle tree.  The file
> > +	  is also made read-only.
> > +
> > +	  This serves as an integrity check, but the availability of the
> > +	  Merkle tree root hash also allows efficiently supporting
> > +	  various use cases where normally the whole file would need to
> > +	  be hashed at once, such as auditing and authenticity
> > +	  verification (appraisal).
> > +
> > +	  If unsure, say N.
> > +
> >  config EXT4_DEBUG
> >  	bool "EXT4 debugging support"
> >  	depends on EXT4_FS
> > diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> > index 12f90d48ba613..e5475a629ed80 100644
> > --- a/fs/ext4/ext4.h
> > +++ b/fs/ext4/ext4.h
> > @@ -43,6 +43,9 @@
> >  #define __FS_HAS_ENCRYPTION IS_ENABLED(CONFIG_EXT4_FS_ENCRYPTION)
> >  #include <linux/fscrypt.h>
> > 
> > +#define __FS_HAS_VERITY IS_ENABLED(CONFIG_EXT4_FS_VERITY)
> > +#include <linux/fsverity.h>
> > +
> >  #include <linux/compiler.h>
> > 
> >  /* Until this gets included into linux/compiler-gcc.h */
> > @@ -405,6 +408,7 @@ struct flex_groups {
> >  #define EXT4_TOPDIR_FL			0x00020000 /* Top of directory hierarchies*/
> >  #define EXT4_HUGE_FILE_FL               0x00040000 /* Set to each huge file */
> >  #define EXT4_EXTENTS_FL			0x00080000 /* Inode uses extents */
> > +#define EXT4_VERITY_FL			0x00100000 /* Verity protected inode */
> >  #define EXT4_EA_INODE_FL	        0x00200000 /* Inode used for large EA */
> >  #define EXT4_EOFBLOCKS_FL		0x00400000 /* Blocks allocated beyond EOF */
> >  #define EXT4_INLINE_DATA_FL		0x10000000 /* Inode has inline data. */
> > @@ -472,6 +476,7 @@ enum {
> >  	EXT4_INODE_TOPDIR	= 17,	/* Top of directory hierarchies*/
> >  	EXT4_INODE_HUGE_FILE	= 18,	/* Set to each huge file */
> >  	EXT4_INODE_EXTENTS	= 19,	/* Inode uses extents */
> > +	EXT4_INODE_VERITY	= 20,	/* Verity protected inode */
> >  	EXT4_INODE_EA_INODE	= 21,	/* Inode used for large EA */
> >  	EXT4_INODE_EOFBLOCKS	= 22,	/* Blocks allocated beyond EOF */
> >  	EXT4_INODE_INLINE_DATA	= 28,	/* Data in inode. */
> > @@ -517,6 +522,7 @@ static inline void ext4_check_flag_values(void)
> >  	CHECK_FLAG_VALUE(TOPDIR);
> >  	CHECK_FLAG_VALUE(HUGE_FILE);
> >  	CHECK_FLAG_VALUE(EXTENTS);
> > +	CHECK_FLAG_VALUE(VERITY);
> >  	CHECK_FLAG_VALUE(EA_INODE);
> >  	CHECK_FLAG_VALUE(EOFBLOCKS);
> >  	CHECK_FLAG_VALUE(INLINE_DATA);
> > @@ -1654,6 +1660,7 @@ static inline void ext4_clear_state_flags(struct ext4_inode_info *ei)
> >  #define EXT4_FEATURE_RO_COMPAT_METADATA_CSUM	0x0400
> >  #define EXT4_FEATURE_RO_COMPAT_READONLY		0x1000
> >  #define EXT4_FEATURE_RO_COMPAT_PROJECT		0x2000
> > +#define EXT4_FEATURE_RO_COMPAT_VERITY		0x8000
> > 
> >  #define EXT4_FEATURE_INCOMPAT_COMPRESSION	0x0001
> >  #define EXT4_FEATURE_INCOMPAT_FILETYPE		0x0002
> > @@ -1742,6 +1749,7 @@ EXT4_FEATURE_RO_COMPAT_FUNCS(bigalloc,		BIGALLOC)
> >  EXT4_FEATURE_RO_COMPAT_FUNCS(metadata_csum,	METADATA_CSUM)
> >  EXT4_FEATURE_RO_COMPAT_FUNCS(readonly,		READONLY)
> >  EXT4_FEATURE_RO_COMPAT_FUNCS(project,		PROJECT)
> > +EXT4_FEATURE_RO_COMPAT_FUNCS(verity,		VERITY)
> > 
> >  EXT4_FEATURE_INCOMPAT_FUNCS(compression,	COMPRESSION)
> >  EXT4_FEATURE_INCOMPAT_FUNCS(filetype,		FILETYPE)
> > @@ -1797,7 +1805,8 @@ EXT4_FEATURE_INCOMPAT_FUNCS(encrypt,		ENCRYPT)
> >  					 EXT4_FEATURE_RO_COMPAT_BIGALLOC |\
> >  					 EXT4_FEATURE_RO_COMPAT_METADATA_CSUM|\
> >  					 EXT4_FEATURE_RO_COMPAT_QUOTA |\
> > -					 EXT4_FEATURE_RO_COMPAT_PROJECT)
> > +					 EXT4_FEATURE_RO_COMPAT_PROJECT |\
> > +					 EXT4_FEATURE_RO_COMPAT_VERITY)
> > 
> >  #define EXTN_FEATURE_FUNCS(ver) \
> >  static inline bool ext4_has_unknown_ext##ver##_compat_features(struct super_block *sb) \
> > @@ -2293,6 +2302,15 @@ static inline bool ext4_encrypted_inode(struct inode *inode)
> >  	return ext4_test_inode_flag(inode, EXT4_INODE_ENCRYPT);
> >  }
> > 
> > +static inline bool ext4_verity_inode(struct inode *inode)
> > +{
> > +#ifdef CONFIG_EXT4_FS_VERITY
> > +	return ext4_test_inode_flag(inode, EXT4_INODE_VERITY);
> > +#else
> > +	return false;
> > +#endif
> > +}
> > +
> 
> Hi Eric,
> 
> Can you please explain as to why we check for the presence of
> EXT4_INODE_VERITY flag only when fsverity is enabled during kernel build?
> 

Good question, this might not be the best approach actually; I think this was
originally copied from the f2fs version.  It does reduce the overhead introduced
by the fs-verity changes in the !CONFIG_EXT4_FS_VERITY case.  But it will allow
opening verity files, even for writing which will corrupt them.

Probably we should make ext4_verity_inode() work regardless of
CONFIG_EXT4_FS_VERITY, so open(), truncate(), etc. will fail with EOPNOTSUPP on
verity files when !CONFIG_EXT4_FS_VERITY, like how ext4 encryption works.

Thanks,

- Eric
