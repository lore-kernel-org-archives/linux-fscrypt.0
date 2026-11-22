Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.180.15
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795383108;
	b=Fmx/z02zPP9ySiigk+lJ4rx+gqCkiIgyghoQOv4Mw6nEIVoEEF+PhutxM4wziHhWXmwJ
	 lMsRWtKB1lU7xINdOgRjGmli2j+A0me+2bScfI/tzyzdLYRFC/MG2E0bGaus0TnugcKmi
	 Mxlpsd7ro02peGerUzQPQMfb928b+ul3hxy/5T7ob4I0QeIhpx0jeobPxIgQV4l1q6dhf
	 wI+NL13Yo2J0okKXTT85W4XILJDIur4rk/9mT7mqYI1wIEXAJVhbaIl3kLYsaBf2f4kEP
	 1GVQBCZ1sNs3ZERbet4i/ll4RKsM5qcXlU0/8bsTai5iAx9m6zQ7fOedI3Ze7aSM0Pg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795383108;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding:
	 X-ZohoMailClient;
	bh=4Da26eW8Um/2wSqYK3x7AJPTzG5yvEtwSmXbjg+Qb4E=;
	b=boaczwKnB0IefoxFx+doMLdZvPFx00GGIDpOhcIXZfYpK0Rmd8Ngkltjya4O2rymUzF3
	 H8HLX5ZjciJ2TF2vWXnAMFpGtIdNh3i6pvv0oal9InCYkkvEfUhzqZvNI0xbTBeazZ1sR
	 kgdbNu/kLxOYzM6/2xFmgFgT1RPu5+pvolg38ziEI0p3l/Air44V1XLwPdsbAOsBe1xT9
	 kChe+pAkbTnVfRt7Go0vrFoFegikg4d7AsPeG/IHJBdNTtt5lcuPhfzKIPVUrM2OQTSW4
	 rP32Al2+UWnQQ5CCa2Tojn7uoS0HQPNjwh9JtQtE4chVNzB8nlY2VPwxfs8m31YGMsg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=laveeshbansal.com;
	spf=pass smtp.mailfrom=laveeshbansal.com;
	dkim=pass header.d=laveeshbansal.com header.i=@laveeshbansal.com header.a=rsa-sha256 header.s=zoho header.b=ctc+hlCt;
	arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.180.15
Received: from sender6-op-o15.zoho.com (sender6-op-o15.zoho.com [165.173.180.15])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CCAA1606A31A;
	Sun, 22 Nov 2026 21:31:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CCAA1606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=laveeshbansal.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=laveeshbansal.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=laveeshbansal.com header.i=@laveeshbansal.com header.a=rsa-sha256 header.s=zoho header.b=ctc+hlCt
ARC-Seal: i=1; a=rsa-sha256; t=1795383091; cv=none; 
	d=zohomail.com; s=zohoarc; 
	b=F75hLaiX0g07PSKho6TTYeNwZgUiIegt3onfbar6bHrMrW/1SW1xafD/o3odxLnzAjiHgtrzO8g7XAwiJrR1t1nEd2KBQX9Tv9ubyEeDw6gHjX5TfJ46UYPfG6rF+SonloGTICzNYlxs6ZEgNRRqbPqBfyfbdcII7TBGMPNcrNY=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.com; s=zohoarc; 
	t=1795383091; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=4Da26eW8Um/2wSqYK3x7AJPTzG5yvEtwSmXbjg+Qb4E=; 
	b=fK71F375RdKR0P8UUiLfeyU/zFovBkDjySQCBiRiKJtDLFRGzSLwgqpXQjIicFeISBp4Ox3BHsnM38GyQSHI+RLPe5HfPjUcrLCfHWXuCdWpfkdBF757FFHp1nTxTYLQqzn0uq3m3xa1sEpm+OpndMBnfwxvzoJ+Gdpds6mR84U=
ARC-Authentication-Results: i=1; mx.zohomail.com;
	dkim=pass  header.i=laveeshbansal.com;
	spf=pass  smtp.mailfrom=laveeshb@laveeshbansal.com;
	dmarc=pass header.from=<laveeshb@laveeshbansal.com>
DKIM-Signature: a=rsa-sha256; b=ctc+hlCtD37eGZr3h8/TagiPVPxK6T4HwnnbMauSG/XU5tMq/enEdqh7jtPv4ywC/vufNxzfTYiFPwLA2yjr6IBfGu/EaUu9vvkWZtqU4Qv1/kidodhLqBH9s2rKw9hwvHRTx0A0LbhbQxogvaC9X6sCifJuRlqHHvaxtHBkQq4=; c=relaxed/relaxed; s=zoho; d=laveeshbansal.com; v=1; bh=4Da26eW8Um/2wSqYK3x7AJPTzG5yvEtwSmXbjg+Qb4E=; h=Content-Description:Content-ID:Content-Type:Content-Transfer-Encoding:Cc:Date:From:In-Reply-To:List-Subscribe:List-Post:List-Owner:List-Id:List-Archive:List-Help:List-Unsubscribe:MIME-Version:Message-ID:Resent-Sender:Resent-Cc:Resent-Date:Resent-To:Reply-To:Resent-Message-ID:Resent-From:Sender:Subject:To:Date:From:Message-Id:Reply-To:Subject:To:Cc;
Received: by smtp.zohomail.com with SMTPS id 1795383089229257.78063783334767;
	Sun, 22 Nov 2026 13:31:29 -0800 (PST)
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
Subject: [PATCH] blk-crypto: avoid fs reclaim under profile->lock in the fallback
Date: Sun, 22 Nov 2026 13:31:20 -0800
Message-ID: <20261122213120.20974-1-laveeshb@laveeshbansal.com>
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

