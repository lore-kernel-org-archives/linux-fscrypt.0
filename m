Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28E2F38B13C;
	Wed, 24 Jun 2026 08:28:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782289711; cv=none; b=uUGlT2RWIPe1USsmOsoUU9KI2nGmmIEL3gJzM/Y1hNr9V/odJd2wqMJAcpnAVk3bORMrITq6Foa3oU4b1bO13soK30/ZMdt0JQ5nHrRBibg4S1doklczEPXyd/fsfyLxdMp66S0q9TL+IFNf65OlDVmBxR2xBYwgDkFkAsc7uXA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782289711; c=relaxed/simple;
	bh=bYlj+fmXYWJzCmxqy42ZJ0mafGhITdkZePh/6u32QC8=;
	h=Message-ID:Date:MIME-Version:Cc:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=W4QAcZ+UwR2EVEbaM3Xd/Eu1NS9aLgeM9iNvKOprkGubX5thPA11bUnORMa3l3Vkd7Zxb1Xc5rje2+kbZZB0rqscK0aJ8VBNtMNr7OLb9lPjns+deVVxxZYN7oxs5H9ttgQecZNQlBaWJW+LlBd2nH0noljsocXewN+oGHA3SMM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nbjVXSoh; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nbjVXSoh"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BF6E71F000E9;
	Wed, 24 Jun 2026 08:28:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782289710;
	bh=Wfh/P99IwchT4VHP5S2uoDUD6OJUbSYALHpjt96hxt8=;
	h=Date:Cc:Subject:To:References:From:In-Reply-To;
	b=nbjVXSoh8lGDMcEIFETBOWr5/TbVI4Pz/S7rlr+ncCl83wfEgJHEb7rLLiajGp/E3
	 +yHKC/8QmnNc2OAVgoUzViGGC0hCoFKu6+4k/WTGpAhZqiobITU5USuzX1Q9+9DpsU
	 85I+VhDlDkE+l4R+pU1fRN+oDhLs1y3Bb+Nb5uHFxzVRq+AR7qPv6qKr0Fk5zl/mJt
	 OP30YI7TfSb3Zk6aKMKKeXMfsRYynv8QyFwclKvvtS2CnByblgsuB5o+pFzppXrZTZ
	 pA7UydHKJrEdOqukbouVQwh0FPC/iiNRMejeDZKRJxS7TbZ5AZs3ga7zRGhV6pSRJc
	 RLeut/SZoFwxA==
Message-ID: <d25d1fb2-de6d-4a92-a798-fd304e8e5654@kernel.org>
Date: Wed, 24 Jun 2026 16:28:26 +0800
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Cc: chao@kernel.org, linux-fscrypt@vger.kernel.org,
 linux-f2fs-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
 jaegeuk@kernel.org, Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] fscrypt,f2fs: introduce fscrypt_finalize_bounce_folio()
 for cleanup
To: Eric Biggers <ebiggers@kernel.org>
References: <20260622011539.2292553-1-chao@kernel.org>
 <20260623232926.GA7864@quark>
Content-Language: en-US
From: Chao Yu <chao@kernel.org>
In-Reply-To: <20260623232926.GA7864@quark>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 6/24/26 07:29, Eric Biggers wrote:
> On Mon, Jun 22, 2026 at 01:15:39AM +0000, Chao Yu wrote:
>> As part of the linux kernel's migration to folio-based APIs, introduce
>> fscrypt_finalize_bounce_folio() as the folio equivalent of
>> fscrypt_finalize_bounce_page(), and clean up f2fs codes with this new
>> helper.
>>
>> Suggested-by: Matthew Wilcox <willy@infradead.org>
>> Cc: Eric Biggers <ebiggers@kernel.org>
>> Signed-off-by: Chao Yu <chao@kernel.org>
>> ---
>>
>> Is it worth to introduce fscrypt_finalize_bounce_folio(), then try to
>> do clean in f2fs_write_end_bio() first, and then replace
>> fscrypt_finalize_bounce_page() later?
> 
> I'm working on making ext4 and f2fs always do file contents
> en/decryption using fscrypt_set_bio_crypt_ctx(), which already supports
> large folios and doesn't require the filesystem to manage bounce
> buffers.  I don't think these minor tweaks to the other implementation
> (which don't actually make it support large folios) accomplish anything
> useful, and we should focus on removing it instead.

Good, I see your patchset removing those codes, let's ignore current patch.

Thanks,

> 
> - Eric

