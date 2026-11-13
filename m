Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564148;
	b=3K3TlYGue/M5EBXITHAqlnSKFMrPw15jNyFQRgoQEQ2ykTTtXKFb3NrViY5Ch+vR7erq
	 NSL3B3WuCUMa1qqCMtvQ0SZd1r/avRjXCuWXbBNfg1J4Xj4PI96JECPAJntYIIosamB59
	 c6UiIguPEDJ6yXJJYn5C93U/G6JoaECuOPRee4wsxwivqfocdI4RnadTRrkjtQ5LePjAl
	 749Bw1GFEtm4nZ/AAKbWVXwfasVjdkQm71uFy5ZNaJh8KW/x2zgn6FHT72++bBGyS0Q5x
	 7kOcMpIOGgO1yUPaBnGUek8iokm1vhv+0PF+XMUjRx7lin+lXAn4mqXCThxV2FtLP0w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564148;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=pzZcjfjDWk1PwzzMGLnVgF6yn5vNx9o9DymrdJtwYo0=;
	b=APaZJw3Z2dbZcLe6GaUNygt1hyJqOFbiafhLSaa1eo6ujg3BPg5b1Hsr7cUyRRovLYon
	 PmjTIfAz9QtN5oqdvW8NZmcrkmk5C/LPSFAw4KHNw1SYCH/SlF1aePtZU2uzyJ6YIFufM
	 Ca0zSIHCflTx2HIbsP6kEToqBMMTi1u5l1JNAOsNalqFILjrVXqRWwpJCnCJr2RdK9/BK
	 3MKJDXUkHNwjkSdfV5Y9UG1hYpFfHlw5W6bQedV16ibgI2CUfkF/qcumX97L44d/Xcsnr
	 xDwhkg8l+t1pDECxg3HeJgGYjwpe1nx6znAePNxLrgLO+0ivcIFPEZl0qwRQe/TsnqQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=eGgB6pVR;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=EPWTG4D0;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=EypKC0TQ;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=fsEZRtQF;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A592606A330
	for <linux-fscrypt@vger.kernel.org>; Fri, 13 Nov 2026 10:02:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6A592606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=eGgB6pVR;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=EPWTG4D0;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=EypKC0TQ;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=fsEZRtQF
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 646F01F863;
	Fri, 13 Nov 2026 10:02:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794564145; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=pzZcjfjDWk1PwzzMGLnVgF6yn5vNx9o9DymrdJtwYo0=;
	b=eGgB6pVRD6FBVXPbfggtBF45RdomKNtUm6ZYxdHgOiMxhvOSUH4F9FiKaZHRegV68xUS2U
	e/UDP2/SiUaV3vx6gZhAeF4xhsPUQk4L5vn8dLqmbWVuaRty4JmD3QD0mhw/pGw1KmtFo5
	EnJL5VCfZU74c6MM09FkVFQ3Hiqc8cM=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794564145;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=pzZcjfjDWk1PwzzMGLnVgF6yn5vNx9o9DymrdJtwYo0=;
	b=EPWTG4D00sIHqz4XYdH5sLA6AV9GZZOVENFB1YIbdqwAGcmEMwCKJ85nKdZFKnLSLgTREF
	CyKQZK/M7/nIKIDg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794564144; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=pzZcjfjDWk1PwzzMGLnVgF6yn5vNx9o9DymrdJtwYo0=;
	b=EypKC0TQYS47UKYRQjYa2oPAW7ZwXve7bDfDEZ18JXhMyMBNQDC9fphwomwWP2aQkNifId
	JGXQt78OP7TBNM17LjHGLj80FPF38OwIZQTin2Cj2Z+W5TWAu29rMUB9zNrOLCKrTZB24T
	THxIdKAQv4Q26cYfz2RbX39KZqSQoMg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794564144;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=pzZcjfjDWk1PwzzMGLnVgF6yn5vNx9o9DymrdJtwYo0=;
	b=fsEZRtQFsL5FeOI3zh+xdzb4Pz66ZsH1EZ+EJ2Z5q6kANM5AAuiDUGAr0Mb9+tw0jBIx1f
	Op+LOKnvTcSfDhAg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 3BE0A1344A;
	Fri, 13 Nov 2026 10:02:24 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id oKrzBTDg9mqXZAAAD6G6ig
	(envelope-from <jack@suse.cz>); Fri, 13 Nov 2026 10:02:24 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id BFBD922C6C; Fri, 13 Nov 2026 11:02:23 +0100 (CET)
Date: Fri, 13 Nov 2026 11:02:23 +0100
From: Jan Kara <jack@suse.cz>
To: sashiko-reviews@lists.linux.dev
Cc: Jan Kara <jack@suse.cz>, Christian Brauner <brauner@kernel.org>, 
	Andreas Gruenbacher <agruenba@redhat.com>, Mike Marshall <hubcap@omnibond.com>, 
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, Dave Kleikamp <shaggy@kernel.org>, 
	Carlos Maiolino <cem@kernel.org>, David Howells <dhowells@redhat.com>, 
	Marc Dionne <marc.dionne@auristor.com>, Miklos Szeredi <miklos@szeredi.hu>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, Eric Biggers <ebiggers@kernel.org>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, Anna Schumaker <anna@kernel.org>
Subject: Re: [PATCH 09/13] gfs2: Fix dirtiness checks in gfs2_write_inode()
 and evict_linked_inode()
Message-ID: <x3f2gj46crjxc7e5qkchy7fxpazxhiak3crhelewluugzmb6ok@rgjjdnccdisr>
References: <20261113083336.15152-1-jack@suse.cz>
 <20261113084700.739002-22-jack@suse.cz>
 <sashiko-outbox-212482@kernel.org>
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
In-Reply-To: <sashiko-outbox-212482@kernel.org>
X-Spamd-Result: default: False [-12.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[18];
	MISSING_XM_UA(0.00)[];
	FROM_HAS_DN(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	URIBL_BLOCKED(0.00)[imap1.dmz-prg2.suse.org:helo,suse.cz:email,suse.com:email];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo,suse.cz:email]
X-Spam-Score: -12.80
X-Spam-Level: 
X-Spam-Flag: NO

On Fri 13-11-26 08:56:48, sashiko-bot@kernel.org wrote:
> Thank you for your contribution! Sashiko AI review found 1 potential
> issue to consider:
> - [Low] gfs2: missing Fixes trailers for broken i_flags dirtiness checks
> --
> 
> commit 7de49fbf42de584cd1afa16382bbb192cfbdaf7c
> Author: Jan Kara <jack@suse.cz>
> 
> > gfs2: Fix dirtiness checks in gfs2_write_inode() and evict_linked_inode()
> >
> > The checks are bogus because they check against inode->i_flags instead
> > of inode->i_state. Use the inode_or_folios_dirty() helper which actually
> > checks what was intended.
> >
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> [Severity: Low]
> Should this include Fixes: tags for the commits that introduced the
> inode->i_flags & I_DIRTY checks in gfs2_write_inode() and
> evict_linked_inode()?
> 
>   Fixes: 957a7acd46e6 ("gfs2: Remove inode from ordered write list in gfs2_write_inode()")
>   Fixes: bd67f17718cc ("gfs2: Fix data loss during inode evict")

Yeah, these Fixes tags would be adequate.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
