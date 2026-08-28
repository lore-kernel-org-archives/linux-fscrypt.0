Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4B053264C1;
	Fri, 28 Aug 2026 01:46:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787881601; cv=none; b=SgRBmdLW6tWB0LYhuk67bCE8M7IZ83Nolnm0ZcoejDk5ADumTAWuIyi88fRGblxtB7dUR9GUzflFVRxsUU0fW+29JCnklZkRC4hCUrQ1sNJ1XUBaqEU+yZQQHksfFMXYllUN6kor2TSvgBanBXM4Z7IyUNEurconNKINKJDEVQc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787881601; c=relaxed/simple;
	bh=hqgCT4vJ679z/l/lWrEZtlqdUFm5kMnI0KnystEXAEA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dnQwLoghym3Cx2tIs45KGVitE5yWoRqFHhc4a1iQQUE2bruiLRIprXLocFSki4Pza8416W9xMsu3XDvn6+QjBF7Ydia6s3b3oRHefYZxYr0hw5r/jycAgO0F5QuY9rdUl6uwPsMkK39/0v09C2kDDmfEe3UImxdN7DiIY7hnF2E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RVLqyzxL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RVLqyzxL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 607791F00A3E;
	Fri, 28 Aug 2026 01:46:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787881599;
	bh=hNAzuVZj1IIFZRlUnxjRcE2OX9vWGSOtCy3XeX1EJyI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RVLqyzxL7ISrUCgjBX8je3cd0dMyWR3mZvRf+Vh85oxXzaWK1IVLrZthVu6h5USeB
	 kHBgFUbIUhNaYmsYBvlv+kwSy8lkHpmb4XOu+naqxUtUkBYNcsTiHe8BejrnQ0Ybh1
	 8Z57yp2Ip86thp/fuZlgT0UbifnQkJDyd7GrycL+ymCiRxXLyc8Jvo8RHTi4S+k8Ik
	 qkYYNZEj8mWQVZ/2TqRBXU+lCXvi1TGUh+aGn4dc0egZ1E+RhhMi9vx9wYjOmbq80F
	 Q7efoZb/t1HB9bDqc/ZN1tF1FPDiN/8RxeNgDsZB046YPa92G7OAJ1yizw3vklKrR7
	 BvvWYR44EOUuw==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-ext4@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>,
	Disha Goel <disgoel@linux.ibm.com>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 5.10] ext4: don't enable DAX on new encrypted files
Date: Thu, 27 Aug 2026 21:46:23 -0400
Message-ID: <20260827-stable-daily-0010-ext4-dax-5-10@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260827034018.136340-1-ebiggers@kernel.org>
References: <20260827034018.136340-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> commit da32af420d6d466e247c43ac0b829edeac7ae0ad upstream.
>
> Currently, when a new encrypted regular file is created, the call to
> ext4_set_inode_flags(inode, init=true) in __ext4_new_inode() is made
> before EXT4_INODE_ENCRYPT is set.  As a result, it can set S_DAX if the
> filesystem is mounted with "-o dax=always".

Queued for 5.10, thanks.

-- 
Thanks,
Sasha
