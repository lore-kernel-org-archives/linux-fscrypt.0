Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792784303;
	b=kKrH38vX9c170uum2HadvjAWJ/28ACrdacVPYGtSCK1XM2U0IOH/y7LjXgK6lAfWFEDQ
	 i+Y3tp3WffW4CE2qhuWvYlk59/SA1uUZD7LPc9ahO+30QJCvUA2jTvI4H4dUx7nPc/IvH
	 FRYBW+6mJas2wgc4IJPEsE+cN4lqbcbjTHqr3zzCu9TcTYH6VwbxG1B43oQa6aR+CV41X
	 dps/zm+hNJi8Ji2iMNc+uKcTvxZA/dwM93lu+JOinIWU/OLuKPt/EnI+CGDQw0NPhzRhF
	 DATTtYvUP7LV1/OcGgHvlJlsxWr3Mw0pEnCs/afccXtWoW029ZiZqkj6EUmdQ6S1hEg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792784303;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=RPPuwZPucbwy2XSLdynlz8wKx1+hcu99bZJ28Lx7lTs=;
	b=HLy2o/5lpzdtCTi2HSYoCtiwR5bnUBL8BM7Mb8oSB0RVn3D4Ca8O5llIWMxll62HjCAG
	 5Lc5MYkOWmKTBlryNb1O0xjfh5LbW0Z5UdW0NYExx+e4iHsGnEEdz4JtDhtYokwg4nzt5
	 izGwt3gLC714BDDnb0mJauacjkusVJVgs7XwYiTgTbzg/e06/e8Bnih/b2erJenTPiJ/M
	 zgL0Hf46tubQQTkiTe6X73S2XEw3TGLasgUqkQDACPJtnF78Onw32qBFKKuwHv/Bm0gUw
	 RlUihytDvIZjKWl1a7mg1mlRapuTkiJSDl6UrumSd4zM92aVn2Mc6T40/97THeIUejw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YilIglj3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D01F0606A31A;
	Fri, 23 Oct 2026 19:38:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YilIglj3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 792E71F01825;
	Fri, 23 Oct 2026 19:38:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792784302;
	bh=RPPuwZPucbwy2XSLdynlz8wKx1+hcu99bZJ28Lx7lTs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=YilIglj3gUtbL+8nFzgEluM2h4Wdn1iEh3v5rXSjogwL9YuueE/GGWYeqwmiLJPUL
	 YsLd4toEQmFJJPCC5aIgooLYL1+SYkfkIGidKzUkG+lY3TicAMdJ2trFsKlbcxHQix
	 m4RDXiF7kDmpKPQyFurXT/JhY5yiC+suhCOTs3g1/KbrmaMahXucEyvfHwfssudHZe
	 xqCFAIIFtOuKF38S5W8d8yuIpKBMf8p+tqvHkVMonD/tvyqnrN3YBeBM2x6g6ZEDAg
	 Ggjujy3XcO9BbJqKlC8XUSF+LoZYx1dhJBnmTmDz6A4EgOg9XLj54IubM8k2YNzuWX
	 Pt/kgon7DJ+fA==
Date: Fri, 23 Oct 2026 19:38:21 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: linux-fscrypt@vger.kernel.org, tytso@mit.edu, jaegeuk@kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH v3] fscrypt: Fix missing barrier in
 fscrypt_find_mode_key()
Message-ID: <20261023193821.GA3091192@google.com>
References: <20261023160747.1382973-1-libaokun@linux.alibaba.com>
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
In-Reply-To: <20261023160747.1382973-1-libaokun@linux.alibaba.com>

On Sat, Oct 24, 2026 at 12:07:47AM +0800, Baokun Li wrote:
> dm-inlinecrypt reaches its key only through srcu_dereference(md->map),
> with no acquire anywhere on the I/O path.

The above seems like a stray sentence that should be deleted.

> Suggested-by: Eric Biggers <ebiggers@kernel.org>
> Link: https://patch.msgid.link/20261014161153.GC322435@quark

Nit: lore.kernel.org instead of patch.msgid.link, since it links to a
discussion (in response to a patch) rather than directly to a patch.

> diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
> index 892044ebcaca..984ef43982a3 100644
> --- a/fs/crypto/keysetup.c
> +++ b/fs/crypto/keysetup.c
> @@ -205,8 +205,14 @@ fscrypt_find_mode_key(struct fscrypt_master_key *mk, u8 hkdf_context,
>  		if (node->hkdf_context == hkdf_context &&
>  		    node->mode_num == mode_num &&
>  		    node->data_unit_bits == ci->ci_data_unit_bits &&
> -		    fscrypt_is_key_prepared(&node->key, ci))
> +		    fscrypt_is_key_prepared(&node->key, ci)) {
> +			/*
> +			 * Pairs with list_add_tail_rcu() in
> +			 * setup_per_mode_enc_key().
> +			 */
> +			smp_acquire__after_ctrl_dep();
>  			return &node->key;
> +		}
>  	}

I think a better comment would be:

			/*
			 * Upgrade the RCU dereference to a full ACQUIRE, so
			 * that blk-crypto global state is seen as initialized.
			 */

That helps convey why the pre-existing RCU dereference isn't enough.

Other than that this patch looks good.  I can fix all the above when
applying, if you agree, or you can just resend.  Thanks!

- Eric
