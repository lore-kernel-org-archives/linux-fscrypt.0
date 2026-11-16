Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794848838;
	b=Co+YbKUp/CCpyujIMaFcUmyf7DbcNjfuTNISFVN1pYqHi/8o7EEtVc9uFWobkzEtAur6
	 kzXzsBkYq6/rzOw0jK8FqEgfH78pZHiLnc/7uy/h0dUjyR8gdszPrnHTWhz78NQfL9FAw
	 diMA6IXKIKN3/SXi6t0lMOg8irPHSAuWCLtT7IURzb5mAmzyS6Sn8VlnlApDhQCy/LpHj
	 7QeouDpqj+/tCrfHY5+0M/NtNJ/8RsTpBOcWNurO/wdTIRazf140EA8irB8QwqdRTEYxF
	 Y9TCrbEx0V2glpTHvaMQeYFEaq4jh+7+I6XuyEXP/2TKU+0nJjwMWsyvwT9NE95T9cg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794848838;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=ZNhkbFLmdWlDxBP+VbCDLBk7TECa3Ts7dDVyvIVcM6E=;
	b=tcjWXMfEC/RN/ypNJ+ykA+9YTLjLPlzWlPXMXLUcYfwFzXcePzRYS1t+vdho0CO9PXUa
	 wNfUdT7TQqeEiI2AaUQogi/byyMor8F3b03iEUGrGBTZEwFSoz/Szwo2sFmiqe/O4Og3Y
	 YurtSL30l1rTFst/FfHcmVnLGd/2qBStrJVmVoT9PsABibPe+nRR086zTR/IjyM+OaFP8
	 nBjXqT8vuLDzcbbSdxOxf8qwG0hSThUy3IpDRCV96z/Pd+jFEN22KGNRpRY9KgRWwyOFt
	 0kv0Ow+dF5v7+tc+LVRWPO/0BNoG9v4tIi9MTQ7/MX26xTYWBE7xxsMMLPx93iIWSxg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="E05RK8Q/";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=lUfKD2fb;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b="E05RK8Q/";
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=lUfKD2fb;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5915606A31C
	for <linux-fscrypt@vger.kernel.org>; Mon, 16 Nov 2026 17:07:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D5915606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=E05RK8Q/;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=lUfKD2fb;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=E05RK8Q/;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=lUfKD2fb
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 0FA001F7C4;
	Mon, 16 Nov 2026 17:07:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794848836; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZNhkbFLmdWlDxBP+VbCDLBk7TECa3Ts7dDVyvIVcM6E=;
	b=E05RK8Q/R3QP6IooGK0K2uKd77pktoWZnqFNlm8lRM/SdtZ2jy/sUY5vARWvu2kuhdquPn
	Zol4YlHokNGs8kClyWjkZY0efcL7NnEpPe6EQaxK2HcgqnGhFiPLAkxHbm8uF8lnVUOIyw
	aMd42idReVsAtzp9qhLbFOE6giaDPvg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794848836;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZNhkbFLmdWlDxBP+VbCDLBk7TECa3Ts7dDVyvIVcM6E=;
	b=lUfKD2fbyhCzXGVYxup9x2uUhL7w0iSLStSZifPuMMa8MmWyh80DIAaxBXh6gjIQD57bxf
	NAxhylw92EHpdBCg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794848836; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZNhkbFLmdWlDxBP+VbCDLBk7TECa3Ts7dDVyvIVcM6E=;
	b=E05RK8Q/R3QP6IooGK0K2uKd77pktoWZnqFNlm8lRM/SdtZ2jy/sUY5vARWvu2kuhdquPn
	Zol4YlHokNGs8kClyWjkZY0efcL7NnEpPe6EQaxK2HcgqnGhFiPLAkxHbm8uF8lnVUOIyw
	aMd42idReVsAtzp9qhLbFOE6giaDPvg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794848836;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZNhkbFLmdWlDxBP+VbCDLBk7TECa3Ts7dDVyvIVcM6E=;
	b=lUfKD2fbyhCzXGVYxup9x2uUhL7w0iSLStSZifPuMMa8MmWyh80DIAaxBXh6gjIQD57bxf
	NAxhylw92EHpdBCg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id CAFEA13408;
	Mon, 16 Nov 2026 17:07:15 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id Z9aHKUM4+2qjGQAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 17:07:15 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 5BD0524E8E; Mon, 16 Nov 2026 18:07:11 +0100 (CET)
