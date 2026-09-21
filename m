Received: from mta0.migadu.com (out-2.mta0.migadu.com [91.218.175.2])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF96E26656D
	for <linux-fscrypt@vger.kernel.org>; Mon, 21 Sep 2026 07:03:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.2
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789974224; cv=none; b=mb06balgFpEVoWHrPTQ24pVdMt5L62kAdbK2A8HZysp0ph0kLri7vTTNgAXiJ6XPH07T+u6824LGjSd5tz/JGX/KfSfXz6Bannxr/ej93xJj5VW6k9H3NW8x8/NgBCgdakf1bGFmW3DK9tfp7GLgvhfFzvCOE4H93xOCUnM61ww=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789974224; c=relaxed/simple;
	bh=WmDc0N1baiP/8WMRHDil/n3WL/xh4aCmEkI/IFkGwhA=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=ol7lbwKMMyLSSzbdh/dmhJ+KvNT3FqfPfnhvVK1I3jxN0Yvwe/23IfxcCkXIG0O4RNITZkXCPvCm1zf+rpOdIpVX2qiBd84GUGuuA41yXfYOzWw9Qo88QDP+RBhUVY+dmyNk1w3WOU7wWhJWQcHmqaBN+ZmQH7EjIRR12EM/NHA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=F7s8Zsc+; arc=none smtp.client-ip=91.218.175.2
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="F7s8Zsc+"
X-Envelope-To: linux-fscrypt@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=WmDc0N1baiP/8WMRHDil/n3WL/xh4aCmEkI/IFkGwhA=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1789974220; v=1; x=1790579020;
 b=F7s8Zsc+INX0m5yAUWTb7oLir5C5P+2JRBYIOQsffQHjDhXtp4WpzbmESuY4ndfYvaI6JtlZ
 OtLVefN2yT/B9XtQA06/hkgBhUSm51qKAnuI/mAm8PtfCWIo1aRmmUjsWJtqEzWU1GbyA5NnR+9
 GtV4savXtVGJIgwMBsAiF8sI=
X-Envelope-To: linux-fscrypt@vger.kernel.org
Received: by smtp.migadu.com with ESMTPS id 9f90210b135d8c77;
	Mon, 21 Sep 2026 07:03:39 +0000
X-Mizu-Trace-ID: 9f90210b135d8c77
X-Migadu-Flow: FLOW_OUT
Message-ID: <a44de8c6-a095-481b-80c5-5c61fad3151f@linux.dev>
Date: Mon, 21 Sep 2026 15:03:25 +0800
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v5 04/17] fscrypt: stop setting PG_private on bounce page
Content-Language: en-US
To: Zi Yan <ziy@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@suse.com>, Usama Arif <usama.arif@linux.dev>,
 Alistair Popple <apopple@nvidia.com>, "Liam R. Howlett"
 <liam@infradead.org>, Muchun Song <muchun.song@linux.dev>,
 Vlastimil Babka <vbabka@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 David Hildenbrand <david@kernel.org>, Nico Pache <nico.pache@linux.dev>,
 Baolin Wang <baolin.wang@linux.alibaba.com>,
 Ying Huang <ying.huang@linux.alibaba.com>,
 Suren Baghdasaryan <surenb@google.com>, Lorenzo Stoakes <ljs@kernel.org>,
 Mike Rapoport <rppt@kernel.org>, Eric Biggers <ebiggers@kernel.org>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>, Dev Jain
 <dev.jain@arm.com>, "Theodore Y. Ts'o" <tytso@mit.edu>,
 Barry Song <baohua@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>,
 Qi Zheng <qi.zheng@linux.dev>, Gregory Price <gourry@gourry.net>,
 Shakeel Butt <shakeel.butt@linux.dev>, Johannes Weiner <hannes@cmpxchg.org>,
 Kairui Song <kasong@tencent.com>, linux-fscrypt@vger.kernel.org,
 Ryan Roberts <ryan.roberts@arm.com>
References: <20260920-remove-pg_private-v5-0-bb68b6a21869@nvidia.com>
 <20260920-remove-pg_private-v5-4-bb68b6a21869@nvidia.com>
From: Lance Yang <lance.yang@linux.dev>
In-Reply-To: <20260920-remove-pg_private-v5-4-bb68b6a21869@nvidia.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit



On 2026/9/21 10:28, Zi Yan wrote:
> The pointer to a plain text folio is stored in bound_page->private and
> cannot be NULL until the bounce_page is freed, making PG_private redundant.
> 
> It prepares for a future commit that remove PG_private.
> 
> No functional change intended.
> 
> Assisted-by: LLM
> To: Eric Biggers <ebiggers@kernel.org>
> To: "Theodore Y. Ts'o" <tytso@mit.edu>
> To: Jaegeuk Kim <jaegeuk@kernel.org>
> Cc: linux-fscrypt@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Acked-by: Eric Biggers <ebiggers@kernel.org>
> Acked-by: Usama Arif <usama.arif@linux.dev>
> Acked-by: David Hildenbrand (Arm) <david@kernel.org>
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> ---

LGTM! Feel free to add:

Reviewed-by: Lance Yang <lance.yang@linux.dev>
