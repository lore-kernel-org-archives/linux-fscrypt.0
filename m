Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.129.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795044959;
	b=KsFod8joYAdotGs4uNaeqibxRFslSvXRwqsmv/eGmbiE0v+zgziF0SJI/1ERDUgieluX
	 vgy4v5GO6OH0CljYNC+5lCO+wvRXEPP+cKA9Rz+LYc0cxKLfB7GprHH4Gz+l0tQm3I3Of
	 Q4dFnZ7gDOjMeLTO24dliB0PXprZmOeqVoUrX1FJ3xSY/wcRlPSUBXlwupLOLpiu/o9rv
	 GNkUirbE52bKZnjITc7GOW7ZKx8eUmVDssUKhw+wUHdyBIVWzi7ayhufZdbBDKsWvVX1k
	 1qifIGjQH90wm/5WhC1dZuk0lrmKq4/M0ddG0kMN/XAuYVGK+GGN/a9ojKvdZJdH+xA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795044959;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=1sqaAoxbPYdo18ldNOsiM1TbcJ03Gv+SVlc5ayXI+nY=;
	b=MoOr/6DXFcx9ke/wFdiXpHEvoHJujYP3lXjwDJIOwBw89K+1ARRtaVlwFRJruHWW6j1O
	 d2x7lRt/YLBdX4K8ZFn/TF+n8+iCMI85R1TfCfTV5sVMkdkKtS8ja8zjWfn8JGSgGkSwO
	 +Z1T0AQnkXx3tDRlF9x/a4fU1UtciP5tX2RlE1OXF25IH51I3Ulpdfyp/l+Pi6zOuzbZP
	 gTva7eHZnG7TugoHnEA8EDJ5mKxQsJE6QyDcSS4TqjFGLtyc+3/VwwdwjxfNRN5GLXto3
	 LZ/ymgzNA4GSczJX+8Lq1bjFq2IGEdnnOJQ5fLKy3cGGXcdS0BqCmgG+lr8stO/U+fg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=V6kE9d08;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=VV4lacCc;
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93FDD606A31C
	for <linux-fscrypt@vger.kernel.org>; Wed, 18 Nov 2026 23:35:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 93FDD606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=V6kE9d08;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=VV4lacCc
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795044957;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=1sqaAoxbPYdo18ldNOsiM1TbcJ03Gv+SVlc5ayXI+nY=;
	b=V6kE9d08nJ5XPprhWrW4xawozHefwUp7xdWFrPK0Eqi2zbTu4Le1UAQ1FL6i2xeyBOY2cI
	T3ihGA2JNGESzS4BLSOv7jkrD0Kme0Pn25aS5O1tXCuAlQ7HRRJ8uLVbn8hIGakYggzLGi
	b3PcFkWVNXxhG58VN+SodjUFyC8pA2M=
