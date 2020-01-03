Return-Path: <SRS0=g9fr=2Y=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7403BC2D0C2
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 16:59:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 474A121734
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 16:59:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1578070796;
	bh=ZJB44nwQCm+aExn/7YF4Pm9qKNyOqji2YX/ddgZw6MA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=qnZzteFMmCGE7nfjsXYmZjLoCc/1pQLVYCgNqQkjMkZoyGV6ivoW97379RdIirA7M
	 twoXoFYK7Bd2s5knbvOa7RnP+Sgfl0R09WhyUaqDAAgZtybT3VyJXGrd2zw8XbSNrW
	 LqESOApNz6iT5ciMht7hT53RqTYoZL3ZsI/EVTks=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727952AbgACQ74 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 3 Jan 2020 11:59:56 -0500
Received: from mail.kernel.org ([198.145.29.99]:55582 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727769AbgACQ7z (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 3 Jan 2020 11:59:55 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id DC5C0206DB;
        Fri,  3 Jan 2020 16:59:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1578070795;
        bh=ZJB44nwQCm+aExn/7YF4Pm9qKNyOqji2YX/ddgZw6MA=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=d0ZSVo4iAU0Jg+Kfkv1mMZzq2u58fh94l/QoCV3mWj5kWbWEb1UzhtXhtNo726bmq
         AkaBMt9KkEU3NNLtx5TQsgoU/AMX1PwBNLaojqXGnkPYoY6gh4kP4e2l4RMTzNuyNb
         lMOYUHC7ztxrnnJ7QJ6IfLenIjd3r7FHx8ZMe2hU=
Date:   Fri, 3 Jan 2020 08:59:53 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fscrypt: introduce fscrypt_needs_contents_encryption()
Message-ID: <20200103165953.GH19521@gmail.com>
References: <20191209205021.231767-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191209205021.231767-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Dec 09, 2019 at 12:50:21PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Add a function fscrypt_needs_contents_encryption() which takes an inode
> and returns true if it's an encrypted regular file and the kernel was
> built with fscrypt support.
> 
> This will allow replacing duplicated checks of IS_ENCRYPTED() &&
> S_ISREG() on the I/O paths in ext4 and f2fs, while also optimizing out
> unneeded code when !CONFIG_FS_ENCRYPTION.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  include/linux/fscrypt.h | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
> index cb18b5fbcef92..2a29f56b1a1cb 100644
> --- a/include/linux/fscrypt.h
> +++ b/include/linux/fscrypt.h
> @@ -72,6 +72,21 @@ static inline bool fscrypt_has_encryption_key(const struct inode *inode)
>  	return READ_ONCE(inode->i_crypt_info) != NULL;
>  }
>  
> +/**
> + * fscrypt_needs_contents_encryption() - check whether an inode needs
> + *					 contents encryption
> + *
> + * Return: %true iff the inode is an encrypted regular file and the kernel was
> + * built with fscrypt support.
> + *
> + * If you need to know whether the encrypt bit is set even when the kernel was
> + * built without fscrypt support, you must use IS_ENCRYPTED() directly instead.
> + */
> +static inline bool fscrypt_needs_contents_encryption(const struct inode *inode)
> +{
> +	return IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode);
> +}
> +
>  static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
>  {
>  	return inode->i_sb->s_cop->dummy_context &&
> @@ -269,6 +284,11 @@ static inline bool fscrypt_has_encryption_key(const struct inode *inode)
>  	return false;
>  }
>  
> +static inline bool fscrypt_needs_contents_encryption(const struct inode *inode)
> +{
> +	return false;
> +}
> +
>  static inline bool fscrypt_dummy_context_enabled(struct inode *inode)
>  {
>  	return false;
> -- 
> 2.24.0.393.g34dc348eaf-goog
> 

Applied to fscrypt.git#master for 5.6.

- Eric
