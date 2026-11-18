Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794961784;
	b=KMIz0fDQk+EsBhpwrePmTnVig4lfSYnNcuFqO2ROa5K0nCbTjBd+9xltQ25XmxGKXeC5
	 IGP4vUhB2ZnJT7tjPWmCFknEZQEw//tes0EKKE4d9qJIS+DVDiI/ys5ozQRewanYJlaxi
	 +bQgoN8/C8kB5F8YjhbQKnWiiLQkOkDvPh6n4ZqhJyPMleq8WRT7skqGukq0tblG06hsT
	 QAfCxE9qCgQ3UQsf+tFjk9ycjY9EsqwiU7mFnaj11d+MIPnfcZvuRwaXrswgVdGmI6etY
	 5pcQMMDIrRHSq+Jb+hWGsVe9kjZdxH92XxrzrsgY8rMuvK1dEGi9qz7I2Vj3eTG178Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794961784;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-Developer-Signature:
	 X-Developer-Key:Content-Transfer-Encoding;
	bh=Qt60u/01NFUb/AYhVxHzrtbOvOOGfTfWBLgqtTss5Z0=;
	b=j4+BjXPapeAq33MK22DhdIihCu4AvJeGhJGneEgXJtnPRLzwC8d3ObognIvX1mSwO34C
	 TjZeVhXmYkQho0ntv3VQGTp8xL2yBJSQVCDrwOG3NdIBFT7yMkqsGE/hMjSvRb0Hz2DIa
	 Tq/bB2WpBSl+4Tu4VMqpiMyiLOi3kvbd0WhVxOy1vnKKVbhcB9zzCoeJ+Z//P7it+Atca
	 mDGJt/MSFid/dRiZrvbFNxMU5KakD/mPmQqMDb5WnsVqrqLGWY8zmMRvO6CNkaB2OYMAM
	 /fCwiKKIuiI1nrFvSazz9yA2jkk2Vt32hBGOsP//jbnxtyCyqCrPB9FsqSjFbn4+IBw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Nk16DLld;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80602606A32C;
	Wed, 18 Nov 2026 00:29:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Nk16DLld
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3CF291F000CA;
	Wed, 18 Nov 2026 00:29:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794961784;
	bh=Qt60u/01NFUb/AYhVxHzrtbOvOOGfTfWBLgqtTss5Z0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Nk16DLldu3/i9fxqzBvs7WbOc2fj5wTFODes7aYf9CJn9LQZy8P4T8RCtAqmun3w3
	 8S5zvFrpuV58qdUQqwfBUXhmfKWBBfuVTBkfdYUE66lqYSFjCqV9WMI2HIi6ahl8gM
	 Dxi/MXuzgrA2hS733BiZZKsBVTG8aqOrKAVQYo5FH3lxScFwuzy5NyVaZn/c3W+DAZ
	 /rrxYoBTfVV4mtvcdW2iDEO3qs5Z1DwG94mpdz7JZpAG9Pt+4N1mwqk2Ut0OB2zedT
	 j4TK84yyaHmrQqdukeVOk6Y1WWZ0tfPT3tikxqN1Qr1BZ4sCQAc9dZ+DqMTc/MKGAW
	 BM4Wis3M20cmQ==
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
Subject: [PATCH 2/4] btrfs: Use FSTR() for the "default" name
Date: Wed, 18 Nov 2026 01:28:48 +0100
Message-ID: <20261118002845.574426-8-blum@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2827; i=blum@kernel.org; h=from:subject; bh=C5PvMKO+6yQo+bVlkdY4gYEIvoCwjLB1zuR+7E63A20=; b=owGbwMvMwCUWt7pQ4caZUj3G02pJDFl/Ptq1zPv2VvVsMH+cXGqFUv7t04UVn/a/sYrbkPs08 rr3qs6DHaUsDGJcDLJiiiwPZv2Y4VtaU7nJJGInzBxWJpAhDFycAjCRqpOMDG9mrb3o3LUvRezg olKvBGOToHTri6VNm5f/qPv1/4lygQbDP5PYuAX8bYciMvUs+lp59R1UVZovTdG/67Gx2KH1rVg uEwA=
X-Developer-Key: i=blum@kernel.org; a=openpgp; fpr=1D60735E8AEF3BE473B69D84733678FD8DFEEAD4
Content-Transfer-Encoding: 8bit

