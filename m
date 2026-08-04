Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3BD636BCDA;
	Tue,  4 Aug 2026 00:54:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785804842; cv=none; b=rY8+3IMPMOFHOwMIywnZw54AAiLSMJCnpCw52sqVEDdicztYSo4dwBdPBQeQ8pg8CeDb2fIq4FIwHRIU1M/uLuPolKYoBRUDraLMDbxKpLEabA1OLd8XZT9KIxWZ9G+eZHNVctBa+Z9vsptECt2xXkiUYZI54bgY++m5kgRfq+A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785804842; c=relaxed/simple;
	bh=xe4BLgwBCdF9S0ili9ZpNXYo4U//JWxr6h/8qV1A3nI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=T0YPI3Z4hA0MvBVKfrAX+OTe5JsvluFGgSnI4wMzmMKVpsSwpMiqNqrdrlK8gGeakafOB0eZAZKVcMRG8HxkfT+PAljv+ApAjU8Knk0kM4sGLQTzLsakiQY1aIotetAnu2TfjodimjXFx9IPG5aqSX8liYJF+nCTQux9fyyIVDk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=APllE/PC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="APllE/PC"
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 4A0FB1F000E9;
	Tue,  4 Aug 2026 00:54:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785804841;
	bh=9mtyAOozxkrs5lt5Qaj4Fv8f+eSVOgvFX15YH+LWjPE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=APllE/PCHQWGGJrtM7vINNmaN8/ak94vQ7ak8C15VI013xWe5pCbBFiuduN6Fcwrc
	 GWzv8QSkQ1Q7+AtpkfgGteHXTmA4wSwA12u5M4FSqeRhxdQFDeIWQLanm3Na+vzgxr
	 4VsjLDPzCH53+Z1Kco1tZWCgQyI5ly4zyVyOE+NfEwXmHSKJgT8U7cXIvztT19ftKD
	 Zt7jXsIiKnIukVFCsfvAOZQ04fB6IeoTwgdeLPUPhaiuLQCVmzq/QVrDLhVioBo68l
	 5nL0XeBpqZUJh/7VDVk3LeYqGewNE+fvFqioFOg4gSu0NO96z5megrkQ0+akDGmURo
	 Q4wgYZsdmddHw==
Date: Mon, 3 Aug 2026 17:54:00 -0700
From: "Darrick J. Wong" <djwong@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Chris Li <chrisl@kernel.org>, Kairui Song <kasong@tencent.com>,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kemeng Shi <shikemeng@huaweicloud.com>,
	Nhat Pham <nphamcs@gmail.com>, Baoquan He <baoquan.he@linux.dev>,
	Barry Song <baohua@kernel.org>,
	Youngjun Park <youngjun.park@lge.com>, stable@vger.kernel.org
Subject: Re: [PATCH v2] mm/swap: reject swapon() on filesystem-level
 encrypted files
Message-ID: <20260804005400.GB3560112@frogsfrogsfrogs>
References: <20260803180426.3123-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260803180426.3123-1-ebiggers@kernel.org>

On Mon, Aug 03, 2026 at 11:04:26AM -0700, Eric Biggers wrote:
> ext4 and f2fs don't prevent filesystem-level encrypted files from being
> set up directly as swap files.  In this case, encryption is bypassed.
> 
> No one should be doing this, vs. the methods of encrypted swap that
> actually do work (such as swapping to a dm-crypt device, or swapping to
> a loopback device on top of a filesystem-level encrypted file).
> 
> Nevertheless, to prevent user error, make swapon() explicitly reject
> this case.  Document this behavior in fscrypt.rst as well.
> 
> Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
> Fixes: f424f664f0e8 ("f2fs crypto: add encryption policy and password salt support")
> Cc: stable@vger.kernel.org
> Reviewed-by: Baoquan He <baoquan.he@linux.dev>
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>

Looks good to me!
Reviewed-by: "Darrick J. Wong" <djwong@kernel.org>

--D

> ---
> 
> Changed in v2:
>    - Added a pr_warn_once
>    - Removed unnecessary word from fscrypt.rst
>    - Added Reviewed-by
> 
>  Documentation/filesystems/fscrypt.rst | 4 ++++
>  mm/swapfile.c                         | 7 +++++++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
> index c0dd35f1af12..e4882b73120e 100644
> --- a/Documentation/filesystems/fscrypt.rst
> +++ b/Documentation/filesystems/fscrypt.rst
> @@ -1238,6 +1238,10 @@ astute users may notice some differences in behavior:
>  
>  - DAX (Direct Access) is not supported on encrypted files.
>  
> +- Encrypted files cannot be used directly as swap files.  To swap to
> +  an encrypted file, set up a loopback device on top of it.
> +  Alternatively, encrypted swap can use a dm-crypt device.
> +
>  - The maximum length of an encrypted symlink is 2 bytes shorter than
>    the maximum length of an unencrypted symlink.  For example, on an
>    EXT4 filesystem with a 4K block size, unencrypted symlinks can be up
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 78b49b0658ad..8538659acb9e 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -3650,6 +3650,13 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
>  		error = -EBUSY;
>  		goto bad_swap_unlock_inode;
>  	}
> +	if (IS_ENCRYPTED(inode)) {
> +		pr_warn_once(
> +			"Filesystem-level encrypted swapfile '%s' is unsupported. Create a loop device over it, or use dm-crypt\n",
> +			name->name);
> +		error = -EINVAL;
> +		goto bad_swap_unlock_inode;
> +	}
>  
>  	/*
>  	 * The swap subsystem needs a major overhaul to support this.
> 
> base-commit: f5098b6bae761e346ebcd9da7f95622c04733cff
> -- 
> 2.55.0
> 
> 
