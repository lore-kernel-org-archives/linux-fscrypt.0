Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE9EB30CD95;
	Sat, 18 Jul 2026 21:49:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784411344; cv=none; b=hu79a5lkV/wosRqYOF+lB9pXkO/gHJimAjcfA7TOu/4uWklCrW1vkmCKNX/yBLnUeIKCPShdcdq2csapc5wmSMdxxDm/Mz1jhIilIf+onNJ2ubgcSAzqPihc4rT4mPX37WZAzpJulEgvdNuL2WYorZjF2ytHRGVyP2vHDsNYj+g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784411344; c=relaxed/simple;
	bh=hg8xIfhC8YFEIBgohBnRQCRhLhXaTPccnde8juQMzho=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jMFWEN1fEiA3FJssV61rUSO8lx/Po0cBB6GyFejgTxJcxb3TTEH6hqV36Q5HueLadc9SAQTj6LUmp1Szb0uOUAJ5mibzHuWtDeCrYe79CHA1DcqUWB91GIseWYbeyF3wU7tc3nMpmRB1/yO/85m554Fld8ZhesqNbjTeAIM9RNs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nOz1PA5t; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nOz1PA5t"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7DAC61F00A3D;
	Sat, 18 Jul 2026 21:49:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784411343;
	bh=2xDXV67Vek3YVUUcSTKyTdZEU/LcZVKunALSMqoxvdE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nOz1PA5te72VepSoLCsCgOIbaXHv1S9jkM7enCiZVtrGkDI06SxwPF+NRIlMz+zXf
	 XqcdOuzdr6TkQqPoSyR8WAST99xtoszV1NU0Us4Rh80Zh+KKRl4G7bg5E6h/EO4Frk
	 cH1dzwGgWOBCrJlIdO5IzOWJP+THsDFVSIvpYsMR/xEhfXtPg/O64nzmsxKnF43ZjQ
	 Sf7novlrXnT70NJtgFNufVftrSH0iRW3lkTCGd8Ek+nlL6iYm44Eqf4KoVPDt1qiIO
	 9RgbkY6OmnPHAZq708SrxtDVdE/me/C/LDyL47ij2ekw11bMowTAVWTgUD8rJpYGKE
	 h5gXHIkI6QevA==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-doc@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 1/6] fs: Update outdated comment for SB_INLINECRYPT
Date: Sat, 18 Jul 2026 14:46:50 -0700
Message-ID: <20260718214655.63186-2-ebiggers@kernel.org>
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

Update the comment for SB_INLINECRYPT to match the latest code, where
SB_INLINECRYPT now controls whether blk-crypto uses inline encryption
hardware rather than whether blk-crypto is used.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 include/linux/fs/super_types.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/fs/super_types.h b/include/linux/fs/super_types.h
index ef7941e9dc79..3bdd7f7fb9e5 100644
--- a/include/linux/fs/super_types.h
+++ b/include/linux/fs/super_types.h
@@ -300,7 +300,7 @@ struct super_block {
 #define SB_NODIRATIME   BIT(11)	/* Do not update directory access times */
 #define SB_SILENT       BIT(15)
 #define SB_POSIXACL     BIT(16)	/* Supports POSIX ACLs */
-#define SB_INLINECRYPT  BIT(17)	/* Use blk-crypto for encrypted files */
+#define SB_INLINECRYPT  BIT(17)	/* Use inline crypto hardware if available */
 #define SB_KERNMOUNT    BIT(22)	/* this is a kern_mount call */
 #define SB_I_VERSION    BIT(23)	/* Update inode I_version field */
 #define SB_LAZYTIME     BIT(25)	/* Update the on-disk [acm]times lazily */
-- 
2.55.0

