Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3987883F
	for <linux-fscrypt@vger.kernel.org>; Mon, 23 Feb 2026 13:22:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771852971; cv=none; b=dOjvyaEYzcdKRzbny7aLt13KMlvyOUHAYGhiPnr61dKtWQGv5ETb6fOfCCaOS4uGi7zUcXNCACQhnds7fkvwd/u2vxDp5vtTlxuTPpb7G1U0R5GyyK0/hfwHECWo657cufIqB7KIm/73AafQtZfmUnZpMjodrprJFErhRsXJYmw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771852971; c=relaxed/simple;
	bh=0s+1xYOmLxGL/YAJHo9cKB+lTpl0y7L08ahwhMvrkEQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=tOAyz1SxpYZuR7REbtkyd/eX5fFtG2KXBt6pP/cUPnPNKyzsvWD1GmMZirgH3UaJlII0t1NdvIS0ywnFWrw68unD+49gU2ilaTDxaBE1fAlqx7ahDeqpaJMeF6Dadssfm+BdVPmLOIK5+zAUrtmHUpJaN+334j0H18sru4E2d4Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jeCma4x8; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jeCma4x8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3558AC116C6;
	Mon, 23 Feb 2026 13:22:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771852970;
	bh=0s+1xYOmLxGL/YAJHo9cKB+lTpl0y7L08ahwhMvrkEQ=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=jeCma4x8Y9qhEKAJkO3pP2yMUhuMGqI7YjXszcxTOjJf1nMuxj4aNKw9In7B+VBl4
	 3EKYO1OdKtOskNPJKkqBKsWXedHwkQibA2TicHRB2WuRhycmH4EvakC/Z78U4mhdkP
	 cDwyZhPqZjcMkRu05a2+HXN47jusCH5GNgvQorQ06FSE71saAbhEZSYjvzMdoQsksu
	 AnG7CiMdGFK0ZFPdwJEt4/xIJGLBYkWkHlzfRykg8Ec8DteOaOd//shp6EyoAzFJ58
	 B8xeg2vaLDa9vgKY14LVP6e3MWyPNZk1f6MKlSiluqjXvO8KsRn3vSEg+v++u89jjb
	 mPd4JqPIUYXzg==
Message-ID: <94f41e2a-53c1-4b7c-8f6c-4553ae729608@kernel.org>
Date: Mon, 23 Feb 2026 14:22:45 +0100
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] f2fs: remove unreachable code in f2fs_encrypt_one_page()
To: Eric Biggers <ebiggers@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>,
 Chao Yu <chao@kernel.org>, linux-f2fs-devel@lists.sourceforge.net
Cc: linux-fscrypt@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
 Vlastimil Babka <vbabka@suse.cz>
References: <20260221201316.22025-1-ebiggers@kernel.org>
From: "Vlastimil Babka (SUSE)" <vbabka@kernel.org>
Content-Language: en-US
In-Reply-To: <20260221201316.22025-1-ebiggers@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 2/21/26 21:13, Eric Biggers wrote:
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

Acked-by: Vlastimil Babka (SUSE) <vbabka@kernel.org>

Thanks!

> ---
>  fs/f2fs/data.c | 14 ++------------
>  1 file changed, 2 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
> index 338df7a2aea6..400f0400e13d 100644
> --- a/fs/f2fs/data.c
> +++ b/fs/f2fs/data.c
> @@ -2785,33 +2785,23 @@ static void f2fs_readahead(struct readahead_control *rac)
>  int f2fs_encrypt_one_page(struct f2fs_io_info *fio)
>  {
>  	struct inode *inode = fio_inode(fio);
>  	struct folio *mfolio;
>  	struct page *page;
> -	gfp_t gfp_flags = GFP_NOFS;
>  
>  	if (!f2fs_encrypted_file(inode))
>  		return 0;
>  
>  	page = fio->compressed_page ? fio->compressed_page : fio->page;
>  
>  	if (fscrypt_inode_uses_inline_crypto(inode))
>  		return 0;
>  
> -retry_encrypt:
>  	fio->encrypted_page = fscrypt_encrypt_pagecache_blocks(page_folio(page),
> -					PAGE_SIZE, 0, gfp_flags);
> -	if (IS_ERR(fio->encrypted_page)) {
> -		/* flush pending IOs and wait for a while in the ENOMEM case */
> -		if (PTR_ERR(fio->encrypted_page) == -ENOMEM) {
> -			f2fs_flush_merged_writes(fio->sbi);
> -			memalloc_retry_wait(GFP_NOFS);
> -			gfp_flags |= __GFP_NOFAIL;
> -			goto retry_encrypt;
> -		}
> +					PAGE_SIZE, 0, GFP_NOFS);
> +	if (IS_ERR(fio->encrypted_page))
>  		return PTR_ERR(fio->encrypted_page);
> -	}
>  
>  	mfolio = filemap_lock_folio(META_MAPPING(fio->sbi), fio->old_blkaddr);
>  	if (!IS_ERR(mfolio)) {
>  		if (folio_test_uptodate(mfolio))
>  			memcpy(folio_address(mfolio),
> 
> base-commit: 8934827db5403eae57d4537114a9ff88b0a8460f

