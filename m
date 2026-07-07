Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3710142E8E0
	for <linux-fscrypt@vger.kernel.org>; Tue,  7 Jul 2026 14:28:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783434494; cv=none; b=c5RxfQHoLRUxENHJY5/6CdK0kidh2STP5vbDldph3jGK3fOmv90/R1cxypJPYIxeWmlxMb/YWsN83+3GAA4RpRKfrlSCE2LZ2SeO93NwMFA8sOk8Fumf7nVJzpTnTl6g2cVYSYBkHIZtMKIree+++O4CzponH+0OfOGQU5Jb+DY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783434494; c=relaxed/simple;
	bh=DA0gDf/+Kao3lI5yyXsQwCUXZF4op+0khdlsTRAi9HY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=BHNmZh2ruxnfKDJ9A7i1V/y9B95zZXB9FIo7SzMPnEKHlwKsIaXq2zrG0Awe8Q5RRGaEeXzv+PSZcXJrxExv2+sKv35EGM5xT7yuP+M3JMvQJgeeGZ31ZtvkB+KsL9Q1hFYM6NuOj9NS3UeAYPUhDqxsawx1csQujjHZ/aVa9kI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 8AD0575D29;
	Tue,  7 Jul 2026 14:27:47 +0000 (UTC)
Authentication-Results: smtp-out2.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 69904779AE;
	Tue,  7 Jul 2026 14:27:47 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id QJg7GeMMTWoLaQAAD6G6ig
	(envelope-from <neelx@suse.com>); Tue, 07 Jul 2026 14:27:47 +0000
From: Daniel Vacek <neelx@suse.com>
To: David Sterba <dsterba@suse.com>
Cc: Daniel Vacek <neelx@suse.com>,
	linux-fscrypt@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 7/7] btrfs-progs: recognize ENCRYPT inode item flag
Date: Tue,  7 Jul 2026 16:27:36 +0200
Message-ID: <20260707142736.2330146-8-neelx@suse.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260707142736.2330146-1-neelx@suse.com>
References: <20260707142736.2330146-1-neelx@suse.com>
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
X-Rspamd-Queue-Id: 8AD0575D29
X-Spam-Flag: NO
X-Spam-Score: -4.00
X-Spam-Level: 
X-Rspamd-Action: no action
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Spamd-Result: default: False [-4.00 / 50.00];
	REPLY(-4.00)[]

Signed-off-by: Daniel Vacek <neelx@suse.com>
---
 kernel-shared/print-tree.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel-shared/print-tree.c b/kernel-shared/print-tree.c
index 6a4eee48..cae5c6df 100644
--- a/kernel-shared/print-tree.c
+++ b/kernel-shared/print-tree.c
@@ -1012,6 +1012,7 @@ static struct readable_flag_entry inode_flags_array[] = {
 	DEF_INODE_FLAG_ENTRY(NOATIME),
 	DEF_INODE_FLAG_ENTRY(DIRSYNC),
 	DEF_INODE_FLAG_ENTRY(COMPRESS),
+	DEF_INODE_FLAG_ENTRY(ENCRYPT),
 	DEF_INODE_FLAG_ENTRY(ROOT_ITEM_INIT),
 };
 static const int inode_flags_num = ARRAY_SIZE(inode_flags_array);
-- 
2.53.0

