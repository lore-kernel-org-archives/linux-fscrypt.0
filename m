Return-Path: <SRS0=XJag=3R=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14C34C33CB2
	for <linux-fscrypt@archiver.kernel.org>; Tue, 28 Jan 2020 23:40:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DCE432173E
	for <linux-fscrypt@archiver.kernel.org>; Tue, 28 Jan 2020 23:40:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1580254823;
	bh=FTTLR9MIHR1/Gdr9WwAJ4oAT91xeiib4YGas1QXvfTI=;
	h=Subject:From:In-Reply-To:References:Date:To:Cc:List-ID:From;
	b=gNv9aQuBKph1pzs+wNHb/TWNvKlRvX27N5V8nKpnTLvCaPYsACmghGLWAIkXO7Ua1
	 wFFLGVAhs4BDQXbB1tiq1du9eECqGNvpG9FOOzkGNkXfOHSUiAQ9XrsjnCUJgT8Nqa
	 4bFnAhP6kwDrzBP7czejph6PZsOU6S/sfDHGYGG0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726428AbgA1XkC (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 28 Jan 2020 18:40:02 -0500
Received: from mail.kernel.org ([198.145.29.99]:49198 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726293AbgA1XkC (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 28 Jan 2020 18:40:02 -0500
Subject: Re: [GIT PULL] fscrypt updates for 5.6
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1580254801;
        bh=FTTLR9MIHR1/Gdr9WwAJ4oAT91xeiib4YGas1QXvfTI=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=nRScizGtR1OS6FiMFccAEgDKKl9hkf3hBIEfV5G3fVot+rYpGszsKD39er9Ei1F62
         oCnFjli/S49RKmryJe8Po/gzCi0RPkU/zl92yUelxjPpUZozEOJIvEBTRHVkcJy5rM
         d8BaZB0Ctx8uvnhBQO9PQTt/htJzAOtc01y6gj6s=
From:   pr-tracker-bot@kernel.org
In-Reply-To: <20200128014653.GA960@sol.localdomain>
References: <20200128014653.GA960@sol.localdomain>
X-PR-Tracked-List-Id: <linux-fsdevel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20200128014653.GA960@sol.localdomain>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git
 tags/fscrypt-for-linus
X-PR-Tracked-Commit-Id: edc440e3d27fb31e6f9663cf413fad97d714c060
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: f0d874414329a86b67198cb0299d0dc9310592f1
Message-Id: <158025480189.16364.5716437858039757596.pr-tracker-bot@kernel.org>
Date:   Tue, 28 Jan 2020 23:40:01 +0000
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Daniel Rosenberg <drosen@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

The pull request you sent on Mon, 27 Jan 2020 17:46:53 -0800:

> https://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fscrypt-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/f0d874414329a86b67198cb0299d0dc9310592f1

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker
