Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F14614B08A;
	Tue,  2 Jun 2026 02:27:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780367238; cv=none; b=V00FjfnuELWl/2VG1RpFAniLdqA92zwTaP6LDK8lN11a8b8xFv/GzwhCkHNIQMIyT/avYuAagC41GEhjvuoVpIvZQxU2bkdHlHQDXaXz0HMxtExh+hJBCrO35KWlOAe+/YpI9GdCyLknXp8lv7J7AiV3SxyQPS1V4ptqpdfxL3M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780367238; c=relaxed/simple;
	bh=xh5UTebwoTaJowF/caom4XsBxJnvBYNsa8feunb0Nh0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=XpqwU8ro+cf1OvgzuhocoUgkCJv2o66LrAU72PEJV5UWr0Qu6dc7AE51fUC/u6bruv7XY9HTO9vO7W/nwRwsSjNT+7ij4UShWLTN9/DQLC7IH3XMDmaxh4TG5Z0WLg1+sd/8EU8ODfbpjAEry7OOi3rlknvDkMnLXs+TklIdbos=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TBp6yDOS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TBp6yDOS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 12FBF1F00893;
	Tue,  2 Jun 2026 02:27:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780367237;
	bh=rZGdAyljt+9D6Yth8VqYWsVrybBQ37b7qGSayvIDdss=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=TBp6yDOSpgGe4fBRS1WlG+K1YrLrNf/BhtCuM1ASQKUbZxGwjR18GF4sijAdpUVlU
	 lOulDcd/GQzR8qmvpb4iM23/W9O7kHkgMmRIkgoHJZi50l5OaEsYjPZKaw4gNBomKO
	 3JhyTEvVeQBaMqiSEtj9P896Eew3UiNTHymSAETEua8MoNeiEq13M9b1TITfv6ytGO
	 dnR6B9E9N61yr9Z6XZpJjXdBp2sMy0bjTQIqZWyJjOfJ72uxEO8gOQ0MUCbscFc6Yj
	 by130FmHjNgftvLWQsaSLO9GsBiUud3HR7WtE4ismnE0o7V8ErgKWjL3AEz5c+rKmZ
	 cAQQdWdZjOqCw==
Date: Mon, 1 Jun 2026 19:25:53 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: David Sterba <dsterba@suse.cz>
Cc: Daniel Vacek <neelx@suse.com>, David Sterba <dsterba@suse.com>,
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org,
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH v7 00/43] btrfs: add fscrypt support
Message-ID: <20260602022553.GA2295@sol>
References: <20260513085340.3673127-1-neelx@suse.com>
 <CAPjX3FdHJpZUVk2dfA+Ov5K6vOSsOJMUaxCU4G8y1qg6baMXYw@mail.gmail.com>
 <20260531002812.GA2302@sol>
 <20260601185730.GE880787@twin.jikos.cz>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260601185730.GE880787@twin.jikos.cz>

On Mon, Jun 01, 2026 at 08:57:30PM +0200, David Sterba wrote:
> The testing is not straightforward as it needs 3 projects to
> synchronize, kernel, fstests and btrfs-progs. Testing may need to use
> custom git branches for all of them. For btrfs-progs the changes will ge
> it in soon. For fstests it can be a chicken-egg problem, as they don't
> accept tests for unmerged code. We've been using our fstests [1] with
> additional fixups (not upstreamable, related to CI workarounds). Though
> I'm not sure if Daniel has updated the branch with his most recent
> version.
> 
> [1] https://github.com/btrfs/fstests branch staging

Where are the btrfs-progs changes, then?  I'd like to try this out, but
there's no way to do it without the btrfs-progs changes.

- Eric
