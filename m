Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 524EC5733E;
	Mon, 17 Aug 2026 03:25:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786937124; cv=none; b=blpbc/lF07+dhhqo97aRP9MTg6Y4SYMjNQda9b50lvmJM5IglJxiTR9LY6JkJCfLSDevCjexcWFr90EgeuQvSO1re/Xck9kbMjy1qY4zCG6H0XTSAISAHUIsPu6jGPXfpQMwadHHgXHqJ7y3t0KCIBVxrB6+9Xul+h2H5vrD4xU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786937124; c=relaxed/simple;
	bh=rXAw6C0kINsbtOtOO/CgdIQ3saE0HiF55eOsWt0q7Jo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tu2wo8naI6Wu7URffyIlRX0tFWv0K/4Hc19VCCT42N9JMBTeQmlUSUZ46eM6ber5iQLsn5qChkGyPVL7SV2QmnR0c36VELzrErr7Rf/zzbIx4JCRKzdfCdPYKfzF5lwe5w5Es/re7pE5QKQjwlcmxkC/KO79SHOFlpy/eGY62aA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NnA3omT3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NnA3omT3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 860F21F000E9;
	Mon, 17 Aug 2026 03:25:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786937123;
	bh=craASOyF6hTJdsisc6ZAWmFlfeWlY+kOXRvgiiaLn54=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NnA3omT3F/5hCM7ku/BXauYdyPLqLWo7q0x2yJy45wJ6UN3Bs0+ajH3lCddo3mIb8
	 NHrHwXuKdmdkXbyoajKY7kTvXT658fucui9sgYHGXPH5UMyZNxtzlqHekZwTRkrQXj
	 xTYqF78GAm4dspeuuT0ucVCadCZFCIJgSdNElB3dXxy7ZINB5no2WqMO7ygj/BTXex
	 4bS155kdJz4cpI26mT1cBo9gUZ5QVyBwJM/3HCdNypHtuI5zCfeINxV+tdv94Q2VLD
	 GCn2ahgNFhVxLiwA51TNhpK+0WfEzNY+WehqkjHwLcOPqHTxMkmWwjlCG5mGQg11t6
	 wjQ9PRsvFhD8g==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>,
	syzbot+f55b043dacf43776b50c@syzkaller.appspotmail.com,
	Mohammed EL Kadiri <med08elkadiri@gmail.com>
Subject: Re: [PATCH 5.15] fscrypt: Replace mk_users keyring with simple list
Date: Sun, 16 Aug 2026 23:25:10 -0400
Message-ID: <20260816211000.4@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260815183126.101678-1-ebiggers@kernel.org>
References: <20260815183126.101678-1-ebiggers@kernel.org>
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

Queued for 5.15, thanks.

-- 
Thanks,
Sasha
