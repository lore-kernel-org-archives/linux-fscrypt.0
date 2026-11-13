Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564861;
	b=MI/F6fC+7s2pOeeUaKw6KFSfC+DpmvRg/HfpvYLlmeYlis/WiWnqL19JvuskV1VUUYom
	 bZoKRZFg8d7rzQsjPSfPmWQD+/cezZSmp97xUOI0NuwyTIg5K+xwx7VHRCKPoRGQ81ZSw
	 LChQwrwqvO7UBAYwUC2P6SMN1fZl2AclJiXyaTSdCeUvWTthyCEKVqJqK1fBtpffetVk5
	 cKcZZMjAz3+NnwIgNEyZhrdvtHVwu4e4RGPDaPAF2JOqyDMjxkRqiUjDa9frf0TbtrNzU
	 PFSQaaRxEK3vmKVNJIBMdDz8kMUFsKoxOEZM787CkqzZm5hNF/VmrkQTbPQ2cTKEa0g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564861;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To:X-Rspamd-Queue-Id:X-Spam-Level:
	 X-Rspamd-Server:X-Rspamd-Action:X-Spam-Flag:X-Spamd-Result:
	 X-Spam-Score;
	bh=R+BQ3YDqHXKcy+cUyFBlq7lXheFdbpMKJC809gP5ZDs=;
	b=5YqMYHTy/HjOCmpgJDxbNVPsXkb3LpstIn7/XKzxL7igjUIt3mnOgGSVxIWATaSdGgfu
	 /Xlw4lGNrhIaV3pUnUPuy1Cuck41vC4caogtml59VhsYS1wfnnc9KfvOlYIKJDyVT5cGy
	 O/uLVUjXEB8zDhVem0XD207yb92trNWBqB3+zjBTpYxnh8Cwvn8Np9J2lQHDYscxi8AXb
	 2UHCc+lREJEbXrV03l4zlI7Z55oBrW3VV17IgeGuEurdeKSyejIz9jXyyYkpHvnnoHShf
	 8BTrvPYctNHyResPc96+EYmhTo2o6/WFYr4qJPYLgQSmOPuLioYU+f0VA4rSFcBIbIQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=NaAMJIB4;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=w24hAtq1;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=NaAMJIB4;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=w24hAtq1;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41342606A32A
	for <linux-fscrypt@vger.kernel.org>; Fri, 13 Nov 2026 10:14:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 41342606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=NaAMJIB4;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=w24hAtq1;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=NaAMJIB4;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=w24hAtq1
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 0B72721FF3;
	Fri, 13 Nov 2026 10:14:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794564858; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=R+BQ3YDqHXKcy+cUyFBlq7lXheFdbpMKJC809gP5ZDs=;
	b=NaAMJIB45F0M12kv3Hlw1jteSDptA37MX75SoHGxBf3PipyI8harDmWwwNBIk9UjZEya0h
	AFas9hg6DyAZFKcuAadF92EmbDewK7gIQ/vCdYhXChT+9d0EHzlItnN84IYSMlzHmqemNB
	hX+WjidkTG73z0NJoKjo5KGXZ9E92us=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794564858;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=R+BQ3YDqHXKcy+cUyFBlq7lXheFdbpMKJC809gP5ZDs=;
	b=w24hAtq1KJJ3nDdJ1wWSTNKEujiR92Lr29qv0lG6oGR1bgVxlbPzidYkoEQn6cHjahN6Wd
	uwQzYKaksLLtOTBQ==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=NaAMJIB4;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=w24hAtq1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794564858; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=R+BQ3YDqHXKcy+cUyFBlq7lXheFdbpMKJC809gP5ZDs=;
	b=NaAMJIB45F0M12kv3Hlw1jteSDptA37MX75SoHGxBf3PipyI8harDmWwwNBIk9UjZEya0h
	AFas9hg6DyAZFKcuAadF92EmbDewK7gIQ/vCdYhXChT+9d0EHzlItnN84IYSMlzHmqemNB
	hX+WjidkTG73z0NJoKjo5KGXZ9E92us=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794564858;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=R+BQ3YDqHXKcy+cUyFBlq7lXheFdbpMKJC809gP5ZDs=;
	b=w24hAtq1KJJ3nDdJ1wWSTNKEujiR92Lr29qv0lG6oGR1bgVxlbPzidYkoEQn6cHjahN6Wd
	uwQzYKaksLLtOTBQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id D559E1344A;
	Fri, 13 Nov 2026 10:14:17 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id BEcRLPni9mpKcQAAD6G6ig
	(envelope-from <jack@suse.cz>); Fri, 13 Nov 2026 10:14:17 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 6948F22C74; Fri, 13 Nov 2026 11:14:17 +0100 (CET)
Date: Fri, 13 Nov 2026 11:14:17 +0100
From: Jan Kara <jack@suse.cz>
To: sashiko-reviews@lists.linux.dev
Cc: Jan Kara <jack@suse.cz>, Christian Brauner <brauner@kernel.org>, 
	Andreas Gruenbacher <agruenba@redhat.com>, Mike Marshall <hubcap@omnibond.com>, 
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, Dave Kleikamp <shaggy@kernel.org>, 
	Carlos Maiolino <cem@kernel.org>, David Howells <dhowells@redhat.com>, 
	Marc Dionne <marc.dionne@auristor.com>, Miklos Szeredi <miklos@szeredi.hu>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, Eric Biggers <ebiggers@kernel.org>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, Anna Schumaker <anna@kernel.org>
