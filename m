Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B1E839768F;
	Fri, 26 Jun 2026 05:27:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782451651; cv=none; b=IItKstw0atlLpsz6Vmew6ei5VqehPIUe92EE1I1hqGCTH+M+Gos32AFTsPizr7vP4YZW8cN20oVS6Mo3dqknJ3H39SkS+fhfPV9l297UFmTisaokGGtTYNrtmC9SZ67H/X2VSVrwUJ/R6v1bU9WfGHSfitRsSCJl/1EHcVWbu3U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782451651; c=relaxed/simple;
	bh=M7NmYC/Iylm9myghHwqILim55SAUt9QrM+UZYk0eJlw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=VFqP1NixT1jX1P/7r46PXOSR3tMdGiiyX6N7mMey+CadMV89CH6Rau5YUVUU/+hMCw1j566DtoNROxH1b9Gx5yWuLOj4FEPHZiaUgsIMpg3I9jx+r45AQ6Fo5GyBnS6QWe5TYUArxhUaKfr4M1ju+B+nuKNMdaHBT0EkdcsaxFI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id B25A768B05; Fri, 26 Jun 2026 07:27:21 +0200 (CEST)
Date: Fri, 26 Jun 2026 07:27:21 +0200
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
Subject: Re: [PATCH 11/16] fscrypt: Replace calls to
 fscrypt_inode_uses_inline_crypto()
Message-ID: <20260626052721.GJ9043@lst.de>
References: <20260624050334.124606-1-ebiggers@kernel.org> <20260624050334.124606-12-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260624050334.124606-12-ebiggers@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

