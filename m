Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5963D16A956;
	Sun, 31 May 2026 00:29:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780187376; cv=none; b=uVFD8wFRvutFcVVfBCQKzFBya8H1DUB/FtPpP4ol4TV2gtWsjze/PdCde0irAlpovYnkKWyAQfYPCqBPw/wlq8tz70sAibkQwbHlJuhRHGJj37NklennmLrVZGASL9zwsAv0/h3D8pHYy0+cHxal73CpJqRyUknjVl3LZFhAsQk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780187376; c=relaxed/simple;
	bh=AD1AMy5bLVcMYXuWIyDGwnjZnlmVsyuSxOkaZb5G28g=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=urOm02W2a8uppEjpc+Dqsfz+QAyg5yHUnIg7kkvatZyy7mEcTPbe9STavd0f9I9nF90UEWpyzvpuGXUHG1mM1bxTcBiCiDn7AvFmO9UNx23Ic06TYNRgLDBSGNOif4y5XWJ4UnDy+H4Ooxs95hYiae44vj7wq56GvHbcjJGGFiQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VCebwP2+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VCebwP2+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8B9C91F00893;
	Sun, 31 May 2026 00:29:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780187374;
	bh=GpQP2cCzQg14Z3YhYQfDikSA8Afbh8IGn5xQA/IJRNY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=VCebwP2+SkNVGSz4hbKEf0beGCCpWJUIAt+upfMd/YfmYsrUFCfq9pLuME2OmIyuT
	 P39tUUTGEEKtSU4gJtc/Y358+GIa2PEmVYNWg5rBsmPV2ZAIq9/icVp247l5A5Xvvx
	 1tVt+74uSGepB/SA1XFAHSQRp75JoMkHXzsTUrxdRQhrqw6E2dCO3QCKQT99xO5YWT
	 Qy3EotHIa9pnzWtHR/Ag55NveO0nFzaJ3ARqWWBGOYoUdBdHABKyKeHTJdVVzH+h2Z
	 jmYai3zb2LcB+qQerAbJTVnNfxpmGtZZfRSBvMDzYsThhhtaK/8ygzbo2kSTlqOJ28
	 SUzpPCc9axbDw==
Date: Sat, 30 May 2026 17:28:12 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Daniel Vacek <neelx@suse.com>
Cc: David Sterba <dsterba@suse.com>, linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>
Subject: Re: [PATCH v7 00/43] btrfs: add fscrypt support
Message-ID: <20260531002812.GA2302@sol>
References: <20260513085340.3673127-1-neelx@suse.com>
 <CAPjX3FdHJpZUVk2dfA+Ov5K6vOSsOJMUaxCU4G8y1qg6baMXYw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPjX3FdHJpZUVk2dfA+Ov5K6vOSsOJMUaxCU4G8y1qg6baMXYw@mail.gmail.com>

On Fri, May 22, 2026 at 09:00:46AM +0200, Daniel Vacek wrote:
> Hi Eric,
> 
> This is just a gentle ping.
> I was wondering if you had a chance to look at this version?
> I believe all your previous feedback has been addressed and this
> version is solid.
> Please, let me know your thoughts.
> 
> Regards,
> Daniel

It's been really hard to find time to review this huge patchset.  I've
started going through it and will try to leave comments next week.

In the mean time it would be really helpful if you went through the
Sashiko reviews
(https://sashiko.dev/#/patchset/20260513085340.3673127-1-neelx%40suse.com)
and address the ones that make sense to.  It found 93 issues including
16 critical ones, which is kind of a lot.  Some of them are the same
things I'm noticing already.  Same for the issue that Christoph noticed
where new devices can be added; Sashiko had already found that too.

If I'm going to have to use my limited human review time to point out
issues that were already found, that's not a great use of time.

I also don't see any information about how this was tested (and will
continue to be tested in the future).

- Eric
