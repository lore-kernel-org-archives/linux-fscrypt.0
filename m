Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.182.15
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795457684;
	b=nbIE6ozgHuIxe0sRhj44xyOMGKoziueiBSDxluBEDwgZHlR+pTg4gSD2Qreg1L9U/XBB
	 kyvUIgfqtk5OqFBJx2oD0CX/+f5iHSjG8lWa3c0fxYpHIWW456wYeHOXO68VCq08dXieb
	 VmO6lQKsrxdXlyWFKV20Cy9PlObRc4g3rAiSIWxBW86XiH3j2X9azdCRNCRQJNmJHpnLn
	 ER6GTTB8Q5RSKJyBuiUzJZm1+gGFFg+gnzk3FPBLgMk8MELzDy1LDOY2MzgGfNLK16eTB
	 i9TvxmxZuxc/oml+5o7mf6tVysXgZxlrSSZTdXlMQ7WGeyEq2r8eMJdUNP9kQGEnGmw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795457684;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding:
	 X-ZohoMailClient;
	bh=yOy40zyrDNkufLfX1+5C1rSlLdTXQCSrlMTkU/yGIbE=;
	b=kxNu6xUoBJwWoOhPdgksddAZjI4E7g2CDNpCHvlWmQJG8zmR5332m3sSUiQaWETveVuw
	 5vIOwKbtAgFnZRBR7aKkTmQpxrzbRbLFf8OQqBqfOaUItJRRiIPL+i8lBwzFCw5GAuzle
	 lLyAWTJUoIbAGNB0MzQlHDkFaCrbDT6/opCnF0OEzbeAaQAi3WO6SpmoISPUalSvHfdiV
	 5Ohc191kBfeKX3kBA/Ti6fITS/Hz5YraL+eTliA/DZSZXkhs0GX8ZqT/UPA+VfiziQdmK
	 5A0UUF+09LCjwW7G96QcAFMrh19nu5eWTr8jqGe2Qd6aOvPh+R9ApoCe3FVO2omzaEg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=laveeshbansal.com;
	spf=pass smtp.mailfrom=laveeshbansal.com;
	dkim=pass header.d=laveeshbansal.com header.i=@laveeshbansal.com header.a=rsa-sha256 header.s=zoho header.b="WUZJWl/W";
	arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.182.15
Received: from sender5-op-o15.zoho.com (sender5-op-o15.zoho.com [165.173.182.15])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74173606A31A;
	Mon, 23 Nov 2026 18:14:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 74173606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=laveeshbansal.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=laveeshbansal.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=laveeshbansal.com header.i=@laveeshbansal.com header.a=rsa-sha256 header.s=zoho header.b=WUZJWl/W
ARC-Seal: i=1; a=rsa-sha256; t=1795457656; cv=none; 
	d=zohomail.com; s=zohoarc; 
	b=GO/PQr/knQKRwutlrxpwmQnlF4ufiC1/MxPjTAEzuUQ1JguR57eiMoVdXUD1X0AUduAakU6A5sLNMSyGaFSYW7Sp4oR8jNmF2f5WP04t0LCn25Up5MlHbWvURM+l4L9OwnxpM9F/ALmJf7zgJXHXmzEk04rjIWqUagq70iDzuFw=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.com; s=zohoarc; 
	t=1795457656; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=yOy40zyrDNkufLfX1+5C1rSlLdTXQCSrlMTkU/yGIbE=; 
	b=awhHWwnYOwCb3N6C0YPM59LdRm3Y5BtyaYEuTOhHe7hijdDD+gIFhTAMqLfheZiDkFuQdnb0E/xEh03lFogFBLQx3zcoKpGGK+gX2/GEiP3POJFhYC0VQw8BFzCIzGQc7bpnmV4r6dAmaOrNqa72f56FOXjS9zSU0veebSdWEc0=
ARC-Authentication-Results: i=1; mx.zohomail.com;
	dkim=pass  header.i=laveeshbansal.com;
	spf=pass  smtp.mailfrom=laveeshb@laveeshbansal.com;
	dmarc=pass header.from=<laveeshb@laveeshbansal.com>
