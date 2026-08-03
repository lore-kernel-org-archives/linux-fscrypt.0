Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C785E439F67;
	Mon,  3 Aug 2026 18:05:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785780317; cv=none; b=NZystbsTjhbSsQmMw7yum6AhYYhmmyaOYa+7K03fyCJfNNRt5ywNTvH6EyVe4v9UQxFw7IgsLhXUmDiqjLjj7hBfykDvHAAyn2Zywo1uZoWe6onAlAsGqPfTroyz4ZmcP5UpZzd2Ap+XnZkSh+lE/pD6HSpqzhiyW4zBUTrPcdk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785780317; c=relaxed/simple;
	bh=unqYEMw1raDW/MN2NEoCbyzyRUpMh8rkPsxGeqHmZbE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=NxH4LfudmGYrpA8fgUB78mndiaF4alf3bXNeLMT0VkZInt8NHTsfOE1GVK6V8B2YQ3ev6ljU/BD47LchiphGhkcmgnp2+ZAasMAan7NQWzpBtDVH0oWx9tqwptpDZcuuRlPg9DqFhGfTAKJwMuLtWheFQ3vTubnv4Jf3/+iBbaY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JMUECnJP; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JMUECnJP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CA4F01F00A3D;
	Mon,  3 Aug 2026 18:05:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785780314;
	bh=W2kStB1YVLVAsQPtUhw3R9F4+saCiGZ5gertLGOHTy8=;
	h=From:To:Cc:Subject:Date;
	b=JMUECnJP5du5ysAKwoLyMQiDiGNYXlVRUq/jZCqBrv1ijy7sailXgEvXbniKkAgUv
	 7CvucJgQ2c/xRqrhe1JGRT3xaN38/honV6cGw/RCu1hMtL1sN4vs3VLIT2sfMkdD9R
	 LCY/87XFNb1QnLJu7tfvrWYuzZhIpACYLQCHvI7Ze75HQsWaxFYmfKHbYpqtwIt/Ay
	 GT8WPt+dPkX94Ha8/d68fRGAeaFSBS8NsxJHizAOSdkLH5VsWnk+fLI96Y412qKhEB
	 JW1LYt7Zf8mhN3d4Y7zp5B+tvU3YsozNo1RVdBAHVc8AOYu4JX/vBVu8UXYtVST7rI
	 PxI03tlWuVv5g==
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
Subject: [PATCH v2] mm/swap: reject swapon() on filesystem-level encrypted files
Date: Mon,  3 Aug 2026 11:04:26 -0700
Message-ID: <20260803180426.3123-1-ebiggers@kernel.org>
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
Reviewed-by: Baoquan He <baoquan.he@linux.dev>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---

Changed in v2:
   - Added a pr_warn_once
   - Removed unnecessary word from fscrypt.rst
   - Added Reviewed-by

 Documentation/filesystems/fscrypt.rst | 4 ++++
 mm/swapfile.c                         | 7 +++++++
 2 files changed, 11 insertions(+)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index c0dd35f1af12..e4882b73120e 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -1238,6 +1238,10 @@ astute users may notice some differences in behavior:
 
 - DAX (Direct Access) is not supported on encrypted files.
 
+- Encrypted files cannot be used directly as swap files.  To swap to
+  an encrypted file, set up a loopback device on top of it.
+  Alternatively, encrypted swap can use a dm-crypt device.
+
 - The maximum length of an encrypted symlink is 2 bytes shorter than
   the maximum length of an unencrypted symlink.  For example, on an
   EXT4 filesystem with a 4K block size, unencrypted symlinks can be up
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 78b49b0658ad..8538659acb9e 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -3650,6 +3650,13 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		error = -EBUSY;
 		goto bad_swap_unlock_inode;
 	}
+	if (IS_ENCRYPTED(inode)) {
+		pr_warn_once(
+			"Filesystem-level encrypted swapfile '%s' is unsupported. Create a loop device over it, or use dm-crypt\n",
+			name->name);
+		error = -EINVAL;
+		goto bad_swap_unlock_inode;
+	}
 
 	/*
 	 * The swap subsystem needs a major overhaul to support this.

base-commit: f5098b6bae761e346ebcd9da7f95622c04733cff
-- 
2.55.0

