Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3A313101A6;
	Thu, 18 Jun 2026 18:49:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781808566; cv=none; b=McAdqBzzLBsKovUFZEIj+sr3eInRgHVKNNcGmXefMZ99L+TGMkJDFB6oR/6JD0S2wAvnIC8lasOOaVZN0RC/OQe8XJDPu9loBGC4tD1mhJLLiqEN1LnegpW9Ad24DFkzPq1w9WZX4jFI71z/j2gIRRaivaVMjtuwCkhSTKD3KIg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781808566; c=relaxed/simple;
	bh=5cp/4GPWgUkHvCH/UjHzWKlNBP55jn9A1lVeolEmwXU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=XuO/qY531/Q+dKt1ouSMja+7kNT1YNhtrd9iQgPYExAlQCTp0+F4Q5JwLXgIWdQkQsfBTX2/MBqlae9bbWTvkFtxGKSfMO9D6JNQ4FdIetkuh/KgvlH/wWMzJ8zFva98kPuYJAKmxkIXpgoDiTt+wEzEDjkLIuS8MiKzSA9jiJM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Tx7s3XTs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Tx7s3XTs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8492A1F000E9;
	Thu, 18 Jun 2026 18:49:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781808564;
	bh=pcl3bM4eeGVgQ/7vwFsJ90J824uNnNVuWepUoMCRzng=;
	h=From:To:Cc:Subject:Date;
	b=Tx7s3XTsHdMTTpBjUa6uIPodt8ECNjo0ouzVSDe1KaP+fW7SuCuRJM6k5NlubTvAN
	 tU9YaxLHYLJ6o4O/uKboB46y+Ojl0Mef1nl6COu9EKOnh+UTmMDHVDY1ckP/5opQMh
	 Wr64FoLDgzJ9rdvuWpv1xHmQSkp/AC3RfYuOWEoEcx+M2VD4KA4i+7d7Z1f2ANruXd
	 t7xEyAs8O8z57Az++EGB1v4YqPOZcrTqzhV2ivz4D+/QwPSdMbXZet99TVWR+ENXoD
	 Bk+Ue9ZcYngwpB5NmBEF6+EKTdR1ez6lGeM7ok62aw3gSwu0hqibO8kzhgGF2ddAHD
	 qeTn+Igdh8tOA==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: Use lock guards for mutexes
Date: Thu, 18 Jun 2026 18:48:52 +0000
Message-ID: <20260618184852.3469301-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0.rc0.738.g0c8ab3ebcc-goog
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace all remaining calls to mutex_lock() and mutex_unlock() in
fs/crypto/ with lock guards.  No functional change.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---

This is intended to be taken through the fscrypt tree for 7.3

 fs/crypto/crypto.c   | 13 ++++---------
 fs/crypto/keyring.c  |  3 +--
 fs/crypto/keysetup.c | 23 +++++++++++------------
 3 files changed, 16 insertions(+), 23 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 570a2231c945..10097a3251f5 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -321,35 +321,30 @@ EXPORT_SYMBOL(fscrypt_decrypt_block_inplace);
  *
  * Return: 0 on success; -errno on failure
  */
 int fscrypt_initialize(struct super_block *sb)
 {
-	int err = 0;
 	mempool_t *pool;
 
 	/* pairs with smp_store_release() below */
 	if (likely(smp_load_acquire(&fscrypt_bounce_page_pool)))
 		return 0;
 
 	/* No need to allocate a bounce page pool if this FS won't use it. */
 	if (!sb->s_cop->needs_bounce_pages)
 		return 0;
 
-	mutex_lock(&fscrypt_init_mutex);
+	guard(mutex)(&fscrypt_init_mutex);
 	if (fscrypt_bounce_page_pool)
-		goto out_unlock;
+		return 0;
 
-	err = -ENOMEM;
 	pool = mempool_create_page_pool(num_prealloc_crypto_pages, 0);
 	if (!pool)
-		goto out_unlock;
+		return -ENOMEM;
 	/* pairs with smp_load_acquire() above */
 	smp_store_release(&fscrypt_bounce_page_pool, pool);
-	err = 0;
-out_unlock:
-	mutex_unlock(&fscrypt_init_mutex);
-	return err;
+	return 0;
 }
 
 void fscrypt_msg(const struct inode *inode, const char *level,
 		 const char *fmt, ...)
 {
diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index 5fe0d985a58d..6ce6b436c34f 100644
--- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -523,11 +523,11 @@ static int do_add_master_key(struct super_block *sb,
 {
 	static DEFINE_MUTEX(fscrypt_add_key_mutex);
 	struct fscrypt_master_key *mk;
 	int err;
 
-	mutex_lock(&fscrypt_add_key_mutex); /* serialize find + link */
+	guard(mutex)(&fscrypt_add_key_mutex); /* serialize find + link */
 
 	mk = fscrypt_find_master_key(sb, mk_spec);
 	if (!mk) {
 		/* Didn't find the key in ->s_master_keys.  Add it. */
 		err = allocate_filesystem_keyring(sb);
@@ -550,11 +550,10 @@ static int do_add_master_key(struct super_block *sb,
 			 */
 			err = add_new_master_key(sb, secret, mk_spec);
 		}
 		fscrypt_put_master_key(mk);
 	}
-	mutex_unlock(&fscrypt_add_key_mutex);
 	return err;
 }
 
 static int add_master_key(struct super_block *sb,
 			  struct fscrypt_master_key_secret *secret,
diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index f905f9f94bdd..281b5a8b0bcd 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -347,22 +347,21 @@ static int fscrypt_setup_iv_ino_lblk_32_key(struct fscrypt_inode_info *ci,
 	if (err)
 		return err;
 
 	/* pairs with smp_store_release() below */
 	if (!smp_load_acquire(&mk->mk_ino_hash_key_initialized)) {
-
-		mutex_lock(&fscrypt_mode_key_setup_mutex);
-
-		if (mk->mk_ino_hash_key_initialized)
-			goto unlock;
-
-		fscrypt_derive_siphash_key(mk, HKDF_CONTEXT_INODE_HASH_KEY,
-					   NULL, 0, &mk->mk_ino_hash_key);
-		/* pairs with smp_load_acquire() above */
-		smp_store_release(&mk->mk_ino_hash_key_initialized, true);
-unlock:
-		mutex_unlock(&fscrypt_mode_key_setup_mutex);
+		guard(mutex)(&fscrypt_mode_key_setup_mutex);
+
+		if (!mk->mk_ino_hash_key_initialized) {
+			fscrypt_derive_siphash_key(mk,
+						   HKDF_CONTEXT_INODE_HASH_KEY,
+						   NULL, 0,
+						   &mk->mk_ino_hash_key);
+			/* pairs with smp_load_acquire() above */
+			smp_store_release(&mk->mk_ino_hash_key_initialized,
+					  true);
+		}
 	}
 
 	/*
 	 * New inodes may not have an inode number assigned yet.
 	 * Hashing their inode number is delayed until later.

base-commit: 83f1454877cc292b88baf13c829c16ce6937d120
prerequisite-patch-id: 319d2891e88c7df1ebb5ebf434d18b68f770399f
-- 
2.55.0.rc0.738.g0c8ab3ebcc-goog

