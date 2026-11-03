Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793745608;
	b=odta8g/AhpJOmF+sayLwhKfP9pu0v+TN+mTujUJ8RvkiXJ+fkj2GqOkhyY/jpIzubEwn
	 6iJh2zqzzs20Nw+qfdMMufhxvalctusZB0luyLIRcVqlFjfqHxsy/OXVwBJZsn3dIHdAA
	 +FOsU3Y/Q3OhINTT2luIfXheDq3tEWxePnAQfdOGjHWq6ToXsb0Y/ltWE8qPh31HsoZMR
	 c3KNaMjF8dU3mypSXF21pKTIOKUI0I2YH4ISfmnn9lepaCpaFtBy9lHyXWseRg+qfbeuQ
	 3CJmn6aZrKkknm7LhwMXBQ5CcF1yGxQn5kh2LzY56UIberxf7H0duJmxkXPAewPnkJA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793745608;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=dUEcv/MhjejPHmrcC/hqEGgmsco9xyikaqobVQKO0YY=;
	b=S/JYKPEHhzqFUC3DQEC6MNJqnVLB6bdvOEMKoSaapok48luhohxUvConqgleSdPeXU8q
	 O3lvnlAzdvgpLppeSthyMdo13ySNl0Xis/bl45XwQquS/5xz1swNGNVUORC92VA5dOKJ4
	 3GpGxpAyodvKHv3D7K78zeFRUFIexXDbrU4E09erSBLKyRvmQTCoAm8Qqr4LOs9jkeufG
	 UzJxqqfnWjcct445swYJe4Y24keL23DoGwPBR/b95wCoY2z/1qpxJ8/9sVDu/OB7IUadl
	 srUlZ0T59CZeh34P7GnMqGAQzGd8uIqhi7gNn/NjzRUJhHJCF/MCJWqJ07d4uzlkJGg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bxGTlxWt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3CF2606A326;
	Tue,  3 Nov 2026 22:40:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bxGTlxWt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2D1F71F000C1;
	Tue,  3 Nov 2026 22:40:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793745608;
	bh=dUEcv/MhjejPHmrcC/hqEGgmsco9xyikaqobVQKO0YY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=bxGTlxWtkIXT16CSYrycZF+3yQIFZzteNGUn/wvC+uY5HUgsRJsRONapbcP8Xn8QT
	 cvT9XGvvYgjX4uC6bDYlnLVa+v6se1zJmHVGzZwrI1L6+LL2CJ8My58I80BsczFH0o
	 dIiJL251RpctvSa52xq90EzpWx+Pmd+6yEZNv9awr0NqwHWMHRqK6TMjDiQtTKd3ox
	 uwhddIF85AqYC/CsvrdiIE7VT9S+buNAPS9BbjNNL9TmJKkiTES9RVZt0J1j1N+y4C
	 qgpOx1/oKrbIn9BflRcELCzbROkXgkV8OT3JUtLIhYHAaZWiF42XWjZ3bSlqgD6LpY
	 D1kqafzMMan7w==
Date: Tue, 3 Nov 2026 14:40:06 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Baokun Li <libaokun@linux.alibaba.com>
Cc: linux-fscrypt@vger.kernel.org, jaegeuk@kernel.org, tytso@mit.edu,
	linux-ext4@vger.kernel.org, adilger.kernel@dilger.ca, jack@suse.cz,
	yi.zhang@huawei.com, ojaswin@linux.ibm.com, ritesh.list@gmail.com,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/4] fscrypt: Cap data units at the page size
Message-ID: <20261103224006.GC2281@quark>
References: <20261103153132.4154855-1-libaokun@linux.alibaba.com>
 <20261103153132.4154855-2-libaokun@linux.alibaba.com>
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
In-Reply-To: <20261103153132.4154855-2-libaokun@linux.alibaba.com>

On Tue, Nov 03, 2026 at 11:31:29PM +0800, Baokun Li wrote:
> diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
> index e602c31b3844..0dc158563e71 100644
> --- a/fs/crypto/fscrypt_private.h
> +++ b/fs/crypto/fscrypt_private.h
> @@ -203,7 +203,9 @@ static inline int
>  fscrypt_policy_v2_du_bits(const struct fscrypt_policy_v2 *policy,
>  			  const struct inode *inode)
>  {
> -	return policy->log2_data_unit_size ?: inode->i_blkbits;
> +	if (policy->log2_data_unit_size)
> +		return policy->log2_data_unit_size;
> +	return min_t(unsigned int, inode->i_blkbits, PAGE_SHIFT);
>  }

This would make the interpretation of the default value
log2_data_unit_size=0 depend on the page size, which (unlike i_blkbits)
is not part of the filesystem's on-disk format.

I think that for a sub-block data unit size to be used, it should need
to continue to be explicitly specified.  Otherwise the default would
become ambiguous.

- Eric
