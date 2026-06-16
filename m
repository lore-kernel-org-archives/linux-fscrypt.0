Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 01D9B2D12EC;
	Tue, 16 Jun 2026 23:02:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781650938; cv=none; b=moBhYf27SrAkl5DUF0QrmxCpWXAm2mlszhlcNzKXV+EMGWCc3/XM20lg4kn4+xUPfIyPwc/23rkAUiPSSD0IkvDxWqTiEEuh4EiBr5eIdXkGcV0vLocc6NCETAZ4hrz3Hbov5w0AE01u4+P5jPE31guSvJbaF16G34uF4PsmnRA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781650938; c=relaxed/simple;
	bh=Dq2XvKfdYhSbvZxkXcwcL7/IoWIBOMEcHJflP3/VUWE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=eB/46qxrMJvCEV7vwfaA5J0g9nrSIg+FgyVp2aSmQDxH+jrrLBYmYQClAJVEAyWAf3pKAWJPblGYh6M5dc8Zq3Pzmi0I49x2KZ/HI2RtmOEtSBYLN3dIhmK3IBriqSfhV1hh7rE/kAZ+/N5iyrmnXyA3buCPxPDDRT6WmfY3s3Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UiXgzW7o; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UiXgzW7o"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 32AF71F000E9;
	Tue, 16 Jun 2026 23:02:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781650937;
	bh=ALycoJqF47JiSW3q3qosjWMWmgc4Rn8LlDIDcPMChlY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=UiXgzW7oJNp5oLHQKJ+Gv76OvpIPe8p65skAe0t9XSOL1cp39mb+FBktdJzMe4adZ
	 WyeS9jMjNt0JXod4D1pdLs+el05lNXdpqmbq1OaAwdax0uwpGy51feTDK0YxyHMp3+
	 xsE5MurJ4YYrePYXaiTgY0ApjU5KX9/Ts1LTERPAOcvKW/Ag8c9aP7MuRf0oPx19DW
	 NQpHR2qrvunvGzI/1Vd2XfQl3tI82+QD39dRBxAWNjUFrTjfWUJzpezsx5tzS0Sgoz
	 phE0PvPHxbC3DVPDhs699/3Zan6/0cDsBVpJ11iA6lgAFzILlc9I76mTpqOkLtRxh5
	 +s+L4S8Nk66TQ==
Date: Tue, 16 Jun 2026 16:02:15 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: LiaoYuanhong-vivo <liaoyuanhong@vivo.com>
Cc: chao@kernel.org, corbet@lwn.net, jaegeuk@kernel.org,
	linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-fscrypt@vger.kernel.org, linux-kernel@vger.kernel.org,
	skhan@linuxfoundation.org, tytso@mit.edu
Subject: Re: [PATCH v3 0/3] f2fs: support encrypted inline data
Message-ID: <20260616230215.GA1873@quark>
References: <20260615193728.GA1764@quark>
 <20260616094612.45505-1-liaoyuanhong@vivo.com>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260616094612.45505-1-liaoyuanhong@vivo.com>

On Tue, Jun 16, 2026 at 05:46:12PM +0800, LiaoYuanhong-vivo wrote:
> Could you share more about the direction you have in mind for simplifying
> f2fs/ext4 contents encryption around blk-crypto?

Currently ext4 and f2fs each have two implementations of file contents
encryption and decryption:

- One where the en/decryption is done in the filesystem layer

- One where the filesystem attaches a bio_crypt_ctx to the bios and the
  en/decryption is done either in the block layer by blk-crypto-fallback
  or by inline encryption hardware

I'd like to drop the first one, for simplicity and to reduce the burden
on ongoing developments like large folio support.

> For f2fs inline_data, there is still a real space-saving benefit on phones,
> since many encrypted files are smaller than 4K. Is there any acceptable
> future direction to support this kind of inode-resident data with
> blk-crypto or hardware-wrapped keys?

It is incompatible with inline encryption hardware.  A CPU-based
solution like Intel Key Locker or RISC-V High Assurance Cryptography
could provide similar security properties.  But there's nothing for
arm64 yet.  And I should mention that no one has wanted to use Key
Locker anyway because it's really slow.

- Eric
