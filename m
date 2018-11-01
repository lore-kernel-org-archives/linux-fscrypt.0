Return-Path: <SRS0=DPN/=NM=vger.kernel.org=linux-integrity-owner@kernel.org>
From: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v2 07/12] fs-verity: add SHA-512 support
Date: Thu,  1 Nov 2018 15:52:25 -0700
Message-Id: <20181101225230.88058-8-ebiggers@kernel.org>
In-Reply-To: <20181101225230.88058-1-ebiggers@kernel.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-integrity-owner@vger.kernel.org
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add SHA-512 support to fs-verity.  This is primarily a demonstration of
the (small) changes needed to support a new hash algorithm; it's
anticipated that most users will still prefer SHA-256 due to the smaller
space required to store the hashes, though some may prefer SHA-512.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/verity/fsverity_private.h  | 2 +-
 fs/verity/hash_algs.c         | 5 +++++
 include/uapi/linux/fsverity.h | 1 +
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/verity/fsverity_private.h b/fs/verity/fsverity_private.h
index dfdbac3874d74..c3a261a598557 100644
--- a/fs/verity/fsverity_private.h
+++ b/fs/verity/fsverity_private.h
@@ -30,7 +30,7 @@
  * Largest digest size among all hash algorithms supported by fs-verity.  This
  * can be increased if needed.
  */
-#define FS_VERITY_MAX_DIGEST_SIZE	SHA256_DIGEST_SIZE
+#define FS_VERITY_MAX_DIGEST_SIZE	SHA512_DIGEST_SIZE
 
 /* A hash algorithm supported by fs-verity */
 struct fsverity_hash_alg {
diff --git a/fs/verity/hash_algs.c b/fs/verity/hash_algs.c
index 9c19c9553f120..3174a0c08785d 100644
--- a/fs/verity/hash_algs.c
+++ b/fs/verity/hash_algs.c
@@ -18,6 +18,11 @@ struct fsverity_hash_alg fsverity_hash_algs[] = {
 		.digest_size = 32,
 		.cryptographic = true,
 	},
+	[FS_VERITY_ALG_SHA512] = {
+		.name = "sha512",
+		.digest_size = 64,
+		.cryptographic = true,
+	},
 };
 
 /*
diff --git a/include/uapi/linux/fsverity.h b/include/uapi/linux/fsverity.h
index 55b9f32676220..67ed830ae2ece 100644
--- a/include/uapi/linux/fsverity.h
+++ b/include/uapi/linux/fsverity.h
@@ -28,6 +28,7 @@ struct fsverity_digest {
 
 /* Supported hash algorithms */
 #define FS_VERITY_ALG_SHA256	1
+#define FS_VERITY_ALG_SHA512	2
 
 /* Metadata stored near the end of verity files, after the Merkle tree */
 /* This structure is 64 bytes long */
-- 
2.19.1.568.g152ad8e336-goog
