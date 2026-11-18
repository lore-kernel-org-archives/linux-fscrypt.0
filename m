Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794962095;
	b=iSOyqjRsEuKCbGq4RVghl3yflbpYHigRvbOdRkEK9YlR3BL/IbNIopRzTzQH1ciSlZm4
	 ztPXwUiT2ee7UKChn5x+QjtpvdE86Z5VVwn2J1BPYvgfwa/CfJ6EfgOXz+lQvYDQXnRLf
	 NNj0q3HIktVuEqm/TiBls9cQX3fK3+hfzhxQ6wNbwCYiAY1Iq31QiMwpP+ekKHH0UEiYa
	 9Tat4O+ZORG9G2HFhQiToAuHH+zGmxAW8/dLQnTPOE/JQIgDG5hzmp7SfycjVvpYbYrTY
	 PtgZd4edmx77q3uUmnJ/8r92Hheg8kKap2/s7ZsFsYQJU545PfQTLN/W+CXv9zh9D5A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794962095;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=grDX5BW3y3nwxYvdAlv8lyOrchhlt+LOaHhEjnfWQSk=;
	b=RLozyD3dH7ccKFhERCl7YAyAZ/7kpKUTGszs+EDDHs+7Y3GfFxKvMQqZ+dW4cbcr2ugg
	 rM5HlMRJNxB8xsP7YPffmZTsaUIfhEy+s3A4SN2tGLASUjKhk7gGy2BsqJIa3Q0ScjeuY
	 VxO4sfOiBf4A3rSDjz+/9YlF3BMIn22M5FPiLVTO7PlImy9XOh75xO3AalX349OSttxmN
	 Q0XkdnMnLYim22ikuPLbHZAQUOujlrOPCy0INMc7TmrCPiParmwg2fBChnFWRDN3yp1E0
	 ck0EcTVfwyGY79QdLikLZxJQvOmefDVIL56caFIceCvh6LBZokJWZ/R2JOsZuhpvsQw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=flP6NtLl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A13C5606A31C
	for <linux-fscrypt@vger.kernel.org>; Wed, 18 Nov 2026 00:34:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=flP6NtLl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D1FF71F000C4;
	Wed, 18 Nov 2026 00:34:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794962095;
	bh=grDX5BW3y3nwxYvdAlv8lyOrchhlt+LOaHhEjnfWQSk=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=flP6NtLlcvo6w68rWjQHjp+nC/w63CAflOFj+LLB1EG7zzwRao2UYoLxQCWdI7yTz
	 5RluHJiCOJuvt7/i4Z0vXXgL/Mhg4JSHunGrMGSmnMMFlw+6Y5J2aXYaZTifMiitLj
	 eHX9HqPgvexkloZ42mg72R7VzslMQj9aKqHiKGeIjefXjkbjtH6pGLkXkEs3w90mmW
	 1L0Hr0ubVZbDeV98xlGkm1/8ufNYG2dSNiJKCFVsFs/sQbx44c0x9lNL/KpV9/7pQf
	 IWHCiPHPvCJ4+I1AtClmZidpLSGkU2iqX6tP6sg1jLo5F0Z7HcqfykT6VDfdIdcJGV
	 GoglZMjh/l5Cg==
Message-ID: <sashiko-outbox-219851@kernel.org>
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
Date: Wed, 18 Nov 2026 00:34:54 +0000
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

commit b8fcd8b365f77753007ac6808d8a6b998a34c773
Author: Thorsten Blum <blum@kernel.org>

ubifs: Use FSTR() in ubifs_xattr_{set,get,remove}()

This commit replaces FSTR_INIT(..., strlen(name)) with the FSTR() macro in
ubifs_xattr_set(), ubifs_xattr_get(), and ubifs_xattr_remove().

> diff --git a/fs/ubifs/xattr.c b/fs/ubifs/xattr.c
> index 3b0e8a270f594..036eb7e2be0b2 100644
> --- a/fs/ubifs/xattr.c
> +++ b/fs/ubifs/xattr.c
> @@ -252,7 +252,7 @@ int ubifs_xattr_set(struct inode *host, const char *n=
ame, const void *value,
>  {
>  	struct inode *inode;
>  	struct ubifs_info *c =3D host->i_sb->s_fs_info;
> -	struct fscrypt_name nm =3D { .disk_name =3D FSTR_INIT((char *)name, str=
len(name))};
> +	struct fscrypt_name nm =3D { .disk_name =3D FSTR((char *)name) };
>  	struct ubifs_dent_node *xent;
>  	union ubifs_key key;
>  	int err;

[ ... ]

> @@ -557,7 +557,7 @@ static int ubifs_xattr_remove(struct inode *host, con=
st char *name)
>  {
>  	struct inode *inode;
>  	struct ubifs_info *c =3D host->i_sb->s_fs_info;
> -	struct fscrypt_name nm =3D { .disk_name =3D FSTR_INIT((char *)name, str=
len(name))};
> +	struct fscrypt_name nm =3D { .disk_name =3D FSTR((char *)name) };
>  	struct ubifs_dent_node *xent;
>  	union ubifs_key key;
>  	int err;

[Severity: High]
This problem wasn't introduced by this patch, but can ubifs_xattr_set(),
ubifs_xattr_remove(), and setflags() (via ubifs_fileattr_set()) mutate state
on a read-only or errored UBIFS filesystem [1]?

A stacked filesystem such as ecryptfs can call vfs_setxattr(),
vfs_removexattr(), or vfs_fileattr_set() on a lower UBIFS mount without
acquiring write access on the lower mount, and those VFS helpers dispatch
into UBIFS without rejecting read-only or emergency read-only lower
superblocks.

ubifs_xattr_set() and ubifs_xattr_remove() then call create_xattr(),
change_xattr(), and remove_xattr(), which mutate in-memory host and xattr
inode state before reaching reserve_space(), where ubifs_assert(c,
!c->ro_media && !c->ro_mount) fires, c->ro_error is set, and the xattr inode
is marked bad.  Similarly, setflags() in fs/ubifs/ioctl.c allocates dirty
inode budget via ubifs_budget_space() and dirties the inode without checking
c->ro_mount, c->ro_media, or c->ro_error, leaking c->bi.dd_growth on a
read-only mount and tripping ubifs_assert(c, c->bi.dd_growth =3D=3D 0) at
unmount.

[1] https://sashiko.dev/#/bug/linux-5bb2275d-76e5-4d6a-b814-a7ac921778bf

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/20261118002845.5744=
26-6-blum@kernel.org?part=3D4
