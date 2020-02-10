Return-Path: <SRS0=YAsz=36=vger.kernel.org=linux-fscrypt-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3295C352A4
	for <linux-fscrypt@archiver.kernel.org>; Mon, 10 Feb 2020 23:11:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9C6DB2082F
	for <linux-fscrypt@archiver.kernel.org>; Mon, 10 Feb 2020 23:11:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="esB/56n6"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727455AbgBJXL2 (ORCPT
        <rfc822;linux-fscrypt@archiver.kernel.org>);
        Mon, 10 Feb 2020 18:11:28 -0500
Received: from mail-lf1-f67.google.com ([209.85.167.67]:41468 "EHLO
        mail-lf1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727422AbgBJXL2 (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Mon, 10 Feb 2020 18:11:28 -0500
Received: by mail-lf1-f67.google.com with SMTP id m30so5568634lfp.8
        for <linux-fscrypt@vger.kernel.org>; Mon, 10 Feb 2020 15:11:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jHnULLRvzcnTmrApgk0J6kXZO0qLfuB4AVQHnM4cmAE=;
        b=esB/56n6Q/Msdc20g+jexMovttxt6hCUBxvlvmdqGEumLlcmF5aj3v38oGR21nFNxo
         cOk4ekYVR6FdU2NjqUfNrI3LKVvMII6sqM7sSRTkqviALl/XYnv7z0n+5b5yYI3Lni/Z
         pHlhrG3K7Bp+8RWOpjWHLKMsY1f7PTIEy4J/RPb301AvTHMZeUbf9QaVy+/1sChmohPn
         5sq+e6/X6b3sYiGh+ziR8racoEm4OmMe/es+FRFQCba4zTFopBh8xK7owBMwffjbGKty
         kt8xNXlsArGuuruRAvzftXBAFrERmdhUUoEdMwiUrXKqtFq9YOe+1lKW7UiPQs4r9v/n
         YlSQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=jHnULLRvzcnTmrApgk0J6kXZO0qLfuB4AVQHnM4cmAE=;
        b=HDuHRAN5Yft9smBYvac9dEZXCnUYiordqjYulydoV7CuVHQcC93c+oStKyNf9w0bV7
         ROx8ArSOqFnZR80MuMnoH7HW+JZ6hCm8IfqnNVqLeTpaa5p+rjB5BX9K14NqbMZXpDps
         chDYQPrxOCakMKPkwLauVc6uuU5VIjAEI1j7aDKOQZo7+9jyM+J2hiUDg7C9xrzSt3A7
         jbfIim9gh++s9QxR+hc/hQxOaVxbMeyknwHR5XTobNlwjJ00TZ1UWI1S+gAPJxxAsLBi
         aiIQ22I0NHWqfOx1It/igeAFq+dBi31co4cKvoybCR0XiZy8DFFfJqnDGq5SzmG5tQEN
         F8dg==
X-Gm-Message-State: APjAAAWbs09GrfKqxy6Kswz8cPQfs4Czsd4nRrdsbYSdM8TxzSHYhmcC
        1ekb2nYksH+vmgB5R9/kwGniWf45P/E9GvAVGnzQpg==
X-Google-Smtp-Source: APXvYqxiERXVniVJSVLKbVx/xqUKUzq4lPf5gqhBdctRYV5+IUwsgO7mOTwXnfu4yRdcGlrvRlDwJrZV+Drqhe6D0W8=
X-Received: by 2002:a05:6512:2035:: with SMTP id s21mr1781905lfs.99.1581376284825;
 Mon, 10 Feb 2020 15:11:24 -0800 (PST)
MIME-Version: 1.0
References: <20200208013552.241832-1-drosen@google.com> <20200208013552.241832-3-drosen@google.com>
 <20200208021216.GE23230@ZenIV.linux.org.uk>
In-Reply-To: <20200208021216.GE23230@ZenIV.linux.org.uk>
From:   Daniel Rosenberg <drosen@google.com>
Date:   Mon, 10 Feb 2020 15:11:13 -0800
Message-ID: <CA+PiJmTYbEA-hgrKwtp0jZXqsfYrzgogOZ0Pt=gTCtqhBfnqFA@mail.gmail.com>
Subject: Re: [PATCH v7 2/8] fs: Add standard casefolding support
To:     Al Viro <viro@zeniv.linux.org.uk>
Cc:     "Theodore Ts'o" <tytso@mit.edu>, linux-ext4@vger.kernel.org,
        Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <chao@kernel.org>,
        linux-f2fs-devel@lists.sourceforge.net,
        Eric Biggers <ebiggers@kernel.org>,
        linux-fscrypt@vger.kernel.org, Richard Weinberger <richard@nod.at>,
        linux-mtd@lists.infradead.org,
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

On Fri, Feb 7, 2020 at 6:12 PM Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> On Fri, Feb 07, 2020 at 05:35:46PM -0800, Daniel Rosenberg wrote:
>
>
> Again, is that safe in case when the contents of the string str points to
> keeps changing under you?

I'm not sure what you mean. I thought it was safe to use the str and
len passed into d_compare. Even if it gets changed under RCU
conditions I thought there was some code to ensure that the name/len
pair passed in is consistent, and any other inconsistencies would get
caught by d_seq later. Are there unsafe code paths that can follow?
