Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792528027;
	b=1oyA6Jl3E1wu78FoG+XR1xiTI/HnCIq7QgGxy+Kb2PoH3UXVTUBClxMrwpigF/9+8tAV
	 98GsJInc2go2/klgoWwamPBCnHGHi2dwX0WXL4Ir7+NgGguOP5dwR6gJieS2VtaDxaCWN
	 hpLgdeYWwF12TuTifEE4lu3abZDzQGht4xlwqNGkUxi/6IX5AcHIXgM2oMrG9+XDg/uQc
	 yMPhTgmki2MbuM3sf2TJ1sk8C4qRRqlDDA0yZRnwxzlfkQFc9KKvk1+UUIVw0jVw6rq4u
	 SB92007apZUkrxd6JS5yLcz9t51tJ6HVJzr5EmAGP/cuX0syd5xf/KXYosyeK+bjUbw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792528027;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=/eb/I1d03/gtpLIJJSwv9VD8j2S7RruxMe6k1xmmguU=;
	b=SDRxLFAuak94rM+3rjVVPy36Nj20vRsuv1TIg9Tgy6LbeH+CgPl3FBmZymwiVaxZTQzG
	 WelUe061CBjHVqZzcXmrn8BKlW11dSHJ+h6eWDpqH2ZD4WzH19C3eg9dH3zQ4Oct1KsI1
	 XSY0mYM5g0eHxgXOVKrQg6I2VV1AWcztnDHaWq9fG6RgwCBzvAp9zH188vEcEzTqoljMI
	 vmLV+9fQ0EGTbf55OjXT+V+Ddp1Wk0e1dBTKkPteVZG38F5zkA0SiNS+aMaUF70U6IJvf
	 qM29F1o9zZeaG1FmWFVQXXoZDbU0GDaWo1ZLcKsqMZW2oPO2NEEUSmAEEka2Vvd5LOQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=KjBtcODc;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b="PL/TEgYt";
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 101F9606A325
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 20:27:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 101F9606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=KjBtcODc;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=PL/TEgYt
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792528026;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=/eb/I1d03/gtpLIJJSwv9VD8j2S7RruxMe6k1xmmguU=;
	b=KjBtcODcs3nJbggHw1XV/8ddKA0OuoR/A+XaWxIb2b6qan+KpyY9XPePiqE6kMhOW5t+vg
	R+jTM/uzSLYD7P3LvtPQeoukMHwKhvE28EyWQEcBwiL9p29FI5PIgQ8+JhPgXUWsbF3+qL
	pK/s/hNP7yWbjCDT0BIc+dg6742FV9Y=
