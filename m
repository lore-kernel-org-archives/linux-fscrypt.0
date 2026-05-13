Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74EE33FFADD
	for <linux-fscrypt@vger.kernel.org>; Wed, 13 May 2026 08:55:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778662542; cv=none; b=j17fngBVxrlb5CsRDFiAUgv0JO+pmYJsbD5uoaAQS75B3P9sPquuMrJVCABx3DFiX0GNO5bsGgrxTGQvWalWFgE3fq3HvklePkTGwQ7dBdHR6Z2daRGjaddPwueEJqSomdBGisckavA3OjwjtTKmxpuxhUY+Nr8RHhI+WvUIEds=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778662542; c=relaxed/simple;
	bh=KtfNLE89GgWs5ZVCFdvTnmLjuOFG/9LKygObCx4BoO8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ORd0jPaGjJujLal2lyxegYcUJMYNtZwc+nnDV3pXxZkY+E7ykZckNDJC5E1I4xPqmU6t0K1q43GkSJCpZGqBhuKcsXTZdpoC3TuWDckvTrpIpK4siv+9XXkrpyDPiRptNe8kN73f5uezS3/jgdJ2B/9z7VzkBSQp70JbsDZqCA8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=J1FDz/+J; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=J1FDz/+J; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="J1FDz/+J";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="J1FDz/+J"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id E69C976658;
	Wed, 13 May 2026 08:54:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1778662473; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=YV6DevLRcQAD0vuaX0Jatv3mKe8GTnnRj8+hMj9Dz4k=;
	b=J1FDz/+JWGwREpBfunrJi9hdtqYQ+vy7vORaTcz4HbuhjQjDGdLNRyMpDc7XdONUkx9frQ
	eAy4BKi1xjpoEKsFTAT+OfH5pRAiYGM6xx8FBxynTXA89rqTggBAkruqjlKL8aJx4Alm3M
	TLbSRIlTELD6mOkhgQc2QrgAHnCflo0=
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1778662473; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=YV6DevLRcQAD0vuaX0Jatv3mKe8GTnnRj8+hMj9Dz4k=;
	b=J1FDz/+JWGwREpBfunrJi9hdtqYQ+vy7vORaTcz4HbuhjQjDGdLNRyMpDc7XdONUkx9frQ
	eAy4BKi1xjpoEKsFTAT+OfH5pRAiYGM6xx8FBxynTXA89rqTggBAkruqjlKL8aJx4Alm3M
	TLbSRIlTELD6mOkhgQc2QrgAHnCflo0=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id C317B593A9;
	Wed, 13 May 2026 08:54:33 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 8F8IL0k8BGpERwAAD6G6ig
	(envelope-from <neelx@suse.com>); Wed, 13 May 2026 08:54:33 +0000
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
Subject: [PATCH v7 23/43] btrfs: keep track of fscrypt info and orig_start for dio reads
Date: Wed, 13 May 2026 10:52:57 +0200
Message-ID: <20260513085340.3673127-24-neelx@suse.com>
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
X-Spam-Flag: NO
X-Spam-Score: -6.80
X-Spamd-Result: default: False [-6.80 / 50.00];
	REPLY(-4.00)[];
	BAYES_HAM(-3.00)[100.00%];
	MID_CONTAINS_FROM(1.00)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_MISSING_CHARSET(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.com:mid];
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
X-Spam-Level: 

From: Josef Bacik <josef@toxicpanda.com>

We keep track of this information in the ordered extent for writes, but
we need it for reads as well.  Add fscrypt_extent_info and orig_start to
the dio_data so we can populate this on reads.  This will be used later
when we attach the fscrypt context to the bios.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---

No changes in v7.
v6 changes:
 * Open-code orig_start to start - offset.
v5: https://lore.kernel.org/linux-btrfs/acf3d79bcd72a4447b2993e78d9742fa5a05397f.1706116485.git.josef@toxicpanda.com/
---
 fs/btrfs/direct-io.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/btrfs/direct-io.c b/fs/btrfs/direct-io.c
index e46bca590f35..f87656db6157 100644
--- a/fs/btrfs/direct-io.c
+++ b/fs/btrfs/direct-io.c
@@ -17,6 +17,8 @@ struct btrfs_dio_data {
 	ssize_t submitted;
 	struct extent_changeset *data_reserved;
 	struct btrfs_ordered_extent *ordered;
+	struct fscrypt_extent_info *fscrypt_info;
+	u64 orig_start;
 	bool data_space_reserved;
 	bool nocow_done;
 };
@@ -550,6 +552,9 @@ static int btrfs_dio_iomap_begin(struct inode *inode, loff_t start,
 							       release_offset,
 							       release_len);
 		}
+	} else {
+		dio_data->fscrypt_info = fscrypt_get_extent_info(em->fscrypt_info);
+		dio_data->orig_start = em->start - em->offset;
 	}
 
 	/*
@@ -640,6 +645,11 @@ static int btrfs_dio_iomap_end(struct inode *inode, loff_t pos, loff_t length,
 		dio_data->ordered = NULL;
 	}
 
+	if (dio_data->fscrypt_info) {
+		fscrypt_put_extent_info(dio_data->fscrypt_info);
+		dio_data->fscrypt_info = NULL;
+	}
+
 	if (write)
 		extent_changeset_free(dio_data->data_reserved);
 	return ret;
-- 
2.53.0

