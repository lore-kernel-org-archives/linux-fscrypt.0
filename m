Return-Path: <linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55F97C56201
	for <linux-fscrypt@archiver.kernel.org>; Sun, 22 Nov 2020 04:56:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1776C20885
	for <linux-fscrypt@archiver.kernel.org>; Sun, 22 Nov 2020 04:56:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727262AbgKVEzn (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Sat, 21 Nov 2020 23:55:43 -0500
Received: from bhuna.collabora.co.uk ([46.235.227.227]:50974 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727236AbgKVEzn (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Sat, 21 Nov 2020 23:55:43 -0500
Received: from [127.0.0.1] (localhost [127.0.0.1])
        (Authenticated sender: krisman)
        with ESMTPSA id 8363F1F45BFE
From:   Gabriel Krisman Bertazi <krisman@collabora.com>
To:     Daniel Rosenberg <drosen@google.com>
Cc:     "Theodore Y . Ts'o" <tytso@mit.edu>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        Eric Biggers <ebiggers@kernel.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Chao Yu <chao@kernel.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Richard Weinberger <richard@nod.at>,
        linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-mtd@lists.infradead.org, kernel-team@android.com,
        Eric Biggers <ebiggers@google.com>
Subject: Re: [PATCH v4 1/3] libfs: Add generic function for setting dentry_ops
Organization: Collabora
References: <20201119060904.463807-1-drosen@google.com>
        <20201119060904.463807-2-drosen@google.com>
Date:   Sat, 21 Nov 2020 23:55:37 -0500
In-Reply-To: <20201119060904.463807-2-drosen@google.com> (Daniel Rosenberg's
        message of "Thu, 19 Nov 2020 06:09:02 +0000")
Message-ID: <87tutij8hi.fsf@collabora.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/27.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Daniel Rosenberg <drosen@google.com> writes:

> This adds a function to set dentry operations at lookup time that will
> work for both encrypted filenames and casefolded filenames.
>
> A filesystem that supports both features simultaneously can use this
> function during lookup preparations to set up its dentry operations once
> fscrypt no longer does that itself.
>
> Currently the casefolding dentry operation are always set if the
> filesystem defines an encoding because the features is toggleable on
> empty directories. Unlike in the encryption case, the dentry operations
> used come from the parent. Since we don't know what set of functions
> we'll eventually need, and cannot change them later, we enable the
> casefolding operations if the filesystem supports them at all.
>
> By splitting out the various cases, we support as few dentry operations
> as we can get away with, maximizing compatibility with overlayfs, which
> will not function if a filesystem supports certain dentry_operations.
>
> Signed-off-by: Daniel Rosenberg <drosen@google.com>
> Reviewed-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Gabriel Krisman Bertazi <krisman@collabora.com>

-- 
Gabriel Krisman Bertazi
