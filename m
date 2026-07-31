Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9EF553CB567
	for <linux-fscrypt@vger.kernel.org>; Fri, 31 Jul 2026 11:57:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785499067; cv=none; b=hHk2cotGH09SdO4LV28YO9q866WkwEkEFynDCzJIvIOdQiJZO4huydOKWyWL79VdDDx5cjZc5t4wCnqGjrKyBS+EL4AXqtXOkbi/1clOyvnXWAyrkz6Q+bsqcNLeB1j+9BTYdYIKVOdHa5U+e7UhIoD26NeKSE62dFXRrYWSmG0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785499067; c=relaxed/simple;
	bh=4ebNtaYM47g+iC2MCt63BN9zreli2zWZpF2+WlYW8I0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=aOMxD87L67YEdi9t93ZVVcTnAFg/BG/gwJeDPY10qsSO9hW99qCJg38UkboKHir8hSW6ftzESoNfv7QGC2sqpL12PZI0wTWfX2vLbL6gR0+TBbCsQPFr984w26YPT1jyboz09LFDk7YbqzSRv4Iocc1KSABqLdFo3roYxDQ573c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=gCOk0P3G; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=+0wE5aTs; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=u8+nXhWi; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=h43eim/X; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="gCOk0P3G";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="+0wE5aTs";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="u8+nXhWi";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="h43eim/X"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id A7A2F410C;
	Fri, 31 Jul 2026 11:57:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1785499053; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cTgMwaWPzZIqwwhLFXF76DzOC7OTGrQ4O4jIUUHt9oQ=;
	b=gCOk0P3GD5dKzTvHX7KVbUTO+wjDO5o+CRD0LHZHqlfvWA5G9X1+DImySUQsB0BTffUxCf
	swMLe1ddV506Y+KTtd8u5sRkLXFRNN1avxVSQ61o9xEO3XP5ZgvKuPIR2YeEt+0kgV3J89
	Ava/ERfm9lsLF0cXcrvt/N9WzOD3/es=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1785499053;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cTgMwaWPzZIqwwhLFXF76DzOC7OTGrQ4O4jIUUHt9oQ=;
	b=+0wE5aTs2t+Temb2JJ7AoVE/qmIOek2/I/g3a7nFtWSuVx8uAWjcejv4geLaj5LEua8HWM
	jNBBA8KfN81bWpBg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1785499049; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cTgMwaWPzZIqwwhLFXF76DzOC7OTGrQ4O4jIUUHt9oQ=;
	b=u8+nXhWie/a1eXCl5tAmd9P5krNGYfWuSVTcTicn48zMiF74vkdqQyztJE/p2f21tH6LAx
	c7NJGVx2/5FUnjnPQ5WUoe4WgHhaMdOmsPr8H1c26cn5g6RUZJngglBaMkgLDNRSU+5bxV
	0hFA4mbY/4sjH3Mw/lafUGqHaO9jsgo=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1785499049;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cTgMwaWPzZIqwwhLFXF76DzOC7OTGrQ4O4jIUUHt9oQ=;
	b=h43eim/XTeHwYYQc5OzZYiWItp2+ynW/A5GFBpA6jyBhGA8jiANwBIFpgeKEoFjl9aPMCb
	1mUytZ3vslI0neBw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 87FD1779B0;
	Fri, 31 Jul 2026 11:57:29 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id qjwtIamNbGr8ZwAAD6G6ig
	(envelope-from <jack@suse.cz>); Fri, 31 Jul 2026 11:57:29 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 2BEACA13A4; Fri, 31 Jul 2026 13:57:29 +0200 (CEST)
Date: Fri, 31 Jul 2026 13:57:29 +0200
From: Jan Kara <jack@suse.cz>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, 
	Andreas Dilger <adilger.kernel@dilger.ca>, Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>, 
	Ojaswin Mujoo <ojaswin@linux.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, 
	Zhang Yi <yi.zhang@huawei.com>, Ira Weiny <iweiny@kernel.org>, linux-fscrypt@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Disha Goel <disgoel@linux.ibm.com>, stable@vger.kernel.org
