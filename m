Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792528032;
	b=dsXo2rAfIjoH+UlQSvzkPOuQPXfQ9spVlhlD2j6fkW3ZtZxV2QwVj7HsKDyOvXhKImrK
	 epU4x0gV7GJWNzYMv0JE0BnP35C9/SzUyG19F2Np/HRylWNDf/p1vwjKyKX+VJR44wNrB
	 Bn0sXPO5k1FQwhdDwrLeXMvD57XSOQlecSVjGlQCGxMnZqH5O2iYA/ZjdGGW455MRLrv7
	 MiBODl0keIyM+YUvP+kqTYHVcp9gGqfpt/6K9jcv3gCNbmdz7y9AzYw3Qdb83ybo30Uc1
	 FG6ss8kUx5MI0SUSYaN2qkdQ3J7F54WvZoH96KTh5nJaP4uJF3cU9wB/iYTaJI+cpLA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792528032;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=NvN/9rdtCqBm0bPLQHSnHrWV0GBxmaW3XHbP7+iX0Ck=;
	b=sdyQ4A6LzHzTG1YgAkVrWrwyJjKPkUwifFlpQxOZaNfGlOfAAkeKAlnC3TXjgtTLTZbc
	 PPM29U472R5Ypfed9Kt1CmyNXDvdq/SAcy5fmJor05uioS789jHYmV3YSEkPJXPIaaLfx
	 yyh3EBTPOBEOh7uommBrVZUxDMI4kfk+rCe5//qFbLJWsGM6OdBi7/RRZB5O8R0vNpzDP
	 c1Xss1L5G9JH7nBQOhCyyKxdq0HJvDtyWvukmyfFN6rVzE3LUzCI0N9/PvppiNztczZgn
	 oh17WWrhsyvr7qivUoeJLuDc9Af4sUfyY7KA4ZlSdGSvky+EMfeKC4PrmLoaJxJZrRA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=KUnAAeTd;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=I0Qf2bW4;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D28D2606A319
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 20:27:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D28D2606A319
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=KUnAAeTd;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=I0Qf2bW4
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792528029;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=NvN/9rdtCqBm0bPLQHSnHrWV0GBxmaW3XHbP7+iX0Ck=;
	b=KUnAAeTdZc0Nmaw/NPidVUqqtHcCJWGSOo7MkjBEE0XnGFa+Qn03Dx1SYJqm7aZzQKRsdU
	UZZSZ7ykROpJFNguRlIIxpUy/y2Khzvp89Z43r6cr3DXxPy+c8z/kc41n0BVepQw/+AQ+1
	8wJXcRz/MffSmWerMcRuLug/vGduukY=
