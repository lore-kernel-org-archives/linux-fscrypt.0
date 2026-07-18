Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED0A43793D0;
	Sat, 18 Jul 2026 21:49:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784411345; cv=none; b=srQuf5h9PBzjSnvwfF7MBYSFvLaY/xQQEv8/sJjCWuAqS6hoqhNq45IF5wmd21lNex/4MmG5wMhMO043ipS/2AUvughWYU9CDq5aIwkn0jCRMWZhJDSfxHmy+bnsfHDBaM6hq3AIrzIp4mzMEFigN9l/bius49oVAM0NGU2Jcvs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784411345; c=relaxed/simple;
	bh=DD+ht/qZuWashhBykwYO6wqzg4eJENSj2Hp9/ildZxI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=A/UgSiBMEpTEcR5Pynd5erQw92248ekXA1Ado84P+d522ySGdS/P/DM1LcmKhpOpup6ygZMs2Duh/tKLWlOmHsW1IxkWh/q7cKM24ISNvG4sXKCUAzXbAu4oFSIABVd0AOwynEBZDSHkh1mNIsFjkunQoXJqQcBl2BqhAV5tG4M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=izWg8MeO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="izWg8MeO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CBC6C1F00A3E;
	Sat, 18 Jul 2026 21:49:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784411344;
	bh=NJWkMqhNzPOnX6d2XCeG2SWavkTSF6lVRqA3hgxwQvY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=izWg8MeOHBTG6L6M+o6+HnnLjgGAS+lNf10ofnZLayydZnr3LlVn/QkHr94MF+A3d
	 kQ6BqhpO12dd98pHAooSfvPYYU8g4iz5q0uhixsApB/C+3oZEU8owigj6NYOzBBXDx
	 G3QOsIAUXBoucad1qbdCC6e8IsAa+XQVRINdsW19h5VtHMoE55G++qr8Oe3nfvEC+7
	 ZgWjfWeTvi3ovDBdibhZL6qMtwr+OfuWBN0t2Y22jeIAieALlG/uvWu1L9znKMuaaX
	 zS/+ERapCV89mVb+/yEm54t0/6PMjbzIeeTX6TP4+HGxaDh7SpWaYcWf2YOj49u/Tw
	 nENo05rLN+UGA==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-doc@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 2/6] f2fs: Update outdated comment in f2fs_write_begin()
Date: Sat, 18 Jul 2026 14:46:51 -0700
Message-ID: <20260718214655.63186-3-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260718214655.63186-1-ebiggers@kernel.org>
References: <20260718214655.63186-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Refer to f2fs_set_bio_crypt_ctx() instead of the removed function
f2fs_encrypt_one_page().

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/f2fs/data.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 65117dd2e123..a88ed125d266 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -3956,7 +3956,7 @@ static int f2fs_write_begin(const struct kiocb *iocb,
 		/*
 		 * Although the block may be stored in the COW inode, the folio
 		 * belongs to @inode and its data was encrypted (or not) using
-		 * @inode's context (see f2fs_encrypt_one_page()).  Read with
+		 * @inode's context (see f2fs_set_bio_crypt_ctx()).  Read with
 		 * @inode so the post-read decryption decision matches the
 		 * folio's owner; otherwise an unencrypted @inode whose COW inode
 		 * is encrypted hits a NULL ->i_crypt_info on decryption.
-- 
2.55.0

