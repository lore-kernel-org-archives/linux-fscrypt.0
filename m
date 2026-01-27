Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 387994C97;
	Tue, 27 Jan 2026 03:48:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769485707; cv=none; b=MlRixufoeM2lO7BHeWeTWT+ZOQojqTKy0JIUWcwsl3leHTrxEsN52bNoLqY3COwbTXfdE8veZ9puVGBpWOkWc778JosiVcfzfzHxxp6k8vkBVK04DztrRvX4gse1sfdwmJV5w3Pv0i/fHsKm0bRDiPyPu54TZyCyEY2vH5bgC7A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769485707; c=relaxed/simple;
	bh=p+9CJq2ZUkjxxgU2f9aFJtjJPlIGTQwggauWr+tRdHk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=k9xEvCAgw9/CaWDav6HfQKqvsj2Pkb3j0b4a+akFNzgVnGvwxwEbDOCUJ8E+OXla/6I8aaPpAHLmTPeMDPhuCRjQf+L5ODNKPp/MJRMxN9YijeHLffMr7l1WJ7B34mGUxyGmO+/7HluII69Ic+mTwo3jBQUxh0Ea9rMMqMBk8BY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J5NsmEUx; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J5NsmEUx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DCE88C116C6;
	Tue, 27 Jan 2026 03:48:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769485707;
	bh=p+9CJq2ZUkjxxgU2f9aFJtjJPlIGTQwggauWr+tRdHk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=J5NsmEUxeH2dFMUe5z7MNRLsa7EtQVOb1yaY2ZSqCZiKQBZlwlAzhhdKx0XfZcZoR
	 qr1hV6o3QbQxE8IOi65OU5KtFKRk+ZndRi1PihlljV3lI5i0siT2Bkqj0Aw1+qR/lK
	 VlzNG8+jwr0Kkddz/iAHVrMFVYB5pqODjEDKWReSLO4UvdSswjsjJRNo5oZ3Vm7E+K
	 j4pZWWgctmSkOf0mwC2lP1q/cS5/lSeYfMj1NxD9febvf1tk503KJiW2wFybvOzwgq
	 G4qoe8cAHcS1kqKwctzicL9qp9H7HB3dbzQmr8eVW3PaVMW+KMIM32VXEwl+sLN8Rx
	 NQ3St7voDhOjw==
Date: Mon, 26 Jan 2026 19:47:54 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Qing Wang <wangqing7171@gmail.com>
Cc: jaegeuk@kernel.org, linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	syzbot+d130f98b2c265fae5297@syzkaller.appspotmail.com,
	tytso@mit.edu
Subject: Re: [PATCH v2] fscrypt: Fix uninit-value in ovl_fill_real
Message-ID: <20260127034754.GA4470@sol>
References: <20260124182547.GA2762@quark>
 <20260126062216.496560-1-wangqing7171@gmail.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260126062216.496560-1-wangqing7171@gmail.com>

On Mon, Jan 26, 2026 at 02:22:16PM +0800, Qing Wang wrote:
> ---
>  fs/overlayfs/readdir.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

This is an overlayfs patch, so please title it appropriately and use
get_maintainer.pl to get the correct recipients.  You can leave
linux-fscrypt@vger.kernel.org on Cc.

- Eric
