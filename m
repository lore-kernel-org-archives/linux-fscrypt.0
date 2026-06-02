Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B60B0366563;
	Tue,  2 Jun 2026 02:56:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780368961; cv=none; b=EGYR73Qs9UpVsNJ0mP2HBxewZE6ckvjEh5JzTjSZhoaZZeDhBeuYPhk3/05upEIA/Q6vQZENWn9SfFmKZ+6642jvCkms/0oSMI9Vv2jMCzhPiUrGNojapey7xW17bktE+b2TPQ6JvDr1MahpDKuE8s1DxYs/2721R+RHPKZxd24=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780368961; c=relaxed/simple;
	bh=K8Fwb7tX6ubMdGXYelWZ7HS/8wp3b0w0G1MppNWjDiI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=FBkelf3GOVfX7yFehGpdLX+gkciUcpwKG+lpcs5D/vMf7f7wLgoxIvFK0uemE2bCnVFm5/7WIEFtGj+1XT++FmCXK8wfXQm2HVGDcbCewgCp7xGu+caEGPL+K/aFhF9klXkwK+DXrvwyn2BYh3eg/54FEmkmCMcGghHkKh+yimo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=a00dtIgU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="a00dtIgU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E0F761F00898;
	Tue,  2 Jun 2026 02:55:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780368960;
	bh=4uSFYiLIOYv/5mn4dn/NqyP7Hr3H809L6pTBK3uFMCg=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=a00dtIgUgmEPE+/jjLMnLs0GCg6Z8+eWZ8KMlZXlE69ATq2gQu1EBr7muXIWO+b+Z
	 zO3VfGPKzwqMievXsLAFyj7m1EyPQDgi4BZNlYNHETVCyOcZEinFw2FNIgwBh3MuUB
	 d0k1L2q5J1pXTvDW6+a90+3BpmzL1qfMfgsLuCS1tCCMuhv99C8hX00qolt0Yyq6E8
	 5YGsND4wWzwV4FtDgufhn9IEi0MI4+NbpHFxWxVgLdC9AR1Q09bSTGNAb518GVySwM
	 K8cT964igSLNpJUC99LgF63nxIhwMdczmzLnho1i8sTruWD4nnaZiWBBigbdtwN1i9
	 SbW1qisG3cTLQ==
Date: Mon, 1 Jun 2026 19:54:36 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Daniel Vacek <neelx@suse.com>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>,
	David Sterba <dsterba@suse.com>, linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Boris Burkov <boris@bur.io>
Subject: Re: [PATCH v7 09/43] btrfs: add infrastructure for safe em freeing
Message-ID: <20260602025436.GF2295@sol>
References: <20260513085340.3673127-1-neelx@suse.com>
 <20260513085340.3673127-10-neelx@suse.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260513085340.3673127-10-neelx@suse.com>

On Wed, May 13, 2026 at 10:52:43AM +0200, Daniel Vacek wrote:
> +/*
> + * Drop a ref for the extent map in the given tree.
> + *
> + * @tree:	tree that the em is a part of.
> + * @em:		the em to drop the reference to.
> + *
> + * Drop the reference count on @em by one, if the reference count hits 0 and
> + * there is an object on the em that can't be safely freed in the current
> + * context (if we are holding the extent_map_tree->lock for example), then add
> + * it to the freed_extents list on the extent_map_tree for later processing.
> + *
> + * This must be followed by a btrfs_free_pending_extent_maps() to clear
> + * the pending frees.
> + */
> +void btrfs_free_extent_map_safe(struct extent_map_tree *tree,
> +				struct extent_map *em)

The "unsafe" btrfs_free_extent_map() still exists.  Assuming both
variants will continue to be needed, shouldn't the comment above the
"unsafe" variant be updated to document the preconditions for using it?

> diff --git a/fs/btrfs/extent_map.h b/fs/btrfs/extent_map.h
> index 6f685f3c9327..a962012be1c3 100644
> --- a/fs/btrfs/extent_map.h
> +++ b/fs/btrfs/extent_map.h
> @@ -97,11 +97,18 @@ struct extent_map {
>  	u32 flags;
>  	refcount_t refs;
>  	struct list_head list;
> +	struct list_head free_list;
> +};

The comment above this struct says "Keep this structure as compact as
possible, as we can have really large amounts of allocated extent maps
at any time."  Is there any way to avoid adding a whole list_head?

- Eric
