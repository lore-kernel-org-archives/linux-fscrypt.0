Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40DFF1714AA;
	Fri, 26 Jun 2026 05:17:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782451035; cv=none; b=e1o4vZm/XGltbcGkTco0HG+HT18GnCjrRM42rpWXJ6/7XUSJKgV1MRVceTtkZyr7X5QyblXG3DtRGvpqUGFkpWMoL0UAhPlXowSM4N0SMIPTtPiXZqXr5boGoIOl4a2s/hIfugK+OqRxviD+Xb3XxH0pD2AeC3KTzmfU6sZysb4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782451035; c=relaxed/simple;
	bh=jLmt3+eE4jJPzSJIb5TXjXC8/57s9fXSmW2h/HafM8s=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ZXvTlMVo87L9gU68ykcsAnt+4f7y0F4b0icml3LHu0f+kNSelwQy05MWbRHYRPbh51GQb6g/vfFx5O2kXTaUuCQGKq9IGd3xMTo5moOhb72urb0IdIrTLUyc7Vs8ynk7Y8+w53nMe5krr1kRQP046WDNp5q3sDw/66yVdL/ixng=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 6C60368C4E; Fri, 26 Jun 2026 07:17:08 +0200 (CEST)
Date: Fri, 26 Jun 2026 07:17:07 +0200
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
Subject: Re: [PATCH 01/16] blk-crypto: Simplify check for fallback support
Message-ID: <20260626051707.GA9043@lst.de>
References: <20260624050334.124606-1-ebiggers@kernel.org> <20260624050334.124606-2-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260624050334.124606-2-ebiggers@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Jun 23, 2026 at 10:03:19PM -0700, Eric Biggers wrote:
> Since blk-crypto-fallback supports all blk_crypto_keys except wrapped
> keys, just check for that condition directly instead of using
> __blk_crypto_cfg_supported().  With this done,
> __blk_crypto_cfg_supported() is now used only for the hardware support.

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

