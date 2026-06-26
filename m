Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E54813A75BB;
	Fri, 26 Jun 2026 05:18:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782451104; cv=none; b=kFdwtwqJNiqGUlMZgl9EvpZyrxP9QWCDPV2XY14UZFj0AYgKz7huVEl8V5yPS/Gb2Q+RfP4hoRFGeHNeAMwg98ngTknJeokwXIfs04nMSNshhsu+SxGEMkwzdAnRB4lSfq68FOiCQC3SnGuVwqDIIrg14qC6fcrl/xQcwd0OCYE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782451104; c=relaxed/simple;
	bh=VYP7aoAgLFOaBFGSh4aq85fiV4qvPFcwXlqIOQpgMEY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=QYgPGbG2F4KZmpIe9QQCIbCq6xpWTGZqA+M15XvA6reqIq7v2ChDnwX95whK57Uo5gf+ysVItSBjM+G2PfaPvQObaUneRRgN7pmRYMJx6p7facQ1zFbzaznSJ0DqBobe020qFXqQzUDcAw/qBFf+Pp4jqTwsvYxYf7EjJSAvUeI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 4FA5C68C4E; Fri, 26 Jun 2026 07:18:20 +0200 (CEST)
Date: Fri, 26 Jun 2026 07:18:19 +0200
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
Subject: Re: [PATCH 03/16] blk-crypto: Allow control over whether hardware
 is used
Message-ID: <20260626051819.GC9043@lst.de>
References: <20260624050334.124606-1-ebiggers@kernel.org> <20260624050334.124606-4-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260624050334.124606-4-ebiggers@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Jun 23, 2026 at 10:03:21PM -0700, Eric Biggers wrote:
> fscrypt uses inline encryption hardware only when the "inlinecrypt"
> mount option is given.  I'd like to keep that behavior even after
> standardizing on the blk-crypto API for file contents encryption.  That
> is, the default should continue to be the well-tested CPU-based
> encryption code, and the use of inline encryption hardware should
> continue to be an opt-in feature for systems where it's beneficial and
> has been fully validated (including verifying ciphertext correctness).
> 
> To support this use case, add an allow_hw field to struct
> blk_crypto_config.
> 
> For now it's always set to true.  Later commits will change that.

Maybe a flags argument with a descriptive flag name would be better
than a bool for a public API like this?

Otherwise looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

