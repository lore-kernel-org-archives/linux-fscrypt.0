Return-Path: <linux-fscrypt-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4997C6FA8E
	for <linux-fscrypt@archiver.kernel.org>; Thu,  2 Mar 2023 22:36:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230173AbjCBWg5 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Thu, 2 Mar 2023 17:36:57 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55440 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229709AbjCBWg4 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 2 Mar 2023 17:36:56 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id EE9E6515C1;
        Thu,  2 Mar 2023 14:36:55 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id A5017B811EF;
        Thu,  2 Mar 2023 22:36:54 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4B045C433EF;
        Thu,  2 Mar 2023 22:36:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1677796613;
        bh=m39fw1icTY50SWFvnYJ2LWIZxM09EX3LTqdVMzccAdk=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=Tm1135vaGcDI0GiEbWxiC7/BjErlIrT9mosKbqG4MttFGOA0bb2OWNs8dJ17GCqQt
         +yV7KWr53UK79I0eC61uw4AODlL4IMlH8DNjRW5SGQAbZfekAxtl/EUUtk595hcYq4
         ARQLt2emSWnSDhUJmkGc8dOqf1yJe0p+4Tl055xrfgUi0d0VjZR9V0d8SfaBfQLgNd
         DLXvXLE9XgSN2g1sRe1ck2EghWOLycZDTVY8FCVbsHbtXukuFwuITfthmGOEWWkDnl
         oQlbISr6/A8DY/TZIisQpQ+SmrSB6jB/xgAjmtUGDLNazd+LnsvDrk4kPlm1PbY13a
         +jND3XZHNQ5vw==
Date:   Thu, 2 Mar 2023 22:36:51 +0000
From:   Eric Biggers <ebiggers@kernel.org>
To:     Nathan Huckleberry <nhuck@google.com>
Cc:     linux-block@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
        linux-fscrypt@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH] blk-crypto: make blk_crypto_evict_key() always try to
 evict
Message-ID: <ZAElA0k4Q/Pb7xNT@gmail.com>
References: <20230226203816.207449-1-ebiggers@kernel.org>
 <CAJkfWY4UOmizG=gm4+Zob7PhwMcmDe7mEviTb-hULT7ByCuqew@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJkfWY4UOmizG=gm4+Zob7PhwMcmDe7mEviTb-hULT7ByCuqew@mail.gmail.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Thu, Mar 02, 2023 at 02:28:00PM -0800, Nathan Huckleberry wrote:
> Hey Eric,
> 
> On Sun, Feb 26, 2023 at 12:43 PM Eric Biggers <ebiggers@kernel.org> wrote:
> >
> > From: Eric Biggers <ebiggers@google.com>
> >
> > Once all I/O using a blk_crypto_key has completed, filesystems can call
> > blk_crypto_evict_key().  However, the block layer doesn't call
> > blk_crypto_put_keyslot() until the request is being cleaned up, which
> > happens after upper layers have been told (via bio_endio()) the I/O has
> > completed.  This causes a race condition where blk_crypto_evict_key()
> > can see 'slot_refs > 0' without there being an actual bug.
> >
> > This makes __blk_crypto_evict_key() hit the
> > 'WARN_ON_ONCE(atomic_read(&slot->slot_refs) != 0)' and return without
> > doing anything, eventually causing a use-after-free in
> > blk_crypto_reprogram_all_keys().  (This is a very rare bug and has only
> > been seen when per-file keys are being used with fscrypt.)
> >
> > There are two options to fix this: either release the keyslot in
> > blk_update_request() just before bio_endio() is called on the request's
> > last bio, or just make __blk_crypto_evict_key() ignore slot_refs.  Let's
> > go with the latter solution for now, since it avoids adding overhead to
> > the loop in blk_update_request().  (It does have the disadvantage that
> > hypothetical bugs where a key is evicted while still in-use become
> > harder to detect.  But so far there haven't been any such bugs anyway.)
> 
> I disagree with the proposal to ignore the race condition in
> blk_crypto_evict_key(). As you said, ignoring the error could lead to
> undetected bugs in the future. Instead, I think we should focus on
> fixing the function ordering so that blk_crypto_put_keyslot() is
> called before blk_crypto_evict_key().
> 
> I think the overhead is a necessary trade-off to ensure correctness.
> 
> Thanks,

Sure, I'm concerned about pushback on adding something to blk_update_request()
that's not critical, but I'll send out that patch for consideration too.

- Eric
