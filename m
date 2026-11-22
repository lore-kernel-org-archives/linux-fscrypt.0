Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795383848;
	b=eAF9YPjEo2YSazvxkBWUgOMvMRXGy5eDyGUBtXTGJgdmmhMJnCyAsdiDOWn20ogNdka2
	 3H8Eb6nfOlT11iB7o404KWsMK/9YyhT+2J5iK5kT9Yp1R0cb7AK6NVwCvt6VJqrQco8tN
	 5lcM6bzgQ30N8Sx4wo4yq06UHmhl6xKVnwxqOEPcAInZCRAxE6MWstXSVBlUpSZmrlDAB
	 v+zG8Ut4ccIFQvFWbHR28qgoVxjZl1JglVu3XjH4iuSJqFVX+CpO1mkY581iz+x1OZFEl
	 U1yrHmialK1wFWD+jcfOPOr7vhkArUFEswT3F0kpawhwe7jDhDGDof+SmumDfF6Barg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795383848;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=Mm/8mRyZax2YVXg0RDS5bNGwonwO0wM6qVgh6f9a91o=;
	b=bdu6diDKhPfiguNiKaFRmIyMCirLyDD8t8pHvsUClWbMDrX/xGwUs2wGDJVnUpwYwP1H
	 9izL25Q6RCRxUkaqFOsEzpWKD9/YWr66MKE2Nm43xgEQXDKbVo59/4auYTni5b8bFdxq7
	 /yg1ct+npw8RvFgNvnouqHxEqYOcsynttMX0+yp2mXgPolTcsnXNzTxT+QuYgVl++fSHz
	 pn8bWhJXnaVsYQv6FHeOe0FhFNhn8Bt6WF4OvsVq0jfBy0C8kqoHFitehVApT++XSI9uu
	 CbPrOsQ5hUI+pxQD+FuYj4MjiBgAgq96aFUTMPMDRwow0Ky1dxTDdm2xTtMu33S7nPQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="M55Og/By";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DCCA1606A31A;
	Sun, 22 Nov 2026 21:44:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M55Og/By
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 29E1E1F000C4;
	Sun, 22 Nov 2026 21:44:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795383848;
	bh=Mm/8mRyZax2YVXg0RDS5bNGwonwO0wM6qVgh6f9a91o=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=M55Og/BymrlJdKLFKVKWp1OjpkfLljWc5uTtkxs6qKea8KygH+sGKno8KF2ot3lAn
	 y6OMResxHO9opIYHoJ9/3ftAgu9ZgDjXk8Qo5SW1puTUG91y1A5Z1qa0Tn1tIGlmHf
	 36PAYVU94ard+ECTiELMt9nUuKJjlLV6hlgSygMuak1R2FyXwiHJ+VSvE2nViQgGXo
	 a6zl6FZdm5Yjzwb1U2T9clsvI/yEhWB+3cU5AotRKOAQn1hgV4HCaLw5tBHFqbBB92
	 x1DWyIgxnyqXdrmH7MxOXJgtquuaNDIXPp2hePpSOBmJhVJrEUAyf1CMrY0JAvRomS
	 sCtfxNCPN7oaA==
Message-ID: <sashiko-outbox-228362@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH] blk-crypto: avoid fs reclaim under profile->lock in the
 fallback
Reply-To: sashiko-reviews@lists.linux.dev
To: "Laveesh Bansal" <laveeshb@laveeshbansal.com>, "Jens Axboe" <axboe@kernel.dk>, "Eric
 Biggers" <ebiggers@kernel.org>
Cc: "Christoph Hellwig" <hch@lst.de>, =?utf-8?b?VGhlb2RvcmUgWS4gVHMnbw==?= <tytso@mit.edu>, "Jaegeuk
 Kim" <jaegeuk@kernel.org>, syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com, linux-fscrypt@vger.kernel.org, linux-crypto@vger.kernel.org
In-Reply-To: <20261122213120.20974-1-laveeshb@laveeshbansal.com>
References: <20261122213120.20974-1-laveeshb@laveeshbansal.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 22 Nov 2026 21:44:07 +0000
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

Thank you for your contribution! Sashiko AI review found no new issues
in this patch, but noticed 1 related pre-existing issue it does not
introduce:
- [High] block: NULL deref and OOB read in blk-crypto-fallback with
  num_keyslots=3D0 [1]
--

commit 7d0d16db31e8a22572290b726bc65b670e7fa101
Author: Laveesh Bansal <laveeshb@laveeshbansal.com>

blk-crypto: avoid fs reclaim under profile->lock in the fallback

This commit wraps the crypto_sync_skcipher_setkey() calls in the blk-crypto
fallback with memalloc_noio_save() to prevent direct reclaim from recursing
into filesystem key eviction while holding profile->lock.

> diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
> index 12e0b487e23ab..2df418f169328 100644
> --- a/block/blk-crypto-fallback.c
> +++ b/block/blk-crypto-fallback.c
> @@ -89,17 +89,24 @@ static struct bio_set enc_bio_set;
>   */
>  static u8 blank_key[BLK_CRYPTO_MAX_RAW_KEY_SIZE];
> =20
> +/*
> + * setkey can allocate while profile->lock is held, and reclaim takes th=
at lock
> + * to evict a key.  Use NOIO so those allocations can't recurse into the=
 fs.
> + */
>  static void blk_crypto_fallback_evict_keyslot(unsigned int slot)
>  {
>  	struct blk_crypto_fallback_keyslot *slotp =3D &blk_crypto_keyslots[slot=
];

[Severity: High]
This problem wasn't introduced by this patch, but can setting the
num_keyslots module parameter to 0 cause an out-of-bounds read here and a
NULL pointer dereference in blk_crypto_keyslot_index() [1]?

When profile->num_slots is 0, __blk_crypto_evict_key() invokes
keyslot_evict() with slot set to -1, which blk_crypto_fallback_evict_keyslo=
t()
uses as an unsigned index into the zero-length blk_crypto_keyslots[] array:

block/blk-crypto-profile.c:__blk_crypto_evict_key() {
	if (profile->num_slots =3D=3D 0) {
		if (profile->ll_ops.keyslot_evict) {
			blk_crypto_hw_enter(profile);
			err =3D profile->ll_ops.keyslot_evict(profile, key, -1);
			blk_crypto_hw_exit(profile);
			return err;
		}
		return 0;
	}
}

Similarly, during encryption with num_slots =3D=3D 0, blk_crypto_get_keyslo=
t()
returns BLK_STS_OK with *slot_ptr =3D NULL, and
blk_crypto_fallback_encrypt_bio() -> blk_crypto_fallback_tfm() ->
blk_crypto_keyslot_index() dereferences slot->profile.

[1] https://sashiko.dev/#/bug/linux-3e1346dd-cfa2-4a1f-89e7-2cad97d10dce

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261122213120.2097=
4-1-laveeshb@laveeshbansal.com?part=3D1
