Received: from mail-wr2-f12.google.com (mail-wr2-f12.google.com [74.125.225.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 303AA5452BC
	for <linux-fscrypt@vger.kernel.org>; Tue, 22 Sep 2026 14:06:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.225.76
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790085967; cv=pass; b=dB3vxujjNgsQHkCep72D6vUhjxptF3yBxAAhOphNAnnbEx3tAuB3L+E25pot+PUB+tfJ2p45fq0WE0Uq1W/WrNARpVeQwR4FX4I36vHua97wKnbz7qQrfH+Aewhxvl5K17SGmZlj3Y5bq8kYMxJ7MKLy7kDhs+OOWdPfyYZTHy8=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790085967; c=relaxed/simple;
	bh=FFDGTIkdjwlrSIKakQdYABzBT/A8PNvRaqDPQjmAe6k=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=ZZpZ8Nx0RePjk+dgMdoVaticd/0Ni0gbd4Dd8Y7Ks5gqYeMaogyGPItDxAKn4BrJ9cDYIBX0aqYymkjT/eBPNP67YGw6aRIhumZpxfCV2IzZm3wkdXsuNHaBSWIjmTy5Zc6oY0rM56U6vd6KNoW1l5qYpsf8WvPhU2xbh4FXbWA=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=Y2mCWJGM; arc=pass smtp.client-ip=74.125.225.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="Y2mCWJGM"
Received: by mail-wr2-f12.google.com with SMTP id ffacd0b85a97d-4843796e373so2439760f8f.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 22 Sep 2026 07:06:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790085963; cv=none;
        d=google.com; s=arc-20260327;
        b=SlEVkqJz2NrkCBDCpvhtFTg6OjVvaQp47T7a0kFDJKRRwPsqq9Yv+1NJB4bp0JTdU7
         y4bNKwL4TFqlTikYd80w/+Ia+gY0g4+IiKdHg8Ek6kK9vSzGAsnNNqNi1fffKeYQWpQh
         5YSuJKNXccg7Iyq8xZK3gnRqUjxpN5hRLptl89qAokfi9VevRSKJybbaUuKLIoaJ2vqg
         YYB/tI/5/xJQ9ShAFrRiHKZA8k7N/ksdJ/+6XL9zJA9YJUptqbv6XfuvJmj3lIgbj01A
         SpFmG1XIDAyWGWuRyNU33BpBDmy1uEKCdrlxoxD3cEU1hmIWE4L/GtyuVnlx++OcJ+e4
         im5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HQ5Sa3kOLjyBVe2SVv4WjG5tA5uHiXwiU9nv/zosuek=;
        fh=0Gs0pATX8nDml+99oCj3bW0YfjZhC2n8dqPjg5Wac3U=;
        b=sd8C4yWULnqsukiy3n1QrxEvDqk9Lm9T0x2E0h7sBSXgWrZ9ujnHcbEGYONVVKbey9
         DYw5o0rwS4ggbxCSeliplRxR+ZHv/yxxP0jaJGlWunPCq2pUQNbs9n8QUlQbgcaMeUYz
         atz5q+gjucUbyMrxuPWnNWeUcTPZp5ZCsNEilKfKG8hUnTBByHn0v7GhFZzBhsa1vgXX
         7RtfYiwnQF1eBN1KmrB/uRxLm9JpB4iGk/uHH7Hly9SrD3ugR+P+jeHiabdu3Yk8t77a
         eZM3ZeWyt1dW4jFzexAW/8q0ZHteyKBm/g2CT8GUdS2k9KhX4a8MGqu73v7q8CCP7w62
         d+nA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1790085963; x=1790690763; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=HQ5Sa3kOLjyBVe2SVv4WjG5tA5uHiXwiU9nv/zosuek=;
        b=Y2mCWJGM63FTGl4+yJW4u+r0juwVDCmvwuHvh08vBoh/KHFZxx1mQrlB4lOpzLGQkd
         +PoPDF3QjeFaDtroPLiULmOeE+PQFuJ4pwcUXjRAZ8Kdws5qRDV+RttmHRfXlh4FGt07
         ICZFwgy6nM+mR5fslmAPAZNVCuIheNoI2G3r3svUf9EUJqSgw6sDDiDY/Q3BE3V5/2ut
         whQPnVzaooSi/VV/jgruiDIvINZFSRvpb6BFoiqPw25LpeFLwd2bAqVzG38z6CNMBfds
         wjpVpgyQufgMueHsbd7zyqTl9DOLfgyBul+EvaSMTPh6Ekl9YjstZjQ46O7hJanLyAD0
         e1gg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790085963; x=1790690763;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=HQ5Sa3kOLjyBVe2SVv4WjG5tA5uHiXwiU9nv/zosuek=;
        b=qI/FP55U+w9dC0jUkHRzJY6csLOzlmClQbwjq7OHAjc99GEqX2u3cBsk2Bxko7IgfS
         xv1xHhJi1H+oYP+duhqVw4J12LMm6Hc6bFMRUqRWNF8EsIPqrlLcqA8eDwhizZr/OOcz
         7x4t0VbXgqiGGOwhkQkpK+1kfGA6+g4t35m+iJ151XPze2UqanUosFi1tzl0hvPHgd+J
         v8DxElNV+fWvySMnDfRIUHIcSmOQ6+RBldFvFy0CD6bdITjzh08anHkv6uhxdsyYyrFr
         iYCXAZSKIEPqdxkYLYkyNFJ6UQfKLI3ALQwcT9M5G8yhRYEAsShMktUWNKjIm+C6qMTm
         Im5A==
X-Forwarded-Encrypted: i=1; AKwUvBxNT8yMDxYWq/wyZk/T54BCxs8QGwXq7KsSdZrTlF+mk9Eg6nxBbpGWgSALG8TGK2BWrRjOYyOJn2kJLDjO@vger.kernel.org
X-Gm-Message-State: AFuF++mFXS1jdSnjXDMIF+roVXjQgSJDEqByw2WM2ut+sKmVockt+wxb
	FDmxhhKHTxgyrI3hMxCJnY+tgO/CiRYi2HKSLZabXUenURRaReRBydd8NiU0W0ENhTHrQHsz5VY
	rq+RsOFalnktNCjOBc404hZcDiAMgU9Vvc4lyMjqdSw==
X-Gm-Gg: AYBFou3DW9Q+lFQgXnXW9eYPdAOA0f/1MI8sKoI/9NFnfWTcN68TuHcose2mCpFhFEx
	F9nI88TMDJW/YkqbH1O52fPcuucrM5QKZn+5mUQueCkK4cUbatSTrpz3YyaOECrT9qjO3gjhtMJ
	nIdoU9vpnHqLYh1hpKFyfy7/X6RprS2ap7zRh/Sp41s9fqOtwPk0aYZDSIm0VtQChx0Nj0Jto1J
	cPbJohKtabwnNDFnS4wu1S7Yq+ezHHiijjwcDfiAS3hTVEnsiClqsfZLMhucBKwTK0QGaCqIINx
	8cDltTJCKwmJA1Qvh+podpAOitiohzA2w6fT8GG7P7RiQ/W2e8gRp2MGEnEoEQmeOwOytJRHgfF
	rtEyUfqUtG/Gdf2cMDF6KQV0y5hfU8/aC+dfLWzeGv33mpvLCQDbUxHdwwynKKuYT
X-Received: by 2002:a05:6000:2081:b0:487:936:7ce0 with SMTP id
 ffacd0b85a97d-4871e268810mr20353521f8f.28.1790085963456; Tue, 22 Sep 2026
 07:06:03 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-16-neelx@suse.com>
 <20260602023556.GC2295@sol>
In-Reply-To: <20260602023556.GC2295@sol>
From: Daniel Vacek <neelx@suse.com>
Date: Tue, 22 Sep 2026 16:05:51 +0200
X-Gm-Features: AclHuK9CuIsJsfiw8COS456pIsuT7e5VI7VW-i2_tJPdheeuBMmFVb8b2MLQ3fY
Message-ID: <CAPjX3FfSeE+WOya6Dg8aLSCRADBvnm0nFBk_uBbaeFM4egvqGQ@mail.gmail.com>
Subject: Re: [PATCH v7 15/43] btrfs: implement fscrypt ioctls
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, 
	"Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, 
	David Sterba <dsterba@suse.com>, linux-block@vger.kernel.org, 
	linux-fscrypt@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Omar Sandoval <osandov@osandov.com>, 
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 04:37, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:49AM +0200, Daniel Vacek wrote:
> > diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
> > index 6a37dd3cc5ee..2e0b79f41197 100644
> > --- a/fs/btrfs/ioctl.c
> > +++ b/fs/btrfs/ioctl.c
> > @@ -5159,6 +5159,35 @@ long btrfs_ioctl(struct file *file, unsigned int
> >               return btrfs_ioctl_get_fslabel(fs_info, argp);
> >       case FS_IOC_SETFSLABEL:
> >               return btrfs_ioctl_set_fslabel(file, argp);
> > +#ifdef CONFIG_BTRFS_EXPERIMENTAL
> > +     case FS_IOC_SET_ENCRYPTION_POLICY: {
> > +             if (!IS_ENABLED(CONFIG_FS_ENCRYPTION))
> > +                     return -EOPNOTSUPP;
> > +             if (sb_rdonly(fs_info->sb))
> > +                     return -EROFS;
> > +             /*
> > +              *  If we crash before we commit, nothing encrypted could have
> > +              * been written so it doesn't matter whether the encrypted
> > +              * state persists.
> > +              */
> > +             btrfs_set_fs_incompat(fs_info, ENCRYPT);
> > +             return fscrypt_ioctl_set_policy(file, (const void __user *)arg);
> > +     }
> > +     case FS_IOC_GET_ENCRYPTION_POLICY:
> > +             return fscrypt_ioctl_get_policy(file, (void __user *)arg);
> > +     case FS_IOC_GET_ENCRYPTION_POLICY_EX:
> > +             return fscrypt_ioctl_get_policy_ex(file, (void __user *)arg);
> > +     case FS_IOC_ADD_ENCRYPTION_KEY:
> > +             return fscrypt_ioctl_add_key(file, (void __user *)arg);
> > +     case FS_IOC_REMOVE_ENCRYPTION_KEY:
> > +             return fscrypt_ioctl_remove_key(file, (void __user *)arg);
> > +     case FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS:
> > +             return fscrypt_ioctl_remove_key_all_users(file, (void __user *)arg);
> > +     case FS_IOC_GET_ENCRYPTION_KEY_STATUS:
> > +             return fscrypt_ioctl_get_key_status(file, (void __user *)arg);
> > +     case FS_IOC_GET_ENCRYPTION_NONCE:
> > +             return fscrypt_ioctl_get_nonce(file, (void __user *)arg);
> > +#endif /* CONFIG_BTRFS_EXPERIMENTAL */
>
> Are you sure you want to auto-enable the "encrypt" feature flag like
> this?  It doesn't even require a privilege.
>
> It's also only in FS_IOC_SET_ENCRYPTION_POLICY, so this doesn't work in
> cases where users add a key first.

The filesystem is flagged with encryption once the first file is
encrypted. Adding a key does not change any on-disk data if I'm not
mistaken.

Though I'm open to suggestions.

--nX

> - Eric
