Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:52224 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726843AbfCOAH4 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 14 Mar 2019 20:07:56 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] generic/398: accept EXDEV for rename or link into encrypted dir
Date: Thu, 14 Mar 2019 17:05:47 -0700
Message-Id: <20190315000547.179665-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Update generic/398 to pass after kernel commit f5e55e777cc9 ("fscrypt:
return -EXDEV for incompatible rename or link into encrypted dir"),
which intentionally changed some error codes from EPERM to EXDEV in
order to allow standard tools like 'mv' to move files into an encrypted
directory.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/398     | 69 +++++++++++++++++++++++++------------------
 tests/generic/398.out | 22 ++++++--------
 2 files changed, 49 insertions(+), 42 deletions(-)

diff --git a/tests/generic/398 b/tests/generic/398
index efb8348c..ecf82690 100755
--- a/tests/generic/398
+++ b/tests/generic/398
@@ -7,9 +7,9 @@
 # Filesystem encryption is designed to enforce that a consistent encryption
 # policy is used within a given encrypted directory tree and that an encrypted
 # directory tree does not contain any unencrypted files.  This test verifies
-# that filesystem operations that would violate this constraint fail with EPERM.
-# This does not test enforcement of this constraint on lookup, which is still
-# needed to detect offline changes.
+# that filesystem operations that would violate this constraint fail.  This does
+# not test enforcement of this constraint on lookup, which is still needed to
+# detect offline changes.
 #
 seq=`basename $0`
 seqres=$RESULT_DIR/$seq
@@ -26,10 +26,21 @@ _cleanup()
 	rm -f $tmp.*
 }
 
-filter_enokey()
+# The error code for incompatible rename or link into an encrypted directory was
+# changed from EPERM to EXDEV in Linux v5.1, to allow tools like 'mv' to work.
+# See kernel commit f5e55e777cc9 ("fscrypt: return -EXDEV for incompatible
+# rename or link into encrypted dir").  Accept both errors for now.
+filter_eperm_to_exdev()
 {
-	# rename without key can also fail with EPERM instead of ENOKEY
-	sed -e "s/Required key not available/Operation not permitted/g"
+	sed -e 's/Operation not permitted/Invalid cross-device link/'
+}
+
+# The error code for incompatible cross-rename without the key has been ENOKEY
+# on all filesystems since Linux v4.16.  Previously it was EPERM on some
+# filesystems.  Accept both errors for now.
+filter_eperm_to_enokey()
+{
+	sed -e 's/Operation not permitted/Required key not available/'
 }
 
 # get standard environment, filters and checks
@@ -67,27 +78,27 @@ touch $edir2/efile2
 touch $udir/ufile
 
 
-# Test linking and moving an encrypted file into an encrypted directory with a
-# different encryption policy.  Should fail with EPERM.
+# Test linking and renaming an encrypted file into an encrypted directory with a
+# different encryption policy.  Should fail with EXDEV.
 
 echo -e "\n*** Link encrypted <= encrypted ***"
-ln $edir1/efile1 $edir2/efile1 |& _filter_scratch
+ln $edir1/efile1 $edir2/efile1 |& _filter_scratch | filter_eperm_to_exdev
 
 echo -e "\n*** Rename encrypted => encrypted ***"
-mv $edir1/efile1 $edir2/efile1 |& _filter_scratch
+src/renameat2 $edir1/efile1 $edir2/efile1 |& filter_eperm_to_exdev
 
 
-# Test linking and moving an unencrypted file into an encrypted directory.
-# Should fail with EPERM.
+# Test linking and renaming an unencrypted file into an encrypted directory.
+# Should fail with EXDEV.
 
 echo -e "\n\n*** Link unencrypted <= encrypted ***"
-ln $udir/ufile $edir1/ufile |& _filter_scratch
+ln $udir/ufile $edir1/ufile |& _filter_scratch | filter_eperm_to_exdev
 
 echo -e "\n*** Rename unencrypted => encrypted ***"
-mv $udir/ufile $edir1/ufile |& _filter_scratch
+src/renameat2 $udir/ufile $edir1/ufile |& filter_eperm_to_exdev
 
 
-# Test linking and moving an encrypted file into an unencrypted directory.
+# Test linking and renaming an encrypted file into an unencrypted directory.
 # Should succeed.
 
 echo -e "\n\n*** Link encrypted <= unencrypted ***"
@@ -95,33 +106,33 @@ ln -v $edir1/efile1 $udir/efile1 |& _filter_scratch
 rm $udir/efile1 # undo
 
 echo -e "\n*** Rename encrypted => unencrypted ***"
-mv -v $edir1/efile1 $udir/efile1 |& _filter_scratch |& _filter_mv
-mv $udir/efile1 $edir1/efile1 # undo
+src/renameat2 $edir1/efile1 $udir/efile1
+src/renameat2 $udir/efile1 $edir1/efile1 # undo
 
 
-# Test moving a forbidden (unencrypted, or encrypted with a different encryption
-# policy) file into an encrypted directory via an exchange (cross rename)
-# operation.  Should fail with EPERM.
+# Test renaming a forbidden (unencrypted, or encrypted with a different
+# encryption policy) file into an encrypted directory via an exchange (cross
+# rename) operation.  Should fail with EXDEV.
 
 echo -e "\n\n*** Exchange encrypted <=> encrypted ***"
