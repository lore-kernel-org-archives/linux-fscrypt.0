Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792603487;
	b=TTk3ulElk146rRU2aR87jw/zogDmPs3oVfBL6pGQiOaKWRKoaAmkx2zZwydo503FpIjf
	 1WuNd8xcQgE5nafZFLleRtt212kKn11eMlZTg+vHkp0T6mJslsHZr1ojKY/rN1vmEt8x5
	 Me3Xh15UcLSAh09o8eKNLPCNBtra9QEzfV18GPSkq8Qd+HIDcnhwzgUck3W6oRrrPVAVH
	 /69Ur2/kGSUINc7cyqawfw0vUDgYG/PIq+c8s3f8c8ipWqGfj6h1wjPReQkHkwZf1ilWN
	 yAL7lqMqMC0ONDUukmm9YrAMX+a6miOTZO8wCdx6VuMOK3FBAryUfZMWlb39XKRuo+A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792603487;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=DXV+aH3notSoKMy4wQw/6P/Xlnp9FuOgu7u/zubMkSY=;
	b=QsvOSYc43fO/vX1x5tg+ZdLipM1awM9LRIHddSX0qdvnN4jDxbme8qW/BvbPboAaXtzs
	 1rE9iAgbjlqdIvhji9N2XSKNeAIMAkbXMNkJhOGvKT1rhJYjJcOccpMyqd6VgIE/S48EM
	 ws4x+ctoTtdTv2cwUlT5pU6HIkcpxQESdSR/ze+mWOhRW9eyUM0CCPTXjA5Le2H6OxwzC
	 sQg88wT65b+OP6LytiDrgtzNAU4ZNpVLYbMl7TMq7TUzuzKa8DlWM8tN0/+84CfQ8jRvY
	 lKPbB52VGROqUtRfR4sMZgncyZuC2MJGWGLdFmWqBDLMMg+zkG6WR8AV4lODwrHPKTQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="A9l2uI/H";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F308606A31B;
	Wed, 21 Oct 2026 17:24:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=A9l2uI/H
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 358B71F000C1;
	Wed, 21 Oct 2026 17:24:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792603486;
	bh=DXV+aH3notSoKMy4wQw/6P/Xlnp9FuOgu7u/zubMkSY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=A9l2uI/HFcF59245LRH8r7DvYuKa2BWuA040155VzQp1Ug9SBMsznrzQo05Ado0Dq
	 LNWGEXVCVo+v6kbaiOj//ig47GqgF1JaHNr23lArUt3d2ISYX84t+FdcPXdczMue2W
	 kylxk7KWotPNl4l5/U761xpttSuLUcZz0IS6MMduHlYOUb6CJMyEXXu6P+pdOcxn+5
	 q0L1huu5H+xtulOsEXN/7/dsqEoc1I3qSaCPjnJy0OFVl+OgK75yB4xnIgcrKktSew
	 TfK6MnJYuEOgLnqUo78cKyyXFj1tieCQSdfzQc3pYdr3NeQaFpCxpbcp0h4m7RG1b/
	 lWgXfODCeoB0A==
Date: Wed, 21 Oct 2026 10:24:44 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Alex Markuze <amarkuze@redhat.com>
Cc: ceph-devel@vger.kernel.org, idryomov@gmail.com, xiubo.li@clyso.com,
	slava@dubeyko.com, viro@zeniv.linux.org.uk, brauner@kernel.org,
	jack@suse.cz, linux-fsdevel@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, tytso@mit.edu, jaegeuk@kernel.org,
	linux-kernel@vger.kernel.org, kernel test robot <lkp@intel.com>
Subject: Re: [PATCH v5 1/5] dcache: export d_find_alias_rcu() for modular
 filesystems
Message-ID: <20261021172444.GE1879@quark>
References: <cover.1792527529.git.amarkuze@redhat.com>
 <ad1e9d2c5ba4803f1c7dafc6687638b0489a7265.1792527529.git.amarkuze@redhat.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ad1e9d2c5ba4803f1c7dafc6687638b0489a7265.1792527529.git.amarkuze@redhat.com>

On Tue, Oct 20, 2026 at 08:26:46PM +0000, Alex Markuze wrote:
> The Ceph subvolume quarantine ancestry walk needs to find a dentry
> alias under RCU without taking a reference. d_find_alias_rcu() provides
> these semantics, but it is not exported, so a modular Ceph client fails
> at modpost with an undefined reference to the helper.
> 
> Export d_find_alias_rcu() to GPL modules so filesystem modules can use
> the existing RCU lookup without changing its lifetime rules.
> 
> Reported-by: kernel test robot <lkp@intel.com>
> Closes: https://lore.kernel.org/oe-kbuild-all/202610171220.i77KPiw5-lkp@intel.com/
> Signed-off-by: Alex Markuze <amarkuze@redhat.com>

This is a prerequisite for later commits rather than a bug fix.  So it
shouldn't really have Reported-by and Closes tags, even if you found out
it was needed via the kernel test robot.

- Eric
