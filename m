Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 24FF8349AEA;
	Mon,  9 Mar 2026 20:43:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773088992; cv=none; b=fv/1ViK7NNx4olOiFD8j2K8sDch65FGmGz6SkVAJsrz4fDpfybqonE//jyXFZ+pCL5lhn70CHUBn/AukGlaaniTulvbMyxEkRl/g+nFifRlnBFFwuI5SH9SSFEj+kItENVw2P88XcIB0mfKpuhPZevW4x07NMiJzwzhS1X5VwZI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773088992; c=relaxed/simple;
	bh=LgbkmLMqtuYdFY11z23RJwEuy3ulRqnM9TgZfuz+WJI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=rUD8zGPwRuBf1OC/g05J6H5XwWa22i+4FfFcyS+rNuXPinWqBzfyaMO7M4ZPBSavIdFb/Sb+KtOBHTO4ZaATgHnyE4gGsWUnb1CKb6T5N94vRbZv0FpubrNdoOJqBR9rrLY7Je8DrvS5Mmd/A0jCNXXIw7Vtf2jaVK6iPRoa40o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=pECjVXrp; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="pECjVXrp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 27EB9C2BC87;
	Mon,  9 Mar 2026 20:43:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773088991;
	bh=LgbkmLMqtuYdFY11z23RJwEuy3ulRqnM9TgZfuz+WJI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=pECjVXrpy9OUbNbNVsH0KaVo3LTgKu7FDofzwVvojZhIC+oT6MSC7DHR8ef/by7ob
	 6itzmOmMCDtY972OYbTjZloNCOdo12p/r7AZtpteRKJldBv5Y+dkbk0XAiZSauZaWk
	 Ry2KCfqFQjZQLW4k7GutSWPCjM9o/zS1hAdjswBVo+dSe9ObPKKDYWs1y1+2WcrNOk
	 1f0DEmAI22rCPgKEbpxbYJWLJWj/5Ivx/yvvdTN+kraZXbARq5F3NAo1aTaKxeBiux
	 X4cY4t6ohPYFgAmqCeHJEO1LYVn9h3S5DBWKYllkI67xDjgNSpHQLz/IaIjfboBojx
	 izjvSIggQsg4Q==
Date: Mon, 9 Mar 2026 13:43:09 -0700
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
Message-ID: <20260309204309.GB2048@quark>
References: <20260302141922.370070-1-hch@lst.de>
 <20260303223507.GA56397@quark>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260303223507.GA56397@quark>

On Tue, Mar 03, 2026 at 02:35:07PM -0800, Eric Biggers wrote:
> On Mon, Mar 02, 2026 at 06:18:05AM -0800, Christoph Hellwig wrote:
> > Hi all,
> > 
> > this series cleans up various fscrypt APIs to pass logical offsets in
> > and lengths in bytes, and on-disk sectors as 512-byte sector units,
> > like most of the VFS and block code.
> > 
> > Changes since v2:
> >  - use the local bio variable in io_submit_init_bio
> >  - use folio instead of io_folio (and actually test the noinline mode,
> >    which should have cought this for the last round)
> >  - add an extra IS_ENABLED(CONFIG_FS_ENCRYPTION) to safeguard
> >    against potentially stupid compilers
> >  - document the byte length needs to be a multiple of the block
> >    size
> >  - case to u64 when passing the byte length
> >  - move a hunk to an earlier patch
> > Changes since v1:
> >  - remove all buffer_head helpers, and do that before the API cleanups
> >    to simplify the series
> >  - fix a bisection hazard
> >  - spelling fixes in the commit logs
> >  - use "file position" to describe the byte offset into an inode
> >  - add another small ext4 cleanup at the end
> 
> This looks good now.  I'll plan to apply this to fscrypt.git#for-next in
> a bit.  Other reviews and acks appreciated.

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
