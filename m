Return-Path: <SRS0=ijPz=OO=infradead.org=rdunlap@kernel.org>
From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH -next] fsverity: fix Documentation typo
Message-ID: <27be2f83-ea37-5818-9709-7e6c11c73b79@infradead.org>
Date: Tue, 4 Dec 2018 17:24:00 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
To: Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
Cc: Eric Biggers <ebiggers@kernel.org>, "Theodore Y. Ts'o" <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix a typo in fsverity.rst.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Eric Biggers <ebiggers@kernel.org>
Cc: Theodore Y. Ts'o <tytso@mit.edu>
Cc: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
---
 Documentation/filesystems/fsverity.rst |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20181204.orig/Documentation/filesystems/fsverity.rst
+++ linux-next-20181204/Documentation/filesystems/fsverity.rst
@@ -269,7 +269,7 @@ file as being in the "fsveritysetup" for
 fs-verity footer if zeroes have been appended.
 
 The kernel cannot handle fs-verity footers that cross a page boundary.
-Padding must be prepended as needed to meet this constaint.
+Padding must be prepended as needed to meet this constraint.
 
 Filesystem support
 ==================
