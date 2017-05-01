Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fscrypt: correct collision claim for digested names
Date: Mon,  1 May 2017 11:43:32 -0700
Message-Id: <20170501184332.37532-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mtd@lists.infradead.org, Gwendal Grignou <gwendal@chromium.org>, hashimoto@chromium.org, kinaba@chromium.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

As I noted on the mailing list, it's easier than I originally thought to
create intentional collisions in the digested names.  Unfortunately it's
not too easy to solve this, so for now just fix the comment to not lie.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 include/linux/fscrypt_supp.h | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/include/linux/fscrypt_supp.h b/include/linux/fscrypt_supp.h
index e12c224a0d1e..cd4e82c17304 100644
--- a/include/linux/fscrypt_supp.h
+++ b/include/linux/fscrypt_supp.h
@@ -81,20 +81,16 @@ extern int fscrypt_fname_usr_to_disk(struct inode *, const struct qstr *,
  * followed by the second-to-last ciphertext block of the filename.  Due to the
  * use of the CBC-CTS encryption mode, the second-to-last ciphertext block
  * depends on the full plaintext.  (Note that ciphertext stealing causes the
- * last two blocks to appear "flipped".)  This makes collisions very unlikely:
- * just a 1 in 2^128 chance for two filenames to collide even if they share the
- * same filesystem-specific hashes.
+ * last two blocks to appear "flipped".)  This makes accidental collisions very
+ * unlikely: just a 1 in 2^128 chance for two filenames to collide even if they
+ * share the same filesystem-specific hashes.
  *
- * This scheme isn't strictly immune to intentional collisions because it's
- * basically like a CBC-MAC, which isn't secure on variable-length inputs.
- * However, generating a CBC-MAC collision requires the ability to choose
- * arbitrary ciphertext, which won't normally be possible with filename
- * encryption since it would require write access to the raw disk.
- *
- * Taking a real cryptographic hash like SHA-256 over the full ciphertext would
- * be better in theory but would be less efficient and more complicated to
- * implement, especially since the filesystem would need to calculate it for
- * each directory entry examined during a search.
+ * However, this scheme isn't immune to intentional collisions, which can be
+ * created by anyone able to create arbitrary plaintext filenames and view them
+ * without the key.  Making the "digest" be a real cryptographic hash like
+ * SHA-256 over the full ciphertext would prevent this, although it would be
+ * less efficient and harder to implement, especially since the filesystem would
+ * need to calculate it for each directory entry examined during a search.
  */
 struct fscrypt_digested_name {
 	u32 hash;
-- 
2.13.0.rc0.306.g87b477812d-goog
