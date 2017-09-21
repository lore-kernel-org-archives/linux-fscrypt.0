Return-Path: <david@fromorbit.com>
Date: Thu, 21 Sep 2017 16:45:02 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/25] fscrypt: add some higher-level helper functions
Message-ID: <20170921064502.GR10621@dastard>
References: <20170920224605.22030-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170920224605.22030-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Sep 20, 2017 at 03:45:40PM -0700, Eric Biggers wrote:
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

This all looks much nicer. Having just been looking at this stuff,
it makes the code much simpler to understand. So:

Acked-by: Dave Chinner <dchinner@redhat.com>

While I'm here, the fscrypt header file includes are clunky and
nasty. I worte a quick patch a couple of days ago to clean it up.
See below....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com


fscrypto: clean up include file mess

From: Dave Chinner <dchinner@redhat.com>

Filesystems have to include different header files based on whether
they are compiled with encryption support or not. That's nasty and
messy.

Instead, rationalise the headers so we have a single include
fscrypt.h and let it decide what internal implementation to include
based on the __FS_HAS_ENCRYPTION define. Filesystems set
__FS_HAS_ENCRYPTION before including linux/fscrypt.h if they are
built with encryption support.

Add guards to prevent fscrypt_supp.h and fscrypt_notsupp.h from
being directly included by filesystems.

Signed-Off-By: Dave Chinner <dchinner@redhat.com>
---
 fs/crypto/fscrypt_private.h                   |  3 +-
 fs/ext4/ext4.h                                | 11 +++----
 fs/f2fs/f2fs.h                                |  8 +++---
 fs/ubifs/ubifs.h                              |  9 +++---
 include/linux/{fscrypt_common.h => fscrypt.h} | 41 ++++++++++++++++++---------
 include/linux/fscrypt_notsupp.h               |  7 +++--
 include/linux/fscrypt_supp.h                  |  7 +++--
 7 files changed, 54 insertions(+), 32 deletions(-)

diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index a1d5021c31ef..a180981ee6d7 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -11,7 +11,8 @@
 #ifndef _FSCRYPT_PRIVATE_H
 #define _FSCRYPT_PRIVATE_H
 
-#include <linux/fscrypt_supp.h>
+#define __FS_HAS_ENCRYPTION 1
+#include <linux/fscrypt.h>
 #include <crypto/hash.h>
 
 /* Encryption parameters */
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index e2abe01c8c6b..900ac79879b3 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -33,17 +33,18 @@
 #include <linux/percpu_counter.h>
 #include <linux/ratelimit.h>
 #include <crypto/hash.h>
-#ifdef CONFIG_EXT4_FS_ENCRYPTION
-#include <linux/fscrypt_supp.h>
-#else
-#include <linux/fscrypt_notsupp.h>
-#endif
+
 #include <linux/falloc.h>
 #include <linux/percpu-rwsem.h>
 #ifdef __KERNEL__
 #include <linux/compat.h>
 #endif
 
+#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#define __FS_HAS_ENCRYPTION 1
+#endif
+#include <linux/fscrypt.h>
+
 /*
  * The fourth extended filesystem constants/structures
  */
diff --git a/fs/f2fs/f2fs.h b/fs/f2fs/f2fs.h
index 9a7c90386947..66502c5f7d67 100644
--- a/fs/f2fs/f2fs.h
+++ b/fs/f2fs/f2fs.h
@@ -23,12 +23,12 @@
 #include <linux/bio.h>
 #include <linux/blkdev.h>
 #include <linux/quotaops.h>
+#include <crypto/hash.h>
+
 #ifdef CONFIG_F2FS_FS_ENCRYPTION
-#include <linux/fscrypt_supp.h>
-#else
-#include <linux/fscrypt_notsupp.h>
+#define __FS_HAS_ENCRYPTION 1
 #endif
-#include <crypto/hash.h>
+#include <linux/fscrypt.h>
 
 #ifdef CONFIG_F2FS_CHECK_FS
 #define f2fs_bug_on(sbi, condition)	BUG_ON(condition)
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index cd43651f1731..e5b6c8f02133 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -38,12 +38,13 @@
 #include <linux/backing-dev.h>
 #include <linux/security.h>
 #include <linux/xattr.h>
+#include <linux/random.h>
+
 #ifdef CONFIG_UBIFS_FS_ENCRYPTION
-#include <linux/fscrypt_supp.h>
-#else
-#include <linux/fscrypt_notsupp.h>
+#define __FS_HAS_ENCRYPTION 1
 #endif
