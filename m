Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CA7C33F5BE;
	Sat, 26 Sep 2026 15:27:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790436435; cv=none; b=WoBZ0RhCCaUJ+LpVDQNMMS9Q8Fe7FYdqY3F+wo5hneWuG6nz/OOfOK/eIQWShwA93K0+lDqS/vG3u66VQxa/ERHhrIBdJzMn4nfYswX5ElOuqmQrOTGwqX365ZTaAqb0rIHbu1D6CCrzV2KGA9UhPD2teF3QhfAHHLTkBQswrY0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790436435; c=relaxed/simple;
	bh=CqqO0p1owogF6hNXfHok/PA5ctjevkw329RbVdtyngw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=BPzwefF+42NlLYUhrin745tMcEifnYeHfz9McWo0DVe4y3JxtkfCuYgwnmJ540n621+TNPXDL0lmbakg4QtIvZjgsgpg+tXK7ST0/0ZY3C+oZEZKgFrHcUFNeZLRzahtu7/6ZG1gibZykmfU5AoQuh0qLN/LKfyuQNonRpMMHy0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mXZW35A8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mXZW35A8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7017A1F00893;
	Sat, 26 Sep 2026 15:27:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790436433;
	bh=QbnY1KcZdcLSf/h6FTU94+McCURWh0TDX+JT/VqgBco=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=mXZW35A8dEa7T90iUrKVxs+ckQDjk+R6S2CN+JQhk2shIpymzs0QPrMsO3R29cWOS
	 bRGj+IEPfU5tsgnvOzxBDG2RxiOzGUFmNUANTvGp+DgaEuWiYtEzWmxZsgfX2Q6F+G
	 4JQ2SgMZnFfWNi7zFTXaMeCAH+1POeodRxzDykEdc0iwvkaoh+TtEx9kIyK8TQPdgO
	 OWEqZ5ueppZQ790eBJWYqaqIl3zkS8PhufpWkEQSAv85dLoiDoB4ENkqqkQmacxGYZ
	 tVR1KRChl7Yd4owJv9KOzRoC5af6IU1o2AO1ABHCYASw6RllaRMjTFtcb3OL8i3+bU
	 chpwqLxu4QE4Q==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	Alberto Garcia <berto@igalia.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>,
	Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>,
	Eric Biggers <ebiggers@kernel.org>,
	linux-ext4@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	regressions@lists.linux.dev
Subject: Re: [PATCH 7.2.y] ext4: don't enable large folios on encrypted inodes
Date: Sat, 26 Sep 2026 11:26:54 -0400
Message-ID: <2026-09-26-daily-reply-0001-re-ext4-large-folios-encrypted-7-2@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260925153127.1472301-1-berto@igalia.com>
References: <20260925153127.1472301-1-berto@igalia.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> This patch has no upstream equivalent: in v7.3 the code was
> significantly refactored and the problem no longer happens, see commit
> b4e409c18c79 ("ext4: Remove fs-layer file contents en/decryption
> code").

Since this is a stable-only change, I'd like an ack from the ext4 side
before queuing it. Eric's Reviewed-by is already in.

Ted, could you ack this for 7.2.y? I'll queue it once you do.

-- 
Thanks,
Sasha
