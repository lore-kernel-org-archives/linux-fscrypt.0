Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792528022;
	b=Yi68wRC7z0AIpu/NZzIWlVZZ6fcAgTPvemdseF6B/09QlW8wVgDNd91WcJlsMc0+co5d
	 AGV88QcR3EBp8SThmqKhbHYLiEV8WJlYaMpTSBEMyo8bkCbG3i3N9KVWsIpirOa4AQpre
	 FpZW4QUG++KftuP3rWAUXhzWM7rUCc+Ge5Gc+zhR1qOmgvtt2mp6fSKoktSfCbFBrYa28
	 NGpDYq6nfbQD6RD2Eie3lg6yoANStWwXgXsGzVJP11E/pZaiKumpfIIICcGBMzabaYLX5
	 2+sS3IZ3a/EYHcBTVts3AAGxUtIbKo7hdM3hbbFGPIWVofwZSHnxABzt0QgXRGzXzHw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792528022;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=RRNHwuzxK2uMbz7SC9yJ7WKgsG9c53Ltjg56svJJIY8=;
	b=GKckXsTjFTnyGf7htwX7jV4cmqnvaABvw6sCoqMfEOwTJ3+W3X6/mDQ0Yg+pesBdFTUD
	 z/w+H27sfqjaKKUvwnnUJXC9px1atPc0B6WSmzKVIaOUDtn/jbd+YYQtFYE3Ghk6o3wlI
	 bnC3ncQz+s4acMRb/mmjylat7P3EpC4Y7H3iStxlU+QaoGcWEVLDSE7+ZtWInBzHfUzaT
	 Qtc6E6vpXkRA/ah/rTDGMduQ/vkifv4qBUsaTE3+DeyC9L6+46Mh93MYO7ci6AcQW479z
	 9DDWb666PQM6OSs3u+hW7zMZJ8UsoSkRoHaTrR1BZ3f+vJ68onPhWulC8w2WoF6reYQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=cBondb5e;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=qD38TerE;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10C2F606A322
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 20:27:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 10C2F606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=cBondb5e;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=qD38TerE
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792528021;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=RRNHwuzxK2uMbz7SC9yJ7WKgsG9c53Ltjg56svJJIY8=;
	b=cBondb5ewmwkBTgocX4KT+IRAcWkpnglE2k9a+guhzkjL0l3HiGU3mRRKnoqZBrww8KRfm
	p8iQr22VI04YGdeVb0gvuLiGWNY/6OdxGx4KWa0qow4pNOjbT1/Ykmid5IEoNfMhCiZEtw
	1LX+sg/XaKDjbWK8junLGu0B8pnfhYs=
