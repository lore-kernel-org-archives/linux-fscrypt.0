Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACA4D3F9F20
	for <linux-fscrypt@vger.kernel.org>; Wed, 13 May 2026 08:55:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778662525; cv=none; b=gmQV4m2CwxB/AkQJ3uUmraY2EvcHF1RBh+CE5n45XImiUtQ1LFUPR4xRqmzffU+A+mKRg4TBBUczn7DG1vxzAktJG9z85r+YE4ESsB3kkh/nFASjQYCZZ0tNpTvENowgyyhdFUCozkVok7liYLCR0jtlH4sLRRDOL+pV+eAKCJo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778662525; c=relaxed/simple;
	bh=E2zsscr+gIRqaz6Z/xBCtNiDsxch4QYQPOHcJ3IkMJE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FXC3pU/Mlx2gGq6ieR9oGzGfA6X7LAr+8C5qp+xymlysStAw2QvXvFzwXznGL4SQZJfyYCRD4NeF6aRiJdbBHSjBKint1qTuLFPTxIjHuzgfRfww9kPUAZ2gG+Q5JB/8cT2t/XPkCkihwax5gT6/+FwnU6L8lC2t4jZxHmH5+WI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id DE71476655;
	Wed, 13 May 2026 08:54:28 +0000 (UTC)
Authentication-Results: smtp-out2.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id B873B593A9;
	Wed, 13 May 2026 08:54:28 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id CAmQLEQ8BGpERwAAD6G6ig
	(envelope-from <neelx@suse.com>); Wed, 13 May 2026 08:54:28 +0000
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
Subject: [PATCH v7 16/43] btrfs: select encryption dependencies if FS_ENCRYPTION
Date: Wed, 13 May 2026 10:52:50 +0200
Message-ID: <20260513085340.3673127-17-neelx@suse.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260513085340.3673127-1-neelx@suse.com>
References: <20260513085340.3673127-1-neelx@suse.com>
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
X-Rspamd-Queue-Id: DE71476655
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Spam-Score: -4.00
X-Spam-Level: 
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Flag: NO
X-Rspamd-Action: no action

From: Josef Bacik <josef@toxicpanda.com>

We need this to make sure the appropriate encryption algorithms are
turned on in our config if we have FS_ENCRYPTION enabled, and
additionally we only support inline encryption with the fallback block
crypto, so we need to make sure we pull in those dependencies.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---

v7 changes:
 * Alsos depend on BLK_INLINE_ENCRYPTION as suggested by Chris' AI review.
No changes in v6.
v5: https://lore.kernel.org/linux-btrfs/396f5067b2551a9f2de4b439509e1a285985d358.1706116485.git.josef@toxicpanda.com/
---
 fs/btrfs/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/btrfs/Kconfig b/fs/btrfs/Kconfig
index 5e75438e0b73..3a41392135da 100644
--- a/fs/btrfs/Kconfig
+++ b/fs/btrfs/Kconfig
@@ -16,6 +16,10 @@ config BTRFS_FS
 	select RAID6_PQ
 	select XOR_BLOCKS
 	select XXHASH
+	select FS_ENCRYPTION_ALGS if FS_ENCRYPTION
+	select FS_ENCRYPTION_INLINE_CRYPT if FS_ENCRYPTION
+	select BLK_INLINE_ENCRYPTION if FS_ENCRYPTION
+	select BLK_INLINE_ENCRYPTION_FALLBACK if FS_ENCRYPTION
 	depends on PAGE_SIZE_LESS_THAN_256KB
 
 	help
-- 
2.53.0

