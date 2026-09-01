Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3367347FAFB
	for <linux-fscrypt@vger.kernel.org>; Tue,  1 Sep 2026 12:18:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.221.53
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788265134; cv=pass; b=jdTkyNNmKWQPCdIkKGUfNQ4hQjJweo237euCcWo4cxWK/ZKjm1hY6np6enJ/5NXmHlLaFlxpIn8cxkBoFL1lVwdST6Ifb4/gsm2pwWwybvALhcnyn3eypIUSbmhQs2lxbjsRUKIGUzCnfg8YjClONJLtwCdu0kRKrWDa/0R76oM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788265134; c=relaxed/simple;
	bh=Es/cIjPUD1zzwXufbvKj4+Elkno+b+6GyubYx/khWOg=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=JVNQBq1apxNBg4PjPwaTBB8Qc90v40FuiZV+55w157oNOWLdcs8nQ5d2R5u5MZwGVZ9H27PEj3wU5sWu3rv0KS2Us88TnhHmEmu2um/FQX+yzho6fVchLSoNJA1MJjEiwLdm4jFxZ1fozsn5b2pj8SsHC8HmKYqpIEiBljexDxQ=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=cu+sxr8M; arc=pass smtp.client-ip=209.85.221.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="cu+sxr8M"
Received: by mail-wr1-f53.google.com with SMTP id ffacd0b85a97d-48444ec4fe2so314123f8f.0
        for <linux-fscrypt@vger.kernel.org>; Tue, 01 Sep 2026 05:18:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1788265130; cv=none;
        d=google.com; s=arc-20260327;
        b=RkxiUcsTWz7x6Kp/rFOA5ec6VGE/ADtvazn1X8j6W9jcSbjpuGa8hu4hlx8DdC/S0z
         xlWJMWCAXiqMGRft/9F8WwhPclhkU/u1vlu1vTXo4MgjVqT2cm7O9xD/mIj51i9qhgns
         SqhmWXjHPWOr4nHFiFM0nyIZEKn0P//bTfR+0ia2JCQUBdQG5kEJ/4X0EdmzsseDZutU
         RehyWO9PG2jaDj3RYbetUW4wlAJgasSKy9paz717ngnPnD3jHlbJOa5+tbZW8ENDv3vH
         FHRrNLK7r0/EZGbLbteG+NejX9BGBGRkDDn42FP6P1ffsrq7sVCWGz6Fh2iEd90xxZsm
         z14g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UvAi+mvqn+hfoITwGygPm/YRj+YQGu0S7A55rivu94M=;
        fh=4CGwBxzJnPV8+MlwaCChu87q+VEVPEwxs05iKpfwd18=;
        b=mejRH4lkUlETTXa7nRKsz2rwLfS+2EfF70C60madKBfRiZQs9O32eFFs+QsOJvcHjn
         mObZxU+DUOrpbk3GbuO6HCfkKvxEAKWRUOy9oS3J6DlfdZ6U50+MdglTgWX7dpWtA+Ou
         N77QOFOYcOyxwVslfQl+n2zB53Y6ZgzkmsryQq8aMCX0ZxBwra131qrfZgK2WAzJtGnl
         6mUKwYwhqRA5rAedHkm14uCskEWCFd7R4VSIuvS0ahv2KXuAyFOLsWxGkSRaTMrSo1Ag
         ykQ0/2F2yPp9CV9WIt0wMLWhN7kM8MAI9ClcpzNKI1R1IUyeMUhe4jH2ddWixAO+CQ2s
         KRPA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1788265130; x=1788869930; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=UvAi+mvqn+hfoITwGygPm/YRj+YQGu0S7A55rivu94M=;
        b=cu+sxr8MK5sNC/uVsEzuQ15QB5fgL926vBMF3dm9MLyD0FjEmRuoRHqdEw9BqHWhye
         TBa1ExtRh8OOER2i74w5OILPqw3+MU4Kneja2YTshuGPesAeBzKlKZEA+4NbY/5uo52s
         RDr+jyzZQQCG6tHuikKqwWYYiwbpYYhMR6EbPHdhaZQl39yJH+6Ucx/k92aI0waI5QSl
         O6fMckPyqyodn5Dc8lzaFZj2I8G38EoFHu45F90amE/RCLIGCffXnCpC2dryp2Qwhlb4
         V10VFurB6/JJp3Fd+6q9Mu32cH5NG19cGUnMpuMfignb3pTXtybWNn1dMXKfukPyXipz
         0y6A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788265130; x=1788869930;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=UvAi+mvqn+hfoITwGygPm/YRj+YQGu0S7A55rivu94M=;
        b=ku7wzCQnsJEYn75OkeSFt+Lvx6KJcNdoF1NatpQG+TAVGy+JUzHeJDSuNh4mBxe4c3
         bysUila426xZ6g6eG6mOtBW221/prD3AWUzp4igl6AE3SetFhv2ZfyFk/l/fnjTPZ11Y
         QnQBUcZaGpdldUQI2HYAnfeyGQKidsy9fiUKI0itdlP4RZ98+LwZaDAyvgI4DGQ03W2l
         N1xKKCCC7iGXzN8MVti9EFGhAAa9HJBRUFwlVqwx7CR1m/vpFkkGe7avtAVdWckkNLzq
         R/ubiIPjUykzCekubuY/XdiVPVRPzNPsN4h6MoS0UFAwTZdIFaMq3HE+bJZPT4rukfz7
         FyYw==