-#include <linux/random.h>
+#include <linux/fscrypt.h>
+
 #include "ubifs-media.h"
 
 /* Version of this UBIFS implementation */
diff --git a/include/linux/fscrypt_common.h b/include/linux/fscrypt.h
similarity index 79%
rename from include/linux/fscrypt_common.h
rename to include/linux/fscrypt.h
index 97f738628b36..4db0a7ec26d9 100644
--- a/include/linux/fscrypt_common.h
+++ b/include/linux/fscrypt.h
@@ -1,14 +1,17 @@
 /*
- * fscrypt_common.h: common declarations for per-file encryption
+ * fscrypt.h: declarations for per-file encryption
+ *
+ * Filesystems that implement per-file encryption include this header
+ * file with the __FS_HAS_ENCRYPTION set according to whether that filesystem
+ * is being built with encryption support or not.
  *
  * Copyright (C) 2015, Google, Inc.
  *
  * Written by Michael Halcrow, 2015.
  * Modified by Jaegeuk Kim, 2015.
  */
-
-#ifndef _LINUX_FSCRYPT_COMMON_H
-#define _LINUX_FSCRYPT_COMMON_H
+#ifndef _LINUX_FSCRYPT_H
+#define _LINUX_FSCRYPT_H
 
 #include <linux/key.h>
 #include <linux/fs.h>
@@ -119,23 +122,35 @@ static inline bool fscrypt_is_dot_dotdot(const struct qstr *str)
 	return false;
 }
 
+#ifdef __FS_HAS_ENCRYPTION
+
 static inline struct page *fscrypt_control_page(struct page *page)
 {
-#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
 	return ((struct fscrypt_ctx *)page_private(page))->w.control_page;
-#else
+}
+
+static inline bool fscrypt_has_encryption_key(const struct inode *inode)
+{
+	return (inode->i_crypt_info != NULL);
+}
+
+#include <linux/fscrypt_supp.h>
+
+#else /* !__FS_HAS_ENCRYPTION */
+
+static inline struct page *fscrypt_control_page(struct page *page)
+{
 	WARN_ON_ONCE(1);
 	return ERR_PTR(-EINVAL);
-#endif
 }
 
-static inline int fscrypt_has_encryption_key(const struct inode *inode)
+static inline bool fscrypt_has_encryption_key(const struct inode *inode)
 {
-#if IS_ENABLED(CONFIG_FS_ENCRYPTION)
-	return (inode->i_crypt_info != NULL);
-#else
 	return 0;
-#endif
 }
 
-#endif	/* _LINUX_FSCRYPT_COMMON_H */
+#include <linux/fscrypt_notsupp.h>
+#endif	/* __FS_HAS_ENCRYPTION */
+
+
+#endif	/* _LINUX_FSCRYPT_H */
diff --git a/include/linux/fscrypt_notsupp.h b/include/linux/fscrypt_notsupp.h
index ec406aed2f2f..2d0b6960831e 100644
--- a/include/linux/fscrypt_notsupp.h
+++ b/include/linux/fscrypt_notsupp.h
@@ -3,13 +3,16 @@
  *
  * This stubs out the fscrypt functions for filesystems configured without
  * encryption support.
+ *
+ * Do not include this file directly. Use fscrypt.h instead!
  */
+#ifndef _LINUX_FSCRYPT_H
+#error "Incorrect include of linux/fscrypt_notsupp.h!"
+#endif
 
 #ifndef _LINUX_FSCRYPT_NOTSUPP_H
 #define _LINUX_FSCRYPT_NOTSUPP_H
 
-#include <linux/fscrypt_common.h>
-
 /* crypto.c */
 static inline struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *inode,
 						  gfp_t gfp_flags)
diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index 32e2fcf13b01..5a90e5ef4687 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -1,14 +1,15 @@
 /*
  * fscrypt_supp.h
  *
- * This is included by filesystems configured with encryption support.
+ * Do not include this file directly. Use fscrypt.h instead!
  */
+#ifndef _LINUX_FSCRYPT_H
+#error "Incorrect include of linux/fscrypt_supp.h!"
+#endif
 
 #ifndef _LINUX_FSCRYPT_SUPP_H
 #define _LINUX_FSCRYPT_SUPP_H
 
-#include <linux/fscrypt_common.h>
-
 /* crypto.c */
 extern struct kmem_cache *fscrypt_info_cachep;
 extern struct fscrypt_ctx *fscrypt_get_ctx(const struct inode *, gfp_t);
