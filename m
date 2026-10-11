Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C9255328635;
	Sun, 11 Oct 2026 17:18:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739105; cv=none; b=BUJu7/XcZUz9NiW3tEzjz4Tk8ZCUe3eTI6w/XVjYoJC8d9/GQhB3F/KG/o+MnkMLo5lG/whlb/NYlNkTIEcG+wWVEsjaYh/jkVzCA3G+5E31z3fj0PBpkanDmcVlG0hCPtKfnTB1RK02OJbThTVbO+UVyom1Gr6MOBLbqWW2gq0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739105; c=relaxed/simple;
	bh=UYTbdUwAbo2wEhYq5RzyzKCuI5y/Swm24Oj9PAYf0L4=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=RxW+eyKKXWkiADnenaRc7m546vAZFiedNQ0dhbRxLtz0INQp/h1Z4dHhknlmPEFnHThTH7jAgl+Ad5uY7KNfw1bgcYW92cm7zLSVeQv6QLfti6YQrt3dmZQPSZjGJg4DvGtq4fPQEAnRMLRpi/8PyfCvD6qPvbB1HUOAIxYZIhw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CdH2lUQF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CdH2lUQF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7918D1F0089B;
	Sun, 11 Oct 2026 17:18:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739104;
	bh=UYTbdUwAbo2wEhYq5RzyzKCuI5y/Swm24Oj9PAYf0L4=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=CdH2lUQFa8fdQmmHmekE8QAQhwxQ21FwQLQVv+Z54H1kO7dRDRCEtRb/s2orhai3m
	 PnrbV7eqhsYkQecy3pzeFOe+MDCs5FROU7jQG6yZbBwW/7agutbk3UxI3Y8NUTky0e
	 WNwpARkYwT3zlxIZjV4qcr+ayZIv7/FYgrn1fJ9NwOoaSQ1hbsu/XQ/4GwxlgHZpn4
	 THiAedFueCBgtNY+A6ZqJva6fDwt/SRnmBk+KxO+YnB60p7eNp+LDA4rBWzyFsG152
	 H5kzzejQ53xPy7hiHTZAAPLvMPLDa20g+QpcCUzTZSdY7J4j0bVCfWFX4hhPIdvInh
	 CUZTTqZWN5B7w==
Message-ID: <sashiko-outbox-167338@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 09/13] block: warn about bios that can't be split
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, tytso@mit.edu, linux-fscrypt@vger.kernel.org
In-Reply-To: <20261011170958.1759230-10-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-10-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:18:24 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

> bio_split_io_at() fails a bio that it can't split into a valid request
> with -EINVAL: a bio may have too many discontiguous segments for the
> queue, may have virtual boundary gaps that leave it without a block
> sized split, and now that the split size is rounded down to the data
> unit size of an encryption context, it may have a data unit that does
> not fit in the room that the queue limits leave for the split.
>=20
> Nothing else says which queue limit caused the failure, and a limit that
> is smaller than the data unit size, e.g. a max_sectors_kb that was
> lowered below it, is accepted by the block layer, so warn about it, with
> the bytes that fit and the alignment involved.
>=20
> Signed-off-by: Baokun Li <libaokun@linux.alibaba.com>

Sashiko has reviewed this patch and found no issues. It looks great!

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D9