X-Forwarded-Encrypted: i=1; AHgh+Ro5pf6mGKUXTs47VsisHQyssBDXgdRgg1XxOHTx2k8VrWcDSOcI+8h8rCLpeFAZHMqAilIstvgfXbmnn5TQ@vger.kernel.org
X-Gm-Message-State: AFuF++kXCsFgww6Iv0JujKy09M5gT3rgNK89S0eGGn36yglFyIT4ecoJ
	9ZGy0MJj0gLj3eJypLSG91nQPEn1Pcxnt+ZZz0JlMrmehapqKAMLc0WTsS55jbiDazIwtZKkG2/
	asqP8bHdPTiGSda/9iVNo0tCQzCxaSyPIONvM9JWrYg==
X-Gm-Gg: AR+sD13DuRP6bkSZ5uwpqoegHb1YwmN56kKcFTD9Ag9xEDLlx4MYs30ToJ+NsuuPvAe
	/7j2a47QUoP4Ys9HhM6xfSVzJ9MXnmu0CytWQob+aEqklYC1Ip1imUAFlMbldIWK8So36vSNSBf
	9rhZmiPXNDWb+OnbMH3sudvglhozPd7HI44KoCo3bqgjbUSHr1YeL4iR0SzkGckUQTfDDXUKYDi
	Y4KrvtH29cq6e0LTegHcVMYFMKrCKHZLLD8lzf+nxQUWygOXju8VDUChFQ1x4U4UtsfTIvYykHj
	fx8ABc38MUA18TxONcW5lI+ebCQh9liHjIDU4vab6LNcDjCuaKw2zMQBPxiYU8OLIhiNkFzClJW
	LW2rSX9kq3/P5vsKe8JYrmshO+Q8M2+ykzLOKs4HW/A==
X-Received: by 2002:a05:600c:3b13:b0:495:4d5c:903e with SMTP id
 5b1f17b1804b1-49cdc4332d4mr140012115e9.7.1788265130443; Tue, 01 Sep 2026
 05:18:50 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-6-neelx@suse.com>
 <20260601230913.GD25574@quark>
In-Reply-To: <20260601230913.GD25574@quark>
From: Daniel Vacek <neelx@suse.com>
Date: Tue, 1 Sep 2026 14:18:39 +0200
X-Gm-Features: AcwNN1WZzfR7nMvK7wzsu0uw9g-Q6K8Z-mgC6-phqgqu2rO8TCpwPmWb_Vlt_uY
Message-ID: <CAPjX3FebVAj-U3s7nJiwu3D74p_nAGacYPJAX04TVXJBaievGg@mail.gmail.com>
Subject: Re: [PATCH v7 05/43] blk-crypto: add a process bio callback
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, David Sterba <dsterba@suse.com>, 
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 01:09, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:39AM +0200, Daniel Vacek wrote:
> > @@ -330,6 +330,17 @@ static void __blk_crypto_fallback_encrypt_bio(struct bio *src_bio,
> >               }
> >       }
> >
> > +     /* Process the encrypted bio before we submit it. */
> > +     if (bc->bc_key->crypto_cfg.process_bio) {
> > +             blk_status_t status;
> > +
> > +             status = bc->bc_key->crypto_cfg.process_bio(src_bio, enc_bio);
> > +             if (status != BLK_STS_OK) {
> > +                     enc_bio->bi_status = status;
> > +                     goto out_free_enc_bio;
> > +             }
> > +     }
>
> This looks very out of place in this function, because this function
> potentially submits multiple encrypted bios whereas this code assumes
> there's just one.  I think we could at least use a comment here, as well
> as a WARN_ON_ONCE(!bc->bc_key->crypto_cfg.process_bio) in the case where
> an additional bio is being submitted.

While this funcion may submit multiple encrypted bios in general case,
the check below makes sure that in case of crypto_cfg.process_bio
callback splitting is not allowed and only single encrypted bio will
be submitted. The WARN_ON would be impossible to hit. That's why no
handling is implemented with the in-loop submit.

> > +     /*
> > +      * We cannot split bio's that have process_bio, as they require the original bio.
> > +      * The upper layer must make sure to limit the submitted bio's appropriately.
> > +      */
> > +     if (bio_segments(src_bio) > BIO_MAX_VECS && bc->bc_key->crypto_cfg.process_bio) {
>
> Checks should be reversed so that the expensive bio_segments() check
> only gets done if process_bio is non-NULL.
>
> (Sashiko spotted this too, by the way)

Yup, true.

> > + * @process_bio: the call back if the upper layer needs to process the encrypted
> > + *            bio
>
> or NULL if no such callback is needed.

I'll add this.

> > + * @proces_bio: optional callback to process encrypted bios.
>
> Typo.

Already fixed. Sashiko also noticed.

> By the way, after writing kerneldoc you should run the kerneldoc
> checker, as it will find things like this:
>
> $ scripts/kernel-doc -v -none include/linux/blk-crypto.h
> Info: include/linux/blk-crypto.h:79 Scanning doc for struct blk_crypto_config
> Warning: include/linux/blk-crypto.h:95 struct member 'process_bio' not described in 'blk_crypto_config'

Hey, this is a good hint. Thanks, I'll keep that in mind.

--nX
