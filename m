Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.129.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792516577;
	b=weSNCa3lSARojczQhuwcl3rK7w5kPeAluIVLXMGRaju9YX4XxrKKFDK+W1Q0mpSKQ7qG
	 s+YxfcKuw0Gi0RCzPZlP+jK3EqAiV+62Bjetf639ImrrjyK8dyc2vtS4+bO2UwIHtEr0a
	 L8hffSV1psoOGqniT3Df0rhHWHTQazMf4QPixoD79AWokpjIePTFiKFiCtmCVNPsvGZ6N
	 750T9j8w7OFSscXRDIwMKhZ3dRdu8EB1EowVmi4Cw5iLijaSGxUiJCKtX5ddY3lj0BLU4
	 G5OryNrXXlda8JPAi7Db40d++YCcuOcML9ni/zAeH0f+XOXEnVHqAAuuSrF3I1uQz0w==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792516577;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=Dqa81DbmEVosVhZIeXDqyDww6DzKrf466i3qKtWkyUc=;
	b=Q0KjUc5fROq9qBApK6NczB+Em5jAKUHgMn9afrlbRy2vXXyyGLmWBvrpZqEQniu3poN1
	 RkCCtBQr4LSPBTHa9m2nbg7Vpcm7tadbJZMIQ17eeMhOdeQqffnXo61j1LvDdweV126Mk
	 3/nePsbhVK/7IaPzl79u0hFB8eyGIwJtl85DiI3LmFysXHrdoSEVuYgWY7YyAcNqnnHBM
	 e6XhlSeGzvB2hciJStZAVdL8j6duyirzrKWqQi8zmH+9vL4+TO2hsy1Hy7T3Vl5Wb61ZB
	 IDoF/mScEu3woYwjd0YEe/RRgKxZFTVEJ1JRctfB1T7c/CSHTVWFoEAHWPBCLGHLCzA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Ecd8DD2A;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=RTR1tuVd;
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 34330606D5B6
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 17:16:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 34330606D5B6
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Ecd8DD2A;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=RTR1tuVd
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792516576;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Dqa81DbmEVosVhZIeXDqyDww6DzKrf466i3qKtWkyUc=;
	b=Ecd8DD2AyE97DPNIMbzgqPsx5CxwwWQuIpAJO24k1c0Yjh0Y/VN1nsqSX+cTbGEjbdExS4
	UPLtINuKV9hVzQC/1HSdzb5/98qkJAfBii4TDE5ygJmZDtH13IQHh9Su5FdNirGTzj+yNJ
	VDbFxt/uiBc91apoegNpSSp2e5MYzc0=
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com
 [209.85.222.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-623-PnTTSJAgMVKigt7q0FQJNw-1; Tue, 20 Oct 2026 17:16:08 +0000
X-MC-Unique: PnTTSJAgMVKigt7q0FQJNw-1
X-Mimecast-MFC-AGG-ID: PnTTSJAgMVKigt7q0FQJNw_1792516568
Received: by mail-ua1-f72.google.com with SMTP id a1e0cc1a2514c-98c88cefeb3so1906051241.3
        for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 10:16:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792516568; cv=none;
        d=google.com; s=arc-20260327;
        b=eUSokP/P0LtKAbpeTCTxP4HjUj2xoRmU7gB1Rh+XOIaqHPGlMPziEASGbP2ZaRsM39
         u99FRnBhedRXBvTxH75vvqCL6sH6bCOUS1s8QDUfYQuyQ5J9FX7klCkc9xCTmUTtckDw
         gX8XCQvI2BfeSv2qkxtUGyPr5/LV/WA4DtAkVnJZwcuS34YjiEMMqGii8XsfxEkjN/C1
         OAI3bwWkcGTq779ITjB35kegggHs8GhfAr9IsYGzG51zTvL/VO8m8wUCCEkOzAarjTlR
         WS5mKLjTD/3F2PIuQBJQxNTCsogCw9iLlSamZ/hIAf5BSFBU5LDY2CcVQMl+kvwH0NyF
         AYWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Dqa81DbmEVosVhZIeXDqyDww6DzKrf466i3qKtWkyUc=;
        fh=tA6xaRJqeFecPHpjlUFtJSvEUp9N/9bUrTg/F8F0h8k=;
        b=rA6d3iFPxTxynaE57+oh91Ce0m2VaEb+hm60lN2TgDPCT0sQjl6IjYlMkaUWZnhDTq
         GiY2RnKui5fZF3aHJf2oBaegaaX317uyT86fV/TgeJnfdZSQJRdJl1sS4lxZmuMbe2er
         xUETsY5e169oKzf2ZG2S3YEocNasCmqtcJ3d6ERW1kKR62Ago8NvmcUakMhgl/8+rcA8
         mZPr86EplYDaKLhOu2AWy/OD+AIDOs09OMUfidS70lP6rdApyzh994T3d27RaNyXlMrh
         YVImO7utsdvI9hb0UtANIj308/O/yoNk81GtRDs/xRskCKBi1LUiDzIov4Vh/tqOAYOO
         Wz+g==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792516568; x=1793121368; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=Dqa81DbmEVosVhZIeXDqyDww6DzKrf466i3qKtWkyUc=;
        b=RTR1tuVdDUHEn2ze9H0ohlkt3ebd/D9SNxeKWODVXZQhpsFgpYk6JwWTN7hONZN1By
         ilI4c70pSxdaJAD8xOn2Tij9xfPC3yZf264U8QH18P2oaXTYQV1Df0UnpJbAwBQj3scN
         KsNZ9qxMAD5WISFxDRN9lhW4g7WcpnSt24ilP5OOpGpr9tIwm6LI4G3rY4E8L4m8Ywam
         +miLtYZNvR7evgHh4FH3sgCgNx0tjkEGtoYSabCtdfYQg5FwSFyXWtijwKwVGB9mYLSx
         UbBoGu4Y3qufmKbf+VOdR0+k255Uq2ab8Dnj2JkqEi3w1LF1E8zW8y2/Tb7qyEsG3iOh
         aqrg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792516568; x=1793121368;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Dqa81DbmEVosVhZIeXDqyDww6DzKrf466i3qKtWkyUc=;
        b=xco8Ly7peRpiOTeGNrZBoxLBgZBDaahICgWec+vFVRKBXRQ8/DL0gXtEruWlzoKn2U
         eNDAO2JByI2snjf+kdLiVGQ1jEb9vAP/LzcvccVvz/GsQ666JaD0/ewCo75aepP9qcP0
         4drbd2Y6WHtcw+DqjzLoMB0xTQypQvPo378htJMkHDBYX0V8ZA0fZt9GpVIBRjXPxOjx
         H5r2CojFZTtl3miv/rTkjPNIvC+XNRK8CaCh1nxGi3D9QBE85wEHXy9SptlPaI1TCZHd
         L8tXi430QAQYxZtnWeYh8UQiT3VqI9EWPZmXbytdPSBn9jDYF2Jes0wNQwL+04N4cQkf
         dlEg==
X-Forwarded-Encrypted: i=1; AKwUvBy07eHoxRWB89PUKhOeSsl6UVbRoq1cmgnLVxD1XuMgg7M9qCjY7DjJ6VSMrszHs0Wr4ufgXSJndQVT+6cq@vger.kernel.org
X-Gm-Message-State: AFq9FYLT1AWkh8rBXDHk/vekrqYFMQDUrJxZjgOOKGNsjTr9P1dX+LUM
	zs2WHU2QDLLYHJH7YRilizRDAv0tRRj7yNre+7rY705QuZQsGRRuW+gyeZmxrGwD5ocizuK46/f
	K+tfwJQ2j5Ykl8U5ueXJfl6rrJl/qIx5hYeWO2LMDH8ytfPGWIbJ0iFysJIYaVF9h70BG+sYnJB
	L5tCr1Sz5R01ZYKJEf774kF4pds06cL1IzMJaIOh2VQA==
X-Gm-Gg: AYBFou0oBILZYJIUzRmsdtmPmYirvxtnoGww3UCMSvbKXj9MR5hwaLO1JVra+DvlaeQ
	bpxTBgMq66aGy+8Eacloz9hOSlYm2BVUZLkG7x5sAsNhAV618qfXKBQpu1EKWZ9oZm1Msue6KVR
	TO1VZafpgVvSOXESOhJbYO6Iu/KfK3Tgy/RURTu8H+HackNuHGzsKDi30Pdb9DVa3ZcNMTMXqvY
	tBnyU26DjDMVlVqEJOTmYP+4iKN/PwW60XhHiJAhnPqoiDLO15LgtijM+MYDFFzOlXxELkCsI9i
	+84j6TW1jASGjCIhwgZzZwkSpw==
X-Received: by 2002:a05:6102:358d:b0:7c3:b15:a981 with SMTP id ada2fe7eead31-7cc3695de87mr3672346137.15.1792516567827;
        Tue, 20 Oct 2026 10:16:07 -0700 (PDT)
X-Received: by 2002:a05:6102:358d:b0:7c3:b15:a981 with SMTP id
 ada2fe7eead31-7cc3695de87mr3672333137.15.1792516567403; Tue, 20 Oct 2026
 10:16:07 -0700 (PDT)
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <cover.1792498351.git.amarkuze@redhat.com> <20261020160537.GD699485@google.com>
In-Reply-To: <20261020160537.GD699485@google.com>
From: Alex Markuze <amarkuze@redhat.com>
Date: Tue, 20 Oct 2026 20:15:56 +0300
X-Gm-Features: AclHuK8IZ3rN_Kb2MqxIXzdba8gBbiLwQmfRP__gRggxXmiCnqZNpSqi1Sf_34w
Message-ID: <CAO8a2SjWStsoCQ7eeoBb5oY3nSUQVFVMT9Rvj1ZcFGNBctuEvg@mail.gmail.com>
Subject: Re: [PATCH v4 0/5] ceph: support subvolume quarantine
To: Eric Biggers <ebiggers@kernel.org>
Cc: ceph-devel@vger.kernel.org, idryomov@gmail.com, xiubo.li@clyso.com, 
	slava@dubeyko.com, viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz, 
	linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, tytso@mit.edu, 
	jaegeuk@kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

My bad, resending.

On Tue, Oct 20, 2026 at 7:05=E2=80=AFPM Eric Biggers <ebiggers@kernel.org> =
wrote:
>
> On Tue, Oct 20, 2026 at 12:52:32PM +0000, Alex Markuze wrote:
> > CephFS subvolume quarantine isolates a subvolume while allowing recover=
y
> > clients with q/Q MDS auth caps to access it. Advertise support only aft=
er
> > cached data and metadata access paths can enforce quarantine.
>
> No base-commit given, and this fails to apply to current mainline,
> current linux-next, and also to the current default branch of
> https://github.com/ceph/ceph-client.git which MAINTAINERS lists for
> fs/ceph/.  So it isn't possible to review this.
>
> Note that Sashiko was unable to apply it too, so no reviews from Sashiko
> are available either.
>
> It's getting to the point where I should just immediately delete all
> patches that don't have a base-commit.  It's a waste of time to even
> bother trying to look at them.
>
> - Eric
>

