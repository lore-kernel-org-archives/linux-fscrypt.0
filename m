Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4511B3A75A7;
	Sun,  5 Jul 2026 19:47:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783280861; cv=none; b=SmluRATf8xVnMbiCAZPAOaygDxMQJphrR5imF8tB9uiNznKpQoxf5tfxf7Jw5q0KRYQ6HltMUT1SDQUGqoiU4uSv5M/FGh6J9La/yhMWOtSTVn+3oJ8+fk7+41SDL5O9A1f8nwUK/Ev4s8HNMEw/rb9/Eq0DTn38MqTIWLX/9mk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783280861; c=relaxed/simple;
	bh=iglCt6P81JmiRYB6Xs2OYNLq3DqcmU5dvw/r3POCit4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=q8XR4y783s9h/AvMae4U8D46B8L+2/ClzQegf8HQ6xKYOOyIAY/bBNhbYjZkJ0lguBWKCRkqZ645P5f/XmtHG6o0QfaLxpVxKMen+WN3qfs+DtjmkU1vmbPsCzijUkoJsjejFHkKHmu+BhaWJ26rffrM9lx2P8BpsMcVZNYOSXE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bkwvRjw1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bkwvRjw1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4DFBB1F00A3A;
	Sun,  5 Jul 2026 19:47:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783280859;
	bh=tKdpjr5i/RImosIY+eiFhMqxSz+elKzS2xT7ckJAoUE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=bkwvRjw1u1rp8gSn/ECS1DhIstnM96dOMOctkXi9ZJoEBiZ5NatqO9gm0NIepGdiF
	 2BZBCLA4sqWoMpbfy2xPqmS2J1Jvr5VOxgZ4kjC5DbrNnozQYD4NWByhJYtG1Rlb24
	 MyVgEn8TT7ne0TSKx3p3TEACoM6GTUbJbY6s+HCWz/YTIJ9Ug9/fmFLn5jaCvD52fi
	 dB9ldBpoTliTHkLctHksCnEnl2+Y9fTS82BEOo+ZqzAXY+/AsYmYguB3mFatir/iok
	 JJBDioWjALQGx9y8dQ2MVCPGdJfyQ2rSFDscJL0maGVf54UJlvNlR1Z9jxHfdNbPJd
	 O8xRMHslucJtg==
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
Subject: [PATCH v2 02/17] blk-crypto: Fold __blk_crypto_cfg_supported() into its caller
Date: Sun,  5 Jul 2026 12:45:39 -0700
Message-ID: <20260705194555.75030-3-ebiggers@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260705194555.75030-1-ebiggers@kernel.org>
References: <20260705194555.75030-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

__blk_crypto_cfg_supported() is called only by
blk_crypto_config_supported_natively(), so fold it in.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 block/blk-crypto-profile.c | 22 ----------------------
 block/blk-crypto.c         | 23 +++++++++++++++++++++--
 2 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/block/blk-crypto-profile.c b/block/blk-crypto-profile.c
index cf447ba4a66e..53126c091b0b 100644
--- a/block/blk-crypto-profile.c
+++ b/block/blk-crypto-profile.c
@@ -335,28 +335,6 @@ void blk_crypto_put_keyslot(struct blk_crypto_keyslot *slot)
 	}
 }
 
-/**
- * __blk_crypto_cfg_supported() - Check whether the given crypto profile
- *				  supports the given crypto configuration.
- * @profile: the crypto profile to check
- * @cfg: the crypto configuration to check for
- *
- * Return: %true if @profile supports the given @cfg.
- */
-bool __blk_crypto_cfg_supported(struct blk_crypto_profile *profile,
-				const struct blk_crypto_config *cfg)
-{
-	if (!profile)
-		return false;
-	if (!(profile->modes_supported[cfg->crypto_mode] & cfg->data_unit_size))
-		return false;
-	if (profile->max_dun_bytes_supported < cfg->dun_bytes)
-		return false;
-	if (!(profile->key_types_supported & cfg->key_type))
-		return false;
-	return true;
-}
-
 /*
  * This is an internal function that evicts a key from an inline encryption
  * device that can be either a real device or the blk-crypto-fallback "device".
diff --git a/block/blk-crypto.c b/block/blk-crypto.c
index 15e25e41b166..de60f03b4d4b 100644
--- a/block/blk-crypto.c
+++ b/block/blk-crypto.c
@@ -351,11 +351,30 @@ int blk_crypto_init_key(struct blk_crypto_key *blk_key,
 }
 EXPORT_SYMBOL_GPL(blk_crypto_init_key);
 
+/**
+ * blk_crypto_config_supported_natively() - Check whether a block device
+ *					    supports hardware inline encryption
+ *					    with the given configuration.
+ * @bdev: the block device
+ * @cfg: the crypto configuration to check for
+ *
+ * Return: %true if @bdev supports hardware inline encryption with @cfg.
+ */
 bool blk_crypto_config_supported_natively(struct block_device *bdev,
 					  const struct blk_crypto_config *cfg)
 {
-	return __blk_crypto_cfg_supported(bdev_get_queue(bdev)->crypto_profile,
-					  cfg);
+	struct blk_crypto_profile *profile =
+		bdev_get_queue(bdev)->crypto_profile;
+
+	if (!profile)
+		return false;
+	if (!(profile->modes_supported[cfg->crypto_mode] & cfg->data_unit_size))
+		return false;
+	if (profile->max_dun_bytes_supported < cfg->dun_bytes)
+		return false;
+	if (!(profile->key_types_supported & cfg->key_type))
+		return false;
+	return true;
 }
 
 /*
-- 
2.54.0

