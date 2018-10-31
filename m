Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:52746 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728453AbeKAInn (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 1 Nov 2018 04:43:43 -0400
Date: Wed, 31 Oct 2018 16:43:20 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [RFC PATCH 1/2] fscrypt: Remove filesystem specific build config
 option
Message-ID: <20181031234319.GA202657@gmail.com>
References: <20181031050005.17770-1-chandan@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181031050005.17770-1-chandan@linux.vnet.ibm.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Chandan Rajendra <chandan@linux.vnet.ibm.com>
Cc: tytso@mit.edu, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Chandan, a couple questions:

On Wed, Oct 31, 2018 at 10:30:04AM +0530, Chandan Rajendra wrote:
> As a first step to avoid copy-pasting common code across filesystems
> which implement fscrypt, this commit removes filesystem specific build
> config option (e.g. CONFIG_EXT4_FS_ENCRYPTION) and replaces it with a
> build option (i.e. CONFIG_FS_ENCRYPTION) whose value affects all the
> filesystems making use of fscrypt.
> 
> Signed-off-by: Chandan Rajendra <chandan@linux.vnet.ibm.com>

Can you be more explicit about the goal here?  It's mostly about implementing
->readpages() when the filesystem may support both fscrypt and fs-verity, right?

> diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
> index 02b7d91..6e9ae56 100644
> --- a/fs/crypto/Kconfig
> +++ b/fs/crypto/Kconfig
> @@ -1,5 +1,5 @@
>  config FS_ENCRYPTION
> -	tristate "FS Encryption (Per-file encryption)"
> +	bool "FS Encryption (Per-file encryption)"
>  	select CRYPTO
>  	select CRYPTO_AES
>  	select CRYPTO_CBC

Is it possible to keep this as a module, rather than requiring that fs/crypto/
always be built-in?  Making this a 'bool' will require all the selected crypto
algorithms to be built-in too.

> -	if (ext4_encrypted_inode(inode)) {
> +	if (IS_ENCRYPTED(inode)) {

I suggest doing the replacements of ext4_encrypted_inode() with IS_ENCRYPTED()
as a standalone patch, so it's easier to review.

Also I suggest sending this patch to the ext4 and f2fs mailing lists too.

Thanks!

- Eric