Received: from mail-yx1-f69.google.com (mail-yx1-f69.google.com
 [74.125.224.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-497-8nSAmhozOrCmTKSqb9s0cA-1; Wed, 18 Nov 2026 18:35:54 -0500
X-MC-Unique: 8nSAmhozOrCmTKSqb9s0cA-1
X-Mimecast-MFC-AGG-ID: 8nSAmhozOrCmTKSqb9s0cA_1795044954
Received: by mail-yx1-f69.google.com with SMTP id 956f58d0204a3-67be24704b9so2571931d50.1
        for <linux-fscrypt@vger.kernel.org>; Wed, 18 Nov 2026 15:35:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795044954; cv=none;
        d=google.com; s=arc-20260327;
        b=B2e73ZhBpjGErMyGA5nA6jANb9RVTtbxPvfGMP1PjQgeoS+YH2o+mKkvqmBRuyn3pa
         mvUwLtiR/T0vR1BOj0SJ1U98pTk6gQfCa/gEfNatcPDqttDrcS3J9myLJ+4y+zrfS9Nz
         UeBchyLqfOakQfeyqDyFKtDegTJaY4yTC+QZRl6dS5Tr11dIaa9gOSiYMcBj2u/DiDBM
         JDPcr3q2Xvr3j0vH4Vct/y4GDx7oOYzqT6BhygVgbPLVM7hkaIFUbl7aGzNpP+mkAqgS
         X+7H7idlFLjVjvgWae2lcTxzHQdh+TwnMPWvFOTU/vemGmLklkqkmiTeostQZec+VZot
         mH5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=1sqaAoxbPYdo18ldNOsiM1TbcJ03Gv+SVlc5ayXI+nY=;
        fh=oyx/5TWdAqXlezhmCHUd4szO4jvhbvM3hbp9/RuxTF4=;
        b=EIaUSTG0gnu8i6GvaE7o33WXhlfMPo4InCC4dch3GGLZsLOqw9sYaftcckQJGJHVrL
         w1x5avwqccFSaMgKQeyMbhUZR+CFvwRaU9J5Uq9eILsAIiYjROmB9dGLoh7s3GZWwnW8
         oeHu+MACf9Ug7nBscqA3naK0RP6C3FE9DC7Fl8ezdMON8zu02FNpq0IuoFT3DvNBuur9
         FMh6uRZVJW5xiaFIfaBMVsjPdl5IHycNRpfq43HnE0dddssWjE76RvPSPTxU09L2+oVy
         mI+F2AxFluCjb8hbRlKhyKBr+M31WuAHA+98QyQ8zlUKcn1npkc86MsqWklLAHPxnYDI
         0zBw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795044954; x=1795649754; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=1sqaAoxbPYdo18ldNOsiM1TbcJ03Gv+SVlc5ayXI+nY=;
        b=VV4lacCcYXl3jx6oU1yk7ocsmoMzxU9SP0AoOrXpBHytOyD+5/iloPPuTFDwHot85c
         i1CuguwIDMKYkYwOifW2jU2ON3pcwrl2ze+1M1zXcGvzpEjssC/9u8BP5GrnFxyulUg4
         m3kl+sBRcRdHC6cSbeJi+MrV0kK8R6nXJ+1+w101Ltg7NsQzens8JvDyW07HuceLJ6GS
         rA+E2+jV1u9T1OR/mFRBlrYQhI5+p4bfkvpqrJOCTWbtpDO3YyPi5JSYd2/v8scOcjke
         d/uPzbLWNdLsBIgq0z3OZKLiCCq8cx+Fg79vmPk4t0z6mQMU/UeaNF5w+hvK8lTtE+Iw
         eTvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795044954; x=1795649754;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=1sqaAoxbPYdo18ldNOsiM1TbcJ03Gv+SVlc5ayXI+nY=;
        b=F5kTZwnAaRWqrku8UES0JQ0GgIjhecP+Evt7m37HGty4Jzn/rEJMg1YSraXLio26IC
         0EVCzfhLGQPS1pBZLNcD67NouklSk8R84StZPL8RZ3hulaRxMU1z72ixrHRjMm1/vkTe
         pWe3RGpuW2EzNg9azYObKAFsl0bHbRAI1t8yfwcyaGvsB5/vBYWJFq5o6DEFOOijJZ4S
         gfp8dzXDwl/BSX1PCT1LGqpEP2NGJxGP0e9L4VNRqJJpE7JbPhTkk7dltAj7MJbYKzXC
         olUbQr8Az8FFeJEubI28/r0aDeHxuMFMr5TqODzKHG5mIeEIV2ml754y3qnU9rQB0DRb
         DmNg==
X-Forwarded-Encrypted: i=1; AL+hErFhfLdbnXpchUfVRNIrZCYLVr1h6i4iQG64E5/4FyL8xb2WLP05IBAeFrLKQv49oYgD+uUaXXU+iFxA0ybt@vger.kernel.org
X-Gm-Message-State: APuU4Z8Vbv1DxhWHCfMG59482lPzfYJ87h/3ILCgwlumfA3qFDkdQzt5
	Rdu9UVxKN0JaDy8jk1LGjCvmcHlc4PdK1zLW0zMeoXn6f4ZAa9lf/lHBLy6z/NzHMQ/i1GnfV9k
	SMllxkcXVfBEkZb2wAPhpDFhpGUqyDPYK1HCBQLtznyKkpV39JJmMoPvYLpkHETQGJH/yg4HYmJ
	/+6p1aoXPVu3Thyvlo2PA6W5DEOtdZE/nIwmIbJWKurQ==
X-Gm-Gg: AZFdTZcfUUFyW81PKop7jD7099DMHvKTjA9Z+wK9+DrJoxzHpHlMaU1J1BN87RRfgoX
	jLFU2Z8juIbvqvS7O8j4D9QVKNiPY9WF+mltqq2ZHSlfIFuprPE12ucea/gwvf89KzznTvcMuhs
	bHdVb3YECWGhxqmEpITsOwJJ78hHkgBjqlvpHh83EFMvyPRz/hECbs1PnhoSOyzXzK9qjl7CyVw
	J9XvhE+EwlMNtIy8s7OHFXVicjftJQ5JvAotGSvJx2k9Q==
X-Received: by 2002:a05:690e:128a:b0:679:2a90:d3ad with SMTP id 956f58d0204a3-67dd403bf8cmr1618046d50.102.1795044953788;
        Wed, 18 Nov 2026 15:35:53 -0800 (PST)
X-Received: by 2002:a05:690e:128a:b0:679:2a90:d3ad with SMTP id
 956f58d0204a3-67dd403bf8cmr1618023d50.102.1795044953295; Wed, 18 Nov 2026
 15:35:53 -0800 (PST)
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116171044.6938-1-jack@suse.cz> <20261118145941.1063127-19-jack@suse.cz>
In-Reply-To: <20261118145941.1063127-19-jack@suse.cz>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 19 Nov 2026 00:35:42 +0100
X-Gm-Features: AclHuK9zTsUN7zuq72-DSL1ny4jnrrzy1tFjBUU4DEu6A9maK7lyiUQZqwV6vuE
Message-ID: <CAHc6FU7NoZua98SGP9Kuga58gAcco6X__u=kOPfsUqbefAKLFQ@mail.gmail.com>
Subject: Re: [PATCH 06/13] gfs2: Avoid racy dirtiness check in gfs2_fsync()
To: Jan Kara <jack@suse.cz>
Cc: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org, gfs2@lists.linux.dev, 
	Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, 
	Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, 
	Carlos Maiolino <cem@kernel.org>, linux-xfs@vger.kernel.org, 
	David Howells <dhowells@redhat.com>, Marc Dionne <marc.dionne@auristor.com>, 
	linux-afs@lists.infradead.org, Miklos Szeredi <miklos@szeredi.hu>, 
	fuse-devel@lists.linux.dev, linux-block@vger.kernel.org, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org, 
	Eric Biggers <ebiggers@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Jan,

On Wed, Nov 18, 2026 at 4:00=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> Check for I_DIRTY_PAGES state in gfs2_fsync() is racy because
> __writeback_single_inode() unconditionally clears the flag and
> reinstates it only later based on PAGECACHE_TAG_DIRTY tag. If
> gfs2_fsync() unlocked read of i_state hits in between, it will not see
> I_DIRTY_PAGES although there may be dirty folios in the mapping. Check
> for PAGECACHE_TAG_DIRTY instead and use inode_is_dirty() helper for
> inode metadata dirtiness check.
>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/gfs2/file.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
>
> diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
> index 1efd0679badd..f5532f72ab99 100644
> --- a/fs/gfs2/file.c
> +++ b/fs/gfs2/file.c
> @@ -749,7 +749,7 @@ static int gfs2_fsync(struct file *file, loff_t start=
, loff_t end,
>  {
>         struct address_space *mapping =3D file->f_mapping;
>         struct inode *inode =3D mapping->host;
> -       int sync_state =3D inode_state_read_once(inode) & I_DIRTY;
> +       bool dirty_data =3D mapping_tagged(inode->i_mapping, PAGECACHE_TA=
G_DIRTY);
>         struct gfs2_glock *gl =3D gfs2_inode_glock(inode);
>         struct gfs2_inode *ip =3D GFS2_I(inode);
>         int ret =3D 0, ret1 =3D 0;
> @@ -760,12 +760,8 @@ static int gfs2_fsync(struct file *file, loff_t star=
t, loff_t end,
>                         return ret1;
>         }
>
> -       if (!gfs2_is_jdata(ip))
> -               sync_state &=3D ~I_DIRTY_PAGES;
> -       if (datasync)
> -               sync_state &=3D ~I_DIRTY_SYNC;
> -
> -       if (sync_state) {
> +       if (inode_is_dirty(inode, datasync) ||
> +           (gfs2_is_jdata(ip) && dirty_data)) {

this adds back the I_DIRTY_TIME check explicitly removed in commit:

3aac630b5ce1 ("gfs2: don't worry about I_DIRTY_TIME in gfs2_fsync()")

Could you please clarify what's going on?

>                 ret =3D sync_inode_metadata(inode, 1);
>                 if (ret)
>                         return ret;
> --
> 2.53.0
>

Thanks,
Andreas

