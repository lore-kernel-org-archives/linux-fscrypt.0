Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71E1F466AE2;
	Fri, 31 Jul 2026 18:16:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785521776; cv=none; b=h7kKyY8nZRCpkUWyI+UqRqsDgIKqvjYrRVVUaDpyk6qCpaswkWrpo+vivzgo9Coksd+rSjSrM098WN6ggOhPXSjVuXHWP78+d+Sy0+RK5ha/OqMLzis6aoh5iCLg2FGQola9cMhva/LSnCMBzwGZsQ2EfGFPRguUKz3+rx8MCy0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785521776; c=relaxed/simple;
	bh=CcxphOxNjL+KMyQ1tu9OR8vnIHJ2PFjVdBP4isIEzpQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pMofuOyl6f5AhREglgHkCf5E4xpiffjlfJ4JPfhw2n0j/SygcIr9uuxcxuG11pggGA8YddQ/mXAFXDka+hIc8ldGja1C8pfBP7AbiWgzIql2BKFoz0w6hVCXBl6htAmrIFwEwADpkag3MliACQr5qmZX6FBqZIvXxdaPLNDY+9U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=C8mqCAa3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="C8mqCAa3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6998C1F00AC4;
	Fri, 31 Jul 2026 18:16:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785521763;
	bh=9wUJP0XuZAHVCju2vCQtbQJIE3DcNFW1LWD6svK3iD8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=C8mqCAa3sOez8bYlcdk7Ex9hl1Zc3wGzNlS+gMfhYDFWo2GO6U1oOyWzlb2bPQY+x
	 hqp45+zj52D2OrfKyI0wE6OnSs4tXIB0pDV9h5BA+FBwqNLLssYqEG2iralfKBbWze
	 8TnH2nZgoDMCRUVPIIfWgQ5CX2TqVmWguLZl5ry0GMyg4/zCAi/p/yVuCqOjBPDh1S
	 3CfPkRN86lNOdPWBsocKmexkv/xlcBg6n1fCMbp7GWE8C9TU8+qYac8CviSfGdpNx7
	 2tBQ+HKflUJA/Bs03oR8x3vLAb4l3YfkvzAafZcN8aqTCzekcrr22Gj5IiA+WkyfGs
	 NrtPDLo03P3hg==
Date: Fri, 31 Jul 2026 11:14:08 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Baoquan He <baoquan.he@linux.dev>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Chris Li <chrisl@kernel.org>, Kairui Song <kasong@tencent.com>,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kemeng Shi <shikemeng@huaweicloud.com>,
	Nhat Pham <nphamcs@gmail.com>, Barry Song <baohua@kernel.org>,
	Youngjun Park <youngjun.park@lge.com>, stable@vger.kernel.org
Subject: Re: [PATCH] mm/swap: reject swapon() on filesystem-level encrypted
 files
Message-ID: <20260731181408.GA12803@sol>
References: <20260730184853.48347-1-ebiggers@kernel.org>
 <amy7Biucbf-et5O2@MiWiFi-R3L-srv>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <amy7Biucbf-et5O2@MiWiFi-R3L-srv>

On Fri, Jul 31, 2026 at 11:11:02PM +0800, Baoquan He wrote:
> On 07/30/26 at 11:48am, Eric Biggers wrote:
> > ext4 and f2fs don't prevent filesystem-level encrypted files from being
> > set up directly as swap files.  In this case, encryption is bypassed.
> > 
> > No one should be doing this, vs. the methods of encrypted swap that
> > actually do work (such as swapping to a dm-crypt device, or swapping to
> > a loopback device on top of a filesystem-level encrypted file).
> > 
> > Nevertheless, to prevent user error, make swapon() explicitly reject
> > this case.  Document this behavior in fscrypt.rst as well.
> > 
> > Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
> > Fixes: f424f664f0e8 ("f2fs crypto: add encryption policy and password salt support")
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> > ---
> >  Documentation/filesystems/fscrypt.rst | 4 ++++
> >  mm/swapfile.c                         | 4 ++++
> >  2 files changed, 8 insertions(+)
> > 
> > diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
> > index c0dd35f1af12..cba1989777da 100644
> > --- a/Documentation/filesystems/fscrypt.rst
> > +++ b/Documentation/filesystems/fscrypt.rst
> > @@ -1238,6 +1238,10 @@ astute users may notice some differences in behavior:
> >  
> >  - DAX (Direct Access) is not supported on encrypted files.
> >  
> > +- Encrypted files cannot be used directly as swap files.  To swap to
> > +  an encrypted file, set up a loopback device on top of it.
> > +  Alternatively, encrypted swap can use a dm-crypt device instead.
> > +
> >  - The maximum length of an encrypted symlink is 2 bytes shorter than
> >    the maximum length of an unencrypted symlink.  For example, on an
> >    EXT4 filesystem with a 4K block size, unencrypted symlinks can be up
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index 78b49b0658ad..e4991da81b5f 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -3650,6 +3650,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
> >  		error = -EBUSY;
> >  		goto bad_swap_unlock_inode;
> >  	}
> > +	if (IS_ENCRYPTED(inode)) {
> > +		error = -EINVAL;
> > +		goto bad_swap_unlock_inode;
> > +	}
> 
> Sounds reasonable to me.
> 
> One minor suggestion: it might be helpful to emit a pr_warn_once()
> explaining *why* the swapon was rejected and pointing users to the
> dm-crypt / loopback alternatives, so the -EINVAL isn't opaque.
> Optional though -- the check itself is what matters.

How's this?

    pr_warn_once("Filesystem-level encrypted swapfile '%s' is unsupported. Create a loop device over it, or use dm-crypt\n", name->name);

> And this patch updates fscrypt.rst. Would it be good to also
> update the swapon(8) man page to document the new -EINVAL
> condition?
> 
> Other than these,
> 
> Reviewed-by: Baoquan He <baoquan.he@linux.dev>

swapon(8) is for the util-linux program, not the syscall, so it doesn't
document error codes specifically.  It does have a NOTES section that
incompletely documents filesystem-specific constraints on swap files.
It's missing most of the current constraints.  But sure, I'll send a
patch that adds a note to there about this one.  That will be a
util-linux patch.

- Eric