Subject: Re: [PATCH] ext4: don't enable DAX on new encrypted files
Message-ID: <4ramlo3giiu63es2enlu5ebbg5swq27pc45b2yso33pp3gtmgr@yd5hfhglyi6d>
References: <20260730175212.36923-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260730175212.36923-1-ebiggers@kernel.org>
X-Spam-Score: -2.30
X-Spam-Level: 
X-Spam-Flag: NO
X-Spamd-Result: default: False [-2.30 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	MISSING_XM_UA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[14];
	TAGGED_RCPT(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	TO_DN_SOME(0.00)[];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[vger.kernel.org,mit.edu,dilger.ca,linux.alibaba.com,suse.cz,linux.ibm.com,gmail.com,huawei.com,kernel.org];
	RCVD_COUNT_THREE(0.00)[3];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo,suse.cz:email]

On Thu 30-07-26 10:52:12, Eric Biggers wrote:
> Currently, when a new encrypted regular file is created, the call to
> ext4_set_inode_flags(inode, init=true) in __ext4_new_inode() is made
> before EXT4_INODE_ENCRYPT is set.  As a result, it can set S_DAX if the
> filesystem is mounted with "-o dax=always".
> 
> EXT4_INODE_ENCRYPT then actually gets set a bit later in
> __ext4_new_inode(), when it calls fscrypt_set_context() which calls
> ext4_set_context().  ext4_set_context() sets EXT4_INODE_ENCRYPT and
> calls ext4_set_inode_flags(inode, init=false) to set S_ENCRYPTED too.
> 
> This was intended to clear S_DAX as well.  However, this was broken by
> commit 043546e46dc7 ("fs/ext4: Only change S_DAX on inode load").  This
> causes data written to the file to bypass encryption, also causing
> xfstests failures such as generic/548 (when "-o dax=always" is used).
> 
> Fix this by simplifying the flow by making __ext4_new_inode() set
> EXT4_INODE_ENCRYPT earlier.  This makes it take effect in
> ext4_set_inode_flags(inode, init=true), making S_DAX never be set.
> 
> Similarly, make EXT4_STATE_MAY_INLINE_DATA never be set in the first
> place on new encrypted inodes.  Then it doesn't need to be cleared.
> 
> As a result of these simplifications, ext4_set_context() no longer needs
> to change inode flags or state when 'handle != NULL'.  Remove that too.
> 
> Reported-by: Disha Goel <disgoel@linux.ibm.com>
> Reported-by: Ojaswin Mujoo <ojaswin@linux.ibm.com>
> Closes: https://lore.kernel.org/r/20260723085648.1500357-1-ojaswin@linux.ibm.com
> Fixes: 043546e46dc7 ("fs/ext4: Only change S_DAX on inode load")
> Cc: stable@vger.kernel.org
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>

Looks good! Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/ext4/crypto.c | 40 ++++++++++++++++++++--------------------
>  fs/ext4/ialloc.c |  4 ++++
>  2 files changed, 24 insertions(+), 20 deletions(-)
> 
> diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
> index f41f320f4437..3971986de028 100644
> --- a/fs/ext4/crypto.c
> +++ b/fs/ext4/crypto.c
> @@ -144,7 +144,13 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>  	if (inode->i_ino == EXT4_ROOT_INO)
>  		return -EPERM;
>  
> -	if (WARN_ON_ONCE(IS_DAX(inode) && i_size_read(inode)))
> +	/*
> +	 * For new encrypted inodes, S_DAX is never set in the first place.
> +	 *
> +	 * For existing inodes, this is called only on empty directories.  ext4
> +	 * never sets S_DAX on directories.
> +	 */
> +	if (WARN_ON_ONCE(IS_DAX(inode)))
>  		return -EINVAL;
>  
>  	if (ext4_test_inode_flag(inode, EXT4_INODE_DAX))
> @@ -163,6 +169,14 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>  	 */
>  
>  	if (handle) {
> +		/*
> +		 * __ext4_new_inode() should have already set the encrypt flag
> +		 * on the inode and avoided enabling inline data.
> +		 */
> +		if (WARN_ON_ONCE(!IS_ENCRYPTED(inode)))
> +			return -EINVAL;
> +		if (WARN_ON_ONCE(ext4_test_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA)))
> +			return -EINVAL;
>  		/*
>  		 * Since the inode is new it is ok to pass the
>  		 * XATTR_CREATE flag. This is necessary to match the
> @@ -170,21 +184,10 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>  		 * function with the credits allocated for the new
>  		 * inode.
>  		 */
> -		res = ext4_xattr_set_handle(handle, inode,
> -					    EXT4_XATTR_INDEX_ENCRYPTION,
> -					    EXT4_XATTR_NAME_ENCRYPTION_CONTEXT,
> -					    ctx, len, XATTR_CREATE);
> -		if (!res) {
> -			ext4_set_inode_flag(inode, EXT4_INODE_ENCRYPT);
> -			ext4_clear_inode_state(inode,
> -					EXT4_STATE_MAY_INLINE_DATA);
> -			/*
> -			 * Update inode->i_flags - S_ENCRYPTED will be enabled,
> -			 * S_DAX may be disabled
> -			 */
> -			ext4_set_inode_flags(inode, false);
> -		}
> -		return res;
> +		return ext4_xattr_set_handle(handle, inode,
> +					     EXT4_XATTR_INDEX_ENCRYPTION,
> +					     EXT4_XATTR_NAME_ENCRYPTION_CONTEXT,
> +					     ctx, len, XATTR_CREATE);
>  	}
>  
>  	res = dquot_initialize(inode);
> @@ -205,10 +208,7 @@ static int ext4_set_context(struct inode *inode, const void *ctx, size_t len,
>  				    ctx, len, 0);
>  	if (!res) {
>  		ext4_set_inode_flag(inode, EXT4_INODE_ENCRYPT);
> -		/*
> -		 * Update inode->i_flags - S_ENCRYPTED will be enabled,
> -		 * S_DAX may be disabled
> -		 */
> +		/* Update inode->i_flags to set S_ENCRYPTED. */
>  		ext4_set_inode_flags(inode, false);
>  		res = ext4_mark_inode_dirty(handle, inode);
>  		if (res)
> diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
> index a40cb27f8116..a5831fc536db 100644
> --- a/fs/ext4/ialloc.c
> +++ b/fs/ext4/ialloc.c
> @@ -997,6 +997,8 @@ struct inode *__ext4_new_inode(struct mnt_idmap *idmap,
>  		err = fscrypt_prepare_new_inode(dir, inode, &encrypt);
>  		if (err)
>  			goto out;
> +		if (encrypt)
> +			i_flags |= EXT4_ENCRYPT_FL;
>  	}
>  
>  	err = dquot_initialize(inode);
> @@ -1306,6 +1308,8 @@ struct inode *__ext4_new_inode(struct mnt_idmap *idmap,
>  	ei->i_extra_isize = sbi->s_want_extra_isize;
>  	ei->i_inline_off = 0;
>  	if (ext4_has_feature_inline_data(sb) &&
> +	    /* Encrypted inodes cannot have inline data */
> +	    !(ei->i_flags & EXT4_ENCRYPT_FL) &&
>  	    (!(ei->i_flags & (EXT4_DAX_FL|EXT4_EA_INODE_FL)) || S_ISDIR(mode)))
>  		ext4_set_inode_state(inode, EXT4_STATE_MAY_INLINE_DATA);
>  	ret = inode;
> 
> base-commit: f5098b6bae761e346ebcd9da7f95622c04733cff
> -- 
> 2.55.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
