Received: from out-174.mta0.migadu.com (out-174.mta0.migadu.com [91.218.175.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D5CF3890F1
	for <linux-fscrypt@vger.kernel.org>; Sat,  1 Aug 2026 00:47:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785545230; cv=none; b=MlCFkNhkMOTYcJ89xnKz70zcf7ZXhQl3VZVds/o3uZOwlR95FXIXwZyeN6CgizjRxR8K1TlOo1kLF5UELcAk+2UrKuRgPgFnlCw/IOpV3TGAkwx1mg4eEv64CDohS90hOJ+xrui9OJbtnrGEp6W+vHAQWMs13hAMlpXffKS0aaw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785545230; c=relaxed/simple;
	bh=aJGluKLug7fUNd7JeyfrJc4LQxPaXirsOBspg/4La3c=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=sV2LyK08uBj7pZgpxA1Tsz6i0Uzv5rbS46VxnVoGBlpxk59du+FUU/Mmw5KjLl6V9YbDoyPC0YwET3Io9pHWVZpWpd+GqcLmFxD4hqvOMWQqvKI/DFyxgRCP9uvhy1f0HgzbvyAMuRj6OrnWW/nX8nDPQeqLyoDHIycPm3xqhOY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=Lp/5WC0u; arc=none smtp.client-ip=91.218.175.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="Lp/5WC0u"
Date: Sat, 1 Aug 2026 08:46:52 +0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1785545219;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=gMek1aawQ8IyooAOw8hjJzP++g15hi+kUNuEx4O2XuA=;
	b=Lp/5WC0ukjnAn5o7N1qqH1jN1lRSaj6RecCQ9ONDeU+uZ3dm1b6L3FalP3D7qZ6EHAhVdC
	VlIh6gP28hAflRVDqF1Bq042TiBVII/vlLXde6jAxOk4MqdsHPCkYT7WPSTm3YwOPD+5px
	ZYNtt22HoOYMfrGxy6XWPDx99Au6IY4=
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
From: Baoquan He <baoquan.he@linux.dev>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Chris Li <chrisl@kernel.org>, Kairui Song <kasong@tencent.com>,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kemeng Shi <shikemeng@huaweicloud.com>,
	Nhat Pham <nphamcs@gmail.com>, Barry Song <baohua@kernel.org>,
	Youngjun Park <youngjun.park@lge.com>, stable@vger.kernel.org
Subject: Re: [PATCH] mm/swap: reject swapon() on filesystem-level encrypted
 files
Message-ID: <am1B_Mz21L54mrDS@MiWiFi-R3L-srv>
References: <20260730184853.48347-1-ebiggers@kernel.org>
 <amy7Biucbf-et5O2@MiWiFi-R3L-srv>
 <20260731181408.GA12803@sol>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260731181408.GA12803@sol>
X-Migadu-Flow: FLOW_OUT

On 07/31/26 at 11:14am, Eric Biggers wrote:
> On Fri, Jul 31, 2026 at 11:11:02PM +0800, Baoquan He wrote:
> > On 07/30/26 at 11:48am, Eric Biggers wrote:
> > > ext4 and f2fs don't prevent filesystem-level encrypted files from being
> > > set up directly as swap files.  In this case, encryption is bypassed.
> > > 
> > > No one should be doing this, vs. the methods of encrypted swap that
> > > actually do work (such as swapping to a dm-crypt device, or swapping to
> > > a loopback device on top of a filesystem-level encrypted file).
> > > 
> > > Nevertheless, to prevent user error, make swapon() explicitly reject
> > > this case.  Document this behavior in fscrypt.rst as well.
> > > 
> > > Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
> > > Fixes: f424f664f0e8 ("f2fs crypto: add encryption policy and password salt support")
> > > Cc: stable@vger.kernel.org
> > > Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> > > ---
> > >  Documentation/filesystems/fscrypt.rst | 4 ++++
> > >  mm/swapfile.c                         | 4 ++++
> > >  2 files changed, 8 insertions(+)
> > > 
> > > diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
> > > index c0dd35f1af12..cba1989777da 100644
> > > --- a/Documentation/filesystems/fscrypt.rst
> > > +++ b/Documentation/filesystems/fscrypt.rst
> > > @@ -1238,6 +1238,10 @@ astute users may notice some differences in behavior:
> > >  
> > >  - DAX (Direct Access) is not supported on encrypted files.
> > >  
> > > +- Encrypted files cannot be used directly as swap files.  To swap to
> > > +  an encrypted file, set up a loopback device on top of it.
> > > +  Alternatively, encrypted swap can use a dm-crypt device instead.
> > > +
> > >  - The maximum length of an encrypted symlink is 2 bytes shorter than
> > >    the maximum length of an unencrypted symlink.  For example, on an
> > >    EXT4 filesystem with a 4K block size, unencrypted symlinks can be up
> > > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > > index 78b49b0658ad..e4991da81b5f 100644
> > > --- a/mm/swapfile.c
> > > +++ b/mm/swapfile.c
> > > @@ -3650,6 +3650,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
> > >  		error = -EBUSY;
> > >  		goto bad_swap_unlock_inode;
> > >  	}
> > > +	if (IS_ENCRYPTED(inode)) {
> > > +		error = -EINVAL;
> > > +		goto bad_swap_unlock_inode;
> > > +	}
> > 
> > Sounds reasonable to me.
> > 
> > One minor suggestion: it might be helpful to emit a pr_warn_once()
> > explaining *why* the swapon was rejected and pointing users to the
> > dm-crypt / loopback alternatives, so the -EINVAL isn't opaque.
> > Optional though -- the check itself is what matters.
> 
> How's this?
> 
>     pr_warn_once("Filesystem-level encrypted swapfile '%s' is unsupported. Create a loop device over it, or use dm-crypt\n", name->name);

Looks good to me, thx.

> 
> > And this patch updates fscrypt.rst. Would it be good to also
> > update the swapon(8) man page to document the new -EINVAL
> > condition?
> > 
> > Other than these,
> > 
> > Reviewed-by: Baoquan He <baoquan.he@linux.dev>
> 
> swapon(8) is for the util-linux program, not the syscall, so it doesn't
> document error codes specifically.  It does have a NOTES section that
> incompletely documents filesystem-specific constraints on swap files.
> It's missing most of the current constraints.  But sure, I'll send a
> patch that adds a note to there about this one.  That will be a
> util-linux patch.

Sounds great, thanks.

