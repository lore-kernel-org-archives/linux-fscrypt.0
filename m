Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795126082;
	b=iKe2lOpECrdykcRkW5Mt96bnsjYKHVFDZEHNgdtSHiEsnE4g2oCirRnuC98vEueh7KVi
	 vDOcJ1Gv8CvOFNvbKQkDQwVGaDaq5Qth0jUtNkGGa0MM3qx6e7yt+WOn9o0HeaEREduVE
	 RJtbhwAnYe0nVSQpmxfcMW7TTGC7J32bMKiZSS1jfI/i+gENqF8h/5EMB3E3Olo44vLSB
	 xQCJczpoTz6xHwWKUhoiGKunaHgffXJOXFU/S4ziYLLQ/WHxIJ/w0W1RKEEt3nRgFDjW6
	 DkVq+tm4YiyGOzm+jcIEeVbBpYEPW2Wesu5ig876tX0uiU4RythHeCHf5635Dj+qmug==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795126082;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=8/SiqAa+2qW3EAGgeQZqBwx2PB5/W55r5n3pw1Pdp10=;
	b=Qtq0qKVK8U2QsFAfGg/JQG4JkBkgVqHbcaAFMWoOrLKGgLU+4NJbSUHykBR/GfDR/zRP
	 kxJxcaQxyqrvVdAVCBM3Io4r51OiCJ5q4OjeLgkREIZTag54LX06YXOtOCAaJ5jH3+Mw/
	 uRPIVqSWJqG1MC1JttrnnChmzTRAbzBJue5CnYJJfE1NrGY8CwBYzrAH9wMz4N5q+k/1M
	 IpqpTXCwY03+WhV+0F8W4/e7UurQh/q/cRgrdygA/tbXnnISGOzpo+Ck/S7ZvuvEse0aB
	 mQaC8ofZe3Ng/y+zotqznDmSJgvX5pvqM0qctGYykz4myeH4PUkXummZIzasFrYTjQQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=l6N8jZEr;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 602F3606A325;
	Thu, 19 Nov 2026 22:08:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=l6N8jZEr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CB7E51F000C6;
	Thu, 19 Nov 2026 22:08:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795126082;
	bh=8/SiqAa+2qW3EAGgeQZqBwx2PB5/W55r5n3pw1Pdp10=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=l6N8jZErNrcxTVGMnxrrzsYfI/V2JpNFR1R/kmLATYWmAwZrrbWYG51jt1uaknPUH
	 3VZyebgvbu5WgydG2ff3P+GDZYi/nq+FayN4opF9ayhNTZUg82t0ZAnYRHvZqXH9SL
	 sEZxcUFdU/2D+ACf4c50SP+DwexwlPkv0baN0+aKJ7YA82Wf7aSNbAJU9b0m018wWK
	 +lrRHdBMI0yw7L/OeyxxYygW37KpeZCyUR0LFoMBOlrjxxu9rpmfe6YML7pCR7de2Y
	 fsmIshkuMavnbN7yIslMWKJ+nnUmdOMtCCGOGlIJZUSmnVirJdyZKH7z2mmC/3SNgX
	 t6H6E3fITVBqQ==
Date: Thu, 19 Nov 2026 14:08:00 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: shyckless@gmail.com
Cc: jaegeuk@kernel.org, tytso@mit.edu, linux-kernel@vger.kernel.org,
	linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Don't set a policy on immutable or append-only
 directories
Message-ID: <20261119220800.GA1894@quark>
References: <20261119-fscrypt-v1-1-c07e1dd93644@gmail.com>
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
In-Reply-To: <20261119-fscrypt-v1-1-c07e1dd93644@gmail.com>

On Thu, Nov 19, 2026 at 12:57:20PM +0000, Suyuan Wang via B4 Relay wrote:
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
> already set still return 0, since they don't change the inode.
> 
> Found with a static analysis tool and checked by hand.
> 
> Fixes: 0b81d0779072 ("fs crypto: move per-file encryption from f2fs tree to fs/crypto")
> Co-developed-by: Kaixuan Li <kaixuan.li@ntu.edu.sg>
> Signed-off-by: Kaixuan Li <kaixuan.li@ntu.edu.sg>
> Signed-off-by: Suyuan Wang <stevewong@hust.edu.cn>

I guess so.  Could you correct the Fixes tag and add 'Cc stable'?  It
should be:

    Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
    Fixes: f424f664f0e8 ("f2fs crypto: add encryption policy and password salt support")
    Cc: stable@vger.kernel.org

Also, the documentation should be updated too, e.g.:

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index 6e2e511a70bb5..188295f09b213 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -736,7 +736,7 @@ FS_IOC_SET_ENCRYPTION_POLICY can fail with the following errors:
   feature flag enabled using ``tune2fs -O encrypt`` or ``mkfs.ext4 -O
   encrypt``.)
 - ``EPERM``: this directory may not be encrypted, e.g. because it is
-  the root directory of an ext4 filesystem
+  the root directory of an ext4 filesystem or is immutable or append-only
 - ``EROFS``: the filesystem is readonly
 
 Getting an encryption policy
