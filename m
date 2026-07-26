Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B23E1DF75A;
	Sun, 26 Jul 2026 04:35:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785040560; cv=none; b=gzBeZFV62N7KUlcd7bUYed9MBuaFLEKoD995AU3eQZP6PWtxPuW3URLuIVVXqNkZhAL1JDOevExlPrasMvyCjxP2ci6WxssmJ+n4k33yc3nBfrBUJhrg2tcHCHTGkPX/2rCYHQFPBX0w+jOmf6F9XjT975y5Mnxi/e4hoypHrok=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785040560; c=relaxed/simple;
	bh=73txoG+kQ+vQUTAlXbAeuuxkM1brd3bO/p0XZivxkWE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Wb3JfZLOIJ/XLH2W69/VVd2lOLhg36NO9yR2/8hoY96Euzqv8DixpBcfSQyq0UUe2ncP0CFO6Ws0lY6OmVIBQbh0h1NM0dfOuGWg7MaIA7UcSZGwgsO2WavfRCFUy8V1MOvIOgYC5KGtIQLYbeSZQbwNAWQDLMKIEdcmWM+Ners=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=D2Ka0pTd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="D2Ka0pTd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 258351F000E9;
	Sun, 26 Jul 2026 04:35:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785040559;
	bh=D+VglhCbI3Wt64SJjP1te0rRfJe5ACcS742dQMn199U=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=D2Ka0pTdeWKX6xY9Z/JRdVMFI91Dp/vBbcmNkmmWPQZXYNcV9isdD+X07eg550s7S
	 dJFuwW1xPYW1jS6n+G1uwHe5eHQu/6oKrqltDQSm9PkOHOfLJJwb9KhsMj1L7hhY2A
	 70ASWidELpIlyD67xW7zcXHgEEPt30BFhQo0x8aBSo+RNjllD8KIf0MazvwNnCVBRo
	 jF6J4y/O2LtA9kKv2BzgiA3zt542X7EKcuEO9xbX6OxQ2iuaCMW4vMBsLIZJvAHjS9
	 Ov/FSDsmr1oXOyFW2GeF158Izy91AgFqWqmd0+UvBkvM0Acn8/j53RQ+lCT2o0CQ5B
	 T3+WqEIKYSSXQ==
Date: Sat, 25 Jul 2026 21:34:06 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Zhan Xusheng <zhanxusheng1024@gmail.com>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
	linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhan Xusheng <zhanxusheng@xiaomi.com>, stable@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fscrypt: use the mount idmap for the owner check in
 fscrypt_ioctl_set_policy()
Message-ID: <20260726043406.GA1708@sol>
References: <20260725080004.929328-1-zhanxusheng1024@gmail.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260725080004.929328-1-zhanxusheng1024@gmail.com>

[+Cc linux-fsdevel@vger.kernel.org]

On Sat, Jul 25, 2026 at 04:00:04PM +0800, Zhan Xusheng wrote:
> From: Zhan Xusheng <zhanxusheng@xiaomi.com>
> 
> fscrypt_ioctl_set_policy() calls inode_owner_or_capable() with
> &nop_mnt_idmap before allowing an encryption policy to be set, instead of
> the idmap of the mount the ioctl was issued on.
> 
> fscrypt is used by filesystems that support idmapped mounts (e.g. ext4,
> f2fs), so on such a mount this compares the caller's fsuid against the
> unmapped on-disk owner rather than the mapped owner: the actual owner can
> be wrongly denied with -EACCES and an unrelated caller wrongly allowed.
> Use file_mnt_idmap(filp) instead.
> 
> Fixes: 01beba7957a2 ("fs: port inode_owner_or_capable() to mnt_idmap")
> Cc: stable@vger.kernel.org
> Signed-off-by: Zhan Xusheng <zhanxusheng@xiaomi.com>
> ---
>  fs/crypto/policy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
> index 9915e39362db..c80b24a941ad 100644
> --- a/fs/crypto/policy.c
> +++ b/fs/crypto/policy.c
> @@ -534,7 +534,7 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
>  		return -EFAULT;
>  	policy.version = version;
>  
> -	if (!inode_owner_or_capable(&nop_mnt_idmap, inode))
> +	if (!inode_owner_or_capable(file_mnt_idmap(filp), inode))
>  		return -EACCES;
>  
>  	ret = mnt_want_write_file(filp);
> -- 
> 2.43.0

Thanks.  I don't think the Fixes commit is quite right: 01beba7957a2
seems to have been a behavior-preserving commit.  It even says that it
was "eliminating the possibility of any bugs" :-)

Really it seems a patch to this function was just missing entirely, but
I would probably use 14f3db5542e6 ("ext4: support idmapped mounts").
That's when the other ext4 ioctls got converted to use
file_mnt_user_ns() and the idmap support was enabled on ext4, but this
was missed.  (And ext4 was the first fscrypt-capable filesystem to get
idmap support.)  As usual, this also needs 'Cc stable'.

I guess I'll plan to take this through the fscrypt tree.  I'll update
the tags when committing if there's no other feedback.

- Eric
