Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C4B463264E0;
	Sun, 11 Oct 2026 17:20:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739242; cv=none; b=HHcgp1CZ68MmbErMiaPaDPoXcNmoEj7QSh6JAqhZulvjlkiZ8mG4DcWdopUzYNtiipIcB8aZsUmgVcp3KLBXCmetEnR8DIKEd2gly6+RAg3DYskCnjniETnz/N7VQI4GJPbYcg6CPOYZMGdUL32jr7VYLhbuzTaeOsZY+dD/W/c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739242; c=relaxed/simple;
	bh=cECy2f3R+QC4k7AcbZ3rJfRyBAtLEtjH+ZDYsrKzmyM=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=GTwjRDFBpru/eHhUm+lC5lJX24d7qJbWRJNu7gKcH5JJLNe6wocUnZlf3vGR+KEGor+zj0+X8ceCqMVS3bV1a3cvlGc5i8bvfh+8A+oMf41ScPjNfoqmlgmBeQ+yywTUwLpeyZ6xs0JEd/hAfym8pyw1PoUIJakuVSTY7ioxjBg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Tu4c1Xh3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Tu4c1Xh3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 363FF1F0089B;
	Sun, 11 Oct 2026 17:20:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739241;
	bh=Ac6fOVmjsZ1AlUnhWFZiz83ODUBzHgfK1N+ESdH/LSk=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=Tu4c1Xh3t2g1OfI/+KpkT5O8k0vz5NP/ZA36vzmSDMAO2VKHt/440lNysgmWmDsTQ
	 J2YGjvNgHGykHSpTMFC2bbAeNgAvcvdliAbw9ND5x+0vo8ZPGBaLiFqZFG8YGwFsDV
	 VexJPNfqk7sfZ7dalGcg6oysKKR1jAT5qE2tA+qIWf460+tJcTUItV2ZPdRy/iJKuF
	 8cMsOvm7Ie2dLF4dCQ7Jnq8hCKYY1/Qwnbxx/+qa+tzTqetkMUlpEmA8h3C2nl3xYV
	 VOyEN86HflUFh28bcjLi8gaoj7WB0/kR0Kz4gAtgrkPEM/ven82MoEs7ePQhRgKSbf
	 HRnN7lLTn4rgA==
Message-ID: <sashiko-outbox-167341@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 03/13] blk-crypto: reject fallback data unit sizes it
 can't handle
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org, tytso@mit.edu
In-Reply-To: <20261011170958.1759230-4-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-4-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:20:40 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

Thank you for your contribution! Sashiko AI review found 1 potential issue(=
s) to consider:
- [High] block: NULL pointer deref in blk_crypto_fallback_evict_key() on se=
tup failure
--

commit 9e7475fafabf0ae30868c1ceef29977b6846a713
Author: Baokun Li <libaokun@linux.alibaba.com>

    blk-crypto: reject fallback data unit sizes it can't handle

This patch restricts the data unit sizes advertised by blk-crypto-fallback
to only those it actually supports. It also rejects unsupported data unit
sizes early when setting up the key, preventing failures during I/O.

> diff --git a/block/blk-crypto-fallback.c b/block/blk-crypto-fallback.c
> index 2a8f40a65158b..a75daadba4c86 100644
> --- a/block/blk-crypto-fallback.c
> +++ b/block/blk-crypto-fallback.c

[ ... ]

> @@ -612,16 +616,24 @@ static int blk_crypto_fallback_init(void)
>  }
> =20
>  /*
> - * Prepare blk-crypto-fallback for the specified crypto mode.
> - * Returns -ENOPKG if the needed crypto API support is missing.
> + * Prepare blk-crypto-fallback for the specified crypto configuration.
> + * Returns -EOPNOTSUPP if the fallback can't handle the data unit size o=
f the
> + * configuration, or -ENOPKG if the needed crypto API support is missing.
>   */
> -int blk_crypto_fallback_start_using_mode(enum blk_crypto_mode_num mode_n=
um)
> +int blk_crypto_fallback_start_using_key(const struct blk_crypto_config *=
cfg)
>  {
> +	enum blk_crypto_mode_num mode_num =3D cfg->crypto_mode;
>  	const char *cipher_str =3D blk_crypto_modes[mode_num].cipher_str;
>  	struct blk_crypto_fallback_keyslot *slotp;
>  	unsigned int i;
>  	int err =3D 0;
> =20
> +	if (!(BLK_CRYPTO_FALLBACK_DU_MASK & cfg->data_unit_size)) {
> +		pr_warn_ratelimited("can't handle data unit size %u\n",
> +				    cfg->data_unit_size);
> +		return -EOPNOTSUPP;
> +	}
> +

[Severity: High]
Does this early return bypass blk_crypto_fallback_init() and leave
blk_crypto_fallback_profile as NULL?

If this is the first fallback usage, returning here means we haven't
initialized the profile. If downstream callers (like dm-inlinecrypt) handle
this -EOPNOTSUPP error by attempting to evict the partially initialized key,
can it lead to a NULL pointer dereference?

When target teardown calls blk_crypto_evict_key(), it will eventually call
blk_crypto_fallback_evict_key(), which passes the uninitialized profile
directly:

block/blk-crypto-fallback.c:blk_crypto_fallback_evict_key() {
	return __blk_crypto_evict_key(blk_crypto_fallback_profile, key);
}

This unvalidated profile pointer is then dereferenced when checking the num=
ber
of slots:

block/blk-crypto-profile.c:__blk_crypto_evict_key() {
	...
	if (profile->num_slots =3D=3D 0) {
	...
}

Could this cause a kernel panic if a user with device mapper access requests
an unsupported data unit size?

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D3
