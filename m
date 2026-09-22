Received: from mail-wr2-f12.google.com (mail-wr2-f12.google.com [74.125.225.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B61F754CF6B
	for <linux-fscrypt@vger.kernel.org>; Tue, 22 Sep 2026 14:05:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.225.76
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790085948; cv=pass; b=MNCFrpsukZkDFWIJmRtxOGHAqUc3nO8g/TIQIbXyV7eZGyU4NoXDwxUKT5KTlFx7vXBqAIMDhs3l0AqWbxZfHd0UZFGeR84RhDsUDIn4YEL/izzI0NwyeKwiMz0vwSOGkXxeKB9K2EpCu80OYafDxhl6pTROclJhYjFvnm1lib0=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790085948; c=relaxed/simple;
	bh=4H7cYh/XcFy79IKh5ntWbkLJLoAWIpLRyRLXVAEP+zw=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=q+aNJ4C3Cf7I/vFDwKTKmWwZqnvK97rYyWPACqsxyLP63UU6MXu/81hru+iSIgZ12QXvQkx1Xnfh0ZONTM2qh/0cU+75kDJHAKvANqwGOgthLfkK750GMaM0H8AB8vETwnlcd5WntXkD83cktP4K4SptIQ1Lspl0k189etaq2mc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=OaZw4Jlp; arc=pass smtp.client-ip=74.125.225.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="OaZw4Jlp"
Received: by mail-wr2-f12.google.com with SMTP id ffacd0b85a97d-482f6350f91so2522426f8f.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 22 Sep 2026 07:05:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790085945; cv=none;
        d=google.com; s=arc-20260327;
        b=L5VN4MTByJq/hnyJwXIf6lys+so5y8gIq+GcieKChsejpawXkLJMnOl7FUK/hlfLz/
         fBRKB4NH06v+7iI9jE3u/jtzHA5ZII9x3Kr+KiYARO1DZAmjoaHAsK0+WY4dhCSngbTA
         X0PsBBfjd5B/12GwCjp6u+0/SIqSoIImBjKnG6ddKuu3QCfYZq0qYFD1K9UDl6ccRVQA
         a8YO0th2rJzAo18XpHJK7LFYBRqS+5HrgpGHR2mKPYr/1CFbkzngo4Pe6yMKjuvfVB84
         z54bZV4dxQwRIC3PnAxmKH77vtRtKVFe2HkPOHiPn/T/JF3wlTToSg3ml8WFtyLiDE/M
         WdkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LV8hwkL+g4D+YUVw11Whf1ua4hVH+TJu4M6R33VpXN0=;
        fh=bcYHLv86NKzdrTzuWIkxp20OMfb8EvBcslaYnpL3chU=;
        b=dBDnUyN/1ZbVd13UY5GS0KihxaBTazzidyKzm4gYrMnyHAizMFaJho2Jjah6Ul2FNg
         yuSwCJoYW/5C75Jk9NX8g0uk/d5iYvFswksuDGVwasLL9+OOapT5k5klBVAZXoRDa/zy
         e62lVpr2RqymBbrvIn+K/yRtAQK/WPvfxX1F7QGgi2dTGIAkR8qaphmDmTug0YaoUnej
         i5/bFiNiPtolYdUfTn/B4/hSsPQdnoX5BVfxStJbtaJp8M4IN6Ec01XlxQWhhMVIn0Zh
         rJIRwbgbLxYAKJouvh4eebnl8zTcqHk3l2L/9/TxO6E/Gq7nDdniY8+l312Uvn/bzPyd
         ltJA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1790085945; x=1790690745; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=LV8hwkL+g4D+YUVw11Whf1ua4hVH+TJu4M6R33VpXN0=;
        b=OaZw4JlpEJnPotAAApkw/LFOiwvi3X6tj5Xr6yfn43f8A4HJunL2BYhfAn/tznUyVN
         qjajcgIof+vAF77Nlhhn7LGc8XluAKPY9Yugz6Saty9rYpmP2sMv0tARCSpOk7VNloUX
         pg6RkXpf1TMnVHEw2B1zF43vBSyFXnJTkQ80F6dOKOiEAGWiHSkNIcJ7rQ3Ikjox+m3j
         IWk3KcV3HzS5aK8rZVaUHv+4hEfKXf49VAYL0MLmlhtyUpDhuaGK2eEgUidZx8GkSY0o
         6dUI/uQ/eDY1C2+J4jWSCEsIm4YwmSej4UX+8SNIix6XGo6yUUSuhmH5ang8rK0XG26q
         sY/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790085945; x=1790690745;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=LV8hwkL+g4D+YUVw11Whf1ua4hVH+TJu4M6R33VpXN0=;
        b=xT4j3uyrpoyGVvvD3TOqpQC56Xthp8J4dhKD/pnTr/r7Bzghnir2gw5+mWM8qx/S+O
         bkiP4fU0mh0VCWIdHbaSsavZOe/w0wsWzmqgbpkEPb+f6ViUXfuv0UEndX3sa+2o0Csx
         1XsKBKH8snRiogTGUYvPtxkwNUZK+cB5wnL9igbXVO3a7JMYrDZGTDDq0HcYZsHEVxFK
         K8iJ1kdS5Xg5v5TsVucCeGJ3/nVdpTn0bC2bKtaWtmVsYP9xaZ5BEbvlFO4xaFZgq+ic
         0fl/BKRUWoivj80uHFFeQLtNmFfhH8Ye33/1gQwWQd4RuvDYhQfR0izraNsMCcePimQf
         QMtg==
X-Forwarded-Encrypted: i=1; AKwUvBxe1AtXCYC5fL7ilK5Mzo6INvxHhGljOmuOmbyMmp07QY21zOly9jhtxUkhQKlqlpmPQYViJtwc8LK+5RjY@vger.kernel.org
X-Gm-Message-State: AFuF++k4uTK6w9sA/LJLfCam5gsyZz7AL/NCukZcK1PBI8vb0UYV1oFg
	Ob68alvGTYObJKwQgzIcCcvay5Tope4/lXOITvVNvtmAfCfkoTsTw/szzBd133OP7OZSNMeBa3w
	6MAVHenq1H1H/J5zKD7emId+VVSiydyuVH693GHnnFg==
X-Gm-Gg: AYBFou1g87TaUHrDN8E1A+nMptlHXdlsEE3VcYGyJgimyoBu+HhVKzQwxN9iJO1F7ah
	MGXT2QgSYTN/3vbTcUqeM1I5LDZrH6aoeGIh+uSx4XNfxeLAY3wqzLO1hMEU2Y9j0uO8+Ijl7TR
	a/jORoehdls2uvt6V95EohWnfCH+PG1AHAmtDIk5X/QIewKGq45g6mLpXZOlmeVXyxjHujwqRlK
	epJiwiyg05WdGh4fGEKam8FKRRX2ntj6ariooDB0hiZWO09C1iiRluvHuNWIlMORs1TkjqRRXSS
	tw3f8GLL/3Tr6sy7GHGw3UKrpMQhD9Z9HYXLmwbOH6/Dk4BGTSCIB/wuEDcm0OCDXwuyu0Vo/QI
	oodC434Gh9VsPzF1kqO8CchQfKZfpNSqR4UJBxKn9tOtkZu+Yhp77
X-Received: by 2002:a05:6000:2409:b0:487:342:d147 with SMTP id
 ffacd0b85a97d-4871e363e1cmr24110192f8f.39.1790085944981; Tue, 22 Sep 2026
 07:05:44 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-14-neelx@suse.com>
 <20260601234454.GF25574@quark>
In-Reply-To: <20260601234454.GF25574@quark>
From: Daniel Vacek <neelx@suse.com>
Date: Tue, 22 Sep 2026 16:05:33 +0200
X-Gm-Features: AclHuK8dl-tYp2fYNBoxko904-iqmC5latOeVGuZqXI84CESlhxypC11MK8aWjs
Message-ID: <CAPjX3FctU6PQ1=2vL5yVPhWRb9konu2P=Oz_W4E-KSu0FmG96g@mail.gmail.com>
Subject: Re: [PATCH v7 13/43] btrfs: adapt readdir for encrypted and nokey names
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, 
	"Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, 
	David Sterba <dsterba@suse.com>, linux-block@vger.kernel.org, 
	linux-fscrypt@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, Omar Sandoval <osandov@osandov.com>, 
	Sweet Tea Dorminy <sweettea-kernel@dorminy.me>
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 01:44, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:47AM +0200, Daniel Vacek wrote:
> > +     /*
> > +      * TODO: This should maybe be using the crypto API, not the fallback,
> > +      * but fscrypt uses the fallback and this is only used in emulation of
> > +      * fscrypt's buffer sha256 method.
> > +      */
>
> You can delete this TODO.  The SHA-256 library functions just do the
> right thing now.

That's great! Thanks.

While at it, there was also a BUG for folios of order > 0. So I
cleaned up the whole function a bit.

--nX

> - Eric
