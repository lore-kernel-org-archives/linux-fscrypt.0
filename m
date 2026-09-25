Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BFCA4AA032;
	Fri, 25 Sep 2026 14:20:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790346013; cv=none; b=FeOhEVD8e8/cJCL0B2YNpW4FKVngSYJwkCmupgbpdg3Y7EGAeQg/2rqI20piWjq9MxBmZATWJ4Hi/XURia+kimTYr7yHqCuq2RDtczkQT5imbejIlyHldb3NKYtaIhFWBdc9D6ddB567F2Tq2iOibObi/nhESU1fZj6+Ug86xLU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790346013; c=relaxed/simple;
	bh=GcVTtEi8b0ZdUojHhrR1Wc/h+lQ+LWYWTg80TrEuLgc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rCwcd8nNWvmS0QnQwty8y7kArh5F00b7Qd5JuvlwOHgEufYn5ayu2+mbSgRTGwwRZiPzJTUh3VzNXhqlCQ6BS+/gUoTLHc3WqY5TVEeOWz4p4ZCcRg3ZsWerJWeQBZ+divXdKplzkKivfjo8w1NMEHi/w3Rlbuojdf9fw78ETGM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=gLg7jz12; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="gLg7jz12"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Content-Transfer-Encoding:MIME-Version:Message-ID:Date:Subject:
	Cc:To:From:From:Reply-To; bh=I+chnCazZmQwQElFyekWrYnhtyuiFAkFedch2oPTV3k=; b=
	gLg7jz12tI9WhlnLOGW9EFmh+m9RaJM7r0x6afrzNCO/vtPKb/FkXVJPZCsc79RdE4vG5YLy32yDq
	VNGSyDbITPgnvjazM5z69HPf+5F53glU54bzwbeovJK+VKqApKZUiOn+YAsRtCDOr82sRwFiw12Vo
	44u4BeeGcPj0pEdVZ3sIbwg8HnlGkL9c1mdRCd+VpE07c0PRNokcl1QJQoj4gs8DfF/JuEAJGcM1q
	kSt9UbfaJZJ8nm0uAmOwIfEpkpkMgGVjFxr3h/odSMjRizrbeTKjWEKWOQRIvfQpSNPP0x/lEmvAI
	npkVaAN7BhbcVBVPnJwrnvG5kasGZnYdeA==;
Received: from ip40.wifi.igalia.com ([192.168.12.40] helo=zeus.local)
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1xA6mA-007B5Z-Il; Fri, 25 Sep 2026 16:19:46 +0200
Received: from berto by zeus.local with local (Exim 4.98.2)
	(envelope-from <berto@igalia.com>)
	id 1xA6mA-000000065Ti-0gTv;
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
	linux-ext4@vger.kernel.org,
	stable@vger.kernel.org
Subject: [PATCH 1/2] ext4: refuse encryption when block size > page size
Date: Fri, 25 Sep 2026 16:19:18 +0200
Message-ID: <093b40e9df29fc102907092f4ff73461f4cfcbfd.1790343958.git.berto@igalia.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <cover.1790343958.git.berto@igalia.com>
References: <cover.1790343958.git.berto@igalia.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Encryption is not supported when a filesystem's block size is larger
than the page size, and commit 709f0f1f1bf5 ("ext4: add checks for
large folio incompatibilities when BS > PS") added a check to refuse
mounting such a filesystem.

However, it is also possible to enable the "encrypt" feature on a
filesystem that is already mounted (with tune2fs -O encrypt). Once
that happens it won't be possible to mount the filesystem again in
the future, but there is nothing preventing the user from setting an
encryption policy while the filesystem is still mounted.

Fix this by refusing to set an fscrypt context in ext4_set_context()
when the block size is larger than the page size.

Fixes: 709f0f1f1bf5 ("ext4: add checks for large folio incompatibilities when BS > PS")
Cc: stable@vger.kernel.org # v6.19+
Signed-off-by: Alberto Garcia <berto@igalia.com>
---
 fs/ext4/crypto.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
index 1a0fccb084ef..318b2eaea741 100644
--- a/fs/ext4/crypto.c
+++ b/fs/ext4/crypto.c
@@ -156,6 +156,15 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 	if (ext4_test_inode_flag(inode, EXT4_INODE_DAX))
 		return -EOPNOTSUPP;
 
+	/*
+	 * Encryption is not supported when the block size is larger
+	 * than the page size.  This is rejected at mount time by
+	 * ext4_check_large_folio(), and this check here is for the case
+	 * when the 'encrypt' feature is enabled on a mounted filesystem.
+	 */
+	if (inode->i_sb->s_blocksize > PAGE_SIZE)
+		return -EOPNOTSUPP;
+
 	res = ext4_convert_inline_data(inode);
 	if (res)
 		return res;
-- 
2.47.3

