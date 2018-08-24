Return-Path: <SRS0=14es=LH=vger.kernel.org=linux-integrity-owner@kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH 04/10] fs-verity: implement FS_IOC_MEASURE_VERITY ioctl
Date: Fri, 24 Aug 2018 09:16:36 -0700
Message-Id: <20180824161642.1144-5-ebiggers@kernel.org>
In-Reply-To: <20180824161642.1144-1-ebiggers@kernel.org>
References: <20180824161642.1144-1-ebiggers@kernel.org>
Sender: linux-integrity-owner@vger.kernel.org
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add a function for filesystems to call to implement the
FS_IOC_MEASURE_VERITY ioctl.  This ioctl retrieves the file measurement
hash that fs-verity calculated for the given file and is enforcing for
reads; i.e., reads that don't match this hash will fail.

This ioctl can be used to implement lightweight auditing or
authentication of file hashes in userspace, as an alternative to an
in-kernel policy such as an IMA policy.

Note that due to fs-verity's use of a Merkle tree, opening a file and
executing this ioctl takes constant time, regardless of the file's size.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/verity/ioctl.c        | 49 ++++++++++++++++++++++++++++++++++++++++
 fs/verity/setup.c        |  4 +++-
 include/linux/fsverity.h |  6 +++++
 3 files changed, 58 insertions(+), 1 deletion(-)

diff --git a/fs/verity/ioctl.c b/fs/verity/ioctl.c
index 993f2afdcc734..3da9b0f441c13 100644
--- a/fs/verity/ioctl.c
+++ b/fs/verity/ioctl.c
@@ -119,3 +119,52 @@ int fsverity_ioctl_enable(struct file *filp, const void __user *arg)
 	return err;
 }
 EXPORT_SYMBOL_GPL(fsverity_ioctl_enable);
+
+/**
+ * fsverity_ioctl_measure - get a verity file's measurement
+ *
+ * The FS_IOC_MEASURE_VERITY ioctl retrieves the file measurement that the
+ * kernel is enforcing for reads from a verity file.
+ *
+ * No privileges are required to use this ioctl, since it is a read-only
+ * operation on a single regular file.
+ *
+ * Return: 0 on success, -errno on failure
+ */
+int fsverity_ioctl_measure(struct file *filp, void __user *_uarg)
+{
+	const struct inode *inode = file_inode(filp);
+	struct fsverity_digest __user *uarg = _uarg;
+	const struct fsverity_info *vi;
+	const struct fsverity_hash_alg *hash_alg;
+	struct fsverity_digest arg;
+
+	vi = get_fsverity_info(inode);
+	if (!vi)
+		return -ENODATA; /* not a verity file */
+	hash_alg = vi->hash_alg;
+
+	/*
+	 * The user specifies the digest_size their buffer has space for; we can
+	 * return the digest if it fits in the available space.  We write back
+	 * the actual size, which may be shorter than the user-specified size.
+	 */
+
+	if (get_user(arg.digest_size, &uarg->digest_size))
+		return -EFAULT;
+	if (arg.digest_size < hash_alg->digest_size)
+		return -EOVERFLOW;
+
+	memset(&arg, 0, sizeof(arg));
+	arg.digest_algorithm = hash_alg - fsverity_hash_algs;
+	arg.digest_size = hash_alg->digest_size;
+
+	if (copy_to_user(uarg, &arg, sizeof(arg)))
+		return -EFAULT;
+
+	if (copy_to_user(uarg->digest, vi->measurement, hash_alg->digest_size))
+		return -EFAULT;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(fsverity_ioctl_measure);
diff --git a/fs/verity/setup.c b/fs/verity/setup.c
index 84cc2edeca25b..3f5cb9526dbc9 100644
--- a/fs/verity/setup.c
+++ b/fs/verity/setup.c
@@ -842,7 +842,9 @@ static int __init fsverity_module_init(void)
 		goto error;
 
 	err = -ENOMEM;
-	fsverity_info_cachep = KMEM_CACHE(fsverity_info, SLAB_RECLAIM_ACCOUNT);
+	fsverity_info_cachep = KMEM_CACHE_USERCOPY(fsverity_info,
+						   SLAB_RECLAIM_ACCOUNT,
+						   measurement);
 	if (!fsverity_info_cachep)
 		goto error_free_workqueue;
 
diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
index c710b6b5fb4a6..9d3371dbd262f 100644
--- a/include/linux/fsverity.h
+++ b/include/linux/fsverity.h
@@ -23,6 +23,7 @@ struct fsverity_operations {
 
 /* ioctl.c */
 extern int fsverity_ioctl_enable(struct file *filp, const void __user *arg);
+extern int fsverity_ioctl_measure(struct file *filp, void __user *arg);
 
 /* setup.c */
 extern int fsverity_file_open(struct inode *inode, struct file *filp);
@@ -46,6 +47,11 @@ static inline int fsverity_ioctl_enable(struct file *filp,
 	return -EOPNOTSUPP;
 }
 
+static inline int fsverity_ioctl_measure(struct file *filp, void __user *arg)
+{
+	return -EOPNOTSUPP;
+}
+
 /* setup.c */
 
 static inline int fsverity_file_open(struct inode *inode, struct file *filp)
-- 
2.18.0
