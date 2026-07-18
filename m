Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 354CF379EE4;
	Sat, 18 Jul 2026 21:49:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784411347; cv=none; b=OoO9y9OVc5kphZ0lgFyWorQlaNcr7hSphAxl8OtuC3dGKvtxinAPuWvNKOcfG2UQgWcJiFwXoRPLj7YBbes6CyrVD9OU1ZXKhrs+c+6g2sF1nYEajCxbyJpZftRkQ566L7v8oZu0k4agKyq7yaKunKDOUcBPLh8EXsaA6Ao6RO0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784411347; c=relaxed/simple;
	bh=+YUzJNvtOcJ/MQUwOd/HJ8k6re65xkgmqv12oiWVpvc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FqzdkxslzVLOtKLTxYpktRdOevCvY6rtYQ0flYi9O4GyifTf/8LGRUHdp6x0/zrcdOl62WIRaBfAL1yc/CJ4mqdu6PjT+xmDMgLR7nQVL0vj+Xh22KDNnTZkIW4zlwgfUkMR19y0Azb4bi3ORdt3VO9ywcQXjayysfW5fhoS1G0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=k5+0M4B1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="k5+0M4B1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E91671F000E9;
	Sat, 18 Jul 2026 21:49:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784411345;
	bh=51BZI0czokw254bwWkQ+Q7dU3NsJmPHSH27DSUDwsvQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=k5+0M4B1y7CJshMruk8auUvrezpIIGRwRHFUoaRPzCxWdOsoaktzhBM2fkqkvY7p4
	 CPMlD4KZZjJYDjso3fQ1BXPMb0PLfzqbNKqd26ung8QygO5ZgwJqMJE+eIlb5c8ycP
	 oy9XfDo5PX6jFfw4IenDm/uYmxZG1qW/ofrl9vw1ss297L1QrKh/Eg0Jh6R/3oXIuo
	 qkWVu5tLxAb4q8mzmHbrtQT+9ovcOKCbbxdF3m6Bdx3gUtZaD8KuL2wNQ5K46HYg0f
	 uRGSHGxwClG5xAyK7ktJbo1/MMqeMdDBAuN3JaAkSTzUhUZIwcAXlh5xIARPvtokdg
	 JoyONc5c0jo9w==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-doc@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 3/6] fscrypt: Remove unused function fscrypt_finalize_bounce_page()
Date: Sat, 18 Jul 2026 14:46:52 -0700
Message-ID: <20260718214655.63186-4-ebiggers@kernel.org>
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

fscrypt_finalize_bounce_page() is no longer called, so remove it.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 include/linux/fscrypt.h | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 52ff014aeae6..42ffd66a2491 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -1057,15 +1057,4 @@ static inline int fscrypt_encrypt_symlink(struct inode *inode,
 	return 0;
 }
 
-/* If *pagep is a bounce page, free it and set *pagep to the pagecache page */
-static inline void fscrypt_finalize_bounce_page(struct page **pagep)
-{
-	struct page *page = *pagep;
-
-	if (fscrypt_is_bounce_page(page)) {
-		*pagep = fscrypt_pagecache_page(page);
-		fscrypt_free_bounce_page(page);
-	}
-}
-
 #endif	/* _LINUX_FSCRYPT_H */
-- 
2.55.0

