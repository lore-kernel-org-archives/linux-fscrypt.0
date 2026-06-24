Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A348E34216C
	for <linux-fscrypt@vger.kernel.org>; Wed, 24 Jun 2026 16:52:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782319923; cv=none; b=dYjeEIu59N2nNjhdZ/dFSXH/uKwBbFArFy5u1cAJbNkWdyjKQVlzUZR3yYpNjimqDQcERU05i5ztPbMI368A463+Z+dVCJV6TO7Yv3bePbnkrhmIyKNqZeA2TkZkj0UrfS1N7Pkd2KXImG/g5SYgISi+dFzWN1uosGoHh5REHFc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782319923; c=relaxed/simple;
	bh=FEhoGe6/dwUAe/swlMKIquDdilQn7PQ1GjRAFsos8Zc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Go/KTCBRFqemFWy0pkePpYvp5ljidTzp+ja9Dhd45Kdsce6+15BL8M31RYVpmaxqXrwK1v065cz3y4ZtbaGRU4SV9iFBpqzL6ze1K74n++i6aCl7AJW0ScpY4+GScIO9sac0wuS6qRHahWOnrkXkB4uXEvBm7oJCakhMaTDsuFM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 3E2EC76059;
	Wed, 24 Jun 2026 16:51:51 +0000 (UTC)
Authentication-Results: smtp-out2.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 268C5779AC;
	Wed, 24 Jun 2026 16:51:51 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id YPTyCCcLPGrUTgAAD6G6ig
	(envelope-from <neelx@suse.com>); Wed, 24 Jun 2026 16:51:51 +0000
From: Daniel Vacek <neelx@suse.com>
To: David Sterba <dsterba@suse.com>
Cc: Daniel Vacek <neelx@suse.com>,
	linux-fscrypt@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: [PATCH v2 5/8] btrfs-progs: print encryptin type field of file extents
Date: Wed, 24 Jun 2026 18:51:41 +0200
Message-ID: <20260624165144.556908-6-neelx@suse.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260624165144.556908-1-neelx@suse.com>
References: <20260624165144.556908-1-neelx@suse.com>
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
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Spam-Flag: NO
X-Spam-Score: -4.00
X-Spam-Level: 
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Spamd-Result: default: False [-4.00 / 50.00];
	REPLY(-4.00)[]
X-Rspamd-Queue-Id: 3E2EC76059
X-Rspamd-Action: no action

From: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>

Encrypted file extents now have the 'encryption' field set to an
encryption type.  Let's print it.

Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---
 check/main.c               | 1 -
 kernel-shared/print-tree.c | 2 ++
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/check/main.c b/check/main.c
index dedb4db4..a32247b3 100644
--- a/check/main.c
+++ b/check/main.c
@@ -1778,7 +1778,6 @@ static int process_file_extent(struct btrfs_root *root,
 			rec->errors |= I_ERR_BAD_FILE_EXTENT;
 		if (extent_type == BTRFS_FILE_EXTENT_PREALLOC &&
 		    (btrfs_file_extent_compression(eb, fi) ||
-		     btrfs_file_extent_encryption(eb, fi) ||
 		     btrfs_file_extent_other_encoding(eb, fi)))
 			rec->errors |= I_ERR_BAD_FILE_EXTENT;
 		if (compression && rec->nodatasum)
diff --git a/kernel-shared/print-tree.c b/kernel-shared/print-tree.c
index 0afa3696..159f0825 100644
--- a/kernel-shared/print-tree.c
+++ b/kernel-shared/print-tree.c
@@ -471,6 +471,8 @@ static void print_file_extent_item(struct extent_buffer *eb,
 	printf("\t\textent compression %hhu (%s)\n",
 			btrfs_file_extent_compression(eb, fi),
 			compress_str);
+	printf("\t\textent encryption %hhu\n",
+			btrfs_file_extent_encryption(eb, fi));
 }
 
 /* Caller should ensure sizeof(*ret) >= 16("DATA|TREE_BLOCK") */
-- 
2.53.0

