Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794848014;
	b=V3CFWEKMmortZFzOK30GJKwYYQPydo1oOyzI8GYURJISoOi+sM+VJ+hxiSusjpm8xNU8
	 0mLvrfSOkx3IzRXL0f3OkPg0FGDOqOJ5FDzCsQw0mHBmKYRyXL5H7y5PO0lD/gqFL6YdO
	 dBNcKKfAU72rIXrUyQN9AzibyWkljK3WWOF1Xvidm4sojIGEsktDQfuEUdiFMepgqL8n3
	 X6RYKBZwin43iXDWSQSRwTfLyUfdsC8hZ2UVmnu2DlQ1vJ3+EOzEzw6/3dFh1uJ14ZOLX
	 umD422kbxqaVgcGsyhyzc9i6ClF2hhgBUNX4Yi2P32cGgQgwHjKKoXemE/f2YRgYd4g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794848014;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To:X-Spamd-Result:X-Rspamd-Server:
	 X-Rspamd-Action:X-Spam-Flag:X-Spam-Score:X-Spam-Level:
	 X-Rspamd-Queue-Id;
	bh=Gex1bYtiRcAcLEdG3dKc8nOze5cdZDbOIAuRhEws/aE=;
	b=VhWEFRYMpt+U4Y7wxd7y/bAvNsag5mz+RCDSitlXZmGE3bdM/+1XXRHgeLuX14I/dz+8
	 R0g88f4ZEjdYv/jafU/mBN5ukecCNJP0RFawo1UgUxmq8qp+uBqOi4nyhdxBmdCIwZBB/
	 yV/CRnnDgnCZ2FkrtUJQGHZXUfn6sbBohgOgss1ne3J6MIeGBtpzBu8UQ7qemg5VURvME
	 Z935YWLam/OgAJ5lxtKJlPx/nFVTH94RHUx9dGGgz2jUiLv/hJLbors87Dcln/dzfK32y
	 BC2sR9THInZrrhs849oG6xRSvHKtI9Fm/FeyO6MrpttsTj+lzJIdCbx2I9TBWVe/qdA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=yUbthPur;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="y2PYR/Mn";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=yUbthPur;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="y2PYR/Mn";
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DEBA606A323
	for <linux-fscrypt@vger.kernel.org>; Mon, 16 Nov 2026 16:53:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5DEBA606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=yUbthPur;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=y2PYR/Mn;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=yUbthPur;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=y2PYR/Mn
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 5ABE02227F;
	Mon, 16 Nov 2026 16:53:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794848011; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Gex1bYtiRcAcLEdG3dKc8nOze5cdZDbOIAuRhEws/aE=;
	b=yUbthPurRXW05FPYN+Q1isT6WzvZ36DAx2D8yYt0bYcZoIp8vShz3jLcojVRGw46u1UR2c
	Z5KHulNH7P2njE5sXg8b/1PqYZRVbByyqnWltENT8/8Zgb26edOb4jGHMsOPMeojWnYJHH
	3DMvBgOjOnFxoAezdZ6tlBBurrHAXpw=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794848011;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Gex1bYtiRcAcLEdG3dKc8nOze5cdZDbOIAuRhEws/aE=;
	b=y2PYR/Mnj0OC1mQxqOw3ZQboe6GJKnvexAneQohDnJfqac6G1baLvowa2V8YHuQ4VUB5YM
	ZSHBQ+gqerC5SFCA==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=yUbthPur;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b="y2PYR/Mn"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794848011; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Gex1bYtiRcAcLEdG3dKc8nOze5cdZDbOIAuRhEws/aE=;
	b=yUbthPurRXW05FPYN+Q1isT6WzvZ36DAx2D8yYt0bYcZoIp8vShz3jLcojVRGw46u1UR2c
	Z5KHulNH7P2njE5sXg8b/1PqYZRVbByyqnWltENT8/8Zgb26edOb4jGHMsOPMeojWnYJHH
	3DMvBgOjOnFxoAezdZ6tlBBurrHAXpw=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794848011;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Gex1bYtiRcAcLEdG3dKc8nOze5cdZDbOIAuRhEws/aE=;
	b=y2PYR/Mnj0OC1mQxqOw3ZQboe6GJKnvexAneQohDnJfqac6G1baLvowa2V8YHuQ4VUB5YM
	ZSHBQ+gqerC5SFCA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 0B7351334C;
	Mon, 16 Nov 2026 16:53:31 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id QiPqNAo1+2otCwAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 16:53:31 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 6FD9424E87; Mon, 16 Nov 2026 17:53:30 +0100 (CET)
