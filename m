Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
From: Eric Biggers <ebiggers@kernel.org>
Date: Fri, 24 Aug 2018 09:16:38 -0700
Message-Id: <20180824161642.1144-7-ebiggers@kernel.org>
In-Reply-To: <20180824161642.1144-1-ebiggers@kernel.org>
References: <20180824161642.1144-1-ebiggers@kernel.org>
Subject: [f2fs-dev] [RFC PATCH 06/10] fs-verity: add CRC-32C support
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Cc: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>, Michael Halcrow <mhalcrow@google.com>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-integrity@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Add CRC-32C support to fs-verity, to provide a faster alternative to
SHA-256 for users who want integrity-only (not authenticity), i.e. who
want to detect only accidental corruption, not malicious changes.

CRC-32C is chosen over CRC-32 because the CRC-32C polynomial is believed
to provide slightly better error-detection properties; and CRC-32C is
just as fast (or can be just as fast) as CRC-32, or even faster e.g. on
some x86 processors that have a CRC-32C instruction but not CRC-32.

We use "crc32c" from the crypto API, so the polynomial convention is
bitwise little-endian, the digest is bytewise little-endian, and the CRC
bits are inverted at the beginning and end (which is desirable).

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/verity/hash_algs.c         | 4 ++++
 include/uapi/linux/fsverity.h | 1 +
 2 files changed, 5 insertions(+)

diff --git a/fs/verity/hash_algs.c b/fs/verity/hash_algs.c
index e16d767070fec..3fd4bba7c4aa6 100644
--- a/fs/verity/hash_algs.c
+++ b/fs/verity/hash_algs.c
@@ -23,6 +23,10 @@ struct fsverity_hash_alg fsverity_hash_algs[] = {
 		.digest_size = 64,
 		.cryptographic = true,
 	},
+	[FS_VERITY_ALG_CRC32C] = {
+		.name = "crc32c",
+		.digest_size = 4,
+	},
 };
 
 /*
diff --git a/include/uapi/linux/fsverity.h b/include/uapi/linux/fsverity.h
index 64846763f7aef..b1afd205bbf87 100644
--- a/include/uapi/linux/fsverity.h
+++ b/include/uapi/linux/fsverity.h
@@ -29,6 +29,7 @@ struct fsverity_digest {
 /* Supported hash algorithms */
 #define FS_VERITY_ALG_SHA256	1
 #define FS_VERITY_ALG_SHA512	2
+#define FS_VERITY_ALG_CRC32C	3	/* for integrity only */
 
 /* Metadata stored near the end of verity files, after the Merkle tree */
 /* This structure is 64 bytes long */
-- 
2.18.0


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
