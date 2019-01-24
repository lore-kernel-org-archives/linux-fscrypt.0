Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53810 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726015AbfAXXvs (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 24 Jan 2019 18:51:48 -0500
Date: Thu, 24 Jan 2019 15:51:46 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] MAINTAINER: add Eric Biggers as an fscrypt maintainer
Message-ID: <20190124235145.GC10448@gmail.com>
References: <20190124214224.18563-1-tytso@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124214224.18563-1-tytso@mit.edu>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Theodore Ts'o <tytso@mit.edu>
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jan 24, 2019 at 04:42:24PM -0500, Theodore Ts'o wrote:
> Also update the location of the git tree as we will be using a shared
> git tree.
> 
> Signed-off-by: Theodore Ts'o <tytso@mit.edu>
> ---
> 
> (This is assuming we get the git tree location that I requested in the
> ticket to Konstantin and his team, of course.)
> 
>  MAINTAINERS | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 51029a425dbe..419b326e711a 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -6193,9 +6193,10 @@ F:	include/linux/fscache*.h
>  FSCRYPT: FILE SYSTEM LEVEL ENCRYPTION SUPPORT
>  M:	Theodore Y. Ts'o <tytso@mit.edu>
>  M:	Jaegeuk Kim <jaegeuk@kernel.org>
> +M:	Eric Biggers <ebiggers@kernel.org>
>  L:	linux-fscrypt@vger.kernel.org
>  Q:	https://patchwork.kernel.org/project/linux-fscrypt/list/
> -T:	git git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git
> +T:	git git://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git
>  S:	Supported
>  F:	fs/crypto/
>  F:	include/linux/fscrypt*.h
> -- 
> 2.19.1
> 

Acked-by: Eric Biggers <ebiggers@kernel.org>
