Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 21CCD282F22;
	Sun,  5 Jul 2026 19:12:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783278740; cv=none; b=m+Xdanwxb1xKJEV3bT8Vh7R7uCFfxmE4UN6nSeqf6u4GHQUBQ3AQN96u8h3J09jTTYIYSrSx3yEK+0p8MLiEfhtXb/TYtF8EK4FrFIb4EjC5on5xHE1yhjhDE0DZOGhPMyfsmYv1cknYCh6CmkSSQWdol8Y86a7NOtE8h7FdC7A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783278740; c=relaxed/simple;
	bh=50NrJxqbSb5e4b+na2UDJHqhUiS+q783nmq5MYeMbug=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=L/k8jgKQRycrZZMhG40uVOaNhClYE8n1nA+g53E/7p985VebE9XuXy1AGEBYVoUQQJdm9YPLKx2v+7HOqU11wtqKIvP/fB3pWj8NbZ00HjCvodtpj8bRn45VG8kcmJLe232txapY9w1GXmCqXbqXSyLSAwVk1B2hJ4BGPABQFg4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=H8u58LHp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="H8u58LHp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A6EE61F000E9;
	Sun,  5 Jul 2026 19:12:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783278738;
	bh=mVrwpxtlnPRsDChMxLDmownxKUYn+VOZNA8DCKfgNZ0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=H8u58LHpwuMGXVfsFx4bHjuc0KqA8pBQQNPnul5LuwhGRl1KpdYGKHufgbtoMkZ3M
	 lQRskGxGmpNk+QUJ5zXSQz67yBQrLwibvhYvSpF3h84Ixn8fLWgPuofnT6hhnDzEl3
	 cdHYZ2EdkTAfVDI2DB8XbAnwizll1kq3dVyMD1hmhNdUeOaRcg6lZn6kDIsm/qxQFf
	 eSELWBxvWBbVw95MObZ1eNCyHe2KkswIeo3jqUwUU/AnCAzGHRywCmsjwaXoUTBt11
	 boxg+VDOE4axpG4JUNVwQBm3DuYoMnaaIxxd/0vo3pDGKd9EQL7Upi4FmOgy/NLJlS
	 TdN31I+hR6g5g==
Date: Sun, 5 Jul 2026 12:12:16 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Remove workaround for bug in gcc 7 and earlier
Message-ID: <20260705191216.GD41916@quark>
References: <20260619051008.51223-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260619051008.51223-1-ebiggers@kernel.org>

On Thu, Jun 18, 2026 at 10:10:08PM -0700, Eric Biggers wrote:
> Since the kernel's minimum gcc version is now 8.1, the workaround for a
> strange gcc bug in fscrypt_ioctl_set_policy() is no longer needed.
> 
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---
>  fs/crypto/policy.c | 17 ++---------------
>  1 file changed, 2 insertions(+), 15 deletions(-)

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
