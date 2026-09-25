Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1DB044A8A16;
	Fri, 25 Sep 2026 14:20:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790346013; cv=none; b=tK0DSB9DeHKnU6baTJ5bu3mKDo2pBQf+DViHwnJm6t/ag3GPqMvj86GEeGgCgbBJfSzJaJoQOFWCMp7Nl+gU3MVZ76oAPrUjbAp3afvaeHscwYCfwnn57+w+wbUnpd7XpeuBTDvEC4J5no4tqIlGFyIh6wP2L7aavPBzaqHezDU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790346013; c=relaxed/simple;
	bh=I2rMiwf6RZxnJqT46cQ7B0/M04KbIobpbJwq54s6TA4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=flGNR4Y1ahLnDtagZVI9AW6He+gS3s7TrIsbP3E0rf66EbgWXCDSDe1Nqxarg8o1lhNoGt/zm8UKM5ufH052+bm5XhKmV9KnLSb8ZtfDY+KDWnjpdqFBOtoJ8t/lPoLiOJ6pQqZ+6Q1q4v4WIt8JYvCtyOb7letaVOTAMOOA4UY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=pb3Jtd1B; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="pb3Jtd1B"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Content-Transfer-Encoding:MIME-Version:Message-ID:Date:Subject:
	Cc:To:From:From:Reply-To; bh=MSuQPMNvWdQGl98a8NLc2lKTCTzV0NPoj/P4up09+SY=; b=
	pb3Jtd1BmGMbhpL62V8hvHwgLVBt/zBpH7itPjaynkIwZXoTqgAjpz041wSEwlx38g0aKrO4SA3LX
	2h++2ZW5DFMuxzsYYDuQVyyguieDPnmJe4/YozL4zsTI5heOE4scQ7rhL6AH6/4MXU3kaf4OUYPFR
	9w87tFKGa0WlTIe9aTQHBgIawA/S22TUCicOO3+m3n6lrr5okcyoVDSXzpnd7wk0IIGiaQZ658GBc
	OV32uU203v2AwLEv/0G4hWnVLUI0784piceX9uzkS6/wh5lFyblAfOnleaPfgLrG1+aTKVCbqRAng
	PqnQR2RDKHzUGgAkNyV0u5o7skQCnCxL5Q==;
Received: from ip40.wifi.igalia.com ([192.168.12.40] helo=zeus.local)
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1xA6mA-007B5b-KJ; Fri, 25 Sep 2026 16:19:46 +0200
Received: from berto by zeus.local with local (Exim 4.98.2)
	(envelope-from <berto@igalia.com>)
	id 1xA6mA-000000065Tl-0pJW;
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
Subject: [PATCH 2/2] ext4: reject encrypted inodes when block size > page size
Date: Fri, 25 Sep 2026 16:19:19 +0200
Message-ID: <aeb8efa8beb72721fb4b13cffe6eb22c795ec33f.1790343958.git.berto@igalia.com>
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
than the page size. ext4_check_large_folio() refuses to mount a
filesystem like that if the "encrypt" feature is already enabled, and
ext4_set_context() refuses to create encrypted inodes if the feature
is enabled after mounting.

However, a corrupted or hand-crafted filesystem can still have
encrypted inodes even if the "encrypt" feature is not set, and those
inodes can be unlocked if they're using v1 policies.

Check this in __ext4_iget() and reject them as corrupted.

Fixes: 709f0f1f1bf5 ("ext4: add checks for large folio incompatibilities when BS > PS")
Suggested-by: Eric Biggers <ebiggers@kernel.org>
Cc: stable@vger.kernel.org # v6.19+
Signed-off-by: Alberto Garcia <berto@igalia.com>
---
 fs/ext4/inode.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 26f0f9714f03..31248fef8bce 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5671,6 +5671,12 @@ struct inode *__ext4_iget(struct super_block *sb, unsigned long ino,
 		ret = -EFSCORRUPTED;
 		goto bad_inode;
 	}
+	if (IS_ENCRYPTED(inode) && sb->s_blocksize > PAGE_SIZE) {
+		ext4_error_inode(inode, function, line, 0,
+				 "encrypted inode with block size larger than page size");
+		ret = -EFSCORRUPTED;
+		goto bad_inode;
+	}
 
 	ext4_set_inode_mapping_order(inode);
 
-- 
2.47.3

