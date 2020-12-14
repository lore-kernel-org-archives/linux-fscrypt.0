Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F0AEC4361B
	for <linux-fscrypt@archiver.kernel.org>; Mon, 14 Dec 2020 20:57:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1645823877
	for <linux-fscrypt@archiver.kernel.org>; Mon, 14 Dec 2020 20:57:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2503502AbgLNU5Q (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 14 Dec 2020 15:57:16 -0500
Received: from mail.kernel.org ([198.145.29.99]:37242 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2503474AbgLNU5K (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 14 Dec 2020 15:57:10 -0500
Subject: Re: [f2fs-dev] [GIT PULL] fsverity updates for 5.11
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1607979389;
        bh=SYq1bIYMrR7dKenr5O6tsqn7Cs9DoPJBsBbmjg3Pi4w=;
        h=From:In-Reply-To:References:Date:To:Cc:From;
        b=D5RYJr1xHimBJzu0z4RPdsPgwzc83vHfyuniQ8o8Ypw/C58SdGKFotbwWwt8kUMEC
         aSr191iwAitghakUcscUOHJlfdEvkbLS7A1P3aAeSDVRAjUfTEw7yXy0/b6sJPs2JU
         jJIgNFuBuhFbgR7D4f9W0IxZjGN4RIro0rwuBEfQXhB3SPvfNHLHPPTGT0+ILjjkmj
         Z3HaPRCzQBk6RTGY4QQoe+xhv5wnXGzQFRFdp1oz56afzCMC+/YVdzpj7zoqzuBZ+s
         ZmHvBkGQYTLYrZKijUzX9ytGRe5b0BIHN6txWgodrLePpiLCvO2opPorLSXQZlh/Rw
         wcEDaxnFxsQKA==
From:   pr-tracker-bot@kernel.org
In-Reply-To: <X9b910/Ldj6kdljm@sol.localdomain>
References: <X9b910/Ldj6kdljm@sol.localdomain>
X-PR-Tracked-List-Id: <linux-f2fs-devel.lists.sourceforge.net>
X-PR-Tracked-Message-Id: <X9b910/Ldj6kdljm@sol.localdomain>
X-PR-Tracked-Remote: https://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fsverity-for-linus
X-PR-Tracked-Commit-Id: bde493349025ca0559e2fff88592935af3b8df19
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 51895d58c7c0c65afac21570cc14a7189942959a
Message-Id: <160797938955.26822.4023695605419451387.pr-tracker-bot@kernel.org>
Date:   Mon, 14 Dec 2020 20:56:29 +0000
To:     Eric Biggers <ebiggers@kernel.org>
Cc:     Linus Torvalds <torvalds@linux-foundation.org>,
        Theodore Ts'o <tytso@mit.edu>, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

The pull request you sent on Sun, 13 Dec 2020 21:53:27 -0800:

> https://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git tags/fsverity-for-linus

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/51895d58c7c0c65afac21570cc14a7189942959a

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/prtracker.html
