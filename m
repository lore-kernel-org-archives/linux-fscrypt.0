Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B0692C324C;
	Thu, 30 Jul 2026 18:55:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785437718; cv=none; b=b1zzJwDgqMm2OTe6O18nDD/BWjuZnzV1YsYjGlx8jYOjrL2xcnJ74gQFmYD3V5E2q54FEH/9CS5uPkW83tooFxF/xrLJ6p7HOWG6Ah5ejmguFg5ggtiuVF0WjIr+UqqvkWQZYCgsurpWWihyqey4xirogipVTPyXJgE2K67mcTo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785437718; c=relaxed/simple;
	bh=5aA2U49N1iuNFz0GJexrhwc8RpBGM51tHK8UiJ+8S/4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ipUocZRCpW2XU+Au+LFt7pD66Dy98FHewjUUah1pTv04t2ZS2CX8fnoSPeVUbOGE7AG+MiHccIpMQwtHm3vrGreuCzh78s+BA8prw9V3tvVPi9HReqocn8m8czqNMq/DYs7uyusd/dwjfaGqOKxi3gAw0pcYyfdv3QFOnheqhms=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UmTfwEIc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UmTfwEIc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AE5231F000E9;
	Thu, 30 Jul 2026 18:55:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785437715;
	bh=Hfg/Gngqd8SEsjmvDZsSbSWbGJu/DBm8x/q7YUwOtSU=;
	h=From:To:Cc:Subject:Date;
	b=UmTfwEIcQAZ86kDM34UYJMbq473z2fsOFlb728dkck+ISBouYAxxdTTa17upWeCAd
	 Fa952fHS1lUK5GYeiu4zWH3buJ4uR9EZ7TWSXC2lc9Un/KGctN/G4jrnRsJWN0Z3O4
	 icXTXhrMyGzLgaCR3MW4oWiKwMahsSDodIrIUqVBEd2c77lrw/RFUYTdgTB14yJb7J
	 AmQmDSvbuqXeefuq7nB6tIdLkstbSL/n0Y6OXGiQH8nG9JbgC7N9vYtzeMuWCwX/Px
	 YQzQKRIk/AQZMRzMIxKwr9/DY5gDArP6OBunaEBI0dow0OGiJN54LSNJvA3RVVacLl
	 FhFznXM7WnipQ==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Chris Li <chrisl@kernel.org>,
	Kairui Song <kasong@tencent.com>
Cc: linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Kemeng Shi <shikemeng@huaweicloud.com>,
	Nhat Pham <nphamcs@gmail.com>,
	Baoquan He <baoquan.he@linux.dev>,
	Barry Song <baohua@kernel.org>,
	Youngjun Park <youngjun.park@lge.com>,
	Eric Biggers <ebiggers@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH] mm/swap: reject swapon() on filesystem-level encrypted files
Date: Thu, 30 Jul 2026 11:48:53 -0700
Message-ID: <20260730184853.48347-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ext4 and f2fs don't prevent filesystem-level encrypted files from being
set up directly as swap files.  In this case, encryption is bypassed.

No one should be doing this, vs. the methods of encrypted swap that
actually do work (such as swapping to a dm-crypt device, or swapping to
a loopback device on top of a filesystem-level encrypted file).

Nevertheless, to prevent user error, make swapon() explicitly reject
this case.  Document this behavior in fscrypt.rst as well.

Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
Fixes: f424f664f0e8 ("f2fs crypto: add encryption policy and password salt support")
Cc: stable@vger.kernel.org
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 Documentation/filesystems/fscrypt.rst | 4 ++++
 mm/swapfile.c                         | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index c0dd35f1af12..cba1989777da 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -1238,6 +1238,10 @@ astute users may notice some differences in behavior:
 
 - DAX (Direct Access) is not supported on encrypted files.
 
+- Encrypted files cannot be used directly as swap files.  To swap to
+  an encrypted file, set up a loopback device on top of it.
+  Alternatively, encrypted swap can use a dm-crypt device instead.
+
 - The maximum length of an encrypted symlink is 2 bytes shorter than
   the maximum length of an unencrypted symlink.  For example, on an
   EXT4 filesystem with a 4K block size, unencrypted symlinks can be up
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 78b49b0658ad..e4991da81b5f 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3650,6 +3650,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		error = -EBUSY;
 		goto bad_swap_unlock_inode;
 	}
+	if (IS_ENCRYPTED(inode)) {
+		error = -EINVAL;
+		goto bad_swap_unlock_inode;
+	}
 
 	/*
 	 * The swap subsystem needs a major overhaul to support this.

base-commit: f5098b6bae761e346ebcd9da7f95622c04733cff
-- 
2.55.0

