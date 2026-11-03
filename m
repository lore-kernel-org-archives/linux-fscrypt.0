Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.97
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793722177;
	b=zdZVAWbHHxKbbXx3xH+E3M8dbt8nsEmnmWY0qiTHnT/2Mr0wIx5oj8esGJ2V1yK6UMQU
	 NInJ1GjHsbeqlJUU9D2n1HEeOMOsl4nuaWyhIrG58aNjqP1kX3yMOnPq3tsTMitb+2pFO
	 /7Y4KvfumLzfSlfj3vbGfNE6KQwKsRCVfozsVI/Io+OPdoVATFU79vJA7U9Wb670Yt2pm
	 q3FPK4EX94YzSxaV3znO3AmTSr1DDEYDXwxeQSlDMB1EXm5BI2gyy9/w+FSRr0jqRU8FL
	 7XzKV7RUGQFLuSNpkqoJJdM/Jl4A18R+rilicnjFyh7sG3Rh+huJTVXZsFFQcFcG58g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793722177;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=VvejGUVxmaiLNVk+Kiil53rHji7qg0RpKsHyxlR2IsQ=;
	b=daKmjMfA1opgH3X/UkG+IJl7//CK6vvoITs60jlJP/OWne4faq8+uvlIzhk/lVGHDwSM
	 FbyahgKKKDFCIKKlFixyDk2KPQciE57R4SejB06uQwR2rPuRB04WBZWft4YeQvM6D4JLw
	 7YNY0LHQQgQ7XC4L5JJ0ziqyfso7Xvq1e5m/YT//a4gQ+bcgsY3dvA08kJBjnKkrMshWR
	 bAU9to6q4BhXZQFo2QwCZvKdwCAvvYjd4C1r1Ir0qxb/h1TiNAQHDxxlXsI5TgHuHQKCG
	 Vut76CmReyMYow5BrFEy9g8L0srCqOD0ZbL7cTqInArAnLG8Lpidv4tBt4ygN3Et78g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b="Afl9tf/y";
	arc=none smtp.remote-ip=115.124.30.97
