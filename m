Return-Path: <SRS0=z5Dv=ZZ=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F72FC432C0
	for <linux-fscrypt@archiver.kernel.org>; Tue,  3 Dec 2019 19:45:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 69B60206EC
	for <linux-fscrypt@archiver.kernel.org>; Tue,  3 Dec 2019 19:45:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726785AbfLCTpB (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Tue, 3 Dec 2019 14:45:01 -0500
Received: from bhuna.collabora.co.uk ([46.235.227.227]:36160 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726564AbfLCTpA (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 3 Dec 2019 14:45:00 -0500
Received: from localhost (unknown [IPv6:2610:98:8005::647])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: krisman)
        by bhuna.collabora.co.uk (Postfix) with ESMTPSA id 28F2D28D559;
        Tue,  3 Dec 2019 19:44:59 +0000 (GMT)
From:   Gabriel Krisman Bertazi <krisman@collabora.com>
To:     Daniel Rosenberg <drosen@google.com>
Cc:     "Theodore Ts'o" <tytso@mit.edu>, linux-ext4@vger.kernel.org,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>,
        linux-f2fs-devel@lists.sourceforge.net,
        Eric Biggers <ebiggers@kernel.org>,
        linux-fscrypt@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        kernel-team@android.com
Subject: Re: [PATCH 6/8] ext4: Use struct super_block's casefold data
Organization: Collabora
References: <20191203051049.44573-1-drosen@google.com>
        <20191203051049.44573-7-drosen@google.com>
Date:   Tue, 03 Dec 2019 14:44:56 -0500
In-Reply-To: <20191203051049.44573-7-drosen@google.com> (Daniel Rosenberg's
        message of "Mon, 2 Dec 2019 21:10:47 -0800")
Message-ID: <85sgm1b3d3.fsf@collabora.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

Daniel Rosenberg <drosen@google.com> writes:

> Switch over to using the struct entries added to the VFS, and
> remove the redundant dentry operations.

getting this in VFS instead of per filesystem is gonna allow us to mix
not only fscrypt with case-insensitive but also overlayfs.

Need to do a closer review, but thanks for doing this!!

-- 
Gabriel Krisman Bertazi