-src/renameat2 -x $edir1/efile1 $edir2/efile2 |& _filter_scratch
+src/renameat2 -x $edir1/efile1 $edir2/efile2 |& filter_eperm_to_exdev
 
 echo -e "\n*** Exchange unencrypted <=> encrypted ***"
-src/renameat2 -x $udir/ufile $edir1/efile1 |& _filter_scratch
+src/renameat2 -x $udir/ufile $edir1/efile1 |& filter_eperm_to_exdev
 
 echo -e "\n*** Exchange encrypted <=> unencrypted ***"
-src/renameat2 -x $edir1/efile1 $udir/ufile |& _filter_scratch
+src/renameat2 -x $edir1/efile1 $udir/ufile |& filter_eperm_to_exdev
 
 
 # Test a file with a special type, i.e. not regular, directory, or symlink.
 # Since such files are not subject to encryption, there should be no
-# restrictions on linking or moving them into encrypted directories.
+# restrictions on linking or renaming them into encrypted directories.
 
 echo -e "\n\n*** Special file tests ***"
 mkfifo $edir1/fifo
-mv -v $edir1/fifo $edir2/fifo | _filter_scratch |& _filter_mv
-mv -v $edir2/fifo $udir/fifo | _filter_scratch |& _filter_mv
-mv -v $udir/fifo $edir1/fifo | _filter_scratch |& _filter_mv
+src/renameat2 $edir1/fifo $edir2/fifo
+src/renameat2 $edir2/fifo $udir/fifo
+src/renameat2 $udir/fifo $edir1/fifo
 mkfifo $udir/fifo
 src/renameat2 -x $udir/fifo $edir1/fifo
 ln -v $edir1/fifo $edir2/fifo | _filter_scratch
@@ -138,9 +149,9 @@ efile1=$(find $edir1 -type f)
 efile2=$(find $edir2 -type f)
 
 echo -e "\n\n*** Exchange encrypted <=> encrypted without key ***"
-src/renameat2 -x $efile1 $efile2 |& filter_enokey
+src/renameat2 -x $efile1 $efile2 |& filter_eperm_to_enokey
 echo -e "\n*** Exchange encrypted <=> unencrypted without key ***"
-src/renameat2 -x $efile1 $udir/ufile |& filter_enokey
+src/renameat2 -x $efile1 $udir/ufile |& filter_eperm_to_enokey
 
 # success, all done
 status=0
diff --git a/tests/generic/398.out b/tests/generic/398.out
index f9274878..e8caefe4 100644
--- a/tests/generic/398.out
+++ b/tests/generic/398.out
@@ -1,45 +1,41 @@
 QA output created by 398
 
 *** Link encrypted <= encrypted ***
-ln: failed to create hard link 'SCRATCH_MNT/edir2/efile1' => 'SCRATCH_MNT/edir1/efile1': Operation not permitted
+ln: failed to create hard link 'SCRATCH_MNT/edir2/efile1' => 'SCRATCH_MNT/edir1/efile1': Invalid cross-device link
 
 *** Rename encrypted => encrypted ***
-mv: cannot move 'SCRATCH_MNT/edir1/efile1' to 'SCRATCH_MNT/edir2/efile1': Operation not permitted
+Invalid cross-device link
 
 
 *** Link unencrypted <= encrypted ***
-ln: failed to create hard link 'SCRATCH_MNT/edir1/ufile' => 'SCRATCH_MNT/udir/ufile': Operation not permitted
+ln: failed to create hard link 'SCRATCH_MNT/edir1/ufile' => 'SCRATCH_MNT/udir/ufile': Invalid cross-device link
 
 *** Rename unencrypted => encrypted ***
-mv: cannot move 'SCRATCH_MNT/udir/ufile' to 'SCRATCH_MNT/edir1/ufile': Operation not permitted
+Invalid cross-device link
 
 
 *** Link encrypted <= unencrypted ***
 'SCRATCH_MNT/udir/efile1' => 'SCRATCH_MNT/edir1/efile1'
 
 *** Rename encrypted => unencrypted ***
-'SCRATCH_MNT/edir1/efile1' -> 'SCRATCH_MNT/udir/efile1'
 
 
 *** Exchange encrypted <=> encrypted ***
-Operation not permitted
+Invalid cross-device link
 
 *** Exchange unencrypted <=> encrypted ***
-Operation not permitted
+Invalid cross-device link
 
 *** Exchange encrypted <=> unencrypted ***
-Operation not permitted
+Invalid cross-device link
 
 
 *** Special file tests ***
-'SCRATCH_MNT/edir1/fifo' -> 'SCRATCH_MNT/edir2/fifo'
-'SCRATCH_MNT/edir2/fifo' -> 'SCRATCH_MNT/udir/fifo'
-'SCRATCH_MNT/udir/fifo' -> 'SCRATCH_MNT/edir1/fifo'
 'SCRATCH_MNT/edir2/fifo' => 'SCRATCH_MNT/edir1/fifo'
 
 
 *** Exchange encrypted <=> encrypted without key ***
-Operation not permitted
+Required key not available
 
 *** Exchange encrypted <=> unencrypted without key ***
-Operation not permitted
+Required key not available
-- 
2.21.0.360.g471c308f928-goog
