Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0255C433E9
	for <linux-fscrypt@archiver.kernel.org>; Sun, 21 Feb 2021 18:41:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8C93364EEC
	for <linux-fscrypt@archiver.kernel.org>; Sun, 21 Feb 2021 18:41:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230257AbhBUSlW (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sun, 21 Feb 2021 13:41:22 -0500
Received: from mail.kernel.org ([198.145.29.99]:56660 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230307AbhBUSk6 (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 21 Feb 2021 13:40:58 -0500
Received: by mail.kernel.org (Postfix) with ESMTPS id 0319164F02;
        Sun, 21 Feb 2021 18:39:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1613932783;
        bh=BdtrW9KKDysj8aSQB1bawTcYxDbJkOXemTzKewhvJ78=;
        h=Subject:From:In-Reply-To:References:Date:To:Cc:From;
        b=ZSHiINmaMM87c6IgWKHfqFHPqVNZ8AGEAnz8XoQw3V8h/DTZmurFjzS0I549CnFaz
         8ziigEHpUWC+Yx9K7cdHa618zXwvESb0mozqThsQdQO/9xnHer85BmFhFdTA/JFiZs
         cNB43Jj+y3t7xnVI0cR5xx6mAFG4sjqCZghL4/DVuh3JX9uNizhTFvhx2ZB66wbsrJ
         LZj9fjJNgQMv22UBLbwR2egxotAX/F3MNrURbYFD3bZooaX0RmCsVhx/SMrIsTVXA2
         1ICII5fGJ1f6wrLVS32rTogG4ZOZY8lrmP2Uid/vmFVYNgt7qLubvDpjSlM0BNNyUy
         TLYbik49dgJ+w==
Subject: Re: [GIT PULL] fsverity updates for 5.12
From:   pr-tracker-bot@kernel.org
In-Reply-To: <YCwBY/FsxEsnI0M/@sol.localdomain>
References: <YCwBY/FsxEsnI0M/@sol.localdomain>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <YCwBY/FsxEsnI0M/@sol.localdomain>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fsverity-for-linus
X-PR-Tracked-Commit-Id: 07c99001312cbf90a357d4877a358f796eede65b
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: f7b36dc5cb37615b568b7161ddc53d604973ec8b
Message-Id: <161393278298.20435.13432772684850802253.pr-tracker-bot@kernel.org>
Date:   Sun, 21 Feb 2021 18:39:42 +0000
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Theodore Ts'o <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Victor Hsieh <victorhsieh@google.com>
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

The pull request you sent on Tue, 16 Feb 2021 09:31:15 -0800:

> https://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fsverity-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/f7b36dc5cb37615b568b7161ddc53d604973ec8b

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
