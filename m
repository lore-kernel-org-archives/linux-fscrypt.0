Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792500775;
	b=k0KdxXnmb4Ew7JZt/9n+q3NN3V2GXPNCCC62O1K3s4oYqbGi/CD16VehSFJsO37SObik
	 CdJ/PHg7swvot5bWcynKsz0vB7kcnjmvKHJ+zTfDFmHKB+3BOKGbJwPTewV43ktfukF39
	 iiUPmFZsHb1LxmvFABey6Q9w6iSb20LHx+FuiUrqSt25mh1wMWkobH0Ke1eeyImtOTFwC
	 PwdQPn981qhYBVVHWyu/2/RFfvVKb+QilolAqMx6kYOjYw2TafVkDNIu1g6FhkeLpIxM0
	 hBrUjpH8eya6LspBxwwxVR4Lw8cg9W26f90PsC2mXOExcwG3RKqlsZ5Ip6+ZjU48jmw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792500775;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=/eb/I1d03/gtpLIJJSwv9VD8j2S7RruxMe6k1xmmguU=;
	b=FnIKOIC9FSEwF3i0gYVlUh161wxHSfaQi54Xm3XkywW41IiLOr7i//ld/VSa4Ksmoi8x
	 LdLZyrtrHunNwbyiDGvQqPMADm1RTJAdakD9kg+0CITeaftLSZX41pcZOugiTx1p6iFuC
	 Jk63W9ZhGv02EY351JMZzMXhDjatUdS1BwEXp5haHxf7OaibUY68foJTNBOxP2B1dc+sk
	 jDri2bLBAcijApj6x1VMOcBTV/YkTLM3AgQYQCVeQP1CN2N8q82Ay9Vz3waDXE4HIhMjO
	 4oy9vf6vLOO0nj77OG5KMvNdYjVgLFpyoPdNbAnQcu5ABPdSsUIKNcillhQV0SHtmUA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=YtIABNMW;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=Sxz25ht1;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B06060A4AD7
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 12:52:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8B06060A4AD7
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=YtIABNMW;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=Sxz25ht1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792500773;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=/eb/I1d03/gtpLIJJSwv9VD8j2S7RruxMe6k1xmmguU=;
	b=YtIABNMWHtF0y0IIpB/sjSofTEqQkTZdV05HrWTITHh/ZTzc3cR+9NlX3+/tA6ODHPiKdp
	+DmaiyoH8FFW6JWWfJpOYyVJNfYJ5cspQuCxJUpMkSvFWXkqmFQPtlokM2dT0BOuIokhT2
	O4om2wRaZ/Y2GmR4VDptNzYEsowSHvc=
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com
 [209.85.208.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-209-fdqfWOjLPQm4p5L50V61ig-1; Tue, 20 Oct 2026 12:52:46 +0000
X-MC-Unique: fdqfWOjLPQm4p5L50V61ig-1
X-Mimecast-MFC-AGG-ID: fdqfWOjLPQm4p5L50V61ig_1792500765
Received: by mail-ed1-f71.google.com with SMTP id 4fb4d7f45d1cf-6b1a4c9eadeso3108672a12.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 05:52:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792500765; x=1793105565; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=/eb/I1d03/gtpLIJJSwv9VD8j2S7RruxMe6k1xmmguU=;
        b=Sxz25ht1Di0z0S0fBCiVHyEB+3U8FDm7nOw6Dp2jL7y/hbR6XGpeZLHl4bYl0D43KI
         tAnRtDQYY3auDzClqzE28MPikFSPaYWUMQJENFSFBcmqt4Fhe+mx0Uolc2+nhLW6B81g
         fiTiHFeYs74ZT+tYm6/6pV9vJE6yKouKnm/NSZlkDlQhDL98LqrfbRc1GQ3kjcoBvbPh
         9hskZZD396IG0fWkb1cp9u+MCrQCWMPmQou0fj6lr5WcyTaWCWShgY3fZk60RxbPZULd
         OFdrcP1TBpDVJZNLjDFkgykxyQ1Cit41kDMdhVr9mvia6KqPTGUy+wFQygToifbBaTAt
         I/bw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792500765; x=1793105565;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=/eb/I1d03/gtpLIJJSwv9VD8j2S7RruxMe6k1xmmguU=;
        b=EWkhDkANup3WlovzwOAt3UohM4vODWTX0kaegvj4fBm1J8LVMku3npoDh7qMjMgzfF
         5rE3wLA1wOQjLJwsV6xDH6I+eJ77X8Tz1FqA8+UtH56RRgKSIwPw1lUH96MwfVK3INfO
         1AgBLn7oA2yxiR4rP0zkumNtjh7dNIpLFQkbzYMImvwO64LUebhgx14DgrcHgQd1BliQ
         MIt+ae9MuyglvzmTgWT9stpeUofJNjsbHuIqTHPoW2F0spNN7+R8JXHjdIEzjyd7hE2Q
         AK8h194AS1qZ8h04+s6CgUMbSxD5bIZsOPgkKgl3Zja2W+PXAFzhrr5El7Yx856m9io8
         6P+A==
X-Forwarded-Encrypted: i=1; AKwUvBw1k67iiyFrVpC8BMnnWMsBmJvzIUWoSRKIlXBKgm84CAW56s/X4lcNUURX7YTl3O45lNqurmVTVPv7Pizh@vger.kernel.org
X-Gm-Message-State: AFq9FYKZU+UNThq0VSbfV68VB6W7ZMnvboptfwCB9ANxVUwhMhNE3OzR
	O1HbM/TBHgXEb3apaeU8PIOiUFzirtq5qvOSzlwYkluT1hOEEp2dl6DFtpz85fUz2P7PYG3Xu2O
	3fdJ2RnLVNbgzVIErpGSVJQMzzLfG48hGWd+BgfFMCbsveN4A4Nju5LgU7i2ZTfcL8/0=
X-Gm-Gg: AYBFou1Jy/PPC4/57kB2z5k8cFTaiOGF15F3hsmZpwxV+w3CR8iveklPqIe4m3bN70k
	cURMRLZJ8LnJSWoj2+EfvbwHQWA33+mhjTNOSnxv70z81LOqeGQKlZjIGYUsrJOq+KCxotvswRz
	jclEU4Cpc94K7kiGKyNqPXl6TBT6CKw/RpO5lFSQgbPF54i64FO1CfUkv+ytPE/WflxphJBbHEc
	ohYHpSiyjjPUxbdIDPBZzfRDF8h+f0IPJJLo4CvAqueODhRIRIQ8AhZhTqfjeRB8fT7lE0Ze+CM
	rfpo8zkPDKDdblFQkfT3Aqo6ObgTvPWw42yPohSVNpsM22hy3ajT3Lb0YXBv6MMThJ8pJ+ylKUF
	oq+uhD5t+d8JaMB8MTcu9Ei4bDYSDPdG24Yk7FGb5sKxDBhhIr+qehoTCYVvOu+UMUgSAqZS2kz
	/+UBTwiEWjDUQQwNvEaVCN9ROltUSomPotHE5hCqS8Kty+pG+O1Et87Q79fIxU8t3qsH+5b34JO
	ls=
X-Received: by 2002:a05:6402:1ed3:b0:6a9:9766:59ad with SMTP id 4fb4d7f45d1cf-6b3a81d9dadmr7485387a12.43.1792500765108;
        Tue, 20 Oct 2026 05:52:45 -0700 (PDT)
X-Received: by 2002:a05:6402:1ed3:b0:6a9:9766:59ad with SMTP id 4fb4d7f45d1cf-6b3a81d9dadmr7485370a12.43.1792500764752;
        Tue, 20 Oct 2026 05:52:44 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b3c74eb8a7sm2982781a12.2.2026.10.20.05.52.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 05:52:44 -0700 (PDT)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 3/5] ceph: add subvolume quarantine wire definitions
