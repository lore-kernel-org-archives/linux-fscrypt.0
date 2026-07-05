Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36F87258EE9;
	Sun,  5 Jul 2026 19:11:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783278671; cv=none; b=h9QpTQZA0x1J0eO331NzwB694Pfx9NoQkRDf5rxJzzBMSvw9MJLrfifcXbaOJyQgiJ6SAJoGHj3ZDHvPFEciLjfMG2Y3KKIIeu00FE8hce9dKTwmS3GtvWvITGIn9uA2b4ByHnhguurcGUO8Dtz9Sb1nfbPH9UToqEMUre0bziA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783278671; c=relaxed/simple;
	bh=nEbUL8VzNGr2cV2A+r8SXhMi1vSeK8Q4oSPypjUXT3c=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=nAMeDJSMyTCl5EdXUI6lc7W/RPlf9bxe+et+R3fLc1YIld7yeNbApOv9b3358Lg+b64q3dST0N5S4CFl9Vph0R20E4FhnUjz4L5Bn9qXqzzp2SHTm0hBGdJQQ2ksAyfYPrl88DrSppRGet8CxhyJ9jJlvKUkHwmzBf8P3P0LqXc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SemxVThV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SemxVThV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ACE771F000E9;
	Sun,  5 Jul 2026 19:11:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783278669;
	bh=axwfpVNbAgEBwVQMUNeeaZnKAq8IlWldmJIEc03VvgU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=SemxVThVD2kkA0yw2lb5tTxJMQkt8Vkv1t5D1djaka36Y31B2hPpuBE0NzvXeOeJB
	 7E6w+Mm6dXT7y+jg9B+prfb7kggOPQM3Pe3No3EOlSRtt3TJBoId9wDwDAK1rjD994
	 8QneKpwpAPE3QFFrd8oFuodHD+eRQDBXF3u9Wsk0rCIKNRkiiJKws+6SPdDUvg9Ewt
	 3MFrPO/NPvNJCsSyf5M9HBQq+CX62da97AmiYlh0NEIOMFb8/tm8JGSbffk1l6A+KJ
	 oy/GU8cePEAuKzVHzUamSuhB5w6SyJLMOok3T4DZHXbkbpe3Cz97KkJLGeJiU3XXYH
	 zbwSmfiXTH85Q==
Date: Sun, 5 Jul 2026 12:11:07 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Use lock guards for mutexes
Message-ID: <20260705191107.GA41916@quark>
References: <20260618184852.3469301-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260618184852.3469301-1-ebiggers@kernel.org>

On Thu, Jun 18, 2026 at 06:48:52PM +0000, Eric Biggers wrote:
> Replace all remaining calls to mutex_lock() and mutex_unlock() in
> fs/crypto/ with lock guards.  No functional change.
> 
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---
> 
> This is intended to be taken through the fscrypt tree for 7.3
> 
>  fs/crypto/crypto.c   | 13 ++++---------
>  fs/crypto/keyring.c  |  3 +--
>  fs/crypto/keysetup.c | 23 +++++++++++------------
>  3 files changed, 16 insertions(+), 23 deletions(-)

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
