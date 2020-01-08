Return-Path: <SRS0=cMR6=25=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65F81C33CA2
	for <linux-fscrypt@archiver.kernel.org>; Wed,  8 Jan 2020 21:24:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 31FB720705
	for <linux-fscrypt@archiver.kernel.org>; Wed,  8 Jan 2020 21:24:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DDNcIote"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727416AbgAHVYX (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Wed, 8 Jan 2020 16:24:23 -0500
Received: from mail-lj1-f196.google.com ([209.85.208.196]:35881 "EHLO
        mail-lj1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726836AbgAHVYS (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Wed, 8 Jan 2020 16:24:18 -0500
Received: by mail-lj1-f196.google.com with SMTP id r19so4892027ljg.3
        for <linux-fscrypt@vger.kernel.org>; Wed, 08 Jan 2020 13:24:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MrgqnfuzWiyeoBisKfI9WUGDpT/I3A3pzpV2omGtkBc=;
        b=DDNcIoteefV8aBFRJqRjAYF8UmeDfEGuxO5aoHpC40ksghWZNn1vYOvHVH75utqX92
         8pyR/nWuhn+vomgt79nK/sovZ1x7PhYhTnNXeT0womFAJ98oI98vJEh+zZtrLhhAsaiT
         xHAeO525OvgTSe1X+L3USeOsbOk+RWWtyuGny4uD91Ul8TIcjfd6L4XmBIrytt5zzyEs
         hQErb3i2mU9p3strf1rp4eW3q1/1zYZBB0VrVfwfyEPkEBvcTwGsqDvhRh9K2zjsT3ch
         4bymw0ydHk1l0bLwoVhIPuVYIxoBXZ9csRffl8URhKARiRZg6AEOEEzGhtohlDS2x0zL
         xbtA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=MrgqnfuzWiyeoBisKfI9WUGDpT/I3A3pzpV2omGtkBc=;
        b=C75rpTj7B/pbSq1O4LX9FPX+OrHuBrw1kXOsr5K1adrh0lOralGUk4eMMFpSea5tFM
         G/62TleSa+nilcnz6N+TmHYU47aFdAZBcYnXZQ2CTUehZnqWnHjyU5hGixKUVgrlg5fL
         CeSgM/pCQTvUB7HxkOnWK/3Efl9VT5Kn1sm3lFuw2kYhCzjzb39IyCdlYRGM+zu++yZE
         HNNKVft2HXuut/QF2P4tTcUh5f+EGgwPJTVDGRGJbghudpOu87KSwwn6rVFB7hP7oRKt
         wb5g4TYvCFT8vrhgkJVYDuyKZ6RR2EqmC0aqLxHAzsrDRTCHJVPMo9IV1j0S1DtwmkGD
         f5iA==
X-Gm-Message-State: APjAAAW9W/7d3pUkpc4bdPvqVuIT+n5+eMGNZOZo8cEb4Vc87WqfBJkc
        9tEbOq8FzttQxyanibY/sUuineYfR5UVMOQMj8/oJA==
X-Google-Smtp-Source: APXvYqzIFAaH51EKKHEbmEN6pXokDd653dkwA7mvIiTffi1G/lQMFKNkhMpqs1Z3DU3Ocqxwmy/VJxTCWBZ8KPcs8nw=
X-Received: by 2002:a05:651c:1049:: with SMTP id x9mr4073045ljm.233.1578518656460;
 Wed, 08 Jan 2020 13:24:16 -0800 (PST)
MIME-Version: 1.0
References: <20200107051638.40893-1-drosen@google.com> <20200108185005.GE263696@mit.edu>
In-Reply-To: <20200108185005.GE263696@mit.edu>
From:   Daniel Rosenberg <drosen@google.com>
Date:   Wed, 8 Jan 2020 13:24:05 -0800
Message-ID: <CA+PiJmSLFVvRazSKDWOiygtgvE3-o6m6rq9q+jUKuhP-T2RHNw@mail.gmail.com>
Subject: Re: [PATCH v2 0/6] Support for Casefolding and Encryption
To:     "Theodore Y. Ts'o" <tytso@mit.edu>
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
Content-Type: text/plain; charset="UTF-8"
Sender: linux-fscrypt-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-fscrypt.vger.kernel.org>
X-Mailing-List: linux-fscrypt@vger.kernel.org

On Wed, Jan 8, 2020 at 10:50 AM Theodore Y. Ts'o <tytso@mit.edu> wrote:
>
> On Mon, Jan 06, 2020 at 09:16:32PM -0800, Daniel Rosenberg wrote:
> > changes:
> > fscrypt moved to separate thread to rebase on fscrypt dev branch
> > addressed feedback, plus some minor fixes
>
> What branch was this based on?  There is no fscrypt dev branch, so I
> took the fscrypt master branch, and then applied your fscrypt patches,
> and then I tried to apply this patch series.  I got patch conflicts
> starting with the very first patch.
>
> Applying: TMP: fscrypt: Add support for casefolding with encryption
> error: patch failed: fs/crypto/Kconfig:9
> error: fs/crypto/Kconfig: patch does not apply
> error: patch failed: fs/crypto/fname.c:12
> error: fs/crypto/fname.c: patch does not apply
> error: patch failed: fs/crypto/fscrypt_private.h:12
> error: fs/crypto/fscrypt_private.h: patch does not apply
> error: patch failed: fs/crypto/keysetup.c:192
> error: fs/crypto/keysetup.c: patch does not apply
> error: patch failed: fs/crypto/policy.c:67
> error: fs/crypto/policy.c: patch does not apply
> error: patch failed: fs/inode.c:20
> error: fs/inode.c: patch does not apply
> error: patch failed: include/linux/fscrypt.h:127
> error: include/linux/fscrypt.h: patch does not apply
> Patch failed at 0001 TMP: fscrypt: Add support for casefolding with encryption
> hint: Use 'git am --show-current-patch' to see the failed patch
> When you have resolved this problem, run "git am --continue".
> If you prefer to skip this patch, run "git am --skip" instead.
> To restore the original branch and stop patching, run "git am --abort".
>
>                                                   - Ted
>
> --
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

This is based off of ToT master. I put in a dummy fscrypt patch so you
wouldn't need to rebase on top of fscrypt, but I could just do future
patch sets all on top of fscrypt-dev. I guess my attempt to make it
easier just made it more confusing :(
