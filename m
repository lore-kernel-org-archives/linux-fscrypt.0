Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.132
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792743585;
	b=0X7J16vcJkDqYR4iKMkhBMIlOdqWky8bF+2Tj+CeoeL8hWOCDBl/iOAftaO3wVZzIaAQ
	 0iPUCsb0dglnzp4LTojFLuztJCEejcstc628v2R3t/XjFQ7KSBeSCdfXnFmw16v0bgoqN
	 BjbUBbCP9mxlpibe7MWP5f1VdNUVUn0iihTCEDj+jt+ZDdWcH8EFDUdGGDT1CfYNt8vYs
	 8DinEKj6n0Knczxzz/T/p2a9Uq7BlTbtB8e4Ws9thkRH1e1F32c5Sh5vtM6fxIFfn4HBg
	 r5NuQpeKFBUZRHuGOhVrBlSrJzUNnAVzZZy8RVWMvM88Sq4WdTg1xj88keVqXR9qyoA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792743585;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=aBrMWknICibqOEH4OG2gicLYXH4Dvkn7sWSAjLgDFB4=;
	b=PPoJacv0le6VdHdoyU/48zOyK2ZFwRoaq6zofuSKEfN1R0kUE4EzPUphciqS7JtagTq4
	 ktPxbT6VyiSFbibUS4H0kUkC6LJNTXV/hwyGmZRpd5kT6QLIXHW6bMAhrc05wYhor+M9J
	 vJ3kJ2heWRMYE5bLRa2EarM6FqntdPh7wecYMQBbpevp9QMDE8fFFU/1+wJ6gtDr+rLdf
	 zDGS6jznt+GSs4Uvdy4GXCjNYHIC0/TzrWKAUQJVJSMisFpDTIhRaXpN7xOGkksA60mhP
	 uIFGrv9z1eGGUzc4FCrmCiyaVOeTvO7CPh0PeQsk0O7Mq7REe84FWDpTh3jDRdGeKjQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=c5QtSXy3;
	arc=none smtp.remote-ip=115.124.30.132
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com [115.124.30.132])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 88FB4606A31A;
	Fri, 23 Oct 2026 08:19:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 88FB4606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=c5QtSXy3
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1792743579; h=From:To:Subject:Date:Message-ID:MIME-Version:Content-Type;
	bh=aBrMWknICibqOEH4OG2gicLYXH4Dvkn7sWSAjLgDFB4=;
	b=c5QtSXy3vJO7zEvTD/DzdporMf14fm2Oj6G48nEKqzK6RpANaVxMB4UeKwYhHc53Y2fzax1AM1if258I6u+JW2EfHqrB97BDe8StOdXsqS2P0NiEwipQOPni9Lkg2jwyLFgl0KfTxwyepbG5XKt7rmvhf+iK8rocZL+MJzi9f/8=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R161e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045133197;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=11;SR=0;TI=SMTPD_---0XDLbawC_1792743549;
Received: from x31h02109.sqa.na131.tbsite.net(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XDLbawC_1792743549 cluster:ay36)
          by smtp.aliyun-inc.com;
          Fri, 23 Oct 2026 16:19:38 +0800
From: Baokun Li <libaokun@linux.alibaba.com>
To: linux-block@vger.kernel.org,
	axboe@kernel.dk
Cc: ebiggers@kernel.org,
	linux-fscrypt@vger.kernel.org,
	hch@lst.de,
	dm-devel@lists.linux.dev,
	mpatocka@redhat.com,
	sweettea-kernel@dorminy.me,
	stable@vger.kernel.org,
	Sashiko <sashiko-bot@kernel.org>
Subject: [PATCH v3] blk-crypto: fix NULL deref and UAF in __blk_crypto_evict_key()
Date: Fri, 23 Oct 2026 16:19:08 +0800
Message-ID: <20261023081908.3505413-1-libaokun@linux.alibaba.com>
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

Sashiko reported a possible NULL pointer dereference, triggered by the
following flow:

  dm-inlinecrypt ctor            # first use of the fallback
   ├─ blk_crypto_init_key()      # succeeds, ctx->key.size != 0
   ├─ blk_crypto_start_using_key()
   │   ├─ hw-wrapped key: -EOPNOTSUPP
   │   │    # profile never allocated (NULL)
   │   └─ raw key: fallback_start_using_mode()
   │      └─ blk_crypto_fallback_init() fails
   │         └─ kfree(profile)   # not NULLed
   ├─ goto bad
   └─ inlinecrypt_dtr()          # evicts whenever key.size is set
      └─ blk_crypto_evict_key()
         └─ blk_crypto_config_supported_natively() = false
            └─ blk_crypto_fallback_evict_key()
               └─ __blk_crypto_evict_key(blk_crypto_fallback_profile)
                  └─ profile->num_slots # BOOM!!!