Date: Tue, 20 Oct 2026 12:52:35 +0000
Message-Id: <774d53d774a44724c2ab8876a28cf51247bcd0c3.1792498351.git.amarkuze@redhat.com>
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

The MDS revokes a quarantined subvolume's caps to PIN and reports
-CEPH_EQUARANTINED in MClientCaps v14. This wire errno is 1000 and
must be translated to EACCES before returning it to applications.
When quarantine is lifted, MQuarantineDisable identifies the inode
whose local mark can be cleared.

Add the errno, message type and packed disable payload, and teach
ceph_msg_type_name() the message name. Advertise the session feature
only after the client can enforce quarantine on cached access.

Signed-off-by: Alex Markuze <amarkuze@redhat.com>
---
 include/linux/ceph/ceph_fs.h | 13 +++++++++++++
 net/ceph/ceph_common.c       |  2 ++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/ceph/ceph_fs.h b/include/linux/ceph/ceph_fs.h
index d70bbce1a1b2..5afccfa891cb 100644
--- a/include/linux/ceph/ceph_fs.h
+++ b/include/linux/ceph/ceph_fs.h
@@ -154,6 +154,7 @@ const char *ceph_con_mode_name(int mode);
 #define CEPH_MSG_CLIENT_SNAP            0x312
 #define CEPH_MSG_CLIENT_CAPRELEASE      0x313
 #define CEPH_MSG_CLIENT_QUOTA           0x314
+#define CEPH_MSG_CLIENT_QUARANTINE_DISABLE 0x315
 
 /* pool ops */
 #define CEPH_MSG_POOLOP_REPLY           48
@@ -921,4 +922,16 @@ struct ceph_mds_quota {
 	__le64 max_files;	/* quota max. files */
 } __attribute__ ((packed));
 
+/*
+ * Cap oserrno used by the MDS when a subvolume is quarantined.
+ * This is not a VFS errno; applications see -EACCES.
+ */
+#define CEPH_EQUARANTINED	1000
+
+/* MDS -> client: quarantine lifted for one inode (ino, oserrno). */
+struct ceph_mds_quarantine_disable {
+	__le64 ino;
+	__le32 oserrno;
+} __packed;
+
 #endif
diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
index 67e88f30409d..cc3d21fd7d5b 100644
--- a/net/ceph/ceph_common.c
+++ b/net/ceph/ceph_common.c
@@ -83,6 +83,8 @@ const char *ceph_msg_type_name(int type)
 	case CEPH_MSG_CLIENT_CAPS: return "client_caps";
 	case CEPH_MSG_CLIENT_CAPRELEASE: return "client_cap_release";
 	case CEPH_MSG_CLIENT_QUOTA: return "client_quota";
+	case CEPH_MSG_CLIENT_QUARANTINE_DISABLE:
+		return "client_quarantine_disable";
 	case CEPH_MSG_CLIENT_SNAP: return "client_snap";
 	case CEPH_MSG_CLIENT_LEASE: return "client_lease";
 	case CEPH_MSG_POOLOP_REPLY: return "poolop_reply";

