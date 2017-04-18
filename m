Return-Path: <linux-ext4-owner@vger.kernel.org>
From: Gwendal Grignou <gwendal@chromium.org>
Subject: [PATCH] fscrypt: use 32 bytes of encrypted filename
Date: Tue, 18 Apr 2017 14:06:42 -0700
Message-Id: <20170418210642.6039-1-gwendal@chromium.org>
Sender: linux-ext4-owner@vger.kernel.org
To: tytso@mit.edu, ebiggers@google.com
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, kinaba@chromium.org, hashimoto@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>

If we use only 16 bytes, due to how CBC works, if the names have the
same beginning, their last ciphertext block (16 bytes) may be identical.

It happens when two file names share the first 16k bytes and both have
length withn 16 * n + 13 and 16 * n + 16.

Instead use 32 bytes to build the filenames from encrypted data when
directory is scrambled.

The drawback is the scrambled filenames change after applying the patch.
Consider an encrypted directory with:

ls -il
total 8
1177380 -rw-r--r--. 1 root root 0 Apr 18 12:10
system@framework@boot-telephony-common.art.crc
1177379 -rw-r--r--. 1 root root 0 Apr 18 12:10
system@framework@boot-telephony-common.oat.crc

Once the key is invalidated, without the patch, ls -li produces:
1177379 -rw-r--r--. 1 root root 0 Apr 18 12:10
_a1Psh01n8FdhC8s9pUywlAyFzlz7n6C3
1177379 -rw-r--r--. 1 root root 0 Apr 18 12:10
_wJS,0akq14ehC8s9pUywlAyFzlz7n6C3

Both files show with the same inode.

After the patch, the names are different, but the inode information is
now correct:
ls -li
1177380 -rw-r--r--. 1 root root 0 Apr 18 12:10
_a1Psh01n8FtxbeglW8BqhuthSUxMqh6cFKwz2nSJDXCIXMXOvfqLcD
1177379 -rw-r--r--. 1 root root 0 Apr 18 12:10
_wJS,0akq14eJcuQks7f2Vsg,zE0Jdz98FKwz2nSJDXCIXMXOvfqLcD

Tested only on ext4.

Signed-off-by: Gwendal Grignou <gwendal@chromium.org>
---
Script to reproduce the error:

BASE_DIR="~/"
DIR="${BASE_DIR}/tmp"
# Create directory.
mkdir -p "${DIR}"
echo foobar | e4crypt add_key "${DIR}"
# Fill directory.
cd "${DIR}"
touch system@framework@boot-telephony-common.oat.crc
touch system@framework@boot-telephony-common.art.crc
cd ..
# Check files have different inode.
ls -il "${DIR}"
# Invalidate key
KEY="$(keyctl show | grep $(e4crypt get_policy "${DIR}" | cut -d ':' -f 2) | sed -ne 's/\(.*\) --al.*/\1/p')"
sync
keyctl invalidate "${KEY}"
echo 3 > /proc/sys/vm/drop_caches
# Once the key is invalidated, both files have the same inode:
ls -il "${DIR}"
if [ $(ls -i1 "${DIR}" | cut -d ' ' -f 1 | uniq | wc -l) -eq 1 ] ; then
  echo same inode!
fi
# if we try to remove the directory, we will get an error
# : Structure needs cleaning
# rm -rf "${DIR}"

 fs/crypto/fname.c | 20 +++++++++++++-------
 fs/ext4/namei.c   |  4 ++--
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index 80bb956e14e5..71ddc3eaa62d 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -274,7 +274,7 @@ int fscrypt_fname_disk_to_usr(struct inode *inode,
 			struct fscrypt_str *oname)
 {
 	const struct qstr qname = FSTR_TO_QSTR(iname);
-	char buf[24];
+	char buf[FS_FNAME_CRYPTO_DIGEST_SIZE + sizeof(u64)];
 
 	if (fscrypt_is_dot_dotdot(&qname)) {
 		oname->name[0] = '.';
@@ -295,14 +295,19 @@ int fscrypt_fname_disk_to_usr(struct inode *inode,
 		return 0;
 	}
 	if (hash) {
-		memcpy(buf, &hash, 4);
-		memcpy(buf + 4, &minor_hash, 4);
+		memcpy(buf, &hash, sizeof(u32));
+		memcpy(buf + 4, &minor_hash, sizeof(u32));
 	} else {
 		memset(buf, 0, 8);
 	}
-	memcpy(buf + 8, iname->name + iname->len - 16, 16);
+	memcpy(buf + sizeof(u64),
+	       iname->name + iname->len - FS_FNAME_CRYPTO_DIGEST_SIZE,
+	       FS_FNAME_CRYPTO_DIGEST_SIZE);
 	oname->name[0] = '_';
-	oname->len = 1 + digest_encode(buf, 24, oname->name + 1);
+	oname->len = 1 + digest_encode(
+			buf,
+			FS_FNAME_CRYPTO_DIGEST_SIZE + sizeof(u64),
+			oname->name + 1);
 	return 0;
 }
 EXPORT_SYMBOL(fscrypt_fname_disk_to_usr);
@@ -375,10 +380,11 @@ int fscrypt_setup_filename(struct inode *dir, const struct qstr *iname,
 	 */
 	if (iname->name[0] == '_')
 		bigname = 1;
-	if ((bigname && (iname->len != 33)) || (!bigname && (iname->len > 43)))
+	if ((bigname && iname->len != 55) || (!bigname && (iname->len > 43)))
 		return -ENOENT;
 
-	fname->crypto_buf.name = kmalloc(32, GFP_KERNEL);
+	fname->crypto_buf.name = kmalloc(
+			FS_FNAME_CRYPTO_DIGEST_SIZE + sizeof(u64), GFP_KERNEL);
 	if (fname->crypto_buf.name == NULL)
 		return -ENOMEM;
 
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index c4a389a6027b..14b2a2335a32 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -1257,8 +1257,8 @@ static inline int ext4_match(struct ext4_filename *fname,
 			int ret;
 			if (de->name_len < 16)
 				return 0;
-			ret = memcmp(de->name + de->name_len - 16,
-				     fname->crypto_buf.name + 8, 16);
+			ret = memcmp(de->name + de->name_len - 32,
+				     fname->crypto_buf.name + 8, 32);
 			return (ret == 0) ? 1 : 0;
 		}
 		name = fname->crypto_buf.name;
-- 
2.12.2.816.g2cccc81164-goog
