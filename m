Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 37960391514
	for <linux-fscrypt@vger.kernel.org>; Wed,  4 Mar 2026 07:53:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772610815; cv=none; b=Rz/5BNmJPbM7F9zWZd9RrGLxA04mE3nDUI+wvKsYQdXgEmBwsoNGBSUNDmb3Wp5TFp2+4PkzkFvqhMCf5Mirp//XcvFWPZruecSFVJYwk4YLgfHiWzbcJQ07dbG2vjT7VqyF3awStQtir95Yb0MSDzbMYy1AEnAks4s92OO8Wlc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772610815; c=relaxed/simple;
	bh=cqOFBwDRyiwFrwYJzDEF/M3/hy2SmgO1cJHU5rE3SQE=;
	h=Message-ID:Date:MIME-Version:Cc:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=P7tHApVzLQ76mm8tOIbv9ucOUcy+1q13/bUvOi54pHrUtfZ6FP09hj8+78TcayuFkYlYUqMCZ2tKQMH9PeQEpXjfyFErMeETxX0tVD4hkFr20O5S1FFSAwjeOk8bUtAVgA2RWFqaZ5HyTonapYwXWYTzHH22BK4r4wMRfV7RtDo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kc+7L5Fe; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kc+7L5Fe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3A42FC19423;
	Wed,  4 Mar 2026 07:53:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772610814;
	bh=cqOFBwDRyiwFrwYJzDEF/M3/hy2SmgO1cJHU5rE3SQE=;
	h=Date:Cc:Subject:To:References:From:In-Reply-To:From;
	b=kc+7L5FepMpDbtxUAF2pVUGExzNt24rIome3JcXsMUgSbi4GF3rnt1cbVxzmDLpWo
	 JW+CHNPuzDTZKSOHE4DuMpjX06k/FRWuMwOZ8IY3z5EBg9uLsCYULYsgM2NrGWHIpV
	 cUfSHWcAi/9RHLyyfK92JU8oQnjLtJQsbMAi1v4pfUBa5ffE311mOquDSXYlXRm6oK
	 MhljSkLRadx99/Mg/zaN1zm5GtZIP6Tbj6q9FWMqOpQ9mumqWDcKPqgZulMApPSkXT
	 9BC46TwzSGEm9PdxW1S9TlooDe5KGnnPp+9V2bmXy5anOllBiSeeLBgLn7aKXgAaZg
	 twI9AjjXq8UAA==
Message-ID: <c0353a3a-418c-4d91-a8e2-1c39c65b6b2b@kernel.org>
Date: Wed, 4 Mar 2026 15:53:03 +0800
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Cc: chao@kernel.org, linux-fscrypt@vger.kernel.org,
 Christoph Hellwig <hch@infradead.org>, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] f2fs: remove unreachable code in f2fs_encrypt_one_page()
To: Eric Biggers <ebiggers@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>,
 linux-f2fs-devel@lists.sourceforge.net
References: <20260221201316.22025-1-ebiggers@kernel.org>
Content-Language: en-US
From: Chao Yu <chao@kernel.org>
In-Reply-To: <20260221201316.22025-1-ebiggers@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 2026/2/22 04:13, Eric Biggers wrote:
> Since commit 52e7e0d88933 ("fscrypt: Switch to sync_skcipher and
> on-stack requests") eliminated the dynamic allocation of crypto
> requests, the only remaining dynamic memory allocation done by
> fscrypt_encrypt_pagecache_blocks() is the bounce page allocation.
> 
> The bounce page is allocated from a mempool.  Mempool allocations with
> GFP_NOFS never fail.  Therefore, fscrypt_encrypt_pagecache_blocks() can
> no longer return -ENOMEM when passed GFP_NOFS.
> 
> Remove the now-unreachable code from f2fs_encrypt_one_page().
> 
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Link: https://lore.kernel.org/all/d9dc2ee1-283d-4467-ad36-a6a4aa557589@suse.cz/
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>

Reviewed-by: Chao Yu <chao@kernel.org>

Thanks,
