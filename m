Return-Path: <SRS0=R2Bm=BA=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55460C433E0
	for <linux-fscrypt@archiver.kernel.org>; Tue, 21 Jul 2020 00:32:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 313EA207FC
	for <linux-fscrypt@archiver.kernel.org>; Tue, 21 Jul 2020 00:32:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1595291545;
	bh=xWhYH850+Dy/XXhslyjfk8C0ENR4CMAVpP1c8JCWOrM=;
	h=Date:From:To:Subject:References:In-Reply-To:List-ID:From;
	b=L0HGD44uF6LV5/7BK7W+OLY5WK2xQWK1oWNymFrGYOhEAy9U3CKrYFrBgWOHDJVgc
	 5ChCbLK5lW1JC3rmCNTGMKbA2g1D/QEbLebChrJcgIvQdt+fn/a/VNPLyPk2EeQrM/
	 WSJOdHIO8qF6sy2R8orRYJ8QLHAZXGVjvKrpO+NI=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726647AbgGUAcZ (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 20 Jul 2020 20:32:25 -0400
Received: from mail.kernel.org ([198.145.29.99]:33166 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726546AbgGUAcY (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 20 Jul 2020 20:32:24 -0400
Received: from sol.localdomain (c-107-3-166-239.hsd1.ca.comcast.net [107.3.166.239])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 3AFC4207FC
        for <linux-fscrypt@vger.kernel.org>; Tue, 21 Jul 2020 00:32:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1595291544;
        bh=xWhYH850+Dy/XXhslyjfk8C0ENR4CMAVpP1c8JCWOrM=;
        h=Date:From:To:Subject:References:In-Reply-To:From;
        b=WhdvXJf1dR3OBzK+3gAb6/EQujerctpvM/gMBh96TJf+SWH6sFZhPEventMoUJbV/
         cPsYPpK3M8U6fee+35+Lu9ZdpVMp9aNN6U5RC+ylQwZ1BXwG7ZY+WgrskCKteaRMiG
         HF3H1e8aVCxv9/YLpKHg1YF6ybKaXrrwbwomO2aA=
Date:   Mon, 20 Jul 2020 17:32:22 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH] fscrypt: add comments that describe the HKDF info strings
Message-ID: <20200721003222.GA7464@sol.localdomain>
References: <20200708215529.146890-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200708215529.146890-1-ebiggers@kernel.org>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Jul 08, 2020 at 02:55:29PM -0700, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> Each HKDF context byte is associated with a specific format of the
> remaining part of the application-specific info string.  Add comments so
> that it's easier to keep track of what these all are.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Applied to fscrypt.git#master for 5.9.
