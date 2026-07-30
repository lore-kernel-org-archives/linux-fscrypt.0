Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A03E53CB567;
	Thu, 30 Jul 2026 20:30:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785443419; cv=none; b=qretVF1A940XMrvsI7tyzIAb5hSTtzxw6UUtGp3mLeNMoVrqFIaenEXNxB2BwFKDTNoBU2dT/hAr+BzkrPOYR6CFofJnqM0HmNjLsqmpeBSPDqHp7WUGO2dMYxV0b5YGJaiYcnwZYMtZyzZ1R+dKpX/a2lI9TePDUgzyWEwWLhc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785443419; c=relaxed/simple;
	bh=SYgAnF5eLutqUtZ4b3NFfEPsVINHKabxfbeJoaOcIdE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=F9yI5FQ5l06vNusaGIE2qnZMNdh7hdCYvxaZpIhaGumNPAIwgrTItEBa/T+s8j2ftGcrdZK4+u1GGZObgJ3J7i9FreHgfOeKtCJgraPHLfQkYG4/mLxZGmjFvEhHq9ppf/sn23Yp6FbCp+9ce922mpQzjGCbwUQdBOUtJKfbThE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hFcsGnLo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hFcsGnLo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B57C31F000E9;
	Thu, 30 Jul 2026 20:30:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785443405;
	bh=0u6gw/MrFBT1/QNrPa7nLjvLVHSDimbPCCINT1jLXiU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=hFcsGnLovWPcFi+YkFwXfujpvSBlB3iFd7TIwz6cMigymfDKsbs8+aVqBQftTS/Qu
	 1hZlGC2QGQAmc9tlfq8EeyI0yzWmfdfg/4SRB9JmulIAJRqlKp78KxAeBd6CpjMWjA
	 ZzLb6YKmWZwiQ0PQdUG+NckRDmJwdf3ZYIyLPX5wEfHj7EwJohV7fQqRzAzfk6fcaW
	 46rrLmUDHXq1kFeu4lRdAs5HrO2gkrT95BMqbHyLUhf9uMEqaMGfA4hg8gN/vKCD8I
	 JVu6aVSWUfm/WQnFqobITKGHVuPzXNwIhKdA74nXROb9GzBc6/rvfSbhgsEEnUNA6N
	 Rmn+CdkioS94w==
Date: Thu, 30 Jul 2026 20:30:03 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Chris Li <chrisl@kernel.org>,
	Kairui Song <kasong@tencent.com>, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kemeng Shi <shikemeng@huaweicloud.com>,
	Nhat Pham <nphamcs@gmail.com>, Baoquan He <baoquan.he@linux.dev>,
	Barry Song <baohua@kernel.org>,
	Youngjun Park <youngjun.park@lge.com>, stable@vger.kernel.org
Subject: Re: [PATCH] mm/swap: reject swapon() on filesystem-level encrypted
 files
Message-ID: <20260730203003.GA2459987@google.com>
References: <20260730184853.48347-1-ebiggers@kernel.org>
 <20260730125327.11fc9227d04f659a59136cdd@linux-foundation.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260730125327.11fc9227d04f659a59136cdd@linux-foundation.org>

On Thu, Jul 30, 2026 at 12:53:27PM -0700, Andrew Morton wrote:
> On Thu, 30 Jul 2026 11:48:53 -0700 Eric Biggers <ebiggers@kernel.org> wrote:
> 
> > ext4 and f2fs don't prevent filesystem-level encrypted files from being
> > set up directly as swap files.  In this case, encryption is bypassed.
> > 
> > No one should be doing this, vs. the methods of encrypted swap that
> > actually do work (such as swapping to a dm-crypt device, or swapping to
> > a loopback device on top of a filesystem-level encrypted file).
> > 
> > Nevertheless, to prevent user error, make swapon() explicitly reject
> > this case.  Document this behavior in fscrypt.rst as well.
> > 
> > Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
> > Fixes: f424f664f0e8 ("f2fs crypto: add encryption policy and password salt support")
> 
> Ouch.  We are going to break ten year old setups?  I don't think we can
> do this!

That assumes anyone is actually depending on this bug, which they
probably aren't.  Encrypted swap is done in other ways.

> I think the best we can do is to emit loud warnings which point the
> operator to some Documentation/ which tells operator that this
> deprecated configuration will be disallowed in, umm, 2029.

... and if they are, they'll want to fix it right away anyway, not in
2029.

Other fixes to explicitly disallow swapfile activation in various cases
have been merged without a deprecation period, e.g. 36e4d95891ed,
377eeaa8e11f, 51cc3a6620a6, d15cab975459.

I think we should try just doing this instead of dragging it out over
several years.

- Eric
