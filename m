Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] MAINTAINERS: fscrypt: update mailing list, patchwork, and git
Date: Wed, 26 Apr 2017 16:43:00 -0700
Message-Id: <20170426234300.54741-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Now that there has been a dedicated mailing list, patchwork project, and
git repository set up for filesystem encryption, update the MAINTAINERS
file accordingly.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 MAINTAINERS | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 38d3e4ed7208..22b509fb1c5e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5365,10 +5365,12 @@ F:	Documentation/filesystems/caching/
 F:	fs/fscache/
 F:	include/linux/fscache*.h
 
-FS-CRYPTO: FILE SYSTEM LEVEL ENCRYPTION SUPPORT
+FSCRYPT: FILE SYSTEM LEVEL ENCRYPTION SUPPORT
 M:	Theodore Y. Ts'o <tytso@mit.edu>
 M:	Jaegeuk Kim <jaegeuk@kernel.org>
-L:	linux-fsdevel@vger.kernel.org
+L:	linux-fscrypt@vger.kernel.org
+Q:	https://patchwork.kernel.org/project/linux-fscrypt/list/
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git
 S:	Supported
 F:	fs/crypto/
 F:	include/linux/fscrypt*.h
-- 
2.13.0.rc0.306.g87b477812d-goog
