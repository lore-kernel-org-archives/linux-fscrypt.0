Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E1601459AE9
	for <linux-fscrypt@vger.kernel.org>; Wed, 12 Aug 2026 14:01:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.43
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786543291; cv=pass; b=ZYDduHTlJHHEfZTePmuddvC9YV1Gh7cDT1txDxgcZM9P7PhuUlRTPC9YmD+gE0PoqeKULJcmBIc+x3a2789MNlVA63h9qGzwRne7cGeVr/J/LtvurHkCjmzl94Iiqub4rirv86iYV45u5uAiCfTzYAUB1TYBu9nstIzvlKjPAoY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786543291; c=relaxed/simple;
	bh=NwhV7wARecxQh7esHydA5zPzLYoC9TtdLCxqqsKZyKg=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=OL3aGV+V8vYfODjsxROIKMU7HSB42J8ldnspqSvNn3INxIgarK5+EQeV2DXeWPUQUdRm4u8h6acMzEuTPOAgnRfJsRBy1aoOwNK80rF7g3b/bVH+gDCL7RjJkfNqTu2O/9di56MOEeLs9EE2GRnXYuqiaqYblqa1G7Eh5ACS3Oc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=bMzpZF95; arc=pass smtp.client-ip=209.85.128.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="bMzpZF95"
Received: by mail-wm1-f43.google.com with SMTP id 5b1f17b1804b1-4954a9e8490so13887145e9.1
        for <linux-fscrypt@vger.kernel.org>; Wed, 12 Aug 2026 07:01:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786543285; cv=none;
        d=google.com; s=arc-20260327;
        b=ST57A/HWTaA1aHJLZmLpQSVJ1WRH/JGAlcdzgoalNk2grU9JzK5ggX1hNM5xuRFIvk
         FwlN/S4hLizPscFhylOqfMAl6Cb+WfZeS1Ash4BSIIB5bItbVw7cmBL/i/TPjDzcuQbh
         8v+Qf4x4BFMozo3NvkcsxfvgtJ+rDHi/ZqoLKvsdkear3eoSaCEWP1xQxRDomNyzkT5f
         ckPwLZwvGxpfvS/XaRVi6zBtcsCF0ev6W0HuKEufcpAj003AjY8tEYPcmEKzZkUNCIhS
         ESPZrteer0xhbCqpwflEgDMXSIAOK844h2XmHgXtsEtzlMxkS67CF4aqXYE/tumtlxtg
         0ukg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jDqguviqlm3mcw1WL6mm0X2Ptol7dkWT6XZ2U3iPzp8=;
        fh=gVizM6NQjSLKpoYfas6Je7/AxNYMMGtmHVcSYzWLueo=;
        b=YNAkO9vFvzOGaVaktq4EJ93khdcyBo1LksfZsHHD1R+yoOdDpBLmBmR0sInQOIcaij
         +O3QUuKA1epreKQr0aZre3jkXd7KssFv2eZOgT065A31t99fUlBZA/DbMUxX/dJXeGba
         XTgB2APbVXiM/yh42NWul+7zE49z+PY7UM3nDQSvhU/h5K9MhdokXphFvxI9XG42IM0F
         1IF+yKXaaRNj3SQlE3oOSJH/lHLWaURHoC2pL5Mifo6TcnwR79dmFrztvICIzIGCet3K
         FQcP9L5VjramKt1Ce5LkWAHdYz5hNVL4Et5TyDm0HgOJqArrWlYqcfpZfZtBgb7uP/YY
         KvGw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1786543285; x=1787148085; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=jDqguviqlm3mcw1WL6mm0X2Ptol7dkWT6XZ2U3iPzp8=;
        b=bMzpZF95Zyx59JzfpcJo+ylEYm+3oxDx4U37dg5o3XJSkZyQ21hWHC5FXbiFKJCtwz
         nfL8s0PNyewVe5v64SBtAquLGvNNGElEyDtfv1m7v/EUT0QcQaNwuW9wyRpIIR/y1/I2
         qyuHfiXFEhkuVCzOfGa1P/JJm1Ww3OlOIFQUOqURWgtRFK8kysRFJzxjb7OvMNzhfMpb
         W8+AmyBf7xHon4mrE1Z3nJl7h0UZkwJNtUv59bhlanZJs285lei7wEGlgIgFrIFE7aDd
         1XE8+MzdFW1P0WnvvjHC5W9GJsp1YOEF6XalZDyutJgLrMAtkyEA347rD9gx0K5SzFQC
         UBmQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786543285; x=1787148085;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=jDqguviqlm3mcw1WL6mm0X2Ptol7dkWT6XZ2U3iPzp8=;
        b=O8IHcG/R2MQlggZwXIixbI6zfMKgQycJ/+qJ26X4kge7ooCFPrGkRxhEbs7rB6nzlt
         pVYuf+P9TULHdd0KQWdXdDnEi6r6mOdePisuBH+z9OQq/FZyQPvpp49xiRQIorj93FvD
         BGHCCeUPyPal7OaXWCEcrvKQ3S4+riGHqRasTP9Jv1qTDPsQ1sPwhju+lyBOVBFNU3zx
         /sORxymVQAlkPY2+Lvont7Ufu3smrRJ1VjLf6bz/01BWVSsPE/gxHxHl2Q6KvCMCWqbG
         hs2wOqNiW3oF8HK+jB2UD6NE6A8rb0XwEYxbrAExwCs1/CjwVivcO3yQ4fuSY0/McKb3
         HGhw==
