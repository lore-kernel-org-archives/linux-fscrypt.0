Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795561688;
	b=pTTcnbvKBOxHS+W01gbmnKB8S+FRmJ8EW3iU52nx7nXZxhnLmHIr5EcHV39YLpdwyn0y
	 ooDcDsWl9apfSlXh541UyyT2GmZPKjelcEMwvXdzQzMNBF+4JgXZFDMTpkhBWZ9WD60Dq
	 w23C0g2SQTIbpsGIzqfpkE4gffG9VeNPKOxpj/Jr+V7r46F5VG6sVAAsk9BXc9ud6mSxp
	 p0utstp7VXit55Vc+slVFH5B4mdzM2PqgEaje4LnqNiyi3lHvy4KBfbbeFA8Zh6Nz8Mqx
	 KxUHpdQOmtV6oQ1HKZv2c4nFPmiKwGRjY2qN/448j6/DOAA5OTbQHpwAUAIJT0uRUdQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795561688;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=ZqBd+LY/nH9rOSDDR+8c8JRkRwL6MGqZxGOrRjKuZz4=;
	b=kcQoDESEyv1S2AIbbM4h0s7EWANe19uxn/X+GBx28hw63UWIs2Y5UxCLezMScEbIJT3u
	 L/JLkbPhuJMDw7/P8RF16j+/RkQOezV/Hl0BharuBftvWEDnP/X4Sr6u+BEjpGWEeQ4bM
	 oqW/Qp7ZFq7AUsuTJCkTnPiL3z5wBjsvcm4Cq0DMakpHBhaqYxUVOUlnfm9kaomjI7XRS
	 EGGcrgQpHssCdDDqBfhR4UhW1EsdzjXkfoakB99WU12GR17IbJIu3cWKV2XtCX61oblXF
	 1yxqNx+3wpI+EneZibmC0hAAftieyUbnEJMoXOkKDFqgKSbs1/P5IoFxY4/ztljF4dg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NZ9hsF3r;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5AF08606A31E;
	Tue, 24 Nov 2026 23:08:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NZ9hsF3r
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 815F01F000C4;
	Tue, 24 Nov 2026 23:08:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795561687;
	bh=ZqBd+LY/nH9rOSDDR+8c8JRkRwL6MGqZxGOrRjKuZz4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=NZ9hsF3rLHhd71iRl0/RHSANC/kVgyrJYwj/mYVdwjiv8RznwHRlHDU6DqE/jLnnQ
	 +aybbeFcV28kgeeEm1qg6/4J9Vbrlyxa8AEbwKq1b0QgPcaFgWT7bqirtVeN1xQO4N
	 GBVBLtjuLXK4+6fa06ovNhyrTRKswxAIkLZUYQ1ckcsK3lPijEtOIz9niAzxvQcqqZ
	 IqwqKvXpWDgZuxD8vJUpGDdeunoOGcN0itWt8XgiEltiIb72eJnxBRE2O8r5g6Sd9c
	 1nC41UidJWx1JNCi1g1bzWXYyfGFN1XjpCG11jqzi2cqIpyWP3f8cACv4n2xwgORth
	 h1pGlFi/Oywfw==
Date: Tue, 24 Nov 2026 15:08:06 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: shyckless@gmail.com
Cc: tytso@mit.edu, jaegeuk@kernel.org, linux-kernel@vger.kernel.org,
	linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH v2] fscrypt: Don't set a policy on immutable or
 append-only directories
Message-ID: <20261124230806.GA2001@quark>
References: <20261120-fscrypt-v2-1-fb752135ea32@gmail.com>
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
In-Reply-To: <20261120-fscrypt-v2-1-fb752135ea32@gmail.com>

On Fri, Nov 20, 2026 at 04:26:54AM +0000, Suyuan Wang via B4 Relay wrote:
> From: Suyuan Wang <stevewong@hust.edu.cn>
> 
> FS_IOC_SET_ENCRYPTION_POLICY stores an encryption context in the
> directory (an xattr on ext4 and f2fs) and marks the inode as encrypted.
> fscrypt_ioctl_set_policy() checks inode_owner_or_capable(), but not the
> immutable or append-only inode flags, so the ioctl also succeeds on a
> directory with one of those flags set. Setting any other xattr on the
> same directory fails with -EPERM in may_write_xattr(), and
> FS_IOC_ENABLE_VERITY refuses such files as well.
> 
> For example, on ext4 with the encrypt feature:
> 
> 	mkdir d && chattr +i d
> 	setfattr -n user.x -v 1 d           -> Operation not permitted
> 	FS_IOC_SET_ENCRYPTION_POLICY on d   -> succeeds, d now has a policy
> 
> Return -EPERM for an immutable or append-only directory before setting
> the policy, as may_write_xattr() does. Calls that find the same policy
> already set still return 0, since they don't change the inode. Update
> the documented EPERM cases to match.
> 
> Found with a static analysis tool and checked by hand.
> 
> Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
> Fixes: f424f664f0e8 ("f2fs crypto: add encryption policy and password salt support")
> Cc: stable@vger.kernel.org
> Co-developed-by: Kaixuan Li <kaixuan.li@ntu.edu.sg>
> Signed-off-by: Kaixuan Li <kaixuan.li@ntu.edu.sg>
> Signed-off-by: Suyuan Wang <stevewong@hust.edu.cn>

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
