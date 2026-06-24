Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F4193812F2;
	Wed, 24 Jun 2026 05:06:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782277561; cv=none; b=VgRvna9/hlv8Y1S0/ahhkdmVhZkZFHVWPsdOuXzbYl/8jQo4QEyzzxoayI2FAhVVNcuQec6vccGWvu0SKCPnwxhNuiFsgkcS3JsFnUpYS3Dp7+kZaLLmA6W8xJpqDUn5Eznmj/+OUGYHn+7HNubiN5e2sF2TMugr2Ig/EdTzyQs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782277561; c=relaxed/simple;
	bh=BLytJrJcCtygVAxFwm6tcA7f/dmjCTnpFlasy6HqVxk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rS9CjjrJxyTs9/vUiRY+/ssHfhJ6uwiYOerpgFjBSIz5tb5FM9Yt5VZADUGsqG34KYL4T0ERxizryNli4Y2VzFGsGNu2+ncPXXV6RFVchd3J1QsSMNwAejam58VhMq3KZpuamNgmfbOChnH1I4IuMsi2VdPHz8GVu/ogDlFtGEQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jN+mn/kY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jN+mn/kY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BE9481F00AC4;
	Wed, 24 Jun 2026 05:05:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782277560;
	bh=cdtSpL9FRuNu5ZvOQb0nQS1YVG/M9728PcsaSITfvVI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jN+mn/kYV8/QvOaOPr0HLlFqfiwAlsa83EIbPu1RC3P22Hu6KOnGHHXL5a7DCS41b
	 bXLl/Lsy5J42/f2KJ4zO36IkQ6L7ytlcwJePz2z04oOkz2wNi4K/4sSYyiayXOqK8G
	 7Ab49k6RK3LpF25O5m9U66TtHSTRldDXwj7AbTth1SHk/KbmYuDbM99E26NNYJsBaa
	 tuPWlIG2Xb74p/iPCvTtukS37UOSmKXUHmKniuGEEW/pYqOoESQp4lg/ZjcSVTOnT5
	 OkYmrhMIUOee+fIX2JfYg5p2+WrhaQKnS5YGtLcWjdYChOS6LZYDR8lMxwgaoCMxhX
	 DHwRXaFw136+w==
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
Subject: [PATCH 03/16] blk-crypto: Allow control over whether hardware is used
Date: Tue, 23 Jun 2026 22:03:21 -0700
Message-ID: <20260624050334.124606-4-ebiggers@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260624050334.124606-1-ebiggers@kernel.org>
References: <20260624050334.124606-1-ebiggers@kernel.org>
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

To support this use case, add an allow_hw field to struct
blk_crypto_config.

For now it's always set to true.  Later commits will change that.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 block/blk-crypto.c          | 8 +++++++-
 drivers/md/dm-inlinecrypt.c | 2 +-
 fs/crypto/inline_crypt.c    | 3 ++-
 include/linux/blk-crypto.h  | 6 +++++-
 4 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/block/blk-crypto.c b/block/blk-crypto.c
