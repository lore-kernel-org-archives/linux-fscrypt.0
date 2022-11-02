Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6423C4332F
	for <linux-fscrypt@archiver.kernel.org>; Wed,  2 Nov 2022 22:07:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230473AbiKBWHU (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 2 Nov 2022 18:07:20 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52056 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229681AbiKBWHT (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 2 Nov 2022 18:07:19 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5FFF7A44F;
        Wed,  2 Nov 2022 15:07:18 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 06DF061C4E;
        Wed,  2 Nov 2022 22:07:18 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5A208C433C1;
        Wed,  2 Nov 2022 22:07:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1667426837;
        bh=01juTMGfzuscVFYhZemJDxSax5NWxtO7tsiIbM5KTQI=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=QD8BMwRMfnGHqvKhNzuT1f9X44RTCkTQIkSm4+n5Y7XgzOHZHdqsldypj8IhNv9uo
         0GJ6asSG66Wk2RKvSjjq07zDMeA7hdEvZ1H/zHe9ldWdkHPqLGG4Lx0HN/vVSWqDV0
         79l0RrYzLcFMphbmP6VSddWALuJ7sJiQyS26wX31McASf67vyT6ZQvTgRDdtpCDGMI
         7ApqYiM7hvu/YtB3m82/+ANNzPcLigXvg0yeDI+0r3HOvOhtdLLx3DYHQFvPkzUn+L
         VM6T9HMkXY++GdqLZLa5ZjYEQLmn4DUh1XTb9Ud5eJ7rRKZv+Z/ckmO8hd6am+/uaP
         Pug54Shs2Dz+g==
Date:   Wed, 2 Nov 2022 15:07:15 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Andreas Dilger <adilger@dilger.ca>
Cc:     linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
Subject: Re: [e2fsprogs PATCH] e2fsck: don't allow journal inode to have
 encrypt flag
Message-ID: <Y2LqExmYPBIOypW0@sol.localdomain>
References: <20221102053554.190282-1-ebiggers@kernel.org>
 <B8D39676-D175-4AC9-B74B-95D4AAF03A9A@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8D39676-D175-4AC9-B74B-95D4AAF03A9A@dilger.ca>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Nov 02, 2022 at 02:55:05PM -0600, Andreas Dilger wrote:
> On Nov 1, 2022, at 11:35 PM, Eric Biggers <ebiggers@kernel.org> wrote:
> > 
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > Since the kernel is being fixed to consider journal inodes with the
> > 'encrypt' flag set to be invalid, also update e2fsck accordingly.
> > 
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > ---
> > e2fsck/journal.c                   |   3 ++-
> > tests/f_badjour_encrypted/expect.1 |  30 +++++++++++++++++++++++++++++
> > tests/f_badjour_encrypted/expect.2 |   7 +++++++
> > tests/f_badjour_encrypted/image.gz | Bin 0 -> 2637 bytes
> 
> Good to have a test case for this.
> 
> In the past Ted has asked that new test cases are generated via mke2fs
> and debugfs in "f_XXX/script" file rather than a binary image, if possible.

I didn't realize the test suite supported this.  Done in v2, thanks!

- Eric
