Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792953791;
	b=R2PiKoe8kGCIbDtnppomKP8n/6fuJ93PuLuE0gPQONWLPRmhyPpxosygZpMoJKQdH+Dt
	 069rKmrHaWEjEZjlPzL4ZjmNT1rhJ5736R0eT9p0kGvLVjMLjMJaV5QKTP5W8Xt3/DHyD
	 /qrzC9XtnyZSxrmV+PxdjXIj+8dsd+PGjer0sbNuhriZQWtNOB/H0fTMkkRGo02eAp+fd
	 cUhnF837F6hoAumKwbTLAvmSrI3eQugTW9xRtorFkvz6msx5yyt9oIBWW83gDc+Ql4NgO
	 5Yp3dQEE61FNBqJoKpDVNYLLXjXWfYSDmpoLfYmSHOdcryOXEBHXka8LSHgWF2TYveA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792953791;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=DMhE0DuDjgGucZKIQYsrRxvz6A90FQ00Q2Qx462EYaE=;
	b=FUyOqrakSQ/R9gA/Cik6vEUVRhNot7eOEmmnFb64P7z88nWQjPImZLJsTa9PCINQDI6Z
	 CMKJz3Jv54WF2/pIEhxJR11iTu4EZq75uXXCW6SIVj+UulBEbOhSG653rS53R2nLN+1U6
	 nIMmnjCCyr4aNSC1VARSkJdLupTIepRJhI526bjlOzewTQyN7/1fcbuJYADnWu9PwzjSv
	 JgFdB0dOBONKUGfMkLO11vgj4fKZJmiSTUnfMrxxjs8bgxx+E3Z6iove8VI+XbH43OnYZ
	 e92pBupdsmJ4ntnX2ELghtfXTcO7ZFDjJ5hVWOcKqMwq+tDbepN/4c4AAsGdEqFvcvQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=eCeogmqm;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=qiQ96K36;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9A85606A333
	for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 18:43:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E9A85606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=eCeogmqm;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=qiQ96K36
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792953789;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=DMhE0DuDjgGucZKIQYsrRxvz6A90FQ00Q2Qx462EYaE=;
	b=eCeogmqmkyJDOZ4vORsVS3ZVWqB1EDyxHdizYNXQ7ScJBG7CelvU3/YUmdRAZft61yWNYw
	D9JJL2G/zfa+mQlxlaAbkBzg8nwYbuX1hRa/Ta5FAHVq87o0igNPxGFkHEGuCWKwwm/CB/
	Z5KSWqzzsxhOsmrq/BE1xBAlITsdLv0=
