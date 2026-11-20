Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=91.218.175.181
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795180283;
	b=BXCGxgaZZV7RVXQPo8D/iSG7Klr7VyCTn4Upr/K+M70WJPOj+8i1QihD+SHmWqVt2gUx
	 +KWVCp3tIYxnNrnGO/28DQeRAxrekpjAXGF8yF+4Q9o0YG1sfvRXmkUAyg8+SwYOtim30
	 v+J3qWnRH5tT8H/wEFAWDqu59lcDge0eRVT8Uddh2YA/HfREvtRxMZNywfs5P0DnwgkNJ
	 lhNyFkpwJm7NySw+xLWeKiphwENY6yfPxZksixaCySYtanUUiyDQRHFrfLGiFJQApucwQ
	 OBbNcFt9IiG4H5SS01qbIjJJJbCtBDXYlyB26LtLvk5t4liImSis5ICm3UkTG2lwopw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795180283;
	h=DMARC-Filter:X-Envelope-To:DKIM-Signature:X-Envelope-To:Received:
	 X-Mizu-Trace-ID:X-Migadu-Flow:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=11EUqqsBHqKJhSEKaLjedxJRvUSCpiSlKRotGWVYopQ=;
	b=4z87Ot+80w2rSjm9nwxB8hVR5e223tgi5NvV8dVxd3QaTsXsjPBZQ1SmA1QF6jTyjR8i
	 5HHj+odsMBi/DDiaLcdp8y/A3elgmGbONX42GEaZMF+UAxHlKdNZ4gyVw0VGiadfaQ/A8
	 Uj/j8QQDy7n3JwuXZ/FigzzqBSYkM7bbmjcGgOu34RGmOORNtPWJnhSsiW8IuEq/6a4Oz
	 /C0PJ+Gr2mZKMkspGv+9Q3vsefXKs0bnY1z80XyJAYYhkvs0S3WJaGw1ENAkxM9IkwNX2
	 fzp+6DYwrpnnA853WJmd7G5D66Dd5ffnSqvV8Qbk98hjUpmCWYIlw4w67lpxmYH2/wQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.dev;
	spf=pass smtp.mailfrom=linux.dev;
	dkim=pass header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=pcpMXMRk;
	arc=none smtp.remote-ip=91.218.175.181
Received: from mta0.migadu.com (out-181.mta0.migadu.com [91.218.175.181])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD87D606A32C
	for <linux-fscrypt@vger.kernel.org>; Fri, 20 Nov 2026 13:11:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BD87D606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.dev header.i=@linux.dev header.a=rsa-sha256 header.s=key1 header.b=pcpMXMRk
X-Envelope-To: linux-fscrypt@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=AFN9OOtQlK1HJO8cWelVMtGeAQ6PKLi87EwwnhaP1iY=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1795180281; v=1; x=1795785081;
 b=pcpMXMRkQ4Ns6fd064vPWWatVGroU9IVtkGO3ROe58Y6pOfgmdrRaA8URbSyfTUF5AbEgZhD
 i68/L46VO8eq6YVzH9zTsvTRNPM0a79tLxALqyXzHBnW3aN7CqxWw7P6596t4l+BKqmEoxYpK8c
 D1wn0Zhz0yPrczpYDf0gH1hM=
X-Envelope-To: linux-fscrypt@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 1d043ee31403846b;
	Fri, 20 Nov 2026 13:11:20 +0000
X-Mizu-Trace-ID: 1d043ee31403846b
X-Migadu-Flow: FLOW_OUT
Date: Fri, 20 Nov 2026 14:11:11 +0100
From: "Pankaj Raghav (Samsung)" <pankaj.raghav@linux.dev>
To: Jan Kara <jack@suse.cz>
Cc: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org, 
	Andreas Gruenbacher <agruenba@redhat.com>, gfs2@lists.linux.dev, Mike Marshall <hubcap@omnibond.com>, 
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, Dave Kleikamp <shaggy@kernel.org>, 
	jfs-discussion@lists.sourceforge.net, Carlos Maiolino <cem@kernel.org>, linux-xfs@vger.kernel.org, 
	David Howells <dhowells@redhat.com>, Marc Dionne <marc.dionne@auristor.com>, 
	linux-afs@lists.infradead.org, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.linux.dev, 
	linux-block@vger.kernel.org, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-nfs@vger.kernel.org, Eric Biggers <ebiggers@kernel.org>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, 
	Carlos Maiolino <cmaiolino@redhat.com>
Subject: Re: [PATCH 02/13] xfs: Drop pointless I_DIRTY_PAGES check in
 xfs_can_free_cowblocks()
Message-ID: <awBGYTkywYFOaYOI@quentin>
References: <20261116171044.6938-1-jack@suse.cz>
 <20261118145941.1063127-15-jack@suse.cz>
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
In-Reply-To: <20261118145941.1063127-15-jack@suse.cz>

On Wed, Nov 18, 2026 at 03:59:36PM +0100, Jan Kara wrote:
> PAGECACHE_TAG_DIRTY is the authoritative source of information about any
> folio being dirty in the mapping. I_DIRTY_PAGES is just an approximation
> used by writeback code that can get stale under certain situations. So
> just rely on the authoritative check.
> 
> Reviewed-by: Carlos Maiolino <cmaiolino@redhat.com>
> Signed-off-by: Jan Kara <jack@suse.cz>

Looks good,
Reviewed-by: Pankaj Raghav (Samsung) <pankaj.raghav@linux.dev>

> ---
>  fs/xfs/xfs_reflink.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/xfs/xfs_reflink.h b/fs/xfs/xfs_reflink.h
> index 683c1841e640..1310cc9fe829 100644
> --- a/fs/xfs/xfs_reflink.h
> +++ b/fs/xfs/xfs_reflink.h
> @@ -17,8 +17,7 @@ xfs_can_free_cowblocks(struct xfs_inode *ip)
>  {
>  	struct inode *inode = VFS_I(ip);
>  
> -	if ((inode_state_read_once(inode) & I_DIRTY_PAGES) ||
> -	    mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY) ||
> +	if (mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY) ||
>  	    mapping_tagged(inode->i_mapping, PAGECACHE_TAG_WRITEBACK) ||
>  	    atomic_read(&inode->i_dio_count))
>  		return false;
> -- 
> 2.53.0
> 
