Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795453854;
	b=q9Bg0qn+A+o0ur0/xK206pd4PUtWFQ5mfdC8kesMX/jCiv50c3HWKUaGO0Lo8+j863i/
	 YaHgd5HGvf//zriDjJcNnrFGHMz9V/ULN4cWAe3Kal4oqT2GlugyeZW7gq4o2/Gf1ZXO6
	 F90adjI0uPLtljQmojjv+UEwQqXfJTwwmKxdHYRl4jb9ny4vfW9juK5bvwTmAF9oBpkoj
	 JYJNxO0tWcsjdPmcN26wZ0W8d9dglcTX0vvWb5O0Lft1qHR3x5dwpJh3JaVvJW5NS5Ki1
	 zP7tc+R7+dFq7/+zoPLUueUr1RQf8HZJtsSlHTegjCmKnXEGKx1fECf5VTuBaMEwo5g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795453854;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Rspamd-Queue-Id:X-Spam-Level:X-Rspamd-Server:
	 X-Rspamd-Action:X-Spam-Flag:X-Spamd-Result:X-Spam-Score;
	bh=/kG84OV1svRUYxEC9cAvJgk73HRiyZOTxHBca81Xqek=;
	b=W9SbyjDUyU+wdyFbWtHRJjLWjT3t4HzyxHlZTKzC+8Dp9NCmU02vz6r4GAMfTeUwEBAn
	 XdCRsDONMoPNPqfQWr6J76F+SWgzOxjcumHp/76kzh9KxR7haZScvKV1pcQSZzNJpYFq4
	 J+5QbrL+/1hmfnTXfBedSvG6gdN6v1ueq3MjEFFav8HEX/SRsEtsjcwcA0d5q8T6kZBHU
	 R6kWVUb1slnZfW4wIfYsb2YF/gEbvbD5QdPEB0XIaIhKmaLX68N8aPPwNNXr7Im1ifYpW
	 BjG9cxt5FV5YjEcxbfYLOx3tJ3lra336+Hk/hQc60o6tetLTobne3sscuC7WjfOIYyQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=w6AcXesO;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=uk+7dI8H;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="k/9dx0+8";
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=VNtsusfa;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1CB1A606A338
	for <linux-fscrypt@vger.kernel.org>; Mon, 23 Nov 2026 17:10:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1CB1A606A338
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=w6AcXesO;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=uk+7dI8H;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=k/9dx0+8;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=VNtsusfa
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 0A18E220FE;
	Mon, 23 Nov 2026 17:10:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795453851; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=/kG84OV1svRUYxEC9cAvJgk73HRiyZOTxHBca81Xqek=;
	b=w6AcXesOZ5YH48nwr4/Zbb2OvihyNPpA2GaS8A7O9z2oG9GBWmJ/46kSzJKa3VCgso4cw2
	JZ4Hnb8sCgjDmnuMc+nIKSwP7dJLbQYA5qcgFiKSaOq9rPRJG87wC5i6XEzABIsGUQJrjL
	mGPiW62u6voVv5zLFWZVR2/IFAMZr5A=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795453851;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=/kG84OV1svRUYxEC9cAvJgk73HRiyZOTxHBca81Xqek=;
	b=uk+7dI8Hik0pNcS54lE0y3ylpW9rFqPZ/mPScz0rW6mN1wlfQSe8bME/EGxR9Ab6udLZqR
	1XWUwDEX3tW9VtCQ==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b="k/9dx0+8";
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=VNtsusfa
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1795453850; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=/kG84OV1svRUYxEC9cAvJgk73HRiyZOTxHBca81Xqek=;
	b=k/9dx0+842+5FtGIhxu7+7wPqr47yYCQpQ+WNd8f8xnShoAIDvn9O0jk9JRHRvvnY8kN//
	jiEInyq0HEZOr+uduUd4dgB4Az4HSaYE7DOWdIo/rJumfwtP4xGnueR8ctNQpcSf2n58Jt
	XVCWDpRbwlVe9lEYdHPr6fUoiyS5SHs=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1795453850;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=/kG84OV1svRUYxEC9cAvJgk73HRiyZOTxHBca81Xqek=;
	b=VNtsusfa+lQYA7pWPGu0Ny1HCtp7roepllJpMCXv8C23shYPD3duAhMPyEnc0n1KJWbwqK
	s8LYDkt36KmCbxCQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id A6C1913510;
	Mon, 23 Nov 2026 17:10:49 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id MyN8IJlzBGvvAwAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 23 Nov 2026 17:10:49 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id E2AEA27683; Mon, 23 Nov 2026 18:10:38 +0100 (CET)
