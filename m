Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 863B137A84F;
	Thu, 30 Jul 2026 02:40:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785379251; cv=none; b=suHvIzODugyzPFJcHy37swUd12H2Q65Qgz1JhrE02TzRwAf01/3qCNMwlbfCEJ2kD3BP3lPb37UrZL/XFXT2xueQYdWscPNtqMI7yrDmxUHX1JHaWJAVsh4zZM4NGH6VUVDBKUDWFZXPmpaauwDLt9hYyzDSkTwFAMRYk9Im5bQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785379251; c=relaxed/simple;
	bh=0v4gaqLSEfSxpFFx3fgC2V1HM6iJDKQLIoC5brxTAEo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gt5QiA8+/QgeG2YZDJVyX7uY5fWgrjCvCpES7M2QIT41niakY0DHI7V0NaG2wpIexlM3GqB+AGcdZaV8xKqDGiuhVrua+omX3CP1Mu9+jaeGMVU6moQk3O5hWAWVSJ5CDY98pEkbfTwDhmkv1TZhQ6OUamyN/zapt2G2eBBuCKQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RKq88Jkz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RKq88Jkz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD3F01F000E9;
	Thu, 30 Jul 2026 02:40:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785379250;
	bh=BNu5iISkcG9D2S/l7dIP4N4/XYpV3KmbdmWedHV+BX8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RKq88Jkzrut6rvXUWrGMASoqoylx6esM56sfsxznqC98GWRr0lvxqBbNh0YqjYBIh
	 D7hCEDSP2XyEcPtwB2F3llzlhhb/uKinx91FaabMmdSN0C+Ictmpg4F1nU3YnWodpG
	 KCddKeYvIUByZrOi6dvog36+di1Lcu3aHUp3ZdOph5jMAFtFlbn0iL0+nUhwsirrow
	 /yCsVQ0gVakEdSu6HZZ7AHq8CyxWYo3EpPBGuLoWOEjvqGzDHpBD+1ji49cDo+Jile
	 /17FS5YM/TVMX3mnKbAlNlOR6+btdrp4VNxO+8QX5TVmfk6ZJRCgFrmTFsl4EP1QgM
	 OMiKWpWHNefCQ==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	Christoph Hellwig <hch@lst.de>,
	Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 6.6] fscrypt: Avoid dynamic allocation in fscrypt_get_devices()
Date: Wed, 29 Jul 2026 22:40:16 -0400
Message-ID: <20260729223316.stable-0020@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260729152539.21888-1-ebiggers@kernel.org>
References: <20260729152539.21888-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> [PATCH 6.6] fscrypt: Avoid dynamic allocation in fscrypt_get_devices()

Queued for 6.6, thanks.

-- 
Thanks,
Sasha
