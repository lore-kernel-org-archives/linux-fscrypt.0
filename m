Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:60366 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727152AbfJSDQg (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 18 Oct 2019 23:16:36 -0400
Date: Fri, 18 Oct 2019 20:16:34 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH 1/2] fs/buffer.c: support fscrypt in
 block_read_full_page()
Message-ID: <20191019031634.GA76786@sol.localdomain>
References: <20191016221142.298754-1-ebiggers@kernel.org>
 <20191016221142.298754-2-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191016221142.298754-2-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-ext4@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Chandan Rajendra <chandan@linux.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Oct 16, 2019 at 03:11:41PM -0700, Eric Biggers wrote:
> +static void end_buffer_async_read_io(struct buffer_head *bh, int uptodate)
> +{
> +	/* Decrypt if needed */
> +	if (uptodate && IS_ENABLED(CONFIG_FS_ENCRYPTION) &&
> +	    IS_ENCRYPTED(bh->b_page->mapping->host)) {
> +		struct decrypt_bh_ctx *ctx = kmalloc(sizeof(*ctx), GFP_ATOMIC);

Technically this should check S_ISREG() too (though it happens not to make a
difference currently).   I'll fix it in the next version of this patchset.

We probably should add a helper function fscrypt_needs_contents_encryption()
that returns IS_ENABLED(CONFIG_FS_ENCRYPTION) && IS_ENCRYPTED() && S_ISREG().

- Eric
