Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8E13220F2A;
	Mon,  1 Jun 2026 22:49:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780354163; cv=none; b=aMJjoborfKcdtLCeXd3nLLo+qkeJ/zpuUmxb79z88oOLFKiNKN5X4qkrgeJ3DKWGoKFsVYRZUCWZh+xS8LU/j79NBC4XFD2pL15oax50V/SrrNwA5JjYDBlJzKQ7Oxp1hF2u2QjsVgLCtvH14ZqSAchQYWc9SLI4Ai03WI/wKV8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780354163; c=relaxed/simple;
	bh=F+WSqdkpPPgftAppQyk1MHcuQ267mtpksfKrqBbVLck=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=KN/5JMKZ04lU73gchIC03oqk+yTE+jH2HlFQOLdCvHLA/V+8rRPw3fjT8etIbPLUWptny+9SAYq2RunGtH7UjGcV+OvBC6IEbMFTPbjlDDi+U0AyQIoYgjSYEumrBUKfYoE1qlAFxqLUj7SIxq5REwoVq+O2nJmU+uImZUFVnEs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TTV3ewj5; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TTV3ewj5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E66EB1F00893;
	Mon,  1 Jun 2026 22:49:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780354162;
	bh=GMHsW4wzBTs17hF6XmXmLDH/uJr0lfwJaTOBO8nbrCo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=TTV3ewj5NsSZQrG7aMRZ9SujP2Q49EJYG3y7929SCvuO91/roGdKCDVFWHXKv+4Jn
	 EiFomtI701tUH5kLtL2n5/pRRvgJe0ABz1WdCTZ6Oam/CCJrZneUXCCPIqPskcTIgm
	 eO6HtnbPHrh8jHSXd52Bcnd90jNWtWLkhV5GYM1UXke1GouPSGTSaWsEDgljBZEdYX
	 2+fmEShszmbFcz7sTxCdGS1iRg3spQ6RIGP6GHaEvIyH9Ra95TMbeRWa+TR0PVZ5VM
	 8YJ9aPVKv2QQKEMCEuWYpLz0hmc6eoagBe1l3ZwP0lXozXHQxmQnpjWGRWZjJqXx/j
	 uTrZAvQoIMicw==
Date: Mon, 1 Jun 2026 15:49:20 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Daniel Vacek <neelx@suse.com>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>,
	David Sterba <dsterba@suse.com>, linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v7 02/43] fscrypt: allow inline encryption for extent
 based encryption
Message-ID: <20260601224920.GB25574@quark>
References: <20260513085340.3673127-1-neelx@suse.com>
 <20260513085340.3673127-3-neelx@suse.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260513085340.3673127-3-neelx@suse.com>

On Wed, May 13, 2026 at 10:52:36AM +0200, Daniel Vacek wrote:
> From: Josef Bacik <josef@toxicpanda.com>
> 
> Instead of requiring -o inlinecrypt to enable inline encryption, allow
> having s_cop->has_per_extent_encryption to indicate that this file
> system supports inline encryption.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> Signed-off-by: Daniel Vacek <neelx@suse.com>
> ---
> 
> v5: https://lore.kernel.org/linux-btrfs/ba0289bf103653d5d98ef576756c9a2a66192865.1706116485.git.josef@toxicpanda.com/
>  * No changes since.

There are multiple places that check SB_INLINECRYPT, and just one was
updated.  Perhaps we should just require that if a filesystem sets
has_per_extent_encryption, then it also sets SB_INLINECRYPT
unconditionally?

- Eric
