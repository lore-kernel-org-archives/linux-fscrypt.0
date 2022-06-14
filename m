Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40483C43334
	for <linux-fscrypt@archiver.kernel.org>; Tue, 14 Jun 2022 04:00:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232558AbiFNEAi (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 14 Jun 2022 00:00:38 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54966 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232385AbiFNEAh (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 14 Jun 2022 00:00:37 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 495A631392;
        Mon, 13 Jun 2022 21:00:37 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id D5C82615E7;
        Tue, 14 Jun 2022 04:00:36 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2CB86C3411B;
        Tue, 14 Jun 2022 04:00:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1655179236;
        bh=ZSO/9XTLGek3bbn+A4yP3tp7yC83nHnozrBB7mYZ2S0=;
        h=Date:From:To:Subject:References:In-Reply-To:From;
        b=jcrbE9O5hbJl6L2U0QQKUo9Iweb4h9JoMSnjHt1cSezPLhhf2HuSDFbqJziTNDNog
         +thxyBv1Kt+EkHsiWUmbu0ahaazwtYPIw4OXBAwkMoCzMd2kOKdkfw87brrXxAoN+J
         z0lZ0WEeAGckeuO4lf7v3I0pHiNGj+mw/6LmLb7VBWGaQwdV3RMo1Aw54zWyaPmGth
         HS7BbO94+M90DAyzuaHduDwnHfRANiIu9p0PqGlGRzJ8nLYm9YpRcfAD/AdLaCCbLR
         H0vJp063iI15XMFS7IPZILEuNinAlb0ddllzjYcBQYa12loCNCBQmdT9aG3hk52y3o
         42/tCwftIaA+w==
Date:   Mon, 13 Jun 2022 21:00:34 -0700
From:   Eric Biggers <ebiggers@kernel.org>
To:     dsterba@suse.cz, linux-fscrypt@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH] fs-verity: mention btrfs support
Message-ID: <YqgH4nDxZmufFzYZ@sol.localdomain>
References: <20220610000616.18225-1-ebiggers@kernel.org>
 <20220613153955.GA20633@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220613153955.GA20633@twin.jikos.cz>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Jun 13, 2022 at 05:39:55PM +0200, David Sterba wrote:
> On Thu, Jun 09, 2022 at 05:06:16PM -0700, Eric Biggers wrote:
> > From: Eric Biggers <ebiggers@google.com>
> > 
> > btrfs supports fs-verity since Linux v5.15.  Document this.
> 
> The reworded paragraphs and the added section regarding btrfs look ok to
> me, thanks. I don't see linux-doc@ in CC I think the documentation
> patches should go there.
> 
> Acked-by: David Sterba <dsterba@suse.com>

I've been taking patches to fsverity.rst myself.  But I've resent this patch
with linux-doc added to Cc in case anyone has any review comments.

- Eric
