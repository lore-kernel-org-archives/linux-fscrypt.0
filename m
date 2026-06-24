Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 26A73369D6D
	for <linux-fscrypt@vger.kernel.org>; Wed, 24 Jun 2026 11:40:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782301260; cv=none; b=FtH8OVLd4HWBVnnATOb/IDB2dz7OjsUo/+2nV+Gwd5U2ELwhZ1ECfOGoOR32vRwiJB7ZM4298+2BuqAOB+DDPjIlL4vS7ms0Zrm4bMO4lvqqiqS1nN7aD/meqAoWdz15S2M0D4HJ/dJe66kLlO6wRjOPBAx16rQ+BsPGjvyj3pQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782301260; c=relaxed/simple;
	bh=K1fFXIxaesd+eFthXGatCw4ranSCgFqT9wKribOcSsc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=OXdJM6RSlxaZKMJzKzgCqf8VHWcMSNoD7CuXyT2o0gtuD6tI+5oQz5C5DaO8uUfrSyJlqRyowclrCfCdgvv/U9BztiE81/CAeiaGZrOyippLQwv2JTDKe9xSccBtvUV7VTeNbE6ABCh4MiFabS5iaSk8JtYe+7jKyL0UCOM/zOs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=hF6NfODF; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=GY8PcayC; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=hF6NfODF; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=GY8PcayC; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="hF6NfODF";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="GY8PcayC";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="hF6NfODF";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="GY8PcayC"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 684BF71314;
	Wed, 24 Jun 2026 11:40:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1782301257; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=1FWZgxDjSUCom9Re05WOOJuJNeJjEZN52wMGosALaUs=;
	b=hF6NfODFPkCXvzr0SSHA/NliEy6UInLzHmobMqkJkWJfYWzdB1aaFCcQ3SiNrr4QQigZ61
	IOck3SKBclnNectWeI+wu8MiofOCvj0ZXWfpy+xmlOOYlUfZExVRabhPdzvAJwfpomETeR
	45DUjs7WXol1xxnSafaemMVirLgl+FA=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1782301257;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=1FWZgxDjSUCom9Re05WOOJuJNeJjEZN52wMGosALaUs=;
	b=GY8PcayCGoSTcAmLpIduGlP87R01qakK2tGhInNlAk5tsyVp1pmYg7EgUSRtXuSA9+T442
	xJqVt0prij7hymBA==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1782301257; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=1FWZgxDjSUCom9Re05WOOJuJNeJjEZN52wMGosALaUs=;
	b=hF6NfODFPkCXvzr0SSHA/NliEy6UInLzHmobMqkJkWJfYWzdB1aaFCcQ3SiNrr4QQigZ61
	IOck3SKBclnNectWeI+wu8MiofOCvj0ZXWfpy+xmlOOYlUfZExVRabhPdzvAJwfpomETeR
	45DUjs7WXol1xxnSafaemMVirLgl+FA=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1782301257;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=1FWZgxDjSUCom9Re05WOOJuJNeJjEZN52wMGosALaUs=;
	b=GY8PcayCGoSTcAmLpIduGlP87R01qakK2tGhInNlAk5tsyVp1pmYg7EgUSRtXuSA9+T442
	xJqVt0prij7hymBA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 5C833779A8;
	Wed, 24 Jun 2026 11:40:57 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id PNKTFknCO2p9HgAAD6G6ig
	(envelope-from <jack@suse.cz>); Wed, 24 Jun 2026 11:40:57 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id EADF4A093E; Wed, 24 Jun 2026 13:40:56 +0200 (CEST)
Date: Wed, 24 Jun 2026 13:40:56 +0200
From: Jan Kara <jack@suse.cz>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, 
	linux-block@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>, 
	Andreas Dilger <adilger.kernel@dilger.ca>, Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>, 
	Ojaswin Mujoo <ojaswin@linux.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, 
	Zhang Yi <yi.zhang@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>
Subject: Re: [PATCH 10/16] fs/buffer: Remove fs-layer decryption code
Message-ID: <hu7h6ga2ndrsedjvjbemdevjzrhvtz7jx2hbc2rtmkskufckmi@yf3a6t4hhike>
References: <20260624050334.124606-1-ebiggers@kernel.org>
 <20260624050334.124606-11-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260624050334.124606-11-ebiggers@kernel.org>
