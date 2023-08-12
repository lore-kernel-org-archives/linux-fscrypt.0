Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B7B8C001B0
	for <linux-fscrypt@archiver.kernel.org>; Sat, 12 Aug 2023 22:43:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230110AbjHLWnC (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 12 Aug 2023 18:43:02 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39994 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229589AbjHLWnB (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 12 Aug 2023 18:43:01 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A5C9793;
        Sat, 12 Aug 2023 15:43:04 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 3827461769;
        Sat, 12 Aug 2023 22:43:04 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 551AFC433C8;
        Sat, 12 Aug 2023 22:43:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1691880183;
        bh=CbC9JInFmjulwcz4C33K7BEDvX9wo/dSMwUbqt+ZdH4=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=BtRkTRqOFnjCQGBKXtBFZw7PMH+yAlhkYNShFgpKCrTPsVMA/U43qtNHdf/3lvx33
         FJkocPTDz73i3mw73rZKGNdWd3gfRG0ePadF6hZg32Yt4NKhCCXbectkds77H1+OJr
         AePzwgb22zTDMzUyW9KN4J8OgIDenIhdMMVR4ja5oWKVL1kA76ud+TmoHdgNnnHYkw
         ewZeIbOoyTCEgcK60FyPQQtL/wFrVNp0xke6aLrsraug2JDjGndj5BQjUoOaMmSTEM
         Lu5cwDlDkjnwvXRDXDgwvlCE6X4PEUGJyKRun0onJEmVnVbSgsjbHyuv1gb2gp+UZI
         qUDkji1u+v3ag==
Date:   Sat, 12 Aug 2023 15:43:01 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Cc:     Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
        David Sterba <dsterba@suse.com>,
        "Theodore Y . Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>, kernel-team@meta.com,
        linux-btrfs@vger.kernel.org, linux-fscrypt@vger.kernel.org
Subject: Re: [PATCH v3 15/16] fscrypt: allow asynchronous info freeing
Message-ID: <20230812224301.GC41642@sol.localdomain>
References: <cover.1691505882.git.sweettea-kernel@dorminy.me>
 <6c4a29fdfabf90f1a43dffff04debd54f941cf93.1691505882.git.sweettea-kernel@dorminy.me>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6c4a29fdfabf90f1a43dffff04debd54f941cf93.1691505882.git.sweettea-kernel@dorminy.me>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Tue, Aug 08, 2023 at 01:08:32PM -0400, Sweet Tea Dorminy wrote:
> btrfs sometimes frees extents while holding a mutex. This makes it hard
> to free the prepared keys associated therewith, as the free process may
> need to take a semaphore. Just offloading freeing to rcu doesn't work,
> as rcu may call the callback in softirq context, which also doesn't
> allow taking a semaphore. Thus, for extent infos, offload their freeing
> to the general system workqueue.
> 
> Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>

Please be specific about which mutex and which semaphore.

What is the specific problem?

- Eric
