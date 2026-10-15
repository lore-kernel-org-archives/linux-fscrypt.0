Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4866D37187C;
	Thu, 15 Oct 2026 18:35:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792089353; cv=none; b=pDcvCOFyicVAMG0CMUrReQbc//stF0EYvwkem6TYeDh6cgluudCvHZPoVdYYmTgx9B5hgD/FAsiO/UR1R4oRmgRL0Owj2UbQ5zk7OaClhy/6gMSEexVp3kB9pHM5x827o6UYTNgonCBzMdgYTkXL1U07DtXpMrWvGaycH0tN/6c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792089353; c=relaxed/simple;
	bh=PgilridrbsX1FD+B++dHlE/QkecVuvuNNOJkor0MveQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=hh9gZhfc6WAP1gd0cTA9MA2bX82FbzPkm+pfTR2uNCnUndybNnXvIEbp5OqsSTZqWjKvynZNSS+WxIbuqHtouDm/2UPgWjKuPN07PfyoGj9if+KXW2480GM0DoWfyQdzLGqAWglBcQ9N5KSdekxeRg2a2Tz1KE3uM2ppZy4Mz+E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=or9vv7b0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="or9vv7b0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6312E1F000C4;
	Thu, 15 Oct 2026 18:35:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792089349;
	bh=7ALLbBDzqNrieL0NuGOfMVmoGTKaJAvR3J1DurpebBs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=or9vv7b01AP5M0f/NeP+B1iQj1ONyjyFrORPWECbAY65nUWmesOVHOtG9uSnscUHw
	 NqCo/dT3ooNiqYQlSTGFzbJq9Tx0L6rlfDLnchqqm+5vZjyZNp9fcrX2YV3vGgVnrm
	 AkflbiKVdnUXl7BV71lfMIGrH1OWeJFiKHFgSoUoURajeE3/RnHv/G6koLjVFE4gJD
	 lkTfWWwaqM4yL35/dppK34NlOQFnJggy2EP3zRE5gm6Pp6jOKiMTc+DnwE/EXNIICC
	 9P67nMoIsoZ78BGD0QGJS+0hAseL+G650SpwyH8lYqlwMzO+VoA0AW8Z6xe4EcLdEz
	 RsFUQRRSJGv4g==
Date: Thu, 15 Oct 2026 18:35:48 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Alex Markuze <amarkuze@redhat.com>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Ilya Dryomov <idryomov@gmail.com>,
	Xiubo Li <xiubo.li@clyso.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fscrypt: allow filesystems to disable symlink target
 caching
Message-ID: <20261015183548.GE2170687@google.com>
References: <a01d0a297a3e174d21741a3ad586ce546327603e.1792081664.git.amarkuze@redhat.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a01d0a297a3e174d21741a3ad586ce546327603e.1792081664.git.amarkuze@redhat.com>

On Thu, Oct 15, 2026 at 05:46:24PM +0000, Alex Markuze wrote:
> fscrypt stores decrypted symlink targets in inode->i_link. The VFS can
> use this field without calling the filesystem's ->get_link() callback.
> The target can remain valid after the access policy changes.
> 
> The CephFS subvolume quarantine series adds access checks to
> ->get_link(). Quarantine can revoke access after a target is cached. The
> VFS cache can bypass these checks.
> 
> The no_symlink_cache option in fscrypt_operations gives filesystems
> control of this cache. It applies during target creation, lookup and
> getattr. With this option set, the helpers do not read or update
> ->i_link. The filesystem callback can then revalidate access.
> 
> Uncached targets use the existing delayed-free callback. Each uncached
> lookup allocates a temporary buffer and decrypts or encodes the target.
> This lets Ceph reuse fscrypt's target validation and buffer ownership.
> 
> The default setting keeps the current cache behavior for other
> filesystems. Ceph selects the option so cached targets cannot bypass its
> ->get_link() checks.
> 
> Signed-off-by: Alex Markuze <amarkuze@redhat.com>

This sounds like a bug fix?  If so, which commit is it fixing?

- Eric
