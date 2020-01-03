Return-Path: <SRS0=g9fr=2Y=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73B23C2D0C2
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 17:02:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3F47A206DB
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 17:02:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1578070976;
	bh=aDA7AeEiGNoPBRANxPTy+BfhdhRrl0XqxQaxvqy/SEs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=RcKrw+UGmVSgXxyqGKPb6wjkYjcHoIKJaQ2hlu6G/mT1qsuTf9k6h6JG4m+/Gtik0
	 qhoYL2ffcBbJZ3JlXrHsgdyffmqLu/Ozie30SzA7k+cEhSJp1hlXdWMKwxNNVxyXNs
	 s1n6TRj0+I8lRz+9brySa8hblImJOefbsUyvvEZ0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727952AbgACRC4 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 3 Jan 2020 12:02:56 -0500
Received: from mail.kernel.org ([198.145.29.99]:59838 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727912AbgACRCz (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 3 Jan 2020 12:02:55 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4D883206DB;
        Fri,  3 Jan 2020 17:02:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1578070975;
        bh=aDA7AeEiGNoPBRANxPTy+BfhdhRrl0XqxQaxvqy/SEs=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=GGD1csfZIP5FXGiU+rE8+9nImTjyFqNAxqDezA+NTrzO1WCu3riD/OWZ1QVKojW3f
         0Y1eMwRLHcQiSGhrcZXKN63noBknksOwpCeHQOcucTFITYN34Tx2u+rvx9TKEG6aJl
         s3PU+bcrDoU23pVMcb9HMh31bNazarx0nHq5XJr4=
Date:   Fri, 3 Jan 2020 09:02:53 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fscrypt: include <linux/ioctl.h> in UAPI header
Message-ID: <20200103170253.GK19521@gmail.com>
References: <20191219185624.21251-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191219185624.21251-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, Dec 19, 2019 at 10:56:24AM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> <linux/fscrypt.h> defines ioctl numbers using the macros like _IORW()
> which are defined in <linux/ioctl.h>, so <linux/ioctl.h> should be
> included as a prerequisite, like it is in many other kernel headers.
> 
> In practice this doesn't really matter since anyone referencing these
> ioctl numbers will almost certainly include <sys/ioctl.h> too in order
> to actually call ioctl().  But we might as well fix this.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  include/uapi/linux/fscrypt.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/uapi/linux/fscrypt.h b/include/uapi/linux/fscrypt.h
> index d5112a24e8b9f..0d8a6f47711c3 100644
> --- a/include/uapi/linux/fscrypt.h
> +++ b/include/uapi/linux/fscrypt.h
> @@ -8,6 +8,7 @@
>  #ifndef _UAPI_LINUX_FSCRYPT_H
>  #define _UAPI_LINUX_FSCRYPT_H
>  
> +#include <linux/ioctl.h>
>  #include <linux/types.h>
>  
>  /* Encryption policy flags */
> -- 
> 2.24.1.735.g03f4e72817-goog
> 

Applied to fscrypt.git#master for 5.6.

(Fixed a typo in the commit message -- "_IORW()" should be "_IOWR()".)

- Eric
