Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 536EE3BC669;
	Fri, 26 Jun 2026 05:33:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782451999; cv=none; b=qXjBFe9TfrkEPhrxInVH5c2faZiwgC7kI3a9MR1wRI/GS3L/2YEAxD5SN5EFgUGWf7BU2iT83AWwaQmpnXgOcjaAUpzS28cZuMOYlwuyFmHFOL409O8SbCuGA3xD0+/jv/UKa+bCo/+RCbrL1lO+f7MX9aorfwwNzvki1q5qZwo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782451999; c=relaxed/simple;
	bh=lxtrRo+jigevR0QJcO58kA51VyPHqNiIDGDN+D9NtO0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=bocICj1x/yDMkYE8nu6Mhb4XgABh6FzbquLjlx3ktMz8KGPEXRZSxjl1AGy97fNKSrL3E74kW199zFJdLz4mn2Gj9D/2owmQ5guMtaDLTyGWDHnu8904k4uG42so/MWEdO+/KoVB+QUYw7r1hpW9kgtqsZN1TUR+7IgRgXztakI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id ED7B468B05; Fri, 26 Jun 2026 07:33:07 +0200 (CEST)
Date: Fri, 26 Jun 2026 07:33:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-block@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>, Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>, Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>
Subject: Re: [PATCH 16/16] fscrypt: Add safety checks to non-block-based
 en/decryption
Message-ID: <20260626053307.GO9043@lst.de>
References: <20260624050334.124606-1-ebiggers@kernel.org> <20260624050334.124606-17-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260624050334.124606-17-ebiggers@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Jun 23, 2026 at 10:03:34PM -0700, Eric Biggers wrote:
> fscrypt_encrypt_pagecache_blocks(), fscrypt_encrypt_block_inplace(),
> fscrypt_decrypt_block_inplace() would dereference a NULL
> fscrypt_inode_info pointer if they were to be called on a file that
> hasn't been opened yet or on a block-based filesystem.  Since they have
> the ability to report errors anyway, add WARN_ON_ONCE checks for this.


Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>
