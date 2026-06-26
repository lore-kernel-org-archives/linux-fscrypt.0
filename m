Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0AB9D369D7A;
	Fri, 26 Jun 2026 05:24:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782451492; cv=none; b=j3XEMi/QLJqLCj6RwOpkI3mdUjabojuqXArgPTXDq5zCx7o18+SnMzjAYoOOrO58sYbB/ueNTgnS75KbDnKUf2wcKrFE7hq6eqiud2b+SqCl/jc9R8mZI90hgRXLKEaPXMsrzT8sK8IFCT2dz7iFgaFfdZiZNTFZ/2djoqrCdxU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782451492; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=qiEREu4EzaTwIsxhiBt9UNX8ccVG9JL5dpl8QWP07sbPvGwiH3ZUtcwIsniONywJNBRK+uw3X86ASm9HaJtLVJ9DyrUtsCmQByukNUBy6LeM0qQw4FCjS4/SY8ScLim764uFxRx6NLXgrCatEIe8ql4xnGg5NxwrFZJ8XpCUHSk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 50DFC68B05; Fri, 26 Jun 2026 07:24:47 +0200 (CEST)
Date: Fri, 26 Jun 2026 07:24:46 +0200
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
Subject: Re: [PATCH 06/16] ext4: Remove fs-layer file contents
 en/decryption code
Message-ID: <20260626052446.GF9043@lst.de>
References: <20260624050334.124606-1-ebiggers@kernel.org> <20260624050334.124606-7-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260624050334.124606-7-ebiggers@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

