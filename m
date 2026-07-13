Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D599D369D45;
	Mon, 13 Jul 2026 02:39:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783910377; cv=none; b=efGka5VNPvRhMM7rxxpWlFlz535sk1WOnPkbQ5mkgSCRF+dgQNipLLxUhUUVJKDiWBsCxqUXxWEXY+5bt0MTtAJ/T0TlDRJCpkGxs5/bcVVWmZK5KO4B3dknOTQEtC0dFkNT4JG37fFoP748I9Y2RIhF6tpXDWz3mC+1eXh78/o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783910377; c=relaxed/simple;
	bh=9tMb0naYDp29ILI7tMnOD6nlLYWs4BHRasU28pJfyfU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=C7ZN1g8IM4f3j2ZjwIgAQZawByvCyWUXrXDm8ryA+OUufrFwlA0ujmC+UxSWGGAQ8w7r9QaDD8U+tEtywAR5sPKv0ccD2LcnEZKQ60xAw5OVkkp2OijnMDGpP7lTOILeBW5hRxTRb6n6Stp8yNDL3cK5OakcsvW/lGuyxRGw1es=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=d+Phk90h; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="d+Phk90h"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1CFDC1F000E9;
	Mon, 13 Jul 2026 02:39:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783910375;
	bh=QaORzSDkR90GYfmKCub9QkAr8t4t0KNC6u6lCI50uUA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=d+Phk90hDIyyQR7xf45lSXzQN9S34n7eDLdI/5q0yuSibJapOgyfO9t+AkO8JJWmL
	 zSJJK3F7T12A6eoFm9mQRG1QZL47sCf34o9gDaw1wpqUKgfd1dl5jhNu4kak/DFIeR
	 kP8GcFl8sekY3LmOj3DRKJAt/12am9Vgelly1Fn74Evp2pBZUa6QAM/CuGaPl7hyxs
	 YDbsMyMC/Hjx4Sx89Odhijd74zGOWbpIvWZ01RbPB7WweYP3IyTleQzSaDCBRCD+1v
	 9BQmCdW7Acu6NFJk3V1rMbu6D7c8roAGtfQFg4T4iFa9CfdPdUSRrRqTFhZL2YPVXp
	 UC+MxzbA7hRig==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-block@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>,
	Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH v3 03/17] blk-crypto: Allow control over whether hardware is used
Date: Sun, 12 Jul 2026 22:36:54 -0400
Message-ID: <20260713023708.9245-4-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260713023708.9245-1-ebiggers@kernel.org>
References: <20260713023708.9245-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

fscrypt uses inline encryption hardware only when the "inlinecrypt"
mount option is given.  I'd like to keep that behavior even after
standardizing on the blk-crypto API for file contents encryption.  That
is, the default should continue to be the well-tested CPU-based
encryption code, and the use of inline encryption hardware should
continue to be an opt-in feature for systems where it's beneficial and
has been fully validated (including verifying ciphertext correctness).

To support this use case, extend blk_crypto_config with a new flag
BLK_CRYPTO_CFG_ALLOW_HW.

For now it's always set.  Later commits will change that.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 block/blk-crypto.c          | 11 ++++++++++-
 drivers/md/dm-inlinecrypt.c |  3 ++-
 fs/crypto/inline_crypt.c    |  4 +++-
 include/linux/blk-crypto.h  | 13 ++++++++++++-
 4 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/block/blk-crypto.c b/block/blk-crypto.c
