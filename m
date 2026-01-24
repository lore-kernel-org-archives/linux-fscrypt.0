Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AFE771D63F3;
	Sat, 24 Jan 2026 18:25:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769279149; cv=none; b=kyViXSaRuKS57E9CTLWNz7xYVXRYAZIVouRJqF8Zu5/qhrHDKU0MekXIwiWEQ1g5lySUb/Ge5bMQ3UfpnEu8MNS0LFWkcJaYqvIkvUJ6MRsl58QIWKBDQcABKsT4ffDLI4WLgaC00/uzTklCYgkHKcFwFwNZnirSCXo4KSeXf9E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769279149; c=relaxed/simple;
	bh=Hfb44i0+SJmSyRQAsok69r++ji1ocTZI7fUeY5DuNjU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lXAmPF1cj/hUDvFqYu6kYCAx+fucuNRS7NbtD4f5QSBsLhzScUcoWJGOj9xWuOE2r6/Py/0s0Boe7bYTRpNIUkHG6GCzdo92qohvFTuI5QyTHLy0coKE57x3ckuiab4xLDNW1VTAZQKfxfqElfjhWeHtR3C/iwXL6su0ZJDJgdg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RPMV2mVP; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RPMV2mVP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E4824C116D0;
	Sat, 24 Jan 2026 18:25:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769279149;
	bh=Hfb44i0+SJmSyRQAsok69r++ji1ocTZI7fUeY5DuNjU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=RPMV2mVPSepOKgIs5NGhlQN/KfimhTd9tIwyvELQC1jTZNFd2S8fTQvL62Q5Lp7dZ
	 GUEdgR2e1rFZw+6a1gxx+G87HMObg7Ll+cyZwK2xV9vBajIkHyjCxsRfEU9dnwExbb
	 kftjLh5ip2wST1QvgqJSOoaZeZOPjSl55NuOBfMpaIdETqG4lJnc82pNTIzN5nx8vl
	 4BvflkgHNKBjXt84HAgk1ZLo4Wtovi2TuQzJwB8pGn76P91XmBzv8/OI38D84qaRe1
	 vs0b34zuGa5nnUACWptFBUteneIlOF67g4UnnRVUhSVqNe33tno7sH9dsvWXF5mImI
	 zMaO7kRW7DfUA==
Date: Sat, 24 Jan 2026 10:25:47 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Qing Wang <wangqing7171@gmail.com>
Cc: tytso@mit.edu, jaegeuk@kernel.org, linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	syzbot+d130f98b2c265fae5297@syzkaller.appspotmail.com
Subject: Re: [PATCH] fscrypt: Fix uninit-value in ovl_fill_real
Message-ID: <20260124182547.GA2762@quark>
References: <20260123073037.4164303-1-wangqing7171@gmail.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260123073037.4164303-1-wangqing7171@gmail.com>

On Fri, Jan 23, 2026 at 03:30:37PM +0800, Qing Wang wrote:
> Syzbot reported a KMSAN uninit-value issue in ovl_fill_real and it was
> allocated from fscrypt_fname_alloc_buffer. Fixed it by kzalloc.
> 
> The call chain is:
> __do_sys_getdents64()
>     -> iterate_dir()
>         ...
>             -> ext4_readdir()
>                 -> fscrypt_fname_alloc_buffer() // alloc
>                 -> dir_emit()
>                     -> ovl_fill_real() // use by strcmp()
> 
> Reported-by: syzbot+d130f98b2c265fae5297@syzkaller.appspotmail.com
> Close: https://syzkaller.appspot.com/bug?extid=d130f98b2c265fae5297
> Signed-off-by: Qing Wang <wangqing7171@gmail.com>
> ---
>  fs/crypto/fname.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
> index a9a4432d12ba..ba8282b96a2e 100644
> --- a/fs/crypto/fname.c
> +++ b/fs/crypto/fname.c
> @@ -220,7 +220,7 @@ int fscrypt_fname_alloc_buffer(u32 max_encrypted_len,
>  	u32 max_presented_len = max_t(u32, FSCRYPT_NOKEY_NAME_MAX_ENCODED,
>  				      max_encrypted_len);
>  
> -	crypto_str->name = kmalloc(max_presented_len + 1, GFP_NOFS);
> +	crypto_str->name = kzalloc(max_presented_len + 1, GFP_NOFS);

For KMSAN issues, it's important to root-cause them.
Zero-initialization isn't necessarily the right fix.

In this case, it looks like ovl_fill_real() is incorrectly assuming that
the name is NUL-terminated.

Yet, the name passed to dir_context::actor isn't normally
NUL-terminated.  Even for a regular directory, ext4 just passes a
pointer to the filename in the ext4_dir_entry_2 in the buffer cache.

The encrypted directory case doesn't seem to be fundamentally different.
Just KMSAN is able to report the issue because the memory is in a slab
buffer rather than the buffer cache.

Can you consider fixing ovl_fill_real()?  Instead of strcmp(".."), it
should check whether namelen is 2 and the first two chars are '.'.

- Eric
