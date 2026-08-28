Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 875FB31E82E;
	Fri, 28 Aug 2026 01:46:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787881600; cv=none; b=pPHg9vhMQoXYkheWEZN2clS//5jNTOgJoeLr7hm60dG1TZ8vMopid/6GwXqRYzscaEk/scTbKFCu981YfPqC5H3xvYGxLBntuai+wesdO9BogZ4cRjI/381huj8X6dBl9G07dYlEA7hg6ZpvPq+e4mke8rzNkq2zOwaBJWLY1YI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787881600; c=relaxed/simple;
	bh=lK58cnrXdhpymFsRurLiolPM19KkMbP2Il3QwmrMe5s=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=RsvqouiJmhWL9/c/93Ui5y7dDlRiwxZw1KgCqOIaXZvxgmI5mzSqtUIhBQ+BZjnSGad+kDtdMClilUmmCJD8wy/76TAcCJy5lczV3amy5Nau3LodDbVLYFrMyJuEyt2z7KQPokrhmVLJ5Eag2eCXt9PutPdFbRlRrrOfeVEQOuQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fCNytTo/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fCNytTo/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9CFB71F00A3A;
	Fri, 28 Aug 2026 01:46:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787881594;
	bh=YZZjxqcJ1Tb4waHVFpFK0i9VQxELjQf/LvCiVxf0j0s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fCNytTo/OKc+IKCDeY8859fjmUPuhERTHI1zDzzrcmCgumieIUgWB8tZ/a60wiOCI
	 5wfgaUXPmvB5KLe8+GHl2eIbRO5WUVOwBtXrAQq3xg5JeaOtb24fCWoCuQlN/sCyG9
	 2AbF/ANkMugBaZsel8rs6WBPjPx1q18dIBRCRXKI33zH/c0PJ8AImuoSJDMVyFSCUn
	 2xeoUzJAY6Eqtzz1qAnqamm07c7+CvjopXikwfOA/Gao5fx4HWX0xrRlldAAGJErSE
	 ITX+odyAltqIXyq2jy1Kd9H1KjMkbS1EJqkegckYv3eiXXTMRTixF5elkgkzu4sVQ9
	 9IuRhKArTTGsA==
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
Subject: Re: [PATCH 6.12] ext4: don't enable DAX on new encrypted files
Date: Thu, 27 Aug 2026 21:46:19 -0400
Message-ID: <20260827-stable-daily-0006-ext4-dax-6-12@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260827032815.82363-1-ebiggers@kernel.org>
References: <20260827032815.82363-1-ebiggers@kernel.org>
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

Queued for 6.12, thanks.

-- 
Thanks,
Sasha
