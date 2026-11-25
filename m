Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=213.95.11.211
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795584793;
	b=5TMFk7dK8qrTeQgG0L1I9y9USME/e+8Bxh7xObAxzw8TUfV2WAIZoHCCJvkyc9wUtvFk
	 12GfJdOBu7X6UWseWtJ6SH/d+TcVns93NI75F81DVpOiXSeNG4AAHZtR4ULxU/GLrqCDF
	 6bpQa5d78VR7YSu8EJP5LO5L2udy1kN9fqybkBqYlDRarq0Fpt5TUKXpLNfgb2nUyERy2
	 y1It8kmPGBiXwiLa9PO4Wp0PsFz+QTkPBcLuCegHqRPCC32cu1raJaAa147MXm3Azp+em
	 QI/hT4h5JP/9kbAIlknQHq30MJNw4Q7uf+Z5aJSoUDBA0c+7fngHNEqpNZ+3PwAaFcg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795584793;
	h=DMARC-Filter:Received:Date:From:To:Cc:Subject:Message-ID:References:
	 MIME-Version:Content-Type:Content-Disposition:In-Reply-To:User-Agent;
	bh=SfHDJG8N1lUb7/rR9etOXwdGral5sYZou2C8hxd7w/w=;
	b=D2yV5UisRVCsog58gUhjwKJ6moBhaZgOje4pEQHhTiLgAum+pwKmJX2NzGmk7KMveD16
	 wCNuRNq5HZQcIcD3hyMQ8v6yPWqIVNAx3fAq4zNdnO0Ff//h7pSAcJrlWXh6/I3Pw/CXS
	 4limI+t1DVB/Xt+l0TlHIa2khEheNh53q/7BHIrrdyjoJfkFgp/F8jDxuQjhnV7/kJwqK
	 NYBwujTj/QkL4aNP1P9huar85QFrD2dV4NfV1lTPcb6/qTpvVd89SSi6Bc2cqQflia+FQ
	 EPrnkFMcQysqTTgQWSJpha1WTJTPkGfF/1cjqPOOsUsIn/tR5ZriKKFfD+/wLmddwZA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=lst.de;
	spf=pass smtp.mailfrom=lst.de;
	arc=none smtp.remote-ip=213.95.11.211
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA95F606A321;
	Wed, 25 Nov 2026 05:33:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EA95F606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 57F7568AFE; Wed, 25 Nov 2026 06:33:08 +0100 (CET)
Date: Wed, 25 Nov 2026 06:33:08 +0100
From: Christoph Hellwig <hch@lst.de>
To: Laveesh Bansal <laveeshb@laveeshbansal.com>
Cc: Jens Axboe <axboe@kernel.dk>, Eric Biggers <ebiggers@kernel.org>,
	Christoph Hellwig <hch@lst.de>, "Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com,
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] blk-crypto: use a NOIO scope while holding
 profile->lock
Message-ID: <20261125053308.GA20407@lst.de>
References: <20261123181408.62972-1-laveeshb@laveeshbansal.com>
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
In-Reply-To: <20261123181408.62972-1-laveeshb@laveeshbansal.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

Looks good:

Reviewed-by: Christoph Hellwig <hch@lst.de>

(and I agree with Eric that killing the allocations is also useful..)
