Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F043C480DC9;
	Mon, 20 Jul 2026 17:47:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784569639; cv=none; b=nzbkVPna+2HDWVcERvzGR0OBoRC+Q4ofKnuyA5+B239I0xoNbrewsDG1O86Svjh1mqqPi7UZWO6LlASCXlhdRQQem1f3wcEXickKU6djN6HR9PZbfpObQsAkx5/dPeYA9jfqVJFaRlr0FeTRBT0+m2AEdTUS1/8bkXHPMcWqqDE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784569639; c=relaxed/simple;
	bh=tnFOUKlsLAIm9KHugI6LqXaXtklkmWk4LQwjyaAjPZw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=hOVHWXuQJrH2haPacy2Rl0+e+qdCckekyByFqwpFAYBNfnmQxmG6gZ90pJY8ZQWq/w7pSOugOArTTLL7qaQBEqqRc6XEynGVo6hpWwrwnWDJaLjScYGnxbJzSF5+19D0+oeBttzH0KnOLDgtd7MT4GqDO3ZSNwYkg2qs5t2mfzg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dkrOE+HJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dkrOE+HJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 28F321F000E9;
	Mon, 20 Jul 2026 17:47:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784569628;
	bh=v1o/AWsWq2yk0qmKA9wRgJroB00SzogBKZlBH4NmK88=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=dkrOE+HJIpfSrychaJB5bkY2Z7sYMTAtwAYoAM8OmdSJU9sp73q9sE33yCvX06D0m
	 cvxl9D5sg/chSJIoWFmWHJ2/1GkH7wFEDYVswzP6I7KH0wxE5ZGsEc1irrhHIX5Xbc
	 1kRvd7ipefPA1sQgfujxxRT6tJQ27im16CJXy+Au6BBui/0d56rW1jjjGO/cxS+Vs1
	 cb4SwTLtHUoFdYDShob6s0tksMMtpcI1MJunJIaDzNlHAnXXcyvdNMlAopuXQWaE5+
	 aSnSg9xg8cym2E0P9W82ax1EUKUBzf7/7c0AkjP+vf+Vqaf/IzTC8xCfnykHrsSJ6/
	 8y/CMLa8SZKWA==
Date: Mon, 20 Jul 2026 10:47:06 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Replace some variable-size memsets with
 fixed-size
Message-ID: <20260720174706.GE1865@quark>
References: <20260718205606.50713-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260718205606.50713-1-ebiggers@kernel.org>

On Sat, Jul 18, 2026 at 01:56:06PM -0700, Eric Biggers wrote:
> For zeroing IVs and raw keys, remove the misguided optimization of
> zeroing the actual size used (typically 16 and 64 bytes respectively)
> instead of the max size (32 and 64 bytes respectively).  Using a
> compile-time constant size allows the compiler to specialize the memset
> for that size (typically by inlining a few 'mov' instructions), which
> is more important than zeroing a few extra bytes with these small sizes.
> 
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---
>  fs/crypto/crypto.c      | 2 +-
>  fs/crypto/keysetup.c    | 4 ++--
>  fs/crypto/keysetup_v1.c | 2 +-
>  3 files changed, 4 insertions(+), 4 deletions(-)

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
