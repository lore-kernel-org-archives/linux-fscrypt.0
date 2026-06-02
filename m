Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E07D027F19F;
	Tue,  2 Jun 2026 03:14:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780370056; cv=none; b=gbawptisuuha0rFQxEjf/IpO0bRSb5eh5WK9FG/zDlnsR3TxneyWb0vyswfz4IQVjkcj8fE3KTlhwy8iip/GRcfjPqWBwwENWP3NeeEG4MvGr1x2UMGr6x6tyVPbwhzk5ZUT8ZmFbofGAs7VoPL0fS6GVOhvsuh50lKHVWdn+po=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780370056; c=relaxed/simple;
	bh=XcuyzpMeexEc4ntKhWKvLmZX5C6PsWn2FLGhM/EaxUg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=EirG8T/N/DOdAZSWcW37rjayWvYE41vYnCfcttn2AlEHHvdQ/D9HhLQ25luHlDYDIuvSnbylqU2dQtl/rMlzXwMMkyi+mSaSLwUZ+af/Bl4NaIq22PCnf6mcjZao+gSkQhmUYnx6mhnzTVJUYJXP5y9DKGwKTJx9/Ys5hZ3CixY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VDON9IYZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VDON9IYZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6DB591F00893;
	Tue,  2 Jun 2026 03:14:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780370055;
	bh=0GmIBwr2K9ISMsr5/bEd8rwWJ/NyaURH6TbEH9AUztU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=VDON9IYZe/F0MBtlfVuhPmMoXI9/A8xu/PvpOuYpULWPGXlVILuG5VFbFJQ6DoQ2T
	 u8GJ3vgn+AfA0yGElhBa9T2fq9xPcKVCNTPfHbsq8Io3/8cCi5/M3RhIicHB+aNSrD
	 Qr5v0OmRUPkCRqBRINxoAs9EBolPIBBbAbc3smJuUTIJbAuLc88aIAPjurEy9LcaDp
	 wXPBjnisCsTTuB/NoXYFM1ZcCjejSoMQ70OFRsGfudo1p6Yv+3HKsubWj4AcKiYW+Q
	 OHESUoB/Teo4vXjBnSiS5XuMwXaVq06me3kUGPsv5k3VP4GUYl7PoINVUCIftj7lsT
	 EKeNOQe3KGrow==
Date: Mon, 1 Jun 2026 20:12:51 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Daniel Vacek <neelx@suse.com>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>,
	David Sterba <dsterba@suse.com>, linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Omar Sandoval <osandov@osandov.com>,
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Subject: Re: [PATCH v7 10/43] btrfs: start using fscrypt hooks
Message-ID: <20260602031251.GG2295@sol>
References: <20260513085340.3673127-1-neelx@suse.com>
 <20260513085340.3673127-11-neelx@suse.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260513085340.3673127-11-neelx@suse.com>

On Wed, May 13, 2026 at 10:52:44AM +0200, Daniel Vacek wrote:
> @@ -9041,20 +9063,28 @@ static int btrfs_symlink(struct mnt_idmap *idmap, struct inode *dir,
>  	};
>  	unsigned int trans_num_items;
>  	int ret;
> -	int name_len;
>  	int datasize;
>  	unsigned long ptr;
>  	struct btrfs_file_extent_item *ei;
>  	struct extent_buffer *leaf;
> +	struct fscrypt_str disk_link;
> +	size_t max_len;
> +	u32 name_len = strlen(symname);
> +
> +	/*
> +	 * BTRFS_MAX_INLINE_DATA_SIZE() isn't actually telling the truth, we actually
> +	 * limit inline data extents to min(BTRFS_MAX_INLINE_DATA_SIZE(), sectorsize),
> +	 * so adjust max_len given this wonderful bit of inconsistency.
> +	 */
> +	max_len = min_t(size_t, BTRFS_MAX_INLINE_DATA_SIZE(fs_info), fs_info->sectorsize);
>  
> -	name_len = strlen(symname);
>  	/*
> -	 * Symlinks utilize uncompressed inline extent data, which should not
> -	 * reach block size.
> +	 * fscrypt sets disk_link.len to be len + 1, including a NUL terminator,
> +	 * but we don't store that '\0' character.
>  	 */
> -	if (name_len > BTRFS_MAX_INLINE_DATA_SIZE(fs_info) ||
> -	    name_len >= fs_info->sectorsize)
> -		return -ENAMETOOLONG;
> +	ret = fscrypt_prepare_symlink(dir, symname, name_len, max_len + 1, &disk_link);
> +	if (ret)
> +		return ret;

This is off by one from the other filesystems.  Yes, the way the other
filesystems do encrypted symlinks is weird, but this still doesn't fix
it, since the unnecessary 'struct fscrypt_symlink_data' is still stored.
If it's not being fixed completely, it should just be done the same way.

Did you do it this way because you're trying to squeeze out an extra
byte, to allow 4094-byte symlink targets instead of 4093 as the other
filesystems do?  Or did you do it this way because btrfs doesn't count a
nul terminator when checking unencrypted symlinks against
BTRFS_MAX_INLINE_DATA_SIZE(fs_info), and you needed to preserve that
behavior?  But at the same time, btrfs *does* count the nul terminator
when validating against 'fs_info->sectorsize', and this changes that
behavior.  So it's not clear what was intended here.

> +	if (IS_ENCRYPTED(inode)) {
> +		ret = fscrypt_encrypt_symlink(inode, symname, name_len, &disk_link);
> +		if (ret) {
> +			btrfs_abort_transaction(trans, ret);
> +			btrfs_free_path(path);
> +			discard_new_inode(inode);
> +			inode = NULL;
> +			goto out;
> +		}
> +	}

fscrypt_encrypt_symlink() already has an IS_ENCRYPTED(inode) check
built-in.

> +static const char *btrfs_get_link(struct dentry *dentry, struct inode *inode,
> +				  struct delayed_call *done)
> +{
> +	struct page *cpage;
> +	const char *paddr;
> +	struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
> +
> +	if (!IS_ENCRYPTED(inode))
> +		return page_get_link(dentry, inode, done);
> +
> +	if (!dentry)
> +		return ERR_PTR(-ECHILD);
> +
> +	cpage = read_mapping_page(inode->i_mapping, 0, NULL);
> +	if (IS_ERR(cpage))
> +		return ERR_CAST(cpage);
> +
> +	paddr = fscrypt_get_symlink(inode, page_address(cpage),
> +				    BTRFS_MAX_INLINE_DATA_SIZE(fs_info), done);
> +	put_page(cpage);

This uses a different max_len from btrfs_symlink().

Speaking of symlinks, btrfs is also missing a hookup to
fscrypt_symlink_getattr().

- Eric
