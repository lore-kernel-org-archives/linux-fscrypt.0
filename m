Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CFF8030DECE;
	Thu, 15 Oct 2026 19:38:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792093083; cv=none; b=VRRSA4oawdLjvZmdKrR4ZkXkUi2I5eo7n5Rqnwc/bMZ1Sw0r1xLo2D7wqa29qgw98ZQRst64cBP04jaqikd5FEgvhK2c26ASg6f1eJxX3fKey0xa3UZjtrCUtA8/u8ezJzsMGd2NeNMQDuEJZ8n0jW7YLTSgUdx8wUV/rfKUaMc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792093083; c=relaxed/simple;
	bh=SnTbC+SB724atHlEOq6yr2otqGLrkeDfMLW+sthUORI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=hfb143u7nOr2mHyVB6V3KFU4DzUXOD7p6ALviI1nnFd4UGoQnhO6tG7TZXsLFWesUAtFdwEkyjhzyLl0cwuDo/KjLJja6mEm2elkW1Ru/Hwjdn9LQE97lZRCjnSqeEUuNA7OqcIItiKk0zQhxCdgHarvE3huc1MCUs9c2R0ylUM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Cpd6cuKq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Cpd6cuKq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5C9F61F000C4;
	Thu, 15 Oct 2026 19:38:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792093082;
	bh=MCzfw+3JLfOteu1hixOiVvtb5qCqzuwkXWc5kuMnKuo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Cpd6cuKqQNWWSQDH/XjHeZzEC3tdAsa9kDWZeSXYYLPNnaeybgxf9XnwKQd1pmRuX
	 1tSemSJQlnRFqv4QKeLGgeM5/RUVOe4OxLRuDhhFs+dTKBNwOL1ZqKaBTfb0Twn5RU
	 zf87HWflXcClsq2QuZjnXCHEbtE6PEASKz1YOeQtNGvoC9Nh16lKPIkErWpM1OSLKg
	 4Xg4e17H1fvzTSHk057t4Z0BpTadt4bYBHjl5I7AngjAopKkyJAKLUSvEcfzKTK/5x
	 zT/v/nvGm9OHPnqi4FvXS+7vocpglkQn0u2r4CPZETVJ8DP0I5/oSODeW+8ebjcdPF
	 YJxAWSUxhDFWg==
Date: Thu, 15 Oct 2026 19:38:00 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Alex Markuze <amarkuze@redhat.com>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Ilya Dryomov <idryomov@gmail.com>,
	Xiubo Li <xiubo.li@clyso.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] fscrypt: allow filesystems to disable symlink target
 caching
Message-ID: <20261015193800.GH2170687@google.com>
References: <a01d0a297a3e174d21741a3ad586ce546327603e.1792081664.git.amarkuze@redhat.com>
 <20261015183548.GE2170687@google.com>
 <CAO8a2Sjr6XSizdgobZK1ZAO8PUd5tCDFKjdD-=3TXHwqOU6qfg@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAO8a2Sjr6XSizdgobZK1ZAO8PUd5tCDFKjdD-=3TXHwqOU6qfg@mail.gmail.com>

On Thu, Oct 15, 2026 at 09:52:11PM +0300, Alex Markuze wrote:
> Hi Eric,
> 
> This supports the concurrent CephFS subvolume quarantine series.
> There’s no Fixes: tag since this isn't addressing an existing upstream
> regression.
> 
> The quarantine series adds checks to Ceph's ->get_link(). However, if
> an encrypted symlink target was cached prior to quarantine, the VFS
> bypasses that callback entirely when following or reading it. While
> the target data is still valid, access now needs to be denied.
> 
> This patch adds an opt-out for symlink caching and enables it for
> Ceph, handling the encrypted-symlink case for the concurrent series
> without affecting other filesystems.
> 

That series wasn't sent to me.  Is it
https://lore.kernel.org/r/cover.1792074165.git.amarkuze@redhat.com/ ?
It would make more sense to add this patch to that series so that they
can be reviewed together.  I can potentially apply a prerequisite patch
by itself, but we'd first need to know that the rest has been reviewed
and will be accepted too, otherwise it will be unused code.

- Eric
