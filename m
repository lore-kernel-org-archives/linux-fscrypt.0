Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCD421F30BB;
	Mon, 20 Jul 2026 17:46:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784569567; cv=none; b=GeVdAE60dMyXkQCo/R8jZ9yABLq9R9RlZlRt+Cd6LxrAOoh/l52u/HjH1+XjU+UYgibDp6zYZRJGzXX3wOHv/kKrCrv37PZL2WKIjRhJ75r6aefLIOXk5BsF+nWAhuFCLRX61+Q4MepyGqRnC59hoy+FFBFX7Or9DWcnAKXN6w4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784569567; c=relaxed/simple;
	bh=4yrRUW/0E+1AcZMdvG7swq047fVSvT/iSTNBDjNsbLU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=N9MTbpCfk3QqkNKt92mpJTJzd87mi97TyjhGsuINMuwRBfwcmAiQtrR1TuvpKEEvWFRHQEt+S89XbczNyR+d5I3BJ3MVJgwwpkb8gW5HPJX/tNmYS3xxbsIv2H0fr/R0NE2vBiX54LgusI+bfKFucgsmmudGp3L7QatFx8+3dso=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MABqk60c; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MABqk60c"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7D4821F00A3A;
	Mon, 20 Jul 2026 17:45:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784569559;
	bh=8Z7qNrG0KSkprPREAOZB1jiU9uYS06edPPc9UNtP1bw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=MABqk60cV6yATXr0Ti5BqMdlfI2ZlHwHV8ww+qU5UTdaM3faehGsMI10u1H+aO9ed
	 iVcfF/HvjX/dWF8Tyanrx11HNohPv/pSVMFov9mSsAf8fkGi4ef6MhiSfBcyoDxlSh
	 KHOLJSiMtCm2XsZrNAQqbqAnSvvijK/C3VhPIuP18b+JW9Vbrd3HBMmCr8Mkf+bjG0
	 sXVAJkWzcKr80G4vtj/d+qgI03U9UgAxh28fQ3icc+P2YOblN7STRFfZVAHG5CJKrz
	 QA6eSkvBC34g0CZoblNS7ep2Nx6DEv3ZFLIuQ5lXaPsWO0mbe2xuU8GqAHioynWOVO
	 uNA2HhR0IJvhQ==
Date: Mon, 20 Jul 2026 10:45:58 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, stable@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Avoid dynamic allocation in
 fscrypt_get_devices()
Message-ID: <20260720174558.GC1865@quark>
References: <20260719055602.78828-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260719055602.78828-1-ebiggers@kernel.org>

On Sat, Jul 18, 2026 at 10:56:02PM -0700, Eric Biggers wrote:
> When a blk_crypto_key starts being used or is evicted, fs/crypto/ calls
> fscrypt_get_devices() to get the filesystem's list of block devices,
> then iterates over them and calls blk_crypto_config_supported(),
> blk_crypto_start_using_key(), or blk_crypto_evict_key() on each one.
> 
> Currently, the block device pointers are placed in a dynamically
> allocated array.  This dynamic allocation is problematic because:
> 
> - It can fail, especially at the fscrypt_destroy_inline_crypt_key() call
>   site when it's invoked for inode eviction under direct reclaim.
> 
> - fscrypt_destroy_inline_crypt_key() doesn't handle the failure.  It
>   just zeroizes and frees the blk_crypto_key without calling
>   blk_crypto_evict_key().  That causes a use-after-free.
> 
> For now, let's fix this in the straightforward and easily-backportable
> way by switching to an on-stack array.  Currently the fscrypt
> multi-device functionality is used only by f2fs, which has a hardcoded
> limit of 8 block devices.  An on-stack array works fine for that.
> 
> (Of course, this solution won't scale up to large number of block
> devices.  For that we'd need a different solution, like moving the block
> device iteration into the filesystem.  Or in the case of btrfs, which
> will only support blk-crypto-fallback, we should make it just call
> blk-crypto-fallback directly, so the block devices won't be needed.)
> 
> Fixes: 22e9947a4b2b ("fscrypt: stop holding extra request_queue references")
> Cc: stable@vger.kernel.org
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-current

- Eric
