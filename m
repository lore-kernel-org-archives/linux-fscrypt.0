Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 890D73A48CE;
	Fri, 26 Jun 2026 05:26:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782451577; cv=none; b=KtsbN2hDVU3ayPQAE0eWmlYdGE+ne/A9595XTpuzc7nUXMTraH6pBswbrz5XW+o4cRJXGukpUG+2cCAxcE8G//3vDtUKvi2ca21W55CnYVvPmQ+RWQ7pNzmvpT1ajIu2zrSzvn8fPmhZpYLbFA3fu/Lut9WivKR3ptlyRjI4dQc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782451577; c=relaxed/simple;
	bh=YrSVqAg5us6uAGsW/AFD5fokE0Fkrz3QrveDNTRf9ww=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=j959eh6EuXXyhANq+lncWwLwl0Lrjk7w+lsrJ2na3cSJqUv4FFJ+eD6wREwROn+sRyjV8PtmR0VbtDYWtSsJIrUUI05UgN6bDkCyh7lC+IrB4kUljmsetW3x6GAyW88WBMCikCbDIgj4H0xdHpnlVh+dGuAXWOWAYe6lECUC1uM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 959AC68C4E; Fri, 26 Jun 2026 07:26:13 +0200 (CEST)
Date: Fri, 26 Jun 2026 07:26:13 +0200
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
Subject: Re: [PATCH 08/16] ext4: Further de-generalize the bio
 postprocessing code
Message-ID: <20260626052613.GH9043@lst.de>
References: <20260624050334.124606-1-ebiggers@kernel.org> <20260624050334.124606-9-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260624050334.124606-9-ebiggers@kernel.org>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Jun 23, 2026 at 10:03:26PM -0700, Eric Biggers wrote:
> +extern int __init ext4_init_verity_caches(void);
> +extern void ext4_exit_verity_caches(void);

Maybe drop these pointless externs while you're at it?

