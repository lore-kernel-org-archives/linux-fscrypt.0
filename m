Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44C3A2FDC28;
	Mon, 17 Aug 2026 03:25:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786937125; cv=none; b=YAy/PtbUal9JojSZIGBLcVNssj2BiErVQ871nr15BQ3svlNGnGC2z6isaeFwyOAilq1qpbu9u0FvxveScmRIX2FRFnPQbmRzxdjuFSW2W66OXWrfQkNMVh8wrp4hBQzfvwWBT89AYiyUG2rZn93MiWrPlNH64xUCvl+lXSo+naI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786937125; c=relaxed/simple;
	bh=uJZ5jzKcSGxqZu+8iabSHHrGiTevMKi7IrlRnmZT3co=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=XXCVRptyZStAP0fHDtD8aOO2gHY4XkIdLylf+U6jdwsWkD7Uh1bbMc7ix5Pc66Ksv4JvUUE+eyIW/Aa4MixQBEtIXDzpwfk7/lTGe4C3CPWCloLWp3DtMm2rHbORovE33GNOJvsB7EtwB9cZteGMO/FdA3tGPwiRsOY84L2WDpc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=f/YkYLuX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="f/YkYLuX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7987C1F00A3E;
	Mon, 17 Aug 2026 03:25:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786937124;
	bh=vGYYtca3OsZLkHAFWAZE97PIxdPEBeyEEs0NCiHSoj0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=f/YkYLuX8EQXSgyCWBDE8dAVB9Rud3+3PlVC5Y/1Rb6Ebb/Fsd8NeV/D/hq4+o3p3
	 9DK9C8yu4zH2aoB6SDd4rIs38tskfUvMrURsv3MzvTZPdgsou068n9XamL6FTq5qV6
	 udw81GVWv7Vr5UOsbGfcA7z2lGGIaEnINPjprRfB5b1xDy9FUp7zKItzSDzp6nMSAr
	 X5/PYVTy7NknKEfgbZReGrmbRpouD51GdBPw/3gaVCuIXvP8HJJsqL//lv01IUsCNj
	 T/VC8xYn02HXeMiDuN+V3auTggdz1xof22BNqpzlJyTamebi9b9upXOxOUAvq4cfGD
	 WJI/u/VMMfdvw==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>,
	syzbot+f55b043dacf43776b50c@syzkaller.appspotmail.com,
	Mohammed EL Kadiri <med08elkadiri@gmail.com>
Subject: Re: [PATCH 6.1] fscrypt: Replace mk_users keyring with simple list
Date: Sun, 16 Aug 2026 23:25:11 -0400
Message-ID: <20260816211000.5@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260815183057.101594-1-ebiggers@kernel.org>
References: <20260815183057.101594-1-ebiggers@kernel.org>
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

Queued for 6.1, thanks.

-- 
Thanks,
Sasha
