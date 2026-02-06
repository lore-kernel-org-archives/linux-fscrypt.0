Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2264143DA53
	for <linux-fscrypt@vger.kernel.org>; Fri,  6 Feb 2026 18:25:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770402339; cv=none; b=K7FpPgVzIcmMUaGxEXFxbYo/wYJvAujoxWKcGIj13zK3SQi5h2/vZNgrq5jZwi7fTdqH2R4gj7HcaLThl+TAX7Z5GSQGyMVuZhQ3DhNrdDuXUF+F1aj0q5aGooGw/u6y0/SpDN5J7d7KXyhk8esZdAIoARAXO1ZDBi4aDXqy+Zk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770402339; c=relaxed/simple;
	bh=fZxW8wexZZ7fyQehWlyzdfCe9GH5o7H4GiTaE8gAS1o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bJcYo64QRwBce1++CC8AGYhbbPWB4bZpmkByAsU+ZeMscQYGzKUdrxtb7KXp8wuvavj5zWY9KyWegJwWdc4Lt9jceD/7bIVUCHTI1/lsUnje4a78meWNFYRWq72NTtg7ZF/9NPXMlqErQXoSOiMDmbGmzwyL4CbW6pChnXa7pEc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 69D0A3E745;
	Fri,  6 Feb 2026 18:24:19 +0000 (UTC)
Authentication-Results: smtp-out1.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 3F3A63EA63;
	Fri,  6 Feb 2026 18:24:19 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id SJfzDtMxhmkTCQAAD6G6ig
	(envelope-from <neelx@suse.com>); Fri, 06 Feb 2026 18:24:19 +0000
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
Subject: [PATCH v6 40/43] btrfs: support encryption with log replay
Date: Fri,  6 Feb 2026 19:23:12 +0100
Message-ID: <20260206182336.1397715-41-neelx@suse.com>
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
X-Rspamd-Queue-Id: 69D0A3E745
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Level: 
X-Spamd-Result: default: False [-4.00 / 50.00];
	REPLY(-4.00)[]
X-Spam-Flag: NO

From: Josef Bacik <josef@toxicpanda.com>

Log replay needs a few tweaks in order to make sure everything works
with encryption.

1. Copy in the fscrypt context if we find one in the log.
2. Set NEEDS_FULL_SYNC when we update the inode context so all of the
   items are copied into the log at fsync time.

This makes replay of encrypted files work properly.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---

v5: https://lore.kernel.org/linux-btrfs/d1ada7ac632c2ab554a840c7ba29b53a93b9855f.1706116485.git.josef@toxicpanda.com/
 * Adapted to the redesigned encryption context storing.
   - No need to specially handle the extent item now.
     It is not any different to before and the
     new context items are simply copied.
---
 fs/btrfs/fscrypt.c  | 1 +
 fs/btrfs/tree-log.c | 4 +++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/btrfs/fscrypt.c b/fs/btrfs/fscrypt.c
index bcb86cbaa171..cbdeaa75a868 100644
--- a/fs/btrfs/fscrypt.c
+++ b/fs/btrfs/fscrypt.c
@@ -145,6 +145,7 @@ static int btrfs_fscrypt_set_context(struct inode *inode, const void *ctx,
 			goto out_err;
 	}
 
+	set_bit(BTRFS_INODE_NEEDS_FULL_SYNC, &BTRFS_I(inode)->runtime_flags);
 	leaf = path->nodes[0];
 	ptr = btrfs_item_ptr_offset(leaf, path->slots[0]);
 
diff --git a/fs/btrfs/tree-log.c b/fs/btrfs/tree-log.c
index 0d01e31a4592..fa75531f9633 100644
--- a/fs/btrfs/tree-log.c
+++ b/fs/btrfs/tree-log.c
@@ -2922,7 +2922,9 @@ static int replay_one_buffer(struct extent_buffer *eb,
 			continue;
 
 		/* these keys are simply copied */
-		if (wc->log_key.type == BTRFS_XATTR_ITEM_KEY) {
+		if (wc->log_key.type == BTRFS_XATTR_ITEM_KEY ||
+		    wc->log_key.type == BTRFS_FSCRYPT_INODE_CTX_KEY ||
+		    wc->log_key.type == BTRFS_FSCRYPT_CTX_KEY) {
 			ret = overwrite_item(wc);
 			if (ret)
 				break;
-- 
2.51.0