index de60f03b4d4b..0fe6ef0eea1d 100644
--- a/block/blk-crypto.c
+++ b/block/blk-crypto.c
@@ -300,6 +300,7 @@ int __blk_crypto_rq_bio_prep(struct request *rq, struct bio *bio,
  * @dun_bytes: number of bytes that will be used to specify the DUN when this
  *	       key is used
  * @data_unit_size: the data unit size to use for en/decryption
+ * @flags: BLK_CRYPTO_CFG_* flags
  *
  * Return: 0 on success, -errno on failure.  The caller is responsible for
  *	   zeroizing both blk_key and key_bytes when done with them.
@@ -309,7 +310,7 @@ int blk_crypto_init_key(struct blk_crypto_key *blk_key,
 			enum blk_crypto_key_type key_type,
 			enum blk_crypto_mode_num crypto_mode,
 			unsigned int dun_bytes,
-			unsigned int data_unit_size)
+			unsigned int data_unit_size, int flags)
 {
 	const struct blk_crypto_mode *mode;
 
@@ -318,6 +319,9 @@ int blk_crypto_init_key(struct blk_crypto_key *blk_key,
 	if (crypto_mode >= ARRAY_SIZE(blk_crypto_modes))
 		return -EINVAL;
 
+	if (flags & ~BLK_CRYPTO_CFG_ALLOW_HW)
+		return -EINVAL;
+
 	mode = &blk_crypto_modes[crypto_mode];
 	switch (key_type) {
 	case BLK_CRYPTO_KEY_TYPE_RAW:
@@ -328,6 +332,8 @@ int blk_crypto_init_key(struct blk_crypto_key *blk_key,
 		if (key_size < mode->security_strength ||
 		    key_size > BLK_CRYPTO_MAX_HW_WRAPPED_KEY_SIZE)
 			return -EINVAL;
+		if (!(flags & BLK_CRYPTO_CFG_ALLOW_HW))
+			return -EINVAL;
 		break;
 	default:
 		return -EINVAL;
@@ -343,6 +349,7 @@ int blk_crypto_init_key(struct blk_crypto_key *blk_key,
 	blk_key->crypto_cfg.dun_bytes = dun_bytes;
 	blk_key->crypto_cfg.data_unit_size = data_unit_size;
 	blk_key->crypto_cfg.key_type = key_type;
+	blk_key->crypto_cfg.flags = flags;
 	blk_key->data_unit_size_bits = ilog2(data_unit_size);
 	blk_key->size = key_size;
 	memcpy(blk_key->bytes, key_bytes, key_size);
@@ -368,6 +375,8 @@ bool blk_crypto_config_supported_natively(struct block_device *bdev,
 
 	if (!profile)
 		return false;
+	if (!(cfg->flags & BLK_CRYPTO_CFG_ALLOW_HW))
+		return false;
 	if (!(profile->modes_supported[cfg->crypto_mode] & cfg->data_unit_size))
 		return false;
 	if (profile->max_dun_bytes_supported < cfg->dun_bytes)
diff --git a/drivers/md/dm-inlinecrypt.c b/drivers/md/dm-inlinecrypt.c
index be1b4aa8f28b..35379f5c84df 100644
--- a/drivers/md/dm-inlinecrypt.c
+++ b/drivers/md/dm-inlinecrypt.c
@@ -406,7 +406,8 @@ static int inlinecrypt_ctr(struct dm_target *ti, unsigned int argc, char **argv)
 
 	err = blk_crypto_init_key(&ctx->key, key_bytes, ctx->key_size,
 				  ctx->key_type, cipher->mode_num,
-				  dun_bytes, ctx->sector_size);
+				  dun_bytes, ctx->sector_size,
+				  BLK_CRYPTO_CFG_ALLOW_HW);
 	if (err) {
 		ti->error = "Error initializing blk-crypto key";
 		goto bad;
diff --git a/fs/crypto/inline_crypt.c b/fs/crypto/inline_crypt.c
index 47324062fee5..aaf71f6068b0 100644
--- a/fs/crypto/inline_crypt.c
+++ b/fs/crypto/inline_crypt.c
@@ -134,6 +134,7 @@ int fscrypt_select_encryption_impl(struct fscrypt_inode_info *ci,
 	crypto_cfg.dun_bytes = fscrypt_get_dun_bytes(ci);
 	crypto_cfg.key_type = is_hw_wrapped_key ?
 		BLK_CRYPTO_KEY_TYPE_HW_WRAPPED : BLK_CRYPTO_KEY_TYPE_RAW;
+	crypto_cfg.flags = BLK_CRYPTO_CFG_ALLOW_HW;
 
 	devs = fscrypt_get_devices(sb, &num_devs);
 	if (IS_ERR(devs))
@@ -175,7 +176,8 @@ int fscrypt_prepare_inline_crypt_key(struct fscrypt_prepared_key *prep_key,
 
 	err = blk_crypto_init_key(blk_key, key_bytes, key_size, key_type,
 				  crypto_mode, fscrypt_get_dun_bytes(ci),
-				  1U << ci->ci_data_unit_bits);
+				  1U << ci->ci_data_unit_bits,
+				  BLK_CRYPTO_CFG_ALLOW_HW);
 	if (err) {
 		fscrypt_err(inode, "error %d initializing blk-crypto key", err);
 		goto fail;
diff --git a/include/linux/blk-crypto.h b/include/linux/blk-crypto.h
index f7c3cb4a342f..5f40821f99cd 100644
--- a/include/linux/blk-crypto.h
+++ b/include/linux/blk-crypto.h
@@ -68,6 +68,15 @@ enum blk_crypto_key_type {
  */
 #define BLK_CRYPTO_SW_SECRET_SIZE	32
 
+/* Flags for blk_crypto_config::flags: */
+
+/*
+ * If set, inline encryption hardware will be used if available.
+ * If unset, CPU-based encryption will always be used (requires
+ * CONFIG_BLK_INLINE_ENCRYPTION_FALLBACK)
+ */
+#define BLK_CRYPTO_CFG_ALLOW_HW		(1 << 0)
+
 /**
  * struct blk_crypto_config - an inline encryption key's crypto configuration
  * @crypto_mode: encryption algorithm this key is for
@@ -77,12 +86,14 @@ enum blk_crypto_key_type {
  *	filesystem block size or the disk sector size.
  * @dun_bytes: the maximum number of bytes of DUN used when using this key
  * @key_type: the type of this key -- either raw or hardware-wrapped
+ * @flags: BLK_CRYPTO_CFG_* flags
  */
 struct blk_crypto_config {
 	enum blk_crypto_mode_num crypto_mode;
 	unsigned int data_unit_size;
 	unsigned int dun_bytes;
 	enum blk_crypto_key_type key_type;
+	int flags;
 };
 
 /**
@@ -150,7 +161,7 @@ int blk_crypto_init_key(struct blk_crypto_key *blk_key,
 			enum blk_crypto_key_type key_type,
 			enum blk_crypto_mode_num crypto_mode,
 			unsigned int dun_bytes,
-			unsigned int data_unit_size);
+			unsigned int data_unit_size, int flags);
 
 int blk_crypto_start_using_key(struct block_device *bdev,
 			       const struct blk_crypto_key *key);
-- 
2.55.0

