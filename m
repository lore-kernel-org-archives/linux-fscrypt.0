Return-Path: <SRS0=g9fr=2Y=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD0EEC2D0C2
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 16:59:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B0679206DB
	for <linux-fscrypt@archiver.kernel.org>; Fri,  3 Jan 2020 16:59:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1578070780;
	bh=XYG9Pq+pG6XUj7HsgXt8s8KXLs4V9sqjvwLztTx6TVM=;
	h=Date:From:To:Subject:References:In-Reply-To:List-ID:From;
	b=B3ZiCYBZfrR09ja2GHMJYnAfrkWrtaPqZ/UNkNDY5oaij/mtULwixDTl/wdJOUyxj
	 7RierKg8IgIixakUngQoA5N00BAgAX7kGJA9IW++gudVHr9y8Vwk0nQpDTPowWjPGi
	 tKICNVQnmSoHT/aa3oOXj2XGqAWmOqS+nHRZ3Ts4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727912AbgACQ7k (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Fri, 3 Jan 2020 11:59:40 -0500
Received: from mail.kernel.org ([198.145.29.99]:55192 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727769AbgACQ7k (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Fri, 3 Jan 2020 11:59:40 -0500
Received: from gmail.com (unknown [104.132.1.77])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id C901A206DB
        for <linux-fscrypt@vger.kernel.org>; Fri,  3 Jan 2020 16:59:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1578070779;
        bh=XYG9Pq+pG6XUj7HsgXt8s8KXLs4V9sqjvwLztTx6TVM=;
        h=Date:From:To:Subject:References:In-Reply-To:From;
        b=kcqA9k316FpwmaIOzgJeAqMrfOPwG8jNxiUYCVzhUXrgZGTYk8fiVgFEyRASrW6NB
         ronpRfD0bKIIFqOo+DwvW1OwUDYD80dFitbUB9vPCRMKScXDu5+fd1/e7c7lT5N0IS
         RD0iueydJ6ZH+BdzNZPSHEKIbtqRoHNYvsGygB8w=
Date:   Fri, 3 Jan 2020 08:59:38 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH] fscrypt: move fscrypt_d_revalidate() to fname.c
Message-ID: <20200103165938.GG19521@gmail.com>
References: <20191209204359.228544-1-ebiggers@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20191209204359.228544-1-ebiggers@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Dec 09, 2019 at 12:43:59PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> fscrypt_d_revalidate() and fscrypt_d_ops really belong in fname.c, since
> they're specific to filenames encryption.  crypto.c is for contents
> encryption and general fs/crypto/ initialization and utilities.
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
>  fs/crypto/crypto.c          | 50 -------------------------------------
>  fs/crypto/fname.c           | 49 ++++++++++++++++++++++++++++++++++++
>  fs/crypto/fscrypt_private.h |  2 +-
>  3 files changed, 50 insertions(+), 51 deletions(-)

Applied to fscrypt.git#master for 5.6.

- Eric
