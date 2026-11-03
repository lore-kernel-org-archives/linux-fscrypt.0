Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.100
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793719930;
	b=Uw+FA+jgW3npUx6UKY1nHimpshpt52X35qaWFZLYzGdo47j9D9n+oMNJUJPsqgVwecCa
	 P17nQBXPAxkJkRkt4QCWtHKQXwatGYhf+sWQy+m/WZDIdN88B9PJ4BVhqZtgYs8pDW61C
	 WzMfJ9/N35XBPOphVVJDVt3e6Ua5PA/5/0XAMe+ErXfIiVx0dCfHnaQUcDiGwjb8wTnq9
	 1LQB7sWDau1sGkhwQ8LQz3SvLOxqDCO/Rs1v1o23vKK5AaqBBBluqpQf7Ezent8r+PyTk
	 ARBsEIG8SxPoLd/n+8dXeBWKaNbVDAL3NRHzip6kmcVBF6xjjiMxpuiHAJBmVDBHWOw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793719930;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=X5ZpIgBof+TLGiClZWygRJ4L7+XLfmAF6PbPLumsy60=;
	b=qO7Z/mfxMupjy+tgiiG3NTDBtvkdyYTiyahTpXyD4PZN7z2V8MotpCgG77b1A9ymVJgI
	 ZA1CJODV8x0ip6XP0egY+MENARmxIEmd17Jp2AE3yi9AmyiO+hal0Iv/RgWi8zpUrLwqp
	 qiSNMSfzANfL/69XEJeJGlTHTMYytbSmMExfdaLssCVvfrx8zieaJa3o8+SFkNg01CyXJ
	 1yFjBP3QMetN2Qmp2nx5Z5nPBLrwTdZWLy33A+945G2nlfcOTRNP0C2QJF6ERbh8dq0p0
	 /+NVyltdJwXjouq2omVH8+Pc2D3pJOkaJVNIutrLFtQgmefuy4XozCpUeiHHOcv1FAg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=yG6YTb9a;
	arc=none smtp.remote-ip=115.124.30.100
Received: from out30-100.freemail.mail.aliyun.com (out30-100.freemail.mail.aliyun.com [115.124.30.100])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96140606A329;
	Tue,  3 Nov 2026 15:32:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 96140606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=yG6YTb9a
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1793719925; h=From:To:Subject:Date:Message-ID:MIME-Version;
	bh=X5ZpIgBof+TLGiClZWygRJ4L7+XLfmAF6PbPLumsy60=;
	b=yG6YTb9aoQwYZb9xNoSaoTm3TbglTApLjqgs8Mm5Oquan+Bd9uUUONdbhpswFOCgK4ev6Rmu6RGSO5N8YZ3aNvNvtpRJFIzOxyeN/LfjcNDLlKD0rwLKwbmVcc1j8xQFH0/HujPmz74FieUx2r9jl2jLxA+LAV3jSJN2G58YN74=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R821e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037033178;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0XE3LUUD_1793719924;
Received: from x31h02109.sqa.na131.tbsite.net(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XE3LUUD_1793719924 cluster:ay36)
          by smtp.aliyun-inc.com;
          Tue, 03 Nov 2026 23:32:04 +0800
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
Subject: [PATCH 3/4] ext4: don't put a DUN wraparound in the middle of a read bio
Date: Tue,  3 Nov 2026 23:31:31 +0800
Message-ID: <20261103153132.4154855-4-libaokun@linux.alibaba.com>
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

Under IV_INO_LBLK_32, a file's DUNs wrap at 2^32, and the policy
is only allowed when the block size equals the page size.

ext4_mpage_readpages() adds a whole folio to one bio, but checks
only the DUN of the first block. blk-crypto assumes the DUNs
in a bio are contiguous and never wraps them, so blocks past
the wraparound are read with the wrong DUNs.

Writeback and direct I/O get this right, but with large folios
a single folio can still span the wraparound.

Fix this by routing such a folio through the buffer_head path,
which submits one bio per block and so gives each block its own DUN.

fscrypt_limit_io_blocks() tells whether the wraparound falls after
the first block; a wraparound at the first block itself is already
caught by fscrypt_mergeable_bio().

A file's DUNs wrap at most once, so at most one folio per file takes
the slower path, and the per-block bios can be merged again by the
block layer.

Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
---
 fs/ext4/readpage.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index c7b6cdb2e124..43af6d9d6ddb 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -264,6 +264,16 @@ static int ext4_mpage_readpages(struct inode *inode, struct fsverity_info *vi,
 			folio_set_mappedtodisk(folio);
 		}
 
+		/*
+		 * blk-crypto assumes a bio's DUNs are contiguous, but under
+		 * IV_INO_LBLK_32 alone they wrap at 2^32.  A folio spanning
+		 * the wrap would be decrypted with wrong IVs, so it goes to
+		 * the buffer_head-based path, one bio per block.
+		 */
+		if (first_hole >
+		    fscrypt_limit_io_blocks(inode, pos >> blkbits, first_hole))
+			goto confused;
+
 		/*
 		 * This folio will go to BIO.  Do we need to send this
 		 * BIO off first?
-- 
2.43.7

