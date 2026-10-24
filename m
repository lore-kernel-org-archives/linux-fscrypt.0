Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792872208;
	b=OadMp2V66Utz/YZ2cL55y2SR3pdTH5y18L7QUUi5gTGFbPf3K1LsZ9qfwzgTWb0A/q/3
	 vK9S84iwkTChSDrjrsiSwoLtB0wURLnyK10UhjV8qHmdpH18HJbUCqUWml0G5cXiev4ZO
	 N845XIsczfLyKRziJdM0lXQxYonAEBtjLfYJO8vxIboJS7cuTLcQVZQ7ts8yHzaPNiZnG
	 G9SX9wc06raN3/obZa8NaPODdQAzr8U0rjgYpdeSTGHo3j4mGNacAB03hrQhtp9037lS4
	 fXRkYz6WPplw0s6pMHeBZ/CXg7FOcv/0kG+kh4ceJN44Zo+XONSDwbrAubrlGJxecjw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792872208;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=5YmyunIAXQwJAKdDJUW0/pajadWYuZ1OX+wjYdVMpNs=;
	b=1u2Nt2cMSQZadlrB8/mt8hbnKMxam320Oi03SaOc4VYZuxEKjh6b2tGPR2MxqS6jfIit
	 onzzZT/Lm1G4QnMlSl8AqLqA8hkkiBnLC7+Agjrq7775/eNlgfu3vL3lNi4HG7ty4ckiB
	 ohL4OiS307sSuANhF10+G6ZqkdK6eB1Kz/CJiAFv8DFDtrdjGxUDsWIwzE+ljzCnIMx+p
	 CcA+TVMHthvX+DfBH8sqJ6g7r3HBs02vPvkKybr7XP1l3EotB+jB9X8Qv85gh54cPYBs4
	 N3w8F8Eh8/NqYPSRHnvSl5kF8xLbJq/b0vsJ73ygblt+FbgD4rvs3ZIKVWPAcxOGXsw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GHcseoZ6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1DBCE606A31A;
	Sat, 24 Oct 2026 20:03:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=GHcseoZ6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 63DBE1F01825;
	Sat, 24 Oct 2026 20:03:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792872207;
	bh=5YmyunIAXQwJAKdDJUW0/pajadWYuZ1OX+wjYdVMpNs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=GHcseoZ6JCXhKdGW23mHlyw5LEzAn6x8gx2RZsVS+rLWYM79lR6Js40yF2LHE/GtN
	 2cWfsWGlpa5Kf76hLiInyex2NYblIJ0ofLOQorr9QpTSXSPiYGXmimx2lW5l0Czd/U
	 mlROFQsfcyJQ5429JPg36g9aMpP92duDaiZCarWJ9x03JXX2ZrWrVoBxClRYwTkqvM
	 YeMpKbhPUcVNJ3obw6N+yFq4QKFrzYvGO8FNGy9sZEGD058g0rwZ9YwpgkNyTPhs1W
	 03+eqwyn/U9wuJSMeoBsddLPiK9kWBPQGvVaqnGglX0+GZvMB34OYNSsRHw2hCWk67
	 hUCidYUONq+uA==
Date: Sat, 24 Oct 2026 13:03:26 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Alberto Garcia <berto@igalia.com>
Cc: Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>, linux-fscrypt@vger.kernel.org,
	linux-ext4@vger.kernel.org
Subject: Re: [PATCH 0/2] ext4: refuse encryption when block size > page size
Message-ID: <20261024200326.GH2553@quark>
References: <cover.1790343958.git.berto@igalia.com>
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
In-Reply-To: <cover.1790343958.git.berto@igalia.com>

On Fri, Sep 25, 2026 at 04:19:17PM +0200, Alberto Garcia wrote:
> Alberto Garcia (2):
>   ext4: refuse encryption when block size > page size
>   ext4: reject encrypted inodes when block size > page size

These didn't get taken through the ext4 tree.  So I've gone ahead and
applied them to the fscrypt tree
(https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next).

- Eric
