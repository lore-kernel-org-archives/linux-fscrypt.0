Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 993833403FF
	for <linux-fscrypt@vger.kernel.org>; Wed, 24 Jun 2026 16:52:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782319947; cv=none; b=dskaBaeRNgq19HipaZNiZ3ADoa15zkPBJmiltf1BTJrODb/HeKmFCkDjRsZ5GITHhfccKW8NEpGzVBuql/TPGy+SBIj5uN6jijmOZngcY7Wcj8Tsru07gHeiWPyxrzs3McLwmLJEvyZA8t2/1b+XTsFHKBYc9mh7WR64qbkDwqM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782319947; c=relaxed/simple;
	bh=cPtOyPjRrTOZWmDdebPD769nsrmw6U+FuUUMc1G7m0I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Z16IUVM8kWM+rg9kFnfhhApuSS2qffQt4quTnPOghmduJcP9lXndMzNoSVjssKuWiOowETFCVaqZR9YKKy8qsQYUaS5jaHlp0g3MFDGRa/jd+yTBKzCtYJMMeWofc5X9iYrHcMZLCZohb1VzDaYvjntsqezVcrYI1gf5dZubums=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 8970176062;
	Wed, 24 Jun 2026 16:51:51 +0000 (UTC)
Authentication-Results: smtp-out2.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 6BCF4779A8;
	Wed, 24 Jun 2026 16:51:51 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id KF/XGScLPGrUTgAAD6G6ig
	(envelope-from <neelx@suse.com>); Wed, 24 Jun 2026 16:51:51 +0000
From: Daniel Vacek <neelx@suse.com>
To: David Sterba <dsterba@suse.com>
Cc: Daniel Vacek <neelx@suse.com>,
	linux-fscrypt@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 8/8] btrfs-progs: recognize ENCRYPT inode item flag
Date: Wed, 24 Jun 2026 18:51:44 +0200
Message-ID: <20260624165144.556908-9-neelx@suse.com>
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
X-Rspamd-Queue-Id: 8970176062
X-Rspamd-Action: no action

Signed-off-by: Daniel Vacek <neelx@suse.com>
---
 kernel-shared/print-tree.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel-shared/print-tree.c b/kernel-shared/print-tree.c
index d68398e9..106708ef 100644
--- a/kernel-shared/print-tree.c
+++ b/kernel-shared/print-tree.c
@@ -1011,6 +1011,7 @@ static struct readable_flag_entry inode_flags_array[] = {
 	DEF_INODE_FLAG_ENTRY(NOATIME),
 	DEF_INODE_FLAG_ENTRY(DIRSYNC),
 	DEF_INODE_FLAG_ENTRY(COMPRESS),
+	DEF_INODE_FLAG_ENTRY(ENCRYPT),
 	DEF_INODE_FLAG_ENTRY(ROOT_ITEM_INIT),
 };
 static const int inode_flags_num = ARRAY_SIZE(inode_flags_array);
-- 
2.53.0

