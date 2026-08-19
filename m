Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C64248124F;
	Wed, 19 Aug 2026 15:59:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787155150; cv=none; b=h2AeQFWdAxXVAXHFu+GRrCgfG+H6MdRTuC2aIauJd2E1ZiJyDdd4cwrt4vqDkUwG0wV/p7jRCP28nQpQzO9KZLuwJkMDY9fTuMRoAObJPeHhUPKQal8fDjp/NNEjtLUl1/AqAcTfN0PlriKJY90G/pedTA1QWFSisDvbArVWrLU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787155150; c=relaxed/simple;
	bh=gyiwzgRFBgpMiO0mYoAMPpWKSTfBiU/hHtAhcpRNnV0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Fpy8I8uSVMvCc7jCSLcl057kBXnJ7dsP5+73Rh3jHXxviucBzrbG6N1gub9ZMMaHceSQDfW7yBb+nXiQZy5f3KuWi3288gYBnyAB+1Y8g0e2BMlPxzpTc+TIcsFaLvNECs9UPT0cg7is48Q8vkvVy5ZWPcQYXV+CB/pjhwb9S1c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GA/UJ7M7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GA/UJ7M7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DBA3F1F000E9;
	Wed, 19 Aug 2026 15:59:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787155149;
	bh=4OZbhIDikR9/2zroFeBxBjqLIO62d/6MwjWrBQmMmBY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=GA/UJ7M7AE4+2XXEmjHT0KfvKO77XFiMupAAOWd2BGPEW6K1WqhO7+iVU+oSyN92N
	 +bKHO8lg6uxReRdC+tbTfvC0SSx8sa0/Ep9IDt46lEUZEgXDaFrFWHXhhSDoD0ZL7o
	 W4OH8EkV2Z/Xami9CyyPvqeEtuQ9joIUtPfTo+msHORyzqwwSfBT9frgziE9Ll05sY
	 2RVApvgDokp0xh6uZz+c72tWrvplbSfXEYsw0yKTi/Cfk9fWRsNwDTlFOEdV7X5Zhq
	 BiyZHZ3cxg8RSWK11vqOjQADFwVPYqbL7gMyq0hzMGXOC+FLDqL/1GK9xqYZhKkENx
	 BpbdknEZ4nN8w==
Date: Wed, 19 Aug 2026 15:59:07 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Daniel Vacek <neelx@suse.com>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>,
	David Sterba <dsterba@suse.com>, linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v7 04/43] fscrypt: conditionally don't wipe mk secret
 until the last active user is done
Message-ID: <20260819155907.GB133077@google.com>
References: <20260513085340.3673127-1-neelx@suse.com>
 <20260513085340.3673127-5-neelx@suse.com>
 <20260601230406.GC25574@quark>
 <CAPjX3FdMBAbz9T5yW=0ytRJD8s6zYHpo+TcYY-9-+egBHL=TFw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPjX3FdMBAbz9T5yW=0ytRJD8s6zYHpo+TcYY-9-+egBHL=TFw@mail.gmail.com>

On Wed, Aug 19, 2026 at 04:22:23PM +0200, Daniel Vacek wrote:
> > > +     /* We can't wipe the master key secret until the last activeref is
> > > +      * dropped on the master key with per-extent encryption since the key
> > > +      * derivation continues to happen as long as there are active refs.
> > > +      * Wipe it here now that we're done using it.
> > > +      */
> > > +     if (sb->s_cop->has_per_extent_encryption)
> > > +             wipe_master_key_secret(&mk->mk_secret);
> >
> > wipe_master_key_secret() is idempotent, so we might as well just do it
> > unconditionally here.
> 
> While this is true, it also (kind of) documents that the secret should
> already be wiped out by now in case of !extent encryption.
> 
> But I can wipe the secret unconditionally here if you insist.

So leave a comment that mentions that it's not always needed.  Just like
how fscrypt_free_master_key() does kfree_sensitive(), because why not.

- Eric
