Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fs/crypto/hooks.c: fix build with pre-4.6 gcc versions
Date: Fri, 19 Jan 2018 13:45:24 -0800
Message-Id: <20180119214524.222850-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

gcc versions prior to 4.6 require an extra level of braces when using a
designated initializer for a member in an anonymous struct or union.
This caused a compile error with the 'struct qstr' initialization in
__fscrypt_encrypt_symlink().

Fix it by using QSTR_INIT().

Reported-by: Andrew Morton <akpm@linux-foundation.org>
Fixes: 76e81d6d5048 ("fscrypt: new helper functions for ->symlink()")
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/hooks.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index 28f9f059571d..bec06490fb13 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -158,7 +158,7 @@ int __fscrypt_encrypt_symlink(struct inode *inode, const char *target,
 			      unsigned int len, struct fscrypt_str *disk_link)
 {
 	int err;
-	struct qstr iname = { .name = target, .len = len };
+	struct qstr iname = QSTR_INIT(target, len);
 	struct fscrypt_symlink_data *sd;
 	unsigned int ciphertext_len;
 
-- 
2.16.0.rc1.238.g530d649a79-goog
