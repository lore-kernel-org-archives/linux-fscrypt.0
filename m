Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 18755155A5D;
	Fri, 27 Feb 2026 21:54:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772229299; cv=none; b=kTenhFii2zbL5yUOdetizpzrdvTclz1IR1HhNNoD7Sv/BkYt5gD3bU/04u5s1SanRjlqJzXPNE3y5oIOheTu3dLKvPYPDwKiTr8jb+iFmUj6jbTFX8wVhLxJ6mmn9T6GggSJrHtUc08F/w2MbCsg/qMtCcwbftg9uUH7DnxwDGo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772229299; c=relaxed/simple;
	bh=UikkZbYLh7UkDKvyWFqmlnIn0V1F3Jk/3G9UbSWnjS8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Yh3u4Hytdmpe7L3TLvmEPoFDRZQ+QW5WM4KdOaZjsSM7Rr2xQm45Qa1L8n8fhWbhgVJwF1jIxqgwKWhvq3Qcucfg7jNtCrUemJDxllbsEIjgu4JywL3ZOfXqFzGRSZkpNv6NZCAKiKDZyHqrrIv/S9egztDQubF17NuJBdwpY1g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mvLbwleN; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mvLbwleN"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 303D9C116C6;
	Fri, 27 Feb 2026 21:54:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772229298;
	bh=UikkZbYLh7UkDKvyWFqmlnIn0V1F3Jk/3G9UbSWnjS8=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=mvLbwleNM8TqC5QDCHByakJS6CS1NQf/QA0pwoOQE3EdCGWgekRNueF/YHffICUY1
	 i8rOse3dzLsCGgcQrGkZ7KXFS7jifPqH/PnV4QGFM1UH/LDk1iy+XXjkDrv39ZXXCg
	 eeqBkqUFVfi6y4+//0wss1dh254ZH13XedVZD71NDVpXK81nBwXHYEpB2BhGiO4Klx
	 Vwf/0sWjCo6jH70VW0AIPE4rVwkjPbtxNLMAbw6s9XalKXRgRXCIgvhndKRJPRjE+4
	 sdb0kLJzlEy88ar5nTaCahDQ5oC2uX8vqqB1fx7QzfrWCfhrt+UzBSWdp/qo+UNQNP
	 DYAbtrpnn2c4g==
Date: Fri, 27 Feb 2026 13:54:50 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Chao Yu <chao@kernel.org>, Christian Brauner <brauner@kernel.org>,
	"Darrick J. Wong" <djwong@kernel.org>,
	linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 05/14] fscrypt: move fscrypt_set_bio_crypt_ctx_bh to
 buffer.c
Message-ID: <20260227215450.GA5357@quark>
References: <20260226144954.142278-1-hch@lst.de>
 <20260226144954.142278-6-hch@lst.de>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260226144954.142278-6-hch@lst.de>

On Thu, Feb 26, 2026 at 06:49:25AM -0800, Christoph Hellwig wrote:
> Note that this does not add ifdefs for fscrypt as the compiler will
> optimize away the dead code if it is not built in.

The call to folio_mapping() isn't optimized out, so it might still be
worth adding an IS_ENABLED(CONFIG_FS_ENCRYPTION).

- Eric