Use memalloc_noio_save() around both setkey calls (keyslot_program and
the blank-key clear in evict_keyslot), as blk_crypto_alloc_enc_bio()
does.

Fixes: 488f6682c832 ("block: blk-crypto-fallback for Inline Encryption")
Cc: stable@vger.kernel.org # v7.3+
Reported-by: syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com
Closes: https://lore.kernel.org/r/6a9b25c3.b5d4176b.238c3e.0004.GAE@google.com
Signed-off-by: Laveesh Bansal <laveeshb@laveeshbansal.com>
---
I used an LLM for the analysis, the patch and the test runs.

A scope in blk_crypto_hw_enter() would also cover hardware drivers (qcom
ICE allocates under the lock); I kept this to the fallback.

Tested on arm64 and x86_64 (QEMU, base c44104f3642d, KASAN and lockdep;
patched runs and fstests include comment-only revisions): f2fs with an
Adiantum policy, creating encrypted files and reading them back with
O_DIRECT under a memory hog, about a minute per run.
Runs showing each symptom:

                                              base      patched
  lockdep cycle warning, arm64                2 of 2    0 of 6
  lockdep cycle warning, x86_64               6 of 6    0 of 16
  task deadlocked on its own lock, arm64      0 of 2    0 of 6
  task deadlocked on its own lock, x86_64     5 of 6    0 of 16
  lockdep cycle warning, x86_64 as uid 65534  2 of 2    0 of 2
  task deadlocked, x86_64 as uid 65534        1 of 2    0 of 2
  profile->lock -> fs_reclaim edge in
    lockdep's dump (runs that got to it)      3 of 3    0 of 21

No KASAN reports. Some runs, base and patched, hit unrelated stalls under the
hog (f2fs and page allocation); none has a blk-crypto frame. fstests -g
encrypt on arm64: f2fs passes; ext4 passes except generic/435, which ran out
of space on a 1 GB scratch device and passes on 2 GB. Could not reproduce on
ext4; fstests not run on x86_64.

 block/blk-crypto-fallback.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
index 12e0b487e23a..2df418f16932 100644
--- a/block/blk-crypto-fallback.c
+++ b/block/blk-crypto-fallback.c
@@ -89,17 +89,24 @@ static struct bio_set enc_bio_set;
  */
 static u8 blank_key[BLK_CRYPTO_MAX_RAW_KEY_SIZE];
 
+/*
+ * setkey can allocate while profile->lock is held, and reclaim takes that lock
+ * to evict a key.  Use NOIO so those allocations can't recurse into the fs.
+ */
 static void blk_crypto_fallback_evict_keyslot(unsigned int slot)
 {
 	struct blk_crypto_fallback_keyslot *slotp = &blk_crypto_keyslots[slot];
 	enum blk_crypto_mode_num crypto_mode = slotp->crypto_mode;
+	unsigned int memflags;
 	int err;
 
 	WARN_ON(slotp->crypto_mode == BLK_ENCRYPTION_MODE_INVALID);
 
 	/* Clear the key in the skcipher */
+	memflags = memalloc_noio_save();
 	err = crypto_sync_skcipher_setkey(slotp->tfms[crypto_mode], blank_key,
 				     blk_crypto_modes[crypto_mode].keysize);
+	memalloc_noio_restore(memflags);
 	WARN_ON(err);
 	slotp->crypto_mode = BLK_ENCRYPTION_MODE_INVALID;
 }
@@ -112,6 +119,7 @@ blk_crypto_fallback_keyslot_program(struct blk_crypto_profile *profile,
 	struct blk_crypto_fallback_keyslot *slotp = &blk_crypto_keyslots[slot];
 	const enum blk_crypto_mode_num crypto_mode =
 						key->crypto_cfg.crypto_mode;
+	unsigned int memflags;
 	int err;
 
 	if (crypto_mode != slotp->crypto_mode &&
@@ -119,8 +127,10 @@ blk_crypto_fallback_keyslot_program(struct blk_crypto_profile *profile,
 		blk_crypto_fallback_evict_keyslot(slot);
 
 	slotp->crypto_mode = crypto_mode;
+	memflags = memalloc_noio_save();
 	err = crypto_sync_skcipher_setkey(slotp->tfms[crypto_mode], key->bytes,
 				     key->size);
+	memalloc_noio_restore(memflags);
 	if (err) {
 		blk_crypto_fallback_evict_keyslot(slot);
 		return err;
-- 
2.43.0

