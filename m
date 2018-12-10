Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53526 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726024AbeLJWZu (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 10 Dec 2018 17:25:50 -0500
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 4/7] generic: test fs-verity descriptor validation
Date: Mon, 10 Dec 2018 14:21:39 -0800
Message-Id: <20181210222142.222342-5-ebiggers@kernel.org>
In-Reply-To: <20181210222142.222342-1-ebiggers@kernel.org>
References: <20181210222142.222342-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-fscrypt-owner@vger.kernel.org
To: fstests@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

This test tries corrupting various fields in the fsverity_descriptor and
verifies that this causes FS_IOC_ENABLE_VERITY to fail.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 tests/generic/902     | 323 ++++++++++++++++++++++++++++++++++++++++++
 tests/generic/902.out | 125 ++++++++++++++++
 tests/generic/group   |   1 +
 3 files changed, 449 insertions(+)
 create mode 100755 tests/generic/902
 create mode 100644 tests/generic/902.out

diff --git a/tests/generic/902 b/tests/generic/902
new file mode 100755
index 00000000..3cb5847b
--- /dev/null
+++ b/tests/generic/902
@@ -0,0 +1,323 @@
+#! /bin/bash
+# SPDX-License-Identifier: GPL-2.0
+# Copyright 2018 Google LLC
+#
+# FS QA Test generic/902
+#
+# Test fs-verity descriptor validation.  This test tries corrupting various
+# fields in the fsverity_descriptor and verifies that this causes
+# FS_IOC_ENABLE_VERITY to fail.
+#
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
+. ./common/verity
+
+# remove previous $seqres.full before test
+rm -f $seqres.full
+
+# real QA test starts here
+_supported_fs generic
+_supported_os Linux
+_require_scratch_verity
+
+_scratch_mkfs_verity &>> $seqres.full
+_scratch_mount
+fsv_orig_file=$SCRATCH_MNT/file
+fsv_file=$SCRATCH_MNT/file.fsv
+
+# Serialize an integer into a little endian hex bytestring of the given length,
+# e.g. `num_to_hex 1000 4` == "\xe8\x03\x00\x00"
+num_to_hex()
+{
+	local value=$1
+	local nbytes=$2
+	local i
+
+	for (( i = 0; i < nbytes; i++, value >>= 8 )); do
+		printf '\\x%02x' $((value & 0xff))
+	done
+}
+
+# Number of bytes in a hex bytestring, e.g. `hexstr_len "\xe8\x03"` == 2
+hexstr_len()
+{
+	echo -n -e "$1" | wc -c
+}
+
+# Get a file's SHA-256 digest as a hex bytestring for "echo -e"
+do_sha256sum()
+{
+	sha256sum "$@" | awk '{print $1}' | sed 's/../\\x\0/g'
+}
+
+# Append a field to 'str', allowing override commands.  See make_test_file().
+do_add_field()
+{
+	local fixed_length=$1
+	local -n str=$2
+	local fieldname=$3
+	local default_val=$4
+	shift 4
+	local cmds=("$@")
+	local cmd
+	local val="$default_val"
+
+	for cmd in "${cmds[@]}"; do
+		if [ $(echo "$cmd" | cut -d' ' -f1) = $fieldname ]; then
+			val=$(echo "$cmd" | sed "s/^$fieldname *//")
+			if $fixed_length && \
+			  [ $(hexstr_len "$val") != $(hexstr_len "$default_val") ]
+			then
+				_fail "wrong value length in '$cmd'"
+			fi
+			break
+		fi
+	done
+	str+="$val"
+}
+
+add_field()
+{
+	do_add_field true "$@"
+}
+
+add_varfield()
+{
+	do_add_field false "$@"
+}
+
+FS_VERITY_EXT_ROOT_HASH=1
+FS_VERITY_EXT_SALT=2
+FS_VERITY_EXT_PKCS7_SIGNATURE=3
+FS_VERITY_EXT_ELIDE=4
+FS_VERITY_EXT_PATCH=5
+
+EXTHDR_SIZE=8
+
+# Create an extension header (struct fsverity_extension)
+create_exthdr()
+{
+	local length=$1
+	local type=$2
+	if [ $# -ge 3 ]; then
+		local reserved=$3
+	else
+		local reserved=0
+	fi
+
+	num_to_hex $length 4
+	num_to_hex $type 2
+	num_to_hex $reserved 2
+}
+
+# Create an extension item, given the type and payload
+create_ext()
+{
+	local type=$1
+	local payload=$2
+	local payload_size=$(hexstr_len "$payload")
+
+	create_exthdr $(( EXTHDR_SIZE + payload_size )) $type
+	echo -n "$payload"
+	num_to_hex 0 $(( -payload_size & 7 ))
+}
+
+# Create a ROOT_HASH extension item
+create_root_hash_ext()
+{
+	local root_hash=$1
+
+	create_ext $FS_VERITY_EXT_ROOT_HASH "$root_hash"
+}
+
+DEFAULT_AUTH_EXT_COUNT=1	# root hash
+DEFAULT_UNAUTH_EXT_COUNT=0	# none
+
+#
+# Generate a file and append fs-verity metadata to it, allowing metadata fields
+# to be overridden.  The overrides are given as command strings in the format
+# "$field $value".  E.g., "major_version \x01" sets the major_version field to
+# the byte \x01 (binary 1, not ASCII 1).  For fixed-length fields (add_field())
+# the override must be the same length as the default value; for variable-length
+# fields (add_varfield()) the override can be any length.
+#
+make_test_file()
+{
+	local cmds=("$@")
+	local out=""
+
+	# 8 KiB file
+	head -c 8192 /dev/urandom > $fsv_orig_file
+	cp $fsv_orig_file $fsv_file
+
+	# Generate the Merkle tree.. there are just 2 data blocks, so it's easy.
+	local hash1=$(head -c 4096 $fsv_file | do_sha256sum)
+	local hash2=$(tail -c 4096 $fsv_file | do_sha256sum)
+	echo -n -e "$hash1" >> $fsv_file
+	echo -n -e "$hash2" >> $fsv_file
+	head -c $((4096 - (32*2))) /dev/zero >> $fsv_file
+	local root_hash=$(tail -c 4096 $fsv_file | do_sha256sum)
+
+	# Append the 'struct fsverity_descriptor'
+	add_field out magic "FSVerity" "${cmds[@]}"
+	add_field out major_version "\x01" "${cmds[@]}"
+	add_field out minor_version "\x00" "${cmds[@]}"
+	add_field out log_data_blocksize "$(num_to_hex 12 1)" "${cmds[@]}" # 4K block size
+	add_field out log_tree_blocksize "$(num_to_hex 12 1)" "${cmds[@]}"
+	add_field out data_algorithm "$(num_to_hex 1 2)" "${cmds[@]}" # SHA-256
+	add_field out tree_algorithm "$(num_to_hex 1 2)" "${cmds[@]}"
+	add_field out flags "$(num_to_hex 0 4)" "${cmds[@]}"
+	add_field out reserved1 "$(num_to_hex 0 4)" "${cmds[@]}"
+	add_field out orig_file_size "$(num_to_hex 8192 8)" "${cmds[@]}"
+	add_field out auth_ext_count "$(num_to_hex $DEFAULT_AUTH_EXT_COUNT 2)" "${cmds[@]}"
+	add_field out reserved2 "$(num_to_hex 0 30)" "${cmds[@]}"
+
+	# Append the authenticated extensions (default: just the root hash)
+	add_varfield out root_hash "$(create_root_hash_ext "$root_hash")" "${cmds[@]}"
+	add_varfield out auth_extensions "" "${cmds[@]}"
+
+	# Append the unauthenticated extensions (default: none)
+	add_field out unauth_ext_count "$(num_to_hex $DEFAULT_UNAUTH_EXT_COUNT 2)" "${cmds[@]}"
+	add_field out unauth_ext_count_padding "$(num_to_hex 0 6)" "${cmds[@]}"
+	add_varfield out unauth_extensions "" "${cmds[@]}"
+
+	# No gap before the footer by default
+	add_varfield out gap_before_footer "" "${cmds[@]}"
+
+	# Append the footer
+	local desc_reverse_offset=$((12 + $(hexstr_len "$out") ))
+	add_field out desc_reverse_offset "$(num_to_hex $desc_reverse_offset 4)" "${cmds[@]}"
+	add_field out ftr_magic "FSVerity" "${cmds[@]}"
+
+	echo -n -e "$out" >> $fsv_file
+}
+
+desc_test()
+{
+	local description=$1
+	shift
+	local cmds=("$@")
+
+	_fsv_begin_subtest "$description"
+	make_test_file "${cmds[@]}"
+	{
+		if _fsv_enable $fsv_file; then
+			cmp $fsv_file $fsv_orig_file
+		fi
+	} |& _filter_scratch
+}
+
+ext_count()
+{
+	local type=$1
+	local count=$2
+	local default_count=$3
+	local sign=${count:0:1}
+	if [ $sign = '+' ] || [ $sign = '-' ]; then
+		count=$(( default_count + $count ))
+	fi
+	echo "$type $(num_to_hex $count 2)"
+}
+
+auth_ext_count()
+{
+	ext_count "auth_ext_count" "$1" $DEFAULT_AUTH_EXT_COUNT
+}
+
+unauth_ext_count()
+{
+	ext_count "unauth_ext_count" "$1" $DEFAULT_UNAUTH_EXT_COUNT
+}
+
+desc_test "control case, valid file"
+desc_test "multiple pages, valid file" "gap_before_footer $(num_to_hex 0 10000)"
+
+desc_test "bad magic: XXXXXXXX" "magic XXXXXXXX"
+desc_test "bad magic: FSVeritY" "magic FSVeritY"
+desc_test "bad major_version" "major_version \xff"
+desc_test "bad minor_version" "minor_version \xff"
+desc_test "bad log_data_blocksize: 0x00" "log_data_blocksize \x00"
+desc_test "bad log_data_blocksize: 0xff" "log_data_blocksize \xff"
+desc_test "bad log_tree_blocksize: 0x00" "log_tree_blocksize \x00"
+desc_test "bad log_tree_blocksize: 0xff" "log_tree_blocksize \xff"
+desc_test "bad data_algorithm: 0x0000" "data_algorithm \x00\x00"
+desc_test "bad data_algorithm: 0xffff" "data_algorithm \xff\xff"
+desc_test "bad tree_algorithm: 0x0000" "tree_algorithm \x00\x00"
+desc_test "bad tree_algorithm: 0xffff" "tree_algorithm \xff\xff"
+desc_test "mismatched block sizes" "log_data_blocksize \x10" "log_tree_blocksize \x0C"
+desc_test "mismatched algorithms" "data_algorithm \x01\x00" "tree_algorithm \x02\x00"
+desc_test "bad flags" "flags \xff\xff\xff\xff"
+desc_test "bad reserved1" "reserved1 \xff\xff\xff\xff"
+desc_test "bad orig_file_size: 0" "orig_file_size $(num_to_hex 0 8)"
+desc_test "bad orig_file_size: > full_isize" "orig_file_size $(num_to_hex 100000 8)"
+desc_test "bad orig_file_size: UINT64_MAX" "orig_file_size \xff\xff\xff\xff\xff\xff\xff\xff"
+desc_test "bad auth_ext_count" "$(auth_ext_count 65535)"
+desc_test "bad reserved2" "reserved2 $(perl -e 'print "\\xff" x 30')"
+
+desc_test "bad desc_reverse_offset: 0" "desc_reverse_offset $(num_to_hex 0 4)"
+desc_test "bad desc_reverse_offset: 64" "desc_reverse_offset $(num_to_hex 64 4)"
+desc_test "bad desc_reverse_offset: 69" "desc_reverse_offset $(num_to_hex 69 4)"
+desc_test "bad desc_reverse_offset: > full_isize" "desc_reverse_offset $(num_to_hex 100000 4)"
+desc_test "bad desc_reverse_offset: UINT32_MAX" "desc_reverse_offset \xff\xff\xff\xff"
+desc_test "bad ftr_magic: XXXXXXXX" "ftr_magic XXXXXXXX"
+desc_test "bad ftr_magic: FSVeritY" "ftr_magic FSVeritY"
+
+desc_test "root hash length wrong: 0" \
+	"root_hash $(create_root_hash_ext "$(num_to_hex 0 0)")"
+desc_test "root hash length wrong: too short" \
+	"root_hash $(create_root_hash_ext "$(num_to_hex 0 16)")"
+desc_test "root hash length wrong: too long" \
+	"root_hash $(create_root_hash_ext "$(num_to_hex 0 100)")"
+desc_test "multiple root hashes" "$(auth_ext_count +1)" \
+	"auth_extensions $(create_root_hash_ext "$(num_to_hex 0 32)")"
+desc_test "no root hash" "$(auth_ext_count -1)" "root_hash"
+
+desc_test "root hash is unauthenticated" \
+	"$(auth_ext_count -1)" \
+	"$(unauth_ext_count +1)" \
+	"root_hash" \
+	"unauth_extensions $(create_root_hash_ext $(num_to_hex 0 32))"
+
+desc_test "salt is unauthenticated" \
+	"$(unauth_ext_count +1)" \
+	"unauth_extensions $(create_ext $FS_VERITY_EXT_SALT foo)"
+
+desc_test "unknown extension type" \
+	"$(auth_ext_count +1)" \
+	"auth_extensions $(create_ext 255 "")"
+
+desc_test "length in extension header smaller than header" \
+	"$(auth_ext_count +1)" \
+	"auth_extensions $(create_exthdr 0 $FS_VERITY_EXT_SALT)"
+
+desc_test "extension length overflows buffer" \
+	"$(auth_ext_count +1)" \
+	"auth_extensions $(create_exthdr 50000 $FS_VERITY_EXT_SALT)"
+
+desc_test "extension length wraps to 0 after rounding" \
+	"$(auth_ext_count +1)" \
+	"auth_extensions $(create_exthdr 0xffffffff $FS_VERITY_EXT_SALT)"
+
+desc_test "reserved bits set in extension header" \
+	"$(auth_ext_count +1)" \
+	"auth_extensions $(create_exthdr $EXTHDR_SIZE $FS_VERITY_EXT_SALT 1000)"
+
+# success, all done
+status=0
+exit
diff --git a/tests/generic/902.out b/tests/generic/902.out
new file mode 100644
index 00000000..27a4a46d
--- /dev/null
+++ b/tests/generic/902.out
@@ -0,0 +1,125 @@
+QA output created by 902
+
+# control case, valid file
+
+# multiple pages, valid file
+
+# bad magic: XXXXXXXX
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad magic: FSVeritY
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad major_version
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad minor_version
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad log_data_blocksize: 0x00
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad log_data_blocksize: 0xff
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad log_tree_blocksize: 0x00
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad log_tree_blocksize: 0xff
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad data_algorithm: 0x0000
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad data_algorithm: 0xffff
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad tree_algorithm: 0x0000
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad tree_algorithm: 0xffff
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# mismatched block sizes
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# mismatched algorithms
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad flags
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad reserved1
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad orig_file_size: 0
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad orig_file_size: > full_isize
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad orig_file_size: UINT64_MAX
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad auth_ext_count
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad reserved2
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad desc_reverse_offset: 0
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad desc_reverse_offset: 64
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad desc_reverse_offset: 69
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad desc_reverse_offset: > full_isize
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad desc_reverse_offset: UINT32_MAX
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad ftr_magic: XXXXXXXX
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# bad ftr_magic: FSVeritY
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# root hash length wrong: 0
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# root hash length wrong: too short
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# root hash length wrong: too long
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# multiple root hashes
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# no root hash
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# root hash is unauthenticated
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# salt is unauthenticated
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# unknown extension type
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# length in extension header smaller than header
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# extension length overflows buffer
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# extension length wraps to 0 after rounding
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
+
+# reserved bits set in extension header
+ERROR: FS_IOC_ENABLE_VERITY failed on 'SCRATCH_MNT/file.fsv': Bad message
diff --git a/tests/generic/group b/tests/generic/group
index f14ad790..f8f67918 100644
--- a/tests/generic/group
+++ b/tests/generic/group
@@ -527,3 +527,4 @@
 522 soak long_rw
 900 auto quick verity
 901 auto quick verity
+902 auto quick verity
-- 
2.20.0.rc2.403.gdbc3b29805-goog
