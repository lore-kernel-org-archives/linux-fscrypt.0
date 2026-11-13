Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794560361;
	b=nW2tVuyH1S0ORT49LA6R+tUg6mFKn8b8dJvop7yBUzNo5mfgEGn6a8c8JXyB9OWdELye
	 4iFtN30Hjs34+tTbsbpYwM5nweiPpoos7FMOlDG8WE3S5KRWZKRTxpPPTMLt4mrYnzOOj
	 OMofrLfDOSZM/Mht2U3I0QVhxyfKFhNM4GKgdCJtoWFw+hVGDoycJmi0yTY7qBGCxxy+m
	 fGSQFpt1y03jy12zzZwp2/fnsYZXys4caPvHmYWeqWCxS9ILz5wpSTd8mS0xoZc6mUDGc
	 zwY+02evU2+Tfg1aD2Q59HA0+/zZchbhkx5ve1dBKNex97rBXA0e5YoWxVWOujLgp1w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794560361;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=AHcMR9ouclLl0qBnB/XHF0hei1XlnHp+j5c1xl4OMsM=;
	b=TJYHXlejMLOFp9Kw7wMyzqmVtnXMSyXBtFzg8xDjPxWqERPCQhNHdlVS04HQMrmaj15S
	 nXK52PHneDFf+OeOOr4b8wIcXqvIdYS/hVGkS4xtZ8WwWNMpxkr5tjIvU7hygPxGXE8J0
	 SfE21MBklhNKrilVEeeYOmjlPc6r1oBm9Cxs9GgnSdYhofC74irV4EU+9+qgA7exRwvo+
	 VYurG65KVhY+qkjcSDGdljQOY4j3k9eCP3piO93evcfFE285Y6OI4A1IlBN88x2IvUoBg
	 hoRqRo1hIw5C4Khs7eBo+qsofeS1c36astnBRBUZ0OGgsAfTpFUZbudq3V7t/VXMdMA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XyckRIce;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EF9B606A881
	for <linux-fscrypt@vger.kernel.org>; Fri, 13 Nov 2026 08:59:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XyckRIce
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 12BA81F000C5;
	Fri, 13 Nov 2026 08:59:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794560360;
	bh=AHcMR9ouclLl0qBnB/XHF0hei1XlnHp+j5c1xl4OMsM=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=XyckRIce55SA8fFI5i90pOxAd6A6iUkJy5O/2h3CBRmYXOOK5HvgN1l0XgxkHH8O3
	 bwnMBBr7gOjR4veBdaTVuCx30PwAlud/o7mFFJy98lL+zmyUqLGWKqTNNwg3Btv+ih
	 hJs36ue2uw5HMTYC74JED0yLBcl3S/913WTaWkKBE4lnSCllzF+voSVEWed46DtRyM
	 vDMHsvq28/HlZYKoZZ6FETbpuhXKdgkqXLujrCg0gKJH+dlRj1m0NKjq2cSWRxzdeD
	 DjHxlH+V615mPEGWNMhTfRkQztV4vdDHs0hh89z36BFQf8Nhu2sMgM//es9aDYcC7O
	 lNX2nvw5a5t4A==
Message-ID: <sashiko-outbox-212487@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 11/13] nfsd: Use inode_or_folios_dirty() for dirtiness
 check in wait_for_concurrent_writes()
Reply-To: sashiko-reviews@lists.linux.dev
To: "Jan Kara" <jack@suse.cz>, "Christian Brauner" <brauner@kernel.org>
Cc: "Andreas Gruenbacher" <agruenba@redhat.com>, "Mike Marshall" <hubcap@omnibond.com>, "Martin
 Brandenburg" <martin@omnibond.com>, devel@lists.orangefs.org, "Dave
 Kleikamp" <shaggy@kernel.org>, "Carlos Maiolino" <cem@kernel.org>, "David
 Howells" <dhowells@redhat.com>, "Marc Dionne" <marc.dionne@auristor.com>, "Miklos
 Szeredi" <miklos@szeredi.hu>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>, "Eric
 Biggers" <ebiggers@kernel.org>, "Jaegeuk Kim" <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, "Anna
 Schumaker" <anna@kernel.org>
In-Reply-To: <20261113084700.739002-24-jack@suse.cz>
References: <20261113083336.15152-1-jack@suse.cz>
 <20261113084700.739002-24-jack@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Fri, 13 Nov 2026 08:59:19 +0000
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

Thank you for your contribution! Sashiko AI review found no new issues
in this patch, but noticed 1 related pre-existing issue it does not
introduce:
- [Medium] nfsd: data race on static variables in
  wait_for_concurrent_writes() [1]
--

commit e80cc2d41e77d086f3f345c30a86cbe9a96c4044
Author: Jan Kara <jack@suse.cz>

nfsd: Use inode_or_folios_dirty() for dirtiness check in wait_for_concurren=
t_writes()

This commit replaces the racy I_DIRTY check in wait_for_concurrent_writes()
with inode_or_folios_dirty() so that concurrent writeback clearing
I_DIRTY_PAGES or lazytime timestamp updates do not cause vfs_fsync() to be
skipped.

> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 6905d3285ce10..f271b474e76ce 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1431,7 +1431,7 @@ static int wait_for_concurrent_writes(struct file *=
file)
>  		dprintk("nfsd: write resume %d\n", task_pid_nr(current));
>  	}
> =20
> -	if (inode_state_read_once(inode) & I_DIRTY) {
> +	if (inode_or_folios_dirty(inode)) {
>  		dprintk("nfsd: write sync %d\n", task_pid_nr(current));
>  		err =3D vfs_fsync(file, 0);
>  	}

[Severity: Medium]
This problem wasn't introduced by this patch, but can concurrent NFSD
threads cause a data race on the static variables last_ino and last_dev in
wait_for_concurrent_writes() [1]?

fs/nfsd/vfs.c:wait_for_concurrent_writes() {
	struct inode *inode =3D file_inode(file);
	static ino_t last_ino;
	static dev_t last_dev;
	int err =3D 0;

	if (atomic_read(&inode->i_writecount) > 1
	    || (last_ino =3D=3D inode->i_ino && last_dev =3D=3D inode->i_sb->s_dev=
)) {
		...
		msleep(10);
		...
	}
	...
	last_ino =3D inode->i_ino;
	last_dev =3D inode->i_sb->s_dev;
	return err;
}

Because last_ino and last_dev are shared across all NFSD threads and read
and written without synchronization, concurrent write requests can observe
torn accesses or mismatched inode and device pairs, causing spurious
msleep(10) delays or missed write deferrals.

[1] https://sashiko.dev/#/bug/linux-f2ccec51-4c11-45a7-a336-775a80d79f1c

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261113083336.1515=
2-1-jack@suse.cz?part=3D11
