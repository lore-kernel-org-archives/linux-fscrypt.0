Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792500778;
	b=gZJ7vK5oRlxqLfJy812lkFAMdYRaeEZjeQkgkjkK+tncJ4xEyUh9z5xO/m2WLy662GQ4
	 rT1ctQi5vXMiIiCE/ToTziis9+JWkvhBAbL85JLd4LuMzQ0mKmWmxM1O06zA7yM0mZo1i
	 oapFd5MMFKpgFt+fV5f5pq20z2cQlG/t0yeKYCe5hbeD4wh+NIi0Na8IIJVLU5euXvIBT
	 E9SZTvref2/Z9rPrNp6Qj45qpsqwUJoCqBnTSk5twPvLMm/AuEP/c2dVtIz+xNQARCgkw
	 pedFhe1iOUluvp8NJvxXRRHQuuDVrO6NTb3+gGl39XLF/xjexKgJzTUeYgaz6MTy/Rw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792500778;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=RRNHwuzxK2uMbz7SC9yJ7WKgsG9c53Ltjg56svJJIY8=;
	b=t2bCJvG7I9cVk6gUjSkaJowIoLVHGxaR8yV9YteZQ5jpvPacLioz3zU6xynlmPqG1o/u
	 5CvgErbWQUgwhOWW/YaUHRi+WEomMvN8J+nv5agc/7j5GFksgrQxPiNPe2Ne2Dkk4kG8O
	 NiCRdjyq2fXUb9hFsWOayEFm5gyTojV1dwjDdsNEehXKEguYC3030tc53eDwTq4rX7MTx
	 Ye81p70jH2B01v8VihWSHdkfcMgcgumOvIsXeOcmcIrovIQ0Jg7pufFxNKLr6B0LASd8Z
	 bQ6g9Oq0Vy1B2Yf3hF1jKNX81HZ6wKNzHpTob+85mfmRblqdBFAjm9hUAKD9Sx279Gg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=fuj4N+cA;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=sJcYLhdB;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6B1A60A5BDE
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 12:52:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A6B1A60A5BDE
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=fuj4N+cA;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=sJcYLhdB
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792500776;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=RRNHwuzxK2uMbz7SC9yJ7WKgsG9c53Ltjg56svJJIY8=;
	b=fuj4N+cAVZVCQq6arQ72/3/lbMxmIUAYmCBFWWyAiEkj88D7GKheKN2MECLZSufA1CX4ng
	tdemMZpyCQb6/py/FOhW8HSMsOOSJ5C2Izv24a161m5R+bNH0zgOx9RQ+MlC45ZuHVHEEn
	YWiHRk/Syyh1hw4QN3gwMPCUs52sW4s=
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com
 [209.85.208.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-629-8FrC71epOc2si2pBPHFnIQ-1; Tue, 20 Oct 2026 12:52:43 +0000
X-MC-Unique: 8FrC71epOc2si2pBPHFnIQ-1
X-Mimecast-MFC-AGG-ID: 8FrC71epOc2si2pBPHFnIQ_1792500762
Received: by mail-ed1-f71.google.com with SMTP id 4fb4d7f45d1cf-6a178080182so3486793a12.2
        for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 05:52:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792500762; x=1793105562; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=RRNHwuzxK2uMbz7SC9yJ7WKgsG9c53Ltjg56svJJIY8=;
        b=sJcYLhdBPlyCvITcjoMJCirtD3PPzZMPnNFxOe87vaVuhpHrIXWHIkuOu2iY/atHLh
         1JF7UuAGdokQTF27QVDwaogPAJj2p+i45CjQ82k92qVljM2CEAu4L1dtWpdcRnWg/nkw
         g5Fkgi0hcuM9hVOl68ideiHl0TGGwq+HjvnkrUPd9xztWqSqPwpQnDjxVrygB6s94SWm
         H6chIRaxCIEQ+keh44j1oAS7Bfjb2Ij3zS3txZkWltNNArc547Dqio+kmRJV/l6P3csv
         dbQjXRPRSp8Sp5p7+PkBB2gvF1Gn7wdPhCy0WReEFI3bOtSYOC3s6w5dvuTQJOBVNQgw
         JCeQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792500762; x=1793105562;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=RRNHwuzxK2uMbz7SC9yJ7WKgsG9c53Ltjg56svJJIY8=;
        b=Kw3MOtkcTaW2dY2U4wv1urO1rgW3CpyRne3b7i4YtuEuCHhG27D/hSCRY88fKpLtgs
         7wmKLQJ3ReZtgHrGDmf8YlsiWraxvynSIRfYAsJsmsQmYqEUQcgAVL1sVqs5rQzcaZcu
         qU93fbbj5wzdqUUVKKYaiLsWt7uYLrooRvazuaF/GM7UzFc7y8VRkSovJ6436Bp56UAN
         gVIw2UO6kh1A5NT9tr1x8ELiZsZPq1KlJGtCHE08MInp6p4W0q138SUWVAlETcg52b8L
         MWYE3SSZ+n4ve29RqTaabbk+HF7U64dCasyxTlRXpQ62Agn9s3U8FFheMKeQ8gQ4QOTU
         sh2w==
X-Forwarded-Encrypted: i=1; AKwUvBwX8WJsP7ZO/Y0CNSeZm3L4h/HxovbvTMxJi4/0azrL0z9YBOsYh1YzPUFsof0A4mFt2A6bLB8+4al7maib@vger.kernel.org
X-Gm-Message-State: AFq9FYKlSduwKPmXBYzYJdZbn5kZzhjmv3vji1jffi0HKMZwwAz9yTV1
	edbS4Q4nDbeTHQxNqu2wtZnI9DIvtyiZ1Qckgmws8E/CriCMJfR0v3acMJx/B21pgwHTJxwDL9J
	9n2bkFya8ImC5PueBBLUsz/xMque0gGaCtpi5aaIBTtYeOp2/ZBmBrCKo1ZNJWezCNy0=
X-Gm-Gg: AYBFou1e/9SRq4LoIBq8U+txSWKxsEurwIjanWMS2SXRVJ7q8MsdiS2HMjgYHBIEyzO
	TPz8VRam01hKdxShev61JFSyn5v0O3yk16lUriXHjjdKlugX0lgqsbENDjpA4iBf+NOz+E7Eyfq
	QKJeNL8l0A5PGE8BlkYbZBhg7aCGjAmkoqmKPpGIDYqVBAmWPW0lZXzllnHZ9rv2NKurs5aVepg
	purWEUwVFXtKw9fivYRT8dL08f7BQtJkZfYXqBqRW9Mb3OqGh1xL5hf7f2hIDKhhh1EboOSxxn1
	v1eu6nUmysfb3p881E9hj0O9DLXOzOx1KfKhWkBBLgXGQL9r0rqcCVUKIIU2H7+PNkEIQxThc9v
	vb1gROlQuRkbbdnn2xQ3t97A4mFmnyb2KLU8Q0bbFNG/cVJ83EjmENqHlKe/92NdP3O1y8V6qS9
	KhBaZpGv4rSn2WTAjcSBIQyN9JdzEqYPzF9i4DaOsIT33UXiQjbJjA37xZdkyeOww9Mazi2EG7S
	FY=
X-Received: by 2002:a05:6402:3206:b0:6b3:b648:3170 with SMTP id 4fb4d7f45d1cf-6b3b6483f02mr6091840a12.4.1792500762150;
        Tue, 20 Oct 2026 05:52:42 -0700 (PDT)
X-Received: by 2002:a05:6402:3206:b0:6b3:b648:3170 with SMTP id 4fb4d7f45d1cf-6b3b6483f02mr6091819a12.4.1792500761744;
        Tue, 20 Oct 2026 05:52:41 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b3c74eb8a7sm2982781a12.2.2026.10.20.05.52.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 05:52:41 -0700 (PDT)
From: Alex Markuze <amarkuze@redhat.com>
To: ceph-devel@vger.kernel.org
Cc: Alex Markuze <amarkuze@redhat.com>,
	idryomov@gmail.com,
	xiubo.li@clyso.com,
	slava@dubeyko.com,
	viro@zeniv.linux.org.uk,
	brauner@kernel.org,
	jack@suse.cz,
	linux-fsdevel@vger.kernel.org,
	linux-fscrypt@vger.kernel.org,
	ebiggers@kernel.org,
	tytso@mit.edu,
	jaegeuk@kernel.org,
	linux-kernel@vger.kernel.org,
	kernel test robot <lkp@intel.com>
Subject: [PATCH v4 1/5] dcache: export d_find_alias_rcu() for modular filesystems
Date: Tue, 20 Oct 2026 12:52:33 +0000
Message-Id: <ad1e9d2c5ba4803f1c7dafc6687638b0489a7265.1792498351.git.amarkuze@redhat.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <cover.1792498351.git.amarkuze@redhat.com>
References: <cover.1792498351.git.amarkuze@redhat.com>
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The Ceph subvolume quarantine ancestry walk needs to find a dentry
alias under RCU without taking a reference. d_find_alias_rcu() provides
these semantics, but it is not exported, so a modular Ceph client fails
at modpost with an undefined reference to the helper.

Export d_find_alias_rcu() to GPL modules so filesystem modules can use
the existing RCU lookup without changing its lifetime rules.

Reported-by: kernel test robot <lkp@intel.com>
Closes: https://lore.kernel.org/oe-kbuild-all/202610171220.i77KPiw5-lkp@intel.com/
Signed-off-by: Alex Markuze <amarkuze@redhat.com>
---
 fs/dcache.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 1b1a81f10da6..13ba553081b3 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1248,6 +1248,7 @@ struct dentry *d_find_alias_rcu(struct inode *inode)
 	spin_unlock(&inode->i_lock);
 	return de;
 }
+EXPORT_SYMBOL_GPL(d_find_alias_rcu);
 
 /*
  *	Try to kill dentries associated with this inode.

