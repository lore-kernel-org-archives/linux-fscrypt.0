Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F7DC28E0F;
	Mon, 15 Jun 2026 03:04:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781492678; cv=none; b=FVgy+Y1Ec4vKGAYM6vKygd1dpQhv7apQKKU/kOwg1lp+tEQDn14Y5p+SQy1oadXTaCX5+SgfPFa7hcw90FmPmjmIhR6/5hyTrWzQB8wmjaN8WkeGq15eeRcVVWxmrdi5k7j6IUNbKlFTYVwbVz34M3Jgt9rS3tr+vq8LWOQCJQQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781492678; c=relaxed/simple;
	bh=F21MQifZHkdI0LPJ7aH9/MswjVZZanEyqZpdCZalIQQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=kkyl9EG6WhoS9CmepLZuKZ5FGQZbYv6/hyIB3Pp6zREj58YFgtkroEjomhwh7dUJ2/dvHeOUKTXOixO5kqubbAPzN0SB+fDgSNYuaSQ5DXL9vJdss89WQW9QfkjD7FIcBGkeZ0wqJS2iBtvqSfLgPRwS8Na2fyZsthfvyWMHQ4c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KVpgvAcA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KVpgvAcA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DBE221F000E9;
	Mon, 15 Jun 2026 03:04:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781492677;
	bh=2QNQXfLtdJq4zDVVS8/wh0UvbzBf1iUZMVkOAs61smM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=KVpgvAcAv8BNr2qvLWHzto6NR0vi1yzqgQ8tIrUJ7se4eKE1bfLdxjpf46Jz8p0Ml
	 YNa84vCmAwc2qByhW6mXLocL7ghqanKvxNsqyu/ImfAEQ4SlT3btNHjbE7HXaIyLGr
	 9brBOs5TTeisTvvWftB8lY8sQpE0zD4cT6zH6jEdzT58VKsPk9gmSLFG1mNWRg95oJ
	 9ZdOiQpc42qn3JUZeAGQVvFfB3BTTHX5WsqtDZRkC/RcXtpQTRWMlg4UxSKYc06yUq
	 DZIUO4WPuYyWpZkG5fC77yjPFbqyl3druHN7kPyduNc6xhyHvNMZYedYkPf41C1egA
	 vhpXbSaf8piCQ==
Date: Mon, 15 Jun 2026 03:04:35 +0000
From: Jaegeuk Kim <jaegeuk@kernel.org>
To: LiaoYuanhong-vivo <liaoyuanhong@vivo.com>
Cc: ebiggers@kernel.org, chao@kernel.org, corbet@lwn.net,
	linux-doc@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
	skhan@linuxfoundation.org, tytso@mit.edu
Subject: Re: [PATCH v2 0/3] f2fs: support encrypted inline data
Message-ID: <ai9rw8tjybY8Aiqu@google.com>
References: <20260602134104.348655-1-liaoyuanhong@vivo.com>
 <20260611125006.508734-1-liaoyuanhong@vivo.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260611125006.508734-1-liaoyuanhong@vivo.com>

On 06/11, LiaoYuanhong-vivo wrote:
> Hi,
> 
> Gentle ping on this series.
> 
> v2 tries to address the previous concerns by avoiding per-file software
> tfm growth, preparing the software transform lazily, and explicitly
> disabling unsupported key combinations.
> 
> The main remaining limitation is hardware-wrapped keys. If this makes
> the feature unlikely to be accepted, please let me know. Otherwise, I
> would appreciate any review comments on the current direction.

Yeah, that'd be a big win, if we have the hardware-wrapped key support. By
any chance, can you add it in the patch set?

> 
> If maintainers have any feasible direction in mind, I would also
> appreciate hearing it.
> 
> Thanks,
> Liao Yuanhong
