Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] generic: test revalidation of encrypted dentries
Date: Thu,  4 May 2017 14:55:48 -0700
Message-Id: <20170504215548.13698-1-ebiggers3@gmail.com>
To: fstests@vger.kernel.org
Cc: Eric Biggers <ebiggers@google.com>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add a test which verifies that dentries in an encrypted directory are
invalidated when an encryption key is added --- which should cause the
plaintext filenames to be visible and accessible, replacing the encoded
ciphertext filenames and any negative dentries for the plaintext names.
This primarily tests for a bug which was fixed in the v4.5 kernel, plus
a v4.6 fix for incorrect RCU usage in the earlier fix.

Cc: linux-fscrypt@vger.kernel.org
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 .gitignore                     |   1 +
 common/encrypt                 |  42 ++++++++---
 src/Makefile                   |   2 +-
 src/t_encrypted_d_revalidate.c | 122 ++++++++++++++++++++++++++++++++
 tests/generic/600              | 154 +++++++++++++++++++++++++++++++++++++++++
 tests/generic/600.out          |  37 ++++++++++
 tests/generic/group            |   1 +
 7 files changed, 349 insertions(+), 10 deletions(-)
 create mode 100644 src/t_encrypted_d_revalidate.c
 create mode 100755 tests/generic/600
 create mode 100644 tests/generic/600.out

diff --git a/.gitignore b/.gitignore
index b609f10f..38f3a001 100644
--- a/.gitignore
+++ b/.gitignore
@@ -112,6 +112,7 @@
 /src/t_dir_offset
 /src/t_dir_offset2
 /src/t_dir_type
+/src/t_encrypted_d_revalidate
 /src/t_futimens
 /src/t_getcwd
 /src/t_holes
diff --git a/common/encrypt b/common/encrypt
index 85f71d5b..723f1b11 100644
--- a/common/encrypt
+++ b/common/encrypt
@@ -84,25 +84,34 @@ _new_session_keyring()
 	$KEYCTL_PROG new_session >>$seqres.full
 }
 
-#
-# Generate a random encryption key, add it to the session keyring, and print out
-# the resulting key descriptor (example: "8bf798e1a494e1ec").  Requires the
-# keyctl program.  It's assumed the caller has already set up a test-scoped
-# session keyring using _new_session_keyring.
-#
-_generate_encryption_key()
+# Generate a key descriptor (16 character hex string)
+_generate_key_descriptor()
 {
-	# Generate a key descriptor (16 character hex string)
 	local keydesc=""
+	local i
 	for ((i = 0; i < 8; i++)); do
 		keydesc="${keydesc}$(printf "%02x" $(( $RANDOM % 256 )))"
 	done
+	echo $keydesc
+}
 
-	# Generate the actual encryption key (64 bytes)
+# Generate a raw encryption key, but don't add it to the keyring yet.
+_generate_raw_encryption_key()
+{
 	local raw=""
+	local i
 	for ((i = 0; i < 64; i++)); do
 		raw="${raw}\\x$(printf "%02x" $(( $RANDOM % 256 )))"
 	done
+	echo $raw
+}
+
+# Add the specified raw encryption key to the session keyring, using the
+# specified key descriptor.
+_add_encryption_key()
+{
+	local keydesc=$1
+	local raw=$2
 
 	#
 	# Add the key to the session keyring.  The required structure is:
@@ -134,6 +143,21 @@ _generate_encryption_key()
 	fi
 	echo -n -e "${mode}${raw}${size}" |
 		$KEYCTL_PROG padd logon $FSTYP:$keydesc @s >>$seqres.full
+}
+
+#
+# Generate a random encryption key, add it to the session keyring, and print out
+# the resulting key descriptor (example: "8bf798e1a494e1ec").  Requires the
+# keyctl program.  It's assumed the caller has already set up a test-scoped
+# session keyring using _new_session_keyring.
+#
+_generate_encryption_key()
+{
+	local keydesc=$(_generate_key_descriptor)
+	local raw=$(_generate_raw_encryption_key)
+
+	_add_encryption_key $keydesc $raw
+
 	echo $keydesc
 }
 
