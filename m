Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:37313 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753881AbeASAJ3 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 18 Jan 2018 19:09:29 -0500
Received: by mail-io0-f193.google.com with SMTP id f89so372297ioj.4
        for <linux-fscrypt@vger.kernel.org>; Thu, 18 Jan 2018 16:09:29 -0800 (PST)
Date: Thu, 18 Jan 2018 16:09:25 -0800
From: Eric Biggers <ebiggers@google.com>
Subject: Re: + fs-crypto-hooksc-fix-build-with-gcc-444.patch added to -mm tree
Message-ID: <20180119000925.qmc7ynnrvlet57ix@google.com>
References: <5a6132f3.CzlRFckHd7ySTlRc%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a6132f3.CzlRFckHd7ySTlRc%akpm@linux-foundation.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: tytso@mit.edu, mm-commits@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

+Cc linux-fscrypt

On Thu, Jan 18, 2018 at 03:51:15PM -0800, akpm@linux-foundation.org wrote:
> ------------------------------------------------------
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: fs/crypto/hooks.c: fix build with gcc-4.4.4
> 
> gcc-4.4.4 has issues with anon union initializers.  Work around this.
> 
> fs/crypto/hooks.c: In function '__fscrypt_encrypt_symlink':
> fs/crypto/hooks.c:161: error: unknown field 'len' specified in initializer
> fs/crypto/hooks.c:161: warning: excess elements in struct initializer
> fs/crypto/hooks.c:161: warning: (near initialization for 'iname')
> 
> Fixes: 76e81d6d50 ("fscrypt: new helper functions for ->symlink()")
> Cc: Eric Biggers <ebiggers@google.com>
> Cc: Theodore Ts'o <tytso@mit.edu>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  fs/crypto/hooks.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN fs/crypto/hooks.c~fs-crypto-hooksc-fix-build-with-gcc-444 fs/crypto/hooks.c
> --- a/fs/crypto/hooks.c~fs-crypto-hooksc-fix-build-with-gcc-444
> +++ a/fs/crypto/hooks.c
> @@ -158,7 +158,7 @@ int __fscrypt_encrypt_symlink(struct ino
>  			      unsigned int len, struct fscrypt_str *disk_link)
>  {
>  	int err;
> -	struct qstr iname = { .name = target, .len = len };
> +	struct qstr iname = { { .hash_len = len, }, .name = target, };
>  	struct fscrypt_symlink_data *sd;
>  	unsigned int ciphertext_len;
>  

Thanks for finding this -- sorry for the trouble!  But I think it should really
use QSTR_INIT(), since that's what almost everywhere else uses to create a
'struct qstr':

	struct qstr iname = QSTR_INIT(target, len);

Ted, can you take the QSTR_INIT() fix into the fscrypt tree?  Maybe folded into
"fscrypt: new helper functions for ->symlink()"?  Or separate is okay too.

Eric
