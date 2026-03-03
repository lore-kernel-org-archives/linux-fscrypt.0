Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 763D02EE611;
	Tue,  3 Mar 2026 22:35:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772577310; cv=none; b=KdQxFW9oxR42odVYyENQSlVnsTo7cTOvQ0I11qLk1R2WmA/TRtjlY2rT4N+I1Hfjg22aXkOsTHHCtGo2bzMGLxQaRKEWIDT7Vrbm8XE4ZgxOiwf3sFU5Jx/iVBdMgqwCSCHg9oLxNBR0pEc6pYaWOmGZEMh0H2FZv4FSkhaobEc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772577310; c=relaxed/simple;
	bh=hLW2gogLkMlcBSOVfuRQe+4qJ4OCx+t0Wq24NyTkByk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=B1AMqmdKfIwo5Wk28MS/6wxIQ/Zu+bk2RRJ7LHeVPU9L2UZwy/5frYS8Mqn60CLuGz+BkVJAXJCRXKmWdmsPkN2qb0dRc0dhWKNzuVz3XH209wxB3crQwd2gLfMZSnY/V3P36RyMGHb6eC1ed/qWR6XGF696AKesZTf4C6Kyjlg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fAUR2HdN; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fAUR2HdN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ADC8BC116C6;
	Tue,  3 Mar 2026 22:35:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772577310;
	bh=hLW2gogLkMlcBSOVfuRQe+4qJ4OCx+t0Wq24NyTkByk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=fAUR2HdNV2dYGUW1Gp2H6pGWUeqFYY3HraLaasw6Ye5WeMS7pBk7RiASmFOVI+kYo
	 LQ146BxJ57YBeCfZnPIq4HjCq/pLTAc+LsVeQneCmVcKzn1wNxkyArwOF4/8g1zWsN
	 MGcDEDIxWOJB3sbw5hJld1pIeDsdTH+Gja44neawvGUsHTdat0f1k3G8KQ5AeFcw0m
	 MGiZQb7RBm8GvrhX5HTW7onWMmYmLy7ZKK30ycsd3jfLNN4tS8BmkCG3Exf3VvZewo
	 dKn+DJXgfIqrK/VFFAGMvf5JI3rsGjE6kB8AjEatFX7qlIl34T3HH4nSZIKHMKs88l
	 dyhe1JTbMJy/Q==
Date: Tue, 3 Mar 2026 14:35:07 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Chao Yu <chao@kernel.org>, Christian Brauner <brauner@kernel.org>,
	"Darrick J. Wong" <djwong@kernel.org>,
	linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Subject: Re: fscrypt API cleanups v3
Message-ID: <20260303223507.GA56397@quark>
References: <20260302141922.370070-1-hch@lst.de>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260302141922.370070-1-hch@lst.de>

On Mon, Mar 02, 2026 at 06:18:05AM -0800, Christoph Hellwig wrote:
> Hi all,
> 
> this series cleans up various fscrypt APIs to pass logical offsets in
> and lengths in bytes, and on-disk sectors as 512-byte sector units,
> like most of the VFS and block code.
> 
> Changes since v2:
>  - use the local bio variable in io_submit_init_bio
>  - use folio instead of io_folio (and actually test the noinline mode,
>    which should have cought this for the last round)
>  - add an extra IS_ENABLED(CONFIG_FS_ENCRYPTION) to safeguard
>    against potentially stupid compilers
>  - document the byte length needs to be a multiple of the block
>    size
>  - case to u64 when passing the byte length
>  - move a hunk to an earlier patch
> Changes since v1:
>  - remove all buffer_head helpers, and do that before the API cleanups
>    to simplify the series
>  - fix a bisection hazard
>  - spelling fixes in the commit logs
>  - use "file position" to describe the byte offset into an inode
>  - add another small ext4 cleanup at the end

This looks good now.  I'll plan to apply this to fscrypt.git#for-next in
a bit.  Other reviews and acks appreciated.

- Eric
