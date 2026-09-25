Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9DE9424501D
	for <linux-fscrypt@vger.kernel.org>; Fri, 25 Sep 2026 04:17:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790309875; cv=none; b=aS4Lh21YPm9zy4Ln/GXHpHDRWaGjoKJfX0l8GNjwYrRGNvF8otX0vImBK4wmVaH3iZ+QsWzdm5PDxPfRcKlweW/X4DxNBMjsH1wPPDumbAmEmSoc+TggM8EPqrEKZDmPp4ckbPRj0rRtDu+jOtuJXT10wRcjoLt4ZEFltPtdFUk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790309875; c=relaxed/simple;
	bh=m5OhRRMCGaZzShvpPEwZXNHEXVJxxC8lfQaSIL7vJKg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=hGTtcH0xCwTK0OvIgqf+m4/D1Pensz7hByWhm/9/HSTgauR8roSAHdaweYJpfZE4DvgcdusuofLkA0q3LQnntKPH7l+xqxhI2QY4VuX8dmd8vBi3gHtKzfOwz+V4BEwZqL2l8PehAZQKjCnRKYjS+rLbS4M+2q7S7eWKrNdeWHw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=M0Fl9U6M; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="M0Fl9U6M"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 525B01F000FF;
	Fri, 25 Sep 2026 04:17:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790309874;
	bh=qpzvwFawcrZIZmXrBCdccu2Zwt025EcVtiOUU0CYE58=;
	h=From:To:Cc:Subject:Date;
	b=M0Fl9U6Mg64MiDciG7lpRIx2sEgh3EcGuKi575AwC+RQry90pj9gdB5Oz4a4iDJDF
	 JSKRs/BGeXyJC/v8lEYcsq9Tv6pzmrTUitQkFCscqondrovD+koHq6olk58jJ/JJ0J
	 ofNAgZQool1yED0hffUI8a3SUg+QSMa0WjFQ5ZGxCUWm5IkWjjp17K7aPG44O7MNup
	 C8Wcksx1rsujrCYZuxRFGpcfcl1GRy3y8n0/Ghw6VdfEkq0y6mlCOZzYPCDuImf01D
	 PrhxPQlfIKMJn441cvvVCjOedE8QYSkfKKhi5jI2tsZl/lXIFxQGPBFCyNtatta7ih
	 sRUUeHQQeKQZg==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Matthias Goergens <matthias.goergens@gmail.com>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] MAINTAINERS: List the fsverity branches
Date: Thu, 24 Sep 2026 21:16:54 -0700
Message-ID: <20260925041654.112935-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The fsverity entry in MAINTAINERS has a T: entry but it doesn't mention
which branches are used.  Update it to have a T: entry for each branch.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 MAINTAINERS | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index c52ec2d7d3c1..2a4b4ef679cd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -10706,7 +10706,8 @@ M:	Theodore Y. Ts'o <tytso@mit.edu>
 L:	fsverity@lists.linux.dev
 S:	Supported
 Q:	https://patchwork.kernel.org/project/fsverity/list/
-T:	git https://git.kernel.org/pub/scm/fs/fsverity/linux.git
+T:	git https://git.kernel.org/pub/scm/fs/fsverity/linux.git for-next
+T:	git https://git.kernel.org/pub/scm/fs/fsverity/linux.git for-current
 F:	Documentation/filesystems/fsverity.rst
 F:	fs/verity/
 F:	include/linux/fsverity.h

base-commit: 165768bb70265b5c38cf0b73fafd75be235f8b14
-- 
2.55.0

