Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F16F37A48B;
	Tue, 17 Feb 2026 21:14:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771362879; cv=none; b=e9yClgPBqmFeP92+gAedxbEuODiwCv0451TedyltJ2z3D450Y5ds6TTOB11Vnx2K+VoSOyXXR4D3O2tCyZMCveCK6p59pGJ7Bb/i3C4NfYimMOkQAGps6iiX32MYWaTNZdK776cbMWtUYm8e1kF3nf7keVxii14QPNnVYtqrJTE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771362879; c=relaxed/simple;
	bh=6hJdaM0GcFWek9dW3PnUx3HenDAaAnbR4Dj/tBebWTw=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=Z2bdHS4P5FBXtPMwxryn/dbI3Rp8ARDzkiz9VeQ6ozv0yWIzIN+k/CQGZ/cAb9OD/oaP7Uosudcm3/MjsfX8WdQNstQdkT0PSB00b0gKK/wclS2oFdPD3B4uiRWoES9a/qdGoygdRjQhifbRuGSrkyqgiqGFgaY080eG8mNDoN8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WsFF9vwt; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WsFF9vwt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 462D8C19425;
	Tue, 17 Feb 2026 21:14:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771362879;
	bh=6hJdaM0GcFWek9dW3PnUx3HenDAaAnbR4Dj/tBebWTw=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
	b=WsFF9vwt03+HzTrBKIZYHHMwK4vsplppy1D31u9WgBMUXk8vuJn6J4OT463b7vifv
	 /q4RmpKbTCO39kDYSi/wvWYXLjK4j+3Zlp5MGNklMb66vt39o+IzUML05u4JnwxoOM
	 3KgCHpN8wKZUIjkNykl25LJoMImsrjHj53tsvT8F+DVGuy5lvkhe5rWwlH0BhF6Dxn
	 EJ4uIa3GV1fqTFUjAsvX5UYszlhLzupZtNLtuN0vQ2JA8mIOlddCWI5pKgV45bzO0S
	 2eXZk/qsRCWRfYoqqtDIRZRxd8Olo1C+Irf4EyvpDpe93NUaFMqYbQcfZkTKXaQES2
	 spjfMrYBrbgdQ==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 4804B3806667;
	Tue, 17 Feb 2026 21:14:32 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [f2fs-dev] [PATCH 01/11] fscrypt: pass a real sector_t to
 fscrypt_zeroout_range_inline_crypt
From: patchwork-bot+f2fs@kernel.org
Message-Id: 
 <177136287109.643511.9798324970398190582.git-patchwork-notify@kernel.org>
Date: Tue, 17 Feb 2026 21:14:31 +0000
References: <20251118062159.2358085-2-hch@lst.de>
In-Reply-To: <20251118062159.2358085-2-hch@lst.de>
To: Christoph Hellwig <hch@lst.de>
Cc: ebiggers@kernel.org, brauner@kernel.org, tytso@mit.edu, djwong@kernel.org,
 linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org,
 adilger.kernel@dilger.ca, linux-fsdevel@vger.kernel.org, jaegeuk@kernel.org,
 linux-ext4@vger.kernel.org

Hello:

This series was applied to jaegeuk/f2fs.git (dev)
by Jens Axboe <axboe@kernel.dk>:

On Tue, 18 Nov 2025 07:21:44 +0100 you wrote:
> While the pblk argument to fscrypt_zeroout_range_inline_crypt is
> declared as a sector_t it actually is interpreted as a logical block
> size unit, which is highly unusual.  Switch to passing the 512 byte
> units that sector_t is defined for.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Eric Biggers <ebiggers@kernel.org>
> 
> [...]

Here is the summary with links:
  - [f2fs-dev,01/11] fscrypt: pass a real sector_t to fscrypt_zeroout_range_inline_crypt
    https://git.kernel.org/jaegeuk/f2fs/c/c22756a9978e
  - [f2fs-dev,02/11] fscrypt: keep multiple bios in flight in fscrypt_zeroout_range_inline_crypt
    https://git.kernel.org/jaegeuk/f2fs/c/bc26e2efa2c5
  - [f2fs-dev,03/11] fscrypt: pass a byte offset to fscrypt_generate_dun
    (no matching commit)
  - [f2fs-dev,04/11] fscrypt: pass a byte offset to fscrypt_mergeable_bio
    (no matching commit)
  - [f2fs-dev,05/11] fscrypt: pass a byte offset to fscrypt_set_bio_crypt_ctx
    (no matching commit)
  - [f2fs-dev,06/11] fscrypt: pass a byte offset to fscrypt_zeroout_range_inline_crypt
    (no matching commit)
  - [f2fs-dev,07/11] fscrypt: pass a byte length to fscrypt_zeroout_range_inline_crypt
    (no matching commit)
  - [f2fs-dev,08/11] fscrypt: return a byte offset from bh_get_inode_and_lblk_num
    (no matching commit)
  - [f2fs-dev,09/11] fscrypt: pass a byte offset to fscrypt_zeroout_range
    (no matching commit)
  - [f2fs-dev,10/11] fscrypt: pass a byte length to fscrypt_zeroout_range
    (no matching commit)
  - [f2fs-dev,11/11] fscrypt: pass a real sector_t to fscrypt_zeroout_range
    (no matching commit)

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


