Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FEF4175A6E;
	Sun,  5 Jul 2026 20:15:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783282535; cv=none; b=CKmbdHl3DQjikZyjoepdxGm0D7/bdQLmkfcPpm6aUdtgYRX+7O0WB8aSt71dfXe+BWqhXtuE5ggdqZtEWa3Sv2Ap4xZLUi+mhhgWNxAK7Sf5eixBGA20zE9bKLsj6MLA8xLpGD9Ir5rUe6va5bEQVAwUJubuv38VwMoVAM9J4lg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783282535; c=relaxed/simple;
	bh=yDS3uFJa8pynG2mdfI80dCmBQ5u2U43X2AnUSZBV4vo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=RqfT+N+4f/1rmLdGbzAnc4FCHLbx7E1oZ7AWuvc1lkY/sCaOdgrq4o17czsh26Epn8sy86TX8mInYrvP/uuhoZEl74De3x62yfSIBKF1Dd3Ix7KGRRJ9SYOSFKLQfwy++22JPkyQyOFmgWwL23RgV7yzyCXn7IJRmT1WhvhrDj8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FrPSMO9A; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FrPSMO9A"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5D97D1F000E9;
	Sun,  5 Jul 2026 20:15:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783282533;
	bh=Jlw6RKgO5cyFNzF+9MdF+LGV8eC96x7LPuun++dRWdk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=FrPSMO9AwY3lL0nuFdbSh3HSNChkX4F+SJ49Vg+msdirBdIz7T8pHZa4LlF60iS/T
	 rk9cQ55SOdy8FZUOkt/CJR6FdKEgTHp7vPUgchC5dy0vAA8uRad0Wz+U6cvv79pycI
	 h8pTbey/lpMxSwDUazOiA0hH/8nPc5RiJuIJ+BDC6jYMCubJhgZCoEge8cajx27R6k
	 s4hzPkpaMYFLXpVOzS16i/RQacoh9L7tQk2qXY7gAtoh11luqRNvRVAGfGwisVerqT
	 sxspH0U+dgY6R8ZJVJWTnt3TP/2YiB0Jc29iDKSr85odkmnfUwqexp2T0M7ILxIboL
	 kPVIUNplZHHNg==
Date: Sun, 5 Jul 2026 13:15:27 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-block@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>
Subject: Re: [PATCH v2 04/17] fscrypt: Fully disallow IV_INO_LBLK_32 with
 s_blocksize != PAGE_SIZE
Message-ID: <20260705201527.GH41916@quark>
References: <20260705194555.75030-1-ebiggers@kernel.org>
 <20260705194555.75030-5-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260705194555.75030-5-ebiggers@kernel.org>

On Sun, Jul 05, 2026 at 12:45:41PM -0700, Eric Biggers wrote:
> FSCRYPT_POLICY_FLAG_IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE works
> only with the fs-layer implementation of file contents encryption, not
> blk-crypto.  This is a problem for standardizing on blk-crypto.
> 
> Fortunately, no one should be using this combination anyway.  It doesn't
> make sense because the entire point of IV_INO_LBLK_32 is to support
> inline encryption hardware that is limited to 32-bit DUNs.
> 
> Thus, fully disallow IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>

Sashiko doesn't like that this would break compatibility of existing
directories using FSCRYPT_POLICY_FLAG_IV_INO_LBLK_32 if someone updates
their kernel to use a different page size.  I think we'll just have to
take the risk here.  I'm pretty confident this scenario isn't being
relied on in practice, for various reasons including the one mentioned.

- Eric
