Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794961792;
	b=22Qtv9E/nYYGuANC6a7LPstQM7f+I34c3YmUTQrO/Yen9s2JWdhpOYza6jptHnK0kzJc
	 HqJ7mLyycaFM/4AipRLSChCBzkEHacw00kCaiSrLQAj0Qzr7XQfyi4cueJMPdFPk2bbSo
	 YoSJ7yM9QOCsWsfXIFtRjaZCo4dU9INLiz1TthaF32E/qKoDhIr2bJ5fI2QUR9dvx4w3U
	 zLg1Y5yW3VlTzank5tHNmE2/Ouk4W0xczeAYXq9mgha9DhjcsPNnuL4Xli7dadPf2BXnG
	 5mrXkiqVB56/koYs2CoOUSSGWo7MrRJHoU2G3g3QewKMywB52LVxtk/qh7wUB1zgMWA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794961792;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-Developer-Signature:
	 X-Developer-Key:Content-Transfer-Encoding;
	bh=XgXrwef3GSdcgoeGpprzCP9+LfeU52zOGFONlLtqopU=;
	b=NwB7MhnLjiShwCaSoJob7lz7+pMQxcNTSeyBdU7zZerWm+8hsw/t2X8zkEoImttEd45N
	 6PTHL1MQBoVrrqj/cZRjVp+Llj9Y+f1QrA/7kIWReaPs/BHGXdj/DAClIn+z3Qz1cQSBT
	 oJdqya03qydM697umX+G4/flOtRtvUIed+zREVWnV3MIAYTg0Epi/LBQXngWqKSuDFXND
	 g4cra1HsNezOtKrZPqBqBiM2B2slnC50H+1tuqmiQeZK/p+Bj7FStLLFFHBFOiNwpyNjv
	 LvI+duu2FpqchepzK7xz0UO7VRLZhRFTOdEBVh3Cb3HR7HDkm9DW+t2aJbop9L5AgoQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UuEw1cbt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D13CA606A31C;
	Wed, 18 Nov 2026 00:29:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UuEw1cbt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 270F41F000CC;
	Wed, 18 Nov 2026 00:29:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794961792;
	bh=XgXrwef3GSdcgoeGpprzCP9+LfeU52zOGFONlLtqopU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UuEw1cbtOFp4TZZlU/lzFOH+uJKcG6CGL/dfukobmupQG0yY0iLuhvoQ1vXICETNR
	 huuTvtM41iyL42N95j/ndGletCBCyM+71NEYMobYA6J7/OPxVSzLyOhqTtQ/2NDFAf
	 T6difwT78ibb3hHwyqX0+VGrFM24wltdIQBBDx+5r/ze70jFJkLM/o19zhIWH52B/t
	 rfWG5izVuLLEA6eQEYVpZxu0VjX4XCeWGuQ7Zre1OkeSPsN8L9k/Vt9Hj3nl0SNTrO
	 F5uMdm0Lib2MG25zvXue8MJTopqXYdFwzI2n16+laauBVKG1syMvA7SxevwJLcfzIi
	 4YHbDl/scnfUA==
From: Thorsten Blum <blum@kernel.org>
To: David Sterba <dsterba@suse.com>,
	Chris Mason <mason@kernel.org>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>,
	Richard Weinberger <richard@nod.at>,
	Zhihao Cheng <chengzhihao1@huawei.com>,
	Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>
Cc: linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-mtd@lists.infradead.org,
	linux-fscrypt@vger.kernel.org,
	Thorsten Blum <blum@kernel.org>
Subject: [PATCH 4/4] ubifs: Use FSTR() in ubifs_xattr_{set,get,remove}()
Date: Wed, 18 Nov 2026 01:28:50 +0100
Message-ID: <20261118002845.574426-10-blum@kernel.org>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <20261118002845.574426-6-blum@kernel.org>
References: <20261118002845.574426-6-blum@kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-Developer-Signature: v=1; a=openpgp-sha256; l=1526; i=blum@kernel.org; h=from:subject; bh=WDBVonVI9poJWjMd/98XRPyVKKRQHMEiFwUXmeGohbE=; b=owGbwMvMwCUWt7pQ4caZUj3G02pJDFl/PtpzGvoq1YpZXE1nFdg5d6r69nbd31K6j/fFReVcE D379qVqRykLgxgXg6yYIsuDWT9m+JbWVG4yidgJM4eVCWQIAxenAExkbg/DP9ub5Yd2J+94fCW0 24VFvituzp1C0eIpyftfha255JrFr8nI8Le94ZLGTtPky04bWC0Ui/6bTvNMPFQwUVuHdd+ZGd9 O8wMA
X-Developer-Key: i=blum@kernel.org; a=openpgp; fpr=1D60735E8AEF3BE473B69D84733678FD8DFEEAD4
Content-Transfer-Encoding: 8bit

Replace FSTR_INIT() with FSTR() and drop the explicit length argument.

Signed-off-by: Thorsten Blum <blum@kernel.org>
---
 fs/ubifs/xattr.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/ubifs/xattr.c b/fs/ubifs/xattr.c
index 3b0e8a270f59..036eb7e2be0b 100644
--- a/fs/ubifs/xattr.c
+++ b/fs/ubifs/xattr.c
@@ -252,7 +252,7 @@ int ubifs_xattr_set(struct inode *host, const char *name, const void *value,
 {
 	struct inode *inode;
 	struct ubifs_info *c = host->i_sb->s_fs_info;
-	struct fscrypt_name nm = { .disk_name = FSTR_INIT((char *)name, strlen(name))};
+	struct fscrypt_name nm = { .disk_name = FSTR((char *)name) };
 	struct ubifs_dent_node *xent;
 	union ubifs_key key;
 	int err;
@@ -315,7 +315,7 @@ ssize_t ubifs_xattr_get(struct inode *host, const char *name, void *buf,
 {
 	struct inode *inode;
 	struct ubifs_info *c = host->i_sb->s_fs_info;
-	struct fscrypt_name nm = { .disk_name = FSTR_INIT((char *)name, strlen(name))};
+	struct fscrypt_name nm = { .disk_name = FSTR((char *)name) };
 	struct ubifs_inode *ui;
 	struct ubifs_dent_node *xent;
 	union ubifs_key key;
@@ -557,7 +557,7 @@ static int ubifs_xattr_remove(struct inode *host, const char *name)
 {
 	struct inode *inode;
 	struct ubifs_info *c = host->i_sb->s_fs_info;
-	struct fscrypt_name nm = { .disk_name = FSTR_INIT((char *)name, strlen(name))};
+	struct fscrypt_name nm = { .disk_name = FSTR((char *)name) };
 	struct ubifs_dent_node *xent;
 	union ubifs_key key;
 	int err;
