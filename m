Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fscrypt: lock mutex before checking for bounce page pool
Date: Thu,  6 Jul 2017 10:57:48 -0700
Message-Id: <20170706175748.33093-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

fscrypt_initialize(), which allocates the global bounce page pool when
an encrypted file is first accessed, uses "double-checked locking" to
try to avoid locking fscrypt_init_mutex.  However, it doesn't use any
memory barriers, so it's theoretically possible for a thread to observe
a bounce page pool which has not been fully initialized.  This is a
classic bug with "double-checked locking".

While "only a theoretical issue" in the latest kernel, in pre-4.8
kernels the pointer that was checked was not even the last to be
initialized, so it was easily possible for a crash (NULL pointer
dereference) to happen.  This was changed only incidentally by the large
refactor to use fs/crypto/.

Solve both problems in a trivial way that can easily be backported: just
always take the mutex.  It's theoretically less efficient, but it
shouldn't be noticeable in practice as the mutex is only acquired very
briefly once per encrypted file.

Later I'd like to make this use a helper macro like DO_ONCE().  However,
DO_ONCE() runs in atomic context, so we'd need to add a new macro that
allows blocking.

Cc: stable@vger.kernel.org # v4.1+
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/crypto/crypto.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index c7835df7e7b8..d262a93d9b31 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -410,11 +410,8 @@ int fscrypt_initialize(unsigned int cop_flags)
 {
 	int i, res = -ENOMEM;
 
-	/*
-	 * No need to allocate a bounce page pool if there already is one or
-	 * this FS won't use it.
-	 */
-	if (cop_flags & FS_CFLG_OWN_PAGES || fscrypt_bounce_page_pool)
+	/* No need to allocate a bounce page pool if this FS won't use it. */
+	if (cop_flags & FS_CFLG_OWN_PAGES)
 		return 0;
 
 	mutex_lock(&fscrypt_init_mutex);
-- 
2.13.2.725.g09c95d1e9-goog
