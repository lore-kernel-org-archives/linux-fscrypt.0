Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.119
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793719928;
	b=bUzDWKRpTfRYBuX5UoJSMqNi3ncj9Xc83grBULibOMBKAVsGQ6klF9jiVbAJ2qViaEx0
	 BK+3Uvbd/fakbpaCEAjmxqFqxnCHdJ+EOHwFz9l5ZyK6pKkn5YlysH7AaRA7ZBHYO+6OD
	 AX4rWx1r9wERBQn8lp5fyz/ZWuQ9M7M5DUySID7RTbspm5oJT96DxbBQjRvEo9TsOcUCj
	 0ib5/pCUxiMeYt4DueIAtscEMZSaZrhdwH/a9Jk0DDzeF1hsoUP8ziV8+qZXMS8A3QgKX
	 7vyqE/QR6NGgNJLQNU/Y+bzI/JmXJ2oH82appB1c+3XL1rgSjInY31ajbApOexugTgA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793719928;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=HmCkZORht9awkKXevmoWlUgHYW61U//k8/StSQKTvUw=;
	b=J7/vFRacd2o/TZpWVhWZk7id5dRpEggY77Hq/El2MzdKNK6WMTycn232r97chQQrOHws
	 uyIE6vbvgn3mI7VTyjhTDAAwTOjykc+z8A4ZwK0Wh0TMhgWWgxBphbKtow/8RiqLgpRSL
	 kJCA4iHyAVYQGMtISdK4WAT+KO3mzxU6VPJaeM69DNuwVLoQQrhz8r0/2CJY1E8NNPLYZ
	 9FQOig4nxnniiN/vkmJX1P9Fo2M1YrOED9fH1QS3WzqqMYN+GFLr8Q7GYA1bFZl+IJHH/
	 lD/FfxmKBoJw7vZszumNADCYpxJZS7E/Qy41lbwh5cocvdxVLqRUlqj1Fa9ENhym3HQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=dRyzmM6J;
	arc=none smtp.remote-ip=115.124.30.119
Received: from out30-119.freemail.mail.aliyun.com (out30-119.freemail.mail.aliyun.com [115.124.30.119])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FFAA606A326;
	Tue,  3 Nov 2026 15:32:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6FFAA606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=dRyzmM6J
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1793719922; h=From:To:Subject:Date:Message-ID:MIME-Version;
	bh=HmCkZORht9awkKXevmoWlUgHYW61U//k8/StSQKTvUw=;
	b=dRyzmM6J8TnZg+N5t+K0KcLi+exL75X7ofzeUsGqnp7UGh5NaQqTqpP8Br1kErnU6HzLiDo1Xr+517jaK2FjKuiU9Kege6EPfPW2CzqAHtkxxMZ3i7oU7MaTtAOqwJgaVBHmTGVSxG7tWQ++Y6tece+UR7DmK+qYrFEh4muiIFU=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R851e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037033178;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=12;SR=0;TI=SMTPD_---0XE3LUMI_1793719892;
Received: from x31h02109.sqa.na131.tbsite.net(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XE3LUMI_1793719892 cluster:ay36)
          by smtp.aliyun-inc.com;
          Tue, 03 Nov 2026 23:32:02 +0800
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
Subject: [PATCH 0/4] ext4: support encryption with block size larger than page size
Date: Tue,  3 Nov 2026 23:31:28 +0800
Message-ID: <20261103153132.4154855-1-libaokun@linux.alibaba.com>
X-Mailer: git-send-email 2.43.7
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

Motivation
==========

Currently ext4 refuses encryption on a filesystem whose block size
is larger than page size.  The reason is in the fallback path:
fscrypt takes the fs block size as the default data  unit size,
while blk-crypto-fallback supports no data unit larger than a page.

fscrypt already supports a data unit size smaller than the block size.
So when none is specified, taking the smaller of the block size and the
page size as the data unit size is enough for fscrypt to support LBS.

Based on v7.4-rc1.

Patch Overview
==============

Patch 1: Caps the default data unit at the page size and rejects the
         policies that would exceed it.
Patch 2: Validates the test_dummy_encryption policy before applying it.
Patch 3: Sends a folio that covers a DUN wraparound to the buffer_head
         path.
Patch 4: Removes the block size > page size checks and enables large
         folios for encrypted files.

Testing
=======

kvm-xfstests -c ext4/all -g auto has been executed with no new failures.

On ext4/32k, two groups of tests fail because they are not adapted, and
no other regressions were observed:

 - the tests that use v1 policies: ext4/024, generic/395, 397, 398, 399,
   419, 421, 429, 440, 576, 580, 581, 593, 613.
 - the tests that don't explicitly set the data unit size (generic/582,
   583, 584): the kernel gets a 4K data unit by default on a 4K-page
   machine while the tests still use the block size.

With the xfstests fix, the first group is skipped and the second group
passes.  The fix will be sent separately.

Benchmark
=========

Hardware: 96-core machine, 3.84T NVMe, 512G memory
Filesystem: ext4, encryption on the fallback path

Buffered sequential 1M writes and reads (1G, fsync) in MiB/s;
medians of 3 runs.

Base tree, 4k-block filesystem:

  job         4k plain    4k enc
  --------    --------    ------
  seqwrite        1969      1418
  seqread         1021       907

LBS enabled, encrypted 4k-block vs 32k-block filesystem:

  job         4k enc    32k enc    32k plain    4k->32k
  --------    ------    -------    ---------    -------
  seqwrite      1430       1958         2138       +37%
  seqread        964       2004         1834      +108%

Buffered sequential writes (1G, fsync) of the encrypted 4k-block
filesystem across request sizes, base tree vs this series:

  fio bs    Before    After    gain
  ------    ------    -----    ----
  4k        1272      1261     -1%
  16k       1457      1803    +24%
  64k       1499      2060    +37%
  256k      1488      2103    +41%
  1M        1418      1928    +36%

Comments and questions are, as always, welcome.

Thanks,
Baokun

Baokun Li (4):
  fscrypt: Cap data units at the page size
  fscrypt: Validate the test_dummy_encryption policy for new inodes
  ext4: don't put a DUN wraparound in the middle of a read bio
  ext4: allow large folios and bs > ps encryption

 Documentation/filesystems/fscrypt.rst | 19 +++++++++++++++----
 fs/crypto/fscrypt_private.h           |  4 +++-
 fs/crypto/keysetup.c                  |  8 ++++++++
 fs/crypto/policy.c                    | 11 ++++++++++-
 fs/ext4/crypto.c                      |  9 ---------
 fs/ext4/inode.c                       |  6 ------
 fs/ext4/readpage.c                    | 10 ++++++++++
 fs/ext4/super.c                       | 22 +---------------------
 8 files changed, 47 insertions(+), 42 deletions(-)

-- 
2.43.7

