Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 713213B9931;
	Fri, 25 Sep 2026 20:08:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790366916; cv=none; b=fzZiMsZ6JxBJYBlUpgoxVn99vE8OH51Thyn/8fR1pNwUMXU5cO7ZeuIpLOIUC5kGs0c8EWmr6rZYhekRRJbnGRfKhNYF8OvCxCq1ueJA8rDfOJDouMrU7smJwAlbMC1AeqgJ7VZKiutUf/tGXtooQrjgGUlZXSOyCQFCHDP9wJE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790366916; c=relaxed/simple;
	bh=chxr91I8LvFS0U6PrOUB5xy3ENrOWUM4Cry8yVLBT7I=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=reFrAHr+kTI13PwgIOKjsEwzCFJfdKggHpBeYY1f9stsnQ5irHW5rwu77P4XUL+bNcFMXK8hUueRgy6MlJoaRD2KPtVfJ9/RHackSoxT/E2dVNked+B/EBHq7rSsUjg343sjlKEo0sjNUlWJ6v59fP/l8vB4P1fRIEJUxXKgg04=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZdGzOa0x; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZdGzOa0x"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B696A1F000FF;
	Fri, 25 Sep 2026 20:08:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790366915;
	bh=Y2x54wdcn0WapveU4aWy1axddCHwlKG0h7ovOHaTYUk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ZdGzOa0xq010uCUfVjmxL6SYk4g1kZwXFghVG8SGJww1FZjUDpJA6CORe1ohELZSD
	 32iQiCVTG1SAkvHJHfWfkPfpySPHyCK1EVF6+s8yiL8BtgzLcpVAJo0yw9F0GN+V0/
	 36g74eodAEuodVe/LRiBwph6bx3pDwPB2C6f1m9B+rchmwem7uOYT12KValIYAbqC4
	 DImw9q+WqW7Xs2rLum0CY2bVH05zd29gabvXAjrbYBgyFiIjYOKhf1qL4FrkpyBtmL
	 m0cRuqVVQwMmJBWeT+1mhqXJIYe0SN/0UszKK/t5nH+GI6gF2Q2aH2eFed3mnGyO8j
	 ESkQielZ1deyQ==
Date: Fri, 25 Sep 2026 13:08:33 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Alberto Garcia <berto@igalia.com>
Cc: stable@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>, linux-ext4@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, regressions@lists.linux.dev
Subject: Re: [PATCH 7.2.y] ext4: don't enable large folios on encrypted inodes
Message-ID: <20260925200833.GB5511@quark>
References: <20260925153127.1472301-1-berto@igalia.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260925153127.1472301-1-berto@igalia.com>

On Fri, Sep 25, 2026 at 05:31:25PM +0200, Alberto Garcia wrote:
> Commit 709f0f1f1bf5 ("ext4: add checks for large folio
> incompatibilities when BS > PS") disables large folios at mount time
> if the "encrypt" feature is set. However, enabling that feature on a
> mounted filesystem circumvents that check, and writing encrypted data
> results in a crash:
> 
>   BUG: kernel NULL pointer dereference, address: 0000000000000028
>   Workqueue: ext4-rsv-conversion ext4_end_io_rsv_work
>   RIP: 0010:ext4_finish_bio+0xf7/0x3e0
>   Call Trace:
>    ext4_release_io_end+0x51/0x110
>    ext4_end_io_end+0x4c/0xe0
>    ext4_end_io_rsv_work+0xb3/0x100
> 
> Fix this by disabling large folios on encrypted inodes, as is
> already done for inodes that use data journaling.
> 
> This affects all kernels between v6.19 and v7.2, but it is not needed
> in v7.3, where the code was significantly refactored.
> 
> Fixes: 709f0f1f1bf5 ("ext4: add checks for large folio incompatibilities when BS > PS")
> Signed-off-by: Alberto Garcia <berto@igalia.com>

Reviewed-by: Eric Biggers <ebiggers@kernel.org>

- Eric
