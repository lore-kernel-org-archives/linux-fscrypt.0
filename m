Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Tue, 22 Jan 2019 16:21:56 -0800
Message-Id: <20190123002156.116601-1-ebiggers@kernel.org>
MIME-Version: 1.0
Subject: [f2fs-dev] [PATCH] fscrypt: return -EXDEV for incompatible rename
 or link into encrypted dir
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
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: Michael Halcrow <mhalcrow@google.com>, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Currently, trying to rename or link a regular file, directory, or
symlink into an encrypted directory fails with EPERM when the source
file is unencrypted or is encrypted with a different encryption policy,
and is on the same mountpoint.  It is correct for the operation to fail,
but the choice of EPERM breaks tools like 'mv' that know to copy rather
than rename if they see EXDEV, but don't know what to do with EPERM.

Our original motivation for EPERM was to encourage users to securely
handle their data.  Encrypting files by "moving" them into an encrypted
directory can be insecure because the unencrypted data may remain in
free space on disk, where it can later be recovered by an attacker.
It's much better to encrypt the data from the start, or at least try to
securely delete the source data e.g. using the 'shred' program.

However, the current behavior hasn't been effective at achieving its
goal because users tend to be confused, hack around it, and complain;
see e.g. https://github.com/google/fscrypt/issues/76.  And in some cases
it's actually inconsistent or unnecessary.  For example, 'mv'-ing files
between differently encrypted directories doesn't work even in cases
where it can be secure, such as when in userspace the same passphrase
protects both directories.  Yet, you *can* already 'mv' unencrypted
files into an encrypted directory if the source files are on a different
mountpoint, even though doing so is often insecure.

There are probably better ways to teach users to securely handle their
files.  For example, the 'fscrypt' userspace tool could provide a
command that migrates unencrypted files into an encrypted directory,
acting like 'shred' on the source files and providing appropriate
warnings depending on the type of the source filesystem and disk.

Receiving errors on unimportant files might also force some users to
disable encryption, thus making the behavior counterproductive.  It's
desirable to make encryption as unobtrusive as possible.

Therefore, change the error code from EPERM to EXDEV so that tools
looking for EXDEV will fall back to a copy.

This, of course, doesn't prevent users from still doing the right things
to securely manage their files.  Note that this also matches the
behavior when a file is renamed between two project quota hierarchies;
so there's precedent for using EXDEV for things other than mountpoints.

xfstests generic/398 will require an update with this change.

[Rewritten from an earlier patch series by Michael Halcrow.]

Cc: Michael Halcrow <mhalcrow@google.com>
Cc: Joe Richey <joerichey@google.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 Documentation/filesystems/fscrypt.rst | 12 ++++++++++--
 fs/crypto/hooks.c                     |  6 +++---
 fs/crypto/policy.c                    |  3 +--
 include/linux/fscrypt.h               |  4 ++--
 4 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index 43dd989e2a3f..08c23b60e016 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -451,10 +451,18 @@ astute users may notice some differences in behavior:
 - Unencrypted files, or files encrypted with a different encryption
   policy (i.e. different key, modes, or flags), cannot be renamed or
   linked into an encrypted directory; see `Encryption policy
-  enforcement`_.  Attempts to do so will fail with EPERM.  However,
+  enforcement`_.  Attempts to do so will fail with EXDEV.  However,
   encrypted files can be renamed within an encrypted directory, or
   into an unencrypted directory.
 
+  Note: "moving" an unencrypted file into an encrypted directory, e.g.
+  with the `mv` program, is implemented in userspace by a copy
+  followed by a delete.  Be aware that the original unencrypted data
+  may remain recoverable from free space on the disk; prefer to keep
+  all files encrypted from the very beginning.  The `shred` program
+  may be used to overwrite the source files but isn't guaranteed to be
+  effective on all filesystems and storage devices.
+
 - Direct I/O is not supported on encrypted files.  Attempts to use
   direct I/O on such files will fall back to buffered I/O.
 
@@ -541,7 +549,7 @@ not be encrypted.
 Except for those special files, it is forbidden to have unencrypted
 files, or files encrypted with a different encryption policy, in an
 encrypted directory tree.  Attempts to link or rename such a file into
-an encrypted directory will fail with EPERM.  This is also enforced
+an encrypted directory will fail with EXDEV.  This is also enforced
 during ->lookup() to provide limited protection against offline
 attacks that try to disable or downgrade encryption in known locations
 where applications may later write sensitive data.  It is recommended
diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index 926e5df20ec3..56debb1fcf5e 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -58,7 +58,7 @@ int __fscrypt_prepare_link(struct inode *inode, struct inode *dir)
 		return err;
 
 	if (!fscrypt_has_permitted_context(dir, inode))
-		return -EPERM;
+		return -EXDEV;
 
 	return 0;
 }
@@ -82,13 +82,13 @@ int __fscrypt_prepare_rename(struct inode *old_dir, struct dentry *old_dentry,
 		if (IS_ENCRYPTED(new_dir) &&
 		    !fscrypt_has_permitted_context(new_dir,
 						   d_inode(old_dentry)))
-			return -EPERM;
+			return -EXDEV;
 
 		if ((flags & RENAME_EXCHANGE) &&
 		    IS_ENCRYPTED(old_dir) &&
 		    !fscrypt_has_permitted_context(old_dir,
 						   d_inode(new_dentry)))
-			return -EPERM;
+			return -EXDEV;
 	}
 	return 0;
 }
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index f490de921ce8..bd7eaf9b3f00 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -151,8 +151,7 @@ EXPORT_SYMBOL(fscrypt_ioctl_get_policy);
  * malicious offline violations of this constraint, while the link and rename
  * checks are needed to prevent online violations of this constraint.
  *
- * Return: 1 if permitted, 0 if forbidden.  If forbidden, the caller must fail
- * the filesystem operation with EPERM.
+ * Return: 1 if permitted, 0 if forbidden.
  */
 int fscrypt_has_permitted_context(struct inode *parent, struct inode *child)
 {
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index eec604840568..e5194fc3983e 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -489,7 +489,7 @@ static inline int fscrypt_require_key(struct inode *inode)
  * in an encrypted directory tree use the same encryption policy.
  *
  * Return: 0 on success, -ENOKEY if the directory's encryption key is missing,
- * -EPERM if the link would result in an inconsistent encryption policy, or
+ * -EXDEV if the link would result in an inconsistent encryption policy, or
  * another -errno code.
  */
 static inline int fscrypt_prepare_link(struct dentry *old_dentry,
@@ -519,7 +519,7 @@ static inline int fscrypt_prepare_link(struct dentry *old_dentry,
  * We also verify that the rename will not violate the constraint that all files
  * in an encrypted directory tree use the same encryption policy.
  *
- * Return: 0 on success, -ENOKEY if an encryption key is missing, -EPERM if the
+ * Return: 0 on success, -ENOKEY if an encryption key is missing, -EXDEV if the
  * rename would cause inconsistent encryption policies, or another -errno code.
  */
 static inline int fscrypt_prepare_rename(struct inode *old_dir,
-- 
2.20.1.321.g9e740568ce-goog



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
