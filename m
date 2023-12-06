Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Cpl4A3X/"
Received: from bombadil.infradead.org (bombadil.infradead.org [IPv6:2607:7c80:54:3::133])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 45E28135;
	Tue,  5 Dec 2023 23:16:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=ep680p/3l1ZjuRd2qyeZxJ3FOs3BAzN7xme9C4tkHF4=; b=Cpl4A3X/GTusI70ItO3TesmVmy
	dCPUZCv+hIHaPz4MFMjKp4WRmWRPbZUCAU4Yhkv2SqiG5Ib01nl+4pdNdn6rYWGnQsLQhgA6keIvN
	WZOWridpWx77cXn6KW3Czgef5e40FaDdU1U9aKqouwjMosWyVdmh+cH5eOD/5ZZylUukkJ4XSIMKd
	vVaPLensBpRS4ex+XuPAlPwWiCq2CshUV6iNXjznHdCacwaJOHgZEiiquKfv10GKG+dVXFAxTWOzv
	UpD8g5lVRJRTqFEteT4rjykZez4sYN+Fb7e4cDfJQkTOE284GhNrRsTN6Hq+hiURe9jQGVV8We6Jt
	TS+pt5Ww==;
Received: from hch by bombadil.infradead.org with local (Exim 4.96 #2 (Red Hat Linux))
	id 1rAm93-009HJ8-33;
	Wed, 06 Dec 2023 07:16:33 +0000
Date: Tue, 5 Dec 2023 23:16:33 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
	Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH] fscrypt: move the call to fscrypt_destroy_keyring() into
 ->put_super()
Message-ID: <ZXAf0WUbCccBn5QM@infradead.org>
References: <20231206001325.13676-1-ebiggers@kernel.org>
 <ZXAW1BREPtCSUz4W@infradead.org>
 <20231206064430.GA41771@sol.localdomain>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20231206064430.GA41771@sol.localdomain>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Tue, Dec 05, 2023 at 10:44:30PM -0800, Eric Biggers wrote:
> There are lots of filesystems that free their ->s_fs_info in ->put_super().  Are
> they all wrong?

Wrong is the wrong word :)

For simple file systems that either don't use block devices, or just
the main one set up by the super.c code using ->put_super is perfectly
fine.  Once a file system does something complicated like setting up
their own block devices, or trying to reuse super blocks using custom
rules it basically has to free ->s_fs_info  in it's own ->kill_sb
handler.  This whole area is a bit messy unfortunately.

