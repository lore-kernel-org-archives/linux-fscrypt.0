Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 166EAC4332B
	for <linux-fscrypt@archiver.kernel.org>; Thu, 28 Jan 2021 20:17:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E321164E02
	for <linux-fscrypt@archiver.kernel.org>; Thu, 28 Jan 2021 20:17:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229819AbhA1UQ4 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 28 Jan 2021 15:16:56 -0500
Received: from mail.kernel.org ([198.145.29.99]:41914 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231215AbhA1UQw (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 28 Jan 2021 15:16:52 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id B014C64DFF;
        Thu, 28 Jan 2021 20:16:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1611864971;
        bh=gAzHBedr8hQIaRX+X9TrS9kGg87gd7QPQ+5CLuBJpt8=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=j64T3tCnPHFXVd9UDcO3ZTOfla2mufg7J90/bA6o9GttXehR+PXluGg1N8SsLHc64
         hYIqClK4YqioUGbBUn5E0/LTUEXZoeydUuBy7C/jJzkWZI3kN4zZyF9bE1w6rjadeL
         mFvFp17Lp762yM1kjCdiPwqwpuP+o08YKXdW1XGD6D16WT4KuYfBIzUjXVdZ6co/bD
         xxK0jkI9gi8qVehzDyDQIdu6ZXozGMk3aJIBF1md2koHrZErBvJ60OUW6zl2Eq+TKp
         Qhv5ViBWNI8ZidtGf4nMqCWpWfPV23xNl6fU0tLWQ9r76Y/LCT/GkpY2UhfD19GJWk
         Tfputr0lYAqiw==
Date:   Thu, 28 Jan 2021 12:16:09 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     Stephan =?iso-8859-1?Q?M=FCller?= <smueller@chronox.de>
Cc:     herbert@gondor.apana.org.au, Jarkko Sakkinen <jarkko@kernel.org>,
        mathew.j.martineau@linux.intel.com, dhowells@redhat.com,
        linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-kernel@vger.kernel.org, keyrings@vger.kernel.org,
        simo@redhat.com
Subject: Re: [PATCH v2 6/7] fs: use HKDF implementation from kernel crypto API
Message-ID: <YBMbiQ/OonYxgzJE@sol.localdomain>
References: <1772794.tdWV9SEqCh@positron.chronox.de>
 <3577027.kQq0lBPeGt@positron.chronox.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3577027.kQq0lBPeGt@positron.chronox.de>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Please prefix the commit subject with "fscrypt: " rather than "fs: ".

On Sun, Jan 24, 2021 at 03:04:31PM +0100, Stephan Müller wrote:
> diff --git a/fs/crypto/hkdf.c b/fs/crypto/hkdf.c
> index e0ec21055505..ae236b42b1f0 100644
> --- a/fs/crypto/hkdf.c
> +++ b/fs/crypto/hkdf.c
> @@ -9,7 +9,7 @@
>   * Copyright 2019 Google LLC
>   */
>  
> -#include <crypto/hash.h>
> +#include <crypto/hkdf.h>
>  #include <crypto/sha2.h>
>  
>  #include "fscrypt_private.h"
> @@ -37,23 +37,7 @@
>   * unnecessarily long master keys.  Thus fscrypt still does HKDF-Extract.  No
>   * salt is used, since fscrypt master keys should already be pseudorandom and
>   * there's no way to persist a random salt per master key from kernel mode.
> - */
> -
> -/* HKDF-Extract (RFC 5869 section 2.2), unsalted */
> -static int hkdf_extract(struct crypto_shash *hmac_tfm, const u8 *ikm,
> -			unsigned int ikmlen, u8 prk[HKDF_HASHLEN])
> -{
> -	static const u8 default_salt[HKDF_HASHLEN];
> -	int err;
> -
> -	err = crypto_shash_setkey(hmac_tfm, default_salt, HKDF_HASHLEN);
> -	if (err)
> -		return err;
> -
> -	return crypto_shash_tfm_digest(hmac_tfm, ikm, ikmlen, prk);
> -}
> -
> -/*
> + *
>   * Compute HKDF-Extract using the given master key as the input keying material,
>   * and prepare an HMAC transform object keyed by the resulting pseudorandom key.
>   *

I don't think this comment should be joined with the one above it.  The earlier
comment describes the general approach taken with fscrypt and HKDF (including
all steps), while the one beginning with "Compute HKDF-Extract" describes
fscrypt_init_hkdf() specifically.

- Eric
