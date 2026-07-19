Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D12182D12ED;
	Sun, 19 Jul 2026 05:58:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784440734; cv=none; b=BwShsZ1mk50VecdLox6Rv1o/em5NRj17cxt2A5locIa4e6pGYwu79H1rW9X2gKFLheLZJOh2XPRv5FnXtKQnIVx5KpNNcnQt3yrtG6FoaKepowbH4TSLZ1XscFA2vi0ZdmtBCW4C09/Ks3kpQL3msJrkoC/gHm4fgx9g8izmrzU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784440734; c=relaxed/simple;
	bh=+PtHe9t5xmkxBy1wDNcyixqRD7DJi981gPXbqCxf+vI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=S/04Fepr5zobgkT2L7oeAEb+JfKFTFyJO/tPTsegFVWONUXsysI1uVLay06pU1ZBZdNi8z9v2v2EHUP/NZneVqTIV/uabYv72NTHIvigZYdOpVlwyObmoC27KgrqEriPC4H2iXuNcZ+qWMQC4LKS0GB4i/T7YPTmW+HL6WTR0IE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Estb7Vk/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Estb7Vk/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7119E1F000E9;
	Sun, 19 Jul 2026 05:58:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784440732;
	bh=iAXVXzJpig6dahM628o/vwK/IOv+3gB72WFYl2PMQQQ=;
	h=From:To:Cc:Subject:Date;
	b=Estb7Vk/3rxdlw0raTwIxe4PkBHn47CIaxwDRnJgNNhsmsn+3dcVDhjdrRddZEfeI
	 gpAMWL87rUNmwsBVoaJMAiPkmQjJLbWsWg2kk2GIaMtIHAXb8UBUDypf/TqnrPL3rg
	 UWJgK9pue0LUpLQKsmeeOQzQRr1LM2XZZJCkVP6TRq6v0qiOP021J3aJt8PsXuKXGL
	 UZbsKcaKZxrWKx/b5NRssFtx9lXjL5vkn1bQbcw6lRoJYbyfZd32iiQb5HCQTvRV/w
	 nBlaZEEQoGuxjPAduLThYxoUOFkrLNiEou1DooulSeq1EyYz1J2x2GapdYgAy7aRwY
	 2Wio8behur0Kg==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	Eric Biggers <ebiggers@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH] fscrypt: Avoid dynamic allocation in fscrypt_get_devices()
Date: Sat, 18 Jul 2026 22:56:02 -0700
Message-ID: <20260719055602.78828-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a blk_crypto_key starts being used or is evicted, fs/crypto/ calls
fscrypt_get_devices() to get the filesystem's list of block devices,
then iterates over them and calls blk_crypto_config_supported(),
blk_crypto_start_using_key(), or blk_crypto_evict_key() on each one.

Currently, the block device pointers are placed in a dynamically
allocated array.  This dynamic allocation is problematic because:

- It can fail, especially at the fscrypt_destroy_inline_crypt_key() call
  site when it's invoked for inode eviction under direct reclaim.

- fscrypt_destroy_inline_crypt_key() doesn't handle the failure.  It
  just zeroizes and frees the blk_crypto_key without calling
  blk_crypto_evict_key().  That causes a use-after-free.

For now, let's fix this in the straightforward and easily-backportable
way by switching to an on-stack array.  Currently the fscrypt
multi-device functionality is used only by f2fs, which has a hardcoded
limit of 8 block devices.  An on-stack array works fine for that.

