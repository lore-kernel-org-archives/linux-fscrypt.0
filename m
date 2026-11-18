Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794962142;
	b=3r/OfrbxVmftXZYAbvJhSQIOrR0pRt28U7E905yhAvWRPjS1Ef/lumEwA/j1XNxhfwbg
	 fSJxxJIlUJinR6aj1ThyWx/IGaIdueUH71NIlHoc4Q/+SYBK/jS7GfPFzRFdmDynTTJbB
	 UYQbtL58+msylwx2BP6+4Mf7F+gUCCfPob2NoQ8XFlWzZPrHqj3hcu+2MUYOfLw2XFimc
	 9tsrcBDRrJxSiPhQzace9PFIqvJWs6RJZmIcnIIZFCK6fcNwmFALQGPYwgaxmOjEcD/r5
	 dB2YGsqkAXyjLabfgSyEpwwbloqDYuN1sNCZViGYMNX0wGoOVw2KlO5Bs9VJhWLigPg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794962142;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=hqUMkp5Rr+0Qewh73PCpylQ+JwLLzC+N6hofSg1nMQk=;
	b=sahqfGbKuFJx1OmYBVKfLuX6KL6KTVHMHVmk8UrYwiEZxYwbmcwkycZn18NW/1FcRDQ2
	 k3IaRFk7W0NwYUfgTMHpfPwcESehW21e9yscSDZklSJ855CaiFBhXBzELJyaZDlcrJAHd
	 agW77B8KTP6L+hFcPz/YG8nykjEY5f/Q6xPwPY7vUeuM2CKOBzqQI2SvrraGhU9qeHJIb
	 MVoIfY2WTawmym9TuZ06tTP0KS7VjYrzrSOywIZppLuaCRQbz/7IDBLOvqTUqFdcNslI5
	 u97lLcNijasPWyuVKp8Yd70Aw+WmR3xZqHrrK0LWT4FYBjqSwAv/Kwx9jp2MEF3AI3Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aLFOm50+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B40A6606A31C
	for <linux-fscrypt@vger.kernel.org>; Wed, 18 Nov 2026 00:35:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aLFOm50+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B5D901F000C4;
	Wed, 18 Nov 2026 00:35:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794962142;
	bh=hqUMkp5Rr+0Qewh73PCpylQ+JwLLzC+N6hofSg1nMQk=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=aLFOm50+b0fEgYPxiRcmtZpBifAmzWSkgaDcAyBWWLpOCY7OLGt7P5zzzitoZJ2YH
	 5tlf0rIjLj9L2v54weomCPvFhB4paWCrz8jA2co9nFs6fRvnJWm5rP4Azm0fTkgTED
	 ZdfYGXZL7KMRJ0QEhHDnvJS7DvdYHFnYJZ0a72mvOEQBWHnI7a91bd8WiYUcDn+PLC
	 hOQxF7A6k5zQTdYsm365pkOWksPIZ0w2g74X9xllH5KTzstT0/CblFb6KGsT6RcyAw
	 8y95fe1uzCw+PH2Kjno+LQjfoya6Ho49LNHOH6/p+m53FA75oaAedJFserrgxhO9bu
	 agun7i4mVfZdg==
Message-ID: <sashiko-outbox-219856@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH 4/4] ubifs: Use FSTR() in ubifs_xattr_{set,get,remove}()
Reply-To: sashiko-reviews@lists.linux.dev
To: "Thorsten Blum" <blum@kernel.org>, "David Sterba" <dsterba@suse.com>, "Chris
 Mason" <mason@kernel.org>, "Jaegeuk Kim" <jaegeuk@kernel.org>, "Chao Yu" <chao@kernel.org>, "Richard
 Weinberger" <richard@nod.at>, "Zhihao Cheng" <chengzhihao1@huawei.com>, "Eric
 Biggers" <ebiggers@kernel.org>, =?utf-8?b?VGhlb2RvcmUgWS4gVHMnbw==?= <tytso@mit.edu>
Cc: linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org, dsterba@suse.cz
In-Reply-To: <20261118002845.574426-10-blum@kernel.org>
References: <20261118002845.574426-6-blum@kernel.org>
 <20261118002845.574426-10-blum@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Wed, 18 Nov 2026 00:35:41 +0000
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

Thank you for your contribution! Sashiko AI review found no new issues
in this patch, but noticed 1 related pre-existing issue it does not
introduce:
- [High] ubifs: missing read-only and error state checks in fileattr and
  xattr setters [1]
--

This problem wasn't introduced by this patch, but can ubifs_xattr_set(),
ubifs_xattr_remove(), and setflags() (via ubifs_fileattr_set()) mutate
state on a read-only or errored UBIFS filesystem [1]?

A stacked filesystem such as ecryptfs can call vfs_setxattr(),
vfs_removexattr(), or vfs_fileattr_set() on a lower UBIFS mount without
acquiring write access on the lower mount, and those VFS helpers
dispatch into UBIFS without rejecting read-only or emergency read-only
lower superblocks.

ubifs_xattr_set() and ubifs_xattr_remove() then call create_xattr(),
change_xattr(), and remove_xattr(), which mutate in-memory host and
xattr inode state before reaching reserve_space(), where ubifs_assert(c,
!c->ro_media && !c->ro_mount) fires, c->ro_error is set, and the xattr
inode is marked bad. Similarly, setflags() in fs/ubifs/ioctl.c allocates
dirty inode budget via ubifs_budget_space() and dirties the inode
without checking c->ro_mount, c->ro_media, or c->ro_error, leaking
c->bi.dd_growth on a read-only mount and tripping ubifs_assert(c,
c->bi.dd_growth =3D=3D 0) at unmount.

[1] https://sashiko.dev/#/bug/linux-5bb2275d-76e5-4d6a-b814-a7ac921778bf

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261118002845.5744=
26-7-blum@kernel.org?part=3D4
