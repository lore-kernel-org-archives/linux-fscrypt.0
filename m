Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DBED3101B6
	for <linux-fscrypt@vger.kernel.org>; Fri, 25 Sep 2026 04:16:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790309781; cv=none; b=rgEdcAMBkPe4bo1hwtMFV7Gm7DQ/babMzLkECt2XSCgjUNyqbijfxlp5qb9oBjG6FlGvBPrlMdnPpLRsS8mRNp6sRu7hImg8LCwQbNFOlII0UFNZtRYLsd2ydAV3G1ZwbsyhwX32F6mAr9seXGcjfcsGxmE7E+GZg3lj6MnfTzA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790309781; c=relaxed/simple;
	bh=OuV14UokT6L/8G49IiDP9Lbtm1oFY0bkNq6CMd1HFzc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Xx1CBVs2BVoCHoKLHjgTqLM8o34LB/Al95SwcU2seDBvD8g/HKrcSgeEtqkfFjv/ToaRyBQn1bqsgh1zEJ0K+X4/j+ahV7tsyyYmoLLUSx+KwGZe1sOZRUqYyhRMB/eB/3zklJIRKeOaS/gkgoFPCnJ+rN9bc0oLnzC5gT9UX+8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GEV7VovI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GEV7VovI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3A8801F000FF;
	Fri, 25 Sep 2026 04:16:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790309780;
	bh=ZZUf5m/zBa7t33qsmaoWn5twWbQE9LVbz45E9+9p0cM=;
	h=From:To:Cc:Subject:Date;
	b=GEV7VovIGc9RTyXNaLCfulAIi/bUlsZ1mz6ClbZOb+483231nsUO2XB7yGIjCjGPj
	 asGuWV4f7KFlJDyIGJx8z4YZ8ontXN3eW73mPHgEYJ1gUSDwWArTSac7ZhCdo1VsrB
	 CvQ8DRd6/DFF8qPtK5gNxjkXhQBTmIqSnp4Dur75Lzrf5aGVXD97kSklHpXVl5rDKA
	 EhuiayTKityDce8d2/Ddzb34L8KhLRHE4ZqJ8gkjdAJNdPokn61HoN9X+cNTzAONtt
	 eZ1IsOB8wwdL0ixcLRb4J+qZYQjBe/mN7H4Ly2/YaVFxk6m0mpPFDRoebzRpW6AmMt
	 4hsOOsaNzrAoA==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Matthias Goergens <matthias.goergens@gmail.com>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] MAINTAINERS: List the fscrypt branches
Date: Thu, 24 Sep 2026 21:15:27 -0700
Message-ID: <20260925041527.112609-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The fscrypt entry in MAINTAINERS has a T: entry but it doesn't mention
which branches are used.  Update it to have a T: entry for each branch.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 MAINTAINERS | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c52ec2d7d3c1..5d43718d1841 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10659,7 +10659,8 @@ M:	Jaegeuk Kim <jaegeuk@kernel.org>
 L:	linux-fscrypt@vger.kernel.org
 S:	Supported
 Q:	https://patchwork.kernel.org/project/linux-fscrypt/list/
-T:	git https://git.kernel.org/pub/scm/fs/fscrypt/linux.git
+T:	git https://git.kernel.org/pub/scm/fs/fscrypt/linux.git for-next
+T:	git https://git.kernel.org/pub/scm/fs/fscrypt/linux.git for-current
 F:	Documentation/filesystems/fscrypt.rst
 F:	fs/crypto/
 F:	include/linux/fscrypt.h

base-commit: 165768bb70265b5c38cf0b73fafd75be235f8b14
-- 
2.55.0

