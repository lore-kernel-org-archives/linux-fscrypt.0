Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.98
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792771697;
	b=QzqTMTUvSyPfKATTbwvYBTT9Z1eLo8567YEroCsiLrfZ79F2KfCQiF29enxh03S+ByDi
	 uBzAARpUPzQXZRPku82WXjgZ9kD/kvpE9IlDSgEfnJ0P0fmWef3QrZj1dPuYvc0cr+Yam
	 6pox+Ue5gVW242aqRxamikiKRtQ9SBTm1bE2i7XndPwW8/NiqVKJaZLVbOKMih8G1IaPx
	 EcP2hqEJW66mXzQaG/AHJ2lYy8v12Uqn6fjWAJrNbEb1O8kJL/JVtRb7IIFdMQ52GmiaC
	 CB1+JlOD0H3UHNuXRd8ZNxnr1ZvIK0MQ/YpWJBWUNIh0qbVOHQLZqEtkmAC+Pjc4eYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792771697;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=I52d5yYI1jKnpurs1AFfCbTEkdJyPAYumuiwLtVfgwc=;
	b=zP/YBgQnt/YZfNgUW5BNokxGnS8OxAYI7TeEtbOQXhLwSuG/AqStsRXmr0B1N5cg1qQ7
	 GtcnJU4vFomiKFzfp6MxfPv4Pl6ESpaiGbEljacujYBfyidMe/Ai64jykNm0jqs6L9GNR
	 0Po05NAhJ8mfRBAUssJKdrm/ECHBvmS9vh607eDknxX9sb6CsAEnwkYwAesS9XTliu85E
	 rYhlp9Difir9GnsH2xKhjJuXVGfEeuan5ACTA5xvTG2oJuF4y8K3usIUBLOHAngAPNseX
	 HFjrL3niMz4yFtL17gErJSubCpv2Eop0RJuYfwNqIBp/IZSfhA6O7Qi+35Gprtxvxew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=sVWkagat;
	arc=none smtp.remote-ip=115.124.30.98
Received: from out30-98.freemail.mail.aliyun.com (out30-98.freemail.mail.aliyun.com [115.124.30.98])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2381A606A31B;
	Fri, 23 Oct 2026 16:08:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2381A606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=sVWkagat
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1792771693; h=From:To:Subject:Date:Message-ID:MIME-Version:Content-Type;
	bh=I52d5yYI1jKnpurs1AFfCbTEkdJyPAYumuiwLtVfgwc=;
	b=sVWkagat9/+qk85fKVxdB7hcUyjh9ItzYId3BqjQgoVvbVGBRRhaM8aliDYqMi81FZT9MtGbEpRXrFQThwo5k/4+/k4dMhysuQz7Q1+shf9MzDOCobtfPqbXRoPb/IUQ92A6uRpiY7TVPDDVjY1VyuBs3Q1BiADkYhLONxbYujI=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R891e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037009110;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0XDMPwbu_1792771667;
Received: from x31h02109.sqa.na131.tbsite.net(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XDMPwbu_1792771667 cluster:ay36)
          by smtp.aliyun-inc.com;
          Sat, 24 Oct 2026 00:08:13 +0800
From: Baokun Li <libaokun@linux.alibaba.com>
To: linux-fscrypt@vger.kernel.org
Cc: ebiggers@kernel.org,
	tytso@mit.edu,
	jaegeuk@kernel.org,
	stable@vger.kernel.org
Subject: [PATCH v3] fscrypt: Fix missing barrier in fscrypt_find_mode_key()
Date: Sat, 24 Oct 2026 00:07:47 +0800
Message-ID: <20261023160747.1382973-1-libaokun@linux.alibaba.com>
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
dm-inlinecrypt reaches its key only through srcu_dereference(md->map),
with no acquire anywhere on the I/O path.

Fix this by upgrading the control dependency to an acquire with
smp_acquire__after_ctrl_dep() once a matching entry has been found.

Fixes: dd015b566d50 ("fscrypt: Fix key setup in edge case with multiple data unit sizes")
Cc: stable@vger.kernel.org
Suggested-by: Eric Biggers <ebiggers@kernel.org>
Link: https://patch.msgid.link/20261014161153.GC322435@quark
Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
---
 fs/crypto/keysetup.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index 892044ebcaca..984ef43982a3 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -205,8 +205,14 @@ fscrypt_find_mode_key(struct fscrypt_master_key *mk, u8 hkdf_context,
 		if (node->hkdf_context == hkdf_context &&
 		    node->mode_num == mode_num &&
 		    node->data_unit_bits == ci->ci_data_unit_bits &&
-		    fscrypt_is_key_prepared(&node->key, ci))
+		    fscrypt_is_key_prepared(&node->key, ci)) {
+			/*
+			 * Pairs with list_add_tail_rcu() in
+			 * setup_per_mode_enc_key().
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