Date: Mon, 16 Nov 2026 18:07:11 +0100
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
Message-ID: <4jxbqdd43u7xys4l4x6yzbwpbtw3yijkxlv6x6qnp4punam5u6@mlaydzf2raal>
References: <20261113083336.15152-1-jack@suse.cz>
 <20261113084700.739002-19-jack@suse.cz>
 <sashiko-outbox-212504@kernel.org>
 <4bfypbk3wiuheb2ntltkt4colxa77fplkxrft2uzvgsjguunna@wela5zxwi2iq>
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
In-Reply-To: <4bfypbk3wiuheb2ntltkt4colxa77fplkxrft2uzvgsjguunna@wela5zxwi2iq>
X-Spam-Flag: NO
X-Spam-Level: 
X-Spamd-Result: default: False [-12.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	URIBL_BLOCKED(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email];
	RCVD_COUNT_THREE(0.00)[3];
	FROM_HAS_DN(0.00)[];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[18];
	MIME_TRACE(0.00)[0:+];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	MISSING_XM_UA(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.cz:email,suse.com:email]
X-Spam-Score: -12.80

On Fri 13-11-26 11:14:17, Jan Kara wrote:
> On Fri 13-11-26 09:08:22, sashiko-bot@kernel.org wrote:
> > Thank you for your contribution! Sashiko AI review found 1 potential
> > issue to consider:
> > - [High] gfs2: gfs2_fsync() checks PAGECACHE_TAG_DIRTY after
> >   filemap_fdatawrite_range()
> > --
> > 
> > commit a74a8e373d1c581c53bf8dbda94cd97b2bf0e19f
> > Author: Jan Kara <jack@suse.cz>
> > 
> > gfs2: Avoid racy dirtiness check in gfs2_fsync()
> > 
> > This commit replaces the unlocked I_DIRTY check in gfs2_fsync() with
> > inode_is_dirty() and a PAGECACHE_TAG_DIRTY check on the mapping for jdata
> > inodes.
> > 
> > > diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
> > > index 1efd0679badd9..9e52f18326737 100644
> > > --- a/fs/gfs2/file.c
> > > +++ b/fs/gfs2/file.c
> > > @@ -749,7 +749,6 @@ static int gfs2_fsync(struct file *file, loff_t start, loff_t end,
> > >  {
> > >  	struct address_space *mapping = file->f_mapping;
> > >  	struct inode *inode = mapping->host;
> > > -	int sync_state = inode_state_read_once(inode) & I_DIRTY;
> > >  	struct gfs2_glock *gl = gfs2_inode_glock(inode);
> > >  	struct gfs2_inode *ip = GFS2_I(inode);
> > >  	int ret = 0, ret1 = 0;
> > > @@ -760,12 +759,9 @@ static int gfs2_fsync(struct file *file, loff_t start, loff_t end,
> > >  			return ret1;
> > >  	}
> > >  
> > > -	if (!gfs2_is_jdata(ip))
> > > -		sync_state &= ~I_DIRTY_PAGES;
> > > -	if (datasync)
> > > -		sync_state &= ~I_DIRTY_SYNC;
> > > -
> > > -	if (sync_state) {
> > > +	if (inode_is_dirty(inode, datasync) ||
> > > +	    (gfs2_is_jdata(ip) && mapping_tagged(inode->i_mapping,
> > > +						 PAGECACHE_TAG_DIRTY))) {
> > >  		ret = sync_inode_metadata(inode, 1);
> > >  		if (ret)
> > >  			return ret;
> > 
> > [Severity: High]
> > Does checking mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY) after
> > filemap_fdatawrite_range(mapping, start, end) miss dirty jdata pages?
> > 
> > Previously, sync_state was sampled before filemap_fdatawrite_range().  For a
> > jdata inode, filemap_fdatawrite_range() runs gfs2_jdata_writepages() with
> > WB_SYNC_ALL, which flushes the log and calls gfs2_write_cache_jdata() ->
> > gfs2_write_jdata_batch() -> folio_clear_dirty_for_io(), clearing
> > PAGECACHE_TAG_DIRTY on the folios in [start, end] before this check is
> > reached.
> 
> So I'm aware the behavior of gfs2_fsync() is changed and on a second
> thought I agree that the mapping_tagged() check should probably happen
> before the filemap_fdatawrite_range() as it used to. But frankly I find the
> code in gfs2_fsync() with multiple filemap writeouts and waits confusing so
> I'd like some feedback from GFS2 folks about the intended behavior to be
> sure.

I've moved the dirtiness check before filemap_fdatawrite_range() now but as
I had a closer look at gfs2_fsync() logic and I'm now pretty much convinced
it is racy and this is just bug-to-bug compatibility. E.g. background
writeback could have just finished by the time gfs2_fsync() is called and
then it would behave exactly as with the dirtiness check after
filemap_fdatawrite_range(). But this really requires someone more
knowledgeable of GFS2 to have a look and decide.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
