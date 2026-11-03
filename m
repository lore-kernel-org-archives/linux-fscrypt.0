Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.112
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793719930;
	b=idbfs4xdwjXxGicWxwFP8OAI2KlSVxd+vNHTjX+TA6WFyZExU33VkUuPZ9Dht4MnWeEA
	 5eVNZDRA+TFJqK+nrevYF6cC/0Rbde1USZpW10Pe8ghPWzXeuZV0n9b5MMF5ZEaSY6dIC
	 3pnktbispWCfm6djjwh8Si3jj1UkMKXHgeUd/j8R5uz4zXMmWg50Rcb5+rOF3YFZaUTCD
	 KeyShCuypE/oVqRwWdjK2pgR8CgzsaY8wtKX0obwE1RiEpNrvK/J628Q2iK3owralhrmD
	 GMsrlVJc5g4lkMohY7w19DESIaEhm3IxFBUWTsJ5w2aOmOxXoUBeCkoZTwoSKXc9UJQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793719930;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=HhW7OF5fcY0inp+RTgNEFBoG2gh1YkTFBmuR8haWWkk=;
	b=qWIe9eAustUTPsbOUMEYU4ieasJeg65aW86cdBj+V/1TW/WDw8N/gM/x+H6w3X93cEoj
	 4UKmYvssvz9fM4Ll1rXE9mcIc27VLIDI0OsoHmHSdu5vhmQFZQ+bmKs1lMU+z9MFjRa1c
	 TbZhY/7oF+cvLKsFqZbpY+9rPpXu7ORcrmaVYwPZrnALayZophKBtEQtBwsfFpJVSUaAq
	 iKTBu/3XiWdTXto2Fzd3sJYPivPL7QjmJE7t4YvJ696jeSyxRRnUp3YjrVuwYCONL78Tq
	 sspVzcfXb2u33pmuaaljWuytECNeWUpPl/MKLcfFWFXbY71K4L33ZTbi2epYkeCZe4g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b="HMI/HcPt";
	arc=none smtp.remote-ip=115.124.30.112
Received: from out30-112.freemail.mail.aliyun.com (out30-112.freemail.mail.aliyun.com [115.124.30.112])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 89A0C606A327;
	Tue,  3 Nov 2026 15:32:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 89A0C606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=HMI/HcPt
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1793719924; h=From:To:Subject:Date:Message-ID:MIME-Version;
	bh=HhW7OF5fcY0inp+RTgNEFBoG2gh1YkTFBmuR8haWWkk=;
	b=HMI/HcPtY6SJbMun0y9jArdloNYyaf9i4xI99pZEek9mumOC/nr3oyio+0668MIQ6m/wDl9+RDW1TSoTfFl8BRc8PKS4GaczzU1VjeDLt6JNC0/zMyz9hAoClu6RC21RytyucMcngOIJErOLkXwMk34Q+3DwZ4ignbSS9A07dqA=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R401e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045133197;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0XE3LUTe_1793719922;
Received: from x31h02109.sqa.na131.tbsite.net(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XE3LUTe_1793719922 cluster:ay36)
          by smtp.aliyun-inc.com;
          Tue, 03 Nov 2026 23:32:03 +0800
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
Subject: [PATCH 1/4] fscrypt: Cap data units at the page size
Date: Tue,  3 Nov 2026 23:31:29 +0800
Message-ID: <20261103153132.4154855-2-libaokun@linux.alibaba.com>
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

blk-crypto-fallback cannot handle a data unit larger than a page:
it walks the bio one page-sized segment at a time, so a data unit
that spans multiple pages never ends on a segment boundary and
the bio fails with BLK_STS_INVAL after the I/O was already
reported to userspace as successful, losing data.

Fix this in fscrypt_supported_v2_policy() by rejecting any v2 policy
that explicitly specifies a data unit size larger than the page size.

A v1 policy always uses the block size as its data unit size,
so fscrypt_supported_v1_policy() has to reject any v1 policy on
a filesystem with a block size larger than the page size (e.g. ext4).