X-Spam-Flag: NO
X-Spam-Score: -2.30
X-Spamd-Result: default: False [-2.30 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	RCPT_COUNT_TWELVE(0.00)[16];
	TAGGED_RCPT(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	TO_DN_SOME(0.00)[];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[vger.kernel.org,lists.sourceforge.net,lst.de,mit.edu,dilger.ca,linux.alibaba.com,suse.cz,linux.ibm.com,gmail.com,huawei.com,kernel.org];
	RCVD_COUNT_THREE(0.00)[3];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Level: 

On Tue 23-06-26 22:03:28, Eric Biggers wrote:
> Now that fscrypt's file contents en/decryption is always implemented
> using blk-crypto when the filesystem is block-based, the fs-layer
> decryption code in fs/buffer.c is unused code.  Remove it.
> 
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>

Fine by me. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/buffer.c | 45 ++++++++-------------------------------------
>  1 file changed, 8 insertions(+), 37 deletions(-)
> 
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 9af5f061a1f8..21dd9596a941 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -334,82 +334,53 @@ static void end_buffer_async_read(struct buffer_head *bh, int uptodate)
>  
>  still_busy:
>  	spin_unlock_irqrestore(&first->b_uptodate_lock, flags);
>  }
>  
> -struct postprocess_bh_ctx {
> +struct verify_bh_ctx {
>  	struct work_struct work;
>  	struct buffer_head *bh;
>  	struct fsverity_info *vi;
>  };
>  
>  static void verify_bh(struct work_struct *work)
>  {
> -	struct postprocess_bh_ctx *ctx =
> -		container_of(work, struct postprocess_bh_ctx, work);
> +	struct verify_bh_ctx *ctx =
> +		container_of(work, struct verify_bh_ctx, work);
>  	struct buffer_head *bh = ctx->bh;
>  	bool valid;
>  
>  	valid = fsverity_verify_blocks(ctx->vi, bh->b_folio, bh->b_size,
>  				       bh_offset(bh));
>  	end_buffer_async_read(bh, valid);
>  	kfree(ctx);
>  }
>  
> -static void decrypt_bh(struct work_struct *work)
> -{
> -	struct postprocess_bh_ctx *ctx =
> -		container_of(work, struct postprocess_bh_ctx, work);
> -	struct buffer_head *bh = ctx->bh;
> -	int err;
> -
> -	err = fscrypt_decrypt_pagecache_blocks(bh->b_folio, bh->b_size,
> -					       bh_offset(bh));
> -	if (err == 0 && ctx->vi) {
> -		/*
> -		 * We use different work queues for decryption and for verity
> -		 * because verity may require reading metadata pages that need
> -		 * decryption, and we shouldn't recurse to the same workqueue.
> -		 */
> -		INIT_WORK(&ctx->work, verify_bh);
> -		fsverity_enqueue_verify_work(&ctx->work);
> -		return;
> -	}
> -	end_buffer_async_read(bh, err == 0);
> -	kfree(ctx);
> -}
> -
>  /*
>   * I/O completion handler for block_read_full_folio() - folios
>   * which come unlocked at the end of I/O.
>   */
>  static void bh_end_async_read(struct bio *bio)
>  {
>  	struct buffer_head *bh;
>  	bool uptodate = bio_endio_bh(bio, &bh);
>  	struct inode *inode = bh->b_folio->mapping->host;
> -	bool decrypt = fscrypt_inode_uses_fs_layer_crypto(inode);
>  	struct fsverity_info *vi = NULL;
>  
>  	/* needed by ext4 */
>  	if (bh->b_folio->index < DIV_ROUND_UP(inode->i_size, PAGE_SIZE))
>  		vi = fsverity_get_info(inode);
>  
> -	/* Decrypt (with fscrypt) and/or verify (with fsverity) if needed. */
> -	if (uptodate && (decrypt || vi)) {
> -		struct postprocess_bh_ctx *ctx = kmalloc_obj(*ctx, GFP_ATOMIC);
> +	/* Verify (with fsverity) if needed. */
> +	if (vi && uptodate) {
> +		struct verify_bh_ctx *ctx = kmalloc_obj(*ctx, GFP_ATOMIC);
>  
>  		if (ctx) {
>  			ctx->bh = bh;
>  			ctx->vi = vi;
> -			if (decrypt) {
> -				INIT_WORK(&ctx->work, decrypt_bh);
> -				fscrypt_enqueue_decrypt_work(&ctx->work);
> -			} else {
> -				INIT_WORK(&ctx->work, verify_bh);
> -				fsverity_enqueue_verify_work(&ctx->work);
> -			}
> +			INIT_WORK(&ctx->work, verify_bh);
> +			fsverity_enqueue_verify_work(&ctx->work);
>  			return;
>  		}
>  		uptodate = false;
>  	}
>  	end_buffer_async_read(bh, uptodate);
> -- 
> 2.54.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
