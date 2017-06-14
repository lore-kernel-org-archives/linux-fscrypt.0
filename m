Return-Path: <linux-fsdevel-owner@vger.kernel.org>
From: Michael Halcrow <mhalcrow@google.com>
Subject: [RFC PATCH 1/4] block: Add bio req flag to disable encryption in block
Date: Wed, 14 Jun 2017 16:40:37 -0700
Message-Id: <20170614234040.4326-2-mhalcrow@google.com>
In-Reply-To: <20170614234040.4326-1-mhalcrow@google.com>
References: <20170614234040.4326-1-mhalcrow@google.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Michael Halcrow <mhalcrow@google.com>, "Theodore Y . Ts'o" <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, dm-devel@redhat.com, linux-ext4@vger.kernel.org, Tyler Hicks <tyler.hicks@canonical.com>
List-ID: <linux-fscrypt@vger.kernel.org>

When both the file system and a lower layer such as dm-crypt encrypt
the same file contents, it impacts performance and power utilization.
Depending on how the operating environment manages the encryption
keys, there is often no significant security benefit to redundantly
encrypting.

File systems that encrypt some of their blocks can set the
REQ_NOENCRYPT flag as a directive to lower layers to not encrypt.

Lower layers may optionally observe the flag, but once thay do, they
must continue to observe it on subsequent I/O on the device.
Otherwise they will decrypt content that they didn't previously
encrypt, resulting in data corruption.

Signed-off-by: Michael Halcrow <mhalcrow@google.com>
---
 include/linux/blk_types.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/blk_types.h b/include/linux/blk_types.h
index 61339bc44400..89da8f5f7be1 100644
--- a/include/linux/blk_types.h
+++ b/include/linux/blk_types.h
@@ -205,6 +205,7 @@ enum req_flag_bits {
 	/* command specific flags for REQ_OP_WRITE_ZEROES: */
 	__REQ_NOUNMAP,		/* do not free blocks when zeroing */
 
+	__REQ_NOENCRYPT,	/* ok to not encrypt */
 	__REQ_NR_BITS,		/* stops here */
 };
 
@@ -223,6 +224,7 @@ enum req_flag_bits {
 #define REQ_BACKGROUND		(1ULL << __REQ_BACKGROUND)
 
 #define REQ_NOUNMAP		(1ULL << __REQ_NOUNMAP)
+#define REQ_NOENCRYPT		(1ULL << __REQ_NOENCRYPT)
 
 #define REQ_FAILFAST_MASK \
 	(REQ_FAILFAST_DEV | REQ_FAILFAST_TRANSPORT | REQ_FAILFAST_DRIVER)
-- 
2.13.1.508.gb3defc5cc-goog
