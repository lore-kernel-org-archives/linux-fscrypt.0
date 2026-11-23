Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.180.15
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795458123;
	b=rbK+hz+J903Jmeu5/5LOFVsPYNCnRZh3TDzarYcEwZUvC7+YEQLWc8SRZDxv0dHg7vmt
	 d2pKELnGjjmwitDivOEAeEdHr9V5mRj0AxlmYoUUJAvQunOwjYJ4I9NY4FYWBAEgwRhIC
	 RKtMYTmAAQCO7Nh2OMu53FJF+RW8ic/V+cSqZ6k8upu16JXwp4Jbd2GlVqk0mJI3LtMKs
	 y/eR4LdDoeO3W7+Vw8MElillZE5UcWMTqMHvP07X//5Sf5ApvPGws/GE7dP+C+zz60eif
	 gPaR5NO8YRXa8vX+iESV4eVR3E6sd2SUQ4Z28z7CBiPeV1ufQGgVL6frotzfHKyuGfA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795458123;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-ZohoMailClient;
	bh=gQaw9Vk9+tQPLXBi7VU6YjTxlhQ/2eyTFTJHqY1EySE=;
	b=zxrx2rTZGYNZ9hjMn6auq9L1osC0awcKlU1yDCBfoVM8kZ8CXTJZPQvvr5bIESm4YV0U
	 1G23Vy30+u6ZvZgwedSjj/6mdfa5rIkn9T12sDxfA+2bado2rpe4A6NBHRwo6UD+aomuL
	 BEpFk+UBGBHefxgUV1XifXw3riMcr0zLt6P9tnY54W++pmU30kV0u6ZNPPcvOEkuGRxuW
	 APzi2rv7Eo6Yy/WdW+zAp4n2CX6BbMP7YZht3wKefNu0Q3QGmL78cxCVDIcMrXtkYay6I
	 52rNX6QoF1fec9+REncGeZ4GpACvFDO0WOqgVQFsehZ+CEyLjRdMzi3F3CLS9wOn9aQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=laveeshbansal.com;
	spf=pass smtp.mailfrom=laveeshbansal.com;
	dkim=pass header.d=laveeshbansal.com header.i=@laveeshbansal.com header.a=rsa-sha256 header.s=zoho header.b=NQCKQ6Re;
	arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.180.15
Received: from sender6-op-o15.zoho.com (sender6-op-o15.zoho.com [165.173.180.15])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 857EC606A31A;
	Mon, 23 Nov 2026 18:22:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 857EC606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=laveeshbansal.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=laveeshbansal.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=laveeshbansal.com header.i=@laveeshbansal.com header.a=rsa-sha256 header.s=zoho header.b=NQCKQ6Re
ARC-Seal: i=1; a=rsa-sha256; t=1795458104; cv=none; 
	d=zohomail.com; s=zohoarc; 
	b=ZGtKsHgNSS/ZvE454aeZ4AE+SU6epq4GNeJPu7klKjDuRv3LiUCnhTXu1PkRi11JRd6vWNnWoYGe4mdLS0dDpxztXw23z/jCLdtitDKoXLNA8fmKa/zJ7hvPeO2wDQ+Xg5UJwTxrg7NtRLHHM5lqfDHlnb2M+KXFNipxrBAOXP8=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.com; s=zohoarc; 
	t=1795458104; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:In-Reply-To:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=gQaw9Vk9+tQPLXBi7VU6YjTxlhQ/2eyTFTJHqY1EySE=; 
	b=mVe3qmonBAON3Sybd7Y2rbLUZm4fZ71en/kHkS6sMDponfrmdeGIq+g4enwAHTvTUrHmppBHdTmCSC636KC0Lol70c7dIrODsHXUlyFVAJ1dZeC2oEChSpUWa13RaU/Mfw11Ggr9Uaw+NQZg1vZkgnOJefqeYz1ZlnNi4A9M3LM=
ARC-Authentication-Results: i=1; mx.zohomail.com;
	dkim=pass  header.i=laveeshbansal.com;
	spf=pass  smtp.mailfrom=laveeshb@laveeshbansal.com;
	dmarc=pass header.from=<laveeshb@laveeshbansal.com>
DKIM-Signature: a=rsa-sha256; b=NQCKQ6Rex/xA5RTPVCehzSMw9tNJYBOBZANzW1pFmeU5Qd1fm/53Q6FGRcSMvNE3pMq+/m9bw4BYc7RRdFnlGCjUjrvFaOcaLm95ekTOWwsRgsMxOQY9jy0tN6eElJC3988gyYYMBE6lYIBE7SaMq4rj93IqoxusfYgYL5b3Gvs=; c=relaxed/relaxed; s=zoho; d=laveeshbansal.com; v=1; bh=gQaw9Vk9+tQPLXBi7VU6YjTxlhQ/2eyTFTJHqY1EySE=; h=Content-Description:Content-ID:Content-Type:Content-Transfer-Encoding:Cc:Date:From:In-Reply-To:List-Subscribe:List-Post:List-Owner:List-Id:List-Archive:List-Help:List-Unsubscribe:MIME-Version:Message-ID:Resent-Sender:Resent-Cc:Resent-Date:Resent-To:Reply-To:Resent-Message-ID:Resent-From:Sender:Subject:To:Date:From:Message-Id:Reply-To:Subject:To:Cc;
Received: by smtp.zohomail.com with SMTPS id 1795458102373833.7656003546538;
	Mon, 23 Nov 2026 10:21:42 -0800 (PST)
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
Subject: Re: [PATCH] blk-crypto: avoid fs reclaim under profile->lock in the fallback
Date: Mon, 23 Nov 2026 10:21:36 -0800
Message-ID: <20261123182136.63256-1-laveeshb@laveeshbansal.com>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261123093134.GA23224@lst.de>
References: <20261123093134.GA23224@lst.de>
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

Thanks for the review. v2 moves the NOIO scope into
blk_crypto_hw_enter()/blk_crypto_hw_exit(), and into
blk_crypto_reprogram_all_keys(), which takes the lock directly:

https://lore.kernel.org/r/20261123181408.62972-1-laveeshb@laveeshbansal.com

Thanks
Laveesh
