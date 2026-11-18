Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794961788;
	b=YA7aFKKxiqlx49bii6buxb/sG8H145Ut0QRXC8r7/GH7ZZ0vtD5elUyJZF/J7GcvsVc1
	 cUYocL7WV5uoBY07D8baF4otGIVfQwCosiiBoPwQi3uVtHaKUvsYi/QBKPUO/wRwIOai7
	 VowaoLwGH0HSAZICKrrAWA80whiqu/FFHmWs+g/f32i2akxf9L8uFstF7NRu3qoxRxKL7
	 TalSpqyU7abWbwxbRK6xVg4WV9clrgv+u7PX1LDGVyjYU97z4t0YlUZc16MEWbS33MJIY
	 WkGF+MTePwtOPoSUTbIXl9ooW53rDq2mTB0OnhfFAt8e0PIyHTSsHVVFGTeu+N3bI6A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794961788;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-Developer-Signature:
	 X-Developer-Key:Content-Transfer-Encoding;
	bh=7p8hzQulzm2sdT6ljl53TR4xqlIGw1FUKTCUNJv0MWM=;
	b=VrVeVsOweJ57Nl7sVXIyR17zGFucznpmL6IYU91JO64L/7TysRRG00d/QSX762tLADIq
	 z2Fw4C32cXUfoRe3BvJWT3SHYCILFdrXAV5qrKOoiYmVZzvCfkCTwogKwz+hFtJHufbZQ
	 5DtlCo/Wdjp9OAXjt3tRC2Swsgpn5xWDPeEPiRAQev5PtX9y6oeo1w0yOiBpczyfqN79e
	 /AhWPNvN05+LVg5yvqwXZoEbfACgd920piBY0g/62hIuEuGLZ3jHTmz3G1aVOmXljKI+z
	 1S367+5U3ezGn24U5VwtObOnWpFRlEiNIfaxbKmCFVxOUS26vv0Yf5WVjw2YHNr9wuw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lP3GMpvF;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8018606A32A;
	Wed, 18 Nov 2026 00:29:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lP3GMpvF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2C7411F000C4;
	Wed, 18 Nov 2026 00:29:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794961788;
	bh=7p8hzQulzm2sdT6ljl53TR4xqlIGw1FUKTCUNJv0MWM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=lP3GMpvFvIEPM7v98/UaUS54HWXwJpqZEQTCiBzDHxv72y1Q5Hg/7gI59uQ8+G2rU
	 wbCh+AFvdJ6fdXjpEhgrDLxOu552gaoMCfkXw9ZO7mGtKfG0zH075ffsllhlYYaJnZ
	 siJEsDxgx0HtMFa1D6H2AXaCdAdLgobMe19vpXgC2CSAYPImdBNAYxfHyGy6vJ2Sq2
	 +1NmhPrUMwKjHWXduX8i/oAJ2URl3dfBOrj3gT/B9dX+QG56gF+tL7emg1tvHDMVl+
	 pZ/Ko3CglaLOm2d2CdAeQpNN/THkB/gi9FBCAMTaQOKe7eZzCgf9ePjUjX2NuHgHFf
	 4fQ0Brrss7xVA==
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
Subject: [PATCH 3/4] f2fs: Use FSTR() in f2fs_do_make_empty_dir()
Date: Wed, 18 Nov 2026 01:28:49 +0100
Message-ID: <20261118002845.574426-9-blum@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1106; i=blum@kernel.org; h=from:subject; bh=grfMiZcoagjGMDC9TYISjWneu7iyoRjVgpowfER1HnI=; b=owGbwMvMwCUWt7pQ4caZUj3G02pJDFl/PtrvevJS83nhl+U99vkmJ9OD2jemKS6ey25/41md5 iWNvB9fOkpZGMS4GGTFFFkezPoxw7e0pnKTScROmDmsTCBDGLg4BWAie/gZ/lcYZ7kVtX8pmD7l AjfbDl2fx3ciG1d9KN655ZnnfR3eTFtGhgMpL/f6HXcpsFg+ybi2vOhk5Iqz5hyf9+5Q2SdUuZf XiAEA
X-Developer-Key: i=blum@kernel.org; a=openpgp; fpr=1D60735E8AEF3BE473B69D84733678FD8DFEEAD4
Content-Transfer-Encoding: 8bit

Replace FSTR_INIT() with FSTR() and drop the hard-coded length argument.

Use FSTR() directly and remove the temporary variables.

Signed-off-by: Thorsten Blum <blum@kernel.org>
---
 fs/f2fs/dir.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/f2fs/dir.c b/fs/f2fs/dir.c
index 97f7fef6b068..469c4cc7a3b7 100644
--- a/fs/f2fs/dir.c
+++ b/fs/f2fs/dir.c
@@ -515,14 +515,11 @@ static void init_dent_inode(struct inode *dir, struct inode *inode,
 void f2fs_do_make_empty_dir(struct inode *inode, struct inode *parent,
 					struct f2fs_dentry_ptr *d)
 {
-	struct fscrypt_str dot = FSTR_INIT(".", 1);
-	struct fscrypt_str dotdot = FSTR_INIT("..", 2);
-
 	/* update dirent of "." */
-	f2fs_update_dentry(inode->i_ino, inode->i_mode, d, &dot, 0, 0);
+	f2fs_update_dentry(inode->i_ino, inode->i_mode, d, &FSTR("."), 0, 0);
 
 	/* update dirent of ".." */
-	f2fs_update_dentry(parent->i_ino, parent->i_mode, d, &dotdot, 0, 1);
+	f2fs_update_dentry(parent->i_ino, parent->i_mode, d, &FSTR(".."), 0, 1);
 }
 
 static int make_empty_dir(struct inode *inode,
