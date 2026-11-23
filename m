Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795426256;
	b=wGij7n7Jns1QLbV++LfWsSkLoV4ZG7o70O30ICcpzv3U4br6+rQGbVfvw3IWPB5mmkfu
	 K9zoK2+hGJGucZu/FJ8YoTj2a0lMOtIuHqFKewsY/wVhM++FgX1ik73OqnESNG8dW/b0o
	 9DSUVLAqC+sGro4lmJQe9Ahwd8wGHyVgGU90zg0jqlPfBzM8t4b0lgnCuyCIoACpSnQiM
	 ziqcMaVdO+6OGPZ7HqOvrrvRfL+x1MduDgkJNj73nphfg1xNfYqc9qPyj81oYJgzzOvyi
	 uDShrS1bJ/KPPz9uGyMiaWzWuyWmslHdNBJtuEfUAyMqge75WnuWF9ZRcWA1iU35akQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795426256;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=HR3tGr01p/xd4kEORuODSHxO9W+SLv53b4nhMVjrxnA=;
	b=tmkoGqfoG5XhUOG+wjhpWgp00OON9pCpeWWo9gEH3Eq8zvLAF+oy6R6EtQKgOIcR+q9K
	 6V0iYPT1I5hDgmifE7KnrJqdFhK/o8kVj5JGhlkc5rfxMo4f5vYp8Cc18EaCPQROlrDNp
	 4vyU2rlBuB1yEw8Y4sbhCyGP38r9hqUbgD7XagvPR336C6oqWhKArnoTW2wOUPhf36Xbg
	 /Wvh49XRpBUWVtucxcyAmerUg6lIx9/X/HHnG8RQdBgOepHA3Zneqe65E9QPLVDX552Jt
	 0lPd6w86rAvsKPMbHg1UVSryv2/2cTNibZ9cV1CSH2SJLlF2pVquGvSgukFSN3nrLPw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=l2sQmqt6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67210606A321;
	Mon, 23 Nov 2026 09:30:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=l2sQmqt6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 370951F000C0;
	Mon, 23 Nov 2026 09:30:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795426256;
	bh=HR3tGr01p/xd4kEORuODSHxO9W+SLv53b4nhMVjrxnA=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=l2sQmqt6fN50A1T5j2Rg3Laut2oeg6i/kGcP8NfVR+rBe9nnLrkX0MfUw6z9PcD8w
	 lsJhzbMwviOpihMdjT1lFgWDyRL8BtYFs9zo6sWXD4uP6bj2xeGL5KLG8aejbD8mgg
	 XJ/g9OKghNehnJgMnJBw/QBdsL0vGE0mefry+z3aSgBkkmjFw9CfUQOLj7AzXpRJ76
	 sEbfwNmkSVMLUJ92Ulzz0uCBcbGXFkk4EO9BIIJhP1TQtxFQoZ2yNMLWeULFmNeO0s
	 dVsenyaP0cC9TH9pxsRBHREbZhcjDqMWWKIdGE4rExeMC+KyjV/C/MrV7NCQtaHLsK
	 3vRafunuHbxmg==
Message-ID: <sashiko-outbox-228978@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH v3 13/13] fs: Use inode_or_folios_dirty() in
 __inode_lru_list_add()
Reply-To: sashiko-reviews@lists.linux.dev
To: "Jan Kara" <jack@suse.cz>, "Christian Brauner" <brauner@kernel.org>
Cc: "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev, "Mike
 Marshall" <hubcap@omnibond.com>, "Martin Brandenburg" <martin@omnibond.com>, devel@lists.orangefs.org, "Dave
 Kleikamp" <shaggy@kernel.org>, "Carlos Maiolino" <cem@kernel.org>, "David
 Howells" <dhowells@redhat.com>, "Marc Dionne" <marc.dionne@auristor.com>, "Miklos
 Szeredi" <miklos@szeredi.hu>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>, "Eric
 Biggers" <ebiggers@kernel.org>, "Jaegeuk Kim" <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, "Anna
 Schumaker" <anna@kernel.org>
In-Reply-To: <20261123090040.19006-26-jack@suse.cz>
References: <20261123085601.21199-1-jack@suse.cz>
 <20261123090040.19006-26-jack@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Mon, 23 Nov 2026 09:30:54 +0000
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
- [High] fs: UAF of inode->i_mapping in __inode_lru_list_add() after
  dev_dax teardown
--

commit dba191eb05adecdae3b365e1982438c7882c5c1d
Author: Jan Kara <jack@suse.cz>

fs: Use inode_or_folios_dirty() in __inode_lru_list_add()

This commit replaces the I_DIRTY_ALL check in __inode_lru_list_add() with a
call to inode_or_folios_dirty().

> diff --git a/fs/inode.c b/fs/inode.c
> index de207f2f95a98..fb759033aa965 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -552,7 +552,9 @@ static void __inode_lru_list_add(struct inode *inode,=
 bool rotate)
>  {
>  	lockdep_assert_held(&inode->i_lock);
> =20
> -	if (inode_state_read(inode) & (I_DIRTY_ALL | I_SYNC | I_FREEING | I_WIL=
L_FREE))
> +	if (inode_state_read(inode) & (I_SYNC | I_FREEING | I_WILL_FREE))
> +		return;
> +	if (inode_or_folios_dirty(inode))
>  		return;

[Severity: High]
Can inode_or_folios_dirty() cause a use-after-free on inode->i_mapping
when a device-dax character special file inode is added to the LRU after
dev_dax teardown?

Unlike mapping_shrinkable(&inode->i_data) below and the other LRU and
eviction paths in fs/inode.c, inode_or_folios_dirty() dereferences
inode->i_mapping via mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)
whenever I_DIRTY_ALL is clear.

When a device-dax character device is opened, dax_open() redirects the
special file's inode->i_mapping to &dax_dev->inode.i_data, which is
normally only reset to &inode->i_data in evict() -> cd_forget() if
inode->i_cdev is still non-NULL.  If the dev_dax instance is unbound or
deleted while the special file inode remains cached, cdev_purge() clears
inode->i_cdev without restoring inode->i_mapping, and dev_dax_release() ->
put_dax() -> dax_free_inode() frees dax_dev.  When the last reference to
the special file inode is later dropped in iput_final() ->
__inode_lru_list_add(), inode_or_folios_dirty() reads from the freed
dax_dev->inode.i_data mapping.

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261123085601.2119=
9-1-jack@suse.cz?part=3D13
