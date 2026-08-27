Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6EC634F279;
	Thu, 27 Aug 2026 03:31:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787801466; cv=none; b=cwPpPO8uGeEZY1zcUV6RRD+S36vq31Lp66z/GzCOOIZI61mz0BTzzAfZttthy2UJZvYlD4Pr36Rm+gRo8fgeq+Q7YifWBZ/9wPgq92kTzFERs6gE2dbEbSTQI1PTrzu6D1mHe8ZMpXLvqmMOVrwJesnlMf3OcMbpUyzCYzh1tAg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787801466; c=relaxed/simple;
	bh=LU0vbSNSxfF0p2/sBaqpmif39OQ1yIFgsr+3msNa/18=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=QirBM+4qh5TjfE7sXo9LhTf136hi54MxnRzPmz5nwvMc2TvKODE4xlZKbX0lMve6/0pdvEjOu5eTjoTkeDcHz7yq39dTZZdTXxXbWLTkplb0ZjkSNVVpZY76wVCp1BNbZEaMiIcivG4Yi0BiMuEfjRzRY1IqEGdVsPj0A7khZOo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dMYHYNA+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dMYHYNA+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 12E321F000E9;
	Thu, 27 Aug 2026 03:31:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787801465;
	bh=Nmy2ReXr+u9YxVp+JLYKjGsSYx4btGirL1/+k+TXAhM=;
	h=From:To:Cc:Subject:Date;
	b=dMYHYNA+o4S0S2UiA9ec28h02ZvOqlVF5T/M7wvdI1lUMBbQ1zONiq2iDOQni4N6H
	 658ZV7bYXwhSjMSfjPmTTn1xlRe/lXNKD5Tp+i9posWJhDSkG92qf6uTjKI4DjdOoU
	 OZ6YSIzzvHlq/5NuInIGOVCnZqfKz1KRuBjcREHf9FWxbTxlUvXI9aix7xbADW6CRq
	 TX8moIqGFcdj5oVTZ/C2gj+M/dYktq6dcOky2T65lPRB4F+/xVNJRQSamIEMTGLg8r
	 SHaG/3nZeagLiASAHyWg7NwmVhomoyTzkbKJ9WWrSFbphgc8uX36eHLDwBezKMLaB8
	 y4Lj/7sphhcow==
From: Eric Biggers <ebiggers@kernel.org>
To: stable@vger.kernel.org
Cc: linux-ext4@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>,
	Disha Goel <disgoel@linux.ibm.com>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>
Subject: [PATCH 6.6] ext4: don't enable DAX on new encrypted files
Date: Wed, 26 Aug 2026 20:28:57 -0700
Message-ID: <20260827032857.82762-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

commit da32af420d6d466e247c43ac0b829edeac7ae0ad upstream.

Currently, when a new encrypted regular file is created, the call to
ext4_set_inode_flags(inode, init=true) in __ext4_new_inode() is made
before EXT4_INODE_ENCRYPT is set.  As a result, it can set S_DAX if the
filesystem is mounted with "-o dax=always".

EXT4_INODE_ENCRYPT then actually gets set a bit later in
__ext4_new_inode(), when it calls fscrypt_set_context() which calls
ext4_set_context().  ext4_set_context() sets EXT4_INODE_ENCRYPT and
calls ext4_set_inode_flags(inode, init=false) to set S_ENCRYPTED too.

This was intended to clear S_DAX as well.  However, this was broken by
commit 043546e46dc7 ("fs/ext4: Only change S_DAX on inode load").  This
causes data written to the file to bypass encryption, also causing
xfstests failures such as generic/548 (when "-o dax=always" is used).

Fix this by simplifying the flow by making __ext4_new_inode() set
EXT4_INODE_ENCRYPT earlier.  This makes it take effect in
ext4_set_inode_flags(inode, init=true), making S_DAX never be set.

Similarly, make EXT4_STATE_MAY_INLINE_DATA never be set in the first
place on new encrypted inodes.  Then it doesn't need to be cleared.

As a result of these simplifications, ext4_set_context() no longer needs
to change inode flags or state when 'handle != NULL'.  Remove that too.

