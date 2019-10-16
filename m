Return-Path: <linux-ext4-owner@vger.kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [xfstests-bld PATCH] test-appliance: add ext4/encrypt_1k test config
Date: Wed, 16 Oct 2019 15:15:52 -0700
Message-Id: <20191016221552.299566-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-ext4-owner@vger.kernel.org
To: linux-ext4@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, Chandan Rajendra <chandan@linux.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add a test configuration to allow testing ext4 encryption with 1k
blocks, which kernel patches have been proposed to support.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 .../files/root/fs/ext4/cfg/encrypt_1k         |  5 ++++
 .../files/root/fs/ext4/cfg/encrypt_1k.exclude | 27 +++++++++++++++++++
 2 files changed, 32 insertions(+)
 create mode 100644 kvm-xfstests/test-appliance/files/root/fs/ext4/cfg/encrypt_1k
 create mode 100644 kvm-xfstests/test-appliance/files/root/fs/ext4/cfg/encrypt_1k.exclude

diff --git a/kvm-xfstests/test-appliance/files/root/fs/ext4/cfg/encrypt_1k b/kvm-xfstests/test-appliance/files/root/fs/ext4/cfg/encrypt_1k
new file mode 100644
index 0000000..5e97cc0
--- /dev/null
+++ b/kvm-xfstests/test-appliance/files/root/fs/ext4/cfg/encrypt_1k
@@ -0,0 +1,5 @@
+SIZE=small
+export EXT_MKFS_OPTIONS="-O encrypt -b 1024"
+export EXT_MOUNT_OPTIONS="test_dummy_encryption"
+REQUIRE_FEATURE=encryption
+TESTNAME="Ext4 encryption 1k block"
diff --git a/kvm-xfstests/test-appliance/files/root/fs/ext4/cfg/encrypt_1k.exclude b/kvm-xfstests/test-appliance/files/root/fs/ext4/cfg/encrypt_1k.exclude
new file mode 100644
index 0000000..e31c371
--- /dev/null
+++ b/kvm-xfstests/test-appliance/files/root/fs/ext4/cfg/encrypt_1k.exclude
@@ -0,0 +1,27 @@
+# These tests are also excluded in encrypt.exclude.
+# See there for the reasons.
+ext4/004
+ext4/022
+ext4/026
+generic/082
+generic/219
+generic/230
+generic/231
+generic/232
+generic/233
+generic/235
+generic/270
+generic/382
+generic/204
+
+# These tests are also excluded in 1k.exclude.
+# See there for the reasons.
+ext4/034
+generic/273
+generic/454
+
+# These tests use _scratch_populate_cached() which tries to create a 1023-byte
+# symlink, which fails with encrypt_1k because encrypted symlinks are limited to
+# blocksize-3 bytes, not blocksize-1 as is the case for no encryption.
+ext4/023
+ext4/028
-- 
2.23.0
