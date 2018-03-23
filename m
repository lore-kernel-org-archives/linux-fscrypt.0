Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 03/14] fscrypt: remove WARN_ON_ONCE() when decryption fails
Date: Fri, 23 Mar 2018 12:23:47 -0700
Message-Id: <20180323192358.95691-4-ebiggers3@gmail.com>
In-Reply-To: <20180323192358.95691-1-ebiggers3@gmail.com>
References: <20180323192358.95691-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

If decrypting a block fails, fscrypt did a WARN_ON_ONCE().  But WARN is
meant for kernel bugs, which this isn't; this could be hit by fuzzers
using fault injection, for example.  Also, there is already a proper
warning message logged in fscrypt_do_page_crypto(), so the WARN doesn't
add much.

Just remove the unnessary WARN.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/bio.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 0d5e6a569d58..771c8684826b 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -43,12 +43,10 @@ static void completion_pages(struct work_struct *work)
 		int ret = fscrypt_decrypt_page(page->mapping->host, page,
 				PAGE_SIZE, 0, page->index);
 
-		if (ret) {
-			WARN_ON_ONCE(1);
+		if (ret)
 			SetPageError(page);
-		} else {
+		else
 			SetPageUptodate(page);
-		}
 		unlock_page(page);
 	}
 	fscrypt_release_ctx(ctx);
-- 
2.17.0.rc0.231.g781580f067-goog
