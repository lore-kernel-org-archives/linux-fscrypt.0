Return-Path: <SRS0=UG77=AS=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36059C433DF
	for <linux-fscrypt@archiver.kernel.org>; Tue,  7 Jul 2020 17:50:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1F2D2206E2
	for <linux-fscrypt@archiver.kernel.org>; Tue,  7 Jul 2020 17:50:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728262AbgGGRug (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 7 Jul 2020 13:50:36 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55600 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728211AbgGGRuf (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 7 Jul 2020 13:50:35 -0400
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk [IPv6:2a00:1098:0:82:1000:25:2eeb:e3e3])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 72C94C061755;
        Tue,  7 Jul 2020 10:50:35 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
        (Authenticated sender: krisman)
        with ESMTPSA id 651CF2A39FD
From:   Gabriel Krisman Bertazi <krisman@collabora.com>
To:     Daniel Rosenberg <drosen@google.com>
Cc:     "Theodore Ts'o" <tytso@mit.edu>, linux-ext4@vger.kernel.org,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>,
        linux-f2fs-devel@lists.sourceforge.net,
        Eric Biggers <ebiggers@kernel.org>,
        linux-fscrypt@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        kernel-team@android.com
Subject: Re: [PATCH v10 1/4] unicode: Add utf8_casefold_hash
Organization: Collabora
References: <20200707113123.3429337-1-drosen@google.com>
        <20200707113123.3429337-2-drosen@google.com>
Date:   Tue, 07 Jul 2020 13:50:27 -0400
In-Reply-To: <20200707113123.3429337-2-drosen@google.com> (Daniel Rosenberg's
        message of "Tue, 7 Jul 2020 04:31:20 -0700")
Message-ID: <877dvftdss.fsf@collabora.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.3 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Daniel Rosenberg <drosen@google.com> writes:

> This adds a case insensitive hash function to allow taking the hash
> without needing to allocate a casefolded copy of the string.
>
> The existing d_hash implementations for casefolding allocates memory
> within rcu-walk, by avoiding it we can be more efficient and avoid
> worrying about a failed allocation.
>
> Signed-off-by: Daniel Rosenberg <drosen@google.com>

Reviewed-by: Gabriel Krisman Bertazi <krisman@collabora.com>

-- 
Gabriel Krisman Bertazi