Received: from mail-qv1-f70.google.com (mail-qv1-f70.google.com
 [209.85.219.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-361-2jSzXRVbMpqRLdma56KgXg-1; Tue, 20 Oct 2026 20:27:08 +0000
X-MC-Unique: 2jSzXRVbMpqRLdma56KgXg-1
X-Mimecast-MFC-AGG-ID: 2jSzXRVbMpqRLdma56KgXg_1792528028
Received: by mail-qv1-f70.google.com with SMTP id 6a1803df08f44-91c0f73807eso1712576d6.0
        for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 13:27:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792528028; x=1793132828; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=NvN/9rdtCqBm0bPLQHSnHrWV0GBxmaW3XHbP7+iX0Ck=;
        b=I0Qf2bW4xxoTSlMwl+BzmarfrRJivGVNz2ZU7T6/bK5Y1z9rH+c35lkUYpRhNZvfj7
         XdhLBSWAQgQzX160r3VjrCoSXYMAxK+IlPBde1wBLjwIB1WFOGTnPQAsfZruaTLNxXn7
         RPUY9W9HWb7nnhma5RmumEQnhpD0v0HkD5ZHCJ66Ze9ToeXROv26ce0j+iCiW2cr/HWJ
         DVQrMl6/MfQ2QIzOExO+rNiFHcR+tgi8Zqz011YGHmcxVM6CIMr4Uq2OxfpZYoc14ySc
         rcT3FSNMPGQrhDDIRhzAvHpJsPwS2peKdiaeme/kcoMv43ahF5rmJvmIu46sAz2c1Oec
         5bkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792528028; x=1793132828;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=NvN/9rdtCqBm0bPLQHSnHrWV0GBxmaW3XHbP7+iX0Ck=;
        b=m8wSg4ZFejyVcOob5tiSJ0LqHlXjpSIFgOasFqL4Q48Tsj70NnuZtZsFQ1t2Pr9iNC
         3fFfSasvU1s/hvP0jy9SHWdObg6kNYGxX3uS/Oz0HS9nmDml2SnMGAykKvv+ShqPaCBh
         IWAU3hu0fTSBaA2x3DaseiFNoRWyY12NlDXVH6StDd8i0WExjcls4HWugshFvXkZ9vxx
         Y+PDYAR6qaioZd42fjoZRVIJinlEOprkhe3Ig0egCnnLN0oc373eVw1eHgnERB4nVfhT
         ZyTxMwlvcDHdegbitJk0OOIQaRopY0ulmWttPPGuvbiI9yb1l7AWl6rsmrYE6VDc6VpF
         WzLw==
X-Forwarded-Encrypted: i=1; AKwUvBxaX9LRrkP5MICZ06FgSC5eH0yx17jmOngytCOIC+R1tI4rVwO3NfvaztkdxfUSb1mjVP6e7XHhN6mumM/G@vger.kernel.org
X-Gm-Message-State: AFq9FYISoU25+rW9pv28ukKbmPGPGW/+Fu1NH3VYnpvPCIhHZX21Kj0e
	20Gb9rO/yLe5nak+XDlFk9ZDDSd1OjzmWp8fQ0rGWKnmtEYAFIIvSdI9SedYC0POAOowRU59MpE
	4PBY6bLFtzONdc+M93Yd6lzpgPEDOCJ3uTvG78w9uBDWAjSsG4KCLGJdAWeuc9NkIsOI=
X-Gm-Gg: AYBFou3k2hcqnsn6UWXdClwQKqPRp0LaIzEhZeoOD2HG1BsaJkgJx/W4bDivEmSSHhK
	acN0M0tIabUws96KMf+oXj167oZI7d/NRve0+SKQZrVTWoa+izS6FEmJFM9O9mXX59Xa+qRon7s
	X/MSwdy+xio0WSwKYovmKrtWbL7gT+wLyUJwUWYPAQnr8MYwthe9LdC4WtuARZ48ZnsDoxjwM2x
	HKZ4oTZ709gGwjlytdoM/2feMctbWCAF7dImZvf/iR1ptKXmmfMFtV/yOe0gkJB1i9XlVQln1f2
	AbE90GoJ/ao/F16XUAC0vra5AF6ttONxm6alYUfjQkQ32kfxCfu9bFuVsYn6OUy2Tl5YWpZXxlZ
	dvG4dlclXSs09lUH30+9BvA+gNQXM7+jQ1oLYY65qe9hoGKtUux2jyl5+GUMHoCmT49K3RF6Gbx
	ydqoa2ORqiWJ4hEwzeQnRP/z+iaS7gjKk+5lW+ANf1P5dcP1SDokeH+Yhu8k79OL4WxOOq4oKuX
	00=
X-Received: by 2002:a05:6214:240a:b0:919:b4fb:eec with SMTP id 6a1803df08f44-91bdf1a4521mr228460896d6.36.1792528026957;
        Tue, 20 Oct 2026 13:27:06 -0700 (PDT)
X-Received: by 2002:a05:6214:240a:b0:919:b4fb:eec with SMTP id 6a1803df08f44-91bdf1a4521mr228459986d6.36.1792528026110;
        Tue, 20 Oct 2026 13:27:06 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91c10a45336sm7461436d6.3.2026.10.20.13.27.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 13:27:05 -0700 (PDT)
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
Subject: [PATCH v5 4/5] ceph: record subvolume quarantine from MDS cap updates
Date: Tue, 20 Oct 2026 20:26:49 +0000
Message-Id: <ff90b10c248b7f46707d0448b5c05cffe85a2ce8.1792527529.git.amarkuze@redhat.com>
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

MClientCaps v14 appends a signed quarantine errno after the v13
subvolume ID. Decode it and keep a sticky, counted mark on the inode.
A PIN-only update can reset the errno without clearing that mark.
An accepted grant above PIN or a disable from the reporting rank
clears it. A fresh metadata request can also confirm recovery across
ranks. Ignore older cap sequences when changing quarantine state.

Retain a pending mark when the reporting cap or session is lost, so
that later access must ask the MDS rather than reuse cached caps.
Wake cap waiters when quarantine state changes.

Skip ancestry checks when no inode is marked. Otherwise cache
complete RCU parent walks by generation; incomplete walks remain
unknown and require an MDS answer. Bound retries and take no inode
or dentry references during the walk. Invalidate generations across
renames and alias attachments. Sleeping splices disable cached
answers without leaving the generation odd across an LSM callback.

This patch records state without advertising quarantine support.
The following patch adds the access checks before enabling it.

Signed-off-by: Alex Markuze <amarkuze@redhat.com>
---
 fs/ceph/caps.c       | 122 ++++++++++-
 fs/ceph/dir.c        |   9 +
 fs/ceph/file.c       |   2 +
 fs/ceph/inode.c      | 476 ++++++++++++++++++++++++++++++++++++++++++-
 fs/ceph/mds_client.c |  23 ++-
 fs/ceph/mds_client.h |  16 ++
 fs/ceph/super.c      |   2 +
 fs/ceph/super.h      |  71 ++++++-
 8 files changed, 713 insertions(+), 8 deletions(-)

diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index b27bcdc24d29..94f015112942 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -692,8 +692,9 @@ void change_auth_cap_ses(struct ceph_inode_info *ci,
  * @fmode is the open file mode, if we are opening a file, otherwise
  * it is < 0.  (This is so we can atomically add the cap and add an
  * open file reference to it.)
+ * Returns false when the raw grant predates the recorded cap sequence.
  */
-void ceph_add_cap(struct inode *inode,
+bool ceph_add_cap(struct inode *inode,
 		  struct ceph_mds_session *session, u64 cap_id,
 		  unsigned issued, unsigned wanted,
 		  unsigned seq, unsigned mseq, u64 realmino, int flags,
@@ -706,6 +707,7 @@ void ceph_add_cap(struct inode *inode,
 	int mds = session->s_mds;
 	int actual_wanted;
 	u32 gen;
+	bool cap_current = true;
 
 	lockdep_assert_held(&ci->i_ceph_lock);
 
@@ -737,6 +739,7 @@ void ceph_add_cap(struct inode *inode,
 		atomic64_inc(&mdsc->metric.total_caps);
 		spin_unlock(&session->s_cap_lock);
 	} else {
+		cap_current = ceph_seq_cmp(seq, cap->seq) >= 0;
 		spin_lock(&session->s_cap_lock);
 		list_move_tail(&cap->session_caps, &session->s_caps);
 		spin_unlock(&session->s_cap_lock);
@@ -823,6 +826,7 @@ void ceph_add_cap(struct inode *inode,
 	cap->mseq = mseq;
 	cap->cap_gen = gen;
 	wake_up_all(&ci->i_cap_wq);
+	return cap_current;
 }
 
 /*
@@ -1264,6 +1268,11 @@ static void __ceph_remove_cap(struct ceph_inode_info *ci, struct ceph_cap *cap,
 
 	mdsc = ceph_inode_to_fs_client(&ci->netfs.inode)->mdsc;
 
+	/* Losing the reporting cap requires fresh MDS revalidation. */
+	if (READ_ONCE(ci->i_qtine_mds) == cap->mds &&
+	    ceph_quarantine_reset(ci))
+		wake_up_all(&ci->i_cap_wq);
+
 	/* remove from inode's cap rbtree, and clear auth cap */
 	rb_erase(&cap->ci_node, &ci->i_caps);
 	if (ci->i_auth_cap == cap)
@@ -3729,6 +3738,9 @@ struct cap_extra_info {
 	u8 *fscrypt_auth;
 	u32 fscrypt_auth_len;
 	u64 fscrypt_file_size;
+	/* MClientCaps v14 oserrno; valid only when oserrno_valid is set */
+	s32 oserrno;
+	bool oserrno_valid;
 };
 
 /*
@@ -3757,6 +3769,45 @@ static int parse_inline_data(void **p, void *end,
 	return -EIO;
 }
 
+/*
+ * Record quarantine state carried by an MClientCaps oserrno.
+ * Caller holds i_ceph_lock. Returns true when waiters should be woken
+ * because quarantine changed or a pending reset was resolved.
+ *
+ * -EQUARANTINED refreshes the sticky flag and its reporting MDS rank.
+ * A current grant above PIN with errno 0 clears only that rank's mark.
+ * Another rank needs a successful metadata request for the current epoch.
+ * A PIN-only update may zero qtine_errno while leaving the flag set.
+ */
+static bool ceph_apply_quarantine(struct ceph_inode_info *ci, int mds,
+				  int newcaps, int oserrno)
+{
+	bool was, now, pending;
+
+	was = READ_ONCE(ci->i_qtine_errno) == -CEPH_EQUARANTINED ||
+	      test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags);
+	pending = test_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags);
+
+	if ((newcaps & ~CEPH_CAP_PIN) && was && oserrno == 0 &&
+	    READ_ONCE(ci->i_qtine_mds) == mds)
+		ceph_quarantine_clear(ci);
+
+	if (oserrno == -CEPH_EQUARANTINED) {
+		ceph_quarantine_set(ci);
+		WRITE_ONCE(ci->i_qtine_mds, mds);
+	}
+
+	if (newcaps || was ||
+	    test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags))
+		WRITE_ONCE(ci->i_qtine_errno, oserrno);
+
+	now = READ_ONCE(ci->i_qtine_errno) == -CEPH_EQUARANTINED ||
+	      test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags);
+	return was != now ||
+	       pending != test_bit(CEPH_I_QUARANTINE_PENDING_BIT,
+				   &ci->i_ceph_flags);
+}
+
 /*
  * Handle a cap GRANT message from the MDS.  (Note that a GRANT may
  * actually be a revocation if it specifies a smaller cap set.)
@@ -3781,6 +3832,7 @@ static void handle_cap_grant(struct inode *inode,
 	u64 max_size = le64_to_cpu(grant->max_size);
 	unsigned char check_caps = 0;
 	bool was_stale = cap->cap_gen < atomic_read(&session->s_cap_gen);
+	bool quarantine_current = ceph_seq_cmp(seq, cap->seq) >= 0;
 	bool wake = false;
 	bool writeback = false;
 	bool queue_trunc = false;
@@ -4128,6 +4180,15 @@ static void handle_cap_grant(struct inode *inode,
 			fill_inline = true;
 	}
 
+	if (quarantine_current && extra_info->oserrno_valid &&
+	    ceph_apply_quarantine(ci, session->s_mds, newcaps,
+				  extra_info->oserrno)) {
+		boutc(cl, "quarantine oserrno %d caps %s %llx.%llx\n",
+		      extra_info->oserrno, ceph_cap_string(newcaps),
+		      ceph_vinop(inode));
+		wake = true;
+	}
+
 	if (le32_to_cpu(grant->op) == CEPH_CAP_OP_IMPORT) {
 		if (ci->i_auth_cap == cap) {
 			if (newcaps & ~extra_info->issued)
@@ -4826,6 +4887,20 @@ void ceph_handle_caps(struct ceph_mds_session *session,
 			goto bad;
 	}
 
+	if (msg_version >= 13) {
+		/* v13: subvolume_id. The inode id is learned from replies. */
+		ceph_decode_skip_64(&p, end, bad);
+	}
+
+	if (msg_version >= 14) {
+		u32 raw_errno;
+
+		/* v14: signed oserrno, -CEPH_EQUARANTINED when quarantined */
+		ceph_decode_32_safe(&p, end, raw_errno, bad);
+		extra_info.oserrno = (s32)raw_errno;
+		extra_info.oserrno_valid = true;
+	}
+
 	/* lookup ino */
 	inode = ceph_find_inode(mdsc->fsc->sb, vino);
 	boutc(cl, " caps mds%d op %s ino %llx.%llx inode %p seq %u iseq %u mseq %u\n",
@@ -4981,6 +5056,51 @@ void ceph_handle_caps(struct ceph_mds_session *session,
 	goto out;
 }
 
+void ceph_handle_quarantine_disable(struct ceph_mds_client *mdsc,
+				    struct ceph_mds_session *session,
+				    struct ceph_msg *msg)
+{
+	struct super_block *sb = mdsc->fsc->sb;
+	struct ceph_client *cl = mdsc->fsc->client;
+	struct ceph_mds_quarantine_disable *h = msg->front.iov_base;
+	struct ceph_vino vino;
+	struct inode *inode;
+	struct ceph_inode_info *ci;
+
+	if (!ceph_inc_mds_stopping_blocker(mdsc, session))
+		return;
+
+	if (msg->front.iov_len < sizeof(*h)) {
+		pr_err_client(cl, "corrupt quarantine_disable mds%d len %d\n",
+			      session->s_mds, (int)msg->front.iov_len);
+		ceph_msg_dump(msg);
+		goto out;
+	}
+
+	vino.ino = le64_to_cpu(h->ino);
+	vino.snap = CEPH_NOSNAP;
+	inode = ceph_find_inode(sb, vino);
+	if (!inode) {
+		doutc(cl, "quarantine disable ino %llx not cached\n", vino.ino);
+		goto out;
+	}
+
+	ci = ceph_inode(inode);
+	spin_lock(&ci->i_ceph_lock);
+	/* Another rank's disable must not erase a newer negative. */
+	if (!test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags) ||
+	    READ_ONCE(ci->i_qtine_mds) == session->s_mds) {
+		ceph_quarantine_clear(ci);
+		WRITE_ONCE(ci->i_qtine_errno, 0);
+	}
+	spin_unlock(&ci->i_ceph_lock);
+	wake_up_all(&ci->i_cap_wq);
+	doutc(cl, "quarantine disable ino %llx\n", vino.ino);
+	iput(inode);
+out:
+	ceph_dec_mds_stopping_blocker(mdsc);
+}
+
 /*
  * Process the expired end of one delayed cap list, whose entries were
  * queued @hold jiffies before they expire.
diff --git a/fs/ceph/dir.c b/fs/ceph/dir.c
index 384e9edabe2a..d8c8b7ad8930 100644
--- a/fs/ceph/dir.c
+++ b/fs/ceph/dir.c
@@ -795,7 +795,9 @@ struct dentry *ceph_handle_snapdir(struct ceph_mds_request *req,
 		struct dentry *res;
 		struct inode *inode = ceph_get_snapdir(parent);
 
+		ceph_quarantine_splice_start(parent->i_sb);
 		res = d_splice_alias(inode, dentry);
+		ceph_quarantine_splice_finish(parent->i_sb);
 		boutc_formats(cl,
 			      "ENOENT on snapdir %p '%s', linking to snapdir %p %llx.%llx. Spliced dentry %p\n",
 			      "ENOENT on snapdir %p '%pd', linking to snapdir %p %llx.%llx. Spliced dentry %p\n",
@@ -1373,7 +1375,9 @@ static int ceph_link(struct dentry *old_dentry, struct inode *dir,
 		d_drop(dentry);
 	} else if (!req->r_reply_info.head->is_dentry) {
 		ihold(d_inode(old_dentry));
+		ceph_quarantine_splice_start(dir->i_sb);
 		d_instantiate(dentry, d_inode(old_dentry));
+		ceph_quarantine_splice_finish(dir->i_sb);
 	}
 	ceph_mdsc_put_request(req);
 	ceph_blog_exit(&__ji);
@@ -1701,12 +1705,17 @@ static int ceph_rename(struct mnt_idmap *idmap, struct inode *old_dir,
 	}
 	err = ceph_mdsc_do_request(mdsc, old_dir, req);
 	if (!err && !req->r_reply_info.head->is_dentry) {
+		struct inode *moved;
+
 		/*
 		 * Normally d_move() is done by fill_trace (called by
 		 * do_request, above).  If there is no trace, we need
 		 * to do it here.
 		 */
+		moved = d_inode(old_dentry);
+		ceph_quarantine_move_start(moved, old_dir, new_dir);
 		d_move(old_dentry, new_dentry);
+		ceph_quarantine_move_finish(moved, old_dir, new_dir);
 	}
 	ceph_mdsc_put_request(req);
 	ceph_blog_exit(&__ji);
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 856710c63765..9a6eadb94ab4 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -785,7 +785,9 @@ static int ceph_finish_async_create(struct inode *dir, struct inode *inode,
 		if (d_in_lookup(dentry) || d_really_is_negative(dentry)) {
 			if (!d_unhashed(dentry))
 				d_drop(dentry);
+			ceph_quarantine_splice_start(dir->i_sb);
 			dn = d_splice_alias(inode, dentry);
+			ceph_quarantine_splice_finish(dir->i_sb);
 			WARN_ON_ONCE(dn && dn != dentry);
 		}
 		file->f_mode |= FMODE_CREATED;
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index 94f5215f8eed..78e97cf2f9a4 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -15,6 +15,7 @@
 #include <linux/sort.h>
 #include <linux/iversion.h>
 #include <linux/fscrypt.h>
+#include <linux/cred.h>
 
 #include "super.h"
 #include "mds_client.h"
@@ -648,6 +649,11 @@ struct inode *ceph_alloc_inode(struct super_block *sb)
 	ci->i_max_bytes = 0;
 	ci->i_max_files = 0;
 	ci->i_subvolume_id = CEPH_SUBVOLUME_ID_NONE;
+	ci->i_qtine_errno = 0;
+	ci->i_qtine_mds = -1;
+	atomic64_set(&ci->i_qtag, 0);
+	atomic64_set(&ci->i_qmds, 0);
+	ci->i_qmds_cred = NULL;
 
 	memset(&ci->i_dir_layout, 0, sizeof(ci->i_dir_layout));
 	memset(&ci->i_cached_layout, 0, sizeof(ci->i_cached_layout));
@@ -730,10 +736,461 @@ struct inode *ceph_alloc_inode(struct super_block *sb)
 	return &ci->netfs.inode;
 }
 
+/*
+ * quarantine_epoch is a seqcount shared by every mark change and every
+ * cross-directory rename. The first writer flips it odd, the last
+ * writer flips it even. Readers must not trust or publish a cache
+ * while it is odd, so a cached false cannot outlive the mutation.
+ *
+ * quarantine_lock makes the writers update and the epoch bump one
+ * step. The epoch is already odd before this returns, and it does not
+ * go even until the last writer has finished the bit change or d_move.
+ * Callers that hold i_ceph_lock take this lock after it. The lock is
+ * not held across the mutation.
+ */
+static void ceph_quarantine_write_begin(struct ceph_mds_client *mdsc)
+{
+	if (!mdsc)
+		return;
+
+	spin_lock(&mdsc->quarantine_lock);
+	if (atomic_inc_return(&mdsc->quarantine_writers) == 1)
+		atomic64_inc_return(&mdsc->quarantine_epoch);
+	spin_unlock(&mdsc->quarantine_lock);
+}
+
+static void ceph_quarantine_write_end(struct ceph_mds_client *mdsc)
+{
+	if (!mdsc)
+		return;
+
+	spin_lock(&mdsc->quarantine_lock);
+	if (atomic_dec_return(&mdsc->quarantine_writers) == 0)
+		atomic64_inc_return(&mdsc->quarantine_epoch);
+	spin_unlock(&mdsc->quarantine_lock);
+}
+
+void ceph_quarantine_set(struct ceph_inode_info *ci)
+{
+	struct ceph_mds_client *mdsc;
+
+	mdsc = ceph_sb_to_mdsc(ci->netfs.inode.i_sb);
+	/* Every accepted negative invalidates earlier requests and receipts. */
+	ceph_quarantine_write_begin(mdsc);
+	if (mdsc)
+		atomic_inc(&mdsc->quarantine_count);
+	if (test_and_set_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags)) {
+		if (mdsc)
+			atomic_dec(&mdsc->quarantine_count);
+	}
+	clear_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags);
+	ceph_quarantine_write_end(mdsc);
+}
+
+bool ceph_quarantine_clear(struct ceph_inode_info *ci)
+{
+	struct ceph_mds_client *mdsc;
+	bool cleared;
+
+	if (!test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags))
+		return false;
+
+	mdsc = ceph_sb_to_mdsc(ci->netfs.inode.i_sb);
+	ceph_quarantine_write_begin(mdsc);
+	cleared = test_and_clear_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags);
+	if (cleared) {
+		clear_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags);
+		WRITE_ONCE(ci->i_qtine_errno, 0);
+		WRITE_ONCE(ci->i_qtine_mds, -1);
+		if (mdsc)
+			atomic_dec(&mdsc->quarantine_count);
+	}
+	ceph_quarantine_write_end(mdsc);
+	return cleared;
+}
+
+/* Session loss requires an MDS answer without reopening cached snap caps. */
+bool ceph_quarantine_reset(struct ceph_inode_info *ci)
+{
+	struct ceph_mds_client *mdsc;
+
+	if (!test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags) ||
+	    test_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags))
+		return false;
+
+	mdsc = ceph_sb_to_mdsc(ci->netfs.inode.i_sb);
+	ceph_quarantine_write_begin(mdsc);
+	set_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags);
+	WRITE_ONCE(ci->i_qtine_errno, 0);
+	ceph_quarantine_write_end(mdsc);
+	return true;
+}
+
+bool ceph_inode_quarantine_direct(struct inode *inode)
+{
+	struct ceph_inode_info *ci;
+
+	if (!inode)
+		return false;
+	ci = ceph_inode(inode);
+	return !test_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags) &&
+		(READ_ONCE(ci->i_qtine_errno) == -CEPH_EQUARANTINED ||
+		 test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags));
+}
+
+/* Low bit is the answer. The rest is quarantine_epoch, odd values excluded. */
+static u64 ceph_qtag_pack(u64 epoch, bool under)
+{
+	return epoch | (under ? 1ULL : 0);
+}
+
+static void ceph_quarantine_publish(struct ceph_inode_info *ci, bool under,
+				    u64 epoch)
+{
+	if (epoch & 1)
+		return;
+
+	/* Pairs with atomic64_read_acquire() of i_qtag. */
+	atomic64_set_release(&ci->i_qtag, ceph_qtag_pack(epoch, under));
+}
+
+static bool ceph_qtag_read(struct ceph_inode_info *ci, u64 epoch, bool *under)
+{
+	u64 packed;
+
+	if (epoch & 1)
+		return false;
+
+	/* Pairs with atomic64_set_release() in ceph_quarantine_publish(). */
+	packed = atomic64_read_acquire(&ci->i_qtag);
+	if ((packed & ~1ULL) != epoch)
+		return false;
+	*under = packed & 1ULL;
+	return true;
+}
+
+/* (epoch | 1) marks an MDS confirmation for this even epoch. */
+static bool ceph_qmds_confirmed(struct ceph_inode_info *ci, u64 epoch)
+{
+	u64 cookie;
+	bool confirmed;
+
+	if (epoch & 1)
+		return false;
+
+	/* Pairs with atomic64_set_release() in remember_clear(). */
+	if ((u64)atomic64_read_acquire(&ci->i_qmds) != (epoch | 1ULL))
+		return false;
+	/* The cookie and its immutable credentials are one locked receipt. */
+	spin_lock(&ci->i_ceph_lock);
+	cookie = atomic64_read(&ci->i_qmds);
+	confirmed = cookie == (epoch | 1ULL) &&
+		ci->i_qmds_cred == current_cred();
+	spin_unlock(&ci->i_ceph_lock);
+	return confirmed;
+}
+
+static void ceph_quarantine_forget_receipt(struct ceph_inode_info *ci)
+{
+	const struct cred *cred;
+
+	spin_lock(&ci->i_ceph_lock);
+	cred = ci->i_qmds_cred;
+	ci->i_qmds_cred = NULL;
+	atomic64_set_release(&ci->i_qmds, 0);
+	spin_unlock(&ci->i_ceph_lock);
+	put_cred(cred);
+}
+
+/* A finished walk reached a mark, an ancestor tag, or the mount root. */
+enum {
+	CEPH_QWALK_CLEAR,
+	CEPH_QWALK_UNDER,
+	CEPH_QWALK_INCOMPLETE,
+};
+
+/*
+ * Parent walk with no inode references. Caller holds rcu_read_lock().
+ * Stops at the mount root, at an MDS mark, or at an ancestor whose
+ * cached answer is for this epoch. No hashed alias, or the depth
+ * limit, is not an answer: the caller must not cache it.
+ */
+static int ceph_quarantine_walk_once(struct inode *inode, u64 epoch,
+				     bool use_cache)
+{
+	struct inode *cur = inode;
+	unsigned int depth = 0;
+	bool under = false;
+	bool done = false;
+
+	while (cur && depth++ < 256) {
+		struct ceph_inode_info *ci = ceph_inode(cur);
+		struct dentry *alias;
+		struct dentry *parent;
+		struct inode *next;
+
+		if (test_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags))
+			break;
+		if (READ_ONCE(ci->i_qtine_errno) == -CEPH_EQUARANTINED ||
+		    test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags)) {
+			under = true;
+			done = true;
+			break;
+		}
+
+		if (use_cache && cur != inode &&
+		    ceph_qtag_read(ci, epoch, &under)) {
+			done = true;
+			break;
+		}
+
+		alias = d_find_alias_rcu(cur);
+		if (!alias)
+			break;
+
+		parent = READ_ONCE(alias->d_parent);
+		/*
+		 * The mount root is its own parent. A disconnected
+		 * alias from d_obtain_alias(), or a secondary root from
+		 * d_obtain_root(), has the same shape and is not a
+		 * finished walk.
+		 */
+		if (!parent || parent == alias) {
+			if (parent == alias && S_ISDIR(cur->i_mode) &&
+			    alias == READ_ONCE(inode->i_sb->s_root))
+				done = true;
+			break;
+		}
+
+		next = d_inode_rcu(parent);
+		if (!next || next == cur || next->i_sb != inode->i_sb)
+			break;
+		cur = next;
+	}
+	if (!done)
+		return CEPH_QWALK_INCOMPLETE;
+	return under ? CEPH_QWALK_UNDER : CEPH_QWALK_CLEAR;
+}
+
+/*
+ * rename_lock covers d_move(). A chain observed across that move is
+ * not an answer. A few retries, then the caller asks the MDS.
+ */
+static int ceph_quarantine_walk(struct inode *inode, u64 epoch, bool use_cache)
+{
+	unsigned int seq;
+	unsigned int tries = 0;
+	int ret = CEPH_QWALK_INCOMPLETE;
+
+	rcu_read_lock();
+	do {
+		seq = read_seqbegin(&rename_lock);
+		ret = ceph_quarantine_walk_once(inode, epoch, use_cache);
+		if (!read_seqretry(&rename_lock, seq))
+			break;
+		ret = CEPH_QWALK_INCOMPLETE;
+		cpu_relax();
+	} while (++tries < 4);
+	rcu_read_unlock();
+	return ret;
+}
+
+/*
+ * CEPH_Q_UNDER when this inode or an ancestor was marked by an MDS cap
+ * update. Ancestors cover children that have not yet received their
+ * own cap message.
+ *
+ * quarantine_count is zero unless some inode is marked, so the common
+ * path does not walk. While a mark is set, a finished walk is one word
+ * on the inode. A walk stops at an ancestor that already holds that
+ * answer. A short walk is not stored in i_qtag. Callers ask the MDS.
+ * An MDS read receipt in i_qmds overrides inherited marks for the
+ * queried inode until the next epoch bump. It does not override a
+ * definite mark on that inode or authorize cached writes.
+ *
+ * An odd quarantine_epoch is a mark or a d_move() in progress. The
+ * observation is dropped and the check is repeated. Bounded retries
+ * return UNKNOWN, so a preempted writer cannot pin the CPU.
+ */
+static enum ceph_qstate __ceph_inode_quarantine_state(struct inode *inode,
+						      bool read_confirmed)
+{
+	struct ceph_mds_client *mdsc;
+	struct ceph_inode_info *ci;
+	unsigned int retries = 0;
+	u64 epoch;
+	bool under, splicing, cached;
+
+	if (!inode)
+		return CEPH_Q_CLEAR;
+
+	mdsc = ceph_sb_to_mdsc(inode->i_sb);
+	if (!mdsc || atomic_read(&mdsc->quarantine_count) == 0)
+		return CEPH_Q_CLEAR;
+
+	ci = ceph_inode(inode);
+	for (;;) {
+		/* Bound retries across both odd writers and changing even epochs. */
+		if (++retries > 32) {
+			cond_resched();
+			return CEPH_Q_UNKNOWN;
+		}
+		/* Pairs with atomic64_inc_return() in write_begin(). */
+		epoch = (u64)atomic64_read_acquire(&mdsc->quarantine_epoch);
+		if (epoch & 1) {
+			cpu_relax();
+			cond_resched();
+			continue;
+		}
+		splicing = atomic_read_acquire(&mdsc->quarantine_splices) != 0;
+
+		if (ceph_inode_quarantine_direct(inode)) {
+			under = true;
+			cached = true;
+		} else if (read_confirmed && !splicing &&
+			   ceph_qmds_confirmed(ci, epoch)) {
+			under = false;
+			cached = true;
+		} else {
+			cached = !splicing && ceph_qtag_read(ci, epoch, &under);
+		}
+		if (cached) {
+			/* Orders the marker, receipt, and tag loads before the retry. */
+			smp_rmb();
+			if ((u64)atomic64_read(&mdsc->quarantine_epoch) == epoch &&
+			    (splicing || !atomic_read(&mdsc->quarantine_splices)))
+				return under ? CEPH_Q_UNDER : CEPH_Q_CLEAR;
+			cpu_relax();
+			cond_resched();
+			continue;
+		}
+
+		switch (ceph_quarantine_walk(inode, epoch, !splicing)) {
+		case CEPH_QWALK_UNDER:
+			under = true;
+			break;
+		case CEPH_QWALK_CLEAR:
+			under = false;
+			break;
+		default:
+			/* Orders the walk before the retry. */
+			smp_rmb();
+			if ((u64)atomic64_read(&mdsc->quarantine_epoch) == epoch &&
+			    (splicing || !atomic_read(&mdsc->quarantine_splices))) {
+				return CEPH_Q_UNKNOWN;
+			}
+			cpu_relax();
+			cond_resched();
+			continue;
+		}
+		/* Orders the walk before the retry, as in read_seqcount_retry(). */
+		smp_rmb();
+		if ((u64)atomic64_read(&mdsc->quarantine_epoch) == epoch &&
+		    (splicing || !atomic_read(&mdsc->quarantine_splices))) {
+			if (!splicing)
+				ceph_quarantine_publish(ci, under, epoch);
+			return under ? CEPH_Q_UNDER : CEPH_Q_CLEAR;
+		}
+		cpu_relax();
+		cond_resched();
+	}
+}
+
+enum ceph_qstate ceph_inode_quarantine_state(struct inode *inode)
+{
+	return __ceph_inode_quarantine_state(inode, true);
+}
+
+enum ceph_qstate ceph_inode_quarantine_write_state(struct inode *inode)
+{
+	/* GETATTR can prove read recovery access under a read-only q grant. */
+	return __ceph_inode_quarantine_state(inode, false);
+}
+
+static struct ceph_mds_client *ceph_quarantine_move_mdsc(struct inode *inode,
+							 struct inode *old_dir,
+							 struct inode *new_dir)
+{
+	if (!inode || old_dir == new_dir)
+		return NULL;
+	return ceph_sb_to_mdsc(inode->i_sb);
+}
+
+/*
+ * Bracket d_move(). The epoch is odd across the parent change, so a
+ * cached false cannot be reused against the new parent. d_move() does
+ * not sleep. Same-directory renames do not take a writer slot.
+ *
+ * Sleeping alias splices use a separate counter below.
+ */
+void ceph_quarantine_move_start(struct inode *inode, struct inode *old_dir,
+				struct inode *new_dir)
+{
+	ceph_quarantine_write_begin(ceph_quarantine_move_mdsc(inode, old_dir,
+							      new_dir));
+}
+
+void ceph_quarantine_move_finish(struct inode *inode, struct inode *old_dir,
+				 struct inode *new_dir)
+{
+	ceph_quarantine_write_end(ceph_quarantine_move_mdsc(inode, old_dir,
+							    new_dir));
+}
+
+/*
+ * d_splice_alias() and d_instantiate() can sleep in the LSM hook before
+ * changing ancestry. Keep the epoch even for that hook, but disallow
+ * all cached answers throughout the splice. A fresh walk also samples
+ * rename_lock, so it cannot accept a chain torn by a move. Bracket
+ * first attachments too: descendants may hold MDS confirmations from
+ * when the directory had no connected alias.
+ *
+ * Fully ordered atomics and quarantine_lock make the counter and epoch
+ * transitions one writer operation. Entry disables cache use before
+ * invalidating tags; exit invalidates tags before enabling cache use.
+ * Adding two preserves the parity of any concurrent mark writer.
+ */
+void ceph_quarantine_splice_start(struct super_block *sb)
+{
+	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(sb);
+
+	spin_lock(&mdsc->quarantine_lock);
+	atomic_inc_return(&mdsc->quarantine_splices);
+	atomic64_add_return(2, &mdsc->quarantine_epoch);
+	spin_unlock(&mdsc->quarantine_lock);
+}
+
+void ceph_quarantine_splice_finish(struct super_block *sb)
+{
+	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(sb);
+
+	spin_lock(&mdsc->quarantine_lock);
+	atomic64_add_return(2, &mdsc->quarantine_epoch);
+	atomic_dec_return(&mdsc->quarantine_splices);
+	spin_unlock(&mdsc->quarantine_lock);
+}
+
+static bool ceph_quarantine_reply_can_clear(struct ceph_inode_info *ci,
+					    struct ceph_mds_session *session)
+{
+	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(ci->netfs.inode.i_sb);
+	struct ceph_mds_request *req;
+	u64 epoch;
+
+	if (READ_ONCE(ci->i_qtine_mds) == session->s_mds)
+		return true;
+	/* Different ranks have independent cap sequences. */
+	req = ceph_current_mds_request(mdsc->fsc);
+	epoch = (u64)atomic64_read_acquire(&mdsc->quarantine_epoch);
+	return req && !(epoch & 1) && req->r_quarantine_epoch == epoch &&
+		!atomic_read(&mdsc->quarantine_splices);
+}
+
 void ceph_free_inode(struct inode *inode)
 {
 	struct ceph_inode_info *ci = ceph_inode(inode);
 
+	put_cred(ci->i_qmds_cred);
 	kfree(ci->i_symlink);
 #ifdef CONFIG_FS_ENCRYPTION
 	kfree(ci->fscrypt_auth);
@@ -759,6 +1216,8 @@ void ceph_evict_inode(struct inode *inode)
 	percpu_counter_dec(&mdsc->metric.total_inodes);
 
 	ci->i_subvolume_id = CEPH_SUBVOLUME_ID_NONE;
+	ceph_quarantine_forget_receipt(ci);
+	ceph_quarantine_clear(ci);
 
 	netfs_wait_for_outstanding_io(inode);
 	truncate_inode_pages_final(&inode->i_data);
@@ -1407,7 +1866,7 @@ int ceph_fill_inode(struct inode *inode, struct folio *locked_folio,
 	/* were we issued a capability? */
 	if (info_caps) {
 		if (!ceph_in_snap(inode)) {
-			ceph_add_cap(inode, session,
+			bool cap_current = ceph_add_cap(inode, session,
 				     le64_to_cpu(info->cap.cap_id),
 				     info_caps,
 				     le32_to_cpu(info->cap.wanted),
@@ -1416,6 +1875,14 @@ int ceph_fill_inode(struct inode *inode, struct folio *locked_folio,
 				     le64_to_cpu(info->cap.realm),
 				     info->cap.flags, &new_cap);
 
+			/*
+			 * Caps above PIN mean quarantine has been lifted,
+			 * including when the disable message was lost.
+			 */
+			if (cap_current && (info_caps & ~CEPH_CAP_PIN) &&
+			    ceph_quarantine_reply_can_clear(ci, session))
+				ceph_quarantine_clear(ci);
+
 			/* set dir completion flag? */
 			if (S_ISDIR(inode->i_mode) &&
 			    ci->i_files == 0 && ci->i_subdirs == 0 &&
@@ -1618,6 +2085,7 @@ static int splice_dentry(struct dentry **pdn, struct inode *in)
 		realdn = d_find_any_alias(in);
 		if (realdn) {
 			struct ceph_dentry_info *di = ceph_dentry(realdn);
+
 			spin_lock(&realdn->d_lock);
 
 			realdn->d_op->d_prune(realdn);
@@ -1634,7 +2102,9 @@ static int splice_dentry(struct dentry **pdn, struct inode *in)
 	/* dn must be unhashed */
 	if (!d_unhashed(dn))
 		d_drop(dn);
+	ceph_quarantine_splice_start(dn->d_sb);
 	realdn = d_splice_alias(in, dn);
+	ceph_quarantine_splice_finish(dn->d_sb);
 	if (IS_ERR(realdn)) {
 		pr_err_client(cl, "error %ld %p inode %p ino %llx.%llx\n",
 			      PTR_ERR(realdn), dn, in, ceph_vinop(in));
@@ -1859,6 +2329,7 @@ int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 		/* rename? */
 		if (req->r_old_dentry && req->r_op == CEPH_MDS_OP_RENAME) {
 			struct inode *olddir = req->r_old_dentry_dir;
+			struct inode *moved;
 			BUG_ON(!olddir);
 
 			boutc(cl, " src %p '%s' dst %p '%s'\n",
@@ -1869,7 +2340,10 @@ int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 			ceph_dir_clear_ordered(dir);
 			ceph_dir_clear_ordered(olddir);
 
+			moved = d_inode(req->r_old_dentry);
+			ceph_quarantine_move_start(moved, olddir, dir);
 			d_move(req->r_old_dentry, dn);
+			ceph_quarantine_move_finish(moved, olddir, dir);
 			boutc(cl, " src %p '%s' dst %p '%s'\n",
 			      req->r_old_dentry, req->r_old_dentry->d_name.name, dn, dn->d_name.name);
 
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index d4ef8a355a48..bb7cf9384fd6 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -2041,10 +2041,12 @@ static int remove_session_caps_cb(struct inode *inode, int mds, void *arg)
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	struct ceph_client *cl = ceph_inode_to_client(inode);
 	bool invalidate = false;
+	bool reset;
 	struct ceph_cap *cap;
 	int iputs = 0;
 
 	spin_lock(&ci->i_ceph_lock);
+	reset = ceph_quarantine_reset(ci);
 	cap = __get_cap_for_mds(ci, mds);
 	if (cap) {
 		boutc(cl, " removing cap %p, ci is %p, inode is %p\n",
@@ -2054,7 +2056,7 @@ static int remove_session_caps_cb(struct inode *inode, int mds, void *arg)
 	}
 	spin_unlock(&ci->i_ceph_lock);
 
-	if (cap)
+	if (cap || reset)
 		wake_up_all(&ci->i_cap_wq);
 	if (invalidate)
 		ceph_queue_invalidate(inode);
@@ -2860,6 +2862,7 @@ ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
 
 	mutex_init(&req->r_fill_mutex);
 	req->r_mdsc = mdsc;
+	req->r_quarantine_epoch = atomic64_read_acquire(&mdsc->quarantine_epoch);
 	req->r_started = jiffies;
 	req->r_start_latency = ktime_get();
 	req->r_resend_mds = -1;
@@ -5009,6 +5012,7 @@ static int reconnect_caps_cb(struct inode *inode, int mds, void *arg)
 	struct ceph_path_info path_info = {0};
 	int err;
 	u64 snap_follows;
+	bool reset = false;
 
 	dentry = d_find_primary(inode);
 	if (dentry) {
@@ -5023,9 +5027,16 @@ static int reconnect_caps_cb(struct inode *inode, int mds, void *arg)
 	}
 
 	spin_lock(&ci->i_ceph_lock);
+	/*
+	 * Require a fresh MDS answer after reconnect. A PIN import may
+	 * carry no quarantine errno, so it must not reopen cached snap caps.
+	 */
+	reset = ceph_quarantine_reset(ci);
 	cap = __get_cap_for_mds(ci, mds);
 	if (!cap) {
 		spin_unlock(&ci->i_ceph_lock);
+		if (reset)
+			wake_up_all(&ci->i_cap_wq);
 		err = 0;
 		goto out_err;
 	}
@@ -5088,6 +5099,8 @@ static int reconnect_caps_cb(struct inode *inode, int mds, void *arg)
 		snap_follows = capsnap->follows;
 	}
 	spin_unlock(&ci->i_ceph_lock);
+	if (reset)
+		wake_up_all(&ci->i_cap_wq);
 
 	if (recon_state->msg_version >= 2) {
 		int num_fcntl_locks, num_flock_locks;
@@ -6468,6 +6481,11 @@ int ceph_mdsc_init(struct ceph_fs_client *fsc)
 	init_completion(&mdsc->safe_umount_waiters);
 	spin_lock_init(&mdsc->stopping_lock);
 	atomic_set(&mdsc->stopping_blockers, 0);
+	atomic_set(&mdsc->quarantine_count, 0);
+	atomic_set(&mdsc->quarantine_writers, 0);
+	atomic_set(&mdsc->quarantine_splices, 0);
+	atomic64_set(&mdsc->quarantine_epoch, 0);
+	spin_lock_init(&mdsc->quarantine_lock);
 	init_completion(&mdsc->stopping_waiter);
 	atomic64_set(&mdsc->dirty_folios, 0);
 	init_waitqueue_head(&mdsc->flush_end_wq);
@@ -7368,6 +7386,9 @@ static void mds_dispatch(struct ceph_connection *con, struct ceph_msg *msg)
 	case CEPH_MSG_CLIENT_QUOTA:
 		ceph_handle_quota(mdsc, s, msg);
 		break;
+	case CEPH_MSG_CLIENT_QUARANTINE_DISABLE:
+		ceph_handle_quarantine_disable(mdsc, s, msg);
+		break;
 
 	default:
 		pr_err_client(cl, "received unknown message type %d %s\n",
diff --git a/fs/ceph/mds_client.h b/fs/ceph/mds_client.h
index 863cdb8d588a..816f5f2d32cc 100644
--- a/fs/ceph/mds_client.h
+++ b/fs/ceph/mds_client.h
@@ -375,6 +375,7 @@ struct ceph_mds_request {
 	int r_fmode;        /* file mode, if expecting cap */
 	int r_request_release_offset;
 	const struct cred *r_cred;
+	u64 r_quarantine_epoch; /* generation when the request was created */
 	struct mnt_idmap *r_mnt_idmap;
 	struct timespec64 r_stamp;
 
@@ -506,6 +507,21 @@ struct ceph_mds_client {
 	spinlock_t              stopping_lock;  /* protect snap_empty */
 	int                     stopping;      /* the stage of shutting down */
 	atomic_t                stopping_blockers;
+	/*
+	 * Inodes with CEPH_I_QUARANTINE set. Hot paths skip the
+	 * ancestor walk while this is zero.
+	 * quarantine_epoch is a seqcount: even while idle, odd while
+	 * quarantine_writers is non-zero. Writers are mark changes and
+	 * cross-directory renames. quarantine_lock covers the writers
+	 * update and the epoch bump together. Sleeping alias splices use
+	 * quarantine_splices instead: readers walk without cached answers
+	 * while it is non-zero. Each splice edge also bumps the epoch.
+	 */
+	atomic_t		quarantine_count;
+	atomic_t		quarantine_writers;
+	atomic_t		quarantine_splices;
+	atomic64_t		quarantine_epoch;
+	spinlock_t		quarantine_lock; /* writers update + epoch bump */
 	struct completion	stopping_waiter;
 
 	atomic64_t		dirty_folios;
diff --git a/fs/ceph/super.c b/fs/ceph/super.c
index 40be4b16e486..ad9460d9673c 100644
--- a/fs/ceph/super.c
+++ b/fs/ceph/super.c
@@ -1139,7 +1139,9 @@ static struct dentry *open_root_dentry(struct ceph_fs_client *fsc,
 		struct inode *inode = req->r_target_inode;
 		req->r_target_inode = NULL;
 		doutc(cl, "success\n");
+		ceph_quarantine_splice_start(fsc->sb);
 		root = d_make_root(inode);
+		ceph_quarantine_splice_finish(fsc->sb);
 		if (!root) {
 			root = ERR_PTR(-ENOMEM);
 			goto out;
diff --git a/fs/ceph/super.h b/fs/ceph/super.h
index 458fd63dd79f..0264bd9d705f 100644
--- a/fs/ceph/super.h
+++ b/fs/ceph/super.h
@@ -444,6 +444,33 @@ struct ceph_inode_info {
 #define CEPH_SUBVOLUME_ID_NONE 0
 	u64 i_subvolume_id;
 
+	/*
+	 * Cap oserrno from the MDS. -CEPH_EQUARANTINED means this inode
+	 * was revoked because its subvolume is quarantined. Paired with
+	 * CEPH_I_QUARANTINE, which stays set when a later PIN-only update
+	 * clears the errno.
+	 */
+	int i_qtine_errno;
+	int i_qtine_mds; /* negative cap origin, retained across pending reset */
+	/*
+	 * Cached ancestry answer: epoch | under, where epoch is even.
+	 * Atomic64 accesses also prevent tearing on 32-bit clients. An odd
+	 * quarantine_epoch means a mark or a rename is in progress.
+	 * Do not trust this word while the epoch is odd or an alias
+	 * splice is in progress.
+	 * Zero means "not under" at epoch 0.
+	 *
+	 * i_qmds stores (epoch | 1) after the MDS confirms an inode
+	 * can be read despite uncertain or marked ancestry. This read
+	 * permission is scoped to this inode, never its descendants or
+	 * cached writes. The next epoch bump drops the confirmation.
+	 * Zero means there is no confirmation.
+	 */
+	atomic64_t i_qtag;
+	atomic64_t i_qmds;
+	/* Immutable request credentials scope the MDS read receipt. */
+	const struct cred *i_qmds_cred; /* protected with i_qmds by i_ceph_lock */
+
 	s32 i_dir_pin;
 
 	int i_fragtree_nsplits;
@@ -773,6 +800,8 @@ static inline u64 ceph_get_truncate_pagecache_size(const struct ceph_inode_info
 					      * the deferred work completes
 					      */
 #define CEPH_I_EVICT_ON_FINAL_IPUT_BIT	(16) /* evict at the final iput() */
+#define CEPH_I_QUARANTINE_BIT		(17) /* subvolume quarantine opt set */
+#define CEPH_I_QUARANTINE_PENDING_BIT	(18) /* quarantine needs MDS confirmation */
 
 #define CEPH_I_DIR_ORDERED		(1 << CEPH_I_DIR_ORDERED_BIT)
 #define CEPH_I_FLUSH			(1 << CEPH_I_FLUSH_BIT)
@@ -1259,6 +1288,38 @@ extern int ceph_getattr(struct mnt_idmap *idmap,
 			u32 request_mask, unsigned int flags);
 void ceph_inode_shutdown(struct inode *inode);
 
+/*
+ * CEPH_Q_CLEAR: cached ancestry is clear, or the MDS confirmed read
+ * access to this exact inode for the current epoch. Writers must use
+ * ceph_inode_quarantine_write_state(), which ignores read receipts.
+ * CEPH_Q_UNDER: this inode or a cached ancestor is marked.
+ * CEPH_Q_UNKNOWN: the parent chain is not fully cached. Ask the MDS.
+ * Do not treat that as quarantined and do not use cached caps.
+ */
+enum ceph_qstate {
+	CEPH_Q_CLEAR = 0,
+	CEPH_Q_UNDER,
+	CEPH_Q_UNKNOWN,
+};
+
+enum ceph_qstate ceph_inode_quarantine_state(struct inode *inode);
+enum ceph_qstate ceph_inode_quarantine_write_state(struct inode *inode);
+bool ceph_inode_quarantine_direct(struct inode *inode);
+int ceph_quarantine_revalidate(struct inode *inode);
+int ceph_snapshot_read_auth(struct inode *inode);
+void ceph_quarantine_set(struct ceph_inode_info *ci);
+bool ceph_quarantine_clear(struct ceph_inode_info *ci);
+bool ceph_quarantine_reset(struct ceph_inode_info *ci);
+void ceph_quarantine_move_start(struct inode *inode, struct inode *old_dir,
+				struct inode *new_dir);
+void ceph_quarantine_move_finish(struct inode *inode, struct inode *old_dir,
+				 struct inode *new_dir);
+void ceph_quarantine_splice_start(struct super_block *sb);
+void ceph_quarantine_splice_finish(struct super_block *sb);
+void ceph_handle_quarantine_disable(struct ceph_mds_client *mdsc,
+				    struct ceph_mds_session *session,
+				    struct ceph_msg *msg);
+
 static inline bool ceph_inode_is_shutdown(const struct inode *inode)
 {
 	unsigned long flags = READ_ONCE(ceph_inode(inode)->i_ceph_flags);
@@ -1368,11 +1429,11 @@ extern void ceph_handle_caps(struct ceph_mds_session *session,
 			     struct ceph_msg *msg);
 extern struct ceph_cap *ceph_get_cap(struct ceph_mds_client *mdsc,
 				     struct ceph_cap_reservation *ctx);
-extern void ceph_add_cap(struct inode *inode,
-			 struct ceph_mds_session *session, u64 cap_id,
-			 unsigned issued, unsigned wanted,
-			 unsigned cap, unsigned seq, u64 realmino, int flags,
-			 struct ceph_cap **new_cap);
+bool ceph_add_cap(struct inode *inode,
+		  struct ceph_mds_session *session, u64 cap_id,
+		  unsigned int issued, unsigned int wanted,
+		  unsigned int seq, unsigned int mseq, u64 realmino, int flags,
+		  struct ceph_cap **new_cap);
 
 /**
  * Determine whether __ceph_remove_cap() has been called on this #cap