Received: from mail-qv1-f72.google.com (mail-qv1-f72.google.com
 [209.85.219.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-612-LWHDQINeMeWQdaYofl1emQ-1; Tue, 20 Oct 2026 20:27:00 +0000
X-MC-Unique: LWHDQINeMeWQdaYofl1emQ-1
X-Mimecast-MFC-AGG-ID: LWHDQINeMeWQdaYofl1emQ_1792528019
Received: by mail-qv1-f72.google.com with SMTP id 6a1803df08f44-91785bd637bso2807976d6.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 13:27:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792528019; x=1793132819; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=RRNHwuzxK2uMbz7SC9yJ7WKgsG9c53Ltjg56svJJIY8=;
        b=qD38TerEvM/xhI2qcwInD8LEBlNiS/MBERmWwGQC5j/F3NqlwIYxOxFx+IhZPtkzkN
         ENXcCbTXRt3YC1+TsNbtx8fk1Wa/YWXLzTMop0W/2wJp9WXUFWddex/QXJTAsa+5Qw9H
         wOuqxeg5sOeXSxlF/KGmhV5KeTmXP4BTJ1Jb8/F/WP9JIqLYi37WziXseeVZrgNx1H0g
         PUME3/C8kIsuYH3WTKEHidYhfPHMGK9/dymDN3G6qlRaAG3PUPlxfXVijFuf0oNiPsXJ
         BCHRJ9iMD1Q1YRPqw306mNMcy0AgwRjMaLtlodFe8ueKeSqNptMuj2UClBSMSVMSutHG
         4JLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792528019; x=1793132819;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=RRNHwuzxK2uMbz7SC9yJ7WKgsG9c53Ltjg56svJJIY8=;
        b=HqK6EAziw0g8DRjFEFgVxRmIP2O6ZFOjfixcxpUPmdy3vHqzxR2TWLWk12+0Viw82m
         d5vAm+eQh9u8XqeEGwknlUjlbCyTaVaQtbT5is56JpgFpXywDrvlQydL8Z6OQCDM8Z/U
         YP0BD6+rzqu7pcco5ZwVQraA1bBJGbu+0+qDUQ19IEjWC/Z2n3h9dYC+PokY3kDff5xk
         oymgPq49ScKcSAKYMXtTZE8hU8WjoqdpwWTt0wF3BNi3ac0RfTEi07ir9tHS5DI9CC3R
         aE/d/F61exNZ2s//wGGIUuwd9fmNJa6mZiM5NlJBZ+h+PzIyDauR38PFBtBiDZo5HL96
         4FBg==
X-Forwarded-Encrypted: i=1; AKwUvBxvIzjkNG+4GpFmatEdsM8k+k0rM35sISvXKjdT1yAKuwlgvtsN3LSvPM/xbP3M8mHxCijz7VyeJDkemBpb@vger.kernel.org
X-Gm-Message-State: AFq9FYL6oVm7CFg5xU8J97LnuK6S8uo1G+p+q/H7lrDPB+rj5jeetZvX
	s1XpI01eerNnwIU9w+ci3EKQWUVv8ZnVESugBaE5uEJxh3a2eIfalyozq6MFuxcsmnA4ybY/SpA
	c5HOHwSZEaviLUgaVgQRh/JSoCThA33CNU36z4M9OQ93Axmlk25ssj8mf+QALA4ra1UfJzJ+hBq
	RcFQ==
X-Gm-Gg: AYBFou00EBcqIHW8HDPRfez0zpxPuOkuBxrEoSstK/4FNkdAZpaLy6r9XC0SqGUHS8Q
	H5iOOuAgic1JI2RQc6cboe7E4vrnoD27enENXVhkV1ARoM+uyVmxsbcPv20INJYUUQOUpGnQt6t
	e4B3zJ4/iHFwhphDlQlHagGnpCP55dsa1AdVq2BE3rkit7L1RfCAhy9qIje61j0q/61pG66ZYpu
	65TqIkH8/wkmIfV5hkhmG4MpnML4neC3a0NciyFhLZqLzaTox3EZpKM/jFV2/nxH2i1PJinJPiD
	sdgTJYeTLAmp5i1/z9R9y0hjmIw76jkeuMrzc1uXu/0mVLDBfZO4XWoV3/kg7iVBhbvBtUbM4JJ
	kcRB4ilCUfBr5NFu8cI3TSc2nxNf/KXYTUH3DiyTJS2B7ywQ217RKR2p8+w6Wfrsd0WolA6N6nM
	2+XzaS9RAoeIM+KC6V9iVKB4CmvIaftczob92Nrl4xZlfGN2dtUnvBG4F/O6Ila6g6Xpg8mJgIf
	xc=
X-Received: by 2002:a05:6214:6107:b0:91b:f9ab:3944 with SMTP id 6a1803df08f44-91c01f39390mr65133176d6.7.1792528019298;
        Tue, 20 Oct 2026 13:26:59 -0700 (PDT)
X-Received: by 2002:a05:6214:6107:b0:91b:f9ab:3944 with SMTP id 6a1803df08f44-91c01f39390mr65132696d6.7.1792528018761;
        Tue, 20 Oct 2026 13:26:58 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91c10a45336sm7461436d6.3.2026.10.20.13.26.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 13:26:58 -0700 (PDT)
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
Subject: [PATCH v5 1/5] dcache: export d_find_alias_rcu() for modular filesystems
Date: Tue, 20 Oct 2026 20:26:46 +0000
Message-Id: <ad1e9d2c5ba4803f1c7dafc6687638b0489a7265.1792527529.git.amarkuze@redhat.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <cover.1792527529.git.amarkuze@redhat.com>
References: <cover.1792527529.git.amarkuze@redhat.com>
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

