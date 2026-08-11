Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F487368D79;
	Tue, 11 Aug 2026 18:04:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786471457; cv=none; b=hjCdSFNra7hPS76/NEq94lfBvqb1XjGAhkebibqvvyw2GvfDry099JEqjlHe47fOM8jEZ3jDY+3RrR3wwzwxQvRBBafXV1XgOxenkyEaS13CSWMj3KXbK+j3EUnOjnE1b5DuOf44NfwpetwXxsAIc3+HfWp5k1Lx8iRMXcEFDHc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786471457; c=relaxed/simple;
	bh=9MqyFy5qbyTdmXiJHR4voj/pzytxkv9gPneieS532Uw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=VOt5MP71aCl9yTAZdckK7hYbadpSh+ZFTG6ODeh6b7VoWGN5Iv+QEYDLy2odnHB/eKTR6sReUHi0E1IDhCl2D5eZS94zm2HnvMzssQhJmQtUJTUJ9YiWj464eJ1rYu88dZhl6EmaRpbiapPtQ/ehDSo9q5KzcROgEVO+6n5qF8o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ews4KBL/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ews4KBL/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4E8D91F000E9;
	Tue, 11 Aug 2026 18:04:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786471455;
	bh=CCXYUWfaQmVmTc4INn+t522+Y+UjSzJVsGmbRsWsMQE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ews4KBL/NG6I/XZFa+YJuqD0O1o5vmAY20ZvXzDnNOIRkvLOHdWW4RNZc51t+Ew1d
	 RAI4431LXFOyhWiGc9gTmgjV5F+1JxZzlLCM7ZmWLFpvdOwXjDft01aP917AGnLtf9
	 0hGeyCo+1YzXtKJxC9fibxEcbKCk2Cy1zou8j3tjRgn2/QWWSGjbBOY0z4uDEyEGug
	 cWzq/Ow2uPzS0phA4ToFbCBqmvQnTlaLiCepreHEDediHD4GAHe1WBNwU5XQm0kn3y
	 sDBCoTBR9c3HZUeipE9maCyUrtqL4YgTD4tkiW5LucjIAR0fD1CnlkArUrshUpA4a5
	 kvKQx1kvqItfA==
Date: Tue, 11 Aug 2026 18:04:13 +0000
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
Subject: Re: [PATCH v3 00/17] fscrypt: Standardize on blk-crypto
Message-ID: <20260811180413.GA2895176@google.com>
References: <20260713023708.9245-1-ebiggers@kernel.org>
 <20260720174323.GA1865@quark>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260720174323.GA1865@quark>

On Mon, Jul 20, 2026 at 10:43:23AM -0700, Eric Biggers wrote:
> On Sun, Jul 12, 2026 at 10:36:51PM -0400, Eric Biggers wrote:
> > Eric Biggers (17):
> >   blk-crypto: Simplify check for fallback support
> >   blk-crypto: Fold __blk_crypto_cfg_supported() into its caller
> >   blk-crypto: Allow control over whether hardware is used
> >   fscrypt: Fully disallow IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE
> >   fscrypt: Always use blk-crypto for contents on block-based filesystems
> >   Documentation: fscrypt: Update docs for inlinecrypt
> >   ext4: Remove fs-layer file contents en/decryption code
> >   ext4: Make ext4_bio_write_folio() return void
> >   ext4: Further de-generalize the bio postprocessing code
> >   f2fs: Remove fs-layer file contents en/decryption code
> >   fs/buffer: Remove fs-layer decryption code
> >   fscrypt: Replace calls to fscrypt_inode_uses_inline_crypto()
> >   fscrypt: Remove fscrypt_dio_supported()
> >   fscrypt: Remove fs-layer zeroout code
> >   fscrypt: Remove unused functions and workqueue
> >   fscrypt: Merge bio.c and inline_crypt.c into block.c
> >   fscrypt: Add safety checks to non-block-based en/decryption
> 
> Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next
> 
> But I'd still like acks on the ext4 and f2fs patches.

Ted and Jaegeuk, any chance for Acks on the ext4 and f2fs patches?

- Eric