Date: Mon, 16 Nov 2026 17:53:30 +0100
From: Jan Kara <jack@suse.cz>
To: Mike Marshall <hubcap@omnibond.com>
Cc: Jan Kara <jack@suse.cz>, sashiko-reviews@lists.linux.dev, 
	Christian Brauner <brauner@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, 
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, Dave Kleikamp <shaggy@kernel.org>, 
	Carlos Maiolino <cem@kernel.org>, David Howells <dhowells@redhat.com>, 
	Marc Dionne <marc.dionne@auristor.com>, Miklos Szeredi <miklos@szeredi.hu>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, Eric Biggers <ebiggers@kernel.org>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, Anna Schumaker <anna@kernel.org>
Subject: Re: [PATCH 03/13] orangefs: Check PAGECACHE_TAG_DIRTY instead of
 I_DIRTY_PAGES inode state
Message-ID: <oaoejnl23mcfhcs5vezy4b32xshnqpzipiwdgndilrqh3yxdo6@kfbyeig5xved>
References: <20261113083336.15152-1-jack@suse.cz>
 <20261113084700.739002-16-jack@suse.cz>
 <sashiko-outbox-212490@kernel.org>
 <6vifbr2gkvxhq2rer5agf6jwy3lrsjqpkxcrfdnypjqqjao4uw@j2al5rnaailb>
 <CAOg9mSQYDoH0ASc_HCgR=oZrGa1r=wy5OuS9qwX5arjd0bKP1w@mail.gmail.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOg9mSQYDoH0ASc_HCgR=oZrGa1r=wy5OuS9qwX5arjd0bKP1w@mail.gmail.com>
