Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC5DC3E3C72
	for <linux-fscrypt@vger.kernel.org>; Wed, 13 May 2026 08:54:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1778662467; cv=none; b=uCNixigeZ14lO2KV7MuC0FyeI/KChP/B6tea++7Q5inQn7aUCvgTd9njUsYyPz/UlIWSB0PnefAnpF+l7tegnSHvLUhkfhgQuFXPjV2OzUsy19uRF+n2CNPlcjZzdKGZN7pywOi2aUZS+KkUAubvLclPRVIF8F7+AE3k+Kmdul4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1778662467; c=relaxed/simple;
	bh=34xv0z50Rb801bLe8lZLvj9GZJgDbm9dun/sfWdJBX4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=PqIcvx9mphplFzKQ+NZ2rh9fY5iqRzuOYDMQYTUpULM5myR5eDGxyrT8osAahvj2UCgAB6JT+yUPdR/dgvVQwVdM1E6V4WaQPIi2LuTfqq+6unsdTJ0YyACUX7ZGhvm6IssfuCVeyErqcynXEfGYbnxo6yPi4TIZDlz+cVHEHoY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=Z9rHicXm; dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b=Z9rHicXm; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="Z9rHicXm";
	dkim=pass (1024-bit key) header.d=suse.com header.i=@suse.com header.b="Z9rHicXm"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id AEB1176645;
	Wed, 13 May 2026 08:54:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1778662457; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=8iKlhUE5U1uO4yyZaetGxyq4QBavoY8yThrDnh9CbQ8=;
	b=Z9rHicXmXrwLuSSh96VVpIRoKQe0xH1toCQe0Kg1UGhAO0HoperlkPG4ER+Fqfe35Zij74
	5d2TE8WNTpzwlVU9TpTQzoQwa7MYQ5KNx24SCT22h4eAR0gqBvBLQHJRqY01pSsbbBdRKB
	iEkf+gDOurI9jec4C0pd4QSZ0K6NSjI=
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.com; s=susede1;
	t=1778662457; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=8iKlhUE5U1uO4yyZaetGxyq4QBavoY8yThrDnh9CbQ8=;
	b=Z9rHicXmXrwLuSSh96VVpIRoKQe0xH1toCQe0Kg1UGhAO0HoperlkPG4ER+Fqfe35Zij74
	5d2TE8WNTpzwlVU9TpTQzoQwa7MYQ5KNx24SCT22h4eAR0gqBvBLQHJRqY01pSsbbBdRKB
	iEkf+gDOurI9jec4C0pd4QSZ0K6NSjI=
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 8D656593A9;
	Wed, 13 May 2026 08:54:17 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id EOnkITk8BGpERwAAD6G6ig
	(envelope-from <neelx@suse.com>); Wed, 13 May 2026 08:54:17 +0000
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
Subject: [PATCH v7 03/43] fscrypt: add a __fscrypt_file_open helper
Date: Wed, 13 May 2026 10:52:37 +0200
Message-ID: <20260513085340.3673127-4-neelx@suse.com>
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
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_CONTAINS_FROM(1.00)[];
	R_MISSING_CHARSET(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_HAS_DN(0.00)[];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	RCPT_COUNT_TWELVE(0.00)[12];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	DKIM_SIGNED(0.00)[suse.com:s=susede1];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	TO_DN_SOME(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email,suse.com:mid];
	RCVD_TLS_ALL(0.00)[]
X-Spam-Level: 

From: Josef Bacik <josef@toxicpanda.com>

We have fscrypt_file_open() which is meant to be called on files being
opened so that their key is loaded when we start reading data from them.

However for btrfs send we are opening the inode directly without a filp,
so we need a different helper to make sure we can load the fscrypt
context for the inode before reading its contents.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
Signed-off-by: Daniel Vacek <neelx@suse.com>
---

No changes in v7.
v6 changes:
 * Adapted to fscrypt changes since the last two years.
v5: https://lore.kernel.org/linux-btrfs/4a372419c3fe6ad425e1b124c342a054e9d6db23.1706116485.git.josef@toxicpanda.com/
---
 fs/crypto/hooks.c       | 38 ++++++++++++++++++++++++++++++++------
 include/linux/fscrypt.h |  8 ++++++++
 2 files changed, 40 insertions(+), 6 deletions(-)

diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index a7a8a3f581a0..3142cf106bde 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -9,6 +9,37 @@
 
 #include "fscrypt_private.h"
 
+/**
+ * __fscrypt_file_open() - prepare for filesystem-internal access to a
+ *			   possibly-encrypted regular file
+ * @dir: the inode for the directory via which the file is being accessed
+ * @inode: the inode being "opened"
+ *
+ * This is like fscrypt_file_open(), but instead of taking the 'struct file'
+ * being opened it takes the parent directory explicitly.  This is intended for
+ * use cases such as "send/receive" which involve the filesystem accessing file
+ * contents without setting up a 'struct file'.
+ *
+ * Return: 0 on success, -ENOKEY if the key is missing, or another -errno code
+ */
+int __fscrypt_file_open(struct inode *dir, struct inode *inode)
+{
+	int err;
+
+	err = fscrypt_require_key(inode);
+	if (err)
+		return err;
+
+	if (!fscrypt_has_permitted_context(dir, inode)) {
+		fscrypt_warn(inode,
+			     "Inconsistent encryption context (parent directory: %llu)",
+			     dir->i_ino);
+		return -EPERM;
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(__fscrypt_file_open);
+
 /**
  * fscrypt_file_open() - prepare to open a possibly-encrypted regular file
  * @inode: the inode being opened
@@ -60,12 +91,7 @@ int fscrypt_file_open(struct inode *inode, struct file *filp)
 	rcu_read_unlock();
 
 	dentry_parent = dget_parent(dentry);
-	if (!fscrypt_has_permitted_context(d_inode(dentry_parent), inode)) {
-		fscrypt_warn(inode,
-			     "Inconsistent encryption context (parent directory: %llu)",
-			     d_inode(dentry_parent)->i_ino);
-		err = -EPERM;
-	}
+	err = __fscrypt_file_open(d_inode(dentry_parent), inode);
 	dput(dentry_parent);
 	return err;
 }
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index f216f1a78069..dda5b1d32f78 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -471,6 +471,7 @@ int fscrypt_zeroout_range(const struct inode *inode, loff_t pos,
 
 /* hooks.c */
 int fscrypt_file_open(struct inode *inode, struct file *filp);
+int __fscrypt_file_open(struct inode *dir, struct inode *inode);
 int __fscrypt_prepare_link(struct inode *inode, struct inode *dir,
 			   struct dentry *dentry);
 int __fscrypt_prepare_rename(struct inode *old_dir, struct dentry *old_dentry,
@@ -818,6 +819,13 @@ static inline int fscrypt_file_open(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+static inline int __fscrypt_file_open(struct inode *dir, struct inode *inode)
+{
+	if (IS_ENCRYPTED(inode))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
 static inline int __fscrypt_prepare_link(struct inode *inode, struct inode *dir,
 					 struct dentry *dentry)
 {
-- 
2.53.0

