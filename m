Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F5BEC43217
	for <linux-fscrypt@archiver.kernel.org>; Thu,  1 Dec 2022 19:18:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230025AbiLATSk (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 1 Dec 2022 14:18:40 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:41570 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229571AbiLATSj (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 1 Dec 2022 14:18:39 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C5E18B3905;
        Thu,  1 Dec 2022 11:18:37 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 8E55AB82005;
        Thu,  1 Dec 2022 19:18:36 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1600FC433D6;
        Thu,  1 Dec 2022 19:18:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1669922315;
        bh=TLSAaaxfq9Im/Ug6pWQ7l7MLzj0kZO+NgXtEu9OvrI4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=MY+VTqXdgXpCIgGrAIVj3OoXTh9xWpJD6sY4JJnOSI4AW4U5L4tbku3iJElxs4DZr
         LmrDzg5Ep/U/BsoGkf19ZM68rZQquGGTiu4F3p6+Knc6Bue6LFb8iNRZNlw15FPr/K
         GWJPMFAyvfDCfyv/lTp+ZF5oMFkZvj4zALffH58JPaJqOF+tl9VCUsVgSLaNKq4IXV
         10BR6XpZn9QoUx81eWzDX6S+gApZVJ4hB46j4RHwpnFlNfl4+VQrxmJMlPW0CUfXlr
         rM3+D5CJsuta2yr4Uwvuhmb+wqZ6/ujfQ33j1bK9GDUFGRBprbpNFLjZAQbc6YziP5
         jjP0q3cFXheBg==
Date:   Thu, 1 Dec 2022 11:18:33 -0800
From:   Eric Biggers <ebiggers@kernel.org>
To:     xiubli@redhat.com
Cc:     idryomov@gmail.com, ceph-devel@vger.kernel.org, jlayton@kernel.org,
        khiremat@redhat.com, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH] ceph: make sure all the files successfully put before
 unmounting
Message-ID: <Y4j+Ccqzi6JxWchv@sol.localdomain>
References: <20221201065800.18149-1-xiubli@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20221201065800.18149-1-xiubli@redhat.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, Dec 01, 2022 at 02:58:00PM +0800, xiubli@redhat.com wrote:
> From: Xiubo Li <xiubli@redhat.com>
> 
> When close a file it will be deferred to call the fput(), which
> will hold the inode's i_count. And when unmounting the mountpoint
> the evict_inodes() may skip evicting some inodes.
> 
> If encrypt is enabled the kernel generate a warning when removing
> the encrypt keys when the skipped inodes still hold the keyring:

This does not make sense.  Unmounting is only possible once all the files on the
filesystem have been closed.

- Eric
