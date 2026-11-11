Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794430776;
	b=iBe6hMEyLmLTq4lkaVJdqIaYlcq5LkutC+u3B5JNRClD6kgf/CIB3DP7MFz4l0/5Q1Cb
	 6rJrFK/tPDlfC5HAj0Qf2RMmNSyAMAEvYgq7dSHiyG1AAkwxTMVjT7EZLqVNfeIGmXlqm
	 Gg4HGQNXMgflj/k+Ry5+hmmdkWD6MXfz9ptyTXuqg3wn3D5mQm8FhRtFwLRg24MOcZWGc
	 5IfFo1Sk40bW6t/jzNUgOPsTgijaLz3mA8ce+8LaqyXQlSRDfIusu4U8P4nq/xbTtUJai
	 18EF2IwJjsZ+1vb0fadBvMHm/s43oei9GcoxuBMMhyNZkghElr6anuFSd7rZv9P/4kw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794430776;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=U00MnREKx4uGclbUtngeNRG3lctx92SV6UE/H2/Kpyo=;
	b=s5X0z6vwV9QzzEg6Wg6Wy47nuCJslmc+6u0rZKfWCrOAhjtT+ulMI2u3ouKbc8ujLpQI
	 6/FmNT7RQsFujlpD/XySvnvTt4vp9Uc46tLD98kaEsTxlXRI7nKUd9k8T4pYAjSBoUSad
	 dvVIZLmUjRN9p3onG5O0dcckc2szkvqh4LZ/eP/tcd9LY+WDOp/bA9r0deXamy0HylCMV
	 l0TI+C/3xy3paBFzjWK3Vlox/YKRcCgBQlHixcA2eh5CAonOvN07gdvlXNaUxor45pBrE
	 yurOW9uBUatyawt16aWPBat3W0ePAjaWmsMK0ra5kqox+dkyRTPPilAwzlfjlkjE3MQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SWCSrCaJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05BE2606A321;
	Wed, 11 Nov 2026 20:59:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=SWCSrCaJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C0431F00A05;
	Wed, 11 Nov 2026 20:59:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794430775;
	bh=U00MnREKx4uGclbUtngeNRG3lctx92SV6UE/H2/Kpyo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=SWCSrCaJA8nJfj8qfLlguiSt7TyDfBCBDYES5ieI/9Deic2hSIAB/k2fQKmPewl3E
	 zyPrKomrYpcNQpxty/57NTSbAhHZPnyst7gk/6k1KDs/0enIbW/l5W6U++pZoH/zzv
	 7/HywWOpCU7QE+QcabYIQ7ZEWzVC5OKz2uqj6EhPdnRCUH131xn5JhELYKHrkZzaK2
	 4unb5gpcV1vaUDGRtss1+pgjeO1pmCt//F+jX1ULUmR/q8Ml1OuX6ytqJ75k6R8lrR
	 XDEir7kTTrQUYf3QEEkAN1rdUhFxmFvfK7kZMZ2CelNzADAyItS47OibAZn5oGpqqv
	 lN3F86hl+mEMQ==
Date: Wed, 11 Nov 2026 12:59:33 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
	linux-fsdevel@vger.kernel.org, stable@vger.kernel.org,
	Ada Smith <adasmithgt@gmail.com>
Subject: Re: [PATCH] fscrypt: Initialize ->ci_master_key before publication
Message-ID: <20261111205933.GA41158@quark>
References: <20261110212011.35487-1-ebiggers@kernel.org>
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
In-Reply-To: <20261110212011.35487-1-ebiggers@kernel.org>

On Tue, Nov 10, 2026 at 01:20:11PM -0800, Eric Biggers wrote:
> fscrypt_prepare_setflags() assumes that if the key for an inode with a
> v2 encryption policy has been set up, then ->ci_master_key is non-NULL.
> This is a reasonable assumption, but it does not take into account the
> very short gap in fscrypt_setup_encryption_info() between the inode's
> fscrypt_inode_info being set and ->ci_master_key being initialized.
> Thus, a NULL pointer dereference was possible.
> 
> Fix this by closing the gap: make fscrypt_setup_encryption_info()
> initialize ->ci_master_key before publication.  If it loses the cmpxchg
> race afterwards, set it back to NULL so that put_crypt_info() continues
> to have the same behavior.
> 
> Fixes: b1c0ec3599f4 ("fscrypt: add FS_IOC_REMOVE_ENCRYPTION_KEY ioctl")
> Cc: stable@vger.kernel.org
> Reported-by: Ada Smith <adasmithgt@gmail.com>
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---
> 
> This patch applies to v7.4-rc2, and I'm planning to take it via the
> fscrypt tree.

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-current

Reviews appreciated!

- Eric
