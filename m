Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED031423A9B
	for <linux-fscrypt@vger.kernel.org>; Tue,  7 Jul 2026 14:27:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783434471; cv=none; b=omQV4YY9QrUAUZOJtfFnOOmxdOmNQBhbN24zCbx3JKI1lBSZjWSoHQMnMy+w0WIMnQsePZCxV9TpY3Q3mebB5AQhUCPNzi/cRtA/Y/jux0k7pSTrcwlmn8VnWLbocPcWdvBMToltMA8rXHJANcZXOxzyiwotTgQJZLk0SCXN9Bk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783434471; c=relaxed/simple;
	bh=4J43lt/ZEf+amV9Zes0Ik7d+/RCnYlz85y/q7/OrNIM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=GiWRh5/FYIAkyG1T4fGPRsEoNtQahuyiPZGus+lUs7b8YoArP6xv4f1L552fnImeR9DqICwaxKRtAhQh+xQV9NM5a89vTtzbXAZjXcArac3F2e+0pmyF/hJLkBgMoPwNYtY16lOaUuM7JcH7L1IylsKL6zJLoYlRsbAPoPLAIkU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=SDyWW382; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=oO1Ogbhp; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="SDyWW382";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="oO1Ogbhp"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id DDFD675D1F;
	Tue,  7 Jul 2026 14:27:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1783434467; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=br2s29azNC5KHqXfUia+BODXiFoqE9p2+mdfIBVP0qw=;
	b=SDyWW382U5EliDIZevKby8yaJGtiyJYaJCPqhC7aT/JCSl1Mfz6m2xPhZhKX3DXaDWZpTk
	Fv+MYHROiBGnEDyurDzdBPDrW8NzNJmkSxidqf5eLcWtbm5yXqXY/e/Jg23D/9FsGKEazF
	BEYkDguuyDqB8yphtRbgVqMgr6Tf7xA=
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1783434466; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=br2s29azNC5KHqXfUia+BODXiFoqE9p2+mdfIBVP0qw=;
	b=oO1Ogbhp9N23lhM20+O0QksQ1FfinQSxLDIMUv0EtN7iDxh3ALhUJLFOYN8lTUx0g8GAJ6
	UYLATFHtoqjAopHU/6Ul86YDAEN+atjIb2TbgHXQ/T9SdXyRJKMO1a+9z7IDc20QF6tX7r
	RDv+pSAuzQur6RkGTkB7WQ5S2fK8WOo=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id C6295779AF;
	Tue,  7 Jul 2026 14:27:46 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id oBvYL+IMTWoLaQAAD6G6ig
	(envelope-from <neelx@suse.com>); Tue, 07 Jul 2026 14:27:46 +0000
From: Daniel Vacek <neelx@suse.com>
To: David Sterba <dsterba@suse.com>
Cc: Daniel Vacek <neelx@suse.com>,
	linux-fscrypt@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: [PATCH v3 1/7] btrfs-progs: add new FEATURE_INCOMPAT_ENCRYPT flag
Date: Tue,  7 Jul 2026 16:27:30 +0200
Message-ID: <20260707142736.2330146-2-neelx@suse.com>
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

