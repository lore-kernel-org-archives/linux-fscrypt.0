Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03AED2FD7C3;
	Sun, 11 Oct 2026 17:25:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791739502; cv=none; b=GomvORh3ZaeTSdqAk2Qh1yJqurEJUbkNtEJONfAgjFJZIGe7NPmZOPAetxIekU0ViNhzyv6GIDrS3dWZwCLdXulBsGudXXoCqBcxE6P+OEzEf/egLkrNXbSJBUs3z2XFAE9KTg8OzJAWbjmU6MAKGcNpaDieZAUPg7+bpjKOciA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791739502; c=relaxed/simple;
	bh=bsWqQV3Dlos7mX3ukiTa8b3k63Rey0LSKmysTARbrsM=;
	h=Message-ID:From:Subject:To:Cc:In-Reply-To:References:Content-Type:
	 Date; b=kBcuw4b4uH/kWezdxGFMNJAJNHGeLGLE2rwTsm50mJBAx19qWXcr4/0vJstyhYjDF218FLlqvWCwmXazi6SWprhj0p/vv21ulD0I5LjTNDgPMgfk9f5JZcfS/jRXku8NNZwp/I4VOT42ZDGGd4LPSx6VhapwsNtXBDoN2IwFfqU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=R3c+Rz50; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="R3c+Rz50"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 564741F0089B;
	Sun, 11 Oct 2026 17:25:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791739500;
	bh=vJBX0Md+Fzj5R7c80s7zjzU4qhRkF+aJisIBLabEABA=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=R3c+Rz50m98snE2EGosfsfeu9pJm4S4Npx57t5GCYO6mMwqoFuBNxJQ+iRPzOVmS7
	 B0F2MHSN58oXbF4QxSjVdiM7urU735MuVnfzSk0RVAo0028Ua28Cu0n73ARkplFoIi
	 3w8Itot5D4GnFeYgnqVIHwTe03lJV067i0oEwyVvX/J/fX1oHtDYjh02EesIWJ1mWf
	 OaGcjPHNA5JKDuB+aGGKDFM9ysOBdgc5wuKvubD5hTQ955awRKy+tOAq4lwq9+8jph
	 HSJxCTCVx7S+n7PtnI/iLKKvk58gyAU1zB1iZk5LyOX6jbid5aAOaYwXJ1PrT33wMu
	 T5c3/Vpp95TIA==
Message-ID: <sashiko-outbox-167346@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 10/13] block: don't require data unit aligned bio_vecs
 for encrypted bios
Reply-To: sashiko-reviews@lists.linux.dev
To: "Baokun Li" <libaokun@linux.alibaba.com>
Cc: tytso@mit.edu, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
In-Reply-To: <20261011170958.1759230-11-libaokun@linux.alibaba.com>
References: <20261011170958.1759230-1-libaokun@linux.alibaba.com>
 <20261011170958.1759230-11-libaokun@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 11 Oct 2026 17:24:59 +0000
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>

Thank you for your contribution! Sashiko AI review found 1 potential issue(=
s) to consider:
- [Critical] btrfs: infinite loop and double submission in btrfs_submit_bbi=
o() due to unhandled negative error from bio_split_rw_at()
--

commit 7790faffa64672f5a012e4c7a5a36eb8b60cf57a
Author: Baokun Li <libaokun@linux.alibaba.com>

block: don't require data unit aligned bio_vecs for encrypted bios

This patch drops the requirement that every bio_vec in an encrypted bio
must be data unit aligned and a multiple of the data unit size. The
alignment is now handled by bio_split_alignment() rounding the split size
down to the data unit size.

> diff --git a/block/blk-merge.c b/block/blk-merge.c
> index 9bcc9c52eea17..dd9be4c04041a 100644
> --- a/block/blk-merge.c
> +++ b/block/blk-merge.c
> @@ -346,20 +346,18 @@ static inline unsigned int bvec_seg_gap(struct bio_=
vec *bvprv,
>  int bio_split_io_at(struct bio *bio, const struct queue_limits *lim,
>  		unsigned *segs, unsigned max_bytes, unsigned len_align_mask)
>  {
> -	struct bio_crypt_ctx *bc =3D bio_crypt_ctx(bio);
>  	struct bio_vec bv, bvprv, *bvprvp =3D NULL;
>  	unsigned nsegs =3D 0, bytes =3D 0, gaps =3D 0;
>  	unsigned int align, split_bytes;
>  	struct bvec_iter iter;
> -	unsigned start_align_mask =3D lim->dma_alignment;
> -
> -	if (bc) {
> -		start_align_mask |=3D (bc->bc_key->crypto_cfg.data_unit_size - 1);
> -		len_align_mask |=3D (bc->bc_key->crypto_cfg.data_unit_size - 1);
> -	}
> =20
>  	bio_for_each_bvec(bv, bio, iter) {
> -		if (bv.bv_offset & start_align_mask ||
> +		/*
> +		 * The bio_vecs of a bio with a crypto context don't have to
> +		 * be data unit aligned, only the bio as a whole does; see
> +		 * bio_crypt_set_ctx() and bio_split_alignment().
> +		 */
> +		if (bv.bv_offset & lim->dma_alignment ||
>  		    bv.bv_len & len_align_mask)
>  			return -EINVAL;

[Severity: Critical]
Since bio_split_io_at() (and functions wrapping it like bio_split_rw_at())
returns negative error codes such as -EINVAL, can this lead to an infinite
loop in btrfs callers?

In fs/btrfs/bio.c:btrfs_append_map_length(), the return value is not
checked for negative error codes:

	sector_offset =3D bio_split_rw_at(&bbio->bio, &fs_info->limits,
					&nr_segs, map_length);
	if (sector_offset) {
		/* ... */
		return ALIGN_DOWN(sector_offset << SECTOR_SHIFT,
				  fs_info->sectorsize);
	}

If bio_split_rw_at() returns a negative error code (such as -EINVAL or
-EAGAIN), ALIGN_DOWN() will operate on a negative value and return a massive
u64.

This huge value is then returned as map_length to btrfs_submit_chunk(),
where it causes the bio split to be skipped since map_length < length is
false.

Because btrfs_submit_chunk() returns false, it causes its caller
btrfs_submit_bbio() to enter an infinite loop:

	while (!btrfs_submit_chunk(bbio, mirror_num))
		;

Do the btrfs callers need to be updated to handle these negative return
values, or does this patch change the conditions under which
bio_split_io_at() returns an error for encrypted bios?

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261011170958.1759=
230-1-libaokun@linux.alibaba.com?part=3D10
