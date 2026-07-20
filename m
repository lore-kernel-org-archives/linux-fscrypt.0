Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA79E4611C2;
	Mon, 20 Jul 2026 17:47:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784569662; cv=none; b=fyyO+/lS/umtcdB6gwFpiV9VBTH7lv4VWrDEAJ28Kafeh7bUeCpohqkXX0RXXfWnjiFed3lP8nWFK6kK61gP3s43XMhxG+3DMyG1j3+1PbOQ6mqqLbEbgtdMsuqEtWH52aCxmOpDzqn1avf1vd1qpIELg7kHTlkAzzhMmf8rSFs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784569662; c=relaxed/simple;
	bh=cK27zPxsS2N305a4lo83MLMzknfsp+whs3hEwpIQ7Xg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=pqn/ssDbpQsGgLh2xzvTlxSN+V8YzbRTj60atsqjKVe4WnUW7+HZVkXCCYgS2ua+dUDnazOeOjl7E2vQhed645aSiHLsIg8tbNJ1FQsq7J6yP/fWHCuagIm4ZFDW+YAaAn03UBH4I1ag727dU2H0iTD3SHbPKU//njNm8/VpeYY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iwI8+6vF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iwI8+6vF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 50BE11F00A3D;
	Mon, 20 Jul 2026 17:47:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784569649;
	bh=ygJ9w2pcuUZwsczxOPAI+JOYFdhJxWhwriXfRTy3dpY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=iwI8+6vFI8XvVER2dBvDl5GXozDe1hTqc2zTGQaNU5Nnq+0jOggQjKHqktA2JSmE1
	 oJ992KbeJryvnEg2kFHlrDZ3uauwTWJwG6M91SAhKcDDe8F4bgAtU2EEyVlohun9xQ
	 l9cIolxVYo8ChN+8vpTao6Mvdccg7SlclY2f7cy3pW4TGa46IhQ2ph8uIRpgBQ+nyX
	 2rXSUbkM1L6xxKWJLCX4JSN3mmP74FJm+u0O6f2MFAuFFpAhkSFW445b4qbFFVRT9B
	 tslwZpq4ZYGzhMm5UJ3j2hYYJt/QYbTmQvHCBtsZp1JgIBoyAMHKDLlhbmlwEwMtru
	 xSQYpuRNzqXYw==
Date: Mon, 20 Jul 2026 10:47:28 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org
Subject: Re: [PATCH] fscrypt: Update encryption policy version docs
Message-ID: <20260720174728.GF1865@quark>
References: <20260718212526.53943-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260718212526.53943-1-ebiggers@kernel.org>

On Sat, Jul 18, 2026 at 02:25:26PM -0700, Eric Biggers wrote:
> Update the wording of the documentation to put v1 encryption policies a
> bit more firmly in the past, explicitly calling them "deprecated" (which
> is consistent with the warning message the kernel has printed ever since
> v5.4).  Do the same for FS_IOC_GET_ENCRYPTION_POLICY which supports only
> v1 policies, and remove the explicit recommendation to fall back to it.
> 
> Also clarify that reusing master keys across policies isn't the best
> practice or normal usage, even though it's technically allowed for v2.
> 
> Signed-off-by: Eric Biggers <ebiggers@kernel.org>
> ---
> 
> This patch is targeting the fscrypt tree

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
