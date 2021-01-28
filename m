Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F563C433DB
	for <linux-fscrypt@archiver.kernel.org>; Thu, 28 Jan 2021 20:22:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DED4664DF5
	for <linux-fscrypt@archiver.kernel.org>; Thu, 28 Jan 2021 20:22:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231249AbhA1UWZ (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 28 Jan 2021 15:22:25 -0500
Received: from mail.kernel.org ([198.145.29.99]:50172 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231159AbhA1UWE (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 28 Jan 2021 15:22:04 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id 61B7B64DFA;
        Thu, 28 Jan 2021 20:21:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1611865283;
        bh=wUztWM1ZKbocb+veVwcbEJQ6urGqp9hVWvYg5OrM/bA=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=i1P6PKdw6gi7+JXGPVqyArGEe2++uOeL/yP+qgTYUIBuYEMFl+ACG80TUhh2rfRl+
         9YdwsW9jPed+iQoSPQSMXmLTLvQ9gTgPQcDp77r4Ygzw2GJGlWicdJS1mdLcY4vx/3
         doqM8S4WbIAhBWh5E2OEjVbs9vC2Qc6ylj39GxLyqfh0ObMHiJ8dYt74uFs7W6waI2
         lAkPlBIwm9o02AXsyiK90wDh/3c8NwlOVKdiyS7P2vl2DXTeMCPXtK7avYLZ5ZcJ+I
         HwMQkHn5wttyQiut3wFzf+vGADzXxHanQNV3eCiFHDlDa8e3YfDBNENNdU63m69hcn
         MmAOungbQdvJA==
Date:   Thu, 28 Jan 2021 12:21:21 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     Stephan =?iso-8859-1?Q?M=FCller?= <smueller@chronox.de>
Cc:     herbert@gondor.apana.org.au, Jarkko Sakkinen <jarkko@kernel.org>,
        mathew.j.martineau@linux.intel.com, dhowells@redhat.com,
        linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-kernel@vger.kernel.org, keyrings@vger.kernel.org,
        simo@redhat.com
Subject: Re: [PATCH v2 7/7] fs: HKDF - remove duplicate memory clearing
Message-ID: <YBMcwcWFgolygTbs@sol.localdomain>
References: <1772794.tdWV9SEqCh@positron.chronox.de>
 <8714658.CDJkKcVGEf@positron.chronox.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8714658.CDJkKcVGEf@positron.chronox.de>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Sun, Jan 24, 2021 at 03:04:50PM +0100, Stephan Müller wrote:
> The clearing of the OKM memory buffer in case of an error is already
> performed by the HKDF implementation crypto_hkdf_expand. Thus, the
> code clearing is not needed any more in the file system code base.
> 
> Signed-off-by: Stephan Mueller <smueller@chronox.de>
> ---
>  fs/crypto/hkdf.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/crypto/hkdf.c b/fs/crypto/hkdf.c
> index ae236b42b1f0..c48dd8ca3a46 100644
> --- a/fs/crypto/hkdf.c
> +++ b/fs/crypto/hkdf.c
> @@ -102,13 +102,10 @@ int fscrypt_hkdf_expand(const struct fscrypt_hkdf *hkdf, u8 context,
>  		.iov_base = (u8 *)info,
>  		.iov_len = infolen,
>  	} };
> -	int err = crypto_hkdf_expand(hkdf->hmac_tfm,
> -				     info_iov, ARRAY_SIZE(info_iov),
> -				     okm, okmlen);
>  
> -	if (unlikely(err))
> -		memzero_explicit(okm, okmlen); /* so caller doesn't need to */
> -	return err;
> +	return crypto_hkdf_expand(hkdf->hmac_tfm,
> +				  info_iov, ARRAY_SIZE(info_iov),
> +				  okm, okmlen);
>  }
>  

Shoudn't this just be folded into the previous patch, which converted
fscrypt_hkdf_expand() to use crypto_hkdf_expand() in the first place?

- Eric
