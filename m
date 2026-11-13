Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794560210;
	b=AiQzRE3MzZDQ7shLcl00DwxP32p7EOgRPdJicvNosmARdK6bIiUP2gGiw63113MN+jP/
	 qYr/PtQBUnSnf702F+MhHqA4kOn/7KjwPQpDb/XV+zgFUEf14v/bflDUPTXrLCVrDDYVF
	 +19W4o5JGP5X5TKfNBf2hPKiKFZUwylDkBHwfQlhlueGyACe7c+eR9KibAYdqW3xgdGPs
	 IlMu2XAHFyUNxN44lOXyBQnzNIZTJhO8uDlRGGPbDFG2OWmB8IM6cGksW66jV6Awy8qoF
	 PPVAP4DjRDx9ZzvCytE+fA6aacqBQ6+GgzzjMBPAp5N2ska9dDLtODbHyU3rTt9Z/qg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794560210;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=IwkvpR11wA+H4zYA7Aml5WgOxftUYq7ttx04va+FqKE=;
	b=pNAZuKM3cnDcdVf1J3hIWqS7W8b/54T3TzIqspagqwFMgJXcE+7/nuBgVf8Vxf65hVAG
	 ZxvaZdH2pcdkK2fIZKETyyjc6yvl9FN4um4X2oGlStnMv3RxinoMARpNhA2Mcay5fUQbI
	 Ugg6Lp5T77OxGiqg0V7nA6OJ33fyubmnxmFmpSCGGWPlXvaNpipcPg/37g5HHy8Qq4NQ1
	 ZyrRw8hFVDbrGHjTv79eq3nufMMmrlwlWU5BBTEGbuHSRDuQlLYgD+VItwRAfhWtfhcLf
	 tLKSLfCBc/n+QzlSFHvAIPI+FhGcYeT9WdyFNw+oJhYUfJ52thaXJdoEDnVtxgErdWA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=O8S7k4yC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1BCA9606A333
	for <linux-fscrypt@vger.kernel.org>; Fri, 13 Nov 2026 08:56:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=O8S7k4yC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A6E3D1F000C4;
	Fri, 13 Nov 2026 08:56:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794560210;
	bh=IwkvpR11wA+H4zYA7Aml5WgOxftUYq7ttx04va+FqKE=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=O8S7k4yCNH+7/YFw8E8ZEtS+BVogpRqz7RSKmX63RJyPVVeJFe7c+uHbLKDSS5A2T
	 kxe3EN4HlwuUM66GseFk4ve72Nzf2Uc/fczXaJqtYyTtXMdRVtop0r6/ptVZLjRdfe
	 VUiSg3D8XqvFpIheBeWmn0wt0oW5cbk5Py0xC/hHhDYmrdVcQWIXQZWn7U9ZWrvib2
	 ED7RVOV5PgNL5qYg8jHkkLYG4goWA+QlWNFepJDTNYh6Ym54RBX8rinApmvOAA3khp
	 V+okagLc50wkaUPjLMIpfEapgu3cOQGR9pCND6BL9HA6u758PG6dJh9L8IJWugGVC1
	 B+C4C7L/M8b4g==
Message-ID: <sashiko-outbox-212482@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 09/13] gfs2: Fix dirtiness checks in gfs2_write_inode()
 and evict_linked_inode()
Reply-To: sashiko-reviews@lists.linux.dev
To: "Jan Kara" <jack@suse.cz>, "Christian Brauner" <brauner@kernel.org>
Cc: "Andreas Gruenbacher" <agruenba@redhat.com>, "Mike Marshall" <hubcap@omnibond.com>, "Martin
 Brandenburg" <martin@omnibond.com>, devel@lists.orangefs.org, "Dave
 Kleikamp" <shaggy@kernel.org>, "Carlos Maiolino" <cem@kernel.org>, "David
 Howells" <dhowells@redhat.com>, "Marc Dionne" <marc.dionne@auristor.com>, "Miklos
 Szeredi" <miklos@szeredi.hu>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>, "Eric
 Biggers" <ebiggers@kernel.org>, "Jaegeuk Kim" <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org, "Anna
 Schumaker" <anna@kernel.org>
In-Reply-To: <20261113084700.739002-22-jack@suse.cz>
References: <20261113083336.15152-1-jack@suse.cz>
 <20261113084700.739002-22-jack@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Fri, 13 Nov 2026 08:56:48 +0000
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
- [Low] gfs2: missing Fixes trailers for broken i_flags dirtiness checks
--

commit 7de49fbf42de584cd1afa16382bbb192cfbdaf7c
Author: Jan Kara <jack@suse.cz>

> gfs2: Fix dirtiness checks in gfs2_write_inode() and evict_linked_inode()
>
> The checks are bogus because they check against inode->i_flags instead
> of inode->i_state. Use the inode_or_folios_dirty() helper which actually
> checks what was intended.
>
> Signed-off-by: Jan Kara <jack@suse.cz>

[Severity: Low]
Should this include Fixes: tags for the commits that introduced the
inode->i_flags & I_DIRTY checks in gfs2_write_inode() and
evict_linked_inode()?

  Fixes: 957a7acd46e6 ("gfs2: Remove inode from ordered write list in gfs2_=
write_inode()")
  Fixes: bd67f17718cc ("gfs2: Fix data loss during inode evict")

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261113083336.1515=
2-1-jack@suse.cz?part=3D9
