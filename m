Return-Path: <SRS0=H3RQ=7Q=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C7AEC433DF
	for <linux-fscrypt@archiver.kernel.org>; Wed,  3 Jun 2020 02:07:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 05ABB20772
	for <linux-fscrypt@archiver.kernel.org>; Wed,  3 Jun 2020 02:07:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1591150066;
	bh=qLcUIqg4MkGQXm/ALUeDTBM4qZrROCTmpgT+XERn3Wo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=WD3T5UPrE31+cVK9gPegte3KchVxG2mo86yX5sD6JlEIutZzP5hJ3ngrw9Zk+UVt6
	 rgZUKP75Pw2q+xgVq6iPY4hbtUYKM7jCSDq5YWWR2A7Nmq/VQdruKq36+cJ93m1peA
	 4sHNZcj7g/oZP7reoR50vuzt76iyDOi5SDzFnKo8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725906AbgFCCHp (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 2 Jun 2020 22:07:45 -0400
Received: from mail.kernel.org ([198.145.29.99]:46960 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725789AbgFCCHp (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 2 Jun 2020 22:07:45 -0400
Received: from sol.localdomain (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 32A502072F;
        Wed,  3 Jun 2020 02:07:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1591150064;
        bh=qLcUIqg4MkGQXm/ALUeDTBM4qZrROCTmpgT+XERn3Wo=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=aq1ZrZwQU3kRCrtJOZAwJUWVfYq2+bOd3t19aKhFjRpZJjQ7d+Ws0QDXHtHTp4POk
         R8bz/dDLIX+5ng8Qi7HF7HQhyQniQJZPjcc7IzSHpZ0zGN5s5i/2EhPAsNVyErNBhD
         imgt4H8pvVTVYE1AU9KFtJHzqyXDQxsAq7RLeOCY=
Date:   Tue, 2 Jun 2020 19:07:42 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Satya Tangirala <satyat@google.com>
Cc:     linux-block@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-ext4@vger.kernel.org,
        Barani Muthukumaran <bmuthuku@qti.qualcomm.com>,
        Kuohong Wang <kuohong.wang@mediatek.com>,
        Kim Boojin <boojin.kim@samsung.com>
Subject: Re: [PATCH v13 10/12] fscrypt: add inline encryption support
Message-ID: <20200603020742.GA50072@sol.localdomain>
References: <20200514003727.69001-1-satyat@google.com>
 <20200514003727.69001-11-satyat@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200514003727.69001-11-satyat@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

One more thing:

On Thu, May 14, 2020 at 12:37:25AM +0000, Satya Tangirala wrote:
> +/* Enable inline encryption for this file if supported. */
> +void fscrypt_select_encryption_impl(struct fscrypt_info *ci)
> +{
> +	const struct inode *inode = ci->ci_inode;
> +	struct super_block *sb = inode->i_sb;
> +	struct blk_crypto_config crypto_cfg;
> +	int num_devs;
> +	struct request_queue **devs;
> +	int i;
> +
> +	/* The file must need contents encryption, not filenames encryption */
> +	if (!fscrypt_needs_contents_encryption(inode))
> +		return;
> +
> +	/* The crypto mode must be valid */
> +	if (ci->ci_mode->blk_crypto_mode == BLK_ENCRYPTION_MODE_INVALID)
> +		return;
> +
> +	/* The filesystem must be mounted with -o inlinecrypt */
> +	if (!(sb->s_flags & SB_INLINECRYPT))
> +		return;
> +
> +	/*
> +	 * blk-crypto must support the crypto configuration we'll use for the
> +	 * inode on all devices in the sb
> +	 */
> +	crypto_cfg.crypto_mode = ci->ci_mode->blk_crypto_mode;
> +	crypto_cfg.data_unit_size = sb->s_blocksize;
> +	crypto_cfg.dun_bytes = fscrypt_get_dun_bytes(ci);
> +	num_devs = fscrypt_get_num_devices(sb);
> +	devs = kmalloc_array(num_devs, sizeof(*devs), GFP_NOFS);
> +	if (!devs)
> +		return;

This function needs to return an error code, so that if this memory allocation
fails, the error is not ignored.

- Eric
