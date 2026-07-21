Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE6244CA26E;
	Tue, 21 Jul 2026 15:08:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784646484; cv=none; b=NpaoB5o5vZr3LEB5NjtZo21VwuMtHR9KGJ46VYNzwIHnMHqJiotFXCbM+svKJAhjOmCZVCYgGcWFip30W6gDpF5fF68boJGdzd7G8rmKDBc2sXpRLtACaa9DgAjmkmhqt4DzLESXpWB27XQ4RPPkCZDw8Hy7oisO7TJgU1LtveI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784646484; c=relaxed/simple;
	bh=HnKAo1UB6Hizrs80DZIvXd/+C/2ggCPfNmCMS/YRiLo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=TyXFkkncrMYetpoDpD6mK71d73HrGs1jVTjeNJJyTDAnzGeoqTlPMAj+YX8e/B3GeM71+dkGs4Das85fN5J0aKZ8KCgkCD2tPFG7zhYjJ92yJ8n06aktPzP4SO7phbdAVkWLpy9pJrhd+Zrl6jigc/7sKUAhIqCMNotPSo0FQwc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cZNO1DWF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cZNO1DWF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 059ED1F000E9;
	Tue, 21 Jul 2026 15:08:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784646482;
	bh=vDGDymem0VUfP+jqOIxAVTQPMbJkKt9Jjw02N2puQ/I=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=cZNO1DWFHSlc5dUYPLLXxXoihBSMDKyfEILKNnFwSm6iNuLrFKIXKql255HXJJT1T
	 aOK6oBiM3eW4lVRqW6P323bmQCHyPT/j1mBNk48ko3aLTwlQUcsD4tdZMlhxDoqh0l
	 3PNtXzakqreTpOMsPa70GWLHYpX8FYXb8iRFILpetH7VgTg0yPPVCXx4bio/LwQFpz
	 d9lkyOFVzgQbtyrLohgj2r+VvU0ep2KLCcQCob09TPL4cAmaZjSsuL8hQO4CdsQ+c7
	 ptJBhikRfHfv16Hrl1+jE8zuGudIS+2dK/gHiMAgDN7W9DJLrUS5N06UmmbdFE9HXs
	 sCwmXs/0cN+Cw==
Date: Tue, 21 Jul 2026 08:06:14 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Marco Baffo <marco@mandelbit.com>
Cc: linux-crypto@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, Jason@zx2c4.com, ardb@kernel.org,
	tytso@mit.edu, jaegeuk@kernel.org, linux-fscrypt@vger.kernel.org,
	kbusch@kernel.org, axboe@kernel.dk, hch@lst.de, sagi@grimberg.me,
	hare@suse.de, linux-nvme@lists.infradead.org, andrew+netdev@lunn.ch,
	edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
	antonio@openvpn.net, sd@queasysnail.net,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/5] lib/crypto: add HKDF and convert fscrypt and NVMe
Message-ID: <20260721150614.GA1932@sol>
References: <20260721140644.780006-1-marco@mandelbit.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260721140644.780006-1-marco@mandelbit.com>

Hi Marco,

