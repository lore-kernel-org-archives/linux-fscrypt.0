Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 388955733E;
	Mon, 17 Aug 2026 03:25:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786937126; cv=none; b=u5fvqvUXH4on8y0zt6BfQX/XAQ3oV/FrFLYZK5ycHClfEY/gE9Wr4R3/0po7adRTmGVwzqkJ+XrkSVJXuiHDEpMqunViNe4OhZEAYoQbM1aqwQXKO7zdIJKd3Oz9fmdr9Q6G83huFYKtgGVb/O6WTsjVotc6mix12QbpfrBaojA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786937126; c=relaxed/simple;
	bh=2No+7i92KPOymKFBsQEvabAxWCRmWUNHCzG28ZJf6Cc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=cvugZXVZYpaI6lgYN22R9xvVM16nELICneIc0DOfHCjgdf5/uh1230PgkEUD/xJb/M9Rvxt7BBYBr8Jlw4a2NpoQBch9fCwaGh6vUvjCkGtodin37CMyB3vdGkpeS3WkDVIFCCWJi+eH1lNPEKzw3uWauz8OfvwcKuG09irgCP0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AMdMBCD7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AMdMBCD7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D95C1F000E9;
	Mon, 17 Aug 2026 03:25:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786937125;
	bh=+3830YA13xeBm39INPBFWNcFZ889LeEB/pCPAMFxVJs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=AMdMBCD7Pd8sva9jvtNdvstemi3xk6BTeVCQEWKbvDyAy3U/ckUaf2q1womYupHU9
	 FfGmgvSgjSV7tlXFnOYkWlu5MNOd1u+DHjX3ZrtLBK+NH+OngoAcgG32NWDy26WRzc
	 Vt+DcVwKMDAVWhQy1zeRqx6dlzcSSFPDg3f0VE9vfRjCIFHFWuW+X8H+cWMeHKIWPV
	 SZ1dppxLHGLNwvH5KWajilIGT9UMNiL9l4hbhY8g+xlDJdKn9fe8aWKnwlQjzb5q40
	 lpm7OAQLN7aTi5nEB8PIDZqXDGnfUJAE1+2qQWexdeXsYFdQ5oIsVtc9OQnLyOUnS3
	 BfZ50f0UqltEg==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>,
	syzbot+f55b043dacf43776b50c@syzkaller.appspotmail.com,
	Mohammed EL Kadiri <med08elkadiri@gmail.com>
Subject: Re: [PATCH 6.6] fscrypt: Replace mk_users keyring with simple list
Date: Sun, 16 Aug 2026 23:25:12 -0400
Message-ID: <20260816211000.6@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260815183036.101530-1-ebiggers@kernel.org>
References: <20260815183036.101530-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> commit 696c030e1e3438955aba443b308ee8b6faa3983e upstream.
>
> Change mk_users (the set of user claims to an fscrypt master key) from a
> 'struct key' keyring to a simple linked list.

Queued for 6.6, thanks.

-- 
Thanks,
Sasha
