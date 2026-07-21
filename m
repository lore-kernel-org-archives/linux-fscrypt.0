Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7411331715F;
	Tue, 21 Jul 2026 12:51:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784638264; cv=none; b=gLK6sJ8m3+qehrQuLj4HB+/D+6p92WprxelqiLMMsx9pWVTPON+HMHtZYiGZMQ9+7Xzh8gOpDAFj/Mb1qeRnVuHOjB05IM7Gl0CwRoDS8KkakO+SiP6d+JxQ7+xuCulbCVAVOfFXKyIB5HVK3mHZM7zDSz0bwl5X4C7gb3eGaIA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784638264; c=relaxed/simple;
	bh=Pt8W7rGIA9t1YuQLMatvF1WwbdfOZzcAcfq1Scuc3gg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=NW2maz8SKUgA7H/Jp+FKtVlat7iP8+GMgiaXZ509AgS1lfRBdUo1xWxxe8gMyHekEPA6zWbPAvWDNyd5/3KMDcBkX6fvCPft9eRuEFw256WyZiFiqtxKkZUWeIatBI1eR85iMtqJWdhh3YP9ryxBM4pKSJYlUwClF5+OemYk2IA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b=XGCvtReT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="XGCvtReT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C0C851F00A3A;
	Tue, 21 Jul 2026 12:51:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linuxfoundation.org;
	s=korg; t=1784638263;
	bh=RtUvxr+S2V9JhRISbGOQhot2AV1CbAsNmE9Y984kZjo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=XGCvtReTx9N5YxJj+D+9z4hm7A5+jK99LnA9JCgHJ5IwxQUU7e0d9srnHHYVBHrJf
	 ZszG94Tf+hd8parodUBE/O5yvdJnbVY+/sjrL0ojmPZ/IQadq9JjNeZdlkoV61RAHi
	 Fs7SzLnQeOoHJeqmKf5G46siDfQzfHkxid78AV7M=
Date: Tue, 21 Jul 2026 14:50:53 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: stable@vger.kernel.org, linux-hardening@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 6.12 0/7] Backport object allocation APIs and two fscrypt
 fixes
Message-ID: <2026072145-remorse-swiftness-1c6e@gregkh>
References: <20260717044303.425265-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260717044303.425265-1-ebiggers@kernel.org>

On Thu, Jul 16, 2026 at 09:42:56PM -0700, Eric Biggers wrote:
> Like I did in an earlier series for 6.18
> (https://lore.kernel.org/linux-hardening/20260709043301.142931-1-ebiggers@kernel.org/),
> this series backports kmalloc_obj() et al to 6.12 so that more upstream
> commits will cherry-pick cleanly.  As in 6.18, the flex counter
> integration isn't included.
> 
> Patches 6-7 then backport two fscrypt fixes (which, like lots of other
> kernel code, happen to use kzalloc_obj()).  Patch 7 is a clean
> cherry-pick, while patch 6 required resolving some other conflicts.
> 
> Eric Biggers (2):
>   fscrypt: Fix key setup in edge case with multiple data unit sizes
>   fscrypt: Replace mk_users keyring with simple list
> 
> Kees Cook (2):
>   slab: Introduce kmalloc_obj() and family
>   slab: Introduce kmalloc_flex() and family
> 
> Linus Torvalds (2):
>   add default_gfp() helper macro and use it in the new *alloc_obj()
>     helpers
>   default_gfp(): avoid using the "newfangled" __VA_OPT__ trick
> 
> Randy Dunlap (1):
>   slab: recognize @GFP parameter as optional in kernel-doc

All now queued up, thanks!

greg k-h
