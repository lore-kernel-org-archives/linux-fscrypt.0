Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D05EB42A163
	for <linux-fscrypt@vger.kernel.org>; Tue,  7 Jul 2026 14:27:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783434480; cv=none; b=WtyCZsV9A66ioS7od/1ipgQB8VsitSRyAwYsXH0uEbDid6XqURdfBzcKVjll/MRfJRHDxixsu+t0HKAhLNiTFaeqinZP1O/bgrGA/g4G6VGaduvb6oyb19xNHcPDW940VP/7x2fCGYqVt/gxcsFQ6TiFxQoVEilCU8NTA3Im2t0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783434480; c=relaxed/simple;
	bh=/SPdENCM8RBJQwYHIyTDuyJJVoa2AGAZfGzAKrbYXMY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=stW+5JtrVwr1/5y2Pj6NgoBBiEuGuyLrh2uBr4kgejvpzfOjsc4/3oWVfHP9ZyZHBUCia3K46as+gQWAOYO2s0KUzft/5mVeaohAE9uXrSuFLpX1An4T2/rp4UVNKFrsCY7VDXqlEomV2Hnm/rLWwKvGAz3l6STKlbdxwdZOmqE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=g+CS243f; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=g+CS243f; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="g+CS243f";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="g+CS243f"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 37E6F75D22;
	Tue,  7 Jul 2026 14:27:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1783434467; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=kymj+BTqfjpAWE7WH3Kg3Vndt4dAXmZuH404tDn0T1I=;
	b=g+CS243f2Fkl4sq/9MGn+k1n97hTuzltvUr0B14DKZ5Ws86VPLek9rNdjVsruR7oVS9kIL
	PzxOmg4sGWLYl0BQB17aKobwBSaRIcsdTMZ6luDzuXtsX0Hw4l5fXlZ9RM85u9SUrgZQ95
	IuiAjMweJ4HDbpfeZd4N/kobU0PrPDM=
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1783434467; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=kymj+BTqfjpAWE7WH3Kg3Vndt4dAXmZuH404tDn0T1I=;
	b=g+CS243f2Fkl4sq/9MGn+k1n97hTuzltvUr0B14DKZ5Ws86VPLek9rNdjVsruR7oVS9kIL
	PzxOmg4sGWLYl0BQB17aKobwBSaRIcsdTMZ6luDzuXtsX0Hw4l5fXlZ9RM85u9SUrgZQ95
	IuiAjMweJ4HDbpfeZd4N/kobU0PrPDM=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 1EF5E779B1;
	Tue,  7 Jul 2026 14:27:47 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id +GMLB+MMTWoLaQAAD6G6ig
	(envelope-from <neelx@suse.com>); Tue, 07 Jul 2026 14:27:47 +0000
From: Daniel Vacek <neelx@suse.com>
To: David Sterba <dsterba@suse.com>
Cc: Daniel Vacek <neelx@suse.com>,
	linux-fscrypt@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: [PATCH v3 4/7] btrfs-progs: print encryptin type field of file extents
Date: Tue,  7 Jul 2026 16:27:33 +0200
Message-ID: <20260707142736.2330146-5-neelx@suse.com>
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
	NEURAL_HAM_SHORT(-0.20)[-0.998];
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

Encrypted file extents now have the 'encryption' field set to an
encryption type.  Let's print it.

Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---
 check/main.c               | 1 -
 kernel-shared/print-tree.c | 7 +++++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/check/main.c b/check/main.c
index 5e29e2c5..7f438302 100644
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
index 0afa3696..2c0168b0 100644
--- a/kernel-shared/print-tree.c
+++ b/kernel-shared/print-tree.c
@@ -445,11 +445,12 @@ static void print_file_extent_item(struct extent_buffer *eb,
 			extent_type, file_extent_type_to_str(extent_type));
 
 	if (extent_type == BTRFS_FILE_EXTENT_INLINE) {
-		printf("\t\tinline extent data size %u ram_bytes %llu compression %hhu (%s)\n",
+		printf("\t\tinline extent data size %u ram_bytes %llu compression %hhu (%s) encryption %hhu\n",
 				btrfs_file_extent_inline_item_len(eb, slot),
 				btrfs_file_extent_ram_bytes(eb, fi),
 				btrfs_file_extent_compression(eb, fi),
-				compress_str);
+				compress_str,
+				btrfs_file_extent_encryption(eb, fi));
 		return;
 	}
 	if (extent_type == BTRFS_FILE_EXTENT_PREALLOC) {
@@ -471,6 +472,8 @@ static void print_file_extent_item(struct extent_buffer *eb,
 	printf("\t\textent compression %hhu (%s)\n",
 			btrfs_file_extent_compression(eb, fi),
 			compress_str);
+	printf("\t\textent encryption %hhu\n",
+			btrfs_file_extent_encryption(eb, fi));
 }
 
 /* Caller should ensure sizeof(*ret) >= 16("DATA|TREE_BLOCK") */
-- 
2.53.0