Received: from mail-qv1-f70.google.com (mail-qv1-f70.google.com
 [209.85.219.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-90-k_ds8rfkN8Cq4k9jAyMNug-1; Tue, 20 Oct 2026 20:27:05 +0000
X-MC-Unique: k_ds8rfkN8Cq4k9jAyMNug-1
X-Mimecast-MFC-AGG-ID: k_ds8rfkN8Cq4k9jAyMNug_1792528024
Received: by mail-qv1-f70.google.com with SMTP id 6a1803df08f44-91b529a8610so1811976d6.0
        for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 13:27:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792528024; x=1793132824; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=/eb/I1d03/gtpLIJJSwv9VD8j2S7RruxMe6k1xmmguU=;
        b=PL/TEgYtsmpwVYabHp5Gzx43TyRxZDYQcCFL6E3+JWQ28BKDj+fcpOM2mbzp3c9iYI
         4A7nmVWVPyaFXCCjN64EhkEDJUPY8Y3+8UYX2oi0T138zJ+oJKTJ60oa+7G4gq+/gFv2
         w7t311vSmLUwyicxUw69U5Mdofu/zeGa7Zodynn7HZHSwn7hFGI5mrhBHMBpi3cfrU9P
         OiNSIJ6EZwO3COTcmZPWIeX9MYf0UE/Z5B4l7kCH2PNe20g5E3Wfixy51wt6VaP0eVSK
         Orka+uKEqSQHbDlPRJ8LDHc+gprL50vyYloeRSphPxAMwez3YXxzqJgqaoL/g6OydAxT
         rl6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792528024; x=1793132824;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=/eb/I1d03/gtpLIJJSwv9VD8j2S7RruxMe6k1xmmguU=;
        b=ptJn6x/zVgpElh5PAkjpDJVSfwO41Au5e+3if/7upc7YYactee2O1iURCrnJrRjWuL
         05KprK+Uf0YuKwrkSO4K03mxuxXek8m+I0dWI0S9BjozaFPnzbrEjfC63wuoUAhs5/xN
         9Py7ekmOS+6509wR7O7PvQo7DWbv4mzGrjIhn7Izo0NcU8iV1k2OXQver5nywj2t2TL7
         4DAcyqPxp7jB6Udseh46AfChateXziUOnMs4KxcNaCh+XdxeZ3cdlX35q8a0SXnXlcXk
         lgHWd50HRCC+CEfQeOeSu1yBS0umNo+Tkj/pZ3ueMv/UcbuOcyXBWTnbpRMKOMCMjqC8
         PfeQ==
X-Forwarded-Encrypted: i=1; AKwUvBwc0meeuLnvZubC6jW4S5eubWa53fozCtN4jnjOYEfk6s8XF9BBuhdj/ZIlpR/jw35GyUm2+sHIHSIylnwo@vger.kernel.org
X-Gm-Message-State: AFq9FYKsPtbmdxnryyvwHjpECluJHfqLbandM8PrOwhz889AOdpsKrAq
	ChLo7oBBvPDVvCza11fkBg3AEzQqm9SJsXPiW8TtYTvFrGyXqqm94tuMb/eFUwRuNdYxDa7fXPr
	iBgo/5zmpKXZ4xtd0QG69UNxFxYp3A2XIiMXMintbn/LkVY6lus1G1SeTAVxiDPGA/2M=
X-Gm-Gg: AYBFou1CYx8Uvu07TsZ/6NTnYu5yGuBOtMB3npU6OENo1JR5a0X+hRjIQfryg8zMe/I
	/HBdin20sPa9pZJp9lY6yNFXIB35jSQR1076ozxncfQJN2YE13swyq5DzpxJnIMdxN3FF1m58I+
	ous8DETi2F6/2B0bsB8vF2e1Mr/Khg/Jd8/BxOj5fbcVyed0t3plx6G+yILY0EiWkUGY11qasJO
	kfsbcPMWx+OptqmpCNT/PKhOpk0jCTt+ofHhbRUKpmEJrguAHB7db+5jto7Iwl/lCx+rg5D7RZg
	rmvXw+lvuRwoSJXS4t3IfVwsys9VOWs/p/hZzmJrb2WbIDz+a7MWjRZXvNlebNYPnzRX6duw8DU
	xTyCiR/HxBRAS5lazNoya9HSpOCJ6xlE0dgVAxLSy/Iyu53VqiFj3GY54ZVP6+hwoN00rkvLpWL
	R+9YCs4KqL3GyoRUAsQEhv7pvvjB7D4sgD4vMfenZ6dQaYXE4v4W/G6ODHoExE8RwZjl9YYEp6z
	QQ=
X-Received: by 2002:a05:6214:8414:b0:91c:305:a955 with SMTP id 6a1803df08f44-91c0305a95bmr51463526d6.31.1792528024198;
        Tue, 20 Oct 2026 13:27:04 -0700 (PDT)
X-Received: by 2002:a05:6214:8414:b0:91c:305:a955 with SMTP id 6a1803df08f44-91c0305a95bmr51463206d6.31.1792528023567;
        Tue, 20 Oct 2026 13:27:03 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91c10a45336sm7461436d6.3.2026.10.20.13.27.01
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 13:27:03 -0700 (PDT)
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
Subject: [PATCH v5 3/5] ceph: add subvolume quarantine wire definitions
Date: Tue, 20 Oct 2026 20:26:48 +0000
Message-Id: <774d53d774a44724c2ab8876a28cf51247bcd0c3.1792527529.git.amarkuze@redhat.com>
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