Reported-by: Disha Goel <disgoel@linux.ibm.com>
Reported-by: Ojaswin Mujoo <ojaswin@linux.ibm.com>
Closes: https://lore.kernel.org/r/20260723085648.1500357-1-ojaswin@linux.ibm.com
Fixes: 043546e46dc7 ("fs/ext4: Only change S_DAX on inode load")
Cc: stable@vger.kernel.org
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
Tested-by: Disha Goel <disgoel@linux.ibm.com>
Reviewed-by: Ojaswin Mujoo <ojaswin@linux.ibm.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Link: https://patch.msgid.link/20260730175212.36923-1-ebiggers@kernel.org
Signed-off-by: Theodore Ts'o <tytso@mit.edu>
---
 fs/ext4/crypto.c | 40 ++++++++++++++++++++--------------------
 fs/ext4/ialloc.c |  4 ++++
 2 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
index 8292494a9b6c..8497f6125a8e 100644
--- a/fs/ext4/crypto.c
+++ b/fs/ext4/crypto.c
@@ -150,7 +150,13 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 	if (inode->i_ino == EXT4_ROOT_INO)
 		return -EPERM;
 
-	if (WARN_ON_ONCE(IS_DAX(inode) && i_size_read(inode)))
+	/*
+	 * For new encrypted inodes, S_DAX is never set in the first place.
+	 *
+	 * For existing inodes, this is called only on empty directories.  ext4
+	 * never sets S_DAX on directories.
+	 */
+	if (WARN_ON_ONCE(IS_DAX(inode)))
 		return -EINVAL;
 
 	if (ext4_test_inode_flag(inode, EXT4_INODE_DAX))
@@ -169,6 +175,14 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 	 */
 
 	if (handle) {
+		/*
+		 * __ext4_new_inode() should have already set the encrypt flag
+		 * on the inode and avoided enabling inline data.
+		 */
+		if (WARN_ON_ONCE(!IS_ENCRYPTED(inode)))
+			return -EINVAL;
+		if (WARN_ON_ONCE(ext4_test_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA)))
+			return -EINVAL;
 		/*
 		 * Since the inode is new it is ok to pass the
 		 * XATTR_CREATE flag. This is necessary to match the
@@ -176,21 +190,10 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 		 * function with the credits allocated for the new
 		 * inode.
 		 */
-		res = ext4_xattr_set_handle(handle, inode,
-					    EXT4_XATTR_INDEX_ENCRYPTION,
-					    EXT4_XATTR_NAME_ENCRYPTION_CONTEXT,
-					    ctx, len, XATTR_CREATE);
-		if (!res) {
-			ext4_set_inode_flag(inode, EXT4_INODE_ENCRYPT);
-			ext4_clear_inode_state(inode,
-					EXT4_STATE_MAY_INLINE_DATA);
-			/*
-			 * Update inode->i_flags - S_ENCRYPTED will be enabled,
-			 * S_DAX may be disabled
-			 */
-			ext4_set_inode_flags(inode, false);
-		}
-		return res;
+		return ext4_xattr_set_handle(handle, inode,
+					     EXT4_XATTR_INDEX_ENCRYPTION,
+					     EXT4_XATTR_NAME_ENCRYPTION_CONTEXT,
+					     ctx, len, XATTR_CREATE);
 	}
 
 	res = dquot_initialize(inode);
@@ -211,10 +214,7 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
 				    ctx, len, 0);
 	if (!res) {
 		ext4_set_inode_flag(inode, EXT4_INODE_ENCRYPT);
-		/*
-		 * Update inode->i_flags - S_ENCRYPTED will be enabled,
-		 * S_DAX may be disabled
-		 */
+		/* Update inode->i_flags to set S_ENCRYPTED. */
 		ext4_set_inode_flags(inode, false);
 		res = ext4_mark_inode_dirty(handle, inode);
 		if (res)
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index 8daebea58027..aa5afd7a17b9 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -996,6 +996,8 @@ struct inode *__ext4_new_inode(struct mnt_idmap *idmap,
 		err = fscrypt_prepare_new_inode(dir, inode, &encrypt);
 		if (err)
 			goto out;
+		if (encrypt)
+			i_flags |= EXT4_ENCRYPT_FL;
 	}
 
 	err = dquot_initialize(inode);
@@ -1310,6 +1312,8 @@ struct inode *__ext4_new_inode(struct mnt_idmap *idmap,
 	ei->i_extra_isize = sbi->s_want_extra_isize;
 	ei->i_inline_off = 0;
 	if (ext4_has_feature_inline_data(sb) &&
+	    /* Encrypted inodes cannot have inline data */
+	    !(ei->i_flags & EXT4_ENCRYPT_FL) &&
 	    (!(ei->i_flags & EXT4_DAX_FL) || S_ISDIR(mode)))
 		ext4_set_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA);
 	ret = inode;

base-commit: dc6160265ffc795a1832bc1424f58291d152c7bb
-- 
2.55.0

