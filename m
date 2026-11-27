Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.182.15
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795760800;
	b=JXyUHNw3bNCbnq3sx5PamlddZNZ+w6e0JO6b8+D0Ytsuvt3kLJAxCPdeYSslqWVbbP7Q
	 TDnBzVTz88dyODhozdqOVQMOQlblzPKCgXM+D8iMJfLpmwuKJMrLM5ZeFXsUtxW/3KLeq
	 SRj2gk2pgTWwf7Ym72+wB+Wq6RlBP/SiufwaSohqeBC7bxpzGgaCMOAybMlEpNTaK0NUy
	 PUDJnlPBVs7TssbTLy0DnlG3dYXJ0bJbIEIFvZMUjFitH0GELyuYKSmLbKea//oFF8RXN
	 gu7nnklGLmC2bV53MI2eeGA7TZone6LG6VX3exAp2vDYgt4fYS2I7ryUbNiyTrfxQNw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795760800;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-ZohoMailClient;
	bh=bCNn9r8VG4aa0r4Am+eSfDy/QqMZMCKrbKXiHll/bkU=;
	b=E/CjVHqSjax6FIhUmI52ts6VXfOiexYoQxnwnxzXr01+mCRGxk4uBg2AJOqKsTUu2tMY
	 8dks4cL5yYSzKbqVJlv7PouJOc/L8ghQtZ4bDXBf4GNGqZyoY0RkdJ+sqd7hn2QWP5Cah
	 BNexw484BQz81LnGGAjG6JKUaHnZXMWW0D+wgxBw0bK+S+1dTkUpmwlzuO0gACQklAznp
	 q3xe6hV2W72quiYK/T2J/OgejEjN0ok0fSfJuWw8wuLFqRKA4xNEX1Zs6KUDwAGAomhER
	 PKLzIncxKhe4PF0fli3b667fNk0giCHej3XHbDiM81gmT9GGw4UTqXwIAD9YrjInsRQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=laveeshbansal.com;
	spf=pass smtp.mailfrom=laveeshbansal.com;
	dkim=pass header.d=laveeshbansal.com header.i=@laveeshbansal.com header.a=rsa-sha256 header.s=zoho header.b=TiQ3U15R;
	arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.182.15
Received: from sender5-op-o15.zoho.com (sender5-op-o15.zoho.com [165.173.182.15])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 01F04606A31C;
	Fri, 27 Nov 2026 06:26:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 01F04606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=laveeshbansal.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=laveeshbansal.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=laveeshbansal.com header.i=@laveeshbansal.com header.a=rsa-sha256 header.s=zoho header.b=TiQ3U15R
ARC-Seal: i=1; a=rsa-sha256; t=1795760783; cv=none; 
	d=zohomail.com; s=zohoarc; 
	b=Iq8+3O6SVynT2p7WX05aK+b7q9YoMkkRNFV3sfhmUDfefXMc9GdZKVzfp/G0qBb1pOMuqmV/5+IHeRerNmIZm5po6BzF/fMCCOhdyI3qgjiPB4wkQDxMYUV+sHdKFHroRNu3ak2OD32zXAtp151sSQvwnJgECfySt0Zo1vmy6+Y=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.com; s=zohoarc; 
	t=1795760783; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:In-Reply-To:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=bCNn9r8VG4aa0r4Am+eSfDy/QqMZMCKrbKXiHll/bkU=; 
	b=jJlsb++oCttRggNA3bAp3KJoKJ1RkFzyGC50RoUTVTkfejfzP9YOJTUtyWcUATRbLTPS37mCMA479lREhVRYJpOuhpsqUP7iLn6GRW0yVnlTHE1IK1FnKZn1gqLWc6gtN9d0dNg3gLz5yCKHXlyQ3UPFzpYswkr1XcYIoZVH/k4=
ARC-Authentication-Results: i=1; mx.zohomail.com;
	dkim=pass  header.i=laveeshbansal.com;
	spf=pass  smtp.mailfrom=laveeshb@laveeshbansal.com;
	dmarc=pass header.from=<laveeshb@laveeshbansal.com>
DKIM-Signature: a=rsa-sha256; b=TiQ3U15RQrizMzkNM3/UKGIzpdsVJHRMduzq6A5gQoelzNgKqo8ooAwP+xzJq5kblOfAfid1MiquAAU9ljG7zIJZT1EH54+nKavCqm0BIEdy6FfPeGk6yRjCfsLl3WW0eZ1ofQgZMGdhKvFcpUpDkQlLUl8xClgnQanoHNLTCwM=; c=relaxed/relaxed; s=zoho; d=laveeshbansal.com; v=1; bh=bCNn9r8VG4aa0r4Am+eSfDy/QqMZMCKrbKXiHll/bkU=; h=Content-Description:Content-ID:Content-Type:Content-Transfer-Encoding:Cc:Date:From:In-Reply-To:List-Subscribe:List-Post:List-Owner:List-Id:List-Archive:List-Help:List-Unsubscribe:MIME-Version:Message-ID:Resent-Sender:Resent-Cc:Resent-Date:Resent-To:Reply-To:Resent-Message-ID:Resent-From:Sender:Subject:To:Date:From:Message-Id:Reply-To:Subject:To:Cc;
Received: by smtp.zohomail.com with SMTPS id 1795760780464754.4038009804824;
	Thu, 26 Nov 2026 22:26:20 -0800 (PST)
From: Laveesh Bansal <laveeshb@laveeshbansal.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>,
	Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com,
	linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] blk-crypto: use a NOIO scope while holding profile->lock
Date: Thu, 26 Nov 2026 22:26:17 -0800
Message-ID: <20261127062617.29510-1-laveeshb@laveeshbansal.com>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261125053308.GA20407@lst.de>
References: <20261125053308.GA20407@lst.de>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-ZohoMailClient: External

Hi Christoph

I sent v3 to address Eric's comments on v2.

blk_crypto_hw_enter() now returns the saved flags and
blk_crypto_hw_exit() takes them, instead of keeping them in the profile.
The comment is reworded and the version is gone from the stable tag:

https://lore.kernel.org/r/20261125081417.77674-1-laveeshb@laveeshbansal.com

I did not carry over your Reviewed-by since the code changed. If you
are ok with v3, please re-add it.

Thanks
Laveesh
