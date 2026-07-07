Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 662DF42A7B9
	for <linux-fscrypt@vger.kernel.org>; Tue,  7 Jul 2026 14:28:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783434497; cv=none; b=IIFrbB/v0PlYyHDwhw+zYjO0e7qT+JfX6jKE/CHxaueQEVQdg/TcS/PiUXBgLbemzXZJIYNTljJR44Ej+kwd/zMUUuZmMQ6IxwBrvJo1Wdb2YI8HQP5QZwRPNdJtgUn+ES76AVW4Tzijys8XqT4Y71O9c7ptEEdq89GypRaihn4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783434497; c=relaxed/simple;
	bh=sWcjTH0F7qORYwLNc3sX2+C5Jqq8ev01ZTC8ettyqo0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AGexXJi2aIsw6EouQzL7NywD0bKCcCoDMRBiFy0IvG5sUr2JTP3Na4XOsKYwCLQU1QRP30r/rJf8niZTu9LG2enub9fCXX4wYMzWrURcvpAFAXcBwFOlbTVuT9G8hOZ15Vumg0+4N3uEk1UdHyp+axfP9BSWZWOLSuz5R5blsGI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=lhD8BqM4; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=lhD8BqM4; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="lhD8BqM4";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="lhD8BqM4"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 687DA75C22;
	Tue,  7 Jul 2026 14:27:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1783434467; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=C99Pc89+/54jWcpyW2UjHVxQ3eEBnNVesDfo+OcPcX4=;
	b=lhD8BqM4iVqUhMl4XGJTBYGp2EaHAAIpBR1AZy/BFrJLtBTXXufnTzJmTqv9B2SOie34Ur
	SYF9X1kU3XvZ3M1o/4b9q2E9BroG/YWfwRLiJCEOGuvBhS9n79vSQ41wVQR0v+OP2KCNxj
	xxSjnGp5qBIWgBBu8uD8YcdNr5KsG4A=
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1783434467; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=C99Pc89+/54jWcpyW2UjHVxQ3eEBnNVesDfo+OcPcX4=;
	b=lhD8BqM4iVqUhMl4XGJTBYGp2EaHAAIpBR1AZy/BFrJLtBTXXufnTzJmTqv9B2SOie34Ur
	SYF9X1kU3XvZ3M1o/4b9q2E9BroG/YWfwRLiJCEOGuvBhS9n79vSQ41wVQR0v+OP2KCNxj
	xxSjnGp5qBIWgBBu8uD8YcdNr5KsG4A=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 51185779AF;
	Tue,  7 Jul 2026 14:27:47 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 8Lg5E+MMTWoLaQAAD6G6ig
	(envelope-from <neelx@suse.com>); Tue, 07 Jul 2026 14:27:47 +0000
From: Daniel Vacek <neelx@suse.com>
To: David Sterba <dsterba@suse.com>
Cc: Daniel Vacek <neelx@suse.com>,
	linux-fscrypt@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: [PATCH v3 6/7] btrfs-progs: check: update inline extent length checking
Date: Tue,  7 Jul 2026 16:27:35 +0200
Message-ID: <20260707142736.2330146-7-neelx@suse.com>
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
X-Spamd-Result: default: False [-6.80 / 50.00];
	REPLY(-4.00)[];
	BAYES_HAM(-3.00)[100.00%];
	MID_CONTAINS_FROM(1.00)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_MISSING_CHARSET(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-0.998];
	MIME_GOOD(-0.10)[text/plain];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.com:mid];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	R_RATELIMIT(0.00)[to_ip_from(RLjpbzrka5mc1bf4fb9cmz1e4f)];
	TO_DN_SOME(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	RCPT_COUNT_FIVE(0.00)[6];
	DKIM_SIGNED(0.00)[suse.com:s=susede1];
	RCVD_TLS_ALL(0.00)[]
X-Spam-Level: 
X-Spam-Score: -6.80

From: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>

As part of the encryption changes, encrypted inline file extents record
their actual data length in ram_bytes, like compressed inline file
extents, while the item's length records the actual size. As such,
encrypted inline extents must be treated like compressed ones for
inode length consistency checking.

Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---
 check/main.c | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/check/main.c b/check/main.c
index 9447b01e..cadcfef0 100644
--- a/check/main.c
+++ b/check/main.c
@@ -1720,9 +1720,7 @@ static int process_file_extent(struct btrfs_root *root,
 	u64 disk_bytenr = 0;
 	u64 extent_offset = 0;
 	u64 mask = gfs_info->sectorsize - 1;
-	u32 max_inline_size = min_t(u32, mask,
-				BTRFS_MAX_INLINE_DATA_SIZE(gfs_info));
-	u8 compression;
+	u8 compression, encryption;
 	int extent_type;
 	int ret;
 
@@ -1747,25 +1745,30 @@ static int process_file_extent(struct btrfs_root *root,
 	fi = btrfs_item_ptr(eb, slot, struct btrfs_file_extent_item);
 	extent_type = btrfs_file_extent_type(eb, fi);
 	compression = btrfs_file_extent_compression(eb, fi);
+	encryption  = btrfs_file_extent_encryption(eb, fi);
 
 	if (extent_type == BTRFS_FILE_EXTENT_INLINE) {
-		num_bytes = btrfs_file_extent_ram_bytes(eb, fi);
-		if (num_bytes == 0)
+		u32 max_inline_size = min_t(u32, mask,
+					BTRFS_MAX_INLINE_DATA_SIZE(gfs_info));
+		u64 num_disk_bytes = btrfs_file_extent_inline_item_len(eb, slot);
+		u64 num_decoded_bytes = btrfs_file_extent_ram_bytes(eb, fi);
+		if (num_decoded_bytes == 0)
 			rec->errors |= I_ERR_BAD_FILE_EXTENT;
-		if (compression) {
-			if (btrfs_file_extent_inline_item_len(eb, slot) >
-			    max_inline_size ||
-			    num_bytes > gfs_info->sectorsize)
+		if (compression || encryption) {
+			if (encryption)
+				max_inline_size = min_t(u32, gfs_info->sectorsize,
+					BTRFS_MAX_INLINE_DATA_SIZE(gfs_info));
+			if (num_disk_bytes > max_inline_size ||
+			    num_decoded_bytes > gfs_info->sectorsize)
 				rec->errors |= I_ERR_FILE_EXTENT_TOO_LARGE;
 		} else {
-			if (num_bytes > max_inline_size)
+			if (num_decoded_bytes > max_inline_size)
 				rec->errors |= I_ERR_FILE_EXTENT_TOO_LARGE;
-			if (btrfs_file_extent_inline_item_len(eb, slot) !=
-			    num_bytes)
+			if (num_disk_bytes != num_decoded_bytes)
 				rec->errors |= I_ERR_INLINE_RAM_BYTES_WRONG;
 		}
-		rec->found_size += num_bytes;
-		num_bytes = (num_bytes + mask) & ~mask;
+		rec->found_size += num_decoded_bytes;
+		num_bytes = (num_decoded_bytes + mask) & ~mask;
 	} else if (extent_type == BTRFS_FILE_EXTENT_REG ||
 		   extent_type == BTRFS_FILE_EXTENT_PREALLOC) {
 		num_bytes = btrfs_file_extent_num_bytes(eb, fi);
-- 
2.53.0

