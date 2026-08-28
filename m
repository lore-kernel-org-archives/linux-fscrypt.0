Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76722307AC7;
	Fri, 28 Aug 2026 01:46:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787881599; cv=none; b=OzyJW5cA4lssUTawKCGW3qQL8//ycNITLojdTOtN5GFIAiHAKJ3BsU+y/ADD5Mgy2pmfYr0e7qcBd0bvF3Q9YcbUIrWjOInZDaSNmYK2VpUa1Q6FQvaHb5lfqHiqVUC8f5ziID/adFNFdXDTNdNWcL8oOEG7dRKA1KVn6SJRS3E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787881599; c=relaxed/simple;
	bh=iEsZqn+XWqlhJ9rwbPm5N6paUN0B5ERQ9QKwXdZZzKY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=nFuNagmnsSLZpTucDRAwXHRAXF9A2uqbXaaFrL7gNl5pF3tcxt7DefaSA5qBOHGGKvOWLOlI7moL4F0pvPhi5nJzkzGy4q9AMA6m/1cK8bzU9hacEQg8BWgs0MjLh2SGDvE176F7aR4hbuLMymPZQeYo7PYfnrB5tPz3OsL87iQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fwh1HqFa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fwh1HqFa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CA51F1F000E9;
	Fri, 28 Aug 2026 01:46:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787881595;
	bh=pNGJHhIXVxYxmgJCk+uDLn44MhxqSdn0CIlCukn3f7g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fwh1HqFavPSO5oO6qyJmo7thwNRGdYReUQaVwr/WibOz2F/xEHEQdizaWMUnZBELS
	 1kUjdZIZERDWvqr9iWC/FqRoU8LsYvBsdZSDZbDGduCaTUAMD3aY3kZrRTXd1BVle/
	 PTvKUqDo3o7kzmSgjT0NR66DBTYyxtXE8emFU1if2aF+Sg74B6uYSMKmczl5AGGSiP
	 X291wECCgp2dsgEm9EPrHqwpQv5Vyt7rjuzm9ppIL11R/cAMxvfgQ77Wk0W2ziL06l
	 bJ/es+nyRGYQL4Gtqu1z5/iTRbYOFDR3B7QSsZrObDm9+cciFVIiNN0nGCeWfob1BB
	 9b5niuOCiFhfg==
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
Subject: Re: [PATCH 6.6] ext4: don't enable DAX on new encrypted files
Date: Thu, 27 Aug 2026 21:46:20 -0400
Message-ID: <20260827-stable-daily-0007-ext4-dax-6-6@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260827032857.82762-1-ebiggers@kernel.org>
References: <20260827032857.82762-1-ebiggers@kernel.org>
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

Queued for 6.6, thanks.

-- 
Thanks,
Sasha
