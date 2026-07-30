Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 841FB344036;
	Thu, 30 Jul 2026 02:40:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785379250; cv=none; b=MoqSh2dmCXHY1hV5Nw+MXqRzw5rbNAz6onZ6qtzxzoQpHl1ApKifn6ACezgjjqqsvBC+y36fH4PO++SVNy8q07mTKkv5sj9aIYyPoPGoxwxTQaB3Dfz6RNF7M7jcX+6hDOEYHMV+W+GkeM62A3RAKprxbWnK5LTkTlvRgENyNSI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785379250; c=relaxed/simple;
	bh=HgUBUlCMmnDJalFLV1AqXguDUJXozQndEARiYf3g890=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AqYyizgCEP7bqWySrqQtNl7gfymfMrvGKDFz3rYbVeFMdy7RvqpAEbT8qrEH+p6loPBInv32ILZdj0YRrTfMB1yfMLwDuwQVAr+JNpXVNmu9Prmoze93ujeNtOpWiIRHfkpyB5uUfjm2nOruYGrjgvZO+z5K8c4EczqhQlKGO4Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KJvuW95d; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KJvuW95d"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BD28B1F00A3D;
	Thu, 30 Jul 2026 02:40:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785379249;
	bh=QLVH5gwjjQR7h/ReEB35nFfhA+98Zkl6i4fNXBvQ5q8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KJvuW95dw1ejoGKeX+FTCT2/WcivxoaJuPQyD+a6288PSZqP2cf+s6UY9rtcp+ypD
	 yo5cVAOxJdE/LDFJRMB74Jb8pBunH7BTPIwNv51pbOVei7n+zA+YA6KexsS8h60PDC
	 hcyFeqpoJzPcKjNXaFb/XOFuGm1+mhFO1csYTfJcQ9cBL0pTQ83/LlV125P1HhPjM5
	 kfsTVpmHezmYQZrdAg+UwMFNgVbN09TaiAqsqG+k7JOMsQE8LE05DShn/+rCRfH0xx
	 fnVGr+Jqd15EMTCLlM38+pt4Sv/N8OUCgH1xMF6/xECSE3Foqy6HmwKcKlcL5i8gSq
	 UVmtrYH7abs/A==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	Christoph Hellwig <hch@lst.de>,
	Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 6.12] fscrypt: Avoid dynamic allocation in fscrypt_get_devices()
Date: Wed, 29 Jul 2026 22:40:15 -0400
Message-ID: <20260729223316.stable-0019@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260729152127.11918-1-ebiggers@kernel.org>
References: <20260729152127.11918-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> [PATCH 6.12] fscrypt: Avoid dynamic allocation in fscrypt_get_devices()

Queued for 6.12, thanks.

-- 
Thanks,
Sasha