A v2 policy with no data unit size specified uses the block size too,
but rejection is not necessary there: sub-block data units are
supported, so it is enough to cap the data unit bits at PAGE_SHIFT in
fscrypt_policy_v2_du_bits().

Note that a filesystem whose block size exceeds 4K then cannot be
made compatible across page sizes (e.g. 4K and 64K); this can be
avoided by explicitly specifying a data unit size of 4K or smaller.

Suggested-by: Eric Biggers <ebiggers@kernel.org>
Link: https://lore.kernel.org/r/20261015185325.GG2170687@google.com
Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
---
 Documentation/filesystems/fscrypt.rst | 19 +++++++++++++++----
 fs/crypto/fscrypt_private.h           |  4 +++-
 fs/crypto/policy.c                    | 11 ++++++++++-
 3 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index 6e2e511a70bb..78251a9706ba 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -649,8 +649,9 @@ This structure must be initialized as follows:
   Not all filesystems support setting ``log2_data_unit_size``.  ext4
   and f2fs support it since Linux v6.7.  On filesystems that support
   it, the supported nonzero values are 9 through the log2 of the
-  filesystem block size, inclusively.  The default value of 0 selects
-  the filesystem block size.
+  filesystem block size, inclusively, but no greater than the log2 of
+  the page size.  The default value of 0 selects the filesystem block
+  size, or the page size if the block size is larger.
 
   The main use case for ``log2_data_unit_size`` is for selecting a
   data unit size smaller than the filesystem block size for
@@ -659,8 +660,18 @@ This structure must be initialized as follows:
   useful for checking which data unit sizes are supported by a
   particular system's inline encryption hardware.
 
-  Leave this field zeroed unless you are certain you need it.  Using
-  an unnecessarily small data unit size reduces performance.
+  A v1 policy has no ``log2_data_unit_size`` and always uses the
+  filesystem block size, so it cannot be used on a filesystem whose
+  block size is larger than the page size.
+
+  A v2 policy on such a filesystem falls back to the page size, so
+  the data unit size depends on the machine's page size and the data
+  becomes unreadable elsewhere.  An image portable across page sizes
+  should explicitly specify a data unit size of 4096 or smaller.
+
+  Leave this field zeroed unless you are certain one of the reasons
+  above applies.  Using an unnecessarily small data unit size reduces
+  performance.
 
 - For v2 encryption policies, ``__reserved`` must be zeroed.
 
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index e602c31b3844..0dc158563e71 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -203,7 +203,9 @@ static inline int
 fscrypt_policy_v2_du_bits(const struct fscrypt_policy_v2 *policy,
 			  const struct inode *inode)
 {
-	return policy->log2_data_unit_size ?: inode->i_blkbits;
+	if (policy->log2_data_unit_size)
+		return policy->log2_data_unit_size;
+	return min_t(unsigned int, inode->i_blkbits, PAGE_SHIFT);
 }
 
 static inline int
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index 6dd510f93e6d..84c496da248e 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -228,6 +228,14 @@ static bool fscrypt_supported_v1_policy(const struct fscrypt_policy_v1 *policy,
 		return false;
 	}
 
+	if (inode->i_sb->s_cop->is_block_based &&
+	    inode->i_blkbits > PAGE_SHIFT) {
+		/* v1 has no way to select a sub-block data unit size. */
+		fscrypt_warn(inode,
+			     "v1 policies can't be used on fs with block size > page size");
+		return false;
+	}
+
 	return true;
 }
 
@@ -270,7 +278,8 @@ static bool fscrypt_supported_v2_policy(const struct fscrypt_policy_v2 *policy,
 			return false;
 		}
 		if (policy->log2_data_unit_size > inode->i_blkbits ||
-		    policy->log2_data_unit_size < SECTOR_SHIFT /* 9 */) {
+		    policy->log2_data_unit_size < SECTOR_SHIFT /* 9 */ ||
+		    policy->log2_data_unit_size > PAGE_SHIFT) {
 			fscrypt_warn(inode,
 				     "Unsupported log2_data_unit_size in encryption policy: %d",
 				     policy->log2_data_unit_size);
-- 
2.43.7