diff --git a/src/Makefile b/src/Makefile
index f1338ca9..e5042c9b 100644
--- a/src/Makefile
+++ b/src/Makefile
@@ -22,7 +22,7 @@ LINUX_TARGETS = xfsctl bstat t_mtab getdevicesize preallo_rw_pattern_reader \
 	seek_copy_test t_readdir_1 t_readdir_2 fsync-tester nsexec cloner \
 	renameat2 t_getcwd e4compact test-nextquota punch-alternating \
 	attr-list-by-handle-cursor-test listxattr dio-interleaved t_dir_type \
-	dio-invalidate-cache stat_test
+	dio-invalidate-cache stat_test t_encrypted_d_revalidate
 
 SUBDIRS =
 
diff --git a/src/t_encrypted_d_revalidate.c b/src/t_encrypted_d_revalidate.c
new file mode 100644
index 00000000..2cfd9834
--- /dev/null
+++ b/src/t_encrypted_d_revalidate.c
@@ -0,0 +1,122 @@
+/*
+ * t_encrypted_d_revalidate
+ *
+ * Test that ->d_revalidate() for encrypted dentries doesn't oops the
+ * kernel by incorrectly not dropping out of RCU mode.  To do this, try
+ * to look up a negative dentry while another thread deletes its parent
+ * directory.  Fixed by commit 03a8bb0e53d9 ("ext4/fscrypto: avoid RCU
+ * lookup in d_revalidate").
+ *
+ * This doesn't always reproduce reliably, but we give it a few seconds.
+ *
+ * ----------------------------------------------------------------------------
+ *
+ * Copyright (c) 2017 Google, Inc.  All Rights Reserved.
+ *
+ * Author: Eric Biggers <ebiggers@google.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public Licence as published by
+ * the Free Software Foundation; either version 2 of the Licence, or (at
+ * your option) any later version.
+ *
+ * This program is distributed in the hope that it would be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <errno.h>
+#include <pthread.h>
+#include <signal.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/stat.h>
+#include <unistd.h>
+
+#define TIMEOUT		10
+#define DIR_NAME	"dir"
+#define FILE_NAME	DIR_NAME "/file"
+
+static volatile sig_atomic_t timed_out = 0;
+
+static void alarm_handler(int sig)
+{
+	timed_out = 1;
+}
+
+static void __attribute__((noreturn))
+die(int err, const char *msg)
+{
+	fprintf(stderr, "ERROR: %s", msg);
+	if (err)
+		fprintf(stderr, ": %s", strerror(err));
+	fputc('\n', stderr);
+	exit(1);
+}
+
+static void *stat_thread(void *_arg)
+{
+	struct stat stbuf;
+
+	for (;;) {
+		if (stat(FILE_NAME, &stbuf) == 0)
+			die(0, "stat should have failed");
+		if (errno != ENOENT)
+			die(errno, "stat");
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	long ncpus;
+	long num_stat_threads;
+	long i;
+	struct stat stbuf;
+
+	if (argc != 2) {
+		fprintf(stderr, "Usage: %s DIR\n", argv[0]);
+		return 2;
+	}
+
+	if (chdir(argv[1]) != 0)
+		die(errno, "chdir");
+
+	ncpus = sysconf(_SC_NPROCESSORS_ONLN);
+	if (ncpus > 1)
+		num_stat_threads = ncpus - 1;
+	else
+		num_stat_threads = 1;
+
+	for (i = 0; i < num_stat_threads; i++) {
+		pthread_t thread;
+		int err;
+
+		err = pthread_create(&thread, NULL, stat_thread, NULL);
+		if (err)
+			die(err, "pthread_create");
+	}
+
+	if (signal(SIGALRM, alarm_handler) == SIG_ERR)
+		die(errno, "signal");
+
+	alarm(TIMEOUT);
+
+	while (!timed_out) {
+		if (mkdir(DIR_NAME, 0777) != 0)
+			die(errno, "mkdir");
+		if (stat(FILE_NAME, &stbuf) == 0)
+			die(0, "stat should have failed");
+		if (errno != ENOENT)
+			die(errno, "stat");
+		if (rmdir(DIR_NAME) != 0)
+			die(errno, "rmdir");
+	}
+
+	printf("t_encrypted_d_revalidate finished\n");
+	return 0;
+}
diff --git a/tests/generic/600 b/tests/generic/600
new file mode 100755
index 00000000..135f9f29
--- /dev/null
+++ b/tests/generic/600
@@ -0,0 +1,154 @@
+#! /bin/bash
+# FS QA Test generic/600
+#
+# Test that encrypted dentries are revalidated after adding a key.
+# Regression test for:
+#	28b4c263961c ("ext4 crypto: revalidate dentry after adding or removing the key")
+#
+# Furthermore, test that encrypted directories are *not* revalidated after
+# "revoking" a key.  This used to be done, but it was broken and was removed by:
+#	1b53cf9815bb ("fscrypt: remove broken support for detecting keyring key revocation")
+#
+# Also test for a race condition bug in 28b4c263961c, fixed by:
+#	03a8bb0e53d9 ("ext4/fscrypto: avoid RCU lookup in d_revalidate")
+#
+# Note: the following fix for another race in 28b4c263961c should be applied as
+# well, though we don't test for it because it's very difficult to reproduce:
+#	3d43bcfef5f0 ("ext4 crypto: use dget_parent() in ext4_d_revalidate()")
+#
+#-----------------------------------------------------------------------
+# Copyright (c) 2017 Google, Inc.  All Rights Reserved.
+#
+# Author: Eric Biggers <ebiggers@google.com>
+#
+# This program is free software; you can redistribute it and/or
+# modify it under the terms of the GNU General Public License as
+# published by the Free Software Foundation.
+#
+# This program is distributed in the hope that it would be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write the Free Software Foundation,
+# Inc.,  51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+#-----------------------------------------------------------------------
+#
+
+seq=`basename $0`
+seqres=$RESULT_DIR/$seq
+echo "QA output created by $seq"
+
+here=`pwd`
+tmp=/tmp/$$
+status=1	# failure is the default!
+trap "_cleanup; exit \$status" 0 1 2 3 15
+
+_cleanup()
+{
+	cd /
+	rm -f $tmp.*
+}
+
+# get standard environment, filters and checks
+. ./common/rc
+. ./common/filter
+. ./common/encrypt
+
+# remove previous $seqres.full before test
+rm -f $seqres.full
+
+# real QA test starts here
+_supported_fs generic
+_supported_os Linux
+_require_scratch_encryption
+_require_xfs_io_command "set_encpolicy"
+_require_command "$KEYCTL_PROG" keyctl
+_require_test_program "t_encrypted_d_revalidate"
+
+# Set up an encrypted directory
+_scratch_mkfs_encrypted &>> $seqres.full
+_scratch_mount
+_new_session_keyring
+keydesc=$(_generate_key_descriptor)
+raw_key=$(_generate_raw_encryption_key)
+mkdir $SCRATCH_MNT/edir
+_add_encryption_key $keydesc $raw_key
+$XFS_IO_PROG -c "set_encpolicy $keydesc" $SCRATCH_MNT/edir
+
+# Create two files in the directory: one whose name is valid in the base64
+# format used for encoding ciphertext filenames, and one whose name is not.  The
+# exact filenames *should* be irrelevant, but due to yet another bug, ->lookup()
+# in an encrypted directory without the key returned ERR_PTR(-ENOENT) rather
+# than NULL if the name was not valid ciphertext, causing a negative dentry to
+# not be created.  For the purpose of this test, we want at least one negative
+# dentry to be created, so just create both types of name.
+echo contents_@@@ > $SCRATCH_MNT/edir/@@@ # not valid base64
+echo contents_abcd > $SCRATCH_MNT/edir/abcd # valid base64
+
+_filter_ciphertext_filenames()
+{
+	_filter_scratch | sed 's|edir/[a-zA-Z0-9+,_]\+|edir/ENCRYPTED_NAME|g'
+}
+
+_show_file_contents()
+{
+	echo "--- Contents of files using plaintext names:"
+	cat $SCRATCH_MNT/edir/@@@ |& _filter_scratch
+	cat $SCRATCH_MNT/edir/abcd |& _filter_scratch
+	echo "--- Contents of files using ciphertext names:"
+	cat ${ciphertext_names[@]} |& _filter_ciphertext_filenames
+}
+
+_show_directory_with_key()
+{
+	echo "--- Directory listing:"
+	find $SCRATCH_MNT/edir -mindepth 1 | sort | _filter_scratch
+	_show_file_contents
+}
+
+# View the directory without the encryption key.  The plaintext names shouldn't
+# exist, but 'cat' each to verify this, which also should create negative
+# dentries.  The ciphertext names are unpredictable by design, but verify that
+# the correct number of them are listed by readdir, and save them for later.
+echo
+echo "***** Without encryption key *****"
+_unlink_encryption_key $keydesc
+_scratch_cycle_mount
+echo "--- Directory listing:"
+ciphertext_names=( $(find $SCRATCH_MNT/edir -mindepth 1 | sort) )
+printf '%s\n' "${ciphertext_names[@]}" | _filter_ciphertext_filenames
+_show_file_contents
+
+# Without remounting or dropping caches, add the encryption key and view the
+# directory again.  Now the plaintext names should all be there, and the
+# ciphertext names should be gone.  Make sure to 'cat' all the names to test for
+# stale dentries.
+echo
+echo "***** With encryption key *****"
+_add_encryption_key $keydesc $raw_key
+_show_directory_with_key
+
+# Test for ->d_revalidate() race conditions.
+echo
+echo "***** Race conditions *****"
+$here/src/t_encrypted_d_revalidate $SCRATCH_MNT/edir
+rm -rf $SCRATCH_MNT/edir/dir
+
+# Now open the files to pin them in the inode cache (needed to make the test
+# reliable), then revoke the encryption key.  This should no longer cause the
+# files to be presented in ciphertext form immediately.
+echo
+echo "***** After key revocation *****"
+(
+	exec 3<$SCRATCH_MNT/edir
+	exec 4<$SCRATCH_MNT/edir/@@@
+	exec 5<$SCRATCH_MNT/edir/abcd
+	_revoke_encryption_key $keydesc
+	_show_directory_with_key
+)
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/600.out b/tests/generic/600.out
new file mode 100644
index 00000000..34bf6aab
--- /dev/null
+++ b/tests/generic/600.out
@@ -0,0 +1,37 @@
+QA output created by 600
+
+***** Without encryption key *****
+--- Directory listing:
+SCRATCH_MNT/edir/ENCRYPTED_NAME
+SCRATCH_MNT/edir/ENCRYPTED_NAME
+--- Contents of files using plaintext names:
+cat: SCRATCH_MNT/edir/@@@: No such file or directory
+cat: SCRATCH_MNT/edir/abcd: No such file or directory
+--- Contents of files using ciphertext names:
+cat: SCRATCH_MNT/edir/ENCRYPTED_NAME: Required key not available
+cat: SCRATCH_MNT/edir/ENCRYPTED_NAME: Required key not available
+
+***** With encryption key *****
+--- Directory listing:
+SCRATCH_MNT/edir/@@@
+SCRATCH_MNT/edir/abcd
+--- Contents of files using plaintext names:
+contents_@@@
+contents_abcd
+--- Contents of files using ciphertext names:
+cat: SCRATCH_MNT/edir/ENCRYPTED_NAME: No such file or directory
+cat: SCRATCH_MNT/edir/ENCRYPTED_NAME: No such file or directory
+
+***** Race conditions *****
+t_encrypted_d_revalidate finished
+
+***** After key revocation *****
+--- Directory listing:
+SCRATCH_MNT/edir/@@@
+SCRATCH_MNT/edir/abcd
+--- Contents of files using plaintext names:
+contents_@@@
+contents_abcd
+--- Contents of files using ciphertext names:
+cat: SCRATCH_MNT/edir/ENCRYPTED_NAME: No such file or directory
+cat: SCRATCH_MNT/edir/ENCRYPTED_NAME: No such file or directory
diff --git a/tests/generic/group b/tests/generic/group
index b3051752..edfc99a6 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -431,3 +431,4 @@
 426 auto quick exportfs
 427 auto quick aio rw
 428 auto quick
+600 auto encrypt
-- 
2.13.0.rc1.294.g07d810a77f-goog