This issue can be reproduced using the following commands:

  dd if=/dev/zero of=/tmp/backing bs=1M count=64
  LOOP=$(losetup -f --show /tmp/backing)
  SZ=$(blockdev --getsz $LOOP)
  KEY=$(head -c 64 /dev/urandom | od -An -tx1 | tr -d ' \n')
  dmsetup create ic --table "0 $SZ inlinecrypt aes-xts-plain64 \
    $KEY 0 $LOOP 0 1 keytype:hw-wrapped"

And the following oops is triggered:

  ==================================================================
  blk-crypto: loop0: no support for wrapped keys
  Oops: general protection fault, probably for non-canonical address
        0xdffffc000000000b: 0000 [#1] SMP KASAN PTI
  KASAN: null-ptr-deref in range [0x0000000000000058-0x000000000000005f]
  CPU: 5 UID: 0 PID: 901 Comm: dmsetup 7.3.0-rc3 #1 PREEMPT(lazy)
  RIP: 0010:__blk_crypto_evict_key+0x2e/0x3b0
  Call Trace:
   blk_crypto_evict_key+0x24c/0x320
   inlinecrypt_dtr+0xf6/0x160
   inlinecrypt_ctr+0x2d3/0xbd0
   dm_table_add_target+0x661/0xf40
   table_load+0x1c4/0x490
   ctl_ioctl+0x32f/0x5f0
   dm_ctl_ioctl+0xe/0x20
  ==================================================================

dm-inlinecrypt is the only caller that can evict a key that was never
started, as fscrypt frees such a key without evicting it.

Fix this by returning early from blk_crypto_fallback_evict_key() when
tfms_inited[] is not set for the key's mode.  tfms_inited[] is only set
after blk_crypto_fallback_init() has successfully initialized the
profile, so the crash above is no longer reachable.

The bug has been latent since commit c984ff1423ae ("blk-crypto:
dynamically allocate fallback profile") was merged in v6.5, and only
became actually triggerable when commit e7f57d2c47e2 ("dm-inlinecrypt:
add target for inline block device encryption") was merged in v7.2.

Fixes: c984ff1423ae ("blk-crypto: dynamically allocate fallback profile")
Cc: stable@vger.kernel.org
Reported-by: Sashiko <sashiko-bot@kernel.org>
Closes: https://patch.msgid.link/sashiko-outbox-167341@kernel.org
Suggested-by: Eric Biggers <ebiggers@kernel.org>
Link: https://patch.msgid.link/20261014155131.GB322435@quark
Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
---
Changes since v2:
 * Skip fallback eviction if tfms_inited[] is unset
   (Suggested by Eric Biggers).
 * Drop v2 2/2; fix the weak ordering in fscrypt instead
   (Suggested by Eric Biggers).

Changes since v1:
 * Publish the profile only after successful init to avoid concurrent
   UAF (Reported by Sashiko).

v2: https://patch.msgid.link/20261014071846.3666398-1-libaokun@linux.alibaba.com
v1: https://patch.msgid.link/20261013095106.881914-1-libaokun@linux.alibaba.com

 block/blk-crypto-fallback.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
index 2a8f40a65158..12e0b487e23a 100644
--- a/block/blk-crypto-fallback.c
+++ b/block/blk-crypto-fallback.c
@@ -524,6 +524,12 @@ bool blk_crypto_fallback_bio_prep(struct bio *bio)
 
 int blk_crypto_fallback_evict_key(const struct blk_crypto_key *key)
 {
+	/*
+	 * Pairs with smp_store_release() in
+	 * blk_crypto_fallback_start_using_mode()
+	 */
+	if (!smp_load_acquire(&tfms_inited[key->crypto_cfg.crypto_mode]))
+		return 0;
 	return __blk_crypto_evict_key(blk_crypto_fallback_profile, key);
 }
 

base-commit: 734bef548a96e8774d6eef5dfa2026c6edc4e80b
-- 
2.43.7

