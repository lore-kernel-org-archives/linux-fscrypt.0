Return-Path: <SRS0=g9fr=2Y=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0525BC2D0C2
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 17:03:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C725F206DB
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 17:03:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1578071008;
	bh=AG7N8CLv6lMYP5l/tbp0GPIHt9AlUnhbNGglb4W4H7g=;
	h=Date:From:To:Subject:References:In-Reply-To:List-ID:From;
	b=ED8dy2YHypxmxa4YWvXUkm1yGH+p6sD3z39N2qRM/U8eQYxSpiVH9CGQIJgp8QGw7
	 Xs9hGAmc+IyRSlSrXZVogbu4dC2SCos2JaKF+9rFCBFY0RatDiMM8VstE7coquTUit
	 X6V1hB2RhLfcYZ0+gIJuiXJhIXndbgC9Gh1B+7iE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728021AbgACRD2 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 3 Jan 2020 12:03:28 -0500
Received: from mail.kernel.org ([198.145.29.99]:60496 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727912AbgACRD2 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 3 Jan 2020 12:03:28 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id DFA5A206DB
        for <linux-fscrypt@vger.kernel.org>; Fri,  3 Jan 2020 17:03:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1578071008;
        bh=AG7N8CLv6lMYP5l/tbp0GPIHt9AlUnhbNGglb4W4H7g=;
        h=Date:From:To:Subject:References:In-Reply-To:From;
        b=hU1166NWgp+d//kHXpRhDxjCgudVBB6D9yBsVQMt8MuBeQICsD4IkjOsE3pbELhnN
         XgGRT7bxn4pCmJCDQAeCPNeTJBC/8mgHqnbIGUtagSfLRnl6B92xXY7oQqwI48uG+q
         ULoemy+h7AuH334nRuFX7F52CBogub5Q5RWV+ZP0=
Date:   Fri, 3 Jan 2020 09:03:26 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH] fscrypt: remove redundant bi_status check
Message-ID: <20200103170326.GL19521@gmail.com>
References: <20191209204509.228942-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191209204509.228942-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Dec 09, 2019 at 12:45:09PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> submit_bio_wait() already returns bi_status translated to an errno.
> So the additional check of bi_status is redundant and can be removed.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/crypto/bio.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
> index 1f4b8a2770606..b88d417e186e5 100644
> --- a/fs/crypto/bio.c
> +++ b/fs/crypto/bio.c
> @@ -77,8 +77,6 @@ int fscrypt_zeroout_range(const struct inode *inode, pgoff_t lblk,
>  			goto errout;
>  		}
>  		err = submit_bio_wait(bio);
> -		if (err == 0 && bio->bi_status)
> -			err = -EIO;
>  		bio_put(bio);
>  		if (err)
>  			goto errout;
> -- 
> 2.24.0.393.g34dc348eaf-goog
> 

Applied to fscrypt.git#master for 5.6.

- Eric
