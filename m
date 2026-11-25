Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.180.15
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795594867;
	b=0SKwkCgSkvHv+Gt+2C4MMfVdOZ7pkua3bK+h3Pwaoc78Fui7OCoOrEVjqrMw+HBkxK8l
	 /dxrE9A3vvJo/u9lmykbpTO57A1M06Ax4RUJjcIe5ppmpMeyD/PGQznuIhHAfT+QBJhZ+
	 IHG5PKosaa6GxByD/sAmcMtsX/g1X0exzs9Qq7N7rOiJruISXMm1Ee/XX2EgY3pfJNonL
	 OPfPot144ZR+niQGuy/vquEvmlMYz2EfwN3L9WDiHY3FIQaT6sh4uegf6Jy3VlpDsAdmm
	 qBswl2BVFsGZlPQEG3qmwE8UxmnhmjA7YLluihplRztDAXNLHAmggbVvyrkc0iNaJgA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795594867;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-ZohoMailClient;
	bh=7WgrRTlfNplaG0KIoL2QZuOhxkVxnuaykkwfTzH0Qo4=;
	b=AgHAZC+7ZKtcSf10If8k6dpl3wQ31ZJUiRLvPM55PhcJf1pPewRorHX8p+DXdTGP5sKE
	 Yk4C0vOUEALg6sa+ufYnOf4RM7njTkEBjc1hJfybTNsoxwLsukJn8xDfe67Jk/d1DZwqa
	 kq45OVQ3MnP2Q4NApJRfDk5DzuDlVxCiyF9KVKlkyIjDZrIkJBI7x8VXtWy/uibAQfJML
	 7i/ocf0cqZKyY8nFtTQAFGj0Tt5b5Y315xvrm+OUkq7O1Bt0CUJJMwdYLP3KS/QHi7Gze
	 CCj9MUIZzTMVc59nKB3sxpjOwkrUy9X0h5s4MMV7SA+68vp+X2ZBw9syQk+uGqLjZrA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=none header.from=laveeshbansal.com;
	spf=pass smtp.mailfrom=laveeshbansal.com;
	dkim=pass header.d=laveeshbansal.com header.i=@laveeshbansal.com header.a=rsa-sha256 header.s=zoho header.b=Fdy1V4G2;
	arc=pass header.oldest-pass=0 smtp.remote-ip=165.173.180.15
Received: from sender6-op-o15.zoho.com (sender6-op-o15.zoho.com [165.173.180.15])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F08DE606A333;
	Wed, 25 Nov 2026 08:21:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org F08DE606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=laveeshbansal.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=laveeshbansal.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=laveeshbansal.com header.i=@laveeshbansal.com header.a=rsa-sha256 header.s=zoho header.b=Fdy1V4G2
ARC-Seal: i=1; a=rsa-sha256; t=1795594850; cv=none; 
	d=zohomail.com; s=zohoarc; 
	b=HaCv45zGfIFSwef5XCKPMVa4ihwxLlklvsi+f0iObqtaqLlMaWeRyR7jIcLJTwSQTO3/9P/dcL8wHr5d7BTlChHQmKZGPD3X7mtd0WVsfJEkF5aSfhdodmNYHL4Z2Gc6phMZo/ifG0YhGI2bfpIL3Xikw/FL54sdyIpWucAswhs=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=zohomail.com; s=zohoarc; 
	t=1795594850; h=Content-Transfer-Encoding:Cc:Cc:Date:Date:From:From:In-Reply-To:MIME-Version:Message-ID:Subject:Subject:To:To:Message-Id:Reply-To; 
	bh=7WgrRTlfNplaG0KIoL2QZuOhxkVxnuaykkwfTzH0Qo4=; 
	b=OA/FCdUwPlk+XCHDKBbU+HeIVKFyqIKzUGWPFk43+ESZTezWZpivD9kBMOZsEr/f4zgLIGg5TLYY5eEgM1g2PbUn6cdEDa58tTeOX00SHhr7nu8zCkJW+O1EOCWnrfGEwlF2UNQCRenKaSyCP5eL5xySoT0mhyg1Cz1E26ImpBs=
ARC-Authentication-Results: i=1; mx.zohomail.com;
	dkim=pass  header.i=laveeshbansal.com;
	spf=pass  smtp.mailfrom=laveeshb@laveeshbansal.com;
	dmarc=pass header.from=<laveeshb@laveeshbansal.com>
DKIM-Signature: a=rsa-sha256; b=Fdy1V4G2HguZdxRwK7LZ1EA/JSaOqRZtjLFvdMJfPB9t15/hSz7DCoU6MZ7NeIEJZ297skj1vqTSZ+g9oWc0o9ViBNlKHz65HfSbN9z7hU7lrtqFqDM+U2y3z+/n5YEMlg2ESONFjE9oazs3pGobB8Y22r9kXXZ0wzhJlBx8020=; c=relaxed/relaxed; s=zoho; d=laveeshbansal.com; v=1; bh=7WgrRTlfNplaG0KIoL2QZuOhxkVxnuaykkwfTzH0Qo4=; h=Content-Description:Content-ID:Content-Type:Content-Transfer-Encoding:Cc:Date:From:In-Reply-To:List-Subscribe:List-Post:List-Owner:List-Id:List-Archive:List-Help:List-Unsubscribe:MIME-Version:Message-ID:Resent-Sender:Resent-Cc:Resent-Date:Resent-To:Reply-To:Resent-Message-ID:Resent-From:Sender:Subject:To:Date:From:Message-Id:Reply-To:Subject:To:Cc;
Received: by smtp.zohomail.com with SMTPS id 17955948481371018.7221762782647;
	Wed, 25 Nov 2026 00:20:48 -0800 (PST)
From: Laveesh Bansal <laveeshb@laveeshbansal.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@lst.de>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	syzbot+20d60aafd9a0d1f2a380@syzkaller.appspotmail.com,
	linux-block@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] blk-crypto: use a NOIO scope while holding profile->lock
Date: Wed, 25 Nov 2026 00:20:34 -0800
Message-ID: <20261125082034.78219-1-laveeshb@laveeshbansal.com>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261125014454.GA2461@sol>
References: <20261125014454.GA2461@sol>
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

Hi Eric

Thanks for the review. v3 returns the flags from blk_crypto_hw_enter(),
rewords the comment and drops the version from the stable tag:

https://lore.kernel.org/r/20261125081417.77674-1-laveeshb@laveeshbansal.com

Thanks
Laveesh