On Tue, Jul 21, 2026 at 04:06:39PM +0200, Marco Baffo wrote:
> fscrypt and NVMe authentication each carry private HKDF
> implementations. Add HKDF-SHA256, HKDF-SHA384, and HKDF-SHA512
> functions to lib/crypto and convert both users.
> 
> Patches 1-4 are intended for review and inclusion.
> 
> Patch 5 is RFC only and is not intended to be applied. It shows how
> the OVPN epoch-key code currently under development can use the new
> HKDF API. That patch has an additional dependency on the OVPN epoch
> series. It is included here to allow the API to be reviewed against
> a third user. The OVPN conversion will be submitted separately once
> its prerequisite code is ready.
> 
> HKDF-Expand accepts info as an array of segments and processes them as
> if concatenated. This preserves the byte ordering used by fscrypt and
> allows NVMe to encode HkdfLabel without allocating a temporary buffer.
> 
> HKDF-Extract produces a prepared HMAC key, avoiding repeated key setup
> when the same PRK is expanded more than once. The implementation uses
> the direct HMAC library functions and neither allocates memory nor
> returns errors.
> 
> The series is intended for the libcrypto tree. Patches 3 and 4 need
> review from the fscrypt and NVMe maintainers, respectively.
> 
> Tested with:
> 
> - HKDF KUnit tests
> - NVMe authentication KUnit tests
> - kvm-xfstests smoketest on ext4
> - kvm-xfstests generic/582, generic/583, and generic/584 on ext4 and f2fs
> - kvm-xfstests encrypt group on ext4 and f2fs
> 
> The following shortlog and diffstat refers only to the first 4 patches.
> 
> Marco Baffo (4):
>   lib/crypto: add HKDF-SHA{256,384,512}
>   lib/crypto: tests: add HKDF KUnit tests
>   fscrypt: use HKDF library functions
>   nvme-auth: use HKDF library functions for TLS PSK derivation
> 
>  drivers/nvme/common/auth.c    | 120 ++++++++-------
>  fs/crypto/hkdf.c              |  56 ++-----
>  include/crypto/hkdf.h         | 131 ++++++++++++++++
>  lib/crypto/.kunitconfig       |   1 +
>  lib/crypto/Makefile           |   4 +-
>  lib/crypto/hkdf-sha256.c      |  22 +++
>  lib/crypto/hkdf-sha512.c      |  34 +++++
>  lib/crypto/hkdf-template.h    |  97 ++++++++++++
>  lib/crypto/tests/Kconfig      |   8 +
>  lib/crypto/tests/Makefile     |   1 +
>  lib/crypto/tests/hkdf_kunit.c | 276 ++++++++++++++++++++++++++++++++++
>  11 files changed, 653 insertions(+), 97 deletions(-)
>  create mode 100644 include/crypto/hkdf.h
>  create mode 100644 lib/crypto/hkdf-sha256.c
>  create mode 100644 lib/crypto/hkdf-sha512.c
>  create mode 100644 lib/crypto/hkdf-template.h
>  create mode 100644 lib/crypto/tests/hkdf_kunit.c

If we're going to reintroduce an HKDF library, this is probably the way
to do it (no crypto_shash dependency).

But I think the positive diffstat makes having an HKDF library at all in
the kernel still kind of questionable.  HKDF is just a wrapper around
HMAC and it can "unroll" to as little as 1-2 HMAC calls.  It's not
really like the other crypto algorithms where the implementations can be
very complex and we often have multiple arch-specific implementations.

In drivers/nvme/common/auth.c, using the library actually ended up as
more code than not using it.

And in fs/crypto/hkdf.c this patchset only saves a bit (with some of the
savings coming from deleting helpful comments).

In the ovpn case, the extraction step isn't actually used.  Nor are
multiple expansion iterations needed, since all the keys needing to be
derived are at most the hash size.  So vs. using hmac_sha256_* directly
it saves maybe 10-15 lines?  (Note that the diffstat in patch 5 isn't
directly relevant, as the starting point was crypto_shash.)

So then we end up with quite a bit of additional code in lib/crypto/, to
support users where the diffstat is basically neutral.

And this is only HKDF, so this hardly solves key derivation in general.
Plenty of KDFs don't use HKDF at all, either ones based on block ciphers
or stream ciphers, or newer hash functions that aren't vulnerable to
length extension attacks so don't require the HMAC layer.  There are
lots of other KDFs implemented in the kernel in various places.  Just to
pick a couple random examples, extract_entropy() in
drivers/char/random.c is doing a KDF, tcp_ao_calc_traffic_key() in
net/ipv4/tcp_ao.c is doing a KDF.  Do those need to be libraries too?

So overall I would suggest it might be best to hold off on this for now
and just call the hmac_sha256_* functions directly from
ovpn_expand_label().  (And again, only one iteration is actually needed
there, so it doesn't even need to be the full HKDF-Expand.)

- Eric
