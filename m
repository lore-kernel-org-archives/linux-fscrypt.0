Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B00EE3F39FF
	for <linux-fscrypt@vger.kernel.org>; Tue,  7 Jul 2026 14:28:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783434488; cv=none; b=E5WpESx4zydlweq9cC7q1aPg5/qYCu+lftI/LjHr6f0zEGD0rSfWBmU7caHT27hn8omRiofbhTYFtFhBfMagu1CNf+X3KFg+fNjGtvou1eJQ7yn73Ws8uOMLRbRQlFKqqN0wx5b8cpkE5yfKwal3WhAK7cbVZl9qkLUiifOTpGM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783434488; c=relaxed/simple;
	bh=QeX1Nty1fuoHKPewLtJEsJq1xrCpoyDjcGTWtWji4Yc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=L5AYdls6efjI+ftmgx6g38Vhafb820Eob8cHuFuVThL1JukQULLoPEqWTtqZh6hOacMuarj9vsQaboYoxr9RIqnb0yZFTFoUqTS1/EovmyCbgd50fCuB3bt2ssVD4r6cYdVTHfNjuo5sEqjN6cL3tB1s18EX8UutO0XDbWbGp4E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=jqwLX1Gz; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=jqwLX1Gz; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="jqwLX1Gz";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="jqwLX1Gz"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 222B375C21;
	Tue,  7 Jul 2026 14:27:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1783434467; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=QAiNo3VZy/hHfTJilfh0f1ieanH0gKSakZ/GTn7Owtw=;
	b=jqwLX1GzTUe8cpBpveMcznXpReBW+KXH+Y6ZC0abE1xRkM7ibQEeST8PKCXBtdl5EOZaxY
	W/jk3UiI6coHeT6cyWsXOZKFESLmlNGdUXsavReiZ0wsSqNtpBhbFsUpdbQl9mixaXOGOp
	BTpN4T7lsn3PFKwUFQZgTIPpu2J0yGs=
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1783434467; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=QAiNo3VZy/hHfTJilfh0f1ieanH0gKSakZ/GTn7Owtw=;
	b=jqwLX1GzTUe8cpBpveMcznXpReBW+KXH+Y6ZC0abE1xRkM7ibQEeST8PKCXBtdl5EOZaxY
	W/jk3UiI6coHeT6cyWsXOZKFESLmlNGdUXsavReiZ0wsSqNtpBhbFsUpdbQl9mixaXOGOp
	BTpN4T7lsn3PFKwUFQZgTIPpu2J0yGs=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 05B1F779B0;
	Tue,  7 Jul 2026 14:27:47 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id cEjdAOMMTWoLaQAAD6G6ig
	(envelope-from <neelx@suse.com>); Tue, 07 Jul 2026 14:27:47 +0000
From: Daniel Vacek <neelx@suse.com>
To: David Sterba <dsterba@suse.com>
Cc: Daniel Vacek <neelx@suse.com>,
	linux-fscrypt@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: [PATCH v3 3/7] btrfs-progs: add inode encryption contexts
Date: Tue,  7 Jul 2026 16:27:32 +0200
Message-ID: <20260707142736.2330146-4-neelx@suse.com>
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
X-Spam-Flag: NO
X-Spam-Score: -6.80
X-Spamd-Result: default: False [-6.80 / 50.00];
	REPLY(-4.00)[];
	BAYES_HAM(-3.00)[100.00%];
	MID_CONTAINS_FROM(1.00)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_MISSING_CHARSET(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-0.997];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_HAS_DN(0.00)[];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	DKIM_SIGNED(0.00)[suse.com:s=susede1];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	RCPT_COUNT_FIVE(0.00)[6];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.com:mid,imap1.dmz-prg2.suse.org:helo];
	RCVD_TLS_ALL(0.00)[]
X-Spam-Level: 

From: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>

Recapitulates relevant parts of kernel change 'btrfs: add inode
encryption contexts'.

Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---
 kernel-shared/uapi/btrfs_tree.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel-shared/uapi/btrfs_tree.h b/kernel-shared/uapi/btrfs_tree.h
index 74d307f1..b4532237 100644
--- a/kernel-shared/uapi/btrfs_tree.h
+++ b/kernel-shared/uapi/btrfs_tree.h
@@ -168,6 +168,9 @@
 #define BTRFS_VERITY_DESC_ITEM_KEY	36
 #define BTRFS_VERITY_MERKLE_ITEM_KEY	37
 
+#define BTRFS_FSCRYPT_INODE_CTX_KEY	41
+#define BTRFS_FSCRYPT_CTX_KEY		42
+
 #define BTRFS_ORPHAN_ITEM_KEY		48
 /* reserve 2-15 close to the inode for later flexibility */
 
@@ -428,6 +431,7 @@ static inline __u8 btrfs_dir_flags_to_ftype(__u8 flags)
 #define BTRFS_INODE_NOATIME		(1U << 9)
 #define BTRFS_INODE_DIRSYNC		(1U << 10)
 #define BTRFS_INODE_COMPRESS		(1U << 11)
+#define BTRFS_INODE_ENCRYPT		(1U << 12)
 
 #define BTRFS_INODE_ROOT_ITEM_INIT	(1U << 31)
 
@@ -444,6 +448,7 @@ static inline __u8 btrfs_dir_flags_to_ftype(__u8 flags)
 	 BTRFS_INODE_NOATIME |						\
 	 BTRFS_INODE_DIRSYNC |						\
 	 BTRFS_INODE_COMPRESS |						\
+	 BTRFS_INODE_ENCRYPT |						\
 	 BTRFS_INODE_ROOT_ITEM_INIT)
 
 #define BTRFS_INODE_RO_VERITY		(1U << 0)
-- 
2.53.0

