Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794566095;
	b=uCY5tqOZSQx/Kcue/YHPdMBOIuLvZ1o6SxLSh+6rsLUwH0AGNkO6QBxh4pxOh8XVAINl
	 fQjfITlwieQuJzQUdq9U6P6xSA15w7NVsRR1qKQMDg6OC2iRgXxmeI/TwYulpMckN5tBu
	 r2ycNs79if7nD6te4Yl2mdD71GYeTJSyQBgMKEhQO4hT1JyjZk0rXcxQL/G4fkYU5CLxO
	 2KEnTUDTBxJ/bXdmmNaF3/So8Axf1swiCxxhOT+tfcfagEOpG0BbuBhJ1EKT3UNxaW0JN
	 MKqCbNJ1ag2kCTHcz99mjpgGgoqHsZ6+dsV8LS44bDvy75dDoHYqsDB9loM9DD+VPlg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794566095;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To:X-Spamd-Result:X-Rspamd-Server:
	 X-Rspamd-Action:X-Spam-Flag:X-Spam-Score:X-Spam-Level:
	 X-Rspamd-Queue-Id;
	bh=2IvkyIclccLHl3VU7iMow03AjLnb0NVGOYgG0mJrUjc=;
	b=HlkIiuwdenhnHn1lKJyPF/d21u/fewJS9Ap6ldbg4wE4Op7ezGMT2T5FfFgiaxQGnuWC
	 vJkr1SlGrzbs8ZimFu4C2d2mH0+w9sFP8gBFt9BYyslJrbz0mxWp57tIh9FRGDJj+6rcB
	 MbG4kwEZEiTYhpTzpocOsd2j5lGN4kk1SuA/VKcw2n7HoFZ0elsKnK21bzt+7jnoRBju6
	 V01eiULgOGd6ydL2xk2NpYgn44Y7Mf/nmuZKQX9U2KkpmGdr6Uhr1enja/PMIem0NUk/E
	 YNnN1C5/ncBXtUp+Bzrld44CZeSkyXLtGfCpv22otNGJZoCK1VL94MwMxmar7Fw6IhQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zl2SxIUU;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="/0WO5sIC";
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zl2SxIUU;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b="/0WO5sIC";
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 33949606A33A
	for <linux-fscrypt@vger.kernel.org>; Fri, 13 Nov 2026 10:34:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 33949606A33A
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zl2SxIUU;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=/0WO5sIC;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=zl2SxIUU;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=/0WO5sIC
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 344831F7FB;
	Fri, 13 Nov 2026 10:34:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794566092; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=2IvkyIclccLHl3VU7iMow03AjLnb0NVGOYgG0mJrUjc=;
	b=zl2SxIUUBN3ONlDpSkIKnjmKRt96daIdGb+ogaYd5WIGMuF47KdshfVl/M+dWpz3fCatWY
	8elFzPsypAlRD/nPjVdo994RZC/1aeNDvULTfQmnrPas5u9pRbdOOz1mryprnmdGhLf+3f
	3I3c+L+H9kA2EIuyvVBzpr3JlJORF70=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794566092;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=2IvkyIclccLHl3VU7iMow03AjLnb0NVGOYgG0mJrUjc=;
	b=/0WO5sICt1VLqjOJYP4VOLWyGmVvgLcHpYEnC0dzd4NpYrJY7UuD9ui/b+76vafV2uNRNk
	fUyOjPfTOwXed3Aw==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=zl2SxIUU;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b="/0WO5sIC"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794566092; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=2IvkyIclccLHl3VU7iMow03AjLnb0NVGOYgG0mJrUjc=;
	b=zl2SxIUUBN3ONlDpSkIKnjmKRt96daIdGb+ogaYd5WIGMuF47KdshfVl/M+dWpz3fCatWY
	8elFzPsypAlRD/nPjVdo994RZC/1aeNDvULTfQmnrPas5u9pRbdOOz1mryprnmdGhLf+3f
	3I3c+L+H9kA2EIuyvVBzpr3JlJORF70=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794566092;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=2IvkyIclccLHl3VU7iMow03AjLnb0NVGOYgG0mJrUjc=;
	b=/0WO5sICt1VLqjOJYP4VOLWyGmVvgLcHpYEnC0dzd4NpYrJY7UuD9ui/b+76vafV2uNRNk
	fUyOjPfTOwXed3Aw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 03195134C3;
	Fri, 13 Nov 2026 10:34:52 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id +dU7M8vn9mp1CAAAD6G6ig
	(envelope-from <jack@suse.cz>); Fri, 13 Nov 2026 10:34:52 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 82A8E22C80; Fri, 13 Nov 2026 11:34:51 +0100 (CET)
Date: Fri, 13 Nov 2026 11:34:51 +0100
From: Jan Kara <jack@suse.cz>
To: sashiko-reviews@lists.linux.dev
Cc: Jan Kara <jack@suse.cz>, Christian Brauner <brauner@kernel.org>, 
	Andreas Gruenbacher <agruenba@redhat.com>, Mike Marshall <hubcap@omnibond.com>, 
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, Dave Kleikamp <shaggy@kernel.org>, 
	Carlos Maiolino <cem@kernel.org>, David Howells <dhowells@redhat.com>, 
	Marc Dionne <marc.dionne@auristor.com>, Miklos Szeredi <miklos@szeredi.hu>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, Eric Biggers <ebiggers@kernel.org>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, Anna Schumaker <anna@kernel.org>
