Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E184CC433F5
	for <linux-fscrypt@archiver.kernel.org>; Mon, 13 Sep 2021 09:33:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C232F60D42
	for <linux-fscrypt@archiver.kernel.org>; Mon, 13 Sep 2021 09:33:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S238684AbhIMJfM (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 13 Sep 2021 05:35:12 -0400
Received: from mail.kernel.org ([198.145.29.99]:48952 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S238683AbhIMJfL (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 13 Sep 2021 05:35:11 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id C880961004;
        Mon, 13 Sep 2021 09:33:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
        s=korg; t=1631525636;
        bh=GY8EbtbGrgePZfSn3NDCuLNemetE1SRK37HKfuiJrzI=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=lXfVZu5j0ppumZyeQdoQvH4+bjWZ2qTjg+7G2oYG4+8A6qFXQ1t9Ht1Wy00W3Dxli
         OeFQkayIypGECabAt0QI2dN2J3NHxXZiJ1A5dQ2xtWflk3NdrQdcbdCjSSMPLDLUXt
         qr+gz75pyugwlAj99JLG6U0f/kVMoJzmSk2BcAZU=
Date:   Mon, 13 Sep 2021 11:33:54 +0200
From:   Greg KH <gregkh@linuxfoundation.org>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     stable@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org
Subject: Re: [PATCH 0/4] backport fscrypt symlink fixes to 4.19
Message-ID: <YT8bAlnKAYXMqFpe@kroah.com>
References: <20210908215033.1122580-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210908215033.1122580-1-ebiggers@kernel.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Sep 08, 2021 at 02:50:29PM -0700, Eric Biggers wrote:
> This series backports some patches that failed to apply to 4.19-stable
> due to the prototype of inode_operations::getattr having changed in
> v5.12, as well as several other conflicts.  Please apply to 4.19-stable.
> 
> Eric Biggers (4):
>   fscrypt: add fscrypt_symlink_getattr() for computing st_size
>   ext4: report correct st_size for encrypted symlinks
>   f2fs: report correct st_size for encrypted symlinks
>   ubifs: report correct st_size for encrypted symlinks
> 
>  fs/crypto/hooks.c               | 44 +++++++++++++++++++++++++++++++++
>  fs/ext4/symlink.c               | 11 ++++++++-
>  fs/f2fs/namei.c                 | 11 ++++++++-
>  fs/ubifs/file.c                 | 12 ++++++++-
>  include/linux/fscrypt_notsupp.h |  6 +++++
>  include/linux/fscrypt_supp.h    |  1 +
>  6 files changed, 82 insertions(+), 3 deletions(-)
> 
> -- 
> 2.33.0.153.gba50c8fa24-goog
> 

All now queued up, thanks!

greg k-h
