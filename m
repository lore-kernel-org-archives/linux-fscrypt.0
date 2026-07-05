Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EDB72FDC30;
	Sun,  5 Jul 2026 20:09:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783282169; cv=none; b=HQ9kKpdA709okP3Xl36o5hkddqpxquHpxmqc68J+pxTRsugQXPLrBKi8GsKXgZE0q/uZFowVljjsyehOFz7Kx6q0g6cReffVl7ZUjAqYnchOyctbPyn/mGrMHJYr9GR80qw53UGjQqkIahlstS6omf0MUseOvJZH7vAVDarwjH4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783282169; c=relaxed/simple;
	bh=hRMnF03ufrAxGtINS47yf7FxGFwn/WyovDL+0tzpcog=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ZsxmJsw8beNqzvsSxb1kMqwg8HkCDpJfyt1EPV+7t6eDd1xAoVVz39XMMJ2PPWvZfkM3uLz8IdaD/UB47LJXy1xftlEfwNO6Rgsp672VjgaVK2N6nsqzQ6EHsvsl2ijAruPeJkc0+0umMXzEZn210NzguTso9mZhaVQzjPNZkKw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Mm/3bpFD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Mm/3bpFD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B67E1F000E9;
	Sun,  5 Jul 2026 20:09:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783282168;
	bh=gadYmpHWMY+QGts0VFp3QV5k1w9S9s1LXnjC9dd9XPk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Mm/3bpFDGGDAGn3pagwlLTUG35H5lJ4MXl3YOHWMDBAJxy9n/uOUvNMI2FFfPBVwA
	 JWqBpp/jC0w0M65gRN5Dro4yiKAaYTh0HQPp8k4zROzc/krdtQXymwOiPtaZFGDJ1Q
	 Qqvk8RUSrWENgFXhy138Ulv8okFBVX1TCvIQWusjSrarWvhwrRRlP4i3TEi+44Xrqd
	 BOKfYdZi6sSs8pLZqIBANG9DZetNes4FEWsFLGxNxNxNjBf7DSVApyDntS7c33mfpd
	 gx/jqHR65l01YM7u/E/+nTKU4w+/yfTwF6+9K7/Jbslmb+wb/yYpbXoBmCI4W5EMQA
	 OhW4w/1qwMquw==
Date: Sun, 5 Jul 2026 13:09:26 -0700
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
Subject: Re: [PATCH v2 03/17] blk-crypto: Allow control over whether hardware
 is used
Message-ID: <20260705200926.GG41916@quark>
References: <20260705194555.75030-1-ebiggers@kernel.org>
 <20260705194555.75030-4-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260705194555.75030-4-ebiggers@kernel.org>

On Sun, Jul 05, 2026 at 12:45:40PM -0700, Eric Biggers wrote:
>  /**
>   * struct blk_crypto_config - an inline encryption key's crypto configuration
>   * @crypto_mode: encryption algorithm this key is for
> @@ -76,13 +85,14 @@ enum blk_crypto_key_type {
>   *	ciphertext.  This is always a power of 2.  It might be e.g. the
>   *	filesystem block size or the disk sector size.
>   * @dun_bytes: the maximum number of bytes of DUN used when using this key
> - * @key_type: the type of this key -- either raw or hardware-wrapped
> + * @flags: BLK_CRYPTO_CFG_* flags
>   */

Sashiko pointed out that I accidentally deleted the @key_type line here.
I'll fix that in the next version.

- Eric
