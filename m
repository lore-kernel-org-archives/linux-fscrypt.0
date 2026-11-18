Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794978120;
	b=Be7boUSpsH+YCIt+lUI9Sg7Y9PKIBT/32OIFRripQWD8TDYnY4VUkJS9uqeRwO8jn5Hf
	 wA4ZB83E7MHMyCWUzN7BvXjh/F5zth7GD6MtgX1r8raI1aJ6aWqbHgo6VCU4jsUI6bHS4
	 gPs8cAxhJ7ugxT/Ls7QyIXiG27hpfiPnzkT8LNFgcex8dMN4TrEIyAiMpooVVpH1PMocE
	 YFSRACsx206WCPWlcGuOLHohmssEiQlwdsed7rY5wI7qbFsfCz3ocv2EyEdA4MoU4LovR
	 dD5IkVF/hkeP3mNUmjCmV2o6j7FMFOjX4uQOc3pNhMcfiuKee0c+9cj051Hvy3Gxfhg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794978120;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=buJAxVxDBcGm0+gFbF5F6hAK1IYNZp2MClhpS9+UJjA=;
	b=UAYffMdn3TAyBVsS8Qhe1XuVGjZVTZvMfrnABRN+nvrf1l8a25jCpcl9JSaF83yD1+P9
	 QL5kPqH9GERzG48HCwefz1UTVH2ZnNsvmeZH1UVniG5Rh4IrrT4QzDphquQ1cEEJOD/zW
	 uHrvJLR5ckJBpEYo+zYXjx0xZVvFoTApA8s3gVQ4Uxl9BnOljC7Z3BbCXLu7h7v3iexgo
	 RJhLi3+6uMp0ib1NeOWELHUqBFzX8iEUJz8WI/Qzc3KIcJVTiG2SiY8gwwiUkzqJnmoIe
	 NycDmbprMaxLnnSHgB/4IB29xB/H+LkHbpAHTsC7i65T+G0vWdMT0lwnbO5mRNHgKlA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FfwTOhXU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F6AA606A31C;
	Wed, 18 Nov 2026 05:02:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=FfwTOhXU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7E2DA1F000C4;
	Wed, 18 Nov 2026 05:01:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794978119;
	bh=buJAxVxDBcGm0+gFbF5F6hAK1IYNZp2MClhpS9+UJjA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=FfwTOhXUXPUk+CcNccykVkrwW0f62fCOj8ajYxrUk8D3gwNNG+f0orXOYe7MAP6Ze
	 kGqxVltBqpd1DH89gmYIJRQdkwTRdgv+x1IaHQx05OnBeLDC13/CE/m6d56egTdOhe
	 MvxdTCzQCk1HX7V4XjpEO/fGBS+XbXedJVssoX23MdbTqGwSKvDIHVWj9jYBd13NX7
	 3F6hRp/2gQq3e+Gtf8QXIk2nMYsFwVOVQMeWE03BzAl+P1CvIwyKp9p7mYD4H8y3ti
	 PIYiXHtwECD1jHhA2UZK5V8gyHBn9SCHHgUujAFow9r9rAOwcSXjeyelZGYhONYPmp
	 0zgXOC8W4UxXw==
Date: Tue, 17 Nov 2026 21:01:58 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Thorsten Blum <blum@kernel.org>
Cc: David Sterba <dsterba@suse.com>, Chris Mason <mason@kernel.org>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>,
	Richard Weinberger <richard@nod.at>,
	Zhihao Cheng <chengzhihao1@huawei.com>,
	"Theodore Y. Ts'o" <tytso@mit.edu>, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH 0/4] fscrypt: Add FSTR() helper macro and convert
 initializers
Message-ID: <20261118050158.GC3400@sol>
References: <20261118002845.574426-6-blum@kernel.org>
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
In-Reply-To: <20261118002845.574426-6-blum@kernel.org>

On Wed, Nov 18, 2026 at 01:28:46AM +0100, Thorsten Blum wrote:
> Similar to QSTR(), add FSTR() to initialize struct fscrypt_str from a
> NUL-terminated string without specifying its length.
> 
> Use the helper for 8 initializers in btrfs, F2FS, and UBIFS, replacing
> hard-coded lengths and explicit strlen() calls.

It would be worth stating explicitly that the new strlen() calls are
constant-folded in most configurations (if they indeed are).

- Eric