Subject: Re: [PATCH 06/13] gfs2: Avoid racy dirtiness check in gfs2_fsync()
Message-ID: <4bfypbk3wiuheb2ntltkt4colxa77fplkxrft2uzvgsjguunna@wela5zxwi2iq>
References: <20261113083336.15152-1-jack@suse.cz>
 <20261113084700.739002-19-jack@suse.cz>
 <sashiko-outbox-212504@kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <sashiko-outbox-212504@kernel.org>
X-Rspamd-Queue-Id: 0B72721FF3
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
	MIME_TRACE(0.00)[0:+];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[18];
	DBL_BLOCKED_OPENRESOLVER(0.00)[sashiko.dev:url,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email];
	RCVD_COUNT_THREE(0.00)[3];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	DKIM_TRACE(0.00)[suse.cz:+]
X-Spam-Score: -13.01

On Fri 13-11-26 09:08:22, sashiko-bot@kernel.org wrote:
> Thank you for your contribution! Sashiko AI review found 1 potential
> issue to consider:
> - [High] gfs2: gfs2_fsync() checks PAGECACHE_TAG_DIRTY after
>   filemap_fdatawrite_range()
> --
> 
> commit a74a8e373d1c581c53bf8dbda94cd97b2bf0e19f
> Author: Jan Kara <jack@suse.cz>
> 
> gfs2: Avoid racy dirtiness check in gfs2_fsync()
> 
> This commit replaces the unlocked I_DIRTY check in gfs2_fsync() with
> inode_is_dirty() and a PAGECACHE_TAG_DIRTY check on the mapping for jdata
> inodes.
> 
> > diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
> > index 1efd0679badd9..9e52f18326737 100644
> > --- a/fs/gfs2/file.c
> > +++ b/fs/gfs2/file.c
> > @@ -749,7 +749,6 @@ static int gfs2_fsync(struct file *file, loff_t start, loff_t end,
> >  {
> >  	struct address_space *mapping = file->f_mapping;
> >  	struct inode *inode = mapping->host;
> > -	int sync_state = inode_state_read_once(inode) & I_DIRTY;
> >  	struct gfs2_glock *gl = gfs2_inode_glock(inode);
> >  	struct gfs2_inode *ip = GFS2_I(inode);
> >  	int ret = 0, ret1 = 0;
> > @@ -760,12 +759,9 @@ static int gfs2_fsync(struct file *file, loff_t start, loff_t end,
> >  			return ret1;
> >  	}
> >  
> > -	if (!gfs2_is_jdata(ip))
> > -		sync_state &= ~I_DIRTY_PAGES;
> > -	if (datasync)
> > -		sync_state &= ~I_DIRTY_SYNC;
> > -
> > -	if (sync_state) {
> > +	if (inode_is_dirty(inode, datasync) ||
> > +	    (gfs2_is_jdata(ip) && mapping_tagged(inode->i_mapping,
> > +						 PAGECACHE_TAG_DIRTY))) {
> >  		ret = sync_inode_metadata(inode, 1);
> >  		if (ret)
> >  			return ret;
> 
> [Severity: High]
> Does checking mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY) after
> filemap_fdatawrite_range(mapping, start, end) miss dirty jdata pages?
> 
> Previously, sync_state was sampled before filemap_fdatawrite_range().  For a
> jdata inode, filemap_fdatawrite_range() runs gfs2_jdata_writepages() with
> WB_SYNC_ALL, which flushes the log and calls gfs2_write_cache_jdata() ->
> gfs2_write_jdata_batch() -> folio_clear_dirty_for_io(), clearing
> PAGECACHE_TAG_DIRTY on the folios in [start, end] before this check is
> reached.

So I'm aware the behavior of gfs2_fsync() is changed and on a second
thought I agree that the mapping_tagged() check should probably happen
before the filemap_fdatawrite_range() as it used to. But frankly I find the
code in gfs2_fsync() with multiple filemap writeouts and waits confusing so
I'd like some feedback from GFS2 folks about the intended behavior to be
sure.

								Honza

> 
> When overwriting already-allocated blocks of an unstuffed jdata file,
> gfs2_iomap_put_folio() only increments tr->tr_num_databuf_new (leaving
> tr->tr_num_buf_new == 0), so I_DIRTY_DATASYNC is not set:
> 
> fs/gfs2/bmap.c:gfs2_iomap_put_folio() {
> 	...
> 	if (gfs2_is_jdata(ip) || gfs2_is_stuffed(ip)) {
> 		if (tr->tr_num_buf_new)
> 			__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> 		gfs2_trans_end(sdp);
> 	}
> 	...
> }
> 
> On fdatasync() (or fsync() when timestamps did not change), both
> inode_is_dirty(inode, datasync) and mapping_tagged(inode->i_mapping,
> PAGECACHE_TAG_DIRTY) then evaluate to false, skipping sync_inode_metadata(),
> file_write_and_wait(), and gfs2_ail_flush(gl, 1) and leaving the jdata AIL
> buffers unrevoked in the journal.
> 
> -- 
> Sashiko AI review · https://sashiko.dev/#/patchset/20261113083336.15152-1-jack@suse.cz?part=6
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
