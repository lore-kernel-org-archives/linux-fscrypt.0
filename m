Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C9BE2D47FF;
	Fri, 25 Sep 2026 04:23:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790310239; cv=none; b=LZZw/u1hzHmaKYL57/oxjdPejzB+9tV/Al+TNU+FoBo8Q3nQX+o57iAJxlU699hvrElFn4vFH/RTqbYWIc6MvKVtCKNnJ0AP93FMDYsUyceFOYIa/SjoeGtXFd7cBfIqmUUn/QTodwByJ72OQfZHGQM9A8jKeIcVfdZhAihp6Tw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790310239; c=relaxed/simple;
	bh=Oe5IWEpcWyIiOJRQBvJRSnEfAKaHoPKwpXW7SBEmO5M=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=O07u1ZH8ekVZE0fgTk37gUXFMn+1CifN1AyS/SYv9ycMct/KGt1arK9+Mep5HwY5j1peP/APXQRgQDIo/Zl6Jz52pT+foDADbIuvAp3blDfvormHqsTCz6yPOCwyvGzOlZPOlVe4/x+ymqX9SWBw+8VMbGcyThFms0+D2wixmt4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ANM/x0iJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ANM/x0iJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 958C51F000FF;
	Fri, 25 Sep 2026 04:23:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790310237;
	bh=jRteOEp8lDW2rT+YhiwRa3HOTSFuotI7r/asuVkN6+8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ANM/x0iJTfUcmgAepUy3sqgLtpPeTlcHbPTj55vyHodE+qT+qqpSloRhQpBCKOoqH
	 UYGmnv5VI/rdsjSKbwV7Q6eu+8w4zy/+4XHSCud2MziRuLgpYz7u/i4aD6v+XWnzDR
	 1JgJ9y1BLf91U70r+gX0FvcgcX3Rz2qYbT1R8PC9GKmLoMYO5QbdLC4PKbEnE/THkm
	 BvKImxaf7UZycW+a7iT6vSSdpfWvUBqY0s/d1mu5YySKrg45/ddrbRQ+UL7wUeYuih
	 5/87+3k7JtOItILpQ9465iOZ6HUYhhTDding54YsW1xUrl1fPyw5tG1/MtQdiAICEB
	 BBnnMCV6Y1Png==
Date: Thu, 24 Sep 2026 21:23:56 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
	Matthias Goergens <matthias.goergens@gmail.com>,
	fsverity@lists.linux.dev
Subject: Re: [PATCH] MAINTAINERS: List the fsverity branches
Message-ID: <20260925042356.GA112369@sol>
References: <20260925041654.112935-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260925041654.112935-1-ebiggers@kernel.org>

+Cc fsverity@lists.linux.dev

On Thu, Sep 24, 2026 at 09:16:54PM -0700, Eric Biggers wrote:
> The fsverity entry in MAINTAINERS has a T: entry but it doesn't mention
> which branches are used.  Update it to have a T: entry for each branch.
> 
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---
>  MAINTAINERS | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index c52ec2d7d3c1..2a4b4ef679cd 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -10706,7 +10706,8 @@ M:	Theodore Y. Ts'o <tytso@mit.edu>
>  L:	fsverity@lists.linux.dev
>  S:	Supported
>  Q:	https://patchwork.kernel.org/project/fsverity/list/
> -T:	git https://git.kernel.org/pub/scm/fs/fsverity/linux.git
> +T:	git https://git.kernel.org/pub/scm/fs/fsverity/linux.git for-next
> +T:	git https://git.kernel.org/pub/scm/fs/fsverity/linux.git for-current
>  F:	Documentation/filesystems/fsverity.rst
>  F:	fs/verity/
>  F:	include/linux/fsverity.h
> 
> base-commit: 165768bb70265b5c38cf0b73fafd75be235f8b14
> -- 
> 2.55.0
> 