X-Spamd-Result: default: False [-13.01 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[18];
	ARC_NA(0.00)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	MIME_TRACE(0.00)[0:+];
	MISSING_XM_UA(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.cz:email,suse.cz:dkim];
	RCVD_COUNT_THREE(0.00)[3];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	URIBL_BLOCKED(0.00)[sashiko.dev:url,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	TO_DN_SOME(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spam-Score: -13.01
X-Spam-Level: 
X-Rspamd-Queue-Id: 5ABE02227F

On Sat 14-11-26 11:02:27, Mike Marshall wrote:
> I worked through Jan's patch and sashiko-bot's review
> with grok build, and came up with this... If what I've
> got here passes muster, I'm thinking Jan should still
> be marked as Author: and Signed-off-by:  it is his patch
> with a little change, but I wouldn't want to attribute
> anything to him that he doesn't want attributed, so
> let me know... My version probably won't feed through
> "git am" since I'm using gmail. I'm not sure how to add
> a message to a thread with "git send-email", even
> when I add in the message-id...

Thanks! I had something very similar in my tree already so I've just
updated that to match your changes with the helper function and I've used
your changelog. Thanks again!

								Honza

> 
> 
> PAGECACHE_TAG_DIRTY is the authoritative source of dirty folios.
> I_DIRTY_PAGES can stay set after filemap_fdatawrite(), which is how
> orangefs_flush() and orangefs_fsync() write the mapping, so a getattr
> keeps serving the cached inode after the folios are clean.
> 
> The dirty tag alone is not enough. folio_start_writeback() clears it
> and sets PAGECACHE_TAG_WRITEBACK before wait_for_direct_io() sends the
> write. OrangeFS writepages does not return until that call finishes, so
> I_DIRTY_PAGES still covers the round trip today. A getattr that looks
> only at the dirty tag stores the server's old size while the write is
> in flight. orangefs_writepage_locked() then reads that size and shortens
> the write.
> 
> Hold the cached attributes while either tag is set.
> 
> 
> ---
>  fs/orangefs/orangefs-utils.c | 22 +++++++++++++++++++---
>  1 file changed, 19 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/orangefs/orangefs-utils.c b/fs/orangefs/orangefs-utils.c
> index 9ab1119ebd28..72fa9865bb86 100644
> --- a/fs/orangefs/orangefs-utils.c
> +++ b/fs/orangefs/orangefs-utils.c
> @@ -233,6 +233,20 @@ static int orangefs_inode_is_stale(struct inode *inode,
>   return 0;
>  }
> 
> +/*
> + * Dirty and writeback tags, not I_DIRTY_PAGES. filemap_fdatawrite()
> + * leaves that flag set after the folios are clean. folio_start_writeback()
> + * clears the dirty tag before wait_for_direct_io() returns, so the
> + * writeback tag is what covers the server write.
> + */
> +static bool orangefs_writeback_pending(struct inode *inode)
> +{
> + struct address_space *mapping = inode->i_mapping;
> +
> + return mapping_tagged(mapping, PAGECACHE_TAG_DIRTY) ||
> +       mapping_tagged(mapping, PAGECACHE_TAG_WRITEBACK);
> +}
> +
>  int orangefs_inode_getattr(struct inode *inode, int flags)
>  {
>   struct orangefs_inode_s *orangefs_inode = ORANGEFS_I(inode);
> @@ -247,7 +261,8 @@ again:
>   spin_lock(&inode->i_lock);
>   /* Must have all the attributes in the mask and be within cache time. */
>   if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)) ||
> -    orangefs_inode->attr_valid || inode_state_read(inode) & I_DIRTY_PAGES) {
> +    orangefs_inode->attr_valid ||
> +    orangefs_writeback_pending(inode)) {
>   if (orangefs_inode->attr_valid) {
>   spin_unlock(&inode->i_lock);
>   write_inode_now(inode, 1);
> @@ -281,13 +296,14 @@ again2:
>   spin_lock(&inode->i_lock);
>   /* Must have all the attributes in the mask and be within cache time. */
>   if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)) ||
> -    orangefs_inode->attr_valid || inode_state_read(inode) & I_DIRTY_PAGES) {
> +    orangefs_inode->attr_valid ||
> +    orangefs_writeback_pending(inode)) {
>   if (orangefs_inode->attr_valid) {
>   spin_unlock(&inode->i_lock);
>   write_inode_now(inode, 1);
>   goto again2;
>   }
> - if (inode_state_read(inode) & I_DIRTY_PAGES) {
> + if (orangefs_writeback_pending(inode)) {
>   ret = 0;
>   goto out_unlock;
>   }
> 
> On Fri, Nov 13, 2026 at 5:34 AM Jan Kara <jack@suse.cz> wrote:
> >
> > On Fri 13-11-26 09:00:01, sashiko-bot@kernel.org wrote:
> > > Thank you for your contribution! Sashiko AI review found 1 potential
> > > issue to consider:
> > > - [High] orangefs: stale i_size overwrite during writeback in
> > >   orangefs_inode_getattr()
> >
> > ...
> >
> > > > diff --git a/fs/orangefs/orangefs-utils.c b/fs/orangefs/orangefs-utils.c
> > > > index 9ab1119ebd28a..4c4036f470cdd 100644
> > > > --- a/fs/orangefs/orangefs-utils.c
> > > > +++ b/fs/orangefs/orangefs-utils.c
> > > > @@ -247,7 +247,8 @@ int orangefs_inode_getattr(struct inode *inode, int flags)
> > > >     spin_lock(&inode->i_lock);
> > > >     /* Must have all the attributes in the mask and be within cache time. */
> > > >     if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)) ||
> > > > -       orangefs_inode->attr_valid || inode_state_read(inode) & I_DIRTY_PAGES) {
> > > > +       orangefs_inode->attr_valid ||
> > > > +       mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
> > > >             if (orangefs_inode->attr_valid) {
> > > >                     spin_unlock(&inode->i_lock);
> > > >                     write_inode_now(inode, 1);
> > > > @@ -281,13 +282,14 @@ int orangefs_inode_getattr(struct inode *inode, int flags)
> > > >     spin_lock(&inode->i_lock);
> > > >     /* Must have all the attributes in the mask and be within cache time. */
> > > >     if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)) ||
> > > > -       orangefs_inode->attr_valid || inode_state_read(inode) & I_DIRTY_PAGES) {
> > > > +       orangefs_inode->attr_valid ||
> > > > +       mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
> > > >             if (orangefs_inode->attr_valid) {
> > > >                     spin_unlock(&inode->i_lock);
> > > >                     write_inode_now(inode, 1);
> > > >                     goto again2;
> > > >             }
> > > > -           if (inode_state_read(inode) & I_DIRTY_PAGES) {
> > > > +           if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
> > > >                     ret = 0;
> > > >                     goto out_unlock;
> > > >             }
> > >
> > > [Severity: High]
> > > Can orangefs_inode_getattr() overwrite inode->i_size with a stale size from
> > > the server while pagecache writeback is in flight?
> > >
> > > When a buffered write extends a file in orangefs_write_end(), inode->i_size
> > > is updated in memory and the folio is marked dirty, while the server only
> > > learns the new size once the writeback RPC in wait_for_direct_io()
> > > completes.  Previously, I_DIRTY_PAGES stayed set in
> > > __writeback_single_inode() across the entire do_writepages() call.
> > > However, folio_start_writeback() clears PAGECACHE_TAG_DIRTY and sets
> > > PAGECACHE_TAG_WRITEBACK before wait_for_direct_io() sends the write to the
> > > server:
> > >
> > > CPU0                                  CPU1
> > > orangefs_writepage_locked()
> > >   folio_start_writeback(folio)
> > >     /* clears PAGECACHE_TAG_DIRTY,
> > >        sets PAGECACHE_TAG_WRITEBACK */
> > >                                       orangefs_getattr()
> > >                                         orangefs_inode_getattr(...,
> > >                                             ORANGEFS_GETATTR_SIZE)
> > >                                           /* PAGECACHE_TAG_DIRTY is false */
> > >                                           service_operation(GETATTR)
> > >                                           inode->i_size = ...; <-- stale size
> > >   len = i_size_read(inode);
> > >   wait_for_direct_io(ORANGEFS_IO_WRITE, ...)
> >
> > Yeah, that's a good catch but I think that this is pre-existing issue. When
> > we don't wait for writeback to complete in __writeback_single_inode()
> > (which happens for sync(2) or for WB_SYNC_NONE writeback), we can clear
> > I_DIRTY_PAGES before writeback completes as well. So this patch just makes
> > the race window larger.
> >
> > But I agree with adding a check for PAGECACHE_TAG_WRITEBACK into the
> > conditions as well to close the race window altogether. Another option
> > would be to sample i_size before calling folio_start_writeback() but I find
> > that too subtle, it would require some barriers etc., so I won't do that
> > unless orangefs guys insist.
> >
> >                                                                 Honza
> >
> > >
> > > As a result, any concurrent getattr with non-zero flags (such as
> > > orangefs_getattr() or orangefs_file_llseek()) fetches the pre-write size
> > > from the server and clobbers inode->i_size, which also causes
> > > orangefs_writepage_locked() (or a subsequent batch in
> > > orangefs_writepages_work()) to clamp the write length to the stale size and
> > > truncate the buffered write.
> > >
> > > Should these checks also test mapping_tagged(inode->i_mapping,
> > > PAGECACHE_TAG_WRITEBACK) (or mapping_writably_mapped() / a helper covering
> > > both PAGECACHE_TAG_DIRTY and PAGECACHE_TAG_WRITEBACK)?
> > >
> > > --
> > > Sashiko AI review · https://sashiko.dev/#/patchset/20261113083336.15152-1-jack@suse.cz?part=3
> > --
> > Jan Kara <jack@suse.com>
> > SUSE Labs, CR
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
