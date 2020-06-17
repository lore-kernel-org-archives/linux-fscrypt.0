Return-Path: <SRS0=MU9e=76=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8886C433DF
	for <linux-fscrypt@archiver.kernel.org>; Wed, 17 Jun 2020 17:47:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C649C21556
	for <linux-fscrypt@archiver.kernel.org>; Wed, 17 Jun 2020 17:47:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1592416020;
	bh=UXP974nYkcnqpDwmLS52ZN4JfgNusjfQ08nltGiLMkk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=oqjNfAjdLv7giGDlevga/Cojv3vWFUHQwbvpx3H3hxhAaNK+R0SCvmbuKdJA0QZpn
	 8wTuZ0Pd4/1ON2P3spPkDF001EyNNnAMZ4iE3NiJ5V7PoLyWK6QK+2kDSENtNSquJX
	 B8p+/HmO5+M1YhRXIUV7R+RzVgKZKcMcgg7+Fmok=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726511AbgFQRrA (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 17 Jun 2020 13:47:00 -0400
Received: from mail.kernel.org ([198.145.29.99]:34744 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726496AbgFQRrA (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 17 Jun 2020 13:47:00 -0400
Received: from localhost (unknown [104.132.1.66])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id BE73221532;
        Wed, 17 Jun 2020 17:46:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1592416019;
        bh=UXP974nYkcnqpDwmLS52ZN4JfgNusjfQ08nltGiLMkk=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=LbwKHHobboW5GPv0wwI+ZH1bHD8EJHTDwG/XEvIaC7RMerremZcH/laUwq3uc8Cnj
         9tnf5tOtejgrxrfIx7RyMAqlxE+kEgZYytd88SETByOu2K0Z7z2M4MUqCVhedRUDmz
         5oZM0Ms7lY2M/CErISFBpz0jW0VZGBPYwi59JrLA=
Date:   Wed, 17 Jun 2020 10:46:59 -0700
From:   Jaegeuk Kim <jaegeuk@kernel.org>
To:     Satya Tangirala <satyat@google.com>
Cc:     linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org
Subject: Re: [PATCH 1/4] fs: introduce SB_INLINECRYPT
Message-ID: <20200617174659.GA114489@google.com>
References: <20200617075732.213198-1-satyat@google.com>
 <20200617075732.213198-2-satyat@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200617075732.213198-2-satyat@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On 06/17, Satya Tangirala wrote:
> Introduce SB_INLINECRYPT, which is set by filesystems that wish to use
> blk-crypto for file content en/decryption. This flag maps to the
> '-o inlinecrypt' mount option which multiple filesystems will implement,
> and code in fs/crypto/ needs to be able to check for this mount option
> in a filesystem-independent way.
> 
> Signed-off-by: Satya Tangirala <satyat@google.com>

Reviewed-by: Jaegeuk Kim <jaegeuk@kernel.org>

> ---
>  fs/proc_namespace.c | 1 +
>  include/linux/fs.h  | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/fs/proc_namespace.c b/fs/proc_namespace.c
> index 3059a9394c2d..e0ff1f6ac8f1 100644
> --- a/fs/proc_namespace.c
> +++ b/fs/proc_namespace.c
> @@ -49,6 +49,7 @@ static int show_sb_opts(struct seq_file *m, struct super_block *sb)
>  		{ SB_DIRSYNC, ",dirsync" },
>  		{ SB_MANDLOCK, ",mand" },
>  		{ SB_LAZYTIME, ",lazytime" },
> +		{ SB_INLINECRYPT, ",inlinecrypt" },
>  		{ 0, NULL }
>  	};
>  	const struct proc_fs_opts *fs_infop;
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 6c4ab4dc1cd7..abef6aa95524 100644
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
> 2.27.0.290.gba653c62da-goog
