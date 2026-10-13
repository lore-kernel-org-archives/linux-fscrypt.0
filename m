Received: from out30-111.freemail.mail.aliyun.com (out30-111.freemail.mail.aliyun.com [115.124.30.111])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C68C3EA97A;
	Tue, 13 Oct 2026 09:51:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=115.124.30.111
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791885100; cv=none; b=XtaRPHzH+5ZKEyRSWojselUamlSspGM0O5+00KpVz76HFx0hZ1sGV7eaP9KmbGkq5roftgMWyal8J5+7BnfSQc2WXSpfDqBtnI60suVwX9C+JxvWgSx17M3TM3nQBBHwWkiO+xQA/1ex9iBwND6ZRXLjdxiCddbw/SK094zk740=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791885100; c=relaxed/simple;
	bh=uzrXPLMvqXiBDcQftrpFHfqmH5aI7M4XqJ0tPb6ooRw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=hetMTDjaKWy1dP2kXdPcukJvNN6Bvwbh+8O/8/GJGi33KNfhre+zKr/Er3uMfxJlKbuy5oExRR4tYH4xZeKFzNqHVBOjhnSOlCe2PgD3Hw2zidVTz7oq6RO1l0ckruFDLfRSOU4jhv1N9tzvuiulZWwYDV396tymbt+y9WWPH+8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com; spf=pass smtp.mailfrom=linux.alibaba.com; dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b=lL28Tkmw; arc=none smtp.client-ip=115.124.30.111
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.b="lL28Tkmw"
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1791885089; h=From:To:Subject:Date:Message-ID:MIME-Version:Content-Type;
	bh=mHJmlxh0JQdpNiWV3C7IoHHFL2rjw3jyGHSsWS10e0M=;
	b=lL28TkmwRy4o4DkqFESGvDjfVtHZjutdQoOzKS1g7GlBF8tLi2PuqNcHf/GcxIqaiT5utuZe7oZQhK1NvSiSFQpQW8+YILCpjl3XDiLKA5lbaeuIMRy5K3quWRzx39w46BzZ0I1/vSlbMbwN+poSWRymIR45zfZihQAcWofXrow=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R311e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045133197;MF=libaokun@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0XClPKIU_1791885066;
Received: from x31h02109.sqa.na131.tbsite.net(mailfrom:libaokun@linux.alibaba.com fp:SMTPD_---0XClPKIU_1791885066 cluster:ay36)
          by smtp.aliyun-inc.com;
          Tue, 13 Oct 2026 17:51:28 +0800
From: Baokun Li <libaokun@linux.alibaba.com>
To: axboe@kernel.dk,
	linux-block@vger.kernel.org
Cc: ebiggers@kernel.org,
	linux-fscrypt@vger.kernel.org,
	hch@lst.de,
	bvanassche@acm.org,
	dm-devel@lists.linux.dev,
	mpatocka@redhat.com,
	linlin.zhang@oss.qualcomm.com,
	libaokun@linux.alibaba.com,
	stable@vger.kernel.org,
	Sashiko <sashiko-bot@kernel.org>
Subject: [PATCH] blk-crypto: fix NULL deref and UAF in __blk_crypto_evict_key()
Date: Tue, 13 Oct 2026 17:51:06 +0800
Message-ID: <20261013095106.881914-1-libaokun@linux.alibaba.com>
X-Mailer: git-send-email 2.43.7
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Sashiko reported a possible NULL pointer dereference, triggered by the
following flow:

  dm-inlinecrypt ctor            # first use of the fallback
   ├─ blk_crypto_init_key()      # succeeds, ctx->key.size != 0
   ├─ blk_crypto_start_using_key()
   │   ├─ return -EOPNOTSUPP     # uninit profile, will NULL deref
   │   └─ blk_crypto_fallback_start_using_key()
   │      └─ blk_crypto_fallback_init() fails
   │         └─ kfree(profile)   # not NULLed, will UAF
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

Fix this by checking the profile for NULL in __blk_crypto_evict_key()
to avoid the NULL pointer dereference, and by clearing the profile
pointer after it is freed to avoid the use-after-free.

Fixes: e7f57d2c47e2 ("dm-inlinecrypt: add target for inline block device encryption")
Cc: stable@vger.kernel.org # v7.2+
Reported-by: Sashiko <sashiko-bot@kernel.org>
Closes: https://patch.msgid.link/sashiko-outbox-167341@kernel.org
Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>
---
 block/blk-crypto-fallback.c | 1 +
 block/blk-crypto-profile.c  | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
index 2a8f40a65158..b7890ee1951c 100644
--- a/block/blk-crypto-fallback.c
+++ b/block/blk-crypto-fallback.c
@@ -605,6 +605,7 @@ static int blk_crypto_fallback_init(void)
 	blk_crypto_profile_destroy(blk_crypto_fallback_profile);
 fail_free_profile:
 	kfree(blk_crypto_fallback_profile);
+	blk_crypto_fallback_profile = NULL;
 fail_free_bioset:
 	bioset_exit(&enc_bio_set);
 out:
diff --git a/block/blk-crypto-profile.c b/block/blk-crypto-profile.c
index 53126c091b0b..1c5feca3b856 100644
--- a/block/blk-crypto-profile.c
+++ b/block/blk-crypto-profile.c
@@ -346,6 +346,9 @@ int __blk_crypto_evict_key(struct blk_crypto_profile *profile,
 	struct blk_crypto_keyslot *slot;
 	int err;
 
+	if (!profile)
+		return 0;
+
 	if (profile->num_slots == 0) {
 		if (profile->ll_ops.keyslot_evict) {
 			blk_crypto_hw_enter(profile);

base-commit: fd73f4a6659897191fa0d40695fe370925dd3780
-- 
2.43.7

