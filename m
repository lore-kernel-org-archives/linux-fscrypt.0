Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D9DB3B6354;
	Fri, 25 Sep 2026 14:20:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790346012; cv=none; b=e/hHTA2V6uHBoUes6Oiy4hTuIH9yx9/hgJwWJ5r0B1O5PMHFjdFmVUyflnnsFxw7z7j7bLcH/UZvp7YFBppJWHd2eXebHliAmY2GX6vvAut3NVpmrRHZ+80e4nJFUJbKqy4X2ts6OFyB/b3/zIa1Dr5q4WO18qhf0LKY3SzXb6M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790346012; c=relaxed/simple;
	bh=8Tlt/Xs/lnHxi6mpME7i6h7KxXZvDx1I51vC8Ed+D28=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=HBpFcgK2O7RZu3DQYyDMb22JdF41NuwkrGK9icitOqsG9PtI5dAQZpLRS3B5x/4wBnWq2DpvHZdmxPZ7xtCyBVQQxQySkS4jo1t66m0bwJEP1fAPfRvRBE8EMulSxRFpMq+i1yoxx8kAa8JnLDAzJ0RhhTtl6SNUNV/CAvi5rMY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=pEv09GjQ; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="pEv09GjQ"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Content-Transfer-Encoding:MIME-Version:Message-ID:Date:Subject:
	Cc:To:From:From:Reply-To; bh=zOjagqsbVpNgX2XaI8021zvpIWajVqwPcnsMhNeTeW8=; b=
	pEv09GjQjsTk9YzLtkW/UeU3lXbfkYys6JUeux+z/UbwojQMedCQd0be+XLnYoZFUTf0fcvhhyYWy
	9wlAqnWTIO+l/prP6R2NosWix/1TvZpoxtQ7PMYaIcuCUXyrbbPfyiqQdLCmnPB1zM08sPSYGt4aE
	ghzmCrpa5dKirL0ze/pYCAzb6oFBSW8+USbk9bczyf2yWNVw0jvgQ8ej/m+LOG/eJnpGp+Qg8wqgR
	eYvYjzlmemHdQa6fRQVpqokz/ZRYrL9RQtoSjkK6Sw90W4wKdKzuAt+2ADrzxLwbneo6463bXJtXA
	RlYUIr4pHpLTMpSa50+OROm75D5s0sEJrQ==;
Received: from ip40.wifi.igalia.com ([192.168.12.40] helo=zeus.local)
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1xA6mA-007B5Y-Hn; Fri, 25 Sep 2026 16:19:46 +0200
Received: from berto by zeus.local with local (Exim 4.98.2)
	(envelope-from <berto@igalia.com>)
	id 1xA6mA-000000065Tf-0VY5;
	Fri, 25 Sep 2026 16:19:46 +0200
From: Alberto Garcia <berto@igalia.com>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Alberto Garcia <berto@igalia.com>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>,
	Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>,
	Eric Biggers <ebiggers@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	linux-ext4@vger.kernel.org
Subject: [PATCH 0/2] ext4: refuse encryption when block size > page size
Date: Fri, 25 Sep 2026 16:19:17 +0200
Message-ID: <cover.1790343958.git.berto@igalia.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,

encryption is not supported when a filesystem's block size is larger
than the page size. Although the kernel refuses to mount such a
filesystem if the "encrypt" feature is already set, it is possible to
enable it on a mounted filesystem with e.g. tune2fs.

# mkfs.ext4 -b 16384 /dev/vdb
# mount /dev/vdb /mnt/
# tune2fs -O encrypt /dev/vdb
# mkdir /mnt/foo
# fscrypt setup /mnt
# fscrypt encrypt /mnt/foo/
# head -c 20M /dev/urandom > /mnt/foo/data
# sync
[  116.014221] EXT4-fs warning (device vdb): ext4_end_bio:360: I/O error 19 writing to inode 19 starting block 130040)
[  116.014235] EXT4-fs (vdb): failed to convert unwritten extents to written extents -- potential data loss!  (inode 19, error -5)
[  116.014241] Buffer I/O error on device vdb, logical block 130040
[...]
[  116.014264] Buffer I/O error on device vdb, logical block 130049
[  116.015505] EXT4-fs warning (device vdb): ext4_end_bio:360: I/O error 19 writing to inode 19 starting block 66552)
[  116.015520] EXT4-fs (vdb): failed to convert unwritten extents to written extents -- potential data loss!  (inode 19, error -5)
[  116.016451] EXT4-fs warning (device vdb): ext4_end_bio:360: I/O error 19 writing to inode 19 starting block 65784)
[  116.016459] EXT4-fs (vdb): failed to convert unwritten extents to written extents -- potential data loss!  (inode 19, error -5)

This affects all kernels starting from v6.19 up to v7.3-rc4.

Note that this still allows encrypted inodes even when the 'encrypt'
feature is missing as long as block size <= page size. With v1
encryption policies they can be used normally.

There's an additional bug that only affects kernels between v6.19 and
v7.2 (but not v7.3), which will be dealt with separately.

Regards,

Berto

Alberto Garcia (2):
  ext4: refuse encryption when block size > page size
  ext4: reject encrypted inodes when block size > page size

 fs/ext4/crypto.c | 9 +++++++++
 fs/ext4/inode.c  | 6 ++++++
 2 files changed, 15 insertions(+)

-- 
2.47.3