X-Forwarded-Encrypted: i=1; AHgh+RqCTs9aMWsfyK3jknkJD5oHkXOlTdQjpVPW/lze5uQw/YbC4lirzquKqmJVxI87bQdtA7MgZjGKn7ped3ab@vger.kernel.org
X-Gm-Message-State: AOJu0YxE/jYnSqarRdmHLY6ov9GhJLlJ4XNpDch+uzQJmpLIowiWfXqh
	o0/YFFHvMMT+KaE1S8lsGHr7H0Uzo3rh8kpVSIyITO1pQOSGX8ugb35N8nfflraiCT3hwqwwBDg
	X1nHV7vVRJHh35FFGRXRUrJ5ebgINaQuteFInvYpD8g==
X-Gm-Gg: AR+sD13ae+njYPT+hvlAjXP/2Pvh6AA/62ny3iI+Rx6Qg1L+Zw4r/O3JWL1c7m8Z/lU
	UU25dTpm0xu9/tkhcCqEA/WqHKooSN2GLb+bybCD9jAJVHRIx91VdgoIiO4hh9EsMwDq1RFz/HD
	mZ8RpnJuz7cxh/04KnKtxhd63Tu6uejpRVi77Uenh7Dl2U+sknUlhV02ilBRPHPcGIZr8/Kf3qr
	Q+vz+xiq0aWH9Bgx+xzVgn+9MS4sU9e18bjP4Tks29JIw6nH36fe8m/b/aHjH7leqpp4QqJRgWY
	b85a3ja8chhxgq6HIFGH5CA3KbcubUsu6/5q1c0hvho1mjYSkv8buAgHMP7bfk5r5xCZA3XgpR1
	p6M1bayOjiBayJtF/wxgF5xwRP1xEf62nbSeyjDcTSQ==
X-Received: by 2002:a05:600c:3545:b0:499:71d6:359a with SMTP id
 5b1f17b1804b1-4997a656f46mr109313045e9.8.1786543284052; Wed, 12 Aug 2026
 07:01:24 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-4-neelx@suse.com>
 <20260602023330.GB2295@sol>
