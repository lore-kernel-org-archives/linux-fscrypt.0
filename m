Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792972257;
	b=c6IH4MEQVWjxA6Q+CmN61Si3yvBj+LYQvR0D7fQflrNJraBuTZ7VfItG9LR635dg+EPQ
	 i6mGzmXqqRtQh9Kw73dffUGFsJhB9PQOMqOyAN7/soQb9RjVUpL9vDxFzDvw07jYBn93Y
	 HL7MH3HIYb8mWkztlovBYiEaYKYlfHho89raTyZOzmXyxdnwxI5BU0tcfeflRWi2rT8U1
	 fs8RjnbpSZ68OAeRYXImDMVjT32e7bqJkWSS8CcaLbTwkt2SYI+Bb4THeFAkrpY7g46f3
	 ejmttM4zfhnjm+87AZKrvpKmK20n2nKdaodrR+FfABS7fbR6v0qC4HLRu7tx1fvOeBw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792972257;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=7JdNRiIZP8QoKhgXwxEL9cPsxZanNaIMVve0+TXzYFE=;
	b=rDRKU25u5AY3vTE2WsvIelfdfKrbe7mi7ysrchdqM5tIfzcE7Z1slt4NTlfBabDArbS+
	 GKnwkF0jMPX1zzAm339mp6XeiQC0iYSaed75GssNQudDn9KxpanOtBw51/F6+R+JX5P8T
	 u90poPfvwLNRW4QIR9laILSY2QQagnQ7K/zriEx4mdq8lE+YuR2WPST9uA/9X1CrMWV/x
	 9XTImibkud0rDBVQ4xsI0rcGzXDuS4ZMNR7yH6Q67efMFFsjYritfU8umRzat/2vB56sM
	 lqLe5dXc2Q3jBM/+WRTpOL/x/M0JBhcTb/z5m3hd1NWdha12BzuMC9UHbA/z5eriAYQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="bUg5/xVa";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A85E0606A31A;
	Sun, 25 Oct 2026 23:50:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bUg5/xVa
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 435591F01825;
	Sun, 25 Oct 2026 23:50:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792972256;
	bh=7JdNRiIZP8QoKhgXwxEL9cPsxZanNaIMVve0+TXzYFE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=bUg5/xVaUySv6itNPSThMbVpsdhq2M4MjnOkwh6MratZzXr0luk6JMuDTs+gL2KiN
	 d+M86MWAFHetxR2NYAov/+SXI4Fws2a+pcXiiYdK2zX6ipz60Vf+IkhoKJ7R79SbTS
	 8ZLqH0+TUEt5TYg38vRFMkF2dFaOpNa8s8vAD+FeGxT/eC8H+ydzWNAfOhDUz1hwKs
	 wlQMp2QmWngG+a8cxKOqyywENRhQNOeQkTUElk1lsp3stIygYfywg51V1cMUgAnblg
	 beSoRuO1owl/NyaMzBpk6jocWzJQlJnd36fsJW7/BPl3cV+372b8Qsde64OEfVNmAT
	 8BknUf5NIr2eA==
Date: Sun, 25 Oct 2026 16:50:54 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Joshua Abata <joshabata@gmail.com>
Cc: linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org,
	tytso@mit.edu, adilger.kernel@dilger.ca
Subject: Re: [BUG] ext4/fscrypt: memory corruption after enabling "encrypt"
 on a mounted fs (large folios + bounce page), 7.0
Message-ID: <20261025235054.GD148998@quark>
References: <CAJoS2iZ6kKLDqs0cib2=aXn5WMXH2HmK3D+KZaVBN0mXiv4yQA@mail.gmail.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJoS2iZ6kKLDqs0cib2=aXn5WMXH2HmK3D+KZaVBN0mXiv4yQA@mail.gmail.com>

On Sun, Oct 25, 2026 at 04:41:16PM -0700, Joshua Abata wrote:
> Hi,
> 
> Enabling the ext4 "encrypt" feature with tune2fs on a *mounted* filesystem
> and then writing through an fscrypt v2
> policy corrupts kernel memory on 7.0 (Ubuntu 7.0.0-38-generic). It
> reproduces in seconds on an untainted kernel in a
> plain QEMU VM; the same steps with an unmount/remount after tune2fs are
> fine.
> 
> Reproducer (as root, any 7.0 x86_64 with ext4 large folios):

7.0 is no longer a supported kernel version upstream.  It was not chosen
as an LTS kernel, and the last 7.0.y stable release occurred on June 27
with Linux v7.0.14.

This sounds like the bug that was already fixed in 7.2 by
"ext4: don't enable large folios on encrypted inodes"
(https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/?h=linux-7.2.y&id=40554d1221e3d2ff2e0d192b74a05d89eb3620e7) and in 7.3 by other changes.

If Ubuntu is using an unsupported kernel version that is missing this
fix, then you would need to report that to Ubuntu.

- Eric
