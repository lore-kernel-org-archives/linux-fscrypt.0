Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44F963AEF3A;
	Fri, 18 Sep 2026 02:22:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789698162; cv=none; b=QdRXAL1soE6dAT7dkA0E0/mhR5W1+enEh7pFPWOlmmPk6dktv0w2AtkoHJi+Fb+RIvR+3397VyYHjuX8eQ41/m1FuzXWPhtK8NXqqd/6rMr9gEaRSXkLLBmc6DbCV5B+0z4V3ncztkceJQgjIg2ystiiPJPSWoDrnqggLAst+1M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789698162; c=relaxed/simple;
	bh=Ep6O95+gdYUjNp8kjamyrzF44y1Pkd+E2Ueag5MVFgk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pUfO8bI3iXrT/O5mP2W6mCes+8yHDCVS94jzXRcsW+puynBHEc8EUdMKinTdi/Ym4HAqJwtOFMvxbVSZqIvzzepxjZ5t9VQQA3+o9fgAri+3ad/5Q9StA46+mykrkjcq2PqQLz7j2dE2DzQwZL/PZ8iWkHl2tHe4bEHsSWOYoeU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MG5NPjMz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MG5NPjMz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 703CA1F000FF;
	Fri, 18 Sep 2026 02:22:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789698148;
	bh=mhZqdanDOkFUucjSAGbEqLNZn6/bNs6d3aNen4B8Iwg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=MG5NPjMz+V95lo7f/KgQHomjMX8Qc2jSnYLiIR9qRDuJ+Fjs1ofz9PJnt29+PQ77v
	 pVC4oecWLphqaVZFwEj7wogCU31LTKbK0FPaL/yd9zl5mQ0WRp1n9UC5IpYeuxx+ni
	 s1XjE3WIOwAUcjFEjdgWflKOhBDc6dOnw/vzdmfkGIYQowBZ+uHutuBQl3DbQl+SPr
	 egZu5W/MwZ2n2J/+3dpNZcoF5H9AE+8zijlPrEoo6U+IQrnMPI5lNTL05KuMARIiGv
	 lSBKAgAbPiCOP6gMaB4N/A+rbOEgdRnUJrtfiXVgnBBW/8I7sc0RfluRNJhqBgEkm4
	 0btL49OChrT+g==
Date: Thu, 17 Sep 2026 19:22:26 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Use aes_ecb_encrypt() for v1 key derivation
Message-ID: <20260918022226.GA1703@sol>
References: <20260831192411.99035-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260831192411.99035-1-ebiggers@kernel.org>

On Mon, Aug 31, 2026 at 12:24:11PM -0700, Eric Biggers wrote:
> Now that there's a library function aes_ecb_encrypt(), use it instead of
> a loop of aes_encrypt() calls.
> 
> Note that the use of AES-ECB here is purely for the key derivation
> function used by the deprecated v1 encryption policies.  v2 encryption
> policies use HKDF-SHA512 instead.  Nevertheless, the original version
> has to continue to be supported for backwards compatibility.
> 
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---
>  fs/crypto/Kconfig       | 2 +-
>  fs/crypto/keysetup_v1.c | 5 ++---
>  2 files changed, 3 insertions(+), 4 deletions(-)

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
