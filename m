Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2403C44BC9F
	for <linux-fscrypt@vger.kernel.org>; Fri,  6 Feb 2026 18:25:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770402330; cv=none; b=N3yw6Y8IGkSPY3oYcdq/4NUuRZcw3q+JcngjVT4qk/TXJPMpfh98KfSZBn8spf+qkNFSJtuIYkuyHLrZq4Es8qW3pW58yVSbJn+LrvOINcuXDcG3cEUEAiyhiorqelJ146lnRuDaHsua7B30iEugP3O7Di6GxynsMF4TJcbgteI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770402330; c=relaxed/simple;
	bh=Tfn+Z9xauLtsg6WSNT0FytGznv6AKi3dk0uKZsElWiM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fS1Z1DhGf3tpgHUmfMo0TlI3LXDU+UZkSJuKVj1fRmdkTrqDxj10b1fGz1SDHkue6bRaBaX/gSA9hsG4AgtFQLutwby70+mupAcOzYRUj90yUxl/U9qMMWogLNDuMh+RCnbL5DTxt5guEWeybuZEkMcCqer7s5IdzB4VAUBgfdQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 7B99D3E75F;
	Fri,  6 Feb 2026 18:24:17 +0000 (UTC)
Authentication-Results: smtp-out1.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 505653EA63;
	Fri,  6 Feb 2026 18:24:17 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id IFK3EtExhmkTCQAAD6G6ig
	(envelope-from <neelx@suse.com>); Fri, 06 Feb 2026 18:24:17 +0000
From: Daniel Vacek <neelx@suse.com>
To: Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>,
	Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Jens Axboe <axboe@kernel.dk>,
	David Sterba <dsterba@suse.com>
Cc: linux-block@vger.kernel.org,
	Daniel Vacek <neelx@suse.com>,
	linux-fscrypt@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v6 36/43] btrfs: deal with encrypted symlinks in send
Date: Fri,  6 Feb 2026 19:23:08 +0100
Message-ID: <20260206182336.1397715-37-neelx@suse.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20260206182336.1397715-1-neelx@suse.com>
References: <20260206182336.1397715-1-neelx@suse.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Spam-Score: -4.00
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Rspamd-Action: no action
X-Rspamd-Queue-Id: 7B99D3E75F
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Level: 
X-Spamd-Result: default: False [-4.00 / 50.00];
	REPLY(-4.00)[]
X-Spam-Flag: NO

From: Josef Bacik <josef@toxicpanda.com>

Send needs to send the decrypted value of the symlinks, handle the case
where the inode is encrypted and decrypt the symlink name into a buffer
and copy this buffer into our fs_path struct.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---

v5: https://lore.kernel.org/linux-btrfs/4d97f35d6f85ff041b09bed33b63446a92b7a20c.1706116485.git.josef@toxicpanda.com/
 * read_symlink_encrypted() reworked from using pages to using folios.
---
 fs/btrfs/send.c | 45 ++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 42 insertions(+), 3 deletions(-)

diff --git a/fs/btrfs/send.c b/fs/btrfs/send.c
index 3dcfdba018b5..b77f96ae2fea 100644
--- a/fs/btrfs/send.c
+++ b/fs/btrfs/send.c
@@ -1701,9 +1701,7 @@ static int find_extent_clone(struct send_ctx *sctx,
 	return ret;
 }
 
-static int read_symlink(struct btrfs_root *root,
-			u64 ino,
-			struct fs_path *dest)
+static int read_symlink_unencrypted(struct btrfs_root *root, u64 ino, struct fs_path *dest)
 {
 	int ret;
 	BTRFS_PATH_AUTO_FREE(path);
@@ -1764,6 +1762,47 @@ static int read_symlink(struct btrfs_root *root,
 	return fs_path_add_from_extent_buffer(dest, path->nodes[0], off, len);
 }
 
+static int read_symlink_encrypted(struct btrfs_root *root, u64 ino, struct fs_path *dest)
+{
+	DEFINE_DELAYED_CALL(done);
+	const char *buf;
+	struct folio *folio;
+	struct btrfs_inode *inode;
+	int ret = 0;
+
+	inode = btrfs_iget(ino, root);
+	if (IS_ERR(inode))
+		return PTR_ERR(inode);
+
+	folio = read_mapping_folio(inode->vfs_inode.i_mapping, 0, NULL);
+	if (IS_ERR(folio)) {
+		iput(&inode->vfs_inode);
+		return PTR_ERR(folio);
+	}
+
+	buf = fscrypt_get_symlink(&inode->vfs_inode, folio_address(folio),
+				  BTRFS_MAX_INLINE_DATA_SIZE(root->fs_info),
+				  &done);
+	folio_put(folio);
+	iput(&inode->vfs_inode);
+
+	if (IS_ERR(buf))
+		return PTR_ERR(buf);
+
+	ret = fs_path_add(dest, buf, strlen(buf));
+	do_delayed_call(&done);
+	return ret;
+}
+
+
+static int read_symlink(struct btrfs_root *root, u64 ino,
+			struct fs_path *dest)
+{
+	if (btrfs_fs_incompat(root->fs_info, ENCRYPT))
+		return read_symlink_encrypted(root, ino, dest);
+	return read_symlink_unencrypted(root, ino, dest);
+}
+
 /*
  * Helper function to generate a file name that is unique in the root of
  * send_root and parent_root. This is used to generate names for orphan inodes.
-- 
2.51.0

