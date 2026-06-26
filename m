Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 45F513BADBC;
	Fri, 26 Jun 2026 05:32:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782451940; cv=none; b=b97UBoupceP7QtCXodPr9idnvfBbz8MSNWoOpSzOfJ4XgsGkbLIvfwspp3RJrx9YVLmsvfgSjxR4NcC0mpuN3Xf5elPNCmo58thx8uo2nbDooosQ3QE4YAS1Yg+iduo+vn02BXPRc5G5R5kWh6euuF3VQZOFPzo6b5IO0k9Gnh4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782451940; c=relaxed/simple;
	bh=4N94msVNWEHGIz5I1uQvqKNgFIy00weUxclT0sezcoM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ufseoFhxY9hh4jtl4u28BQNNM27qANpmLP8YoNLGpx8MWY/KVWkVb53/koXeJOM9cnKFYlJCRSCGO9oqIORSrnU/mCNoWNkWkfyti4CfHGLURopzxIS2KmXsrZQ+kHJ+ZKvYumbIT/hEV3iv8tE5N2UPN2VLeEZEFTOtYw0SksA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 7065F68B05; Fri, 26 Jun 2026 07:32:08 +0200 (CEST)
Date: Fri, 26 Jun 2026 07:32:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-block@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>
Subject: Re: [PATCH 15/16] fscrypt: Merge bio.c and inline_crypt.c into
 block.c
Message-ID: <20260626053207.GN9043@lst.de>
References: <20260624050334.124606-1-ebiggers@kernel.org> <20260624050334.124606-16-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260624050334.124606-16-ebiggers@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Jun 23, 2026 at 10:03:33PM -0700, Eric Biggers wrote:
> Now that fscrypt always uses blk-crypto on block-based filesystems,
> there's no meaningful difference between bio.c and inline_crypt.c.
> Therefore merge the two files into one named block.c.
> 
> Note: I didn't carry over bio.c's "Copyright (C) 2015, Motorola
> Mobility", as none of the code that applied to remained.

Yeah the current from of the code is almost entirely mine,
with some slight traces of your earlier version.

> +struct fscrypt_zero_done {
> +	atomic_t		pending;
> +	blk_status_t		status;
> +	struct completion	done;
> +};
> +
> +static void fscrypt_zeroout_range_done(struct fscrypt_zero_done *done)
> +{
> +	if (atomic_dec_and_test(&done->pending))
> +		complete(&done->done);
> +}
> +
> +static void fscrypt_zeroout_range_end_io(struct bio *bio)
> +{
> +	struct fscrypt_zero_done *done = bio->bi_private;
> +
> +	if (bio->bi_status)
> +		cmpxchg(&done->status, 0, bio->bi_status);
> +	fscrypt_zeroout_range_done(done);
> +	bio_put(bio);
> +}
> +
> +/**
> + * fscrypt_zeroout_range() - zero out a range of blocks in an encrypted file
> + * @inode: the file's inode
> + * @pos: the first file position (in bytes) to zero out
> + * @sector: the first sector to zero out
> + * @len: bytes to zero out
> + *
> + * Zero out filesystem blocks in an encrypted regular file on-disk, i.e. write
> + * ciphertext blocks which decrypt to the all-zeroes block.  The blocks must be
> + * both logically and physically contiguous.  It's also assumed that the
> + * filesystem only uses a single block device, ->s_bdev.  @len must be a
> + * multiple of the file system logical block size.
> + *
> + * Note that since each block uses a different IV, this involves writing a
> + * different ciphertext to each block; we can't simply reuse the same one.
> + *
> + * Return: 0 on success; -errno on failure.
> + */
> +int fscrypt_zeroout_range(const struct inode *inode, loff_t pos,
> +			  sector_t sector, u64 len)

.. but I wonder if we should rename this and move it to libfs, as it
works just fine without encyption and file systems could call it
for the non-fscrypt case and consolidate on a single implementation.

But maybe some other time, no need to complicate this series.

Reviewed-by: Christoph Hellwig <hch@lst.de>

