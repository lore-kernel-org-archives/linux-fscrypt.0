Return-Path: <ebiggers3@gmail.com>
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH 15/24] f2fs: switch to fscrypt_get_symlink()
Date: Fri, 15 Dec 2017 09:42:16 -0800
Message-Id: <20171215174225.31583-16-ebiggers3@gmail.com>
In-Reply-To: <20171215174225.31583-1-ebiggers3@gmail.com>
References: <20171215174225.31583-1-ebiggers3@gmail.com>
To: linux-fscrypt@vger.kernel.org
Cc: "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/f2fs/namei.c | 66 ++++++++-------------------------------------------------
 1 file changed, 9 insertions(+), 57 deletions(-)

diff --git a/fs/f2fs/namei.c b/fs/f2fs/namei.c
index 5b114844806c..37816d2ebb93 100644
--- a/fs/f2fs/namei.c
+++ b/fs/f2fs/namei.c
@@ -1137,68 +1137,20 @@ static const char *f2fs_encrypted_get_link(struct dentry *dentry,
 					   struct inode *inode,
 					   struct delayed_call *done)
 {
-	struct page *cpage = NULL;
-	char *caddr, *paddr = NULL;
-	struct fscrypt_str cstr = FSTR_INIT(NULL, 0);
-	struct fscrypt_str pstr = FSTR_INIT(NULL, 0);
-	struct fscrypt_symlink_data *sd;
-	u32 max_size = inode->i_sb->s_blocksize;
-	int res;
+	struct page *page;
+	const char *target;
 
 	if (!dentry)
 		return ERR_PTR(-ECHILD);
 
-	res = fscrypt_get_encryption_info(inode);
-	if (res)
-		return ERR_PTR(res);
-
-	cpage = read_mapping_page(inode->i_mapping, 0, NULL);
-	if (IS_ERR(cpage))
-		return ERR_CAST(cpage);
-	caddr = page_address(cpage);
-
-	/* Symlink is encrypted */
-	sd = (struct fscrypt_symlink_data *)caddr;
-	cstr.name = sd->encrypted_path;
-	cstr.len = le16_to_cpu(sd->len);
-
-	/* this is broken symlink case */
-	if (unlikely(cstr.len == 0)) {
-		res = -ENOENT;
-		goto errout;
-	}
-
-	if ((cstr.len + sizeof(struct fscrypt_symlink_data) - 1) > max_size) {
-		/* Symlink data on the disk is corrupted */
-		res = -EIO;
-		goto errout;
-	}
-	res = fscrypt_fname_alloc_buffer(inode, cstr.len, &pstr);
-	if (res)
-		goto errout;
-
-	res = fscrypt_fname_disk_to_usr(inode, 0, 0, &cstr, &pstr);
-	if (res)
-		goto errout;
-
-	/* this is broken symlink case */
-	if (unlikely(pstr.name[0] == 0)) {
-		res = -ENOENT;
-		goto errout;
-	}
-
-	paddr = pstr.name;
-
-	/* Null-terminate the name */
-	paddr[pstr.len] = '\0';
+	page = read_mapping_page(inode->i_mapping, 0, NULL);
+	if (IS_ERR(page))
+		return ERR_CAST(page);
 
-	put_page(cpage);
-	set_delayed_call(done, kfree_link, paddr);
-	return paddr;
-errout:
-	fscrypt_fname_free_buffer(&pstr);
-	put_page(cpage);
-	return ERR_PTR(res);
+	target = fscrypt_get_symlink(inode, page_address(page),
+				     inode->i_sb->s_blocksize, done);
+	put_page(page);
+	return target;
 }
 
 const struct inode_operations f2fs_encrypted_symlink_inode_operations = {
-- 
2.15.1
