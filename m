Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0E93E3ACF0B
	for <linux-fscrypt@vger.kernel.org>; Tue, 13 Oct 2026 10:13:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791886391; cv=none; b=GQJvJ6pFQ0t6DfEuVGXgU/iY3Q2+rilO+oZoPGATPm3HUDXZcpDt+9Jdm+PzzKI/+EQPLBt0CWqYC0qqoc192gxNLhVAcHiBsavhpFGscVx7GJTEaKqjE4ymC9R0wTmxavQoropa2Z+MeccBXgsX2Dk1Pk2ADi9UqIcpIXL2+jw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791886391; c=relaxed/simple;
	bh=+t58SXps7GznBDHd5aTkXOHAPRtPL4AgF9lXLvWCfzI=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=ILnqEWwd6bt/6GMoEBVOXD+a0ewTx+u264jLI1OOER4zN6AUS3kN/Cqnlu5ygIBhyysyVNKR60PISYTQc/HEWkCYEIRvssHI4H1kqQDvaYVCc2M/Ss4yzF65wZ1oUHBzmYFad7uBxOv0ZwOg8Fc9QXJG0VuE8/czhNPXyXGUlts=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HXN7T5Qo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HXN7T5Qo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 41BCB1F000FF;
	Tue, 13 Oct 2026 10:13:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791886389;
	bh=qBSZWnSqh9q/0tn+NsaXLEizHD5C0CqQx7aMmb/1Es4=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=HXN7T5QoHJE5ftJ1YydJ35SB/Z1wKG/W0WpkgSOEW9ogNaaqxnNkKFnwlY9M+1IQ7
	 en3/ceDJVu8FncNkX88WrvWx2EGLOZYhV1I0tu1eN6BYLxs6wCMzus1pxDz8etYKBR
	 v3c8mGqIMqQpkN5cx9Tc6joVflm6mccnPMj9hnex5HWsmvquBWgrJkhpfN6o2X9ITm
	 xZvBW6k46j/IwgHCazl09Ex2H+VENfvPNiwvvCGQGcrzGttLSWa24DAVlI0PmXCH9L
	 mLZA7mSkTxjS21XLjSXnSBDDVmnU3DbrxvQrn5ExNyn1r1UW6ciTHsX/KluwqnYJsD
	 lGy214mQ7VZYg==
Message-ID: <sashiko-outbox-169471@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH] blk-crypto: fix NULL deref and UAF in
 __blk_crypto_evict_key()
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>, axboe@kernel.dk
Cc: ebiggers@kernel.org, linux-fscrypt@vger.kernel.org, hch@lst.de, bvanassche@acm.org, mpatocka@redhat.com, linlin.zhang@oss.qualcomm.com
In-Reply-To: <20261013095106.881914-1-libaokun@linux.alibaba.com>
References: <20261013095106.881914-1-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Tue, 13 Oct 2026 10:13:08 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

Thank you for your contribution! Sashiko AI review found 1 potential issue(=
s) to consider:
- [High] block: concurrent UAF in __blk_crypto_evict_key() via lockless glo=
bal read
--

commit e07e1c7433e60b079101f4843a8706bcb93632f8
Author: Baokun Li <libaokun@linux.alibaba.com>
blk-crypto: fix NULL deref and UAF in __blk_crypto_evict_key()

This patch attempts to resolve a NULL pointer dereference and a
use-after-free by checking for a NULL profile in __blk_crypto_evict_key()
and clearing the fallback profile pointer after freeing it on the error
path.

Closes: https://patch.msgid.link/sashiko-outbox-167341@kernel.org

> diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
> index 2a8f40a65158b..b7890ee1951c7 100644
> --- a/block/blk-crypto-fallback.c
> +++ b/block/blk-crypto-fallback.c
[ ... ]
> @@ -605,6 +605,7 @@ static int blk_crypto_fallback_init(void)
>  	blk_crypto_profile_destroy(blk_crypto_fallback_profile);
>  fail_free_profile:
>  	kfree(blk_crypto_fallback_profile);
> +	blk_crypto_fallback_profile =3D NULL;

[Severity: High]
Does this change leave a concurrent use-after-free window open?

In blk_crypto_fallback_init(), the global pointer is published before
initialization is complete:

    blk_crypto_fallback_profile =3D kzalloc_obj(*blk_crypto_fallback_profil=
e);

If another thread concurrently executes blk_crypto_fallback_evict_key(),
it can locklessly read the global blk_crypto_fallback_profile. If the
initialization thread encounters an error and frees the profile:

    kfree(blk_crypto_fallback_profile);

Could the evicting thread end up reading the pointer before the kfree()
occurs and subsequently dereferencing the freed memory? Setting the pointer
to NULL after it is freed might not prevent a data race if the pointer was
already copied by the evicting thread.

>  fail_free_bioset:
>  	bioset_exit(&enc_bio_set);
>  out:
> diff --git a/block/blk-crypto-profile.c b/block/blk-crypto-profile.c
> index 53126c091b0be..1c5feca3b856a 100644
> --- a/block/blk-crypto-profile.c
> +++ b/block/blk-crypto-profile.c
> @@ -346,6 +346,9 @@ int __blk_crypto_evict_key(struct blk_crypto_profile =
*profile,
>  	struct blk_crypto_keyslot *slot;
>  	int err;
> =20
> +	if (!profile)
> +		return 0;
> +
>  	if (profile->num_slots =3D=3D 0) {

[Severity: High]
Because the profile pointer is passed in after being read locklessly by the
caller, could this pointer still point to freed memory if the initialization
thread freed it concurrently?

If so, the new NULL check would be bypassed, and reading profile->num_slots
would trigger a use-after-free.

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261013095106.8819=
14-1-libaokun@linux.alibaba.com?part=3D1
