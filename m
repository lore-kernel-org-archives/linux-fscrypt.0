Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7DA6C299927;
	Fri, 28 Aug 2026 01:46:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787881601; cv=none; b=Qj9aGAOB4m5P8AF39/KHSxBT91XkJhSOVoGc1pIiMfeILulIJg6+XR/SDr8bkBDdNjnb80X5lWT6rqYJBLgtUIpetb8w+cwmTerebl+sH3KVWt3N64tVoF+IuzkZ/vS5f+RprgpCOTpulwz1xtpMYmfhRYgyA6pQZopDQtpYQZQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787881601; c=relaxed/simple;
	bh=PlQvMmRNbKRjZDU8xnP7HjfepJzf71w4SduZT6LLqQA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CM3FSx79xENptnqipAY/peAmPWESyNEe7tWuMzTTszs7O6WQLgO+yG+NGw/Ui9GuoDRL/mFEPmnoYcsbhAdmft2QAXwRpgH6KHQ5K/Ian+blFIb0IlmKWiBQkDe3Ml0aFYArORvQjyZG8vDok1iaWhXO6M71p2KWW5LVBGRlOCw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XiSsjp5H; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XiSsjp5H"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3040D1F00ACA;
	Fri, 28 Aug 2026 01:46:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787881598;
	bh=JqUhF/HWBkcYrVAjh3oxQQSHnUpJZg+y9L7gq3V57+A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XiSsjp5HoIPYQS3LovVS3LQ0/atGgsaEjcq9HzwtT3G6URXtChhbnbZfCQjR+nvvB
	 pazNOegO07yRp9Lu1NmEDN+fJrNJe0+aM0iqZYi0Om5y1F6cdrIc8QPwCEXn17kO6v
	 A1LbsOq9z+rvdrPzC+K5J7qkXcDhQ6JgDJCqz+jS3P8I2mZWyOkxi4/SihAO66K7bd
	 bnDL+atdTVTU0ye5o5Qq4Oq9m06O8iuLaMDjO+yVyP0kJdTEIAaO8YJLlqkitO+4t3
	 PyWT5ceFfALyLY8pZaHsYL2bDIAyibhdFDsNUB0McYeCJIHdEgCfnGLISrSx+Udz1D
	 kS/k0SmLg1VhA==
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
Subject: Re: [PATCH 5.15] ext4: don't enable DAX on new encrypted files
Date: Thu, 27 Aug 2026 21:46:22 -0400
Message-ID: <20260827-stable-daily-0009-ext4-dax-5-15@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260827033833.135937-1-ebiggers@kernel.org>
References: <20260827033833.135937-1-ebiggers@kernel.org>
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

Queued for 5.15, thanks.

-- 
Thanks,
Sasha
