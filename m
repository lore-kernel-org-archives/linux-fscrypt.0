Return-Path: <SRS0=0CXL=C6=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE5F1C4727C
	for <linux-fscrypt@archiver.kernel.org>; Mon, 21 Sep 2020 22:35:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id AC124207C3
	for <linux-fscrypt@archiver.kernel.org>; Mon, 21 Sep 2020 22:35:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600727743;
	bh=ExqIl0YkOtLFrexAc1ymB2vJkK5wR30GfM+4x0tsJS4=;
	h=Date:From:To:Subject:References:In-Reply-To:List-ID:From;
	b=EsAjIAr08irKp0LnDrucafKB+QF0zME3SsT8QKcSOL3jmx4I6RI4ME8KudW7l0Ip6
	 y7MO7YM0eGnolVbW+QkJYb50wXtOMHN8MS8WLiqOKXMmCTITz2qlaxaz/tmSTueaRi
	 5k220F4iSwXUjJiBDthVjXR9PXqKdddBvjOpBqj4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728458AbgIUWfn (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 21 Sep 2020 18:35:43 -0400
Received: from mail.kernel.org ([198.145.29.99]:50466 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726457AbgIUWfm (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 21 Sep 2020 18:35:42 -0400
Received: from sol.localdomain (172-10-235-113.lightspeed.sntcca.sbcglobal.net [172.10.235.113])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4A884207C3
        for <linux-fscrypt@vger.kernel.org>; Mon, 21 Sep 2020 22:35:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600727742;
        bh=ExqIl0YkOtLFrexAc1ymB2vJkK5wR30GfM+4x0tsJS4=;
        h=Date:From:To:Subject:References:In-Reply-To:From;
        b=Mu2sIfR5dyTuScywZvgjIzj+kT4g8LfKkf0LeIwB1+bOnlK67ZEx93aYTARA2ulJj
         KqUiG4vjmKqyPUx+MAhwBaiUNQtxTyukJhnVwQiR0vAzBHLj2LylWVE4dEm4kWiE+I
         HMyQnWIFcw2sd/DPuXd2/PSUj3y1JaQ36jKs8bkU=
Date:   Mon, 21 Sep 2020 15:35:40 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH] fscrypt: use sha256() instead of open coding
Message-ID: <20200921223540.GC844@sol.localdomain>
References: <20200917045341.324996-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200917045341.324996-1-ebiggers@kernel.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Sep 16, 2020 at 09:53:41PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Now that there's a library function that calculates the SHA-256 digest
> of a buffer in one step, use it instead of sha256_init() +
> sha256_update() + sha256_final().
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/crypto/fname.c | 23 +++++++----------------
>  1 file changed, 7 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
> index 47bcfddb278ba..89a05e33e1b3b 100644
> --- a/fs/crypto/fname.c
> +++ b/fs/crypto/fname.c
> @@ -61,15 +61,6 @@ struct fscrypt_nokey_name {
>   */
>  #define FSCRYPT_NOKEY_NAME_MAX	offsetofend(struct fscrypt_nokey_name, sha256)
>  
> -static void fscrypt_do_sha256(const u8 *data, unsigned int data_len, u8 *result)
> -{
> -	struct sha256_state sctx;
> -
> -	sha256_init(&sctx);
> -	sha256_update(&sctx, data, data_len);
> -	sha256_final(&sctx, result);
> -}
> -
>  static inline bool fscrypt_is_dot_dotdot(const struct qstr *str)
>  {
>  	if (str->len == 1 && str->name[0] == '.')
> @@ -366,9 +357,9 @@ int fscrypt_fname_disk_to_usr(const struct inode *inode,
>  	} else {
>  		memcpy(nokey_name.bytes, iname->name, sizeof(nokey_name.bytes));
>  		/* Compute strong hash of remaining part of name. */
> -		fscrypt_do_sha256(&iname->name[sizeof(nokey_name.bytes)],
> -				  iname->len - sizeof(nokey_name.bytes),
> -				  nokey_name.sha256);
> +		sha256(&iname->name[sizeof(nokey_name.bytes)],
> +		       iname->len - sizeof(nokey_name.bytes),
> +		       nokey_name.sha256);
>  		size = FSCRYPT_NOKEY_NAME_MAX;
>  	}
>  	oname->len = base64_encode((const u8 *)&nokey_name, size, oname->name);
> @@ -496,7 +487,7 @@ bool fscrypt_match_name(const struct fscrypt_name *fname,
>  {
>  	const struct fscrypt_nokey_name *nokey_name =
>  		(const void *)fname->crypto_buf.name;
> -	u8 sha256[SHA256_DIGEST_SIZE];
> +	u8 digest[SHA256_DIGEST_SIZE];
>  
>  	if (likely(fname->disk_name.name)) {
>  		if (de_name_len != fname->disk_name.len)
> @@ -507,9 +498,9 @@ bool fscrypt_match_name(const struct fscrypt_name *fname,
>  		return false;
>  	if (memcmp(de_name, nokey_name->bytes, sizeof(nokey_name->bytes)))
>  		return false;
> -	fscrypt_do_sha256(&de_name[sizeof(nokey_name->bytes)],
> -			  de_name_len - sizeof(nokey_name->bytes), sha256);
> -	return !memcmp(sha256, nokey_name->sha256, sizeof(sha256));
> +	sha256(&de_name[sizeof(nokey_name->bytes)],
> +	       de_name_len - sizeof(nokey_name->bytes), digest);
> +	return !memcmp(digest, nokey_name->sha256, sizeof(digest));
>  }
>  EXPORT_SYMBOL_GPL(fscrypt_match_name);
>  

Applied to fscrypt.git#master for 5.10.

- Eric