Replace FSTR_INIT() with FSTR() and drop the hard-coded length argument.

Use FSTR() directly and remove the temporary name variables.

Signed-off-by: Thorsten Blum <blum@kernel.org>
---
 fs/btrfs/inode.c | 3 +--
 fs/btrfs/ioctl.c | 3 +--
 fs/btrfs/super.c | 3 +--
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index abaa33471456..1ffdcdd16bb5 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -4640,7 +4640,6 @@ static noinline int may_destroy_subvol(struct btrfs_root *root)
 	BTRFS_PATH_AUTO_FREE(path);
 	struct btrfs_dir_item *di;
 	struct btrfs_key key;
-	struct fscrypt_str name = FSTR_INIT("default", 7);
 	u64 dir_id;
 	int ret;
 
@@ -4651,7 +4650,7 @@ static noinline int may_destroy_subvol(struct btrfs_root *root)
 	/* Make sure this root isn't set as the default subvol */
 	dir_id = btrfs_super_root_dir(fs_info->super_copy);
 	di = btrfs_lookup_dir_item(NULL, fs_info->tree_root, path,
-				   dir_id, &name, 0);
+				   dir_id, &FSTR("default"), 0);
 	if (!IS_ERR_OR_NULL(di)) {
 		btrfs_dir_item_key_to_cpu(path->nodes[0], di, &key);
 		if (key.objectid == btrfs_root_id(root)) {
diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
index 6ba883db107b..6c371621f014 100644
--- a/fs/btrfs/ioctl.c
+++ b/fs/btrfs/ioctl.c
@@ -2825,7 +2825,6 @@ static long btrfs_ioctl_default_subvol(struct file *file, void __user *argp)
 	struct btrfs_trans_handle *trans;
 	struct btrfs_path *path = NULL;
 	struct btrfs_disk_key disk_key;
-	struct fscrypt_str name = FSTR_INIT("default", 7);
 	u64 objectid = 0;
 	u64 dir_id;
 	int ret;
@@ -2869,7 +2868,7 @@ static long btrfs_ioctl_default_subvol(struct file *file, void __user *argp)
 
 	dir_id = btrfs_super_root_dir(fs_info->super_copy);
 	di = btrfs_lookup_dir_item(trans, fs_info->tree_root, path,
-				   dir_id, &name, 1);
+				   dir_id, &FSTR("default"), 1);
 	if (IS_ERR_OR_NULL(di)) {
 		btrfs_release_path(path);
 		btrfs_end_transaction(trans);
diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
index b424cc836bd4..0b8b808872c7 100644
--- a/fs/btrfs/super.c
+++ b/fs/btrfs/super.c
@@ -911,7 +911,6 @@ static int get_default_subvol_objectid(struct btrfs_fs_info *fs_info, u64 *objec
 	struct btrfs_dir_item *di;
 	BTRFS_PATH_AUTO_FREE(path);
 	struct btrfs_key location;
-	struct fscrypt_str name = FSTR_INIT("default", 7);
 	u64 dir_id;
 
 	path = btrfs_alloc_path();
@@ -924,7 +923,7 @@ static int get_default_subvol_objectid(struct btrfs_fs_info *fs_info, u64 *objec
 	 * to mount.
 	 */
 	dir_id = btrfs_super_root_dir(fs_info->super_copy);
-	di = btrfs_lookup_dir_item(NULL, root, path, dir_id, &name, 0);
+	di = btrfs_lookup_dir_item(NULL, root, path, dir_id, &FSTR("default"), 0);
 	if (IS_ERR(di)) {
 		return PTR_ERR(di);
 	}
