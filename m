Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.101
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793719930;
	b=m5oRY6nH8FcRXRFKjSYRtICXAUvVegMZv6LekBkhoXgf0QDkgLCvaBSg7AaGa56p5YR+
	 VkzbiejTMv8mMg9ty3TUS0Fq7YXF5dFCRcGAyQpSejhJEpTHummPMTXEZ290HkrqY547Q
	 zPE4eXG+sHrhK8D3mXLhd6jbCwB0FwBqw2t+c8ECApo2AgMp1jyhzpxNss50E6QANtnqF
	 eblG5dD75oAXET1wn/6EHldkrYrKhnwWP3RM8m3Gydvz4sKdrs9qlbA+TrQjxN0HBYZ30
	 rSjoQF1orZaS0FyDhL4/PjGVM26vsAW4XoK+KjahjVxaGA5JLSyEGGCt0uGKt5jkS0A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793719930;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=W/VFX91pctIfWD7fpu6N5oVroliWFabFtdCdTHpQeHI=;
	b=L0qyseeU1T9CJPu62w5YtZ6wRCrM+/lT4K1QpAQpcYLUveaGfcv1G8qiqf5s9mdr+rRR
	 8T1hYV0bf9B0ASDGx6ZlC2INyJnsErTonT6dDkN2tOD1JCW7LvsziSF8uDSr7XIyRKttK
	 IjFJNYPr23Am34RpgDID0EHRbOJFYKZGa/EuQK1Sw/q2m/valteMTJkt91qicKsSn++nb
	 htGvETDKRxOCUMnDB7mcw+Wf8TrJlLPe5fMjW73JZ17UPqejvBZ2MGJXEVb3tv83xySiP
	 UPwWbyidr58dXj17ft3RGL2RRXf5t3/C8sELG9/Gfit6IkX/Yce4PCMpj1K8+ptgkZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=wOkLMJHk;
	arc=none smtp.remote-ip=115.124.30.101
Received: from out30-101.freemail.mail.aliyun.com (out30-101.freemail.mail.aliyun.com [115.124.30.101])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8BFBD606A328;
	Tue,  3 Nov 2026 15:32:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8BFBD606A328
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=wOkLMJHk
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1793719926; h=From:To:Subject:Date:Message-ID:MIME-Version;
	bh=W/VFX91pctIfWD7fpu6N5oVroliWFabFtdCdTHpQeHI=;
	b=wOkLMJHk2D8a0+eU/75yKonrrQhBQ6uYQuWhlQr9dbt+7NyEZUin+S46dOPkRp9b5eE62HU3brWv0lUyQ1rq5wyfx7pqDKw2+eCgufx/nFALTlzbaXlLcb5ck+6TNbFv7RVmbshEuWKtE3cFvbU0TGv/xMJe5INhmnTjTN/N7bw=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037026112;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0XE3LUUU_1793719925;
Received: from x31h02109.sqa.na131.tbsite.net(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XE3LUUU_1793719925 cluster:ay36)
          by smtp.aliyun-inc.com;
          Tue, 03 Nov 2026 23:32:05 +0800
From: Baokun Li <libaokun@linux.alibaba.com>
To: linux-fscrypt@vger.kernel.org
Cc: ebiggers@kernel.org,
	jaegeuk@kernel.org,
	tytso@mit.edu,
	linux-ext4@vger.kernel.org,
	adilger.kernel@dilger.ca,
	jack@suse.cz,
	yi.zhang@huawei.com,
	ojaswin@linux.ibm.com,
	ritesh.list@gmail.com,
	linux-kernel@vger.kernel.org
Subject: [PATCH 4/4] ext4: allow large folios and bs > ps encryption
Date: Tue,  3 Nov 2026 23:31:32 +0800
Message-ID: <20261103153132.4154855-5-libaokun@linux.alibaba.com>
X-Mailer: git-send-email 2.43.7
In-Reply-To: <20261103153132.4154855-1-libaokun@linux.alibaba.com>
References: <20261103153132.4154855-1-libaokun@linux.alibaba.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ext4 refuses encryption when the block size exceeds the page size
in three places: at mount time (ext4_check_large_folio()),
in ext4_set_context(), and in __ext4_iget().

Sub-block data units are now enabled by default, so encryption
works on a filesystem whose block size exceeds the page size.
Remove the three checks; stable trees should keep them and
not backport this feature.

ext4_set_max_mapping_order() now runs on every mount, and
the preceding patch routes a folio that crosses a DUN wraparound
to the buffer_head path. Encrypted files therefore get the same
large folio orders as unencrypted files, including when block size
is larger than page size.

Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
---
 fs/ext4/crypto.c |  9 ---------
 fs/ext4/inode.c  |  6 ------
 fs/ext4/super.c  | 22 +---------------------
 3 files changed, 1 insertion(+), 36 deletions(-)

diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
index 318b2eaea741..1a0fccb084ef 100644
--- a/fs/ext4/crypto.c
+++ b/fs/ext4/crypto.c
@@ -156,15 +156,6 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 	if (ext4_test_inode_flag(inode, EXT4_INODE_DAX))
 		return -EOPNOTSUPP;
 
-	/*
-	 * Encryption is not supported when the block size is larger
-	 * than the page size.  This is rejected at mount time by
-	 * ext4_check_large_folio(), and this check here is for the case
-	 * when the 'encrypt' feature is enabled on a mounted filesystem.
-	 */
-	if (inode->i_sb->s_blocksize > PAGE_SIZE)
-		return -EOPNOTSUPP;
-
 	res = ext4_convert_inline_data(inode);
 	if (res)
 		return res;
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 10cd85d4c721..b4d581aa5ee1 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -6571,12 +6571,6 @@ struct inode *__ext4_iget(struct super_block *sb, unsigned long ino,
 		ret = -EFSCORRUPTED;
 		goto bad_inode;
 	}
-	if (IS_ENCRYPTED(inode) && sb->s_blocksize > PAGE_SIZE) {
-		ext4_error_inode(inode, function, line, 0,
-				 "encrypted inode with block size larger than page size");
-		ret = -EFSCORRUPTED;
-		goto bad_inode;
-	}
 
 	ext4_set_inode_mapping_order(inode);
 
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 9cae52471dee..ba2d2e184d3a 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -5165,24 +5165,6 @@ static void ext4_set_max_mapping_order(struct super_block *sb)
 		sbi->s_max_folio_order = EXT4_MAX_PAGECACHE_ORDER(sb);
 }
 
-static int ext4_check_large_folio(struct super_block *sb)
-{
-	const char *err_str = NULL;
-
-	if (ext4_has_feature_encrypt(sb))
-		err_str = "encrypt";
-
-	if (!err_str) {
-		ext4_set_max_mapping_order(sb);
-	} else if (sb->s_blocksize > PAGE_SIZE) {
-		ext4_msg(sb, KERN_ERR, "bs(%lu) > ps(%lu) unsupported for %s",
-			 sb->s_blocksize, PAGE_SIZE, err_str);
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
 static int ext4_load_super(struct super_block *sb, ext4_fsblk_t *lsb,
 			   int silent)
 {
@@ -5461,9 +5443,7 @@ static int __ext4_fill_super(struct fs_context *fc, struct super_block *sb)
 
 	ext4_apply_options(fc, sb);
 
-	err = ext4_check_large_folio(sb);
-	if (err < 0)
-		goto failed_mount;
+	ext4_set_max_mapping_order(sb);
 
 	err = ext4_encoding_init(sb, es);
 	if (err)
-- 
2.43.7

