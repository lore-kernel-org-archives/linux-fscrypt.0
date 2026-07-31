Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D12EE220F2A;
	Fri, 31 Jul 2026 04:06:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785470795; cv=none; b=QKuDYvq/UvjytViR9rE7IBgduDeOGJfYxwGdrXJgGkzK6vUKKR1QKzl1GdB3Vy1pYJWJHILqrxvVmnWzIBFBweXiOYXWLwNbOdBAMyKuVKcWZyYk4O1+429yXp3Jehh0vZfiYbRHDjY8sELjU1HU0Z7/2C4SAfQR8I4RcHFZjFc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785470795; c=relaxed/simple;
	bh=4dy48tLDZGr7DRRYU9A7+5TMxbTgAf0steo+tUd7dNE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=YOJ0XTCnEqXI9CJx/g4cwIpJNrsVQ+KoURwwBskBzw+iW7ETaBax0fgdbeWAOFBaHlclyIhMSKPTgsIZMi6kCXljJarcR7rKipdryXhuk83Ohe0V4rfQqVjuM/1WrQiWsqDOue4YtPQPzTqjm42umCxq5rOH3MQ3EhBo9Tgc96o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=m7B+fjjE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="m7B+fjjE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 03F261F000E9;
	Fri, 31 Jul 2026 04:06:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785470794;
	bh=fn6R3CY2DDXWCXfEF8whxcR7qeoOx35W3rFoVjeg1R4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=m7B+fjjEiGq1rqMarKfoQJQ96mJkrzCxoRde8Udl7TiUxoCJtU/TypNioHp3L+iYu
	 hLo2t58MraJappvVMHjnsGitHOqF5W0wjGzk7GOvzfTVFy7Qx/RL5WmtEs2dw0yVW5
	 X/5s11pJLiivLCbT8OUo1SalZ9VlVQeIPfI+EK4ZG/7ZWy4FgEtr+iy+6XKA0dMVqS
	 n7n+dvfMBWTzi0nHe3BEVxaoZyIjstNS7r4dxs264Ux4cZN5XlFcrk9dHzKSp+HAmI
	 0bOQ9TqmESz1rpQ9X9kJm6iIiEPi2jphSt9RnUqN5IxyRQizFDyp6xumXI86Ge8p8+
	 hkbJfsHCFokQw==
Date: Thu, 30 Jul 2026 21:04:38 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: "Darrick J. Wong" <djwong@kernel.org>
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
Message-ID: <20260731040438.GA57540@sol>
References: <20260730184853.48347-1-ebiggers@kernel.org>
 <20260730125327.11fc9227d04f659a59136cdd@linux-foundation.org>
 <20260730203003.GA2459987@google.com>
 <20260731034931.GA3560112@frogsfrogsfrogs>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260731034931.GA3560112@frogsfrogsfrogs>

On Thu, Jul 30, 2026 at 08:49:31PM -0700, Darrick J. Wong wrote:
> On Thu, Jul 30, 2026 at 08:30:03PM +0000, Eric Biggers wrote:
> > On Thu, Jul 30, 2026 at 12:53:27PM -0700, Andrew Morton wrote:
> > > On Thu, 30 Jul 2026 11:48:53 -0700 Eric Biggers <ebiggers@kernel.org> wrote:
> > > 
> > > > ext4 and f2fs don't prevent filesystem-level encrypted files from being
> > > > set up directly as swap files.  In this case, encryption is bypassed.
> > > > 
> > > > No one should be doing this, vs. the methods of encrypted swap that
> > > > actually do work (such as swapping to a dm-crypt device, or swapping to
> > > > a loopback device on top of a filesystem-level encrypted file).
> > > > 
> > > > Nevertheless, to prevent user error, make swapon() explicitly reject
> > > > this case.  Document this behavior in fscrypt.rst as well.
> > > > 
> > > > Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
> > > > Fixes: f424f664f0e8 ("f2fs crypto: add encryption policy and password salt support")
> > > 
> > > Ouch.  We are going to break ten year old setups?  I don't think we can
> > > do this!
> > 
> > That assumes anyone is actually depending on this bug, which they
> > probably aren't.  Encrypted swap is done in other ways.
> 
> Hmm.  swapon() seems to read the swapfile header via read_mapping_folio,
> which means that fscrypt will read the encrypted block 0, decrypt it,
> and hand the mm a valid swapfile header, right?
> 
> For blockdev filesystem, the setup_swap_extents code will set up a file
> range -> LBA mapping, and the swap code issues bios directly to the
> bdev.  Ondisk contents aren't encrypted, and read()ing the swapfile will
> produce garbage because we're decrypting something that isn't encrypted.
> 
> So I guess the bug here is that the ondisk swapfile contents aren't
> encrypted?  Can we fix the swap code to call fscrypt_set_bio_crypt_ctx?
> 
> Though, you probably don't want anyone to read the non-header swapfile
> contents, so can one create an ephemeral encryption key for the swap
> code?  Or do you not want crypto engines in the swap path?
> 
> (Apologies for my unfiltered idiot thoughts :P)

Well, the direct swapfile implementation bypasses the filesystem after
the header has been read and the on-disk blocks have been queried.  That
seems to be very much what it's designed to do.  It seems out of scope
for it to start trying to implement filesystem features like fscrypt
file contents encryption.  (Note that there's more to it than calling
fscrypt_set_bio_crypt_ctx(), especially in current mainline.)  After
all, we also wouldn't expect it to understand and implement the
compression, checksums, etc. features of various filesystems.

Yes, when people encrypt their swap, they of course use an ephemeral
key.  However, they use either dm-crypt, or a loop device on top of an
fscrypt file.  (Note that if they use zram with a backing file, they
*have* to use a block device anyway.)

Fortunately, I've never heard of someone actually using the direct
swapon() with an fscrypt file, which is what this patch pertains to.
This case was just found by an LLM review.  I don't think we need to add
a new feature here; we should just remove the footgun just in case.

- Eric
