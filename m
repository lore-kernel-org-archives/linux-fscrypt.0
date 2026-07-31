Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 825B71A6806;
	Fri, 31 Jul 2026 03:49:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785469773; cv=none; b=NE0TxvkY/9vpi0X3xBgEaKsnRZd8uixsBlm7tdrCFSjOEtjLE3xHLnAAzVqd+f2Y0TqktOUyQ7jKJcwgxelmtJfsr1CHt1UEl2h9u1zwGAJKuEt52iHin9mrUK9Cs6mhGD9g/RNhShC2FHotNohD+tybY3Q4sPEb/w++2xkYzwE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785469773; c=relaxed/simple;
	bh=Xs5EZBTCGup0ChmpiedahUkIlAS4z4uw3dVD5ImtAA0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=RLIQz6UH2SJiuw5RymkXraq6mc8CU0ZmHM8IbbHOQjfko/uMwmL8ncEgN2fmqGiZlG3Sj6az/MYJmQmv9Fue1SAbQBbdM7OrvlXmg7edSEVSTi1F6wg9VOwWw+iIAlLnWLfb/L42Ws63M6Rv653ekUuDLmEQwaKniHCXFLick+A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FwTJNs5V; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FwTJNs5V"
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 166521F000E9;
	Fri, 31 Jul 2026 03:49:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785469772;
	bh=8q+CEcjT0/iBfHUwPXNhK8ziLF4oFgSoOjKvD4YWaGY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=FwTJNs5Vumh3CUVcguBi+5yKoJxMTtilqRiJuDvone6PZJcbDbmMEHpl1Z7iq9rsE
	 6k6RiSo6KxwvDvHKmoW45fM/wgMISyE14ExPq+sNfEPbTgtRwLqz4JlSImEA2+JbQ+
	 bB5t4T1gzwpajNR6w86Iy2wFmC20uaYQ3YAkkU5fR7ofK+oT+ZiO4N+dUCrW1pq2Bd
	 /EFi7S3O+giNTmCitLkwkXsMZiJeIiWcY+IxIZETcT+vzTTtYB+1qtNHpgZ0HiZnKd
	 RaWTtZIRvcAJWa1M24ky031D9SxNY31Y3NYwjtESZz8wkqq05zS8S2YE1ChAUZ7YqS
	 sN7F0nocCgRLg==
Date: Thu, 30 Jul 2026 20:49:31 -0700
From: "Darrick J. Wong" <djwong@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Chris Li <chrisl@kernel.org>, Kairui Song <kasong@tencent.com>,
	linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
	linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
	Kemeng Shi <shikemeng@huaweicloud.com>,
	Nhat Pham <nphamcs@gmail.com>, Baoquan He <baoquan.he@linux.dev>,
	Barry Song <baohua@kernel.org>,
	Youngjun Park <youngjun.park@lge.com>, stable@vger.kernel.org
Subject: Re: [PATCH] mm/swap: reject swapon() on filesystem-level encrypted
 files
Message-ID: <20260731034931.GA3560112@frogsfrogsfrogs>
References: <20260730184853.48347-1-ebiggers@kernel.org>
 <20260730125327.11fc9227d04f659a59136cdd@linux-foundation.org>
 <20260730203003.GA2459987@google.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260730203003.GA2459987@google.com>

On Thu, Jul 30, 2026 at 08:30:03PM +0000, Eric Biggers wrote:
> On Thu, Jul 30, 2026 at 12:53:27PM -0700, Andrew Morton wrote:
> > On Thu, 30 Jul 2026 11:48:53 -0700 Eric Biggers <ebiggers@kernel.org> wrote:
> > 
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
> > 
> > Ouch.  We are going to break ten year old setups?  I don't think we can
> > do this!
> 
> That assumes anyone is actually depending on this bug, which they
> probably aren't.  Encrypted swap is done in other ways.

Hmm.  swapon() seems to read the swapfile header via read_mapping_folio,
which means that fscrypt will read the encrypted block 0, decrypt it,
and hand the mm a valid swapfile header, right?

For blockdev filesystem, the setup_swap_extents code will set up a file
range -> LBA mapping, and the swap code issues bios directly to the
bdev.  Ondisk contents aren't encrypted, and read()ing the swapfile will
produce garbage because we're decrypting something that isn't encrypted.

So I guess the bug here is that the ondisk swapfile contents aren't
encrypted?  Can we fix the swap code to call fscrypt_set_bio_crypt_ctx?

Though, you probably don't want anyone to read the non-header swapfile
contents, so can one create an ephemeral encryption key for the swap
code?  Or do you not want crypto engines in the swap path?

(Apologies for my unfiltered idiot thoughts :P)

--D

> 
> > I think the best we can do is to emit loud warnings which point the
> > operator to some Documentation/ which tells operator that this
> > deprecated configuration will be disallowed in, umm, 2029.
> 
> ... and if they are, they'll want to fix it right away anyway, not in
> 2029.
> 
> Other fixes to explicitly disallow swapfile activation in various cases
> have been merged without a deprecation period, e.g. 36e4d95891ed,
> 377eeaa8e11f, 51cc3a6620a6, d15cab975459.
> 
> I think we should try just doing this instead of dragging it out over
> several years.
> 
> - Eric
> 
