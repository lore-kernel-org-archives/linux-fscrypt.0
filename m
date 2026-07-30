Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BDD3923E334;
	Thu, 30 Jul 2026 19:53:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785441209; cv=none; b=CsfcM7vv2ysUUVO8kfr1nYMMsfJYslc07KSTl29Xc3eulmd4e8+Ud5Rtq5gXU9lUHMGXbEscK+IANZCKGFsORypVeLLTfjZKtFA9F+3zXB1fMnIjit37e930jRncKTFnOt0IQ0vsCwJztopFCud7XzaB2Fe0MQ0MXXQ3CnGvdi4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785441209; c=relaxed/simple;
	bh=WzgDIfqwT5lmM09RSEWVlfpFJI7yd4ZdPOWtWx1rFSQ=;
	h=Date:From:To:Cc:Subject:Message-Id:In-Reply-To:References:
	 Mime-Version:Content-Type; b=hC+qrJj97JglRcNNwoOxsg9PbCgsmiNJRITPCnR9BnHTF4seqaMr9loytQzAZIdhdxsh+7eZg/iJdjMOdWY2gQe1PrNuX+F7Dr1EKPINCRIkzn5+/rO8QJ9uq+qdUtf1Wo1+2NQN4oSEiXsNbbdYsEpmDM9Vu2/HwkOFPqsev9g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b=iJnEVe1v; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="iJnEVe1v"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0EE6C1F000E9;
	Thu, 30 Jul 2026 19:53:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux-foundation.org; s=korg; t=1785441208;
	bh=SYHnuwd5oBPShQry/A1IMV78wT87yQ12pmYbnlaWCNI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=iJnEVe1voUvv8oU3L/LXlxlWg/TMzmxWX/p+WsY0i3YPuE5mFSEJ4cF0TMcimIXHY
	 ghjBzhczgWPekjA8dP0c5k00yvs2tMguPZfnVAQ1KarieF9XzeUMVueazl7OX9zaeG
	 yRbcWd3iB0SupGRkN7oe2OwtgLEhQG1wvVdm67wE=
Date: Thu, 30 Jul 2026 12:53:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-mm@kvack.org, Chris Li <chrisl@kernel.org>, Kairui Song
 <kasong@tencent.com>, linux-ext4@vger.kernel.org,
 linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org,
 linux-kernel@vger.kernel.org, Kemeng Shi <shikemeng@huaweicloud.com>, Nhat
 Pham <nphamcs@gmail.com>, Baoquan He <baoquan.he@linux.dev>, Barry Song
 <baohua@kernel.org>, Youngjun Park <youngjun.park@lge.com>,
 stable@vger.kernel.org
Subject: Re: [PATCH] mm/swap: reject swapon() on filesystem-level encrypted
 files
Message-Id: <20260730125327.11fc9227d04f659a59136cdd@linux-foundation.org>
In-Reply-To: <20260730184853.48347-1-ebiggers@kernel.org>
References: <20260730184853.48347-1-ebiggers@kernel.org>
X-Mailer: Sylpheed 3.8.0beta1 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Thu, 30 Jul 2026 11:48:53 -0700 Eric Biggers <ebiggers@kernel.org> wrote:

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

Ouch.  We are going to break ten year old setups?  I don't think we can
do this!

I think the best we can do is to emit loud warnings which point the
operator to some Documentation/ which tells operator that this
deprecated configuration will be disallowed in, umm, 2029.

> +  Alternatively, encrypted swap can use a dm-crypt device instead.

That's tautological.  s/ intead// ;)
