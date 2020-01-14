Return-Path: <SRS0=WnaO=3D=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2286FC33C9E
	for <linux-fscrypt@archiver.kernel.org>; Tue, 14 Jan 2020 22:00:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E5D5924673
	for <linux-fscrypt@archiver.kernel.org>; Tue, 14 Jan 2020 22:00:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1579039220;
	bh=myv1tZujatarOxhWpe/ZDoVHrCY2/KGzo+86dr3TQf4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=fET68GX2MAPV+U9VGdz5zC3Xt/DBnRR2n+bAQbKjinNUtloiEc5SxZb7YeU+NrSjP
	 W9VYOjLyCjtASlXMlVuE4JNl7TOjA+l5TSa5C3GvIscWKPbb3Q7JYELtTQE1x8BBhG
	 8+MJsOLDYDjqub2xrACKxVZDVSEfTfoYphztKiSU=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728731AbgANWAT (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 14 Jan 2020 17:00:19 -0500
Received: from mail.kernel.org ([198.145.29.99]:36144 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728656AbgANWAT (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 14 Jan 2020 17:00:19 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id C103824658;
        Tue, 14 Jan 2020 22:00:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1579039218;
        bh=myv1tZujatarOxhWpe/ZDoVHrCY2/KGzo+86dr3TQf4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=mY5ghWc3WrHee+LAlkopBFawq4UUIwj9d8PLPhe10NkZZbmGxUnmycyP+VhlCjVNy
         ZnfDP+GBNlUWp5B8rLyHLpyevvZS8V9LIZuY+ZpKzn4ccAE6Xy8LuXTjcOPMrxlomE
         j0W+k3yzIGYzJD58KTjLs3Wza0el1kKf+3V5QjSg=
Date:   Tue, 14 Jan 2020 14:00:17 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     Richard Weinberger <richard@nod.at>
Cc:     linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 0/2] ubifs: fixes for FS_IOC_GETFLAGS and FS_IOC_SETFLAGS
Message-ID: <20200114220016.GL41220@gmail.com>
References: <20191209222325.95656-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191209222325.95656-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Dec 09, 2019 at 02:23:23PM -0800, Eric Biggers wrote:
> On ubifs, fix FS_IOC_SETFLAGS to not clear the encrypt flag, and update
> FS_IOC_GETFLAGS to return the encrypt flag like ext4 and f2fs do.
> 
> Eric Biggers (2):
>   ubifs: fix FS_IOC_SETFLAGS unexpectedly clearing encrypt flag
>   ubifs: add support for FS_ENCRYPT_FL
> 
>  fs/ubifs/ioctl.c | 14 +++++++++++---
>  1 file changed, 11 insertions(+), 3 deletions(-)

Richard, have you had a chance to review these?  I'm intending that these be
taken through the UBIFS tree too.

- Eric
