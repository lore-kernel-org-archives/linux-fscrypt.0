Received: from mout-b-107.mailbox.org (mout-b-107.mailbox.org [195.10.208.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 027F0388397;
	Tue,  4 Aug 2026 09:25:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.10.208.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785835505; cv=none; b=DpB+Qqm6/JDKGZSgy4o1y4atLujsKxpMAGTChAweMF8pQuiG7A8ldso24kCFozDRb2CxtZ4bU9SLejaevy2n71rUuk11YO71EOFhpl4JDMNW2dYVk9TFOe1nYu+MlBrWGj+LKnyMhiLT0m35v2HzzJ7NKq9/CG/Sdl0s89ejex8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785835505; c=relaxed/simple;
	bh=UQDas1bH0edIUUuJM7WV+CCl9mwU0pTZxv9ZaeXtP5M=;
	h=Date:From:To:Cc:Message-ID:In-Reply-To:References:Subject:
	 MIME-Version:Content-Type; b=MTOn6LHiVPV02K1jL3JUbzt6fz9/OvI8cNVvIoB/+RtvIJwHaziPrzfm9WINYnMvIQPVtnu/Rb3uVRA1kYeqtnma2PH/JTvARiE1LJIWQULV7eL25NIU68weMZYnlknyyUObWNfHeLJmqFOdo+5mTwOURcIHo2RjbWDDvYiGKjg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=mandelbit.com; spf=pass smtp.mailfrom=mandelbit.com; dkim=pass (2048-bit key) header.d=mandelbit.com header.i=@mandelbit.com header.b=KggRqVaf; arc=none smtp.client-ip=195.10.208.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=mandelbit.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mandelbit.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=mandelbit.com header.i=@mandelbit.com header.b="KggRqVaf"
Received: from smtp202.mailbox.org (smtp202.mailbox.org [10.196.197.202])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange x25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-b-107.mailbox.org (Postfix) with ESMTPS id 4hDnwx6Jghz3xxL;
	Tue, 04 Aug 2026 11:16:49 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mandelbit.com;
	s=MBO0001; t=1785835009;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EesaN+w9OeC7jN85hlTnvT94IZFYcOPLiqCpaYTwXQE=;
	b=KggRqVaf/1ux5mOisg7yXZzz7Sg7UGiy415Lt3kI6qn0Mu2qG6Vo35iIn4nDqALvdsyxQD
	VHYe7csJJfyFIFKQQEDWTbMo4+ohwYIDaITONcvy8mjamTgi69wBSUvv+5yNJKdANS2r/7
	SW5qaDRaHAuBGUX0wDkJM65gs62L9p0gVr6D0UFSwCvyBGjtlyfCpQhGUZfWj0/tJtCzEP
	8W1ZQBKPwqxtvE4OydMGGhitUVEhuZ0n+nAMrvDAlhesOSESsHKvPu/pSCx+imrC46qcec
	DUDje/diV3tEZ4u05e2zNymiMwxwbypdce55d/ZPL7vz0XVD05QtkBnsCV9VNg==
Date: Tue, 4 Aug 2026 11:16:39 +0200 (CEST)
From: Marco Baffo <marco@mandelbit.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-crypto@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, Jason@zx2c4.com, ardb@kernel.org, tytso@mit.edu,
	jaegeuk@kernel.org, linux-fscrypt@vger.kernel.org, kbusch@kernel.org,
	axboe@kernel.dk, hch@lst.de, sagi@grimberg.me, hare@suse.de,
	linux-nvme@lists.infradead.org, andrew+netdev@lunn.ch,
	edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
	antonio@openvpn.net, sd@queasysnail.net,
	linux-kernel@vger.kernel.org
Message-ID: <1784680780.63324.1785834999388@app.mailbox.org>
In-Reply-To: <20260721150614.GA1932@sol>
References: <20260721140644.780006-1-marco@mandelbit.com>
 <20260721150614.GA1932@sol>
Subject: Re: [PATCH 0/5] lib/crypto: add HKDF and convert fscrypt and NVMe
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Priority: 3
Importance: Normal

Thanks for the detailed explanation, and sorry for the slow reply.

I see your point now, and I agree that adding a generic HKDF implementation=
 probably would not buy us much here.
I can still see some value in having a shared, well-tested implementation, =
but I agree it=E2=80=99s probably not worth it in this case.

Thanks again for taking the time to review this.

> On 07/21/2026 5:06 PM CEST Eric Biggers <ebiggers@kernel.org> wrote:
>=20
> =20
> Hi Marco,
>=20
> On Tue, Jul 21, 2026 at 04:06:39PM +0200, Marco Baffo wrote:
> > fscrypt and NVMe authentication each carry private HKDF
> > implementations. Add HKDF-SHA256, HKDF-SHA384, and HKDF-SHA512
> > functions to lib/crypto and convert both users.
> >=20
> > Patches 1-4 are intended for review and inclusion.
> >=20
> > Patch 5 is RFC only and is not intended to be applied. It shows how
> > the OVPN epoch-key code currently under development can use the new
> > HKDF API. That patch has an additional dependency on the OVPN epoch
> > series. It is included here to allow the API to be reviewed against
> > a third user. The OVPN conversion will be submitted separately once
> > its prerequisite code is ready.
> >=20
> > HKDF-Expand accepts info as an array of segments and processes them as
> > if concatenated. This preserves the byte ordering used by fscrypt and
> > allows NVMe to encode HkdfLabel without allocating a temporary buffer.
> >=20
> > HKDF-Extract produces a prepared HMAC key, avoiding repeated key setup
> > when the same PRK is expanded more than once. The implementation uses
> > the direct HMAC library functions and neither allocates memory nor
> > returns errors.
> >=20
> > The series is intended for the libcrypto tree. Patches 3 and 4 need
> > review from the fscrypt and NVMe maintainers, respectively.
> >=20
> > Tested with:
> >=20
> > - HKDF KUnit tests
> > - NVMe authentication KUnit tests
> > - kvm-xfstests smoketest on ext4
> > - kvm-xfstests generic/582, generic/583, and generic/584 on ext4 and f2=
fs
> > - kvm-xfstests encrypt group on ext4 and f2fs
> >=20
> > The following shortlog and diffstat refers only to the first 4 patches.
> >=20
> > Marco Baffo (4):
> >   lib/crypto: add HKDF-SHA{256,384,512}
> >   lib/crypto: tests: add HKDF KUnit tests
> >   fscrypt: use HKDF library functions
> >   nvme-auth: use HKDF library functions for TLS PSK derivation
> >=20
> >  drivers/nvme/common/auth.c    | 120 ++++++++-------
> >  fs/crypto/hkdf.c              |  56 ++-----
> >  include/crypto/hkdf.h         | 131 ++++++++++++++++
> >  lib/crypto/.kunitconfig       |   1 +
> >  lib/crypto/Makefile           |   4 +-
> >  lib/crypto/hkdf-sha256.c      |  22 +++
> >  lib/crypto/hkdf-sha512.c      |  34 +++++
> >  lib/crypto/hkdf-template.h    |  97 ++++++++++++
> >  lib/crypto/tests/Kconfig      |   8 +
> >  lib/crypto/tests/Makefile     |   1 +
> >  lib/crypto/tests/hkdf_kunit.c | 276 ++++++++++++++++++++++++++++++++++
> >  11 files changed, 653 insertions(+), 97 deletions(-)
> >  create mode 100644 include/crypto/hkdf.h
> >  create mode 100644 lib/crypto/hkdf-sha256.c
> >  create mode 100644 lib/crypto/hkdf-sha512.c
> >  create mode 100644 lib/crypto/hkdf-template.h
> >  create mode 100644 lib/crypto/tests/hkdf_kunit.c
>=20
> If we're going to reintroduce an HKDF library, this is probably the way
> to do it (no crypto_shash dependency).
>=20
> But I think the positive diffstat makes having an HKDF library at all in
> the kernel still kind of questionable.  HKDF is just a wrapper around
> HMAC and it can "unroll" to as little as 1-2 HMAC calls.  It's not
> really like the other crypto algorithms where the implementations can be
> very complex and we often have multiple arch-specific implementations.
>=20
> In drivers/nvme/common/auth.c, using the library actually ended up as
> more code than not using it.
>=20
> And in fs/crypto/hkdf.c this patchset only saves a bit (with some of the
> savings coming from deleting helpful comments).
>=20
> In the ovpn case, the extraction step isn't actually used.  Nor are
> multiple expansion iterations needed, since all the keys needing to be
> derived are at most the hash size.  So vs. using hmac_sha256_* directly
> it saves maybe 10-15 lines?  (Note that the diffstat in patch 5 isn't
> directly relevant, as the starting point was crypto_shash.)
>=20
> So then we end up with quite a bit of additional code in lib/crypto/, to
> support users where the diffstat is basically neutral.
>=20
> And this is only HKDF, so this hardly solves key derivation in general.
> Plenty of KDFs don't use HKDF at all, either ones based on block ciphers
> or stream ciphers, or newer hash functions that aren't vulnerable to
> length extension attacks so don't require the HMAC layer.  There are
> lots of other KDFs implemented in the kernel in various places.  Just to
> pick a couple random examples, extract_entropy() in
> drivers/char/random.c is doing a KDF, tcp_ao_calc_traffic_key() in
> net/ipv4/tcp_ao.c is doing a KDF.  Do those need to be libraries too?
>=20
> So overall I would suggest it might be best to hold off on this for now
> and just call the hmac_sha256_* functions directly from
> ovpn_expand_label().  (And again, only one iteration is actually needed
> there, so it doesn't even need to be the full HKDF-Expand.)
>=20
> - Eric
