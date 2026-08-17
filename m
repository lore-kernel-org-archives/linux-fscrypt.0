Received: from mta0.migadu.com (out-225.mta0.migadu.com [91.218.175.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 684D322A4E9
	for <linux-fscrypt@vger.kernel.org>; Mon, 17 Aug 2026 07:39:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.225
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786952343; cv=none; b=heByqRVlwrEARrBW57UkEJRSs+jqtPbNout9uhMLnIqQhJmSbUzfO0U8pszlYdqq1R5R5z+1Rc3pho9ie3o/K7JoqGojCoqZkszq0E1CoAXfN8nRZNXpppX+0Bx18E5rNBeSpWh0LAfwVAWmNzeE5sd4kaTdbo/l5Cm/L9nTzH0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786952343; c=relaxed/simple;
	bh=4YGgPm1wRAd8vr5pINF7lmz4ylld4f9QdvgoaXgstqU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=MGw252lmwvG16/VhE9amfRpf83e4rHKirFC/9uVhtOBRFlvsc+ylQqK3PsmeNUpFFnd/d7ispYjTNejiJNepjl/wlvgQotPGe5RMxxELwkmLKJkQFqhhRuhDLMiX3ItqIFaaW4GkYS9g7w2Dol7bbIwIZMuZ4sZYX5a0o77pG8U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=uyGzmdas; arc=none smtp.client-ip=91.218.175.225
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="uyGzmdas"
X-Envelope-To: linux-fscrypt@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=4YGgPm1wRAd8vr5pINF7lmz4ylld4f9QdvgoaXgstqU=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1786952339; v=1; x=1787557139;
 b=uyGzmdasaERXwjWMKUBTkPuPp2qAZK2AqxvO2gh/6ul5FohEcqCplJTcx/CzANBmq8anQaGF
 nyPtZhHOR7X3FEwE7FQKEpSUnlb4u0jXP571OFcwNgSOTSMzfms5hYAt0UqLWWFf0kVKrXQ9B98
 /IHYgVCpeGhhfwATJP42+e+s=
X-Envelope-To: linux-fscrypt@vger.kernel.org
Received: from localhost (3.112.29.171)
	by mta12.migadu.com with ESMTPS id 17e9312474d067d5;
	Mon, 17 Aug 2026 07:38:57 +0000
X-Migadu-Flow: FLOW_OUT
Date: Mon, 17 Aug 2026 15:38:53 +0800
From: Baoquan He <baoquan.he@linux.dev>
To: Lukas Wunner <lukas@wunner.de>,
	Jan Sebastian =?iso-8859-1?Q?G=F6tte?= <contact@jaseg.de>
Cc: Jan Sebastian =?iso-8859-1?Q?G=F6tte?= <linux@jaseg.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@kernel.org>,
	Pasha Tatashin <pasha.tatashin@soleen.com>,
	Pratyush Yadav <pratyush@kernel.org>,
	Dave Young <ruirui.yang@linux.dev>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>, David Howells <dhowells@redhat.com>,
	Jarkko Sakkinen <jarkko@kernel.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Shuah Khan <skhan@linuxfoundation.org>,
	Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Ignat Korchagin <ignat@linux.win>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Keith Busch <kbusch@kernel.org>, Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>, Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@kernel.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	Benjamin Marzinski <bmarzins@redhat.com>, kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, keyrings@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org,
	linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dm-devel@lists.linux.dev
Subject: Re: [PATCH v2 01/13] kexec: add CRASH_WIPE_SECRETS to wipe secrets
 before kdump
Message-ID: <aoK6jXA-tF9qfKOZ@MiWiFi-R3L-srv>
References: <20260811-crash-zeroize-rework-v2-0-9561d13c2340@jaseg.de>
 <20260811-crash-zeroize-rework-v2-1-9561d13c2340@jaseg.de>
 <anw9ILJiO5xIjP4f@MiWiFi-R3L-srv>
 <9765f7ea-36bb-4c7b-a19b-7facec97b762@jaseg.de>
 <aoGpcczo5GkBsPwt@wunner.de>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <aoGpcczo5GkBsPwt@wunner.de>

On 08/16/26 at 02:13pm, Lukas Wunner wrote:
> On Wed, Aug 12, 2026 at 12:08:39PM +0200, Jan Sebastian Götte wrote:
> > I can imagine one alternative way to approach this, tell me what you think:
> > Instead of registering wipe handlers that memzero places on panic, I could
> > put an optional registry of (addr, len) descriptors into crashkernel memory
> > that the original kernel populates with the PAs of buffers to clear ahead of
> > time. Then the kdump kernel could do the actual memzero. This would remove
> > all code from the actual kdump path here. The registry could be made
> > per-core to avoid locks.

Since there are a lot of security expert in CC, I am wondering what's
the risk if we wipe secrets during dumping. System is located in
user's place, and vmcore is dumped and collected in user's place. If we
filter out secrets memory when we dumping, what could be leaked out?

> 
> Or create a dedicated mempool from which all sensitive data is allocated,
> then call mempool_free_bulk() on kexec to poison everything in that pool?
> 
> Thanks,
> 
> Lukas
