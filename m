Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D0DAE361651;
	Fri, 26 Jun 2026 05:18:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782451136; cv=none; b=bCKClA0kQRDxIZN9vWYAkaaQOYcRNmuwi4cINwkYTHCOj4X9MIIC0htKrOpA9dnOzqmzEVFxn+PuMJuSGEWd/OTewLffrx+335c2czX8tboUqhzPNO+n0hjqccyTVv0eCZUCITnw6HLMwCkdJ6hhAFqkMthzenakEm+Ks5E30bs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782451136; c=relaxed/simple;
	bh=3MCOf5J1+KkzJDeyAfkH9vbkQSmdN5CitzbYQ7ScBA0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=B1/pY6l+kJyArsYdfwpl/xlsazHfdohUGbr/1oD4St32UCKsfuG56lRCj8oPrxW53MnQbP7ZzQSnDd2idnrdVAZsfS9ZGkz2uB4RIZaUI+dLy6f9HD2zn6W4G88398hN6oq5TueEir9KzI+b5gFF2+Cs4WlTKM5FL0F2HybMmaI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 3B55268B05; Fri, 26 Jun 2026 07:18:52 +0200 (CEST)
Date: Fri, 26 Jun 2026 07:18:51 +0200
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
Subject: Re: [PATCH 04/16] fscrypt: Fully disallow IV_INO_LBLK_32 with
 s_blocksize != PAGE_SIZE
Message-ID: <20260626051851.GD9043@lst.de>
References: <20260624050334.124606-1-ebiggers@kernel.org> <20260624050334.124606-5-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260624050334.124606-5-ebiggers@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Jun 23, 2026 at 10:03:22PM -0700, Eric Biggers wrote:
> FSCRYPT_POLICY_FLAG_IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE works
> only with the fs-layer implementation of file contents encryption, not
> blk-crypto.  This is a problem for standardizing on blk-crypto.
> 
> Fortunately, no one should be using this combination anyway.  It doesn't
> make sense because the entire point of IV_INO_LBLK_32 is to support
> inline encryption hardware that is limited to 32-bit DUNs.
> 
> Thus, fully disallow IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE.

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

