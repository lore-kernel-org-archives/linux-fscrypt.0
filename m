Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 071D03FB070
	for <linux-fscrypt@vger.kernel.org>; Wed, 13 May 2026 08:57:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778662629; cv=none; b=HL0jMxmQBXKa/6vn+Jsu9a2Qa4OKE4Dqy7FhV1dhh4NbosnBugvA0SmX8HNpoTM65UOTopfXMtJC/QTVWnJ6lJoDWiEhqEdqlFZ475s0m2J1J5bjRRhm19ISjj9qcgu/3jGs1ewhYAlDSwxp43HviDGEcE1mJ6AVCtK3hPlj7v8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778662629; c=relaxed/simple;
	bh=sBQNINEn0dePgJlQkcKwHXUVqv4Mztjd8l1nzN++Ivk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AG72eAk/if/Qehtb8pr/wgbjmQMDHCqdzwbpf7WmkfmVXkI/Kyynk+5a3/6k1gCpA55ALkWWaKMlFFCAKNfj/7s0ul0kFANfjxaXA9hSgDHizpDARxVf3L5zbzbrHn3Lv2H0YegRn6T8M155jb6b1Vx0u6MxP8z7CnICZXMHCSU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=eSmdDZzo; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=eSmdDZzo; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="eSmdDZzo";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="eSmdDZzo"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id B17DB76669;
	Wed, 13 May 2026 08:54:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1778662488; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=rGsf9qjux2z5F14kk7z4wGBg81BVuwKlZhA9MqGmYGg=;
	b=eSmdDZzozg9gny8NOghATOcls5SfdYR7nS+hY78M1k6h4DAyBXY58GRyEtOqZYN2iqDlg1
	krO/bIyzhgP7R+X9FuOibwCeohsqh/EKGwFX0MT/SVtPXSpwnhijkmaPWSI1J6Xkwdj1IO
	W2aWaiS9zhEGfrTnXUhe8hHO5EeYC/0=
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1778662488; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=rGsf9qjux2z5F14kk7z4wGBg81BVuwKlZhA9MqGmYGg=;
	b=eSmdDZzozg9gny8NOghATOcls5SfdYR7nS+hY78M1k6h4DAyBXY58GRyEtOqZYN2iqDlg1
	krO/bIyzhgP7R+X9FuOibwCeohsqh/EKGwFX0MT/SVtPXSpwnhijkmaPWSI1J6Xkwdj1IO
	W2aWaiS9zhEGfrTnXUhe8hHO5EeYC/0=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 8F733593A9;
	Wed, 13 May 2026 08:54:48 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id QHqHIlg8BGpERwAAD6G6ig
	(envelope-from <neelx@suse.com>); Wed, 13 May 2026 08:54:48 +0000
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
	linux-kernel@vger.kernel.org,
	Boris Burkov <boris@bur.io>
Subject: [PATCH v7 43/43] btrfs: disable send if we have encryption enabled
Date: Wed, 13 May 2026 10:53:17 +0200
Message-ID: <20260513085340.3673127-44-neelx@suse.com>
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
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	RCPT_COUNT_TWELVE(0.00)[13];
	DKIM_SIGNED(0.00)[suse.com:s=susede1];
	RCVD_COUNT_TWO(0.00)[2];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FROM_HAS_DN(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	TO_DN_SOME(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.com:mid,bur.io:email]
X-Spam-Level: 

From: Josef Bacik <josef@toxicpanda.com>

send needs to track the dir item values to see if files were renamed
when doing an incremental send.  There is code to decrypt the names, but
this breaks the code that checks to see if something was overwritten.
Until this gap is closed we need to disable send on encrypted file
systems.  Fixing this is straightforward, but a medium sized project.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Reviewed-by: Boris Burkov <boris@bur.io>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---

v5: https://lore.kernel.org/linux-btrfs/62ce86b38e2575c542eed7fbe8d986e68496b1d7.1706116485.git.josef@toxicpanda.com/
 * No changes since.
---
 fs/btrfs/send.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/btrfs/send.c b/fs/btrfs/send.c
index 1e80a3db1df2..11a3e928a4c2 100644
--- a/fs/btrfs/send.c
+++ b/fs/btrfs/send.c
@@ -8095,6 +8095,12 @@ long btrfs_ioctl_send(struct btrfs_root *send_root, const struct btrfs_ioctl_sen
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
+	if (btrfs_fs_incompat(fs_info, ENCRYPT)) {
+		btrfs_err(fs_info,
+		  "send with encryption enabled isn't currently suported");
+		return -EINVAL;
+	}
+
 	/*
 	 * The subvolume must remain read-only during send, protect against
 	 * making it RW. This also protects against deletion.
-- 
2.53.0

