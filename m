Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97CCA44B695;
	Mon, 20 Jul 2026 17:43:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784569409; cv=none; b=bVwiqRWAZssZi583c2MHnmKgwj3MmJkbqkMakG2+Dh+mXW99BAbHeisf191Z4Oe2oSmbWtzvXdF9mBYWa5o5/FBlHAVMfvKxlByE98tyWSuA5F7yLONhzZFOcDv11sgMhRfGNpPJIdoTfH33SPdD1YWuS/MmCMhxarU3XfFwh0s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784569409; c=relaxed/simple;
	bh=sydWdxs/mROWwyi7g9Y+3bygDeCAVu4xoDgdwu5KuQk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=JaY82KG5baPsqXRA+Jab2h0Mu8uvA7ljc6VmDQRAq8JD41oKrv6JE33i9RtpfUWRNedP596AS9mx30vzz8EntzmqiCgtgMtW/MV4aPmUPQVQuUWxgpi5PQa3T0d3xIPlWJ0geEmOHMFusKjQQpInIAIS6R9zfcZEjgktZ8zL0TM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VKsLGqjr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VKsLGqjr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 72D3F1F00A3E;
	Mon, 20 Jul 2026 17:43:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784569404;
	bh=gv/bAqWCLcsD/jMzuWjvkLnXVdOL0UvRkm+6ngUws4U=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=VKsLGqjr93FnM1O6Fx0Z1vNlnHsdf/BfXYf+9rGNcR5ZbyRgcmSNVyAwO3X7GJovI
	 wqra/SVk6au46c0KCIThp5QagmDh/pXxReXmqtaJvsMQmkYOfjRKRxDiwkElGlhqeV
	 yNiJ4xFw7ZFjc3e/9a8a10bfPLlMJ8h/bOMZIRomhczYQsidbevD/b22uHAISk9l2I
	 bi+ILf4TmAL+pAxn4x2FIck3Ln0YCN4nl0sMuo/86RQDAXyyLw9GjDUfsI1kjJ+wkL
	 zKfJGy/BXy5Ha9dZxy6VOmjzTEgDjF+558yT6skJzNrRM4Wxhft0ZjeWe5bpFI+2ms
	 00v5eDbnj+gnA==
Date: Mon, 20 Jul 2026 10:43:23 -0700
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
Message-ID: <20260720174323.GA1865@quark>
References: <20260713023708.9245-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260713023708.9245-1-ebiggers@kernel.org>

On Sun, Jul 12, 2026 at 10:36:51PM -0400, Eric Biggers wrote:
> Eric Biggers (17):
>   blk-crypto: Simplify check for fallback support
>   blk-crypto: Fold __blk_crypto_cfg_supported() into its caller
>   blk-crypto: Allow control over whether hardware is used
>   fscrypt: Fully disallow IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE
>   fscrypt: Always use blk-crypto for contents on block-based filesystems
>   Documentation: fscrypt: Update docs for inlinecrypt
>   ext4: Remove fs-layer file contents en/decryption code
>   ext4: Make ext4_bio_write_folio() return void
>   ext4: Further de-generalize the bio postprocessing code
>   f2fs: Remove fs-layer file contents en/decryption code
>   fs/buffer: Remove fs-layer decryption code
>   fscrypt: Replace calls to fscrypt_inode_uses_inline_crypto()
>   fscrypt: Remove fscrypt_dio_supported()
>   fscrypt: Remove fs-layer zeroout code
>   fscrypt: Remove unused functions and workqueue
>   fscrypt: Merge bio.c and inline_crypt.c into block.c
>   fscrypt: Add safety checks to non-block-based en/decryption

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

But I'd still like acks on the ext4 and f2fs patches.

- Eric
