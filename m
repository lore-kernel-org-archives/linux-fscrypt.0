Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 770BB427F94;
	Mon,  3 Aug 2026 18:40:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785782424; cv=none; b=eX80VRzHDefBNF9z06qvimuJj6dBa9JJ3O+45WmbRUwnOZcSRBZxCqw/TBW76THrzBcFAPMmsZM5KiYzQmFzpx+J+qD2QyDZfpU+1/iyT9efqaBQwA0C6Pys53/NWWvgVUgQnIJ+dKl29ijl5LuRF4jjSoHbOQxlr5hCnrbPwGU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785782424; c=relaxed/simple;
	bh=qrs3OuSEPYJxFSTbHH1zu4mbNnrytcUivCS9s79+9ro=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=mF3FdNADH6X+My5xxRzd3EyQ5N0FNAHi4bOapt89iykS2/yrVOit+h7Tskzhq9AnGQoUcWqZl1GmuWLudej1BvN0i2xwq5yFRYvFQYOTlYEnKLhUH9kFOG0LbwOoYSjl4sRMkOk2vV41gyOTmmVsc90enhYOlt149cmeYIg0fLo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ewuN8cuG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ewuN8cuG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3022C1F000E9;
	Mon,  3 Aug 2026 18:40:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785782423;
	bh=vZb15sPo5N1TfPjLBzaNxLa5T1EMEuStHZ3GRvUGF+E=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=ewuN8cuG7auUrC7UW93BEXpJZzHXJryz6zIWqRe/yq9BMaTlYjkUb28PRwxSvit0y
	 2pDbSrYNK7TfuZmyUpGZEGEIV8ppjlFGZzpHg0H0VrHjc2wCuS+q+H/vxdHWzEjkhR
	 q6mr2g6ltg5Yn8xfzRIdBbpHY6qb1tYvh0UN2HC5cdtNrsbnW5+r1nT9Bja/o/FhlB
	 D277qAmcxpkZU2XPn/KOMlTi8XaI/s041vXXxE0XKXuGivOMw45WRqW93vkF00kggr
	 j9OzfuJoeS9E1sEE2NU2gxILZelXTQp2gLQc/LVID10reyC4xYci3Yf6/QtlAilc0y
	 OK/54yFAKSDBQ==
Date: Mon, 3 Aug 2026 11:40:20 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: Zi Yan <ziy@nvidia.com>
Cc: David Hildenbrand <david@kernel.org>,
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
	Ryan Roberts <ryan.roberts@arm.com>, Dev Jain <dev.jain@arm.com>,
	Barry Song <baohua@kernel.org>, Lance Yang <lance.yang@linux.dev>,
	Usama Arif <usama.arif@linux.dev>,
	Gregory Price <gourry@gourry.net>,
	Ying Huang <ying.huang@linux.alibaba.com>,
	Alistair Popple <apopple@nvidia.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Qi Zheng <qi.zheng@linux.dev>,
	Shakeel Butt <shakeel.butt@linux.dev>,
	Kairui Song <kasong@tencent.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, "Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH RFC 04/14] fs/crypto: stop setting PG_private on bounce
 page
Message-ID: <20260803184020.GC2062@quark>
References: <20260731-remove-pg_private-v1-0-142c97ba3562@nvidia.com>
 <20260731-remove-pg_private-v1-4-142c97ba3562@nvidia.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260731-remove-pg_private-v1-4-142c97ba3562@nvidia.com>

On Fri, Jul 31, 2026 at 10:13:27PM -0400, Zi Yan wrote:
> The point to a plaintext folio is stored in page->private and cannot be
> NULL, making PG_private redundant.
> 
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

Acked-by: Eric Biggers <ebiggers@kernel.org>

- Eric
