Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81384353EC0
	for <linux-fscrypt@vger.kernel.org>; Wed, 24 Jun 2026 16:51:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782319918; cv=none; b=o9Md+H96GRsQMknvPJ2ZIY0z5cflw7OaY3Uq8ZTmRmuoG22sLX7PbZwA8rsf4GiZjBO6UmxyP5hy4j72bRUPQy54NAMmmUtaqnClkNB3neOewdvbQDzArthRoRv7/Ubktb0ulJNKUhQisAHquGiAtlGcq0UwTtQGjD/hayDKLQw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782319918; c=relaxed/simple;
	bh=4J43lt/ZEf+amV9Zes0Ik7d+/RCnYlz85y/q7/OrNIM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=oZC4jm16NGuSO0x/FVBEDaz5jDL58wozg39N+VQinjKdPQfXQbbM9fuOE+PHQMwpjSIZ8xB3y0OlCA6B/6IgEinKV6J1sWYw+TSGKb0SSkmbpWg1/flk6jbvR/JJy7tRi85Bb8nK9dOZT0LZNtNWfvT2X9Bo31fHcdW4LrdZu+o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id EC89B75A82;
	Wed, 24 Jun 2026 16:51:50 +0000 (UTC)
Authentication-Results: smtp-out2.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id D5DB8779A8;
	Wed, 24 Jun 2026 16:51:50 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id KNa5MyYLPGrUTgAAD6G6ig
	(envelope-from <neelx@suse.com>); Wed, 24 Jun 2026 16:51:50 +0000
From: Daniel Vacek <neelx@suse.com>
To: David Sterba <dsterba@suse.com>
Cc: Daniel Vacek <neelx@suse.com>,
	linux-fscrypt@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: [PATCH v2 2/8] btrfs-progs: add new FEATURE_INCOMPAT_ENCRYPT flag
Date: Wed, 24 Jun 2026 18:51:38 +0200
Message-ID: <20260624165144.556908-3-neelx@suse.com>
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
X-Rspamd-Queue-Id: EC89B75A82
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

From: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>

Matches kernel change by the same name.

Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---
 kernel-shared/ctree.h      | 1 +
 kernel-shared/uapi/btrfs.h | 1 +
 libbtrfsutil/btrfs.h       | 1 +
 3 files changed, 3 insertions(+)

diff --git a/kernel-shared/ctree.h b/kernel-shared/ctree.h
index cb5a5f3f..177163f8 100644
--- a/kernel-shared/ctree.h
+++ b/kernel-shared/ctree.h
@@ -99,6 +99,7 @@ static inline u32 __BTRFS_LEAF_DATA_SIZE(u32 nodesize)
 	 BTRFS_FEATURE_INCOMPAT_ZONED |			\
 	 BTRFS_FEATURE_INCOMPAT_EXTENT_TREE_V2 |	\
 	 BTRFS_FEATURE_INCOMPAT_RAID_STRIPE_TREE |	\
+	 BTRFS_FEATURE_INCOMPAT_ENCRYPT |		\
 	 BTRFS_FEATURE_INCOMPAT_SIMPLE_QUOTA |		\
 	 BTRFS_FEATURE_INCOMPAT_REMAP_TREE)
 #else
diff --git a/kernel-shared/uapi/btrfs.h b/kernel-shared/uapi/btrfs.h
index a765fbc4..7144f3ba 100644
--- a/kernel-shared/uapi/btrfs.h
+++ b/kernel-shared/uapi/btrfs.h
@@ -359,6 +359,7 @@ _static_assert(sizeof(struct btrfs_ioctl_fs_info_args) == 1024);
 #define BTRFS_FEATURE_INCOMPAT_ZONED		(1ULL << 12)
 #define BTRFS_FEATURE_INCOMPAT_EXTENT_TREE_V2	(1ULL << 13)
 #define BTRFS_FEATURE_INCOMPAT_RAID_STRIPE_TREE (1ULL << 14)
+#define BTRFS_FEATURE_INCOMPAT_ENCRYPT		(1ULL << 15)
 #define BTRFS_FEATURE_INCOMPAT_SIMPLE_QUOTA	(1ULL << 16)
 #define BTRFS_FEATURE_INCOMPAT_REMAP_TREE	(1ULL << 17)
 
diff --git a/libbtrfsutil/btrfs.h b/libbtrfsutil/btrfs.h
index 47d9ebf8..eac42473 100644
--- a/libbtrfsutil/btrfs.h
+++ b/libbtrfsutil/btrfs.h
@@ -328,6 +328,7 @@ struct btrfs_ioctl_fs_info_args {
 #define BTRFS_FEATURE_INCOMPAT_ZONED		(1ULL << 12)
 #define BTRFS_FEATURE_INCOMPAT_EXTENT_TREE_V2	(1ULL << 13)
 #define BTRFS_FEATURE_INCOMPAT_RAID_STRIPE_TREE (1ULL << 14)
+#define BTRFS_FEATURE_INCOMPAT_ENCRYPT		(1ULL << 15)
 #define BTRFS_FEATURE_INCOMPAT_SIMPLE_QUOTA	(1ULL << 16)
 
 struct btrfs_ioctl_feature_flags {
-- 
2.53.0