Received: from mail-ej1-f69.google.com (mail-ej1-f69.google.com
 [209.85.218.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-673-UcJHl0waNmC8WUv-PAGGVA-1; Sun, 25 Oct 2026 14:42:56 -0400
X-MC-Unique: UcJHl0waNmC8WUv-PAGGVA-1
X-Mimecast-MFC-AGG-ID: UcJHl0waNmC8WUv-PAGGVA_1792953776
Received: by mail-ej1-f69.google.com with SMTP id a640c23a62f3a-c465c4c8da0so273500466b.2
        for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 11:42:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792953776; x=1793558576; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=DMhE0DuDjgGucZKIQYsrRxvz6A90FQ00Q2Qx462EYaE=;
        b=qiQ96K36VLh6fbkS1IkGIZ//P1l9nQLV8bJx2PwPkeX6gFXBx/Cjk5K9f2KaYF+Yjr
         p1q4LgnihU7Nr9X5zZd3n+8t213mehMq+gvkV7VdS9kxIuo87I23QauLM+24K9E/Qiha
         zB5lvwL2rRRP9k4L6yqUT93lMgxn/49iBFl5aq4J/CnSaxZeFAKCrtogaTF41bmbReJo
         qi15GsKg+SIM7Qw1lX+eUyTdKHHNFmgHc8C0NdoPiloWx4hcS+24VzTHsT1VkGWJitd5
         aWUp3rq+ucMk8c9Ki4TUI/hamMQuexTVi7P1L1dM+puc5aHXEmX/9B9TVEeu2uyFlMNn
         mLQA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792953776; x=1793558576;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=DMhE0DuDjgGucZKIQYsrRxvz6A90FQ00Q2Qx462EYaE=;
        b=ArYjWkMduTx0Tf/J+Owtq4dJ2nw85/XIpaLFez+hyXwSWWK1S/ujNoAxh/e8SVeOPc
         FKuqGkz/JL1pUhrlESuj7gNTJ43TwZea7YfmaYC+4O9vEIMBW2p4l3xFt0BQbF+OjS/+
         0Lp7pLVU3j59V8Kq5a9vxR9GSuaqSyA1Ghp5BCzqhoytyp8AXdSLdIDUo2io2iAvGXAJ
         3W1EusKjSfYwM5Rut2GvCZRWOEsmsKfehPj6wE40cTHVR7/dbAQut8Y9s0C+YLuv6+MN
         GtqpTvDHTuzV78DBDmtmA/LJYiDLItAvvZ+80elHkZbpnlGT/V35x6pdc/WGviKCSZcg
         Volg==
X-Forwarded-Encrypted: i=1; AKwUvBxyrilus4KrvfbFzIQGQXB+LdPg/POzU3ILOoF5uRA9eSJqx4ju6vCuBwXjbB/qMVm8nj7vIz6W+V/iPr/b@vger.kernel.org
X-Gm-Message-State: AFq9FYJkCQZ4p6N53Co4r9eJ/1ga569w6K5tcSA5rukRrSoInSS2K8fk
	d78yqvU8Wqi5AgUllr0AJIQ4zC/oqagLfI5/9BmtQOfmNLvVM0wbAAw7IMUk424JYJCXPN4giAH
	++2b/+/npj/ot1LRaGvLRfY+rpN9+i74H6kTX1onuYE0oXhHPfcinlRsAq1cePoMHqZU=
X-Gm-Gg: AYBFou332a+27zO8YeFwMOCyz1vq67DkL/PULbVSa3xnth5oGLARPc/s6896achjC/T
	NhocjvxnDo2JkHqbbHfcIx8I4zwHt8u4uhxK8YdpKAGr5yuG946nPXxi1+KGifnh/Su1b9gxw/e
	PznIUerrUgzikikfrFrt3nP9yuxr948ZvEuyiHV81BtmU9O3N+JjOFHjUPXLL3hcSt7bXtVYJXk
	bgOCPV1rK9yHK1uHiyEM/MPVZn5XXnvsTD9337NZtoKHAu4U2Hg6aofTKumn4rKD+LEYnSFwo4c
	iGhuXIya/IyrX5TxZxhGvZ/3ks6nudZTSZRpcZljr++m8extX2dAfNa0iyD1VDatoLnbGddRKlo
	XkV6/7CodyITkRwcaC5AHs3dat/mLrma8mYOU9RuYo4iL5q3RVD0GzT1WfWpI25hsC+qLgCeLRq
	wGkq1ZlT4m5S8xUd+FYQOj/2D+Vy1RM7ctTW58IL6ctqv/YT2EwR9XDdMkVUkXeIigmQ1E07dK+
	MY=
X-Received: by 2002:a17:907:6d16:b0:c40:b59:f with SMTP id a640c23a62f3a-c46bde5409dmr650015366b.47.1792953774960;
        Sun, 25 Oct 2026 11:42:54 -0700 (PDT)
X-Received: by 2002:a17:907:6d16:b0:c40:b59:f with SMTP id a640c23a62f3a-c46bde5409dmr650011166b.47.1792953774352;
        Sun, 25 Oct 2026 11:42:54 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c46bd66e51fsm230750866b.64.2026.10.25.11.42.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 25 Oct 2026 11:42:53 -0700 (PDT)
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
Subject: [PATCH v6 4/5] ceph: record subvolume quarantine from MDS cap updates
Date: Sun, 25 Oct 2026 18:42:44 +0000
Message-Id: <1b6167c472fe05e2cd650bde2ffc9421892ad4cc.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
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

Quarantine notifications must remain effective while inode ancestry is
cached and while capabilities move between MDS ranks. Decode the signed
errno appended to MClientCaps v14 after the subvolume ID, and track a
sticky, counted quarantine mark and its reporting rank on each inode.

A current zero-error non-IMPORT wire grant above PIN or an explicit
disable from the reporting rank clears the mark. Capability bits
retained during migration are not a fresh grant and cannot authorize
clearing. A current metadata reply can confirm recovery across ranks.
PIN-only updates can reset the errno without clearing the mark. IMPORT's
zero can be an unevaluated default, so it does not clear a known mark;
negative IMPORT errors still apply. An IMPORT is installed before grant
processing, making equality with its stored sequence valid. Older
sequences cannot change quarantine state.

Loss of the reporting cap or session leaves the mark pending until an
MDS reply can authorize access. Session removal and reconnect compare
the reporter under i_ceph_lock, including when its cap is absent, so an
unrelated rank cannot demote the mark. State changes wake cap waiters.
Recovery from a retained IMPORT mark requires an eligible normal grant,
explicit disable or current metadata reply.

When marks exist, resolve inherited state with bounded RCU parent walks
and cache complete answers by generation. Unusable or incomplete aliases
require an MDS answer. The actual live superblock root terminates a walk
even though d_make_root() leaves it unhashed; foreign, disconnected,
unhashed non-root and secondary-root aliases cannot establish ancestry.
Validate parent walks against rename_lock without taking references.
Mark changes, renames and alias attachments invalidate cached answers;
sleeping splices exclude them without leaving the generation odd across
an LSM callback.

This supplies the notification and ancestry state consumed by the access
checks. Client quarantine support is advertised by the access patch.

Signed-off-by: Alex Markuze <amarkuze@redhat.com>
---
 fs/ceph/caps.c       | 128 +++++++++++-
 fs/ceph/dir.c        |   9 +
 fs/ceph/file.c       |   2 +
 fs/ceph/inode.c      | 483 ++++++++++++++++++++++++++++++++++++++++++-
 fs/ceph/mds_client.c |  21 +-
 fs/ceph/mds_client.h |  16 ++
 fs/ceph/super.c      |   2 +
 fs/ceph/super.h      |  71 ++++++-
 8 files changed, 721 insertions(+), 11 deletions(-)

diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index b27bcdc24d29ff7fc9da1ffe5442ef829b012f33..b07814d0038cd72a6fc10813f50846df58e9591a 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -689,11 +689,9 @@ void change_auth_cap_ses(struct ceph_inode_info *ci,
  *
  * Caller should hold session snap_rwsem (read) and ci->i_ceph_lock
  *
- * @fmode is the open file mode, if we are opening a file, otherwise
- * it is < 0.  (This is so we can atomically add the cap and add an
- * open file reference to it.)
+ * Returns false when the raw grant predates the recorded cap sequence.
  */
-void ceph_add_cap(struct inode *inode,
+bool ceph_add_cap(struct inode *inode,
 		  struct ceph_mds_session *session, u64 cap_id,
 		  unsigned issued, unsigned wanted,
 		  unsigned seq, unsigned mseq, u64 realmino, int flags,
@@ -706,6 +704,7 @@ void ceph_add_cap(struct inode *inode,
 	int mds = session->s_mds;
 	int actual_wanted;
 	u32 gen;
+	bool cap_current = true;
 
 	lockdep_assert_held(&ci->i_ceph_lock);
 
@@ -737,6 +736,7 @@ void ceph_add_cap(struct inode *inode,
 		atomic64_inc(&mdsc->metric.total_caps);
 		spin_unlock(&session->s_cap_lock);
 	} else {
+		cap_current = ceph_seq_cmp(seq, cap->seq) >= 0;
 		spin_lock(&session->s_cap_lock);
 		list_move_tail(&cap->session_caps, &session->s_caps);
 		spin_unlock(&session->s_cap_lock);
@@ -823,6 +823,7 @@ void ceph_add_cap(struct inode *inode,
 	cap->mseq = mseq;
 	cap->cap_gen = gen;
 	wake_up_all(&ci->i_cap_wq);
+	return cap_current;
 }
 
 /*
@@ -1264,6 +1265,11 @@ static void __ceph_remove_cap(struct ceph_inode_info *ci, struct ceph_cap *cap,
 
 	mdsc = ceph_inode_to_fs_client(&ci->netfs.inode)->mdsc;
 
+	/* Losing the reporting cap requires fresh MDS revalidation. */
+	if (READ_ONCE(ci->i_qtine_mds) == cap->mds &&
+	    ceph_quarantine_reset(ci))
+		wake_up_all(&ci->i_cap_wq);
+
 	/* remove from inode's cap rbtree, and clear auth cap */
 	rb_erase(&cap->ci_node, &ci->i_caps);
 	if (ci->i_auth_cap == cap)
@@ -3729,6 +3735,9 @@ struct cap_extra_info {
 	u8 *fscrypt_auth;
 	u32 fscrypt_auth_len;
 	u64 fscrypt_file_size;
+	/* MClientCaps v14 oserrno; valid only when oserrno_valid is set */
+	s32 oserrno;
+	bool oserrno_valid;
 };
 
 /*
@@ -3758,6 +3767,46 @@ static int parse_inline_data(void **p, void *end,
 }
 
 /*
+ * Record quarantine state carried by an MClientCaps oserrno.
+ * Caller holds i_ceph_lock. Returns true when waiters should be woken
+ * because quarantine changed or a pending reset was resolved.
+ *
+ * -EQUARANTINED refreshes the sticky flag and its reporting MDS rank.
+ * A current non-IMPORT grant above PIN with errno 0 clears that rank's mark.
+ * IMPORT may carry a default zero without assessing quarantine permission.
+ * Another rank needs a successful metadata request for the current epoch.
+ * A PIN-only update may zero qtine_errno while leaving the flag set.
+ */
+static bool ceph_apply_quarantine(struct ceph_inode_info *ci, int mds,
+				  int newcaps, int oserrno, bool is_import)
+{
+	bool was, now, pending;
+
+	was = READ_ONCE(ci->i_qtine_errno) == -CEPH_EQUARANTINED ||
+	      test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags);
+	pending = test_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags);
+
+	if (!is_import && (newcaps & ~CEPH_CAP_PIN) && was && oserrno == 0 &&
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
+/*
  * Handle a cap GRANT message from the MDS.  (Note that a GRANT may
  * actually be a revocation if it specifies a smaller cap set.)
  *
@@ -3781,6 +3830,7 @@ static void handle_cap_grant(struct inode *inode,
 	u64 max_size = le64_to_cpu(grant->max_size);
 	unsigned char check_caps = 0;
 	bool was_stale = cap->cap_gen < atomic_read(&session->s_cap_gen);
+	bool quarantine_current = ceph_seq_cmp(seq, cap->seq) >= 0;
 	bool wake = false;
 	bool writeback = false;
 	bool queue_trunc = false;
@@ -4128,6 +4178,17 @@ static void handle_cap_grant(struct inode *inode,
 			fill_inline = true;
 	}
 
+	/* Merged caps are not a fresh wire grant authorizing a clear. */
+	if (quarantine_current && extra_info->oserrno_valid &&
+	    ceph_apply_quarantine(ci, session->s_mds, le32_to_cpu(grant->caps),
+				  extra_info->oserrno,
+				  le32_to_cpu(grant->op) == CEPH_CAP_OP_IMPORT)) {
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
index 384e9edabe2a3a0cba8c56b07e04356f3a9920ff..d8c8b7ad893092611014b6094864a14bd36aecca 100644
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
index 856710c6376508d51a505c693fe3b3e1ab1e8896..9a6eadb94ab4f7e67d565b258e780129d9a505ff 100644
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
index 94f5215f8eed5927477ce59c4c9601013db9cfc0..048e0d502eb4ea361389bc4a6e5ddfa9fd9f6ac5 100644
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
@@ -730,10 +736,468 @@ struct inode *ceph_alloc_inode(struct super_block *sb)
 	return &ci->netfs.inode;
 }
 
+/*
+ * quarantine_epoch is a generation shared by every mark change and every
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
+ * cached answer is for this epoch. The superblock pins its live root,
+ * which d_make_root() leaves unhashed. Other unhashed or disconnected
+ * aliases, secondary roots and the depth limit leave the walk incomplete.
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
+		if (alias->d_sb != inode->i_sb ||
+		    (READ_ONCE(alias->d_flags) & DCACHE_DISCONNECTED))
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
+		if (d_unhashed(alias))
+			break;
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
@@ -759,6 +1223,8 @@ void ceph_evict_inode(struct inode *inode)
 	percpu_counter_dec(&mdsc->metric.total_inodes);
 
 	ci->i_subvolume_id = CEPH_SUBVOLUME_ID_NONE;
+	ceph_quarantine_forget_receipt(ci);
+	ceph_quarantine_clear(ci);
 
 	netfs_wait_for_outstanding_io(inode);
 	truncate_inode_pages_final(&inode->i_data);
@@ -1407,7 +1873,7 @@ int ceph_fill_inode(struct inode *inode, struct folio *locked_folio,
 	/* were we issued a capability? */
 	if (info_caps) {
 		if (!ceph_in_snap(inode)) {
-			ceph_add_cap(inode, session,
+			bool cap_current = ceph_add_cap(inode, session,
 				     le64_to_cpu(info->cap.cap_id),
 				     info_caps,
 				     le32_to_cpu(info->cap.wanted),
@@ -1416,6 +1882,14 @@ int ceph_fill_inode(struct inode *inode, struct folio *locked_folio,
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
@@ -1618,6 +2092,7 @@ static int splice_dentry(struct dentry **pdn, struct inode *in)
 		realdn = d_find_any_alias(in);
 		if (realdn) {
 			struct ceph_dentry_info *di = ceph_dentry(realdn);
+
 			spin_lock(&realdn->d_lock);
 
 			realdn->d_op->d_prune(realdn);
@@ -1634,7 +2109,9 @@ static int splice_dentry(struct dentry **pdn, struct inode *in)
 	/* dn must be unhashed */
 	if (!d_unhashed(dn))
 		d_drop(dn);
+	ceph_quarantine_splice_start(dn->d_sb);
 	realdn = d_splice_alias(in, dn);
+	ceph_quarantine_splice_finish(dn->d_sb);
 	if (IS_ERR(realdn)) {
 		pr_err_client(cl, "error %ld %p inode %p ino %llx.%llx\n",
 			      PTR_ERR(realdn), dn, in, ceph_vinop(in));
@@ -1859,6 +2336,7 @@ int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 		/* rename? */
 		if (req->r_old_dentry && req->r_op == CEPH_MDS_OP_RENAME) {
 			struct inode *olddir = req->r_old_dentry_dir;
+			struct inode *moved;
 			BUG_ON(!olddir);
 
 			boutc(cl, " src %p '%s' dst %p '%s'\n",
@@ -1869,7 +2347,10 @@ int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 			ceph_dir_clear_ordered(dir);
 			ceph_dir_clear_ordered(olddir);
 
+			moved = d_inode(req->r_old_dentry);
+			ceph_quarantine_move_start(moved, olddir, dir);
 			d_move(req->r_old_dentry, dn);
+			ceph_quarantine_move_finish(moved, olddir, dir);
 			boutc(cl, " src %p '%s' dst %p '%s'\n",
 			      req->r_old_dentry, req->r_old_dentry->d_name.name, dn, dn->d_name.name);
 
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index d4ef8a355a48090489cdacaf01cccbdcc0d8ed7d..5fec6e129d2822847c5dab6b2674560712db2765 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -2041,10 +2041,13 @@ static int remove_session_caps_cb(struct inode *inode, int mds, void *arg)
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	struct ceph_client *cl = ceph_inode_to_client(inode);
 	bool invalidate = false;
+	bool reset;
 	struct ceph_cap *cap;
 	int iputs = 0;
 
 	spin_lock(&ci->i_ceph_lock);
+	/* The reporter can outlive its cap; test the rank under the inode lock. */
+	reset = ci->i_qtine_mds == mds && ceph_quarantine_reset(ci);
 	cap = __get_cap_for_mds(ci, mds);
 	if (cap) {
 		boutc(cl, " removing cap %p, ci is %p, inode is %p\n",
@@ -2054,7 +2057,7 @@ static int remove_session_caps_cb(struct inode *inode, int mds, void *arg)
 	}
 	spin_unlock(&ci->i_ceph_lock);
 
-	if (cap)
+	if (cap || reset)
 		wake_up_all(&ci->i_cap_wq);
 	if (invalidate)
 		ceph_queue_invalidate(inode);
@@ -2860,6 +2863,7 @@ ceph_mdsc_create_request(struct ceph_mds_client *mdsc, int op, int mode)
 
 	mutex_init(&req->r_fill_mutex);
 	req->r_mdsc = mdsc;
+	req->r_quarantine_epoch = atomic64_read_acquire(&mdsc->quarantine_epoch);
 	req->r_started = jiffies;
 	req->r_start_latency = ktime_get();
 	req->r_resend_mds = -1;
@@ -5009,6 +5013,7 @@ static int reconnect_caps_cb(struct inode *inode, int mds, void *arg)
 	struct ceph_path_info path_info = {0};
 	int err;
 	u64 snap_follows;
+	bool reset = false;
 
 	dentry = d_find_primary(inode);
 	if (dentry) {
@@ -5023,9 +5028,13 @@ static int reconnect_caps_cb(struct inode *inode, int mds, void *arg)
 	}
 
 	spin_lock(&ci->i_ceph_lock);
+	/* Unrelated session recovery must not demote the current reporter's mark. */
+	reset = ci->i_qtine_mds == mds && ceph_quarantine_reset(ci);
 	cap = __get_cap_for_mds(ci, mds);
 	if (!cap) {
 		spin_unlock(&ci->i_ceph_lock);
+		if (reset)
+			wake_up_all(&ci->i_cap_wq);
 		err = 0;
 		goto out_err;
 	}
@@ -5088,6 +5097,8 @@ static int reconnect_caps_cb(struct inode *inode, int mds, void *arg)
 		snap_follows = capsnap->follows;
 	}
 	spin_unlock(&ci->i_ceph_lock);
+	if (reset)
+		wake_up_all(&ci->i_cap_wq);
 
 	if (recon_state->msg_version >= 2) {
 		int num_fcntl_locks, num_flock_locks;
@@ -6468,6 +6479,11 @@ int ceph_mdsc_init(struct ceph_fs_client *fsc)
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
@@ -7368,6 +7384,9 @@ static void mds_dispatch(struct ceph_connection *con, struct ceph_msg *msg)
 	case CEPH_MSG_CLIENT_QUOTA:
 		ceph_handle_quota(mdsc, s, msg);
 		break;
+	case CEPH_MSG_CLIENT_QUARANTINE_DISABLE:
+		ceph_handle_quarantine_disable(mdsc, s, msg);
+		break;
 
 	default:
 		pr_err_client(cl, "received unknown message type %d %s\n",
diff --git a/fs/ceph/mds_client.h b/fs/ceph/mds_client.h
index 863cdb8d588ae3121f31d84a7a4f049e73c0d05f..816f5f2d32ccf19b8d0644a3d5c24a730fd1015b 100644
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
index 40be4b16e486ff0e6b5eb63e1caaa6870df7140e..ad9460d9673cb18230d8fbcb93a27aa26f7ace38 100644
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
index 458fd63dd79f7d73402188b5ba67645662e720ee..0264bd9d705fcb1bc904d0fc7fc94be2b6de3c66 100644
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

