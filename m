Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795561917;
	b=t+lhtunxQOjgzR2/PEVxqRhiQ3I9ah79SIG8SkhrG6goHuyfU6Xz6oAzyoVdbpBsO8Lm
	 oMoFCubVCsTNyOcUR+0VqEGUMql9OwRg00nKaeiHlKMWw0HDhYXKeUxHSVIfYksoEfGCR
	 ++MDIqdRfYC+DXvzi8GCmBTziOHNPljgW+dcjVLGeKrwSivPb2OCphykV80nLE0g7Grxn
	 txhjjo9lTGfEY7sTy0eEgCoSq/ATao55v/Q/OPYLmitcGYmmS3ziEECDZGXCn+6aQvItN
	 iyqRS9W9kcoQVEQhmRFOtSl6BhKOwqSAFdYhwSIAP4xNifVTM1VW7z7su25GM7H0h2Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795561917;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=QXxayGQ5zDJmW5qRYFz3W+oneeyzIOwcisMq8eZ3yFw=;
	b=k28hr6EV57lSpTIvihgUbg8BYmq9zseDnCFeHI4OjSApTURP2yBOzjRB2sxUzBPGJgK6
	 fWQgytQWMA/PPLzglTapZh3xNgbOQwe7bTUd1f+A1u0AcDP43Q7Qlxcbez9BLQ6FUaPUm
	 E2WfzrfTK7vFLv4cSd94dq1gyV3eoth5QoB8bdJ5GUTp8FZnDOaVxvA1H+XiSabO3i5aG
	 liXMWP6NfGujkrsxs1RnG2+A/GSmugR5Eo5bYqPw/KDhrMRHgm5+F1YAFni9Hk2Nb4+jE
	 W0D/WaPSV+ISWEpetl9qGj/l/CNnIlQKRbqxRu+ibKOFiHCVRdDEelXqVN+QeFO4YLg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W3y88tmj;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B924606A31E;
	Tue, 24 Nov 2026 23:11:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=W3y88tmj
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B03D61F000C6;
	Tue, 24 Nov 2026 23:11:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795561917;
	bh=QXxayGQ5zDJmW5qRYFz3W+oneeyzIOwcisMq8eZ3yFw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=W3y88tmj+TqN3sWdK2x05TghZqa+qDv9MXmU3/QPFA2AT98lD6/qJZ3933xeNZZUL
	 mFbgAjZxP3YQfFNGN/E6aq6xHvwq3926/J7i7Ox/gvjyfKu/Jlr/F+6FE6JUy3P4Is
	 6MdPs7dA0CFFOn8AwQK+1AsBSZLa2HZ0FGDt6VcRVLyFogg1MgzTckmIzazFX4Qe7P
	 iFc01fx5AJywo5WpZQFnkHf0EnpzryblgxonC0zrk1gaPk9SkFDRC8a32P1yoFcKpj
	 7HJT1DGrf8SZho5WvdsGUF3oCPgBlo4X/7mshT91A9EhlmNM3yivKhK6IJrlXuYV1U
	 dUiEIUxoIk7dg==
Date: Tue, 24 Nov 2026 15:11:55 -0800
From: Eric Biggers <ebiggers@kernel.org>
To: Thorsten Blum <blum@kernel.org>
Cc: David Sterba <dsterba@suse.com>, Chris Mason <mason@kernel.org>,
	Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>,
	Richard Weinberger <richard@nod.at>,
	Zhihao Cheng <chengzhihao1@huawei.com>,
	"Theodore Y. Ts'o" <tytso@mit.edu>, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH 0/4] fscrypt: Add FSTR() helper macro and convert
 initializers
Message-ID: <20261124231155.GB2001@quark>
References: <20261118002845.574426-6-blum@kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261118002845.574426-6-blum@kernel.org>

On Wed, Nov 18, 2026 at 01:28:46AM +0100, Thorsten Blum wrote:
> Similar to QSTR(), add FSTR() to initialize struct fscrypt_str from a
> NUL-terminated string without specifying its length.
> 
> Use the helper for 8 initializers in btrfs, F2FS, and UBIFS, replacing
> hard-coded lengths and explicit strlen() calls.
> 
> Thorsten Blum (4):
>   fscrypt: Add FSTR() helper macro
>   btrfs: Use FSTR() for the "default" name
>   f2fs: Use FSTR() in f2fs_do_make_empty_dir()
>   ubifs: Use FSTR() in ubifs_xattr_{set,get,remove}()
> 
>  fs/btrfs/inode.c        | 3 +--
>  fs/btrfs/ioctl.c        | 3 +--
>  fs/btrfs/super.c        | 3 +--
>  fs/f2fs/dir.c           | 7 ++-----
>  fs/ubifs/xattr.c        | 6 +++---
>  include/linux/fscrypt.h | 1 +
>  6 files changed, 9 insertions(+), 14 deletions(-)

Applied to https://git.kernel.org/pub/scm/fs/fscrypt/linux.git/log/?h=for-next

- Eric
