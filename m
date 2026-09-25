Received: from fanzine2.igalia.com (fanzine2.igalia.com [213.97.179.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 879D84AA570;
	Fri, 25 Sep 2026 15:32:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.97.179.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790350325; cv=none; b=WrHGVSjy8/ngi4ZPCRSAsPIouRWnj5nyi1lm6Ka4Hl9Zobp3WHtHD0xgmaP2w03XJiLcjF9IwEsrDK1KvaSYkhRqH0nkcDT6rnZrmczi4TpeLp3+pxtaV1YPxx1Jk+ZiHurgoxzSnZWSjIOmaTc8KqO7W6J5f+MuhLLXBFMjRV4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790350325; c=relaxed/simple;
	bh=++Cd2j1h2fgwiOv0UswAsmnkyWoWSPYzp2QkXdONUCc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=rgv6pPgCJeDWJtsTsSu3PyoWGkyxbhLW11caDy876dQLBjhSkNyPDRwgP3lV3SHTySHu9J+NhX2YeqEoOZHKU7EUHNMM3oDkfGEfVX82KZo0MWmvDcHgUTeaBq5+IpSwSzr+1RbsdJvfOTdCHuDjwCZvXGFmhz/AJ+Xuizlg334=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com; spf=pass smtp.mailfrom=igalia.com; dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b=NMydczQZ; arc=none smtp.client-ip=213.97.179.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=igalia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=igalia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=igalia.com header.i=@igalia.com header.b="NMydczQZ"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=igalia.com;
	s=20170329; h=Content-Transfer-Encoding:MIME-Version:Message-ID:Date:Subject:
	Cc:To:From:From:Reply-To; bh=3x6amxJB/jppu/HXcJb5mrj7oqcPlprm3G67FMdho3k=; b=
	NMydczQZyaHjqODWOgvEs3F/ZJvD8j9AmfXbre7AwptMAdJl0aC5No9ni1fxjb0IpDwz6V2FvYH04
	Oj8mBWjUFsd3a/dcUUTq9+KBbA1p4ah/4tDuln84voBQy6JdrAVYU6T6F4yayYHjscadtmxWAieM3
	q8f3yrjJJ7l5fpOiew+gtUJoawGuA14Ol7yxcQkWSCJRiVon9+BCugYrH0b208JEotwIETuHQJ20h
	YWJzZCh9cqjpTvujRArt7VWHmfkLXrH1KoEtlPHND6jppzaR+l/sApM7x7ltt57avdMKZbz9aJsj6
	rD8iKoMII1PuUND2rdZQduUxohIvoU6gww==;
Received: from ip40.wifi.igalia.com ([192.168.12.40] helo=zeus.local)
	by fanzine2.igalia.com with esmtpsa 
	(Cipher TLS1.3:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256) (Exim)
	id 1xA7tc-007Cxw-Pf; Fri, 25 Sep 2026 17:31:32 +0200
Received: from berto by zeus.local with local (Exim 4.98.2)
	(envelope-from <berto@igalia.com>)
	id 1xA7tc-00000006B1T-1ZKJ;
	Fri, 25 Sep 2026 17:31:32 +0200
From: Alberto Garcia <berto@igalia.com>
To: stable@vger.kernel.org
Cc: Alberto Garcia <berto@igalia.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>,
	Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>,
	Eric Biggers <ebiggers@kernel.org>,
	linux-ext4@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	regressions@lists.linux.dev
Subject: [PATCH 7.2.y] ext4: don't enable large folios on encrypted inodes
Date: Fri, 25 Sep 2026 17:31:25 +0200
Message-ID: <20260925153127.1472301-1-berto@igalia.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Commit 709f0f1f1bf5 ("ext4: add checks for large folio
incompatibilities when BS > PS") disables large folios at mount time
if the "encrypt" feature is set. However, enabling that feature on a
mounted filesystem circumvents that check, and writing encrypted data
results in a crash:

  BUG: kernel NULL pointer dereference, address: 0000000000000028
  Workqueue: ext4-rsv-conversion ext4_end_io_rsv_work
  RIP: 0010:ext4_finish_bio+0xf7/0x3e0
  Call Trace:
   ext4_release_io_end+0x51/0x110
   ext4_end_io_end+0x4c/0xe0
   ext4_end_io_rsv_work+0xb3/0x100

Fix this by disabling large folios on encrypted inodes, as is
already done for inodes that use data journaling.

This affects all kernels between v6.19 and v7.2, but it is not needed
in v7.3, where the code was significantly refactored.

Fixes: 709f0f1f1bf5 ("ext4: add checks for large folio incompatibilities when BS > PS")
Signed-off-by: Alberto Garcia <berto@igalia.com>
---
This affects all kernels between v6.19 and v7.2 but only the latter is
still maintained, so I think that it only needs to be applied there.

This patch has no upstream equivalent: in v7.3 the code was
significantly refactored and the problem no longer happens, see commit
b4e409c18c79 ("ext4: Remove fs-layer file contents en/decryption
code").

To reproduce the bug:

# mkfs.ext4 /dev/vdb
# mount /dev/vdb /mnt/
# tune2fs -O encrypt /dev/vdb
# mkdir /mnt/foo
# fscrypt setup /mnt
# fscrypt encrypt /mnt/foo/
# head -c 20M /dev/urandom > /mnt/foo/data
# sync
BUG: kernel NULL pointer dereference, address: 0000000000000028
Workqueue: ext4-rsv-conversion ext4_end_io_rsv_work
[...]

 fs/ext4/inode.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index a33629b397b0..32f79f48a9dd 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -5287,7 +5287,8 @@ void ext4_set_inode_mapping_order(struct inode *inode)
 	if (!min_order && !S_ISREG(inode->i_mode))
 		return;
 
-	if (ext4_test_inode_flag(inode, EXT4_INODE_JOURNAL_DATA))
+	if (ext4_test_inode_flag(inode, EXT4_INODE_JOURNAL_DATA) ||
+	    ext4_test_inode_flag(inode, EXT4_INODE_ENCRYPT))
 		max_order = min_order;
 
 	mapping_set_folio_order_range(inode->i_mapping, min_order, max_order);
-- 
2.47.3

