Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D15FE573;
	Mon, 22 Jun 2026 01:15:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782090952; cv=none; b=MJu1sNWJieaWBpBEOfyEH3hz6+kMH8V2KqnvCW+ymmebEFqy/ccQIntgDrNYbcZWnZD1Dnv4nx1CbudqTOqSBLoK7GHi87UkW9bnIJN+qtao041HJlWvfOiC59xQ/dE4eEd2KgFicFCoKc8O4zG6tyzggS8GhSihYhRbFkwz4ss=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782090952; c=relaxed/simple;
	bh=o6nPS9XBWi29QSp/qdvZ9U/giu9n1idZEBYfIrbmsKE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=IMSNKqqMz07CttW5nuZk/sQcIrl7P0TF3Acuyo0sXMlz/0R+z9n6xo7gHrunl5N1b7Xw5iNRsMa5yfwdQkQTlpOz9zyNW99y7oPh6V9xjSbaLA6oZx3t1jgFr7kvr7XKgZMGFLVTHRxl94YxmPiZpHib5wC8nbi7JxHJF7RxbKM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KjXXnwxx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KjXXnwxx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0EF5B1F000E9;
	Mon, 22 Jun 2026 01:15:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782090951;
	bh=oIPzaruOWHqFKq/etE/EWa8X4ZRmucxNkS3ctpKMPG0=;
	h=From:To:Cc:Subject:Date;
	b=KjXXnwxxyMfMHdpYlLFE1ZJvsBE1w4e/aOTSuWkKgSWVay5ztrODw/XMZHvH13QSZ
	 GLE1WoskpNJJV0aXLhRiIvzJLX7+fb/z8swqaKjCftlI9xl7qqczLEZDvNGNR3Wr2E
	 IE15kL6lpa2OcjiuRcAa/LaMrEBV3RuCJxBsIDoRttXtLsa3+lEKsIbaiRHuhN+WRw
	 7toRam3lV61+sPb/uZzDxCMDbj9xXyJ9v4a6Jsc4Oa7OKvb99xN0id70mmQ3BFnn2c
	 C7wTmo/VJP+AjZsh9AtYmUfsjRex/q+TXFG0IFczc86slfXSfDbA78qe3iH6uBzcDu
	 LraZFGM19x+Rg==
From: Chao Yu <chao@kernel.org>
To: linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net
Cc: linux-kernel@vger.kernel.org,
	jaegeuk@kernel.org,
	Chao Yu <chao@kernel.org>,
	Matthew Wilcox <willy@infradead.org>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt,f2fs: introduce fscrypt_finalize_bounce_folio() for cleanup
Date: Mon, 22 Jun 2026 01:15:39 +0000
Message-ID: <20260622011539.2292553-1-chao@kernel.org>
X-Mailer: git-send-email 2.55.0.rc0.738.g0c8ab3ebcc-goog
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

As part of the linux kernel's migration to folio-based APIs, introduce
fscrypt_finalize_bounce_folio() as the folio equivalent of
fscrypt_finalize_bounce_page(), and clean up f2fs codes with this new
helper.

Suggested-by: Matthew Wilcox <willy@infradead.org>
Cc: Eric Biggers <ebiggers@kernel.org>
Signed-off-by: Chao Yu <chao@kernel.org>
---

Is it worth to introduce fscrypt_finalize_bounce_folio(), then try to
do clean in f2fs_write_end_bio() first, and then replace
fscrypt_finalize_bounce_page() later?

 fs/f2fs/data.c          |  7 +------
 include/linux/fscrypt.h | 11 +++++++++++
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index ac1cf4de3d62..e0fca6c60e34 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -362,12 +362,7 @@ static void f2fs_write_end_bio(struct bio *bio)
 		struct folio *folio = fi.folio;
 		enum count_type type;
 
-		if (fscrypt_is_bounce_folio(folio)) {
-			struct folio *io_folio = folio;
-
-			folio = fscrypt_pagecache_folio(io_folio);
-			fscrypt_free_bounce_page(&io_folio->page);
-		}
+		fscrypt_finalize_bounce_folio(&folio);
 
 #ifdef CONFIG_F2FS_FS_COMPRESSION
 		if (f2fs_is_compressed_page(folio)) {
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 54712ec61ffb..20b59b021c94 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -1132,4 +1132,15 @@ static inline void fscrypt_finalize_bounce_page(struct page **pagep)
 	}
 }
 
+/* If *foliop is a bounce folio, free it and set *foliop to the pagecache folio */
+static inline void fscrypt_finalize_bounce_folio(struct folio **foliop)
+{
+	struct folio *folio = *foliop;
+
+	if (fscrypt_is_bounce_folio(folio)) {
+		*foliop = fscrypt_pagecache_folio(folio);
+		fscrypt_free_bounce_page(&folio->page);
+	}
+}
+
 #endif	/* _LINUX_FSCRYPT_H */
-- 
2.49.0

