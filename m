Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA360360ECD;
	Sun,  5 Jul 2026 20:27:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783283250; cv=none; b=PqLfQm5Gp1UIgmioahsZGRqQ3wzzFemQYEZQ3ySLKCzEYs3YDZOcnQEQ2S1rxUYIicuhrf27qTTWIgKaMIiMn2HCn+CFa6lckEqunwqMTZT602mc8hONU1YkepssU71UalZLzgwnBlz4Z49otRpeKJa+ylKD9n1mCpmKLwDWus4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783283250; c=relaxed/simple;
	bh=AjxYSwb2WqgdMSAz7BWGA1/J/Zc1qyh5EKzw7fDuMCc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=YLV70AKLAmROEfJR8fjoGxt6e3hbd8kKQfBWJuh7j4oOWRGzcU/xqOkelYAR9Ebv52mGlowv2Tq5ixStjRhLx89J6pdLHJzz/T6g/gpDkbeEz75EbziN7hElekYqXaBiPkn+lBvZ3FlMjONdswA5yIOnDxS5khSMFKkjAbFeoEE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ONkvNfO7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ONkvNfO7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EBB921F000E9;
	Sun,  5 Jul 2026 20:27:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783283249;
	bh=aJn2MZML+MCpXCm1e6eEUa6PDLxWsVXQhSkdQWF+JNA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ONkvNfO7vIPU2gSxzCAj2/U9qxr7COrOU3XVQNuoO3cyO4Gb2EB2KBrhR/KthBiDL
	 lIxVNbcyenO7dxge1RD+HatAJg84Rq3H+it1iXBGk1WTDVNIXVr3CC+TIhHlmrrHrV
	 mnP89jhTtAH09EIjmBbOUynb+MhUtYRbyVhkrrOzOHX/zNC8VeVVjPjDF7SdCcu17/
	 rAowTxvRBxDL9piPQHKRlG9+iuM2LAtakBYEiQ7CdfzyZLLC4hHX3U0hSLAK4GiEow
	 MEBZ7LheP/9kIL0fq3lroWPvTxZDICd0FUWpupJsIMcgBEu3U54C3066mKVgf97Q6O
	 P3I8XwjHeCHkg==
Date: Sun, 5 Jul 2026 13:27:27 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net, linux-block@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>, Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>
Subject: Re: [PATCH v2 08/17] ext4: Make ext4_bio_write_folio() return void
Message-ID: <20260705202727.GJ41916@quark>
References: <20260705194555.75030-1-ebiggers@kernel.org>
 <20260705194555.75030-9-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260705194555.75030-9-ebiggers@kernel.org>

On Sun, Jul 05, 2026 at 12:45:45PM -0700, Eric Biggers wrote:
> @@ -2724,9 +2711,7 @@ static int mpage_prepare_extent_to_map(struct mpage_da_data *mpd)
>  			 * through a pin.
>  			 */
>  			if (!mpd->can_map) {
> -				err = mpage_submit_folio(mpd, folio);
> -				if (err < 0)
> -					goto out;
> +				mpage_submit_folio(mpd, folio);
>  				/* Pending dirtying of journalled data? */
>  				if (folio_test_checked(folio)) {
>  					err = mpage_journal_page_buffers(handle,

Sashiko found a subtle bug here, where removing this assignment to 'err'
can leak a positive 'err' value of 1 from ext4_journal_ensure_credits()
into the caller of mpage_prepare_extent_to_map() in certain cases.

I'll fix that by leaving an assignment of 0 to 'err' here.

Really, positive values shouldn't be stored in a variable named 'err' in
the first place though.

- Eric
