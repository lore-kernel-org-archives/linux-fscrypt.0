Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:41488 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727615AbeHXT6v (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 24 Aug 2018 15:58:51 -0400
From: Eric Biggers <ebiggers@kernel.org>
Subject: [RFC PATCH 05/10] fs-verity: add SHA-512 support
Date: Fri, 24 Aug 2018 09:16:37 -0700
Message-Id: <20180824161642.1144-6-ebiggers@kernel.org>
In-Reply-To: <20180824161642.1144-1-ebiggers@kernel.org>
References: <20180824161642.1144-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: linux-integrity@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, Victor Hsieh <victorhsieh@google.com>
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
index c553f99dc4973..1046b87b12dee 100644
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
index 424a26ee2f3c2..e16d767070fec 100644
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
index 24ebb8b6ea0d4..64846763f7aef 100644
--- a/include/uapi/linux/fsverity.h
+++ b/include/uapi/linux/fsverity.h
@@ -28,6 +28,7 @@ struct fsverity_digest {
 
 /* Supported hash algorithms */
 #define FS_VERITY_ALG_SHA256	1
+#define FS_VERITY_ALG_SHA512	2
 
 /* Metadata stored near the end of verity files, after the Merkle tree */
 /* This structure is 64 bytes long */
-- 
2.18.0
