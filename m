Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.132
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792838650;
	b=H/oObs1xaFNTWHInVq1F32oT4Si93sfo5aZDN/WivfeSVvWMipIAquNIaTPDFUJprwOp
	 PpjKgQ0yFI/XxsLXrGVjFebB3DTluLVGoJ6ne7exYJ2OAFiaoPOB8qyfqv9jU+Rfv4605
	 xSJrHuMzxBwUXy4lQAePJ3VMyafQOJ+WQxzPere0WSsEXk01O3LAPv36skVkk14MvTJMT
	 xBlKFj363xYD2EqkXMJ2H/Pr3e1dNd94y/8IHgxSOjog4heBYCiwmecForzq2Pqb6g+cb
	 tiq2m+JR7ZuTi1QvDppBHiMrE4o/Rb5LU0PGTvDM6/zZjAS6kIPl0knDzMk2X25KvrQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792838650;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=g1lBsOByITyOomjH9IC5HsDwOCpARxp+TMH1j0ATMaw=;
	b=hQKtuEpy6YpSbQCoGkaNpo3Pi1s60mXHsJhCi5mS7tGlZ00ubJnpGCa161V0vp6IGdGE
	 IkjuDADRaQUL7yoHGSN4/dwjwJeg4pO1UQ6AIZgdHB4bHxUn1p9ENCTQgzAesMfeDx95c
	 7OdqJUO+H4q9NUigbaee1vRHWiItihXCqitOqr73rbblWbYu2XdwQ0F8Mq2CJBhmC6iy9
	 5rqY3m+/B4aj5zH9rWX/ME2MooaFqf9W/jx2F5n2bQRYqiN9EI9/Ake11mUhiDwO3TY5A
	 d7TekaHUuWDv1VFAdmybV9GbOF+pFDndXMxl3uv9688V1zkYw+Hr/CceDFxUyxs5dpg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=LXynNLz0;
	arc=none smtp.remote-ip=115.124.30.132
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com [115.124.30.132])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0738606A31A;
	Sat, 24 Oct 2026 10:44:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F0738606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=LXynNLz0
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1792838639; h=From:To:Subject:Date:Message-ID:MIME-Version:Content-Type;
	bh=g1lBsOByITyOomjH9IC5HsDwOCpARxp+TMH1j0ATMaw=;
	b=LXynNLz0P/Y5QqQNrifheoZPbxOl7M92N5U/dhr+VEHPe2SPdDU4Uswr0bpEDzYXMPg9jmCUNjnbBTPn5jTWImUlaKQHa+ZofSrHrn/NVbHH0QqqezpG521SzGXUPPnzGrF1N9squdFxI9w4HBxG5fDhvdeAOlv1arw6/S/i/xc=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R641e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037026112;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0XDO1Nnr_1792838631;
Received: from x31h02109.sqa.na131.tbsite.net(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XDO1Nnr_1792838631 cluster:ay36)
          by smtp.aliyun-inc.com;
          Sat, 24 Oct 2026 18:43:58 +0800
From: Baokun Li <libaokun@linux.alibaba.com>
To: linux-fscrypt@vger.kernel.org
Cc: ebiggers@kernel.org,
	tytso@mit.edu,
	jaegeuk@kernel.org,
	libaokun@linux.alibaba.com,
	stable@vger.kernel.org
Subject: [PATCH v4] fscrypt: Fix missing barrier in fscrypt_find_mode_key()
Date: Sat, 24 Oct 2026 18:43:50 +0800
Message-ID: <20261024104350.2257313-1-libaokun@linux.alibaba.com>
X-Mailer: git-send-email 2.43.7
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

fscrypt_find_mode_key() walks an RCU list and hands out a per-mode
key without an acquire:

  setup task
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  setup_per_mode_enc_key()
   ├─ fscrypt_prepare_key()
   │  └─ fscrypt_prepare_inline_crypt_key()
   │     └─ blk_crypto_start_using_key()
   │        └─ blk_crypto_fallback_start_using_mode()
   │           ├─ init profile, keyslots, tfms[]
   │           └─ smp_store_release(tfms_inited[mode])  # init order
   └─ list_add_tail_rcu(&new_node->link, ...)  # release -> finder

  finding task (later submits the I/O itself)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  fscrypt_find_mode_key()
   ├─ list_for_each_entry_rcu(node, ...)
   └─ return &node->key                 # no acquire, chain breaks
  ...
  blk_crypto_fallback_bio_prep()        # WRITE path
   ├─ tfms_inited[mode]                 # addr-dep, reads true
   ├─ blk_crypto_fallback_profile       # no dependency
   ├─ blk_crypto_keyslots               # no dependency
   └─ slotp->tfms[mode]                 # no dependency

RCU publishes the node and the key reachable from it, so
tfms_inited[mode] reads true through the address dependency.  The
independent fallback globals are not covered by it and can be read as
uninitialized.

On a weakly ordered machine, a WRITE bio can crash in
blk_crypto_get_keyslot() or crypto_sync_skcipher_setkey().

Other tasks reach the key through fscrypt_inode_info's
cmpxchg_release()/smp_load_acquire(), which is already ordered after
the list walk; only the finding task's own later I/O was not.

Fix this by upgrading the control dependency to an acquire with
smp_acquire__after_ctrl_dep() once a matching entry has been found.

Fixes: dd015b566d50 ("fscrypt: Fix key setup in edge case with multiple data unit sizes")
Cc: stable@vger.kernel.org
Suggested-by: Eric Biggers <ebiggers@kernel.org>
Link: https://lore.kernel.org/r/20261014161153.GC322435@quark
Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
---
Changes since v3:
 * Update commit message and comments as suggested by Eric.

v3: https://patch.msgid.link/20261023160747.1382973-1-libaokun@linux.alibaba.com

 fs/crypto/keysetup.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index 892044ebcaca..a77b889d7578 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -205,8 +205,14 @@ fscrypt_find_mode_key(struct fscrypt_master_key *mk, u8 hkdf_context,
 		if (node->hkdf_context == hkdf_context &&
 		    node->mode_num == mode_num &&
 		    node->data_unit_bits == ci->ci_data_unit_bits &&
-		    fscrypt_is_key_prepared(&node->key, ci))
+		    fscrypt_is_key_prepared(&node->key, ci)) {
+			/*
+			 * Upgrade the RCU dereference to a full ACQUIRE, so
+			 * that blk-crypto global state is seen as initialized.
+			 */
+			smp_acquire__after_ctrl_dep();
 			return &node->key;
+		}
 	}
 	return NULL;
 }

base-commit: 734bef548a96e8774d6eef5dfa2026c6edc4e80b
-- 
2.43.7

