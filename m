Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68A5F43E9F7
	for <linux-fscrypt@vger.kernel.org>; Fri,  6 Feb 2026 18:24:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770402280; cv=none; b=Ypp8TCsBNp3lkUpHxWUxBHpcbPNjJcBJw4UdXF/vijr1KELAg0G2wOTx0dMuqTyxwAv1o2KPjvc49nWqHq+LT8iiYVyz7pmpPdS7yvAdGyJiSNew0ULRXvoqG1UXzdD3Lxutf+lI/yH6ZSTEu3bhQjHyU4u7QUzIz6wFbh4uO24=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770402280; c=relaxed/simple;
	bh=ILW5MjqFNyY2StUj24TeI6krWd5DbLhdgiXmKM46mD0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FvCMgQMPDkg+5e202yxlSZR/QQ8BuhtUR5cjr1pTk6+FcufXPJNTor2lr5rGDVjqArX/x9eRIigXpPKLOrshbW24PGG7Tpos8N7LvRLiARNpfGt5ulCcciKE2giSt2wwdj7MUsT0EeHDq33O+T/flHc7GI2E47ZXM16/qeRxAdc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 1DD1C3E750;
	Fri,  6 Feb 2026 18:24:07 +0000 (UTC)
Authentication-Results: smtp-out1.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id E69543EA63;
	Fri,  6 Feb 2026 18:24:06 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id aMq9N8YxhmkTCQAAD6G6ig
	(envelope-from <neelx@suse.com>); Fri, 06 Feb 2026 18:24:06 +0000
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
Subject: [PATCH v6 20/43] btrfs: add fscrypt_info and encryption_type to ordered_extent
Date: Fri,  6 Feb 2026 19:22:52 +0100
Message-ID: <20260206182336.1397715-21-neelx@suse.com>
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
X-Spamd-Result: default: False [-4.00 / 50.00];
	REPLY(-4.00)[]
X-Spam-Flag: NO
X-Spam-Score: -4.00
X-Rspamd-Queue-Id: 1DD1C3E750
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Rspamd-Action: no action
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Spam-Level: 

From: Josef Bacik <josef@toxicpanda.com>

We're going to need these to update the file extent items once the
writes are complete.  Add them and add the pieces necessary to assign
them and free everything.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---

v5: https://lore.kernel.org/linux-btrfs/de9ff13d1dc042b764c224d039fbb2a08946e004.1706116485.git.josef@toxicpanda.com/
 * Changed encryption_type member to u8.
---
 fs/btrfs/ordered-data.c | 2 ++
 fs/btrfs/ordered-data.h | 6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/fs/btrfs/ordered-data.c b/fs/btrfs/ordered-data.c
index 5df02c707aee..7a5701937184 100644
--- a/fs/btrfs/ordered-data.c
+++ b/fs/btrfs/ordered-data.c
@@ -192,6 +192,7 @@ static struct btrfs_ordered_extent *alloc_ordered_extent(
 	}
 	entry->inode = inode;
 	entry->compress_type = compress_type;
+	entry->encryption_type = BTRFS_ENCRYPTION_NONE;
 	entry->truncated_len = (u64)-1;
 	entry->qgroup_rsv = qgroup_rsv;
 	entry->flags = flags;
@@ -630,6 +631,7 @@ void btrfs_put_ordered_extent(struct btrfs_ordered_extent *entry)
 		btrfs_add_delayed_iput(entry->inode);
 		list_for_each_entry_safe(sum, tmp, &entry->list, list)
 			kvfree(sum);
+		fscrypt_put_extent_info(entry->fscrypt_info);
 		kmem_cache_free(btrfs_ordered_extent_cache, entry);
 	}
 }
diff --git a/fs/btrfs/ordered-data.h b/fs/btrfs/ordered-data.h
index 1e6b0b182b29..ce19198e7f84 100644
--- a/fs/btrfs/ordered-data.h
+++ b/fs/btrfs/ordered-data.h
@@ -124,6 +124,9 @@ struct btrfs_ordered_extent {
 	/* compression algorithm */
 	int compress_type;
 
+	/* encryption mode */
+	u8 encryption_type;
+
 	/* Qgroup reserved space */
 	int qgroup_rsv;
 
@@ -133,6 +136,9 @@ struct btrfs_ordered_extent {
 	/* the inode we belong to */
 	struct btrfs_inode *inode;
 
+	/* the fscrypt_info for this extent, if necessary */
+	struct fscrypt_extent_info *fscrypt_info;
+
 	/* list of checksums for insertion when the extent io is done */
 	struct list_head list;
 
-- 
2.51.0

