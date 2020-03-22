Return-Path: <SRS0=fJSy=5H=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A252C4332D
	for <linux-fscrypt@archiver.kernel.org>; Sun, 22 Mar 2020 05:40:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 298E12076F
	for <linux-fscrypt@archiver.kernel.org>; Sun, 22 Mar 2020 05:40:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1584855624;
	bh=yqcMe+oO5u/ygxbKnmi1IwScZ+eQ5vdPNYVgs0W0IfA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=MWaZ1Hz+54V4z9A2nXeA4pH121otyusTlueAeXPPCacPlxU8LSKa7tlq3xKJC68XW
	 l8Vxl/RvEYuPLliKnlh8/tfjsdJIwM0s75+faThhL/GpvpmpsE/bmW0NbnT2F77UOL
	 2aF5xXnFod+F6dbSo0eJM0bhn9ZJFlQ92d7gm5UE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725972AbgCVFkX (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sun, 22 Mar 2020 01:40:23 -0400
Received: from mail.kernel.org ([198.145.29.99]:48454 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725825AbgCVFkX (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 22 Mar 2020 01:40:23 -0400
Received: from sol.localdomain (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 01D1420722;
        Sun, 22 Mar 2020 05:40:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1584855623;
        bh=yqcMe+oO5u/ygxbKnmi1IwScZ+eQ5vdPNYVgs0W0IfA=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=QKOGKoktwvsN1xDy9Ny2vF7mnddPhEgpEUFy5MQflbzCvSoid8TZnP733QkzfDH5H
         SLrYi84s/JSUlE4x6AWc625MXx2c8hT45vjLX8sIGnF8irArnvKvAaOcdsXe8THiWN
         UwPwhKZmXlbNTh/a7SGRmH40spKpwt35iy8A520Y=
Date:   Sat, 21 Mar 2020 22:40:21 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Jes Sorensen <jes.sorensen@gmail.com>
Cc:     linux-fscrypt@vger.kernel.org, kernel-team@fb.com,
        Jes Sorensen <jsorensen@fb.com>
Subject: Re: [PATCH 5/9] Create libfsverity_compute_digest() and adapt
 cmd_sign to use it
Message-ID: <20200322054021.GI111151@sol.localdomain>
References: <20200312214758.343212-1-Jes.Sorensen@gmail.com>
 <20200312214758.343212-6-Jes.Sorensen@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200312214758.343212-6-Jes.Sorensen@gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, Mar 12, 2020 at 05:47:54PM -0400, Jes Sorensen wrote:
> @@ -608,16 +433,17 @@ int fsverity_cmd_sign(const struct fsverity_command *cmd,
>  	if (certfile == NULL)
>  		certfile = keyfile;
>  
> -	digest = xzalloc(sizeof(*digest) + hash_alg->digest_size);
> -	memcpy(digest->magic, "FSVerity", 8);
> -	digest->digest_algorithm = cpu_to_le16(hash_alg->hash_num);
> -	digest->digest_size = cpu_to_le16(hash_alg->digest_size);
> -
>  	if (!open_file(&file, argv[0], O_RDONLY, 0))
>  		goto out_err;
>  
> -	if (!compute_file_measurement(file.fd, hash_alg, block_size,
> -				      salt, salt_size, digest->digest))
> +	memset(&params, 0, sizeof(struct libfsverity_merkle_tree_params));

Please use 'sizeof(params)' in cases like this.

> +	params.version = 1;
> +	params.hash_algorithm = hash_alg->hash_num;
> +	params.block_size = block_size;
> +	params.salt_size = salt_size;
> +	params.salt = salt;
> +
> +	if (libfsverity_compute_digest(file.fd, &params, &digest))
>  		goto out_err;

This doesn't close the file on error.

- Eric