DKIM-Signature: a=rsa-sha256; b=WUZJWl/WqOw+OCdZAhZQPiZ+P3MWrUa09CnEksyxXKsCB/Am4F1s50PJq0XhRWHTAPRz+UgEEK3KWCFOlcBNZ/xAFnk4XDXHVjt5GNseG/05CMmBT1aXVCLIhdsUht96tV/TvlU4ZfIVrSNekJMUVAR2wWzv/mHlX1xFmtcjGQk=; c=relaxed/relaxed; s=zoho; d=laveeshbansal.com; v=1; bh=yOy40zyrDNkufLfX1+5C1rSlLdTXQCSrlMTkU/yGIbE=; h=Content-Description:Content-ID:Content-Type:Content-Transfer-Encoding:Cc:Date:From:In-Reply-To:List-Subscribe:List-Post:List-Owner:List-Id:List-Archive:List-Help:List-Unsubscribe:MIME-Version:Message-ID:Resent-Sender:Resent-Cc:Resent-Date:Resent-To:Reply-To:Resent-Message-ID:Resent-From:Sender:Subject:To:Date:From:Message-Id:Reply-To:Subject:To:Cc;
Received: by smtp.zohomail.com with SMTPS id 1795457654842487.56845822427283;
	Mon, 23 Nov 2026 10:14:14 -0800 (PST)
From: Laveesh Bansal <laveeshb@laveeshbansal.com>
To: Jens Axboe <axboe@kernel.dk>,
	Eric Biggers <ebiggers@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com,
	linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2] blk-crypto: use a NOIO scope while holding profile->lock
Date: Mon, 23 Nov 2026 10:14:08 -0800
Message-ID: <20261123181408.62972-1-laveeshb@laveeshbansal.com>
X-Mailer: git-send-email 2.54.0
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-ZohoMailClient: External

