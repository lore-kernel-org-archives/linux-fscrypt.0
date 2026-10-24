Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792865038;
	b=ccvlMpWA2+7PwPmz2vHKh5wy6E7VEFGgycl0YKXXYZh0HDVgBEUkb/FhZZlIoOl2F1ax
	 bUApOJkCEnOZTdNpZwOZQSAIN9IGJaX1XCMSEBJaJ+1/9cDpQUvXGnajzeO8OrJI/J7cP
	 xxXcDYxwjEhLL2XWgM8pgLcSB+X8irNZ2DW0eFjqrd9GFZz1ZqETN9vFZKKaAEPO+CGCb
	 qYsBfHB0T4fpIuu0I7CJvn0sc1xARTdWv9h5kmbOPaTTqDJh+StpCTob3gV0BxZXxtPkH
	 uYxZd+rM+MPHnkaVq7JVpth6BKYMWhJva6jWF1jb8qQw+Fl5HyGSFPK1p4KoUOzYoOg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792865038;
	h=Received:DKIM-Signature:Date:From:To:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=UbjdQSVoNnfL93HHovqwgLtdv55CtCWFyy2MB1oF6gg=;
	b=c5ZrSu6LXf6ccRM1XmNeZI+/Z/LTO3sQiDYpz7zyLABak6il55TyoPezLx8HJQL4jJ7C
	 mk1XojaNOdyJU+eX5D82B63fhg+Lnznz2JzNg4jJMTQglZAbpblwPjVmIChz0vzw4zlMd
	 Pk3wJSjhmPN6oFrX5xaOdYlu8aWENowPr5ftZkKgozV779tUZ0FLMljSChL93cyya7dCb
	 mQr2Gt/iIRoy0iGWnySpI2b7mwCl5a9rtubswR76HWpEjmDRMZuK7ctNuYxy2GLx5ZR/L
	 ZOEvcmDV7x5J3nRJtx07v74kbmKeUirVY48FKHQmZrZ70lOqOtAjkJoDUacu6XSB8aQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="d0/8yxEY";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2FC52606A31A
	for <linux-fscrypt@vger.kernel.org>; Sat, 24 Oct 2026 18:03:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=d0/8yxEY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9A08D1F01825
	for <linux-fscrypt@vger.kernel.org>; Sat, 24 Oct 2026 18:03:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792865037;
	bh=UbjdQSVoNnfL93HHovqwgLtdv55CtCWFyy2MB1oF6gg=;
	h=Date:From:To:Subject:References:In-Reply-To;
	b=d0/8yxEYtjFNw9U2Ok6FnS67UC8IodUzrTHLtoYUMfig+p9rtmOIjiq6+qNDkQZHF
	 NdY2+iuKf0I1+FpjHWhc9l1V17cb9cM0XtRr0M1mFYs4xW+dcvNb+iUECSp9cEXeqc
	 RdkPm8ctw5W2PcT2Q0PjuwzV+R1S2wZvOq3vHGetkii/uQ+fc9cgzk9yLvnxtZcCan
	 j4sBcgpB4ey8Zf817SkdM9K9ylQh0bOBCRCeRIMFzCyhK9hV/bf8mand/Ph8P0AFcD
	 DDAJCk/8K5ED0cCoJqQNR2mTUvLrEFnK+3N0NLiK6n76o17E9nfoGS1IvdfgQoWfH1
	 1/1B2Km9e9nNQ==
Date: Sat, 24 Oct 2026 11:03:56 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Explicitly zeroize sw_secret in error path
Message-ID: <20261024180356.GA2553@quark>
References: <20261021224431.2353673-1-ebiggers@kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261021224431.2353673-1-ebiggers@kernel.org>

On Wed, Oct 21, 2026 at 10:44:31PM +0000, Eric Biggers wrote:
> Explicitly zeroize the sw_secret array in the case where
> fscrypt_derive_sw_secret() fails, in case anything was written to it.
> Doesn't really matter, but this came up in a code review.
> 
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---
>  fs/crypto/keyring.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
