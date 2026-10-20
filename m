Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792512341;
	b=g1qe7TgJJ/RSh7kJC+siY/HhKdouDRxhfpk77K3QjbVkwPEUiEDl0zPgp+M4JezZ49Og
	 DhP2XXfrt2nGZqYHFR5rZfuhuhdaAIMc3LZIM6MUGfgFKWwtl2fj/IaorgMSWDCsvaBcW
	 hgO1t5Fe8GR6hoGpHn79lVnGkgngP0DekXqhWGkV+wItLqtmjxO/lq4Osn7iLc3ePBObF
	 9ZziiIDu7lflQGs8EhpKyuulOTIiV7odUCBVkBYvnU2yAO7DdXEdReQ7VdswHWXhIpskE
	 R46y99TsRHBah822ZovSQiCRhXotjYzRBT6mG4NdveDjFaxpoCj/UvEN+RNNPU3g1Cg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792512341;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=whcq1B+VUUWMMaFEgT3Xk0MHrqFosIyFhnSRUMDP22w=;
	b=U5YFcTrr6JtrTs7IBmQLfYB2OdXRLoxOJGfISxOKfYKZVPIU/9jZUrMX9pRlTIzIqHEH
	 +d1GV2v45CChhdYawKcUSAtf32kyH+Z9Cqwr1/Js1EAbrrn3bS0qv1nN79A8FzGsU6rkh
	 xb7dGE0zLfvCjGut5TV4xdXxjGlK0L576CzNuanG41b/p1vSkaf+/aOMVflVRhluhfLK8
	 DXkFebFwSK2wgNptF/e/W8/4bL2PXZaY59QUFq7nRNFs11TNGXfIB4y55QrtzZlnFrJaA
	 qFdOD89IhQwnYKrmnL8ZUVVDtLApUS0hBmUy/mj4tIyNf5TnICpCD1WjZQsPpa72sqg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wl364cAA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2B4E606A320;
	Tue, 20 Oct 2026 16:05:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Wl364cAA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D93291F000C4;
	Tue, 20 Oct 2026 16:05:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792512340;
	bh=whcq1B+VUUWMMaFEgT3Xk0MHrqFosIyFhnSRUMDP22w=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Wl364cAAzJipqlAaaAIkD5X/tJjNUVHVkdL7QjyIWnl90Q0hJTLx6UGMboTPt1rQf
	 uDU6K9Eqe2s4JnBtT1zB6+9Qe5RUsOS94t9iQ8mbFIRO36PQea3s4xl27QpJSamFrA
	 mLq+4zQV9Zt7BA58zFTyKbTpi/dIPGEWYa1GhYGNlun1qMWeGq7Z7FVC3dng/fwrYU
	 XRrh3mdUkqbHCYDai9AAIcdtMWYc+GkV4v+aQpzpEardMjrpDKie1MrCcVMhawvoP8
	 okQ2gICgNs2Wu5iW/CsGluEqmcEBNdxFKhrW4+v67DBbhlAhKD6mkEdAN8F8i9f+wg
	 bJsYhjnf6aO0Q==
Date: Tue, 20 Oct 2026 16:05:37 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Alex Markuze <amarkuze@redhat.com>
Cc: ceph-devel@vger.kernel.org, idryomov@gmail.com, xiubo.li@clyso.com,
	slava@dubeyko.com, viro@zeniv.linux.org.uk, brauner@kernel.org,
	jack@suse.cz, linux-fsdevel@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, tytso@mit.edu, jaegeuk@kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4 0/5] ceph: support subvolume quarantine
Message-ID: <20261020160537.GD699485@google.com>
References: <cover.1792498351.git.amarkuze@redhat.com>
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
In-Reply-To: <cover.1792498351.git.amarkuze@redhat.com>

On Tue, Oct 20, 2026 at 12:52:32PM +0000, Alex Markuze wrote:
> CephFS subvolume quarantine isolates a subvolume while allowing recovery
> clients with q/Q MDS auth caps to access it. Advertise support only after
> cached data and metadata access paths can enforce quarantine.

No base-commit given, and this fails to apply to current mainline,
current linux-next, and also to the current default branch of
https://github.com/ceph/ceph-client.git which MAINTAINERS lists for
fs/ceph/.  So it isn't possible to review this.

Note that Sashiko was unable to apply it too, so no reviews from Sashiko
are available either.

It's getting to the point where I should just immediately delete all
patches that don't have a base-commit.  It's a waste of time to even
bother trying to look at them.

- Eric