Subject: Re: [PATCH 03/13] orangefs: Check PAGECACHE_TAG_DIRTY instead of
 I_DIRTY_PAGES inode state
Message-ID: <6vifbr2gkvxhq2rer5agf6jwy3lrsjqpkxcrfdnypjqqjao4uw@j2al5rnaailb>
References: <20261113083336.15152-1-jack@suse.cz>
 <20261113084700.739002-16-jack@suse.cz>
 <sashiko-outbox-212490@kernel.org>
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
In-Reply-To: <sashiko-outbox-212490@kernel.org>
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
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCPT_COUNT_TWELVE(0.00)[18];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:dkim,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,sashiko.dev:url];
	RCVD_COUNT_THREE(0.00)[3];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
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
X-Rspamd-Queue-Id: 344831F7FB

On Fri 13-11-26 09:00:01, sashiko-bot@kernel.org wrote:
> Thank you for your contribution! Sashiko AI review found 1 potential
> issue to consider:
> - [High] orangefs: stale i_size overwrite during writeback in
>   orangefs_inode_getattr()

...

> > diff --git a/fs/orangefs/orangefs-utils.c b/fs/orangefs/orangefs-utils.c
> > index 9ab1119ebd28a..4c4036f470cdd 100644
> > --- a/fs/orangefs/orangefs-utils.c
> > +++ b/fs/orangefs/orangefs-utils.c
> > @@ -247,7 +247,8 @@ int orangefs_inode_getattr(struct inode *inode, int flags)
> >  	spin_lock(&inode->i_lock);
> >  	/* Must have all the attributes in the mask and be within cache time. */
> >  	if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)) ||
> > -	    orangefs_inode->attr_valid || inode_state_read(inode) & I_DIRTY_PAGES) {
> > +	    orangefs_inode->attr_valid ||
> > +	    mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
> >  		if (orangefs_inode->attr_valid) {
> >  			spin_unlock(&inode->i_lock);
> >  			write_inode_now(inode, 1);
> > @@ -281,13 +282,14 @@ int orangefs_inode_getattr(struct inode *inode, int flags)
> >  	spin_lock(&inode->i_lock);
> >  	/* Must have all the attributes in the mask and be within cache time. */
> >  	if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)) ||
> > -	    orangefs_inode->attr_valid || inode_state_read(inode) & I_DIRTY_PAGES) {
> > +	    orangefs_inode->attr_valid ||
> > +	    mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
> >  		if (orangefs_inode->attr_valid) {
> >  			spin_unlock(&inode->i_lock);
> >  			write_inode_now(inode, 1);
> >  			goto again2;
> >  		}
> > -		if (inode_state_read(inode) & I_DIRTY_PAGES) {
> > +		if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
> >  			ret = 0;
> >  			goto out_unlock;
> >  		}
> 
> [Severity: High]
> Can orangefs_inode_getattr() overwrite inode->i_size with a stale size from
> the server while pagecache writeback is in flight?
> 
> When a buffered write extends a file in orangefs_write_end(), inode->i_size
> is updated in memory and the folio is marked dirty, while the server only
> learns the new size once the writeback RPC in wait_for_direct_io()
> completes.  Previously, I_DIRTY_PAGES stayed set in
> __writeback_single_inode() across the entire do_writepages() call.
> However, folio_start_writeback() clears PAGECACHE_TAG_DIRTY and sets
> PAGECACHE_TAG_WRITEBACK before wait_for_direct_io() sends the write to the
> server:
> 
> CPU0                                  CPU1
> orangefs_writepage_locked()
>   folio_start_writeback(folio)
>     /* clears PAGECACHE_TAG_DIRTY,
>        sets PAGECACHE_TAG_WRITEBACK */
>                                       orangefs_getattr()
>                                         orangefs_inode_getattr(...,
>                                             ORANGEFS_GETATTR_SIZE)
>                                           /* PAGECACHE_TAG_DIRTY is false */
>                                           service_operation(GETATTR)
>                                           inode->i_size = ...; <-- stale size
>   len = i_size_read(inode);
>   wait_for_direct_io(ORANGEFS_IO_WRITE, ...)

Yeah, that's a good catch but I think that this is pre-existing issue. When
we don't wait for writeback to complete in __writeback_single_inode()
(which happens for sync(2) or for WB_SYNC_NONE writeback), we can clear
I_DIRTY_PAGES before writeback completes as well. So this patch just makes
the race window larger.

But I agree with adding a check for PAGECACHE_TAG_WRITEBACK into the
conditions as well to close the race window altogether. Another option
would be to sample i_size before calling folio_start_writeback() but I find
that too subtle, it would require some barriers etc., so I won't do that
unless orangefs guys insist.

								Honza

> 
> As a result, any concurrent getattr with non-zero flags (such as
> orangefs_getattr() or orangefs_file_llseek()) fetches the pre-write size
> from the server and clobbers inode->i_size, which also causes
> orangefs_writepage_locked() (or a subsequent batch in
> orangefs_writepages_work()) to clamp the write length to the stale size and
> truncate the buffered write.
> 
> Should these checks also test mapping_tagged(inode->i_mapping,
> PAGECACHE_TAG_WRITEBACK) (or mapping_writably_mapped() / a helper covering
> both PAGECACHE_TAG_DIRTY and PAGECACHE_TAG_WRITEBACK)?
> 
> -- 
> Sashiko AI review · https://sashiko.dev/#/patchset/20261113083336.15152-1-jack@suse.cz?part=3
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
