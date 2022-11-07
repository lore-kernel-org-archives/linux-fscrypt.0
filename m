Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CACB3C433FE
	for <linux-fscrypt@archiver.kernel.org>; Mon,  7 Nov 2022 09:00:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230364AbiKGJAF (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 7 Nov 2022 04:00:05 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59764 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229687AbiKGJAE (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 7 Nov 2022 04:00:04 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 03B2C15FF4;
        Mon,  7 Nov 2022 01:00:04 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id A76D1B80E6D;
        Mon,  7 Nov 2022 09:00:02 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 09FDEC433D6;
        Mon,  7 Nov 2022 09:00:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
        s=korg; t=1667811601;
        bh=BLYRJj1wCgFOZvm6y4mO9cbuSsbX18xhGPl83FacJU0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=dqJyxci817uw8ZLX7iRECXBhCD49mU6v/RrANIftM/jJ54KeZ8rK+Xt9b0eg7iP+T
         8p6Edc+dodkpOVq8OKyGLW2J4f+EVtWnykXaRU7+KnAqZvrKMqFfBihdP8wzNqPVvn
         QJr1WAOW4ETxnKk5eU8ObqpmUzTX31fwRkewo2GQ=
Date:   Mon, 7 Nov 2022 09:59:52 +0100
From:   Greg KH <gregkh@linuxfoundation.org>
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     stable@vger.kernel.org, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH 6.0 0/2] fscrypt fixes for stable
Message-ID: <Y2jJCDuKx9a4vsXM@kroah.com>
References: <20221104225439.338239-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221104225439.338239-1-ebiggers@kernel.org>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Fri, Nov 04, 2022 at 03:54:37PM -0700, Eric Biggers wrote:
> Please apply these to 6.0-stable.
> 
> Eric Biggers (2):
>   fscrypt: stop using keyrings subsystem for fscrypt_master_key
>   fscrypt: fix keyring memory leak on mount failure
> 
>  fs/crypto/fscrypt_private.h |  71 ++++--
>  fs/crypto/hooks.c           |  10 +-
>  fs/crypto/keyring.c         | 491 +++++++++++++++++++-----------------
>  fs/crypto/keysetup.c        |  81 +++---
>  fs/crypto/policy.c          |   8 +-
>  fs/super.c                  |   3 +-
>  include/linux/fs.h          |   2 +-
>  include/linux/fscrypt.h     |   4 +-
>  8 files changed, 359 insertions(+), 311 deletions(-)

Both now queued up, thanks.

greg k-h
