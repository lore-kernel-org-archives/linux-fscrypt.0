Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66F8243E9F5
	for <linux-fscrypt@vger.kernel.org>; Fri,  6 Feb 2026 18:24:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770402280; cv=none; b=VVQuTW1dVzAsLeLOcBUUklOpxPfVA2UFdStGO/EnqO/0cixyeB0PUVirkocCza13J49OSO7J36BXSHGYGZubaRj6E5CFtj0wJKSEptGddjW7gs5xoCopN8VDzkkx1VeRvjxWGrjoNuj0w7R0+e0Xm8q7Di/Js/AQT0ACQKm++3g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770402280; c=relaxed/simple;
	bh=+NNKrKZBxf1YzCP43qrAbbVRt54PK87oJ/7BnhV/IO0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DBLWRptSmMJW0akKIYzNxNHhqjLDCU/0M8YGx/jJ7HYqtQjNYdftvh07PqeihVidzOBUH81P8r78xnqf9fMXh5WKicULpaHymeVXBzp5OwJG2+ccCXQvnvloyBZ4extlSzMf3ar+uTy8yHEMn0hONi5unK/ixeE8qJT/MtLvfHM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=OY7zAGUK; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=OY7zAGUK; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="OY7zAGUK";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="OY7zAGUK"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 279305BD29;
	Fri,  6 Feb 2026 18:24:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1770402245; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=1kkMxy8XmUk8cQiHlFLSrRmbG6vYEnV5u0ThGPeCzWw=;
	b=OY7zAGUKsb4fN15VAVW9MtuVeuOPOnPtn71qU40nQuZczR7EjxAFC7akQY0n9vJXHqWCPz
	iSzTXr59NEPcKD4U2pHY5sgJt+QY5mFknIPFWgiC2yCHtgP2WvFsMKSPK2lW2XMEs9h6fT
	qw0Twxd2zBP4bDpcm2j0flvNDjTC5mY=
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1770402245; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=1kkMxy8XmUk8cQiHlFLSrRmbG6vYEnV5u0ThGPeCzWw=;
	b=OY7zAGUKsb4fN15VAVW9MtuVeuOPOnPtn71qU40nQuZczR7EjxAFC7akQY0n9vJXHqWCPz
	iSzTXr59NEPcKD4U2pHY5sgJt+QY5mFknIPFWgiC2yCHtgP2WvFsMKSPK2lW2XMEs9h6fT
	qw0Twxd2zBP4bDpcm2j0flvNDjTC5mY=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id ED0163EA63;
	Fri,  6 Feb 2026 18:24:04 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id AANfOcQxhmkTCQAAD6G6ig
	(envelope-from <neelx@suse.com>); Fri, 06 Feb 2026 18:24:04 +0000
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
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: [PATCH v6 17/43] btrfs: add get_devices hook for fscrypt
Date: Fri,  6 Feb 2026 19:22:49 +0100
Message-ID: <20260206182336.1397715-18-neelx@suse.com>
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[toxicpanda.com:email,suse.com:mid,suse.com:email];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[13];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	R_RATELIMIT(0.00)[to_ip_from(RLjpbzrka5mc1bf4fb9cmz1e4f)];
	DKIM_SIGNED(0.00)[suse.com:s=susede1];
	RCVD_TLS_ALL(0.00)[]
X-Spam-Flag: NO
X-Spam-Score: -6.80
X-Spam-Level: 

From: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>

Since extent encryption requires inline encryption, even though we
expect to use the inlinecrypt software fallback most of the time, we
need to enumerate all the devices in use by btrfs.

Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---

v5: https://lore.kernel.org/linux-btrfs/47ff044fae65cb2b06a6bb6ffc91027511c4d1f4.1706116485.git.josef@toxicpanda.com/
 * No changes since.
---
 fs/btrfs/fscrypt.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/fs/btrfs/fscrypt.c b/fs/btrfs/fscrypt.c
index 078b8c9a0334..608f8797ea6f 100644
--- a/fs/btrfs/fscrypt.c
+++ b/fs/btrfs/fscrypt.c
@@ -12,7 +12,9 @@
 #include "ioctl.h"
 #include "messages.h"
 #include "root-tree.h"
+#include "super.h"
 #include "transaction.h"
+#include "volumes.h"
 #include "xattr.h"
 
 /*
@@ -177,10 +179,44 @@ static bool btrfs_fscrypt_empty_dir(struct inode *inode)
 	return inode->i_size == BTRFS_EMPTY_DIR_SIZE;
 }
 
+static struct block_device **btrfs_fscrypt_get_devices(struct super_block *sb,
+						       unsigned int *num_devs)
+{
+	struct btrfs_fs_info *fs_info = btrfs_sb(sb);
+	struct btrfs_fs_devices *fs_devices = fs_info->fs_devices;
+	int nr_devices = fs_devices->open_devices;
+	struct block_device **devs;
+	struct btrfs_device *device;
+	int i = 0;
+
+	devs = kmalloc_array(nr_devices, sizeof(*devs), GFP_NOFS | GFP_NOWAIT);
+	if (!devs)
+		return ERR_PTR(-ENOMEM);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(device, &fs_devices->devices, dev_list) {
+		if (!test_bit(BTRFS_DEV_STATE_IN_FS_METADATA, &device->dev_state) ||
+		    !device->bdev ||
+		    test_bit(BTRFS_DEV_STATE_REPLACE_TGT, &device->dev_state))
+			continue;
+
+		devs[i++] = device->bdev;
+
+		if (i >= nr_devices)
+			break;
+
+	}
+	rcu_read_unlock();
+
+	*num_devs = i;
+	return devs;
+}
+
 const struct fscrypt_operations btrfs_fscrypt_ops = {
 	.inode_info_offs = (int)offsetof(struct btrfs_inode, i_crypt_info) -
 			   (int)offsetof(struct btrfs_inode, vfs_inode),
 	.get_context = btrfs_fscrypt_get_context,
 	.set_context = btrfs_fscrypt_set_context,
 	.empty_dir = btrfs_fscrypt_empty_dir,
+	.get_devices = btrfs_fscrypt_get_devices,
 };
-- 
2.51.0

