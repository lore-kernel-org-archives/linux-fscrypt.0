Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 772C6428476
	for <linux-fscrypt@vger.kernel.org>; Fri,  6 Feb 2026 18:24:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770402288; cv=none; b=p4Y6oVsZ1D8azdVCDnuQ7ZZGAwjh1J35DEMPvIcri9RgQZXqcDuGS4FNEBy+JwECU+z2IWcvrJ/DzVcVByRxLfq7H+5KDCchZ1NQ+dLgePWaeZSIiiVYiBKKBfW33taSLDpfTnj7KgZkvoZCAM5o+K8vqPJpIamc/HClPcsHSek=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770402288; c=relaxed/simple;
	bh=YnH1HnTod1Q2da9rrj4LriQGSR/+/7gxFU8409P7IKk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=T21v91hq+TGI7tPMOE1FcsZ6F3tMLEEG/BucdxIh2Dd51cOyMzCjxcFJKm5+WzgvquiaMEDzO4xqbZy+1rV9seQ/86s0S/pHRCkh0pCrbtQ9pudj0xxyCQj1zA9H96nYdBP9Z7tgOjcVI/p+CkTWMiTQOmExB5HVpeamHZswyFw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=A+0mPrRF; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=A+0mPrRF; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="A+0mPrRF";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="A+0mPrRF"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id BAFBC3E6E5;
	Fri,  6 Feb 2026 18:24:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1770402248; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=btJMz5miTBcJgRZuwePXkRB+sZ9KG4pk++LUH6QvOIM=;
	b=A+0mPrRF8G7YLXshbBXOAI2DFOgSUL61mCdoUorpfv9vzJKhzXJruReI0JNLlkoHQrCoO1
	tedtN9VrwEvkQAsSpzSgp325h5F93x9iuFxWFAyHZuyzq2X8ygSLqR90fBNLPk2bE2F3Xa
	NGqqJoA7JfgGapTD701mhEGwLmRmMmg=
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1770402248; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=btJMz5miTBcJgRZuwePXkRB+sZ9KG4pk++LUH6QvOIM=;
	b=A+0mPrRF8G7YLXshbBXOAI2DFOgSUL61mCdoUorpfv9vzJKhzXJruReI0JNLlkoHQrCoO1
	tedtN9VrwEvkQAsSpzSgp325h5F93x9iuFxWFAyHZuyzq2X8ygSLqR90fBNLPk2bE2F3Xa
	NGqqJoA7JfgGapTD701mhEGwLmRmMmg=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 8EE023EA63;
	Fri,  6 Feb 2026 18:24:08 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id QKItIsgxhmkTCQAAD6G6ig
	(envelope-from <neelx@suse.com>); Fri, 06 Feb 2026 18:24:08 +0000
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
Subject: [PATCH v6 23/43] btrfs: keep track of fscrypt info and orig_start for dio reads
Date: Fri,  6 Feb 2026 19:22:55 +0100
Message-ID: <20260206182336.1397715-24-neelx@suse.com>
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
X-Spam-Score: -6.80
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
X-Spam-Level: 
X-Spam-Flag: NO

From: Josef Bacik <josef@toxicpanda.com>

We keep track of this information in the ordered extent for writes, but
we need it for reads as well.  Add fscrypt_extent_info and orig_start to
the dio_data so we can populate this on reads.  This will be used later
when we attach the fscrypt context to the bios.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---

v5: https://lore.kernel.org/linux-btrfs/acf3d79bcd72a4447b2993e78d9742fa5a05397f.1706116485.git.josef@toxicpanda.com/
 * Open-code orig_start to start - offset.
---
 fs/btrfs/direct-io.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/btrfs/direct-io.c b/fs/btrfs/direct-io.c
index c95b4e768043..d3789109ca85 100644
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
2.51.0

