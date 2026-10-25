Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792953775;
	b=fvJpbjZB/Vu0VZlfAkkOZduVVM9VjRZ+Y9KsOvGsS/PmF+pvTdcNehHycLRnCd6+Kgn6
	 W3/48F+FJj0wNEQTnfnyRaHR5UEjcMsDaSQUKwcaoKBm42k6qHTmqgn0wqwOL7Sje8EYR
	 Vgb4QGctajueevtjxNLTNUNWCVF+c1m2aWkdnxYaqjND413mbJBm5IN2LnJnqDwb/tjuS
	 UYs3oiwpA+ntjtEzutOiQa4U5KEpANmVjzWj31yCHWFEdxlCK/U9JkSZ2nMmpGUmtoT7E
	 eZQYtzzIkYz/p4sKKlNX1UZXHCtb5Ys9iqzBIWsv33frlsxSOm00f8wWm4L8DQzKSJw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792953775;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=6DaWHhYgIwuBxobGINB7MVgdVFMWECs1oxNBivuWWWY=;
	b=u/eTDF6duG8XEaAjFNZdS0XAeA2pbb9L4xv3kkJNVVpAEYdh74KQnvG3Z0+IqoTx+aG9
	 urmMNIa6XMtmmhPZFukgC4KDcsD8moVcOzhHRvnGlP663vf0gG9xRXeqjUI2LUhTQ8arK
	 8qEpHOicqFiONfI5BoGVhPke3qTjAQcAU7Gdy6BhG7+tVJqXPMV0kz5GNGCgzO+cdrZB6
	 /hnW77+sT2rIL7/zInSQv/mjM+YmSRhdalkxQ04MOv85XGqmp7sATmIvbG90r3WjhGS+q
	 BHNWf1FB37bk1dF6BgnlNpF6IZrfLNooCfWeezTZVQfJjq182OHHLZbMtwNASnzIjZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=PWzM30nI;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=tVnVpHje;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57FD4606A329
	for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 18:42:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 57FD4606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=PWzM30nI;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=tVnVpHje
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792953774;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=6DaWHhYgIwuBxobGINB7MVgdVFMWECs1oxNBivuWWWY=;
	b=PWzM30nImfpG/iYmlCpzvUYdOQQmJ4iNaTraeXXtwlzsG1pjPIdrAxO09o0kTImphRedTA
	+RNYSqx2r7jmA5NuCp6P0VCvtbk2BfTsltESCVfx3xwbfifSTUJ36shfqsjJ6tI1w8SAZ/
	dGg+wEtemjMOCf3+6mrmKe6S1hXJPQ0=
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com
 [209.85.208.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-31-OPCa1YhxMmiDLgo5cKI8kw-1; Sun, 25 Oct 2026 14:42:53 -0400
X-MC-Unique: OPCa1YhxMmiDLgo5cKI8kw-1
X-Mimecast-MFC-AGG-ID: OPCa1YhxMmiDLgo5cKI8kw_1792953772
Received: by mail-ed1-f69.google.com with SMTP id 4fb4d7f45d1cf-6b20352f43eso2259880a12.1
        for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 11:42:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792953772; x=1793558572; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6DaWHhYgIwuBxobGINB7MVgdVFMWECs1oxNBivuWWWY=;
        b=tVnVpHjeJHWyc+4qBdBCZFpyXKtQY4eAqsiMZ32EjZFUTevWDLdNiNvMwSwpfIZGg7
         0wQb9lkF24BqwSHlNZfpqN0jPnNfPUnVpvB08ltclv2mxaLFcvMtqHP1dhyaU9eX9sAX
         7O4z1F26ZAtUPBq+TgPQT+X7YLevSZcHfr94BeZzxkJ9pKMxS2ErMgN9pEbE++DZK2nz
         aGwWuJch/RvcmHsf17XC9mKCzkVMcsphXS64TpmJajUWE04Jl6gN8Vq8Zo6b6VChSUBK
         ooaxB/hv9P4UaA0mY3TzMUiozKiJR2gvM5B3VkkQ3i7Sm6JWmmDwmzP4b6/VcPfRA+Q2
         xxnA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792953772; x=1793558572;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=6DaWHhYgIwuBxobGINB7MVgdVFMWECs1oxNBivuWWWY=;
        b=f0GqdXaliVMpH8NyuuT0DXoOynBxR1UOqpfHeXjRxriYnh4AbvsPD0EZi1g6XAz5iz
         voTYcq45UYUj3wkeqEz1meZ5nBCxKEZAo5zWLXyxwo6VfMNmwGjgsGf9EaOH68GRXB0P
         gmS/BGcUgBMAZbEn9dlLla19umXfXSTjFi0ra+kiqoqkcDeWPkEob8jYd6kTQvOyV3bX
         2wJJqHe8KWbHcqZmcP8MI8f91sw+Kvquz5clFzoOVNctdnQqXIPHz9zm27/JDtcyV6db
         +65o66RearhdCc7ZXxmACQrrWFompXNYt4NaWqCKKnX2+sSqPHwM77OFTb6uibBqIN+2
         bS4g==
X-Forwarded-Encrypted: i=1; AKwUvBxDqOAMlGwK/3nRqKdHw6rk0kTXTohXSOxyCtZrJ9I3rLRnPcAVvfw9zmJvRxMmpwxTpR1n7TDYOBtX8+lK@vger.kernel.org
X-Gm-Message-State: AFq9FYL7ncECFg3RBRClexTZqtM6/69tel46QuAH92KfvwPXvNWILyPJ
	/P6QuK1di7ya/dx/eqqWosQDvNjJERQ1NpIZjxSFmgvhplLlOABpwYbuCuSfrM/RFAqDADLD+Dz
	5nZjDjP7+kJ/C1RfeP5mg5jTgtoc32GFp9GImXd5Pt0vXk6WJ2xprtjgB9WtyPOhhgYU=
X-Gm-Gg: AYBFou2UJ/k9f2GuXfIvLsaRcPKIHF4LYDgmf24zFuN8hRnNNYLnJFGbW0gYGk698sW
	eNgTAxBXFQTt13db+Ta0wKoi4KDEk6MfYdacWNwLAosV7zJNTHfNExGGLojyPWj5yi01p+LiHay
	9YFlyxRoCf7PVwbO2Dmc8tfM4HREkjgdS8VnH99E6hIa03W/84r9nmHFQqyaMCALqSHFjhdHSTa
	VvWZkBtGC7FY6Tnqvx8rxDpcvLFN58U+hgtGtl0PTfe/yGaCeT+VUEEZr7zKFsuxdWk2olufzAk
	acyhxdDkpRIOFtvC933Kq/8L5F1qBAAIrdHj2ANkEKVQDa3yUQzMqbbkv5/P5ySVE01FaLU/M+l
	PMezCdC4YqFCG+dolFp8NxqpvxqsTWyVGG6faPu1sLjtMaFn/818N/C48Zyza8HZGX/YeG4+Te6
	FskmnKGO1GYVdqQglXSgbHowSgSB2A4GxE5ea0RxHn2ouceFQrLIHOT+k2mfWA72MaHAtv3/tDc
	e0=
X-Received: by 2002:a17:907:3f8d:b0:c3e:d0ca:d30a with SMTP id a640c23a62f3a-c46be3866c9mr565911366b.4.1792953771996;
        Sun, 25 Oct 2026 11:42:51 -0700 (PDT)
X-Received: by 2002:a17:907:3f8d:b0:c3e:d0ca:d30a with SMTP id a640c23a62f3a-c46be3866c9mr565908566b.4.1792953771631;
        Sun, 25 Oct 2026 11:42:51 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c46bd66e51fsm230750866b.64.2026.10.25.11.42.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 25 Oct 2026 11:42:51 -0700 (PDT)
From: Alex Markuze <amarkuze@redhat.com>
To: ceph-devel@vger.kernel.org
Cc: idryomov@gmail.com,
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
Subject: [PATCH v6 3/5] ceph: add subvolume quarantine wire definitions
Date: Sun, 25 Oct 2026 18:42:43 +0000
Message-Id: <63fbc27fc8339ee0744d4488016d76cc2cc73e08.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <cover.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
References: <cover.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
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

The MDS reports -CEPH_EQUARANTINED in MClientCaps v14 when quarantine
denies a client's access, and restricts that client's caps to PIN. The
wire errno is 1000; the client must return EACCES to applications.
MQuarantineDisable identifies the inode whose quarantine mark can be
cleared when access is restored.

Define the errno, message type and packed disable payload, and add the
message name to ceph_msg_type_name(). The quarantine state and access
patches consume these definitions; support is advertised after the
cached-access checks are installed.

Signed-off-by: Alex Markuze <amarkuze@redhat.com>
---
 include/linux/ceph/ceph_fs.h | 13 +++++++++++++
 net/ceph/ceph_common.c       |  2 ++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/ceph/ceph_fs.h b/include/linux/ceph/ceph_fs.h
index d70bbce1a1b2b4ffffebe896ef46eb6853ab354b..5afccfa891cb045e9784eda1cc4741749aac4c06 100644
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
index 67e88f30409dd3ffba9dadb6fda529f4101d830f..cc3d21fd7d5bf251bd58ce19f8c7d8a5b02fa1d7 100644
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

