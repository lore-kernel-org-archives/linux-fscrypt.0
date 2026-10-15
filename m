Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B95B38F638
	for <linux-fscrypt@vger.kernel.org>; Thu, 15 Oct 2026 19:45:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=170.10.133.124
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792093533; cv=pass; b=Zu7FrTAsxyUOSZeWY2sPR7U4bJHPqzRvW8L9Bk/yygQSRlkaMOdI5i9WKfRHoTPMj+eG48i52n/qKJX4TtBfunlfSbmofOIPC8iG8LVWqPywIOZR7gxlU4d5BIUopFgsdNG+pp6li8YBZCjTKavLhAYUaH/1dZK+DLTMEjWMeJE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792093533; c=relaxed/simple;
	bh=rUeS/xuQsA6DpulQ5gLZTPgWyt3PFheEdxPEtDmQpAU=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=Azy+odd+uQ+2CG5fKfzrCO60KQZ6DQBhd1enzvZsxx+ejDpghcYDRCwPxESdbXij1A3Mjk5l8BFpIOShzFf9ImlMugIl21YNfv2noqZvi8mo7WTE9hUa/T2X3Y1WPntzBIiZUapJ1VgYX31ruZ1oOKoC+qTx+pkQq9iBmxMavlc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=CkeK1Meo; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=YStH/6zs; arc=pass smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="CkeK1Meo";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="YStH/6zs"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792093531;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=e/jCg/YDFTxo4rxhpppNdODIDqzYkL4lcpoJNVladB8=;
	b=CkeK1MeoZkoVWk+LxXD4mCT3yHaqcyKdBCdT1ffomQdBX4UfZhcZTVPoGhW+FMdnguM2Iy
	PCDD2NFy1dUMi1xARwIQYeCDsv/OLotbJafeYunB+DoYlVmiNjf3J90vwM3PV0AvID6mIe
	qyU8z5yeOc8YpnRPTzu/8cfbPa97WYY=
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com
 [209.85.221.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-464-DolrFXiaNdWyj8QD302eBQ-1; Thu, 15 Oct 2026 19:45:29 +0000
X-MC-Unique: DolrFXiaNdWyj8QD302eBQ-1
X-Mimecast-MFC-AGG-ID: DolrFXiaNdWyj8QD302eBQ_1792093529
Received: by mail-vk1-f200.google.com with SMTP id 71dfb90a1353d-5e95ef10aeaso2051895e0c.2
        for <linux-fscrypt@vger.kernel.org>; Thu, 15 Oct 2026 12:45:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792093529; cv=none;
        d=google.com; s=arc-20260327;
        b=Pmz+g8jTYcLZ0Aa8EXnyvJn7fFVuJikG5/xESmhtuGU1Afgjubx/dMBjnCVlnYyT5v
         sAupvbLvHbQpWE+ARBeNd58xEVRq+fycyzXhC93cFLoO2JbwIez00gFvtLDt4jrlehTf
         +NO+2ZfbXsF9AeaSztWWYGIiDUfv5LFNGk5O9eFE6MVjIRiLkjiI4M34VB+cKP+QmOUs
         Jr2XRTHlg3C6E2MGBkyHtqrcsOlnVqROk1+TjBknRRQ9z4OfN3xOi3p5dDQW7IxNJpEk
         /Wd1PPcZAcrkajsRzbx55IYSN/Jz9aaRpugyTd19yb/zGckuSUsyXSuvElbRZWoSDOKE
         Nw5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=e/jCg/YDFTxo4rxhpppNdODIDqzYkL4lcpoJNVladB8=;
        fh=6tOcpB6h1Us2DBZxzkWb0+f5uwfdzmz0gr4tEFiZlZs=;
        b=iP+yl3c5oS1FJ6poEOcvZt93P53aMXI/ozpeFqIMZkD5LU8h7BBRs9k1DzWmEWRpdp
         YPtkZDX+1nG4i90ZM64E4Cy7uFR1epb+Io+1Sp+vBIHHk9JTSiGp/lSrrcKeZPIH2rbl
         7vGx3AED1mvgxg0+GKKEhV4GypApkHbMEYxGbb2vWtT/p79g42G+T4nwvDkCWsgAEqFN
         VfdQJnVKaFtBGknokHf5hA5JtXAKBCe324j67skmf+iXAHttwwNohvAr+Zdb2H+XA3x8
         enqSoPsYHv0m8I1ygqxn3Aqmb4mHBB+DQCQkmMZDSG/m+lx4ZVwIOVDEIWjk/t7iR+sz
         dWgg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792093529; x=1792698329; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=e/jCg/YDFTxo4rxhpppNdODIDqzYkL4lcpoJNVladB8=;
        b=YStH/6zsrUgqq738WWc3YwiFice/4xeIcv2E3LZpYhV3u8nRzceZ9RkXTR3OnHLQQW
         EIS+7Pi6mVZggvRQdvdDfovtmpiBH16/tjiZzWDLFWv30I6z6EwsBNrcXG3Ag5ZiCBtS
         Aj/Pn/bxEL1ok8uDMMRxH8pdJTIJJM44L/XMS3sg24yKdPiytGTngO4wDZaimU1ULBYc
         qgsXaHT1DV/eLLd6PoEHtwihMKS11eQvQYPesrIXr+K/lWy9wRKgolFLJBXLlTj7jnT5
         4KQlI/FJ9X7uTRPWWNAC/uBV53+8BL3EVxILBcxuBFhoOq5XlxBMJ64MEsPP/Jy0BI52
         dbAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792093529; x=1792698329;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=e/jCg/YDFTxo4rxhpppNdODIDqzYkL4lcpoJNVladB8=;
        b=TlewmtjENJjSbFL3VNJsE9H0fIhS1HZsA7JVr/MtPrgE/IfUv1IjsXWyskl7UXn3Ag
         8vRJCLI+DorLuTNu1DkN9NX47NGKja0fDuBCGpS2UBZjXo+LM7/QQ1eGvaQoYXGv4rFL
         8XA4s6k6IGQq7zibze1kT7xhtDyHv+VdAe56sj+N4IWz/EMLVzndbQ/onskI3AMDZZLg
         6mXD8bD9ALB12GJEuFQT/XneQb3zhv9UbOA4Ey6ISdNfWUAjP6R6QyHFLNljeWJ6e9kL
         S1pjHhLEgNcXFVWHZCij6eh7CTw/J7Opt65FyVUlkzLO4Cqwtgq40XzO1ulEjEObrtcV
         TgOA==
X-Gm-Message-State: AFq9FYIrWMisitDzkfQfdGLAgDLqwsu97hgspvUR3L+W1OhClzjkbtwh
	htnoE0MK7Fw1D0fO6gi68OOniUV98Pa3u5ycEUvLTXCL9n8u5T6Xfn8mB1ZQ80xlSES3PxjB8I+
	OqiDL+XRlKtDkYH58VrRdMuhkBpsBIE0xZ8fApKCOoHUG/cxmJ318mhrWO6QWCStY1gtFwYbGED
	lgdjXdArUpZ9TK7g4CTDQUwWHMaVnCztt+oOuj1tnz5w==
X-Gm-Gg: AYBFou2OpskF7NEVtB0K2daQ+4eQr7B33Gn9cGywPOHLezcQiSzpBmb1df435iQ2IlO
	yB4z+iaWb4FTm2yUY5Qga8AjZYGe+2XSXg6ODXQEVkfpLwo2sBLg5X1vbfZY5hDb5evqNV3js6x
	yKMJQKWFhM1uaUIea7+Hj1Nc2fUS9wWPFVm3VEtjfI6G+0lhtktf0jIw32rjonh0/pCMCH4xMM9
	Zyh4alJ6+AY4K0ADQ/UonlbHaYm+Z2+YebYjMOfSlr4PuvQSVG7ZN1o/6CE8/3rm3GbxXh6YYQ6
	w6I6NxXsPFMbK6bwhMO3fxRCvQ==
X-Received: by 2002:a05:6122:3d0b:b0:5e6:82ca:c551 with SMTP id 71dfb90a1353d-5e91f591b44mr7262720e0c.22.1792093528983;
        Thu, 15 Oct 2026 12:45:28 -0700 (PDT)
X-Received: by 2002:a05:6122:3d0b:b0:5e6:82ca:c551 with SMTP id
 71dfb90a1353d-5e91f591b44mr7262713e0c.22.1792093528527; Thu, 15 Oct 2026
 12:45:28 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <a01d0a297a3e174d21741a3ad586ce546327603e.1792081664.git.amarkuze@redhat.com>
 <20261015183548.GE2170687@google.com> <CAO8a2Sjr6XSizdgobZK1ZAO8PUd5tCDFKjdD-=3TXHwqOU6qfg@mail.gmail.com>
 <20261015193800.GH2170687@google.com>
In-Reply-To: <20261015193800.GH2170687@google.com>
From: Alex Markuze <amarkuze@redhat.com>
Date: Thu, 15 Oct 2026 22:45:16 +0300
X-Gm-Features: AclHuK-i9Hsh1nRovFHiSF3i8Hp7Cu5cMuuh8GOgLNjfxQfG6bb774db-F-FpUQ
Message-ID: <CAO8a2SgiFTarbcg-qgTLgjk1RsOMLwHsjj9ko8HgT99F1DAYrg@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: allow filesystems to disable symlink target caching
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Ilya Dryomov <idryomov@gmail.com>, Xiubo Li <xiubo.li@clyso.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I didn't want to conflate fscrypt patches with Ceph features; arguably
two distinct patchsets.

I will CC you folks when this is acked then.

On Thu, Oct 15, 2026 at 10:38=E2=80=AFPM Eric Biggers <ebiggers@kernel.org>=
 wrote:
>
> On Thu, Oct 15, 2026 at 09:52:11PM +0300, Alex Markuze wrote:
> > Hi Eric,
> >
> > This supports the concurrent CephFS subvolume quarantine series.
> > There=E2=80=99s no Fixes: tag since this isn't addressing an existing u=
pstream
> > regression.
> >
> > The quarantine series adds checks to Ceph's ->get_link(). However, if
> > an encrypted symlink target was cached prior to quarantine, the VFS
> > bypasses that callback entirely when following or reading it. While
> > the target data is still valid, access now needs to be denied.
> >
> > This patch adds an opt-out for symlink caching and enables it for
> > Ceph, handling the encrypted-symlink case for the concurrent series
> > without affecting other filesystems.
> >
>
> That series wasn't sent to me.  Is it
> https://lore.kernel.org/r/cover.1792074165.git.amarkuze@redhat.com/ ?
> It would make more sense to add this patch to that series so that they
> can be reviewed together.  I can potentially apply a prerequisite patch
> by itself, but we'd first need to know that the rest has been reviewed
> and will be accepted too, otherwise it will be unused code.
>
> - Eric
>

