Received: from mail-wm2-f13.google.com (mail-wm2-f13.google.com [74.125.225.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7BB4454CF54
	for <linux-fscrypt@vger.kernel.org>; Tue, 22 Sep 2026 14:05:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.225.141
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790085937; cv=pass; b=lEOwu8Tkbq/Ycazn16K2mmhcclHoPGtwHEK8ndiaDRpvr0B7ySIPzJJV7VQT2G/M3QsunVsYo7i4WrVvoxwhyMC7g2MxzQED3U+hlkrNDbz6U0pFhdTo/RD1+li2LKaAQVAXNocgRAFBP33XWQwqfyC4HxqT84lBgvo9B6ssYTU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790085937; c=relaxed/simple;
	bh=Ay5NjTz63OiCiHZ7ALzt+lcJMCr4C+fqEYLzWAvlTPI=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=Ow+oLdvHHsHuvkYP+H9L0EgBkPiMYEghgSGZ/xBBfTdxislrjtzDWq+uy77Qr4xq5EUMmqTowkZdZFu7JsfIjUP4sgSRq/StrEcKkNnLKKUGLbe3u5AuXBV64DmosfKOVEqXQ42j+HxioG5fV5KKYc63a6sDXlUMyLwmHPgC3dg=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=It34vOS8; arc=pass smtp.client-ip=74.125.225.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="It34vOS8"
Received: by mail-wm2-f13.google.com with SMTP id 5b1f17b1804b1-49e6b885ef8so23536675e9.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 22 Sep 2026 07:05:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790085934; cv=none;
        d=google.com; s=arc-20260327;
        b=YT0Ro7xBVfFSAaciQFbnMoZQQSRim/gEBxiMQhtw8mw9dwZdNdm0PPIP1W7OrLVhm0
         qGi23V2rAUbtJRmRUc+z5n49vjzhLVmj3a6cA7FyD7qi0ztrAy4z/Oucs4TC8fN10pmo
         ZJXEKIxhrG04ts7dXo4Vj+h3hI+pc4PhMa0hGEs0I3P6kV+RxeolQrXRddvChf3Pkxzf
         KqsP2Zi2/rO/BWlHBkVO66zFIcBKRS/fSVxwF+WL8uKP6unSZwN8sGRxv/YjoAyRS8by
         Df1cJsF284gU550BhnsqwJvv7IsX0QHRVvdcUXh/iKKWJqkbYpagrSKuNE16ygEuuQDF
         54gw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6YS2AxBcCq9ZhMi42e6qWSeGTCX4XCRef+vl2kw8gyg=;
        fh=S9+gdCi3mp7Y3PJ/OsozddRlkH45SKHKGdNFi2Ea44Q=;
        b=acQbDqnNOKs77KyTaBZLLIcnH5Wn0AYUZZTOSBTYLCObi/x46ZHbwg9wFUzDliFtPX
         VXL6X6Ot/keNfJPcrFI3Lpr35zT+2gEKXPTSB9QH3Kqcl9mV1unq5qwleEbWaOMdyajP
         YnJJbidhbbgmgJwkWSXsZefV0fFrk4ZI6SwZzXanFDn5BB5QUTn4hF4zqud9fvOtGFw+
         Y/hNBXfafEzzFsC9WjVCNvwvmml6He63iKshh2cQlYA+fPaV+ul0krSfdpbLjVmWhWpT
         fzApbffe93QvuvJiopilLI2QKHQEt+pCCR7PauCgX+YOcwHL6f/EVN7QE7+skWJcgMWu
         yFjA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1790085934; x=1790690734; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=6YS2AxBcCq9ZhMi42e6qWSeGTCX4XCRef+vl2kw8gyg=;
        b=It34vOS8sUSb96CZ88ohJ7YHGY3ycuWEwg8dqvOZUvCFuYqztFt5TZ1DCFgwxQHyGh
         CEc/A06jCixtwMIhOu2JmVnw77yYJBi57m4ovFQHMvxZLomGf0+6/9G3uDF+fmk4CAmL
         3jGIYPDTXXXu+RmKo/edM+Bd/OAxjjgvH5VWPQQf/++/hpBu3W+KgP5DS7gNlPnsDgvJ
         CjAmNYrYTnlE0qDpqbpzji6TzpPacEbI0ugFuwDuPfPRpCuscoQnr4Nb+BODmAzapyPd
         Fwqv7QBanNNIiCmjxvSssudzUGg7vC7fTuVQBcocAQtdODsoDxxrHS/mSCmzzGZS1DZY
         z9+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790085934; x=1790690734;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=6YS2AxBcCq9ZhMi42e6qWSeGTCX4XCRef+vl2kw8gyg=;
        b=cMQhMBz8A29p3eoJCG+tMzGkJ5I1Pt0c3IpkfDXoCjOP/9aZt0/ozn2JdC0VUxeoN/
         PoUH/NBiP2F2ZC5/71FEFlNYUxhANxkHOtlIvD1U50qPQFVy9I99Ygbw0/SapFnZD4Xr
         v6NuFJumfArNT1sWxCaBdEM9/flWV0oHTKUwwhu4bv5Hnoeo/u/SINqD1+PY6eTq0ThP
         EyOKKbkmrvLegZRcuuKfSY2eRzdZxLct0AHP6iYV3Nh4taKe3AybsO6b3z0wMyzoWFid
         qCijHOE2ZrNFwRs7DsECONVSFMPA5Vp5xcVRCpWGkq4LpBfo0rGQYIaUDJOVG9Up3KSs
         Ps9w==
X-Forwarded-Encrypted: i=1; AKwUvBxoMKq3yRWFpM3RxmH7Zh+6e2kcMkiUlQ6stAj+S1N5ZpCf5vrteuWuiRulhA/PxaMnwSuniboeOe4pEnYP@vger.kernel.org
X-Gm-Message-State: AFuF++m1J9/RAnhVgZqIGi9zb5nHmT74pc9vPbvI8GzAqzk+3yE/UhSK
	C5hALbdWI+y9tR2Zvtuwo5KlJUZWZwPxmBtUNH9KWV9GleL9TyFNB3bofmpWz+qHejxL0uuDc1P
	0QzhGRUmEtvT1mPOA4YxjSteY8mqZqJ5VLevOYCVwCQ==
X-Gm-Gg: AYBFou0sGnnfa+8h8MZ3hyCyrele67ufCB+XvMI9a49jfzaxSwjqfj2TcLpjTQAai3n
	enBygP3ba3KotXweRDIissPDhmWgOo69XfllFnPfdg1VOkYibTD8LjUCzI2cphECDUN8K9xvZsv
	BmuMx7P15qQiC9gR0NV7PmMLYN1JNSk7LBM9Fe+Wlq8apDvlLJ+23u1b4UsEBjkBwx3PI4QCCF6
	ctN2W+C5CG8+NklTFn3EX/2Z/PCIpeM/hP6uQQ4DlT0QI4wkZ8E32+e23uTZV0Nj9hcRupm+jzk
	fbhAqvs0IsadCIiJACnYWs8B+/jl9/PtKz7C7O6fg7zHdIAQrycH7WOCr8rNwTyKT+f8JEVl0rw
	mgQIIofRawPOe8QumWkbYkOgKW3nCju/kJmByotXtmKFsm1+oXucK
X-Received: by 2002:a05:600c:83cd:b0:49c:c0d4:53d9 with SMTP id
 5b1f17b1804b1-49fc56f7a11mr167442875e9.14.1790085933488; Tue, 22 Sep 2026
 07:05:33 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-13-neelx@suse.com>
 <20260602032710.GI2295@sol>
In-Reply-To: <20260602032710.GI2295@sol>
From: Daniel Vacek <neelx@suse.com>
Date: Tue, 22 Sep 2026 16:05:22 +0200
X-Gm-Features: AclHuK9W2Pxjl3KwkDzeI2ubrLmu06MdbRUN3yT63V6ZnZJwdsBl8QwyQ-GSdxM
Message-ID: <CAPjX3Ffd8uiaOaOkwyATq_NtCf-Jx5+Q3Q+y-PH+3XhC+GBvgQ@mail.gmail.com>
Subject: Re: [PATCH v7 12/43] btrfs: add new FEATURE_INCOMPAT_ENCRYPT flag
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, 
	"Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, 
	David Sterba <dsterba@suse.com>, linux-block@vger.kernel.org, 
	linux-fscrypt@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Omar Sandoval <osandov@osandov.com>, 
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 05:28, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:46AM +0200, Daniel Vacek wrote:
> > From: Omar Sandoval <osandov@osandov.com>
> >
> > As encrypted files will be incompatible with older filesystem versions,
> > new filesystems should be created with an incompat flag for fscrypt,
> > which will gate access to the encryption ioctls.
> >
> > Signed-off-by: Omar Sandoval <osandov@osandov.com>
> > Signed-off-by: Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> > Signed-off-by: Daniel Vacek <neelx@suse.com>
> > ---
> >
> > v5: https://lore.kernel.org/linux-btrfs/ccbea52046c1dadbbef926bfc878cc23af952729.1706116485.git.josef@toxicpanda.com/
> >  * No changes since.
> > ---
> >  fs/btrfs/fs.h              | 3 ++-
> >  fs/btrfs/super.c           | 5 +++++
> >  fs/btrfs/sysfs.c           | 6 ++++++
> >  include/uapi/linux/btrfs.h | 1 +
> >  4 files changed, 14 insertions(+), 1 deletion(-)
> >
> > diff --git a/fs/btrfs/fs.h b/fs/btrfs/fs.h
> > index a4758d94b32e..dbdb73722c14 100644
> > --- a/fs/btrfs/fs.h
> > +++ b/fs/btrfs/fs.h
> > @@ -322,7 +322,8 @@ enum {
> >       (BTRFS_FEATURE_INCOMPAT_SUPP_STABLE |   \
> >        BTRFS_FEATURE_INCOMPAT_RAID_STRIPE_TREE | \
> >        BTRFS_FEATURE_INCOMPAT_EXTENT_TREE_V2 | \
> > -      BTRFS_FEATURE_INCOMPAT_REMAP_TREE)
> > +      BTRFS_FEATURE_INCOMPAT_REMAP_TREE |    \
> > +      BTRFS_FEATURE_INCOMPAT_ENCRYPT)
> >
> >  #else
> >
> > diff --git a/fs/btrfs/super.c b/fs/btrfs/super.c
> > index efaa0788c1fc..84df97363611 100644
> > --- a/fs/btrfs/super.c
> > +++ b/fs/btrfs/super.c
> > @@ -2563,6 +2563,11 @@ static int __init btrfs_print_mod_info(void)
> >                       ", fsverity=yes"
> >  #else
> >                       ", fsverity=no"
> > +#endif
> > +#ifdef CONFIG_FS_ENCRYPTION
> > +                     ", fscrypt=yes"
> > +#else
> > +                     ", fscrypt=no"
> >  #endif
> >                       ;
> >
> > diff --git a/fs/btrfs/sysfs.c b/fs/btrfs/sysfs.c
> > index 0d14570c8bc2..3fe57843f902 100644
> > --- a/fs/btrfs/sysfs.c
> > +++ b/fs/btrfs/sysfs.c
> > @@ -305,6 +305,9 @@ BTRFS_FEAT_ATTR_INCOMPAT(remap_tree, REMAP_TREE);
> >  #ifdef CONFIG_FS_VERITY
> >  BTRFS_FEAT_ATTR_COMPAT_RO(verity, VERITY);
> >  #endif
> > +#ifdef CONFIG_FS_ENCRYPTION
> > +BTRFS_FEAT_ATTR_INCOMPAT(encryption, ENCRYPT);
> > +#endif /* CONFIG_FS_ENCRYPTION */
> >
> >  /*
> >   * Features which depend on feature bits and may differ between each fs.
> > @@ -338,6 +341,9 @@ static struct attribute *btrfs_supported_feature_attrs[] = {
> >  #ifdef CONFIG_FS_VERITY
> >       BTRFS_FEAT_ATTR_PTR(verity),
> >  #endif
> > +#ifdef CONFIG_FS_ENCRYPTION
> > +     BTRFS_FEAT_ATTR_PTR(encryption),
> > +#endif /* CONFIG_FS_ENCRYPTION */
> >       NULL
> >  };
> >
> > diff --git a/include/uapi/linux/btrfs.h b/include/uapi/linux/btrfs.h
> > index 9165154a274d..2f6a46e5f4ce 100644
> > --- a/include/uapi/linux/btrfs.h
> > +++ b/include/uapi/linux/btrfs.h
> > @@ -335,6 +335,7 @@ struct btrfs_ioctl_fs_info_args {
> >  #define BTRFS_FEATURE_INCOMPAT_ZONED         (1ULL << 12)
> >  #define BTRFS_FEATURE_INCOMPAT_EXTENT_TREE_V2        (1ULL << 13)
> >  #define BTRFS_FEATURE_INCOMPAT_RAID_STRIPE_TREE      (1ULL << 14)
> > +#define BTRFS_FEATURE_INCOMPAT_ENCRYPT               (1ULL << 15)
> >  #define BTRFS_FEATURE_INCOMPAT_SIMPLE_QUOTA  (1ULL << 16)
> >  #define BTRFS_FEATURE_INCOMPAT_REMAP_TREE    (1ULL << 17)
>
> There seems to be an inconsistency where btrfs's fscrypt support depends
> on CONFIG_BTRFS_EXPERIMENTAL, but the support is advertised in sysfs
> regardless.

That is true. These should also depend on BTRFS_EXPERIMENTAL. Will
amend. Thank you.

--nX

> - Eric
