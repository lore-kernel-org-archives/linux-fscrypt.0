Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 217783BB687;
	Sun,  4 Oct 2026 16:30:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791131410; cv=none; b=hQDQ/YP7RfJT6kOJ+eSGcLn7JzgeCMQyAJmT/x49X9gvYxqHGOcaGtCyhu3G8UIMHl5EOnKhSkdIucIILq4mJDQQi9A77u/+DcI6UoVcan+lvk7Qv4Dtr5PkF3MCdoQ8mLjBUM9ktcvnInuebv9wy4uuZLkmq+aRm5N27ZT0tzo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791131410; c=relaxed/simple;
	bh=YQ/ACaHRosvg4SG0+znIeowOKSMUx8BG0j/yARPxKjg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Vp19Q20v9n3eVLxMG0BMyvnPgdl6pUOArQ9aNrfMO9DdVMVbzSEmqdAS0cWNi6rYgXEVCda4itCNDOqzUp+sNDyjd7ROzeHmCNdgjwKxypJpfsFrhwObhip5LhwWuV/CN/KQ5BiVHbJufR33Pjrpqv+qR6105NnOOtbkdhtypTA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=m3qREAR1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="m3qREAR1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 83D361F00893;
	Sun,  4 Oct 2026 16:30:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791131408;
	bh=abwvW8pd8aknu6JYFlkRnqyJB0QZztdntdoOlO4ii6U=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=m3qREAR1xjmdLcUNWSr3z2ZzGJrbzYuLSXdCIQI1dypOaINyWFhBnmHW9eGeYTDZt
	 0qqT4AoqRGla4jurHCNn+ro1Qai3YO9AseWRoTai3NWIQJZiX9ZDGxRrYVMPueLUNU
	 3I/InZFF9opDnAtYVjcYZf2Mg1A958PvZ5NXxJCXL4mpeZhHn1luLJTyppzXq4+8QY
	 K2AKwE3MU7Vgng2TD8so6su2m/uLglbSA2SYSrjWIe4g/YzALXDy8Rk9WiugO3IEyZ
	 kUk8TV+hehpFdU0hOR4CdgYy5WgerH/5IrjL0m/YDGs1K3cT/IQ/T/vRPTGr7OjZ00
	 azYB9jcYS2Nmw==
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
Date: Sun,  4 Oct 2026 12:29:42 -0400
Message-ID: <2026-10-04-1-daily-reply-0004-ext4-large-folios-encrypted-7.2@kernel.org>
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

> Fix this by disabling large folios on encrypted inodes, as is
> already done for inodes that use data journaling.

Queued for 7.2, thanks.

-- 
Thanks,
Sasha
