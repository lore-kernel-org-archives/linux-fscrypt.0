Return-Path: <SRS0=cMR6=25=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38503C33CA2
	for <linux-fscrypt@archiver.kernel.org>; Wed,  8 Jan 2020 18:50:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 143F920705
	for <linux-fscrypt@archiver.kernel.org>; Wed,  8 Jan 2020 18:50:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728536AbgAHSub (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 8 Jan 2020 13:50:31 -0500
Received: from outgoing-auth-1.mit.edu ([18.9.28.11]:54228 "EHLO
        outgoing.mit.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1727326AbgAHSub (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 8 Jan 2020 13:50:31 -0500
Received: from callcc.thunk.org (guestnat-104-133-0-111.corp.google.com [104.133.0.111] (may be forged))
        (authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
        by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id 008Io5fk020705
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
        Wed, 8 Jan 2020 13:50:06 -0500
Received: by callcc.thunk.org (Postfix, from userid 15806)
        id 7075E4207DF; Wed,  8 Jan 2020 13:50:05 -0500 (EST)
Date:   Wed, 8 Jan 2020 13:50:05 -0500
From:   "Theodore Y. Ts'o" <tytso@mit.edu>
To:     Daniel Rosenberg <drosen@google.com>
Cc:     linux-ext4@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>,
        Chao Yu <chao@kernel.org>,
        linux-f2fs-devel@lists.sourceforge.net,
        Eric Biggers <ebiggers@kernel.org>,
        linux-fscrypt@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Gabriel Krisman Bertazi <krisman@collabora.com>,
        kernel-team@android.com
Subject: Re: [PATCH v2 0/6] Support for Casefolding and Encryption
Message-ID: <20200108185005.GE263696@mit.edu>
References: <20200107051638.40893-1-drosen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200107051638.40893-1-drosen@google.com>
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Mon, Jan 06, 2020 at 09:16:32PM -0800, Daniel Rosenberg wrote:
> changes:
> fscrypt moved to separate thread to rebase on fscrypt dev branch
> addressed feedback, plus some minor fixes

What branch was this based on?  There is no fscrypt dev branch, so I
took the fscrypt master branch, and then applied your fscrypt patches,
and then I tried to apply this patch series.  I got patch conflicts
starting with the very first patch.

Applying: TMP: fscrypt: Add support for casefolding with encryption
error: patch failed: fs/crypto/Kconfig:9
error: fs/crypto/Kconfig: patch does not apply
error: patch failed: fs/crypto/fname.c:12
error: fs/crypto/fname.c: patch does not apply
error: patch failed: fs/crypto/fscrypt_private.h:12
error: fs/crypto/fscrypt_private.h: patch does not apply
error: patch failed: fs/crypto/keysetup.c:192
error: fs/crypto/keysetup.c: patch does not apply
error: patch failed: fs/crypto/policy.c:67
error: fs/crypto/policy.c: patch does not apply
error: patch failed: fs/inode.c:20
error: fs/inode.c: patch does not apply
error: patch failed: include/linux/fscrypt.h:127
error: include/linux/fscrypt.h: patch does not apply
Patch failed at 0001 TMP: fscrypt: Add support for casefolding with encryption
hint: Use 'git am --show-current-patch' to see the failed patch
When you have resolved this problem, run "git am --continue".
If you prefer to skip this patch, run "git am --skip" instead.
To restore the original branch and stop patching, run "git am --abort".

   	       		       	   		  - Ted