index dd83fc5af282..c157db869183 100644
--- a/block/blk-crypto.c
+++ b/block/blk-crypto.c
@@ -298,20 +298,21 @@ int __blk_crypto_rq_bio_prep(struct request *rq, struct bio *bio,
  * @key_type: type of the key -- either raw or hardware-wrapped
  * @crypto_mode: identifier for the encryption algorithm to use
  * @dun_bytes: number of bytes that will be used to specify the DUN when this
  *	       key is used
  * @data_unit_size: the data unit size to use for en/decryption
+ * @allow_hw: true if using inline encryption hardware is allowed
  *
  * Return: 0 on success, -errno on failure.  The caller is responsible for
  *	   zeroizing both blk_key and key_bytes when done with them.
  */
 int blk_crypto_init_key(struct blk_crypto_key *blk_key,
 			const u8 *key_bytes, size_t key_size,
 			enum blk_crypto_key_type key_type,
 			enum blk_crypto_mode_num crypto_mode,
 			unsigned int dun_bytes,
-			unsigned int data_unit_size)
+			unsigned int data_unit_size, bool allow_hw)
 {
 	const struct blk_crypto_mode *mode;
 
 	memset(blk_key, 0, sizeof(*blk_key));
 
@@ -326,10 +327,12 @@ int blk_crypto_init_key(struct blk_crypto_key *blk_key,
 		break;
 	case BLK_CRYPTO_KEY_TYPE_HW_WRAPPED:
 		if (key_size < mode->security_strength ||
 		    key_size > BLK_CRYPTO_MAX_HW_WRAPPED_KEY_SIZE)
 			return -EINVAL;
+		if (!allow_hw)
+			return -EINVAL;
 		break;
 	default:
 		return -EINVAL;
 	}
 
@@ -341,10 +344,11 @@ int blk_crypto_init_key(struct blk_crypto_key *blk_key,
 
 	blk_key->crypto_cfg.crypto_mode = crypto_mode;
 	blk_key->crypto_cfg.dun_bytes = dun_bytes;
 	blk_key->crypto_cfg.data_unit_size = data_unit_size;
 	blk_key->crypto_cfg.key_type = key_type;
+	blk_key->crypto_cfg.allow_hw = allow_hw;
 	blk_key->data_unit_size_bits = ilog2(data_unit_size);
 	blk_key->size = key_size;
 	memcpy(blk_key->bytes, key_bytes, key_size);
 
 	return 0;
@@ -366,10 +370,12 @@ bool blk_crypto_config_supported_natively(struct block_device *bdev,
 {
 	struct blk_crypto_profile *profile = bdev_get_queue(bdev)->crypto_profile;
 
 	if (!profile)
 		return false;
+	if (!cfg->allow_hw)
+		return false;
 	if (!(profile->modes_supported[cfg->crypto_mode] & cfg->data_unit_size))
 		return false;
 	if (profile->max_dun_bytes_supported < cfg->dun_bytes)
 		return false;
 	if (!(profile->key_types_supported & cfg->key_type))
diff --git a/drivers/md/dm-inlinecrypt.c b/drivers/md/dm-inlinecrypt.c
index be1b4aa8f28b..a0f039c1e153 100644
--- a/drivers/md/dm-inlinecrypt.c
+++ b/drivers/md/dm-inlinecrypt.c
@@ -404,11 +404,11 @@ static int inlinecrypt_ctr(struct dm_target *ti, unsigned int argc, char **argv)
 		       (ctx->sector_bits - SECTOR_SHIFT);
 	dun_bytes = DIV_ROUND_UP(fls64(ctx->max_dun), 8);
 
 	err = blk_crypto_init_key(&ctx->key, key_bytes, ctx->key_size,
 				  ctx->key_type, cipher->mode_num,
-				  dun_bytes, ctx->sector_size);
+				  dun_bytes, ctx->sector_size, true);
 	if (err) {
 		ti->error = "Error initializing blk-crypto key";
 		goto bad;
 	}
 
diff --git a/fs/crypto/inline_crypt.c b/fs/crypto/inline_crypt.c
index 47324062fee5..0d4c0dd04d20 100644
--- a/fs/crypto/inline_crypt.c
+++ b/fs/crypto/inline_crypt.c
@@ -132,10 +132,11 @@ int fscrypt_select_encryption_impl(struct fscrypt_inode_info *ci,
 	crypto_cfg.crypto_mode = ci->ci_mode->blk_crypto_mode;
 	crypto_cfg.data_unit_size = 1U << ci->ci_data_unit_bits;
 	crypto_cfg.dun_bytes = fscrypt_get_dun_bytes(ci);
 	crypto_cfg.key_type = is_hw_wrapped_key ?
 		BLK_CRYPTO_KEY_TYPE_HW_WRAPPED : BLK_CRYPTO_KEY_TYPE_RAW;
+	crypto_cfg.allow_hw = true;
 
 	devs = fscrypt_get_devices(sb, &num_devs);
 	if (IS_ERR(devs))
 		return PTR_ERR(devs);
 
@@ -173,11 +174,11 @@ int fscrypt_prepare_inline_crypt_key(struct fscrypt_prepared_key *prep_key,
 	if (!blk_key)
 		return -ENOMEM;
 
 	err = blk_crypto_init_key(blk_key, key_bytes, key_size, key_type,
 				  crypto_mode, fscrypt_get_dun_bytes(ci),
-				  1U << ci->ci_data_unit_bits);
+				  1U << ci->ci_data_unit_bits, true);
 	if (err) {
 		fscrypt_err(inode, "error %d initializing blk-crypto key", err);
 		goto fail;
 	}
 
diff --git a/include/linux/blk-crypto.h b/include/linux/blk-crypto.h
index f7c3cb4a342f..7b9dca89aec9 100644
--- a/include/linux/blk-crypto.h
+++ b/include/linux/blk-crypto.h
@@ -75,16 +75,20 @@ enum blk_crypto_key_type {
  *	key.  This is the size in bytes of each individual plaintext and
  *	ciphertext.  This is always a power of 2.  It might be e.g. the
  *	filesystem block size or the disk sector size.
  * @dun_bytes: the maximum number of bytes of DUN used when using this key
  * @key_type: the type of this key -- either raw or hardware-wrapped
+ * @allow_hw: true if inline encryption hardware will be used if available;
+ *	      false to always use CPU-based encryption (requires
+ *	      CONFIG_BLK_INLINE_ENCRYPTION_FALLBACK)
  */
 struct blk_crypto_config {
 	enum blk_crypto_mode_num crypto_mode;
 	unsigned int data_unit_size;
 	unsigned int dun_bytes;
 	enum blk_crypto_key_type key_type;
+	bool allow_hw;
 };
 
 /**
  * struct blk_crypto_key - an inline encryption key
  * @crypto_cfg: the crypto mode, data unit size, key type, and other
@@ -148,11 +152,11 @@ bool bio_crypt_dun_is_contiguous(const struct bio_crypt_ctx *bc,
 int blk_crypto_init_key(struct blk_crypto_key *blk_key,
 			const u8 *key_bytes, size_t key_size,
 			enum blk_crypto_key_type key_type,
 			enum blk_crypto_mode_num crypto_mode,
 			unsigned int dun_bytes,
-			unsigned int data_unit_size);
+			unsigned int data_unit_size, bool allow_hw);
 
 int blk_crypto_start_using_key(struct block_device *bdev,
 			       const struct blk_crypto_key *key);
 
 void blk_crypto_evict_key(struct block_device *bdev,
-- 
2.54.0

