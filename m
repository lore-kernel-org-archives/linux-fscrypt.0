Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Thu,  1 Nov 2018 15:52:24 -0700
Message-Id: <20181101225230.88058-7-ebiggers@kernel.org>
In-Reply-To: <20181101225230.88058-1-ebiggers@kernel.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH v2 06/12] fs-verity: implement
 FS_IOC_MEASURE_VERITY ioctl
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-integrity@vger.kernel.org, linux-ext4@vger.kernel.org, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add a function for filesystems to call to implement the
FS_IOC_MEASURE_VERITY ioctl.  This ioctl retrieves the file measurement
hash that fs-verity calculated for the given file and is enforcing for
reads; i.e., reads that don't match this hash will fail.  This ioctl can
be used for logging or authentication of file hashes in userspace.

This ioctl is documented in Documentation/filesystem/fsverity.rst;
see there for more information.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/verity/ioctl.c        | 47 ++++++++++++++++++++++++++++++++++++++++
 fs/verity/setup.c        |  4 +++-
 include/linux/fsverity.h |  6 +++++
 3 files changed, 56 insertions(+), 1 deletion(-)

diff --git a/fs/verity/ioctl.c b/fs/verity/ioctl.c
index c5f0022cb3bef..640aa78e1c00c 100644
--- a/fs/verity/ioctl.c
+++ b/fs/verity/ioctl.c
@@ -115,3 +115,50 @@ int fsverity_ioctl_enable(struct file *filp, const void __user *arg)
 	return err;
 }
 EXPORT_SYMBOL_GPL(fsverity_ioctl_enable);
+
+/**
+ * fsverity_ioctl_measure - get a verity file's measurement
+ *
+ * Retrieve the file measurement that the kernel is enforcing for reads from a
+ * verity file.  See Documentation/filesystems/fsverity.rst, section
+ * 'FS_IOC_MEASURE_VERITY' for details.
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
index 184bdc96abe51..e0b39c518b890 100644
--- a/fs/verity/setup.c
+++ b/fs/verity/setup.c
@@ -819,7 +819,9 @@ static int __init fsverity_module_init(void)
 		goto error;
 
 	err = -ENOMEM;
-	fsverity_info_cachep = KMEM_CACHE(fsverity_info, SLAB_RECLAIM_ACCOUNT);
+	fsverity_info_cachep = KMEM_CACHE_USERCOPY(fsverity_info,
+						   SLAB_RECLAIM_ACCOUNT,
+						   measurement);
 	if (!fsverity_info_cachep)
 		goto error_free_workqueue;
 
diff --git a/include/linux/fsverity.h b/include/linux/fsverity.h
index 5de50b52ccc70..c30c4f6ed411c 100644
--- a/include/linux/fsverity.h
+++ b/include/linux/fsverity.h
@@ -23,6 +23,7 @@ struct fsverity_operations {
 
 /* ioctl.c */
 extern int fsverity_ioctl_enable(struct file *filp, const void __user *arg);
+extern int fsverity_ioctl_measure(struct file *filp, void __user *arg);
 
 /* setup.c */
 extern int fsverity_file_open(struct inode *inode, struct file *filp);
@@ -51,6 +52,11 @@ static inline int fsverity_ioctl_enable(struct file *filp,
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
2.19.1.568.g152ad8e336-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
