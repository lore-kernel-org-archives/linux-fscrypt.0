Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 312833559F8;
	Sat, 18 Jul 2026 21:49:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784411349; cv=none; b=BQRiuPQ2rj6KXmD4kSTOgZSAEiYi5cFaMVN27yAsiWjTFDG35HmrwHS/aZembrlwQ/Bz40mXpkrkD1lEwGqbYL/SYuxtOopYjCpsQMppmYLUOnhRwB4pSqu/gdcrvyOKSHkZT796QxwOnuLsmWNYQIyvj9uRMdeEPqzp2sqIpx4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784411349; c=relaxed/simple;
	bh=mpB1HsEp/3UwPA0bfDe6SFN3HyroYngcJu2Av3xhL1k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uuJ1yABrx4aD8qbtkQG4Yftossgn9IZcaZiX2ouwNlxwMByIvPepjRXvCh+/GROsiGnGmnNs8MEvYHrEvGmfapRN2FJcb0O/YWDgSGfiqHbaO0w/bkseWWhpNC3LekByJNU40g8QD++ARkLM9lZKPd8UVGnJsoe2drPwztxJFSM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iGBAPnID; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iGBAPnID"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1BFF31F00A3A;
	Sat, 18 Jul 2026 21:49:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784411348;
	bh=uW5iv+RSEE3wkKPr35Uyq8ZKU+zS5v45Ej8aa0FV85o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iGBAPnIDkeUCGJ4C6s2rAeTwuIIqBg7BGPGO/NkGiv5XaKIOietmFCfV72kQjcIlH
	 +fxOHyhPvu3BESJ+0bCAK9aq/Bi6XzMsgUc+QLQJjtl3QxxzVqvG6pCT7FUwLc84SE
	 Sy7V333TtkhLFsiX0tz7lzWPyKGwYtFB3Ig8AvRbEee4hFnA/LvkjHimQfpA7sXai2
	 ofi4gd60KS0yuIRMNchjjQFuRxI79UMs0X00F2Y9aTCD6j07lHajdEIQ+IGX0ONHJE
	 fua23sD4qPDkVoNBO3TvuRwsXOlUD7TivFNJtj/XkJqID8KBmDsTPCuxvxelgsrxXH
	 y6ce2XzYB1CaA==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-doc@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 5/6] blk-crypto: Remove unused function blk_crypto_config_supported()
Date: Sat, 18 Jul 2026 14:46:54 -0700
Message-ID: <20260718214655.63186-6-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260718214655.63186-1-ebiggers@kernel.org>
References: <20260718214655.63186-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

blk_crypto_config_supported() is no longer called, so remove it.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 Documentation/block/inline-encryption.rst | 29 ++++++++---------------
 block/blk-crypto.c                        | 14 -----------
 include/linux/blk-crypto.h                |  2 --
 3 files changed, 10 insertions(+), 35 deletions(-)

diff --git a/Documentation/block/inline-encryption.rst b/Documentation/block/inline-encryption.rst
index cae23949a626..0052c7011b48 100644
--- a/Documentation/block/inline-encryption.rst
+++ b/Documentation/block/inline-encryption.rst
@@ -185,20 +185,12 @@ blk-crypto-fallback is optional and is controlled by the
 API presented to users of the block layer
 =========================================
 
-``blk_crypto_config_supported()`` allows users to check ahead of time whether
-inline encryption with particular crypto settings will work on a particular
-block_device -- either via hardware or via blk-crypto-fallback.  This function
-takes in a ``struct blk_crypto_config`` which is like blk_crypto_key, but omits
-the actual bytes of the key and instead just contains the algorithm, data unit
-size, etc.  This function can be useful if blk-crypto-fallback is disabled.
-
 ``blk_crypto_init_key()`` allows users to initialize a blk_crypto_key.
 
 Users must call ``blk_crypto_start_using_key()`` before actually starting to use
-a blk_crypto_key on a block_device (even if ``blk_crypto_config_supported()``
-was called earlier).  This is needed to initialize blk-crypto-fallback if it
-will be needed.  This must not be called from the data path, as this may have to
-allocate resources, which may deadlock in that case.
+a blk_crypto_key on a block_device.  This is needed to initialize
+blk-crypto-fallback if it will be needed.  This must not be called from the data
+path, as this may have to allocate resources, which may deadlock in that case.
 
 Next, to attach an encryption context to a bio, users should call
 ``bio_crypt_set_ctx()``.  This function allocates a bio_crypt_ctx and attaches
@@ -220,16 +212,15 @@ any kernel data structures it may be linked into.
 In summary, for users of the block layer, the lifecycle of a blk_crypto_key is
 as follows:
 
-1. ``blk_crypto_config_supported()`` (optional)
-2. ``blk_crypto_init_key()``
-3. ``blk_crypto_start_using_key()``
-4. ``bio_crypt_set_ctx()`` (potentially many times)
-5. ``blk_crypto_evict_key()`` (after all I/O has completed)
-6. Zeroize the blk_crypto_key (this has no dedicated function)
+1. ``blk_crypto_init_key()``
+2. ``blk_crypto_start_using_key()``
+3. ``bio_crypt_set_ctx()`` (potentially many times)
+4. ``blk_crypto_evict_key()`` (after all I/O has completed)
+5. Zeroize the blk_crypto_key (this has no dedicated function)
 
 If a blk_crypto_key is being used on multiple block_devices, then
-``blk_crypto_config_supported()`` (if used), ``blk_crypto_start_using_key()``,
-and ``blk_crypto_evict_key()`` must be called on each block_device.
+``blk_crypto_start_using_key()`` and ``blk_crypto_evict_key()`` must be called
+on each block_device.
 
 API presented to device drivers
 ===============================
diff --git a/block/blk-crypto.c b/block/blk-crypto.c
index 0fe6ef0eea1d..bc3a9f59574b 100644
--- a/block/blk-crypto.c
+++ b/block/blk-crypto.c
@@ -386,20 +386,6 @@ bool blk_crypto_config_supported_natively(struct block_device *bdev,
 	return true;
 }
 
-/*
- * Check if bios with @cfg can be en/decrypted by blk-crypto (i.e. either the
- * block_device it's submitted to supports inline crypto, or the
- * blk-crypto-fallback is enabled and supports the cfg).
- */
-bool blk_crypto_config_supported(struct block_device *bdev,
-				 const struct blk_crypto_config *cfg)
-{
-	if (IS_ENABLED(CONFIG_BLK_INLINE_ENCRYPTION_FALLBACK) &&
-	    cfg->key_type == BLK_CRYPTO_KEY_TYPE_RAW)
-		return true;
-	return blk_crypto_config_supported_natively(bdev, cfg);
-}
-
 /**
  * blk_crypto_start_using_key() - Start using a blk_crypto_key on a device
  * @bdev: block device to operate on
diff --git a/include/linux/blk-crypto.h b/include/linux/blk-crypto.h
index 5f40821f99cd..938ff536838c 100644
--- a/include/linux/blk-crypto.h
+++ b/include/linux/blk-crypto.h
@@ -171,8 +171,6 @@ void blk_crypto_evict_key(struct block_device *bdev,
 
 bool blk_crypto_config_supported_natively(struct block_device *bdev,
 					  const struct blk_crypto_config *cfg);
-bool blk_crypto_config_supported(struct block_device *bdev,
-				 const struct blk_crypto_config *cfg);
 
 int blk_crypto_derive_sw_secret(struct block_device *bdev,
 				const u8 *eph_key, size_t eph_key_size,
-- 
2.55.0

