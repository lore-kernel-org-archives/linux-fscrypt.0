Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794560404;
	b=fQgvFAwE/Xn6jRXJbCYH8gZvZMWRd5dTMbZtW5+fq9phQ4kxUT3IbO9njPX2ajGcV4MO
	 2kha/Ki9+Y5+mKsWteIBNCgs8qeuIfUL+UjJoxrlVYx7r7mPQqknHNfv/GzYjkqZCS4Vr
	 jSpZ+HXBFBcBITiWzSdwyCTMQOLk3PapjZbLied/+hSlQSWYu/spOpPD39cTAXqPR7BBM
	 20zA2wLa+Cjk51qy9/RcPHzGeYNRWRbtoSdnBhQVjm+bfGuIwVV366ygd08UrjUXj0xw6
	 mCZUr9J30/MwY3eEr6upGUrHQLDuVBgcL0qaO3px1ANWlT+SkUo0Ndh7bzrgi7Wbv9g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794560404;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=u43gQFAuztgOiqXD0YU6kuxQGoAY0DC78ECQ+347+rw=;
	b=RnqTd86anOzjdLmY+3fDikxXi0mIBsKoz+bjxduLecM6+faXEdVE+XuJ0ycI+7TCXK+5
	 kOwUSObkWInu5tBD4gMk5z96UmLRi5Js25KTzuckyrQK+BKHGwONzrcJYyT+4A/ty7mN6
	 lqmmQ7YMZpOuHKTKQDm2y6qUPa/SJdap8Vu342ICP6F6xQhI6YcyxhI71UUOKLLivOV2i
	 MZEdxpGJc/JVzbedlvHpvrcmuP119gLNhZBx/Q7iUtJLwcDiyPnKG6vbHvH6kqNdKyQBA
	 3efHWAzk20R3XzKRsWN1Tfjt5kDdUfZhYC2D0q4p0z8lBkbm1cXLALrRC2WQuzFl7hg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="a/1wbbN0";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B60F606A330
	for <linux-fscrypt@vger.kernel.org>; Fri, 13 Nov 2026 09:00:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=a/1wbbN0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 37BAF1F000C5;
	Fri, 13 Nov 2026 09:00:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794560404;
	bh=u43gQFAuztgOiqXD0YU6kuxQGoAY0DC78ECQ+347+rw=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=a/1wbbN0NLA24kpZS9ahng1bDUpfwGsGC7WmRpluZnmMGlBRi02MyjWcUrhPRPvbU
	 O2uny+/lJTV1n66q+t1+dK+zbjXJk4mI0CiVdKhYIV68nJiHz1gxXQ/Be8/UZWl5bZ
	 ijQwgyNBzgkxZXx4mexo/jHm3SY2TbTJ1HUF5oNv1uotdyVOhzdnsiRqMPg4Z+L/ve
	 Npj5I3xxofIHhmv6+lCRx5w6wdAq5Oe/TU9L+eBuoYvcO0ZRObzAP5vbXpSf58+rv+
	 1s5+yc/64e9ZlAc4ptDdbZfSPmy15PnfrvxuqlH5n00ZaHOgERRQX6M0bwsdmQZ4nd
	 cgSOY8gKxcQzw==
Message-ID: <sashiko-outbox-212490@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 03/13] orangefs: Check PAGECACHE_TAG_DIRTY instead of
 I_DIRTY_PAGES inode state
Reply-To: sashiko-reviews@lists.linux.dev
To: "Jan Kara" <jack@suse.cz>, "Christian Brauner" <brauner@kernel.org>
Cc: "Andreas Gruenbacher" <agruenba@redhat.com>, "Mike Marshall" <hubcap@omnibond.com>, "Martin
 Brandenburg" <martin@omnibond.com>, devel@lists.orangefs.org, "Dave
 Kleikamp" <shaggy@kernel.org>, "Carlos Maiolino" <cem@kernel.org>, "David
 Howells" <dhowells@redhat.com>, "Marc Dionne" <marc.dionne@auristor.com>, "Miklos
 Szeredi" <miklos@szeredi.hu>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>, "Eric
 Biggers" <ebiggers@kernel.org>, "Jaegeuk Kim" <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, "Anna
 Schumaker" <anna@kernel.org>
