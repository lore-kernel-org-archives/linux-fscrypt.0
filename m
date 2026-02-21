Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07B91CA6F;
	Sat, 21 Feb 2026 19:45:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771703137; cv=none; b=Uwatsqh+CktfLppa8xgoOW6YiOn8tfrick+HQ2F6qM8p11ceLovWjuKIT6iZOBsGOwXAxgbGMuLx/8QxlwGMwf91/FzUPEWmfN4ABGDG/nhfUFz3tXQZk0yPXtktRJ2UEcEoFAeYmjXxmwaX9WHy17wW/XtGck9dT+IUwr7SPYY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771703137; c=relaxed/simple;
	bh=mFAiNSqsxsqOGhfi6yj61qlg7slrIqYxPPaW9O9Y60Q=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lWJ5aeel5ca5ubKYMpG/aSUKIfy7u/0YLjUMlge40do/1u0JIIaEfDp/FzqGqA5WdDbvN9a7ODXvfxYsBQTsAWRNaaASuYyG8cGD0u4sgHmKLvkdAI3XtuFX+J/aK2nMORZKXS4yQboMNwihNSavYQtRSse56T1Rt0Z0IofMce0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WEZIXEN5; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WEZIXEN5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4F133C4CEF7;
	Sat, 21 Feb 2026 19:45:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771703136;
	bh=mFAiNSqsxsqOGhfi6yj61qlg7slrIqYxPPaW9O9Y60Q=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=WEZIXEN5w0Og2gE8E5z1Crq5s0FzNg+4ErjWqUno3rrR6oGCcIwt4lcuDLkDA8fWz
	 aePZIq5glzoDCW7sKquOgRO3wXyVzqSdF9RY5GAq51Ms3BwoWLd365JqTysUvqnpro
	 Brik2jrScJl13SC7NgueLJwNS/zoIpD4qE+gF/JmgcpVEfEhGdFDp8SblpEv4wiGHj
	 UOPSUdg3+HqN78Ow6K4gpBWm708TRX7ZYlIHfvORn6ka71mA4Vs/eWVSh7WVMj5T6Q
	 XBaHgX/w3rR6cXkvfIt7zO8bPtKtMFeosoRV5zShagB0YEHK4UlfaKYdvmVJVJcZ6H
	 oMKy2BZ3PpWkQ==
Date: Sat, 21 Feb 2026 11:45:34 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Chao Yu <chao@kernel.org>, Christian Brauner <brauner@kernel.org>,
	"Darrick J. Wong" <djwong@kernel.org>,
	linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3/9] fscrypt: pass a byte offset to
 fscrypt_set_bio_crypt_ctx
Message-ID: <20260221194534.GC2536@quark>
References: <20260218061531.3318130-1-hch@lst.de>
 <20260218061531.3318130-4-hch@lst.de>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260218061531.3318130-4-hch@lst.de>

On Wed, Feb 18, 2026 at 07:14:41AM +0100, Christoph Hellwig wrote:
> diff --git a/fs/crypto/inline_crypt.c b/fs/crypto/inline_crypt.c
[...]
> /**
>  * fscrypt_set_bio_crypt_ctx_bh() - prepare a file contents bio for inline
>  *				    crypto
>  * @bio: a bio which will eventually be submitted to the file
>  * @first_bh: the first buffer_head for which I/O will be submitted
>  * @gfp_mask: memory allocation flags
>  *
>  * Same as fscrypt_set_bio_crypt_ctx(), except this takes a buffer_head instead
>  * of an inode and block number directly.

Similarly, the above needs "block number" => "file position"

- Eric
