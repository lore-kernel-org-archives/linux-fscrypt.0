Received: from out-189.mta1.migadu.com (out-189.mta1.migadu.com [95.215.58.189])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C78CD33ADA7
	for <linux-fscrypt@vger.kernel.org>; Sat,  1 Aug 2026 14:52:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=95.215.58.189
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785595940; cv=none; b=D52s7d7ncv5i1YUromG9mYhQ8Mm7UKMcrtKxDfy0X35xgGBUFDqVG8KIssrmUlrBTtBfBg7NQxIQZYhAAVCZvRTFCaJ7/L/BRxuJNPjnj9R/wj1+FbJYxfDIszqEpqsHjReMyjYSDdd3ZQrn88/3dmcZLLwoWg2yJO/Fn3uzGyA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785595940; c=relaxed/simple;
	bh=cstxdhByfxAG3A0a/W30IsElR0BQofoPAvvz2J6dY9I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bYVPYe7oTLZeAcMrasnlj71Mw6uAGerzM41cgFLWvrL9/6abenzJSzSnzZUD/PgvqOT02TgLDcxVAT5ZjI5fq+vv4WXyNFusUiI17i/ZcsbQNlCSI7WoukNyDWTBFRNdH+2nHhFsruXPmO3RpwHCYogDycSejJ6ie7kghd8ZGLg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=dY/qZWe/; arc=none smtp.client-ip=95.215.58.189
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="dY/qZWe/"
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1785595936;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=GcGm8f+HjinZy6KpUpQibmKA3BxQ4Nicuuq7tor/vmY=;
	b=dY/qZWe/pctIzM3LCzB73J/MmbY3+GUl3Wm5oBdOtv9fzRMojtyF2M4U6ZiLC3BIP315zn
	SGGrWvW/q4nommTh9uVRrqk/1lgBEVXiKouBxZ49ldIobitG/aClAOMJIDcVixCOgXUkt4
	itTlKiyeiGTV8Aws3LDIYftmReuBv0o=
From: Usama Arif <usama.arif@linux.dev>
To: Zi Yan <ziy@nvidia.com>
Cc: Usama Arif <usama.arif@linux.dev>,
	David Hildenbrand <david@kernel.org>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Muchun Song <muchun.song@linux.dev>,
	Lorenzo Stoakes <ljs@kernel.org>,
	"Liam R. Howlett" <liam@infradead.org>,
	Vlastimil Babka <vbabka@kernel.org>,
	Mike Rapoport <rppt@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Michal Hocko <mhocko@suse.com>,
	Baolin Wang <baolin.wang@linux.alibaba.com>,
	Nico Pache <nico.pache@linux.dev>,
	Ryan Roberts <ryan.roberts@arm.com>,
	Dev Jain <dev.jain@arm.com>,
	Barry Song <baohua@kernel.org>,
	Lance Yang <lance.yang@linux.dev>,
	Gregory Price <gourry@gourry.net>,
	Ying Huang <ying.huang@linux.alibaba.com>,
	Alistair Popple <apopple@nvidia.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Qi Zheng <qi.zheng@linux.dev>,
	Shakeel Butt <shakeel.butt@linux.dev>,
	Kairui Song <kasong@tencent.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH RFC 04/14] fs/crypto: stop setting PG_private on bounce page
Date: Sat,  1 Aug 2026 07:52:07 -0700
Message-ID: <20260801145208.1930586-1-usama.arif@linux.dev>
In-Reply-To: <20260731-remove-pg_private-v1-4-142c97ba3562@nvidia.com>
References: 
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Migadu-Flow: FLOW_OUT

On Fri, 31 Jul 2026 22:13:27 -0400 Zi Yan <ziy@nvidia.com> wrote:

> The point to a plaintext folio is stored in page->private and cannot be
> NULL, making PG_private redundant.

s/point to/pointer to/


And fscrypt_free_bounce_page() NULLs it, so that needs to be corrected.

 
> It prepares for a future commit that remove PG_private.
> 
> No funtional change intended.
> 
> Assisted-by: Claude:claude-opus-4-8
> Assisted-by: Codex:gpt-5
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> To: Eric Biggers <ebiggers@kernel.org>
> To: "Theodore Y. Ts'o" <tytso@mit.edu>
> To: Jaegeuk Kim <jaegeuk@kernel.org>
> Cc: linux-fscrypt@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  fs/crypto/crypto.c | 2 --
>  1 file changed, 2 deletions(-)

Nothing in fscrypt or its users tests PG_private on a bounce page, so
this looks right to me. The commit message needs to be corrected but code
looks correct.

Feel free to add:

Acked-by: Usama Arif <usama.arif@linux.dev>


> 
> diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
> index 570a2231c945a..c8a98dd94650f 100644
> --- a/fs/crypto/crypto.c
> +++ b/fs/crypto/crypto.c
> @@ -73,7 +73,6 @@ void fscrypt_free_bounce_page(struct page *bounce_page)
>  	if (!bounce_page)
>  		return;
>  	set_page_private(bounce_page, (unsigned long)NULL);
> -	ClearPagePrivate(bounce_page);
>  	mempool_free(bounce_page, fscrypt_bounce_page_pool);
>  }
>  EXPORT_SYMBOL(fscrypt_free_bounce_page);
> @@ -202,7 +201,6 @@ struct page *fscrypt_encrypt_pagecache_blocks(struct folio *folio,
>  			return ERR_PTR(err);
>  		}
>  	}
> -	SetPagePrivate(ciphertext_page);
>  	set_page_private(ciphertext_page, (unsigned long)folio);
>  	return ciphertext_page;
>  }
> 
> -- 
> 2.53.0
> 
> 
