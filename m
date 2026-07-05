Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECF77282F22;
	Sun,  5 Jul 2026 19:12:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783278721; cv=none; b=rlpvStokIMEwntFNKOmIdPZooXtkDpJfrUQgvXIlgA8h4lnhDhnr2FTaDdAmDEg2StRn502CmjVQYw2RZsXmbGJgRvb+YuwXnm4DyKbXeG9+xWs27RIAO7RSfkEzFARWfcDHMba5uk5qLjeUziMw453ILA2A8+Rm34+TjiExIzg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783278721; c=relaxed/simple;
	bh=J7wja1x9Ul4RMHMlhAGP9WesqMOVW1jNxlGWK6epGl8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=DTRKvNriMSHsMk0EYeJe0H02t2FETr1aSsYwZFH0PqBiPscD3kpOi6jq0Wtcd1cBdBm+1o3O+BKkHu4csjzsFxmPLup/SDf+zGhndfjas5PHG5E30rcgJRkrbKh/tnXBqbDb3lCN8FfgbHy1NRRcuguQ75J5KxhNb2ZF4ejh52s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EdskQUxY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EdskQUxY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 704221F000E9;
	Sun,  5 Jul 2026 19:12:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783278720;
	bh=LTk5iUV0OWVtBMUNbbzZOyKxgV9pJyKjfwngZtvnon4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=EdskQUxYG/B/Zm2hzgKXXf/uWPNDF2g70EL0UVmkUQX12EXoQJBUv6UzJ5A+UxSIi
	 2nGeY4G9yoBxSO+1PiZ5r/vzBXLeGDUCj2O8Q1GUTPtwxiDwjJbzUHemGcbAUa16wz
	 5X+MAeeC5m+vJP+hCYJTa/G36yJ8pvxs88eYHED0Sbzmp6+Gxmu2n/eByZcmROQ3tE
	 qCER2rF39boX4Djf3cnbEo/zZ5RCP6qcSDWoGXG5uzQjO4WlPNpXhGIM/TnTCUXrx0
	 Rq8MrAvDpwGgy4zVJuBXF4skdQ4R2Ufd2M55vYzJZ2lrbNfnM9tFIAK3EQtCfSm3dM
	 B0q/No6urPBUA==
Date: Sun, 5 Jul 2026 12:11:58 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Simplify handling of errors during initcall
Message-ID: <20260705191158.GC41916@quark>
References: <20260619000030.166851-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260619000030.166851-1-ebiggers@kernel.org>

On Thu, Jun 18, 2026 at 05:00:30PM -0700, Eric Biggers wrote:
> Since CONFIG_FS_ENCRYPTION is a bool, not a tristate, fs/crypto/ can
> only be builtin or absent entirely; it can't be a loadable module.
> Therefore, the error code that gets returned from the fscrypt_init()
> initcall is never used.  If any part of the initcall does fail, which
> should never happen, the kernel will be left in a bad state.
> 
> Following the usual convention for builtin code, just panic the kernel
> if any of part of the initcall fails.  This simplifies the code.
> 
> This closely mirrors commit e77000ccc531 ("fsverity: simplify handling
> of errors during initcall").
> 
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