Received: from out30-97.freemail.mail.aliyun.com (out30-97.freemail.mail.aliyun.com [115.124.30.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA008606A328;
	Tue,  3 Nov 2026 16:09:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EA008606A328
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=Afl9tf/y
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1793722171; h=From:To:Subject:Date:Message-ID:MIME-Version;
	bh=VvejGUVxmaiLNVk+Kiil53rHji7qg0RpKsHyxlR2IsQ=;
	b=Afl9tf/y/rlR81qOGBfINq+CjMEXL1YvQfYVoJAl4jpgWq49/J6gsSVPyDPhUmiRlj57BfwPMq+SwS+9jWODMtuE3nVco0RzoHz12GEUZmlB9At+N7ak5jcz3o1a8BPDasOS7qqMZiIUJ5ufjwFXnBlnPFi4I14t/n8nK7ROVOg=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R651e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045133197;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0XE3LcOt_1793722147;
Received: from x31h02109.sqa.na131.tbsite.net(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XE3LcOt_1793722147 cluster:ay36)
          by smtp.aliyun-inc.com;
          Wed, 04 Nov 2026 00:09:30 +0800
From: Baokun Li <libaokun@linux.alibaba.com>
To: fstests@vger.kernel.org
Cc: zlang@kernel.org,
	linux-fscrypt@vger.kernel.org,
	ebiggers@kernel.org,
	jaegeuk@kernel.org,
	tytso@mit.edu,
	linux-ext4@vger.kernel.org,
	adilger.kernel@dilger.ca,
	jack@suse.cz,
	yi.zhang@huawei.com,
	ojaswin@linux.ibm.com,
	ritesh.list@gmail.com,
	linux-kernel@vger.kernel.org
Subject: [PATCH] common/encrypt: support block sizes larger than the page size
Date: Wed,  4 Nov 2026 00:09:06 +0800
Message-ID: <20261103160906.188544-1-libaokun@linux.alibaba.com>
X-Mailer: git-send-email 2.43.7
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

v1 encryption policies use the filesystem block size as their data unit
size, so they cannot be used on a filesystem whose block size exceeds
the page size.  Make _require_scratch_encryption() skip such tests
when a v1 policy is requested.  Tests that request a v2 policy but
also exercise v1 policies, i.e. generic/580, 581, 593, and 613,
call _require_v1_encryption_support() explicitly.

A v2 policy with log2_data_unit_size 0 uses min(bs, PS) as its data
unit size, not the block size. Add _get_encryption_du_size() and
use it to calculate the expected ciphertext.

Also skip the v1 policy probe in _require_scratch_encryption() when a
v2 policy is requested.  Update the ext4/309 and ext4/310 comments for
the new default data unit size.

Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
---
 common/encrypt    | 68 +++++++++++++++++++++++++++++++++++++++--------
 tests/ext4/309    |  6 ++---
 tests/ext4/310    |  2 +-
 tests/generic/580 |  1 +
 tests/generic/581 |  1 +
 tests/generic/593 |  1 +
 tests/generic/613 |  1 +
 7 files changed, 65 insertions(+), 15 deletions(-)

diff --git a/common/encrypt b/common/encrypt
index c9e0853d8d8c..feaef0682a44 100644
--- a/common/encrypt
+++ b/common/encrypt
@@ -18,15 +18,21 @@
 _require_scratch_encryption()
 {
 	local arg
+	local policy_version=1
+	local prev=
 
 	_require_scratch
 	_require_xfs_io_command "set_encpolicy"
 
 	for arg; do
+		if [ "$prev" = "-v" ]; then
+			policy_version=$arg
+		fi
 		if [ "$arg" = "-s" ]; then
 			# -s option was added later.  Make sure it's available.
 			_require_xfs_io_command "set_encpolicy" "-s"
 		fi
+		prev=$arg
 	done
 
 	# The 'test_dummy_encryption' mount option interferes with trying to use
@@ -56,13 +62,24 @@ _require_scratch_encryption()
 	# to set an encryption policy.  (For ext4 we could instead check for the
 	# presence of /sys/fs/ext4/features/encryption, but this is broken on
 	# some older kernels and is ext4-specific anyway.)
-	mkdir $SCRATCH_MNT/tmpdir
-	if _set_encpolicy $SCRATCH_MNT/tmpdir 2>&1 >>$seqres.full | \
-		grep -Eq 'Inappropriate ioctl for device|Operation not supported'
-	then
-		_notrun "kernel does not support $FSTYP encryption"
+	#
+	# If the test requires a v2 policy, don't probe with a v1 policy:
+	# v1 policies are not supported when the block size exceeds the page
+	# size.  _require_encryption_policy_support() will check for the
+	# requested policy version below.
+	if [ "$policy_version" -le 1 ]; then
+		mkdir $SCRATCH_MNT/tmpdir
+		if _set_encpolicy $SCRATCH_MNT/tmpdir 2>&1 >>$seqres.full | \
+			grep -Eq 'Inappropriate ioctl for device|Operation not supported'
+		then
+			_notrun "kernel does not support $FSTYP encryption"
+		fi
+		rmdir $SCRATCH_MNT/tmpdir
+
+		# v1 policies use the block size as their data unit size,
+		# which doesn't work if the block size exceeds the page size.
+		_require_v1_encryption_support
 	fi
-	rmdir $SCRATCH_MNT/tmpdir
 
 	# If required, check for support for the specific type of encryption
 	# policy required by the test.
@@ -73,6 +90,39 @@ _require_scratch_encryption()
 	_scratch_unmount
 }
 
+# Require that the filesystem supports v1 encryption policies.  v1
+# policies use the filesystem block size as their data unit size, so
+# they aren't supported when the block size exceeds the page size.
+#
+# The scratch filesystem must be mounted.
+_require_v1_encryption_support()
+{
+	local block_size=$(_get_block_size $SCRATCH_MNT)
+
+	if [ "$block_size" -gt "$(_get_page_size)" ]; then
+		_notrun "v1 encryption policies aren't supported on filesystems with block size > page size"
+	fi
+}
+
+# Get the data unit size in bytes for a v2 encryption policy with the
+# given log2_data_unit_size on the filesystem mounted at $1.  A zero
+# value selects min(filesystem block size, page size).
+_get_encryption_du_size()
+{
+	local mnt=$1
+	local log2_dusize=$2
+	local block_size=$(_get_block_size "$mnt")
+	local page_size=$(_get_page_size)
+
+	if [ "$log2_dusize" -ne 0 ]; then
+		echo $((1 << log2_dusize))
+	elif [ "$block_size" -gt "$page_size" ]; then
+		echo "$page_size"
+	else
+		echo "$block_size"
+	fi
+}
+
 _require_encryption_policy_support()
 {
 	local mnt=$1
@@ -1014,11 +1064,7 @@ _verify_ciphertext_for_encryption_policy()
 	fi
 	_scratch_mount
 
-	if (( log2_dusize != 0 )); then
-		crypt_util_contents_args+=" --data-unit-size=$((1 << log2_dusize))"
-	else
-		crypt_util_contents_args+=" --data-unit-size=$(_get_block_size $SCRATCH_MNT)"
-	fi
+	crypt_util_contents_args+=" --data-unit-size=$(_get_encryption_du_size $SCRATCH_MNT $log2_dusize)"
 
 	crypt_util_args+=" --fs-uuid=$(blkid -s UUID -o value $SCRATCH_DEV | tr -d -)"
 
diff --git a/tests/ext4/309 b/tests/ext4/309
index 6bc9b8cb4a4a..aa1b3b68fc8c 100755
--- a/tests/ext4/309
+++ b/tests/ext4/309
@@ -5,9 +5,9 @@
 # FS QA Test No. ext4/309
 #
 # Verify that file contents encryption works on a filesystem with a block size
-# larger than the page size.  fscrypt uses the block size as the data unit size
-# by default, so this tests data units that span multiple pages, both for the
-# writeback path and for the on-disk ciphertext.
+# larger than the page size.  fscrypt uses min(block size, page size) as the
+# default data unit size, so this tests 4K data units on a 32K-block
+# filesystem, both for the writeback path and for the on-disk ciphertext.
 #
 . ./common/preamble
 _begin_fstest auto quick encrypt
diff --git a/tests/ext4/310 b/tests/ext4/310
index 215d3a83cd6d..84473930f8cb 100755
--- a/tests/ext4/310
+++ b/tests/ext4/310
@@ -6,7 +6,7 @@
 #
 # Test reading and writing an encrypted file with O_DIRECT on a filesystem
 # with a block size larger than the page size.  The data unit size is the
-# block size by default, so each data unit spans several pages here.
+# page size by default on such a filesystem.
 #
 . ./common/preamble
 _begin_fstest auto quick encrypt
diff --git a/tests/generic/580 b/tests/generic/580
index eff3f2104bfe..bcb984d1fd82 100755
--- a/tests/generic/580
+++ b/tests/generic/580
@@ -20,6 +20,7 @@ _require_scratch_encryption -v 2
 
 _scratch_mkfs_encrypted &>> $seqres.full
 _scratch_mount
+_require_v1_encryption_support
 
 test_with_policy_version()
 {
diff --git a/tests/generic/581 b/tests/generic/581
index 2773c9108b35..54f31595a832 100755
--- a/tests/generic/581
+++ b/tests/generic/581
@@ -33,6 +33,7 @@ _require_scratch_encryption -v 2
 
 _scratch_mkfs_encrypted &>> $seqres.full
 _scratch_mount
+_require_v1_encryption_support
 
 dir=$SCRATCH_MNT/dir
 
diff --git a/tests/generic/593 b/tests/generic/593
index 05f868f92422..61976df8194d 100755
--- a/tests/generic/593
+++ b/tests/generic/593
@@ -21,6 +21,7 @@ _require_command "$KEYCTL_PROG" keyctl
 _init_session_keyring
 _scratch_mkfs_encrypted &>> $seqres.full
 _scratch_mount
+_require_v1_encryption_support
 _require_add_enckey_by_key_id $SCRATCH_MNT
 
 test_with_policy_version()
diff --git a/tests/generic/613 b/tests/generic/613
index 499af18ef476..aadb3893e73e 100755
--- a/tests/generic/613
+++ b/tests/generic/613
@@ -26,6 +26,7 @@ _require_command "$XZ_PROG" xz
 
 _scratch_mkfs_encrypted &>> $seqres.full
 _scratch_mount
+_require_v1_encryption_support
 
 echo -e "\n# Adding encryption keys"
 _add_enckey $SCRATCH_MNT "$TEST_RAW_KEY"
-- 
2.43.7