Setting a key in blk-crypto-fallback can deadlock on profile->lock.
blk_crypto_get_keyslot() holds it across keyslot_program, whose setkey
allocates with GFP_KERNEL (Adiantum); direct reclaim can evict an fscrypt
inode, and blk_crypto_evict_key() then takes profile->lock again. syzbot
reports it as an fs_reclaim vs profile->lock cycle. Since
commit 5acc6f649a68 ("fscrypt: Always use blk-crypto for contents on
block-based filesystems") hitting it no longer needs -o inlinecrypt.

Enter a NOIO scope in blk_crypto_hw_enter() and leave it in
blk_crypto_hw_exit(), so allocations made under the lock, by the
fallback or a hardware driver, can't recurse into the filesystem. The
saved flags live in the profile. blk_crypto_reprogram_all_keys() takes
the lock directly, so it gets the same scope.

Fixes: 488f6682c832 ("block: blk-crypto-fallback for Inline Encryption")
Cc: stable@vger.kernel.org # v7.3+
Reported-by: syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com
Closes: https://lore.kernel.org/r/6a9b25c3.b5d4176b.238c3e.0004.GAE@google.com
Signed-off-by: Laveesh Bansal <laveeshb@laveeshbansal.com>
---
I used an LLM for the analysis, the patch and the test runs.

Changes in v2:
 - Moved the NOIO scope from the two setkey calls into
   blk_crypto_hw_enter()/blk_crypto_hw_exit(), as Christoph suggested,
   and added it to blk_crypto_reprogram_all_keys().
 - The scope now also covers the hardware drivers' keyslot callbacks. I
   could not test those; it only narrows reclaim for them.
v1: https://lore.kernel.org/r/20261122213120.20974-1-laveeshb@laveeshbansal.com

Tested on arm64 and x86_64 (QEMU, base c44104f3642d, KASAN and lockdep;
patched runs include comment-only revisions): f2fs with an Adiantum
policy, creating encrypted files and reading them back with O_DIRECT
under a memory hog, about a minute per run. Runs showing each symptom:

                                              base      v2
  lockdep cycle warning, arm64                2 of 2    0 of 8
  lockdep cycle warning, x86_64               6 of 6    0 of 12
  task deadlocked on its own lock, arm64      0 of 2    0 of 8
  task deadlocked on its own lock, x86_64     5 of 6    0 of 12
  lockdep cycle warning, x86_64 as uid 65534  2 of 2    0 of 2
  task deadlocked, x86_64 as uid 65534        1 of 2    0 of 2
  profile->lock -> fs_reclaim edge in
    lockdep's dump (runs that got to it)      3 of 3    0 of 18

No KASAN reports. Under the hog memory runs out, and 3 of the 12 x86 runs
stalled in page allocation, two without finishing; base stalls the same
way. In one, the task holding profile->lock was waiting in the setkey
allocation with kswapd queued behind it. That stall began earlier, in the
RAM-backed disk's own allocation, and lockdep reported nothing: NOIO stops
the allocation recursing into key eviction, not a wait for free memory.

fstests -g encrypt on arm64 passes on f2fs and ext4. Could not reproduce
on ext4; fstests not run on x86_64.

 block/blk-crypto-profile.c         | 7 +++++++
 include/linux/blk-crypto-profile.h | 1 +
 2 files changed, 8 insertions(+)

diff --git a/block/blk-crypto-profile.c b/block/blk-crypto-profile.c
index 53126c091b0b..395829fe7bcc 100644
--- a/block/blk-crypto-profile.c
+++ b/block/blk-crypto-profile.c
@@ -29,6 +29,7 @@
 #include <linux/atomic.h>
 #include <linux/mutex.h>
 #include <linux/pm_runtime.h>
+#include <linux/sched/mm.h>
 #include <linux/wait.h>
 #include <linux/blkdev.h>
 #include <linux/blk-integrity.h>
@@ -53,11 +54,14 @@ static inline void blk_crypto_hw_enter(struct blk_crypto_profile *profile)
 	if (profile->dev)
 		pm_runtime_get_sync(profile->dev);
 	down_write(&profile->lock);
+	/* Reclaim evicts keys under this lock; don't recurse into the fs. */
+	profile->memflags = memalloc_noio_save();
 }
 
 static inline void blk_crypto_hw_exit(struct blk_crypto_profile *profile)
 	__releases(&profile->lock)
 {
+	memalloc_noio_restore(profile->memflags);
 	up_write(&profile->lock);
 	if (profile->dev)
 		pm_runtime_put_sync(profile->dev);
@@ -397,6 +401,7 @@ int __blk_crypto_evict_key(struct blk_crypto_profile *profile,
  */
 void blk_crypto_reprogram_all_keys(struct blk_crypto_profile *profile)
 {
+	unsigned int memflags;
 	unsigned int slot;
 
 	if (profile->num_slots == 0)
@@ -404,6 +409,7 @@ void blk_crypto_reprogram_all_keys(struct blk_crypto_profile *profile)
 
 	/* This is for device initialization, so don't resume the device */
 	down_write(&profile->lock);
+	memflags = memalloc_noio_save();
 	for (slot = 0; slot < profile->num_slots; slot++) {
 		const struct blk_crypto_key *key = profile->slots[slot].key;
 		int err;
@@ -414,6 +420,7 @@ void blk_crypto_reprogram_all_keys(struct blk_crypto_profile *profile)
 		err = profile->ll_ops.keyslot_program(profile, key, slot);
 		WARN_ON(err);
 	}
+	memalloc_noio_restore(memflags);
 	up_write(&profile->lock);
 }
 EXPORT_SYMBOL_GPL(blk_crypto_reprogram_all_keys);
diff --git a/include/linux/blk-crypto-profile.h b/include/linux/blk-crypto-profile.h
index 4f39e9cd7576..9209b6a14b98 100644
--- a/include/linux/blk-crypto-profile.h
+++ b/include/linux/blk-crypto-profile.h
@@ -174,6 +174,7 @@ struct blk_crypto_profile {
 	 */
 	struct rw_semaphore lock;
 	struct lock_class_key lockdep_key;
+	unsigned int memflags;
 
 	/* List of idle slots, with least recently used slot at front */
 	wait_queue_head_t idle_slots_wait_queue;
-- 
2.43.0

