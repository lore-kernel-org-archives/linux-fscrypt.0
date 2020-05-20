Return-Path: <SRS0=Ey0P=7C=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3C0BC433E0
	for <linux-fscrypt@archiver.kernel.org>; Wed, 20 May 2020 22:52:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 79D3120884
	for <linux-fscrypt@archiver.kernel.org>; Wed, 20 May 2020 22:52:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1590015158;
	bh=cOMMRvik++uT4gLMAQuu3TGKuohy9FAsvrDOcWA2UL4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=Z9RoDc26CEU1EJl++mBv+fVzp06U0QgXemctvLwg5qhrMYdB27h9kWle/XwEzyEOW
	 NXrPm61svmuDT/KFRsrczKCfW4hSm4EcoSdlO6u2mDhVW5ql+XHlBVTCfvYhrkfvJJ
	 DdkRS5pv7Xy/f41tWDuS8u0/9y9Lt4OHOQ9IXy4U=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728596AbgETWwi (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 20 May 2020 18:52:38 -0400
Received: from mail.kernel.org ([198.145.29.99]:60012 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728447AbgETWwh (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 20 May 2020 18:52:37 -0400
Received: from sol.localdomain (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 777DE20708;
        Wed, 20 May 2020 22:52:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1590015157;
        bh=cOMMRvik++uT4gLMAQuu3TGKuohy9FAsvrDOcWA2UL4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=GFFvwdXWnLW8I75OtVEHT5iTSVEuoTlKH07dKwKDA4jLpm5/0+10iHpLdymDfzGtv
         bWMJLIBzDwX2jNUjtDMzOm6X6SfDiLpqTzd1PapkngDTF7WQDagn1n8G5+z+YlI6fU
         C42Oko4lWBYvFejCpnFGc5xuGqFrqiTcC25punns=
Date:   Wed, 20 May 2020 15:52:36 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
Subject: Re: [PATCH 0/2] fs-verity: misc cleanups
Message-ID: <20200520225236.GB19246@sol.localdomain>
References: <20200511192118.71427-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200511192118.71427-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, May 11, 2020 at 12:21:16PM -0700, Eric Biggers wrote:
> In fs/verity/ and fsverity.h, fix all kerneldoc warnings, and fix some
> coding style inconsistencies in function declarations.
> 
> Eric Biggers (2):
>   fs-verity: fix all kerneldoc warnings
>   fs-verity: remove unnecessary extern keywords
> 
>  fs/verity/enable.c           |  2 ++
>  fs/verity/fsverity_private.h |  4 ++--
>  fs/verity/measure.c          |  2 ++
>  fs/verity/open.c             |  1 +
>  fs/verity/signature.c        |  3 +++
>  fs/verity/verify.c           |  3 +++
>  include/linux/fsverity.h     | 19 +++++++++++--------
>  7 files changed, 24 insertions(+), 10 deletions(-)
> 

All applied to fscrypt.git#fsverity for 5.8.

- Eric
