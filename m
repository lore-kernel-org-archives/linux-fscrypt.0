Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 23BD0318EF6;
	Fri, 28 Aug 2026 01:46:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787881601; cv=none; b=j4HSrK+OoboWELu6bvnRHrsrPAiXKle8b5Cz3T9ENRCARXW9q0n20tBvWD2MI/Hcx1RUcYcbIixBAm5tK11zXC9ytCIj3aSVpDnxvOObwhLBSToYbBW7MhG4Ld5JBI8rMRIDb6ZlfO+TcRDb5T0KMnv/4oyozmktYYSILx83o3s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787881601; c=relaxed/simple;
	bh=+j17+F5ltHbIaOHEDSw1lIJDw/Nn7SgLYTq2rDb1dnY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AShyFVV1Nf7pblxUZH3A9sHbpirmrDJ2GBtovkJwkFdhg9vwSoW++pT0kFg690Y1j9LGKVgusWPrlCk8rBbD3Xk1rJofn4yMyzLuoeEH+ddC8CJynuDVlOZq60WHNsRhlvJPj0Wo27JdJrKI7YquFRn5vDE/RfEshje0b9hIR18=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=i6RFLdHp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="i6RFLdHp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 034C91F00A3D;
	Fri, 28 Aug 2026 01:46:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787881596;
	bh=xYH/EDKbIFfdlkfXs+sHufveN6nwPS2De+QaIzlWMeU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=i6RFLdHpNHpHb/cIdsXaHD3+jkIA4Ixv8HKV+kxTBOawbuhKmRa/sJU7znQOLlY/A
	 JrnHNhtYlY92tV5zOQCmhO8GeSGrN8oiIdnY0YHSH9Edvi1/sMJpARr+xQeOkC9JNi
	 moY+6CkGzGnRO+UUld7+prejN76UDLrvzPeBnOJvlxhY61qWrQFyYI2HMWQQkARv40
	 TCQ/RJPNBtecI8QzaAl5UMn/K2W0fA3c68DMHSSxOtx2HJ/6lGm5fa/G4Pa51x8+DP
	 XUZO4Ytv0/eFRijNMQUx8329ChVtifKEB9Ah9vbPrhUBeSkzrkOBk2a6iYkvmigSmG
	 VsdSlkpzQPuZA==
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
Subject: Re: [PATCH 6.1] ext4: don't enable DAX on new encrypted files
Date: Thu, 27 Aug 2026 21:46:21 -0400
Message-ID: <20260827-stable-daily-0008-ext4-dax-6-1@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260827032917.82878-1-ebiggers@kernel.org>
References: <20260827032917.82878-1-ebiggers@kernel.org>
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

Queued for 6.1, thanks.

-- 
Thanks,
Sasha