Date: Mon, 23 Nov 2026 18:10:38 +0100
From: Jan Kara <jack@suse.cz>
To: sashiko-reviews@lists.linux.dev
Cc: Jan Kara <jack@suse.cz>, Christian Brauner <brauner@kernel.org>, 
	Andreas Gruenbacher <agruenba@redhat.com>, gfs2@lists.linux.dev, Mike Marshall <hubcap@omnibond.com>, 
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, Dave Kleikamp <shaggy@kernel.org>, 
	Carlos Maiolino <cem@kernel.org>, David Howells <dhowells@redhat.com>, 
	Marc Dionne <marc.dionne@auristor.com>, Miklos Szeredi <miklos@szeredi.hu>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, Eric Biggers <ebiggers@kernel.org>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, Anna Schumaker <anna@kernel.org>
Subject: Re: [PATCH v3 13/13] fs: Use inode_or_folios_dirty() in
 __inode_lru_list_add()
Message-ID: <mlnoenfbwzynuicu56rrmw7go5ijomamaidrsarjbmplsqrcjr@bdpui3vcohcg>
References: <20261123085601.21199-1-jack@suse.cz>
 <20261123090040.19006-26-jack@suse.cz>
 <sashiko-outbox-228978@kernel.org>
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
In-Reply-To: <sashiko-outbox-228978@kernel.org>
X-Rspamd-Queue-Id: 0A18E220FE
X-Spam-Level: 
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spamd-Result: default: False [-13.01 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_COUNT_THREE(0.00)[3];
	ARC_NA(0.00)[];
	SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCPT_COUNT_TWELVE(0.00)[19];
	MIME_TRACE(0.00)[0:+];
	FROM_HAS_DN(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	TO_DN_SOME(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.cz:dkim,suse.cz:email,suse.com:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -13.01

On Mon 23-11-26 09:30:54, sashiko-bot@kernel.org wrote:
> Thank you for your contribution! Sashiko AI review found 1 potential
> issue to consider:
> - [High] fs: UAF of inode->i_mapping in __inode_lru_list_add() after
>   dev_dax teardown
> --
> 
> commit dba191eb05adecdae3b365e1982438c7882c5c1d
> Author: Jan Kara <jack@suse.cz>
> 
> fs: Use inode_or_folios_dirty() in __inode_lru_list_add()
> 
> This commit replaces the I_DIRTY_ALL check in __inode_lru_list_add() with a
> call to inode_or_folios_dirty().
> 
> > diff --git a/fs/inode.c b/fs/inode.c
> > index de207f2f95a98..fb759033aa965 100644
> > --- a/fs/inode.c
> > +++ b/fs/inode.c
> > @@ -552,7 +552,9 @@ static void __inode_lru_list_add(struct inode *inode, bool rotate)
> >  {
> >  	lockdep_assert_held(&inode->i_lock);
> >  
> > -	if (inode_state_read(inode) & (I_DIRTY_ALL | I_SYNC | I_FREEING | I_WILL_FREE))
> > +	if (inode_state_read(inode) & (I_SYNC | I_FREEING | I_WILL_FREE))
> > +		return;
> > +	if (inode_or_folios_dirty(inode))
> >  		return;
> 
> [Severity: High]
> Can inode_or_folios_dirty() cause a use-after-free on inode->i_mapping
> when a device-dax character special file inode is added to the LRU after
> dev_dax teardown?
> 
> Unlike mapping_shrinkable(&inode->i_data) below and the other LRU and
> eviction paths in fs/inode.c, inode_or_folios_dirty() dereferences
> inode->i_mapping via mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)
> whenever I_DIRTY_ALL is clear.

Hrm, this is right. We'd need to check inode->i_data and not
inode->i_mapping. Christian, please just drop this patch. The code is
correct as is (we hold i_lock) and the helper would do more harm than good
here.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
