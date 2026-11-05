Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793837964;
	b=q7oYncBTbhpACSxQOe1PZsTDUQkX1vo1POt/zNS8fR5qCow0Ii3OsXRB7228VsR3QPNt
	 C5cdra+p2pl6nVvKiwdnCeb53KnclQ1CKLCBxg9B2HfL71sYkM0P87hYp93xOVk3JPAY2
	 qwjb3lZeF+FmwMl6u7achL1ltNfw7cFQLh/O+wAvNIcRl0AMdxNOSiGdSiNkoHbFj1h9C
	 meCowqyptZTnbC6+YX4B4EqbCwXEfIhT/7/M2rLIuVX7CU9/SxOxwijJSKyAPmXxvvsK9
	 4lSdhtyfEydMdEaXxx8GTzIVKEPccKGiUxt0lOv1e/FThdkL7uNHVlkudW/As+3BMeQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793837964;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=Y1m9VJNw6B2fKCe5TUVIsKZGTYCVq5kjIhqXMi/szw0=;
	b=q8k07dkXEozf5Hpbj0PLqbog2/gZbiZGFrmCHfuTY167daBLubkxzpkPetkXemGa2MV/
	 cU7f6cq6RLZ/4kCOol95y2zR4JplxpDd33rCq8ASVZloMsqX1AI8uQJssh1e3AAu0Owg3
	 whOFIDR6a05m1fAMsjkw8/yHvegAKK+2uSEquIt8ldYtFihrsABONOlovqpkDdtxLCppY
	 lijvA0EcNRS6q0RhQ+LzBJjNhq21og5tRdYMbfRoc1JalBrowXlNI6dMXVd/W79jXdJqL
	 VHhFGTOobNEvxTNWxEmiz2XL2IxksDDROFWoSSfcLST/yGw2QcXSFUvzvaZgSqO5vAQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K2UKogvU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7562606A31B;
	Thu,  5 Nov 2026 00:19:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K2UKogvU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4D1BD1F00A15;
	Thu,  5 Nov 2026 00:19:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793837963;
	bh=Y1m9VJNw6B2fKCe5TUVIsKZGTYCVq5kjIhqXMi/szw0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=K2UKogvU1mouRPupCuhidTloA9d/olpGfKAfNtZnMJz590vF2WCwk18+0lmjGIphl
	 Rtzlnp7T9hjb8xfNx5qFyN0ourM7SjwzCfKeo2IzVfcm7bsktwIQ9dlL+Xhgkj97zZ
	 mIukNCPl0qwfj/ctA5dbyhHYK68rRWOm35k8UB7+IcGgCKazUOAH9wGNr/UU14zEkL
	 rV1nV5+9sqrdihrV1+GCtd2sJyMYFlcUQDhwhW0gXXSep0HgJbPDQ6v+sOLBAu6vX1
	 B2WI8g3XA/DEWyAIIm1jwk8DjyFe5NDT0VS2C0IfwnGbQALklqT+Zj8trT4K3V/2Qb
	 fqQ0Q+583Dn1w==
Date: Wed, 4 Nov 2026 16:19:21 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Tal Zussman <tz2294@columbia.edu>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/2] fscrypt: remove fscrypt_is_bounce_page() and
 fscrypt_pagecache_page()
Message-ID: <20261105001921.GA2084@sol>
References: <20261101-fscrypt-page-helpers-v1-0-bcfbfaf6a237@columbia.edu>
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
In-Reply-To: <20261101-fscrypt-page-helpers-v1-0-bcfbfaf6a237@columbia.edu>

On Sun, Nov 01, 2026 at 03:16:12PM -0500, Tal Zussman wrote:
> Commit ef9024b5fca2 ("ceph: remove ceph_fscrypt_pagecache_page() and
> ceph_fscrypt_page_offset()") removed the last callers of these two
> helpers as part of ceph folio conversions. Remove them.
> 
> ---
> Tal Zussman (2):
>       fscrypt: remove fscrypt_pagecache_page()
>       fscrypt: remove fscrypt_is_bounce_page()
> 
>  include/linux/fscrypt.h | 21 ---------------------
>  1 file changed, 21 deletions(-)
> ---
> base-commit: 46fec1c3029b552ec63b2d01af9d43a386f043ea
> change-id: 20261101-fscrypt-page-helpers-1b2abcb14657

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

Thanks!

- Eric
