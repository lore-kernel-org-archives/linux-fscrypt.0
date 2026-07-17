Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFE242165EA;
	Fri, 17 Jul 2026 16:10:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784304614; cv=none; b=pcDiPl6nddiB1tycQ0FVtQXZ+T5VnF0yVw69PdNosYwQ1aiH3gDA+bfqISKwKKDA2BabiLUV2l7LlwEvuVfQiSj6Z/mDawF+n3hOOPgK723tyS+o3Da8a/F6czGH64hhrRykI79wNClk+bdbx1v9hiKF/PbG0SYN2PrkPGD+aNs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784304614; c=relaxed/simple;
	bh=vq7SG+PrPQSq0mknfwuqqISPBJDjMYOuUhBn8XGP1ng=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=rUAlIZrnbfqI+R345mu2FIVBnxAUQm2kOEg9aSV/yqPyE4NkVdeDCCnfXglLUFWAgkM1n87ZCH7LNg6FWsLWdEFBmlDn7DVe4pfz9fLh4lMUCEHvSy/yOhN7v+C3VBL1/EHutV85KZWgHKIpPeVIkhx9r58v6PbAw/86Wj6COgM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Nks8VVps; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Nks8VVps"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7FD361F000E9;
	Fri, 17 Jul 2026 16:10:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784304613;
	bh=pIUW+eqslxS6fL0da7s3Tey79O3lS7y8FN9jNAzbHUI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Nks8VVps0U/b3zaewmXKNfqgQOMbquU7Es70xmRcf4GzWPzxGe1iL+bHpug9ag8ix
	 q+36dKdX5LFmaH1p6qvDLg2kYEM3yf7LtV5gapPaLs/YLAOQitXDGVs6HK9Bk3WBpg
	 GSBnHPzP1+V6ILFJmoFlQx3nUiocuphYiTrJoupT02pYvYmWLzjs2cPIOgFFtr6BYN
	 hAyJv3gVq0QBxFJukK7aV9wFLxDb9MLOEphgLzE4oASCSUPxNoDVcaiIIOWFlYh+hN
	 q4s8sPfDZAjR3XJfWCewHkbdoMfuBkfuYVg/qbPKI83XQDUcJshIuU8jpXDYoxMiqy
	 t16QO366QOEbQ==
Date: Fri, 17 Jul 2026 09:10:08 -0700
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
Message-ID: <20260717161008.GB2046@quark>
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
>   ext4: Remove fs-layer file contents en/decryption code
>   ext4: Make ext4_bio_write_folio() return void
>   ext4: Further de-generalize the bio postprocessing code
>   f2fs: Remove fs-layer file contents en/decryption code
>   fs/buffer: Remove fs-layer decryption code

Could we get acks from the ext4 and f2fs maintainers on these?

- Eric
