Return-Path: <SRS0=9auF=D4=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24C0FC4363A
	for <linux-fscrypt@archiver.kernel.org>; Wed, 21 Oct 2020 18:46:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7AC0022456
	for <linux-fscrypt@archiver.kernel.org>; Wed, 21 Oct 2020 18:46:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1603306014;
	bh=NoLMYTXbrovew7WM91LBaZpPU9YA1jHiL7nszKMwBWM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=J7xSBkqLHWkHqMl1uqMM93bm+/CK17libjeRWR+uyCFO97xPIMxHD53rhaSEhoK9/
	 /IF+nus9iuV+ppAJ9xaEroYI5+ozNkICH+xmPTOe6sW2i5yuat7l92T+SaAvPmGajA
	 qbU0I6d0i+vxZSZE73y1WLj6gs7kuZe/k6wtFWeo=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2440774AbgJUSqy (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 21 Oct 2020 14:46:54 -0400
Received: from mail.kernel.org ([198.145.29.99]:53378 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2436568AbgJUSqy (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 21 Oct 2020 14:46:54 -0400
Received: from gmail.com (unknown [104.132.1.76])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 6E7F922456;
        Wed, 21 Oct 2020 18:46:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1603306013;
        bh=NoLMYTXbrovew7WM91LBaZpPU9YA1jHiL7nszKMwBWM=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=wFAvTbvIE5tgZRcXKflGfrNeOk5A2vqs7HQ2gBm2h8t301rX30tug6Q0djXDcIx+2
         DKntu1ew6DXsbVG7r6FoWPyccd/8Porw05fGByje96TE9EdwlVNTBSeo3hYSNYNrFX
         yVrUmHi6vSlmMAWpatzirI2ep/2ycmhs2EnW3XWc=
Date:   Wed, 21 Oct 2020 11:46:51 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     luca.boccassi@gmail.com
Cc:     linux-fscrypt@vger.kernel.org
Subject: Re: [fsverity-utils PATCH] Makefile check: use LD_LIBRARY_PATH with
 USE_SHARED_LIB
Message-ID: <20201021184651.GA2326972@gmail.com>
References: <20201020171110.2718640-1-luca.boccassi@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20201020171110.2718640-1-luca.boccassi@gmail.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Oct 20, 2020 at 06:11:10PM +0100, luca.boccassi@gmail.com wrote:
> From: Luca Boccassi <luca.boccassi@microsoft.com>
> 
> When USE_SHARED_LIB is set, the fsverity binary is dynamically linked,
> so the check rule fails. Set LD_LIBRARY_PATH to the working directory.
> 
> Signed-off-by: Luca Boccassi <luca.boccassi@microsoft.com>

Applied, thanks.

- Eric
