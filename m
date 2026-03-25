Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2522334A783;
	Wed, 25 Mar 2026 19:09:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774465762; cv=none; b=LRRNrJPEt520ICGM1p9qWpZAoJtarsk+w4osDDD3OC/sQtmjiH6c2j3EONdomobEihgI8g3TKAgk7nHoWwOmZXCHcHw/tXek9YV6ykLxtL4ku+k+A0aEqWE4yt5cxWfTHHwnzda49DQqZsM+X881i+zZ0BA1PDE1ruNbD9y3gYI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774465762; c=relaxed/simple;
	bh=JXH/6lcixmcdX5BNxk/kFsdew60ar6lkyEXqVOq5Gms=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=GrYoWHEmraus4jh65zlkfY9RNMMrR9wRa5zcUkr4xOZMXU0GicHSsn5bW/Ll4NB6HCNHoKjjJuqLecd3X7GGV8I5jaRqcxgjxrUPxlVUqM2+/ZmTfT+6ovLDfwCRRlaahO4WupKSTxIBTwgVDcZGPW9K5xPFTT01KaEoeMqjUHo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BiXtwqva; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BiXtwqva"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 71DD7C19423;
	Wed, 25 Mar 2026 19:09:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1774465761;
	bh=JXH/6lcixmcdX5BNxk/kFsdew60ar6lkyEXqVOq5Gms=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=BiXtwqvaZZ2MRdJw638zobRjGtZw5mdMDM0eqVUfucIa5VaQubSxtd7vyQaUbPgNR
	 EchhKUMJDcQzCfpn9PYhMpF226m5UoLw+OEw4uJ9L+qiT7zCGPff3p/tKEEyfIKPJv
	 oSIRAUUN4thTy3kNVbKsUufUxWNm0WZr/5vl0fe+ChApyUIojCGUS6aH4g8ZXC3qEQ
	 KNAe0PBE8k6YKPAtciCsgAeq5qIIWPt8H5jSlk+zqEXGJ6fNqhIWw3PXyJ/cwaJovi
	 vZPfccNOU3eVhwEHsVw6WZv4lZ7Xh6jdCQ4aQsU7QAqpQd8mF874w/LEVcs+/q3+Wd
	 lNQQAUYwCiJYA==
Date: Wed, 25 Mar 2026 12:09:19 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Theodore Y . Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [PATCH] fscrypt: use AES library for v1 key derivation
Message-ID: <20260325190919.GA2305@quark>
References: <20260321075338.99809-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260321075338.99809-1-ebiggers@kernel.org>

On Sat, Mar 21, 2026 at 12:53:38AM -0700, Eric Biggers wrote:
> Convert the implementation of the v1 (original / deprecated) fscrypt
> per-file key derivation algorithm to use the AES library instead of an
> "ecb(aes)" crypto_skcipher.  This is much simpler.
> 
> While the AES library doesn't support AES-ECB directly yet, we can still
> simply call aes_encrypt() in a loop.  While that doesn't explicitly
> parallelize the AES encryptions, it doesn't really matter in this case,
> where a new key is used each time and only 16 to 64 bytes are encrypted.
> 
> In fact, a quick benchmark (AMD Ryzen 9 9950X) shows that this commit
> actually greatly improves performance, from ~7000 cycles per key derived
> to ~1500.  The times don't differ much between 32 bytes and 64 bytes
> either, so clearly the bottleneck is API stuff and key expansion.
> 
> Granted, performance of the v1 key derivation is no longer very
> relevant: most users have moved onto v2 encryption policies.  The v2 key
> derivation uses HKDF-SHA512 (which is ~3500 cycles on the same CPU).
> 
> Still, it's nice that the simpler solution is much faster as well.
> 
> Compatibility verified with xfstests generic/548.
> 
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---
> 
> This patch is targeting fscrypt/for-next
> 
>  fs/crypto/Kconfig       |  2 +-
>  fs/crypto/keysetup_v1.c | 87 +++++++++++++----------------------------
>  2 files changed, 29 insertions(+), 60 deletions(-)

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
