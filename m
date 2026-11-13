Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794560903;
	b=CdlIhH58MyC1N+gI/iq7UzQEGAQ2igRIz5rHjdDMJsP01fX/OegAPu3dRWaDoS8GaVrG
	 gmfOQb96COjrnvg8qe8k6Fa3EKuRv180AXWSb8bInq669zRhls2jZzheQeFhhced+KI+m
	 1h9oBiyMDkbRUarQQQ5M3Xz7ywUiNkDC+A9RCO9gFjQzgyuwjIGBZWzivqfTZQimtCbrt
	 ADdSSytBZrU43G97m9emamapIt2nHx5T2+C3n38SZd9cftTEWJp20qdVbVc6KwKom2lM9
	 I3anLES5qmaEHxb/mvnK1QR6VEikqWJcc6zft7Xc9sfiotWI0L5gGADRQ0DGKd+egog==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794560903;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=Ot2429bzU88VhQvLetOvmXP1QJM2MC1F4ZujFUrtmBs=;
	b=1RnlEBt9mOunshI3U14uz1mglcauqgAwEZJg+xaNjQ7m65Jtcnkw7zS8CDuafRe0au4D
	 uQcYu8/Ca3movESc5bVr1y8+y+9AdOWxyjSs3lQQjLPM3pyE3WxvmcXnCZTKcRZ5CSomx
	 Jd16ASWILix29oDtPKtIbWhcgcH1JDkMgGfikkk9hdSn0R+Yx9SZ+PsUD9Xc6tJ6++pVY
	 rT4DPygP/+U4ln8f8o08ddwYb+wjIXZyi2rl6VSmk4Z5pXojssgQkkGsnMNO+YdVaZe9o
	 WhFPjP+sboveOHgU8STvr2UuRDwh91dLNULDuH5H9L3BmpESQZdhBqvwW+wZ+Q0bAVg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DFI90yH6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B3BC1606A321
	for <linux-fscrypt@vger.kernel.org>; Fri, 13 Nov 2026 09:08:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DFI90yH6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ACD181F000C5;
	Fri, 13 Nov 2026 09:08:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794560903;
	bh=Ot2429bzU88VhQvLetOvmXP1QJM2MC1F4ZujFUrtmBs=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=DFI90yH6n9ZIgffqGZ3DmNWuA5qnhH7eERzzvFiQN389WWf+sCVaC4YKBZTffWLvg
	 bbZZ55K6Ke3hj7KsClEp0SZllPJqrBmfcvighr68pxkTekbJVNVsgiUu6VUJeJ3s+e
	 Kzk1gD7mA9D0USbeu3mZ3XmKqh/08DOEsJ9DEODh5KKFHZzDL1VfcsJvmnbLaXcDy9
	 0UIG5PVStYkD+19gNdHE2Cj+ntowSUkYeQP3tHbecn3bc80vgDue5XY+ACMuCzG5In
	 JBtMMAM0OYKPXgeKVnbhAVzQFqlRBDKnur2qhYmJ2GIjWQepuadx0/CUI0MtFckIqI
	 6Zv9RjovwMvvQ==
Message-ID: <sashiko-outbox-212504@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 06/13] gfs2: Avoid racy dirtiness check in gfs2_fsync()
Reply-To: sashiko-reviews@lists.linux.dev
To: "Jan Kara" <jack@suse.cz>, "Christian Brauner" <brauner@kernel.org>
Cc: "Andreas Gruenbacher" <agruenba@redhat.com>, "Mike Marshall" <hubcap@omnibond.com>, "Martin
 Brandenburg" <martin@omnibond.com>, devel@lists.orangefs.org, "Dave
 Kleikamp" <shaggy@kernel.org>, "Carlos Maiolino" <cem@kernel.org>, "David
 Howells" <dhowells@redhat.com>, "Marc Dionne" <marc.dionne@auristor.com>, "Miklos
 Szeredi" <miklos@szeredi.hu>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>, "Eric
 Biggers" <ebiggers@kernel.org>, "Jaegeuk Kim" <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, "Anna
 Schumaker" <anna@kernel.org>