(Of course, this solution won't scale up to large number of block
devices.  For that we'd need a different solution, like moving the block
device iteration into the filesystem.  Or in the case of btrfs, which
will only support blk-crypto-fallback, we should make it just call
blk-crypto-fallback directly, so the block devices won't be needed.)

Fixes: 22e9947a4b2b ("fscrypt: stop holding extra request_queue references")
Cc: stable@vger.kernel.org
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/inline_crypt.c | 57 ++++++++++++++--------------------------
 fs/f2fs/super.c          | 25 ++++++++++--------
 include/linux/fscrypt.h  | 18 +++++++------
 3 files changed, 44 insertions(+), 56 deletions(-)

diff --git a/fs/crypto/inline_crypt.c b/fs/crypto/inline_crypt.c
index 47324062fee51..66b9c9150fed6 100644
--- a/fs/crypto/inline_crypt.c
+++ b/fs/crypto/inline_crypt.c
@@ -22,22 +22,14 @@
 
 #include "fscrypt_private.h"
 
-static struct block_device **fscrypt_get_devices(struct super_block *sb,
-						 unsigned int *num_devs)
+static unsigned int
+fscrypt_get_devices(struct super_block *sb,
+		    struct block_device *devs[FSCRYPT_MAX_DEVICES])
 {
-	struct block_device **devs;
-
-	if (sb->s_cop->get_devices) {
-		devs = sb->s_cop->get_devices(sb, num_devs);
-		if (devs)
-			return devs;
-	}
-	devs = kmalloc_obj(*devs);
-	if (!devs)
-		return ERR_PTR(-ENOMEM);
+	if (sb->s_cop->get_devices)
+		return sb->s_cop->get_devices(sb, devs);
 	devs[0] = sb->s_bdev;
-	*num_devs = 1;
-	return devs;
+	return 1;
 }
 
 static unsigned int fscrypt_get_dun_bytes(const struct fscrypt_inode_info *ci)
@@ -96,7 +88,7 @@ int fscrypt_select_encryption_impl(struct fscrypt_inode_info *ci,
 	const struct inode *inode = ci->ci_inode;
 	struct super_block *sb = inode->i_sb;
 	struct blk_crypto_config crypto_cfg;
-	struct block_device **devs;
+	struct block_device *devs[FSCRYPT_MAX_DEVICES];
 	unsigned int num_devs;
 	unsigned int i;
 
@@ -135,20 +127,15 @@ int fscrypt_select_encryption_impl(struct fscrypt_inode_info *ci,
 	crypto_cfg.key_type = is_hw_wrapped_key ?
 		BLK_CRYPTO_KEY_TYPE_HW_WRAPPED : BLK_CRYPTO_KEY_TYPE_RAW;
 
-	devs = fscrypt_get_devices(sb, &num_devs);
-	if (IS_ERR(devs))
-		return PTR_ERR(devs);
-
+	num_devs = fscrypt_get_devices(sb, devs);
 	for (i = 0; i < num_devs; i++) {
 		if (!blk_crypto_config_supported(devs[i], &crypto_cfg))
-			goto out_free_devs;
+			return 0;
 	}
 
 	fscrypt_log_blk_crypto_impl(ci->ci_mode, devs, num_devs, &crypto_cfg);
 
 	ci->ci_inlinecrypt = true;
-out_free_devs:
-	kfree(devs);
 
 	return 0;
 }
@@ -164,7 +151,7 @@ int fscrypt_prepare_inline_crypt_key(struct fscrypt_prepared_key *prep_key,
 	enum blk_crypto_key_type key_type = is_hw_wrapped ?
 		BLK_CRYPTO_KEY_TYPE_HW_WRAPPED : BLK_CRYPTO_KEY_TYPE_RAW;
 	struct blk_crypto_key *blk_key;
-	struct block_device **devs;
+	struct block_device *devs[FSCRYPT_MAX_DEVICES];
 	unsigned int num_devs;
 	unsigned int i;
 	int err;
@@ -182,17 +169,12 @@ int fscrypt_prepare_inline_crypt_key(struct fscrypt_prepared_key *prep_key,
 	}
 
 	/* Start using blk-crypto on all the filesystem's block devices. */
-	devs = fscrypt_get_devices(sb, &num_devs);
-	if (IS_ERR(devs)) {
-		err = PTR_ERR(devs);
-		goto fail;
-	}
+	num_devs = fscrypt_get_devices(sb, devs);
 	for (i = 0; i < num_devs; i++) {
 		err = blk_crypto_start_using_key(devs[i], blk_key);
 		if (err)
 			break;
 	}
-	kfree(devs);
 	if (err) {
 		fscrypt_err(inode, "error %d starting to use blk-crypto", err);
 		goto fail;
@@ -210,20 +192,21 @@ void fscrypt_destroy_inline_crypt_key(struct super_block *sb,
 				      struct fscrypt_prepared_key *prep_key)
 {
 	struct blk_crypto_key *blk_key = prep_key->blk_key;
-	struct block_device **devs;
+	struct block_device *devs[FSCRYPT_MAX_DEVICES];
 	unsigned int num_devs;
 	unsigned int i;
 
 	if (!blk_key)
 		return;
 
-	/* Evict the key from all the filesystem's block devices. */
-	devs = fscrypt_get_devices(sb, &num_devs);
-	if (!IS_ERR(devs)) {
-		for (i = 0; i < num_devs; i++)
-			blk_crypto_evict_key(devs[i], blk_key);
-		kfree(devs);
-	}
+	/*
+	 * Evict the key from all the filesystem's block devices.
+	 * This *must* be done before the key is freed.
+	 */
+	num_devs = fscrypt_get_devices(sb, devs);
+	for (i = 0; i < num_devs; i++)
+		blk_crypto_evict_key(devs[i], blk_key);
+
 	kfree_sensitive(blk_key);
 }
 
diff --git a/fs/f2fs/super.c b/fs/f2fs/super.c
index 2b8d964111562..9760e4efeffec 100644
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -3749,24 +3749,27 @@ static bool f2fs_has_stable_inodes(struct super_block *sb)
 	return true;
 }
 
-static struct block_device **f2fs_get_devices(struct super_block *sb,
-					      unsigned int *num_devs)
+static unsigned int
+f2fs_get_devices(struct super_block *sb,
+		 struct block_device *devs[FSCRYPT_MAX_DEVICES])
 {
 	struct f2fs_sb_info *sbi = F2FS_SB(sb);
-	struct block_device **devs;
+	int ndevs;
 	int i;
 
-	if (!f2fs_is_multi_device(sbi))
-		return NULL;
+	static_assert(MAX_DEVICES <= FSCRYPT_MAX_DEVICES);
 
-	devs = kmalloc_objs(*devs, sbi->s_ndevs);
-	if (!devs)
-		return ERR_PTR(-ENOMEM);
+	if (!f2fs_is_multi_device(sbi)) {
+		devs[0] = sb->s_bdev;
+		return 1;
+	}
+	ndevs = sbi->s_ndevs;
+	if (WARN_ON_ONCE(ndevs > FSCRYPT_MAX_DEVICES))
+		ndevs = FSCRYPT_MAX_DEVICES;
 
-	for (i = 0; i < sbi->s_ndevs; i++)
+	for (i = 0; i < ndevs; i++)
 		devs[i] = FDEV(i).bdev;
-	*num_devs = sbi->s_ndevs;
-	return devs;
+	return ndevs;
 }
 
 static const struct fscrypt_operations f2fs_cryptops = {
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 54712ec61ffb7..f6b235cd72b45 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -57,6 +57,9 @@ struct fscrypt_name {
 /* Maximum value for the third parameter of fscrypt_operations.set_context(). */
 #define FSCRYPT_SET_CONTEXT_MAX_SIZE	40
 
+/* Maximum supported number of block devices per filesystem */
+#define FSCRYPT_MAX_DEVICES	8
+
 #ifdef CONFIG_FS_ENCRYPTION
 
 /* Crypto operations for filesystems */
@@ -181,21 +184,20 @@ struct fscrypt_operations {
 	bool (*has_stable_inodes)(struct super_block *sb);
 
 	/*
-	 * Return an array of pointers to the block devices to which the
-	 * filesystem may write encrypted file contents, NULL if the filesystem
-	 * only has a single such block device, or an ERR_PTR() on error.
+	 * Retrieve the list of block devices to which the filesystem may write
+	 * encrypted file contents.
 	 *
-	 * On successful non-NULL return, *num_devs is set to the number of
-	 * devices in the returned array.  The caller must free the returned
-	 * array using kfree().
+	 * This writes the block_device pointers to @devs and returns the count
+	 * (between 1 and FSCRYPT_MAX_DEVICES inclusively).
 	 *
 	 * If the filesystem can use multiple block devices (other than block
 	 * devices that aren't used for encrypted file contents, such as
 	 * external journal devices), and wants to support inline encryption,
 	 * then it must implement this function.  Otherwise it's not needed.
 	 */
-	struct block_device **(*get_devices)(struct super_block *sb,
-					     unsigned int *num_devs);
+	unsigned int (*get_devices)(
+		struct super_block *sb,
+		struct block_device *devs[FSCRYPT_MAX_DEVICES]);
 };
 
 int fscrypt_d_revalidate(struct inode *dir, const struct qstr *name,

base-commit: f2ec6312bf711369561bdcb22f8a63c0b118c479
-- 
2.55.0

