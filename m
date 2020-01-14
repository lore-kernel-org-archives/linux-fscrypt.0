Return-Path: <SRS0=WnaO=3D=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84F87C33CB6
	for <linux-fscrypt@archiver.kernel.org>; Tue, 14 Jan 2020 21:04:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5B6C7246A7
	for <linux-fscrypt@archiver.kernel.org>; Tue, 14 Jan 2020 21:04:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1579035848;
	bh=VdbS8mEmXSpt9DK0Rzc+X41XsKnqVc8X/04G/OEHIcM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=zc+Jl/Mp8xHFDuvIHDaeHt+Gv8+Dcj84zbHNugOuhZzfu4cESZO66bY8hWDU1KXL4
	 R29SnOlCYBrWHc+jzbZ2dVIaS48L3Ctl3QtxlG0FEB6o2UF1A8Q4mYA+f2AITwklpm
	 hx263aTjIlXli9gtZr6MyN67NB8JLSmBEE4CafCE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728808AbgANVEH (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 14 Jan 2020 16:04:07 -0500
Received: from mail.kernel.org ([198.145.29.99]:51804 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729134AbgANVEG (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 14 Jan 2020 16:04:06 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 8E1CB24658;
        Tue, 14 Jan 2020 21:04:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1579035845;
        bh=VdbS8mEmXSpt9DK0Rzc+X41XsKnqVc8X/04G/OEHIcM=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=OuS9j6Dv1EvS0E04zyTTEBxvfQP23u+RUjEOR6p5OmiKLuXkKThrzdUlVBuIyor6F
         TT6g0e50F1cf3gdtPor6Y2yG6LozIjmuUZCo2LJS2Gzi5wYtQkc808bRarxk98LdpE
         S3SZK/dYhtrW7smV92leXPZZPGJNbW6h7RCqKe74=
Date:   Tue, 14 Jan 2020 13:04:04 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Cc:     linux-ext4@vger.kernel.org
Subject: Re: [PATCH] fscrypt: document gfp_flags for bounce page allocation
Message-ID: <20200114210403.GB41220@gmail.com>
References: <20191231181026.47400-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191231181026.47400-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Dec 31, 2019 at 12:10:26PM -0600, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Document that fscrypt_encrypt_pagecache_blocks() allocates the bounce
> page from a mempool, and document what this means for the @gfp_flags
> argument.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/crypto/crypto.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)

Applied to fscrypt.git#master for 5.6.

- Eric
