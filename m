Return-Path: <SRS0=F0ny=AK=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C717C433E3
	for <linux-fscrypt@archiver.kernel.org>; Mon, 29 Jun 2020 18:42:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 0AD682063A
	for <linux-fscrypt@archiver.kernel.org>; Mon, 29 Jun 2020 18:42:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1593456149;
	bh=WtcO4OQ+rWVThEy0P5QwrgAlBFNU4fHDkqK2m2rvXk0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=fL7zGBIunG85PagZCXUyiuRPyDtP6VML+00UxKbdEoz6NRz96MkvagVI/ylcgTo77
	 fO6RSQPWVAMoVY21zuA6olpjcnheG+VBUZvfaocFLLLum4we1JGNaeYkFUt3EN1XL3
	 Y8OmEIi4DcIPz1QnF/vH/UkJJ8v4S8FepvmnAGZ8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726901AbgF2Sm2 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 29 Jun 2020 14:42:28 -0400
Received: from mail.kernel.org ([198.145.29.99]:60598 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728938AbgF2Sl0 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 29 Jun 2020 14:41:26 -0400
Received: from sol.localdomain (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id EA2F8255C9;
        Mon, 29 Jun 2020 18:24:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1593455048;
        bh=WtcO4OQ+rWVThEy0P5QwrgAlBFNU4fHDkqK2m2rvXk0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=awED3q3uewhYzryJjBkPIlXegndymb+6phw4rtdtP+XE10ZQqM0ZChJ8CuGUjABvJ
         4dglfld0hQrcgm6zMwZ30JXdyvmkDiFtYMfzFbGwFaoWZ4gAgRuVu3rjXvy0n5nlk5
         z4mTiNZo07S0XF3ZtgiYnG3g2v9BpeC0SIdkkv/Q=
Date:   Mon, 29 Jun 2020 11:24:06 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Satya Tangirala <satyat@google.com>
Cc:     linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org
Subject: Re: [PATCH v2 1/4] fs: introduce SB_INLINECRYPT
Message-ID: <20200629182406.GE20492@sol.localdomain>
References: <20200629120405.701023-1-satyat@google.com>
 <20200629120405.701023-2-satyat@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200629120405.701023-2-satyat@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Jun 29, 2020 at 12:04:02PM +0000, Satya Tangirala via Linux-f2fs-devel wrote:
> Introduce SB_INLINECRYPT, which is set by filesystems that wish to use
> blk-crypto for file content en/decryption. This flag maps to the
> '-o inlinecrypt' mount option which multiple filesystems will implement,
> and code in fs/crypto/ needs to be able to check for this mount option
> in a filesystem-independent way.
> 
> Signed-off-by: Satya Tangirala <satyat@google.com>
> ---
>  include/linux/fs.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 3f881a892ea7..b5e07fcdd11d 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1380,6 +1380,7 @@ extern int send_sigurg(struct fown_struct *fown);
>  #define SB_NODIRATIME	2048	/* Do not update directory access times */
>  #define SB_SILENT	32768
>  #define SB_POSIXACL	(1<<16)	/* VFS does not apply the umask */
> +#define SB_INLINECRYPT	(1<<17)	/* Use blk-crypto for encrypted files */
>  #define SB_KERNMOUNT	(1<<22) /* this is a kern_mount call */
>  #define SB_I_VERSION	(1<<23) /* Update inode I_version field */
>  #define SB_LAZYTIME	(1<<25) /* Update the on-disk [acm]times lazily */
> -- 

Reviewed-by: Eric Biggers <ebiggers@google.com>
