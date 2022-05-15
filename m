Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E395CC433FE
	for <linux-fscrypt@archiver.kernel.org>; Sun, 15 May 2022 03:42:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234935AbiEODml (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 14 May 2022 23:42:41 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42836 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235513AbiEODmj (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 14 May 2022 23:42:39 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 61D6CBC9E;
        Sat, 14 May 2022 20:42:30 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 925CAB80B31;
        Sun, 15 May 2022 03:42:29 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2C310C385B8;
        Sun, 15 May 2022 03:42:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1652586148;
        bh=AEP69mmaVVaYWzdONffLQf2xP264iKgYPDsWkfZaSIM=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=DPH3JUEMGxjKHPzO25aS/3t/bw0yEay8eZ6bXx+SFl3Q1j7Yn2EcBdE/UGu1haTbZ
         MNbna7tzjcMNA2uO3GkwqWc7e8E2YafdBdGtDIfdpU6vifS39DU121c+Rfte8IvrXB
         ySBjLkYFIhfgbkrtukFqkuWSX0S4dln902Z+S05zT8jGWlmMWZdAYvn2XIck0M75P3
         dmaHzqeE25/pB/RxhnLUcLy/ps0zNuf45SBOMLYa7mHffY3U12g6xW5H0lvjyrCFL8
         xbdo1MWBuvVXO1uOYxuZ9FTuo512VlIaZQ7ScxJneK2/y3MrqnJECfvGZx3QNdJCgc
         undF0CfEwEymA==
Date:   Sat, 14 May 2022 20:42:26 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Ritesh Harjani <ritesh.list@gmail.com>
Cc:     linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org,
        Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.cz>
Subject: Re: [PATCHv2 3/3] ext4: Refactor and move
 ext4_ioc_get_encryption_pwsalt()
Message-ID: <YoB2ooMWcb9vTmFt@sol.localdomain>
References: <cover.1652539361.git.ritesh.list@gmail.com>
 <3256b969d6e858414f08e0ca2f5117e76fdc2057.1652539361.git.ritesh.list@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3256b969d6e858414f08e0ca2f5117e76fdc2057.1652539361.git.ritesh.list@gmail.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Sat, May 14, 2022 at 10:52:48PM +0530, Ritesh Harjani wrote:
> diff --git a/fs/ext4/ioctl.c b/fs/ext4/ioctl.c

The include <linux/uuid.h> can be removed from this file.

> diff --git a/fs/ext4/crypto.c b/fs/ext4/crypto.c
[...]
> +int ext4_ioc_get_encryption_pwsalt(struct file *filp, void __user *arg)

ext4 has more functions named "ext4_ioctl_*" thtan "ext4_ioc_*", so it might be
worth adding those extra 2 letters for consistency.

Other than the above minor nits this looks good, thanks!

Reviewed-by: Eric Biggers <ebiggers@google.com>

- Eric