In-Reply-To: <20261113084700.739002-16-jack@suse.cz>
References: <20261113083336.15152-1-jack@suse.cz>
 <20261113084700.739002-16-jack@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Fri, 13 Nov 2026 09:00:01 +0000
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
- [High] orangefs: stale i_size overwrite during writeback in
  orangefs_inode_getattr()
--

commit 627feba60e819dc443191dbfcd63f583f8da0f24
Author: Jan Kara <jack@suse.cz>

orangefs: Check PAGECACHE_TAG_DIRTY instead of I_DIRTY_PAGES inode state

This commit replaces checks of the I_DIRTY_PAGES inode state flag in
orangefs_inode_getattr() with mapping_tagged(..., PAGECACHE_TAG_DIRTY).

> diff --git a/fs/orangefs/orangefs-utils.c b/fs/orangefs/orangefs-utils.c
> index 9ab1119ebd28a..4c4036f470cdd 100644
> --- a/fs/orangefs/orangefs-utils.c
> +++ b/fs/orangefs/orangefs-utils.c
> @@ -247,7 +247,8 @@ int orangefs_inode_getattr(struct inode *inode, int f=
lags)
>  	spin_lock(&inode->i_lock);
>  	/* Must have all the attributes in the mask and be within cache time. */
>  	if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)) ||
> -	    orangefs_inode->attr_valid || inode_state_read(inode) & I_DIRTY_PAG=
ES) {
> +	    orangefs_inode->attr_valid ||
> +	    mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
>  		if (orangefs_inode->attr_valid) {
>  			spin_unlock(&inode->i_lock);
>  			write_inode_now(inode, 1);
> @@ -281,13 +282,14 @@ int orangefs_inode_getattr(struct inode *inode, int=
 flags)
>  	spin_lock(&inode->i_lock);
>  	/* Must have all the attributes in the mask and be within cache time. */
>  	if ((!flags && time_before(jiffies, orangefs_inode->getattr_time)) ||
> -	    orangefs_inode->attr_valid || inode_state_read(inode) & I_DIRTY_PAG=
ES) {
> +	    orangefs_inode->attr_valid ||
> +	    mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
>  		if (orangefs_inode->attr_valid) {
>  			spin_unlock(&inode->i_lock);
>  			write_inode_now(inode, 1);
>  			goto again2;
>  		}
> -		if (inode_state_read(inode) & I_DIRTY_PAGES) {
> +		if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY)) {
>  			ret =3D 0;
>  			goto out_unlock;
>  		}

[Severity: High]
Can orangefs_inode_getattr() overwrite inode->i_size with a stale size from
the server while pagecache writeback is in flight?

When a buffered write extends a file in orangefs_write_end(), inode->i_size
is updated in memory and the folio is marked dirty, while the server only
learns the new size once the writeback RPC in wait_for_direct_io()
completes.  Previously, I_DIRTY_PAGES stayed set in
__writeback_single_inode() across the entire do_writepages() call.
However, folio_start_writeback() clears PAGECACHE_TAG_DIRTY and sets
PAGECACHE_TAG_WRITEBACK before wait_for_direct_io() sends the write to the
server:

CPU0                                  CPU1
orangefs_writepage_locked()
  folio_start_writeback(folio)
    /* clears PAGECACHE_TAG_DIRTY,
       sets PAGECACHE_TAG_WRITEBACK */
                                      orangefs_getattr()
                                        orangefs_inode_getattr(...,
                                            ORANGEFS_GETATTR_SIZE)
                                          /* PAGECACHE_TAG_DIRTY is false */
                                          service_operation(GETATTR)
                                          inode->i_size =3D ...; <-- stale =
size
  len =3D i_size_read(inode);
  wait_for_direct_io(ORANGEFS_IO_WRITE, ...)

As a result, any concurrent getattr with non-zero flags (such as
orangefs_getattr() or orangefs_file_llseek()) fetches the pre-write size
from the server and clobbers inode->i_size, which also causes
orangefs_writepage_locked() (or a subsequent batch in
orangefs_writepages_work()) to clamp the write length to the stale size and
truncate the buffered write.

Should these checks also test mapping_tagged(inode->i_mapping,
PAGECACHE_TAG_WRITEBACK) (or mapping_writably_mapped() / a helper covering
both PAGECACHE_TAG_DIRTY and PAGECACHE_TAG_WRITEBACK)?

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261113083336.1515=
2-1-jack@suse.cz?part=3D3
