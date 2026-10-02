Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADF09449B2D;
	Fri,  2 Oct 2026 21:10:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790975450; cv=none; b=HteAnO/PzeL5uE3LdwqlhK3yUJFaCmnuVRdHPLrxNZAriZJ3ZlsYueAM+DBzlbfga0jTdRO2LkrusP0WxrpmtryT1eerxsGtia/BYKHlMlHjPkTx9aXmVjKtQQ2lnSQoRBMdXsGPo0jc+8hWiy1vcxnxNFNzhItChmrp7yL6OrI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790975450; c=relaxed/simple;
	bh=SrKfNWdFX9QO3qKHwe4md9wCOU3HIa1H+xTL5qrw93I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=f+iL5Y5BUjOKswfrOHH5lzb526okk/ShCN1oN9JYGXpz7LHiu+bMs7GefEDExZJmWmqmWe71gQi8tBSeBX/x6hlAitzZxYnC//F3pplqIhBTDTofYZsZsYSBXBWjRfuywruL1xOSuL4QByrVnhmm6BeGpBTqhnzggIUh5anEXYc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hhJpR/zs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hhJpR/zs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3B41E1F00899;
	Fri,  2 Oct 2026 21:10:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790975448;
	bh=qIfnkHrSDkFnNJUukcuzLEYA0aIjMFSXwuEbnQl7XNQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hhJpR/zs/aUGwbYk9OaWoOxUl5CwLBOSHND8TMc+iSzkWFDMQC1Q1X1Ie4aXpj4pD
	 Y0cMl8IBGaDYxw+Y90YrgBn25JFcrQ6jaIKGrD1IvKGSQ0/mFXNP1oq/DvQmdEK6Pa
	 yCn/jwFdi4wrEI32Rs9yy+t1Ygd0V+BEg4PxwZV8nuYd4gQu6ZqA249MCSOkEQrrAT
	 sIJLn1UER/LDsgVf5fctSEi9V5xYKdbBIzCLBbXol8Du+VQhFsL8K/TlVeJZRg/YQ5
	 L6H2qBBsN5oXme9mxN0mGJWMECDm+XC2wqxIj5TxTNbUlW+1xvF7VyrUSs8Aknmc0L
	 OfJXL9Hp56Zgg==
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
Date: Fri,  2 Oct 2026 17:10:35 -0400
Message-ID: <2026-10-02-1-daily-reply-0009-re-ext4-large-folios-encrypted-7-2-ack@kernel.org>
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

> This affects all kernels between v6.19 and v7.2 but only the latter is
> still maintained, so I think that it only needs to be applied there.

Ted, Jan, Baokun: could one of you ack this for 7.2.y? Eric has already
reviewed it. If there's no objection from the ext4 side by October 9,
I'll queue it on Eric's Reviewed-by.

-- 
Thanks,
Sasha