In-Reply-To: <20261113084700.739002-19-jack@suse.cz>
References: <20261113083336.15152-1-jack@suse.cz>
 <20261113084700.739002-19-jack@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Fri, 13 Nov 2026 09:08:22 +0000
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

Thank you for your contribution! Sashiko AI review found 1 potential
issue to consider:
- [High] gfs2: gfs2_fsync() checks PAGECACHE_TAG_DIRTY after
  filemap_fdatawrite_range()
--

commit a74a8e373d1c581c53bf8dbda94cd97b2bf0e19f
Author: Jan Kara <jack@suse.cz>

gfs2: Avoid racy dirtiness check in gfs2_fsync()

This commit replaces the unlocked I_DIRTY check in gfs2_fsync() with
inode_is_dirty() and a PAGECACHE_TAG_DIRTY check on the mapping for jdata
inodes.

> diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
> index 1efd0679badd9..9e52f18326737 100644
> --- a/fs/gfs2/file.c
> +++ b/fs/gfs2/file.c
> @@ -749,7 +749,6 @@ static int gfs2_fsync(struct file *file, loff_t start=
, loff_t end,
>  {
>  	struct address_space *mapping =3D file->f_mapping;
>  	struct inode *inode =3D mapping->host;
> -	int sync_state =3D inode_state_read_once(inode) & I_DIRTY;
>  	struct gfs2_glock *gl =3D gfs2_inode_glock(inode);
>  	struct gfs2_inode *ip =3D GFS2_I(inode);
>  	int ret =3D 0, ret1 =3D 0;
> @@ -760,12 +759,9 @@ static int gfs2_fsync(struct file *file, loff_t star=
t, loff_t end,
>  			return ret1;
>  	}
> =20
> -	if (!gfs2_is_jdata(ip))
> -		sync_state &=3D ~I_DIRTY_PAGES;
> -	if (datasync)
> -		sync_state &=3D ~I_DIRTY_SYNC;
> -
> -	if (sync_state) {
> +	if (inode_is_dirty(inode, datasync) ||
> +	    (gfs2_is_jdata(ip) && mapping_tagged(inode->i_mapping,
> +						 PAGECACHE_TAG_DIRTY))) {
>  		ret =3D sync_inode_metadata(inode, 1);
>  		if (ret)
>  			return ret;

[Severity: High]
Does checking mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY) after
filemap_fdatawrite_range(mapping, start, end) miss dirty jdata pages?

Previously, sync_state was sampled before filemap_fdatawrite_range().  For a
jdata inode, filemap_fdatawrite_range() runs gfs2_jdata_writepages() with
WB_SYNC_ALL, which flushes the log and calls gfs2_write_cache_jdata() ->
gfs2_write_jdata_batch() -> folio_clear_dirty_for_io(), clearing
PAGECACHE_TAG_DIRTY on the folios in [start, end] before this check is
reached.

When overwriting already-allocated blocks of an unstuffed jdata file,
gfs2_iomap_put_folio() only increments tr->tr_num_databuf_new (leaving
tr->tr_num_buf_new =3D=3D 0), so I_DIRTY_DATASYNC is not set:

fs/gfs2/bmap.c:gfs2_iomap_put_folio() {
	...
	if (gfs2_is_jdata(ip) || gfs2_is_stuffed(ip)) {
		if (tr->tr_num_buf_new)
			__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
		gfs2_trans_end(sdp);
	}
	...
}

On fdatasync() (or fsync() when timestamps did not change), both
inode_is_dirty(inode, datasync) and mapping_tagged(inode->i_mapping,
PAGECACHE_TAG_DIRTY) then evaluate to false, skipping sync_inode_metadata(),
file_write_and_wait(), and gfs2_ail_flush(gl, 1) and leaving the jdata AIL
buffers unrevoked in the journal.

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261113083336.1515=
2-1-jack@suse.cz?part=3D6
