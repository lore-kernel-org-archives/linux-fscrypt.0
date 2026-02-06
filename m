Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68B1044B667
	for <linux-fscrypt@vger.kernel.org>; Fri,  6 Feb 2026 18:25:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770402321; cv=none; b=nib4p0rqBilNG7AHuVDnH94dEXAkFUgWwcS4AwR2mnZd9m1aOO22o5Mwk0lEuwNeSWZa/cjgWpri20MQ702BIZx6CVDL9YKKQTeU7at2/f/kaICGo8rUb17zqy6Cv3CmMzNyXeatIloHho6KALuWawNmJyIrHBLMTKld1AzBNNA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770402321; c=relaxed/simple;
	bh=wBNEVAk30UYG4m43mdnD0/y+iUy42IO/9sgi8dADWHU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DyrjPNpL/5KSpGCaeJBdsyBvQ3Km1h3G4gQXQBnBd5MPuBhweRRNhTvnTUt6IHFwl8o7iqW0SV/GnPZkMS+lurUVX1K9jAiC9BfCmV1Gq9xxS4cegIQAfgeaUWpDVnnhn+EJDflL+hX6fOhcPufy8MrHyiNQYEvArXaZfvdeEg0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=QvI3NU/7; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=QvI3NU/7; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="QvI3NU/7";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="QvI3NU/7"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id D182C5BD30;
	Fri,  6 Feb 2026 18:24:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1770402259; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=naQJMp1+YtAXW7i9Wmu4TNf5csVeJ0Q0sjWmskdGN3Q=;
	b=QvI3NU/7hIF95rabCHRgR+X9m6CVlVvOttcPtm3aEGXNdbg2Wm2NTtNfy38JSZpmytrMLv
	tVP1G8tV4DHSmyYF0Kg1A2AaJCHIZHcbHLKVzXI+4Gh0F4BLwEyNsNIwA0O0LJMg0SMTF0
	FRHZpFDDbOIFaMymXdQKRiSc9pqtPs8=
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1770402259; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=naQJMp1+YtAXW7i9Wmu4TNf5csVeJ0Q0sjWmskdGN3Q=;
	b=QvI3NU/7hIF95rabCHRgR+X9m6CVlVvOttcPtm3aEGXNdbg2Wm2NTtNfy38JSZpmytrMLv
	tVP1G8tV4DHSmyYF0Kg1A2AaJCHIZHcbHLKVzXI+4Gh0F4BLwEyNsNIwA0O0LJMg0SMTF0
	FRHZpFDDbOIFaMymXdQKRiSc9pqtPs8=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id A6BE23EA63;
	Fri,  6 Feb 2026 18:24:19 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id QKcdKNMxhmkTCQAAD6G6ig
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
Subject: [PATCH v6 41/43] btrfs: disable auto defrag on encrypted files
Date: Fri,  6 Feb 2026 19:23:13 +0100
Message-ID: <20260206182336.1397715-42-neelx@suse.com>
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
X-Spamd-Result: default: False [-6.80 / 50.00];
	REPLY(-4.00)[];
	BAYES_HAM(-3.00)[100.00%];
	MID_CONTAINS_FROM(1.00)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_MISSING_CHARSET(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:mid,suse.com:email,toxicpanda.com:email];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[12];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	R_RATELIMIT(0.00)[to_ip_from(RLdafymbgddseoxkryad1wgu8n)];
	DKIM_SIGNED(0.00)[suse.com:s=susede1];
	RCVD_TLS_ALL(0.00)[]
X-Spam-Flag: NO
X-Spam-Score: -6.80
X-Spam-Level: 

From: Josef Bacik <josef@toxicpanda.com>

We will drop the inode and re-look it up to do defrag with auto defrag,
which means we could lose the encryption policy.

Auto defrag needs to be reworked to just hold onto the inode for
scheduling later so we don't lose the context.  For now just disable it
if the file is encrypted.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---

v5: https://lore.kernel.org/linux-btrfs/b717912bf88797b3044a3c2724b59b1ecc17ea78.1706116485.git.josef@toxicpanda.com/
 * No changes since.
---
 fs/btrfs/defrag.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/btrfs/defrag.c b/fs/btrfs/defrag.c
index f64c0502cef9..cd6ea6e5d3ea 100644
--- a/fs/btrfs/defrag.c
+++ b/fs/btrfs/defrag.c
@@ -126,6 +126,14 @@ void btrfs_add_inode_defrag(struct btrfs_inode *inode, u32 extent_thresh)
 	if (!need_auto_defrag(fs_info))
 		return;
 
+	/*
+	 * Since we have to read the inode at defrag time disable auto defrag
+	 * for encrypted inodes until we have code to read the parent and load
+	 * the encryption context.
+	 */
+	if (IS_ENCRYPTED(&inode->vfs_inode))
+		return;
+
 	if (test_bit(BTRFS_INODE_IN_DEFRAG, &inode->runtime_flags))
 		return;
 
-- 
2.51.0

