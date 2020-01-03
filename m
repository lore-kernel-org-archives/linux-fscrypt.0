Return-Path: <SRS0=g9fr=2Y=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 664AFC2D0C2
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 17:00:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3A1F321734
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 17:00:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1578070823;
	bh=lIDnH4Ni7vm7EqDrw9Ig1Jh5Xktimknbpuf93UYQXQY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=HlBk55y/QAUAaTeep4yJFtLi6N0wjPMMa7gYY8w38llLLpqE9OWsknjEDv+WfmhU7
	 ODwAzXhgBKysGEvlWFaxgpXLxDbECw35t9ar7eaxWtS2lWPMr+pUcurzUmNUYYnSy5
	 JfCu1ydpKf3yWYZFmLR9L6xfZjr9c/3ImHWA9a5I=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727912AbgACRAX (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 3 Jan 2020 12:00:23 -0500
Received: from mail.kernel.org ([198.145.29.99]:56256 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727769AbgACRAW (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 3 Jan 2020 12:00:22 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 52345206DB;
        Fri,  3 Jan 2020 17:00:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1578070822;
        bh=lIDnH4Ni7vm7EqDrw9Ig1Jh5Xktimknbpuf93UYQXQY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=KpxvNkg6QA+mLDSw5allu2VB3gYr+Xvg5hOCbAzeiQ5O3aniKwmoQmkBuGkSNIyAb
         DtDxqHX+nc7ZvP+avSXJaUsoOmjVI0lhXGjchN+XFQAh6nF2faJYEGsqSSxYHzxryC
         1PjzOuaXPDXSyTc5XFr3jkr43eqV9mS8sBv5cW+Y=
Date:   Fri, 3 Jan 2020 09:00:20 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     Daniel Rosenberg <drosen@google.com>
Subject: Re: [PATCH 0/4] fscrypt: fscrypt_supported_policy() fixes and
 cleanups
Message-ID: <20200103170020.GI19521@gmail.com>
References: <20191209211829.239800-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191209211829.239800-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Dec 09, 2019 at 01:18:25PM -0800, Eric Biggers wrote:
> Make FS_IOC_SET_ENCRYPTION_POLICY start rejecting the DIRECT_KEY flag
> when it's incompatible with the selected encryption modes, instead of
> delaying this check until later when actually trying to set up the
> directory's key.
> 
> Also make some related cleanups, such as splitting
> fscrypt_supported_policy() into a separate function for each encryption
> policy version.
> 
> Eric Biggers (4):
>   fscrypt: split up fscrypt_supported_policy() by policy version
>   fscrypt: check for appropriate use of DIRECT_KEY flag earlier
>   fscrypt: move fscrypt_valid_enc_modes() to policy.c
>   fscrypt: remove fscrypt_is_direct_key_policy()
> 
>  fs/crypto/fscrypt_private.h |  30 +------
>  fs/crypto/keysetup.c        |  14 +---
>  fs/crypto/keysetup_v1.c     |  15 ----
>  fs/crypto/policy.c          | 163 +++++++++++++++++++++++-------------
>  4 files changed, 111 insertions(+), 111 deletions(-)
> 
> -- 
> 2.24.0.393.g34dc348eaf-goog
> 

All applied to fscrypt.git#master for 5.6.

- Eric