In-Reply-To: <20260602023330.GB2295@sol>
From: Daniel Vacek <neelx@suse.com>
Date: Wed, 12 Aug 2026 16:01:12 +0200
X-Gm-Features: AUfX_myvt915vzGFwNYRlfFfUivl5kbirxl8PA9N2EQBXfOqTu-HUsUGoJNjjyY
Message-ID: <CAPjX3FdO6sn4Yi0x30cJSASqJXJYnit-RVOOAaz56VhBQPKmXA@mail.gmail.com>
Subject: Re: [PATCH v7 03/43] fscrypt: add a __fscrypt_file_open helper
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, David Sterba <dsterba@suse.com>, 
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 04:34, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:37AM +0200, Daniel Vacek wrote:
> > From: Josef Bacik <josef@toxicpanda.com>
> >
> > We have fscrypt_file_open() which is meant to be called on files being
> > opened so that their key is loaded when we start reading data from them.
> >
> > However for btrfs send we are opening the inode directly without a filp,
> > so we need a different helper to make sure we can load the fscrypt
> > context for the inode before reading its contents.
> >
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> > Signed-off-by: Daniel Vacek <neelx@suse.com>
> > ---
> >
> > No changes in v7.
> > v6 changes:
> >  * Adapted to fscrypt changes since the last two years.
> > v5: https://lore.kernel.org/linux-btrfs/4a372419c3fe6ad425e1b124c342a054e9d6db23.1706116485.git.josef@toxicpanda.com/
> > ---
> >  fs/crypto/hooks.c       | 38 ++++++++++++++++++++++++++++++++------
> >  include/linux/fscrypt.h |  8 ++++++++
> >  2 files changed, 40 insertions(+), 6 deletions(-)
> >
> > diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
> > index a7a8a3f581a0..3142cf106bde 100644
> > --- a/fs/crypto/hooks.c
> > +++ b/fs/crypto/hooks.c
> > @@ -9,6 +9,37 @@
> >
> >  #include "fscrypt_private.h"
> >
> > +/**
> > + * __fscrypt_file_open() - prepare for filesystem-internal access to a
> > + *                      possibly-encrypted regular file
> > + * @dir: the inode for the directory via which the file is being accessed
> > + * @inode: the inode being "opened"
> > + *
> > + * This is like fscrypt_file_open(), but instead of taking the 'struct file'
> > + * being opened it takes the parent directory explicitly.  This is intended for
> > + * use cases such as "send/receive" which involve the filesystem accessing file
> > + * contents without setting up a 'struct file'.
> > + *
> > + * Return: 0 on success, -ENOKEY if the key is missing, or another -errno code
> > + */
> > +int __fscrypt_file_open(struct inode *dir, struct inode *inode)
> > +{
> > +     int err;
> > +
> > +     err = fscrypt_require_key(inode);
> > +     if (err)
> > +             return err;
> > +
> > +     if (!fscrypt_has_permitted_context(dir, inode)) {
> > +             fscrypt_warn(inode,
> > +                          "Inconsistent encryption context (parent directory: %llu)",
> > +                          dir->i_ino);
> > +             return -EPERM;
> > +     }
> > +     return 0;
> > +}
> > +EXPORT_SYMBOL_GPL(__fscrypt_file_open);
> > +
> >  /**
> >   * fscrypt_file_open() - prepare to open a possibly-encrypted regular file
> >   * @inode: the inode being opened
> > @@ -60,12 +91,7 @@ int fscrypt_file_open(struct inode *inode, struct file *filp)
> >       rcu_read_unlock();
> >
> >       dentry_parent = dget_parent(dentry);
> > -     if (!fscrypt_has_permitted_context(d_inode(dentry_parent), inode)) {
> > -             fscrypt_warn(inode,
> > -                          "Inconsistent encryption context (parent directory: %llu)",
> > -                          d_inode(dentry_parent)->i_ino);
> > -             err = -EPERM;
> > -     }
> > +     err = __fscrypt_file_open(d_inode(dentry_parent), inode);
> >       dput(dentry_parent);
> >       return err;
> >  }
>
> This change makes fscrypt_file_open() execute an unnecessary extra
> fscrypt_require_key().  Could we just leave fscrypt_file_open() as-is?

Yes, I'm aware of that. Well, it's static inline and gated only for
encrypted inodes. But yeah, I'll refactor it a bit further.

--nX

> - Eric
