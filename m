Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792953789;
	b=BKn6XvSTLtv99uZmXEZeiOFRlZ6xDsBc3MPGkiw9g4FiGd5ksVtlzDd5VZmvAPKpSgyl
	 ERU0y0mppqrhIB4nZ/t0JRAPRirpGtu2Kf3nZp2ojE9hEPND2Q5+I6//1AmlPfFYGRRLv
	 aXsZQQZAsDW4ZwtBvE8xdCdGDSrm9BRX7yHPp+ZuiZ3Q0pGw0vEA75nloraiyUDZpdSW1
	 fGbMcHbLpFQmnjNn75UwTmneiVw0BVQ3Wq81a9vZWX/qoK8XOPvOQYu9KpQMT9yc/2mMy
	 1aesJNxKxDGN3XZyDszIzBxrdatbRjx0WWbW0inqOvS5OhCYm07J7OPuxHo4ejZj9CA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792953789;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=TB1W+dP5wrOw6pt6iQvasea+NOM8getnhPjrpQVqJK8=;
	b=J8Qwwq8QyC53jb6Xq/MGQpoHMETqe8hkN1msZTuc8Q4gi8pJk+0wZeyxPhx6b+GYMRyD
	 TyC7OprPMpuC3C4rv9m1V6KyawSZZKmyujiTdHo/05dj1edn8U/qahNmV+Cw643o+a9tu
	 Dm5XdKqnsRkKG63Zu3J2gE/DKByjYrViG+if6MDF/DNEKyiuPKAsYx9wBgyLa0bG4Kl6o
	 pnV6VINsDQl5oU1qM4Eks+RxLXZluZtRnVR/dZ0w8EibZb5gfOaBG0tlMA+208kk34EK6
	 AEQp0J5IiNDVYnQkN63VdI6mkitAAOP+DL+jeNgK84xPkjnWP4GsX7PY5oL7HP63iBQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=ZOMpUnr1;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=M6Dc0Sva;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F972606A31D
	for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 18:43:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6F972606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=ZOMpUnr1;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=M6Dc0Sva
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792953782;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=TB1W+dP5wrOw6pt6iQvasea+NOM8getnhPjrpQVqJK8=;
	b=ZOMpUnr1katlI4cA1ztjpGirWWb+RFsOyTnexoaglWdvbgRAJLMUlrVrFElNq0Tu8Dryzb
	i4Sf5arFxHjTQxbQySTH6ppFNfZUqcesydOKQB69/g6cZ2Og3PWoXfe+72Fuj9Gp1YE9Nq
	YpdmLeCJuSW3sVBnxlNDXQXz+S+dmQA=
Received: from mail-ej1-f72.google.com (mail-ej1-f72.google.com
 [209.85.218.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-172-gCzjyFNMOxaZRjbOcTVJpg-1; Sun, 25 Oct 2026 14:42:58 -0400
X-MC-Unique: gCzjyFNMOxaZRjbOcTVJpg-1
X-Mimecast-MFC-AGG-ID: gCzjyFNMOxaZRjbOcTVJpg_1792953778
Received: by mail-ej1-f72.google.com with SMTP id a640c23a62f3a-c25501f4aa2so287581066b.1
        for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 11:42:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792953777; x=1793558577; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=TB1W+dP5wrOw6pt6iQvasea+NOM8getnhPjrpQVqJK8=;
        b=M6Dc0SvaJLA6Mhfsqt/qWmzMdMoHAeoqo2sWexMSoje1DheiWrmhC/Cc7lfgkSFEz/
         4qQqBmZPjZVDhIxUr+0w1jXKWdfEwXjwAcB28dkvlzjhM3T2TA0HpRHH2c650xDmakZR
         FbeMTvFRdiAKLa/xZu1Xp+VNmjRI0awe7aQwtUS/dSt+i3SUgd1Ww1wLH6EFbD3M/2ws
         wtffL4ObsUF7dKFWAia7zkp9yIYFNcA57ZT0GZn1F6w3UbZ5dY9R/rNqOP1KWobF/hDz
         4VnGxPiNBKa9PAE8SrVoz5MA5LmQumTT6fPJWtdGb48mPxrLLvvNJNbZodKZ/JeSMiO+
         qvKQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792953777; x=1793558577;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=TB1W+dP5wrOw6pt6iQvasea+NOM8getnhPjrpQVqJK8=;
        b=N4Nz5kDrASRLTx0aSs2CkGPYMAJY/mV5QvBuTu1nDdjCgeExQMpDicu8w4oH2laGbL
         woLUUVgAkO+EsgQ99TVFpf8SKDouLzBDZbm9NzzgtDM867J4HQUYym5XVNJpRr6Dp/uj
         0UVR/zBPdTyo4BrBn5f3l6pH75DsBW14+7HL+CQmgkoCy4NQr35bBFQLcXelcP+6Q4cE
         4ToC4TTB0LiaVGZwzRWfblwMKm+NcSsEMUF1KRRtXA4OKfWz4gTYsyQxHxPadBNXvvnx
         xhd2QDg9NKWCyFdqReL+G165j+FvKtX4q/GvRgtXyvltIFIouUcjzX6EByNNLzvWWqjr
         LBXA==
X-Forwarded-Encrypted: i=1; AKwUvBwRdrfNzZUbDjMsPsxoS6lhaS8Agc5e8ihcDLxaJlzxRGCNtHvR7RgJDlekqzyk4O01L8zn0XS51Kv/7TF5@vger.kernel.org
X-Gm-Message-State: AFq9FYIAc7OSfqk6CBV99g9UuoP32ezg1b/xbl2wnUOzQ2MeMwjcBNz+
	MhpgGvNT4IphrIGQrWLGoIezdidepG8LIhkJr6FzW+lBjDh5QO8iZk9vgM9LgLyUi9E1sLEzql1
	izCYzq6AfCItr0x2JJM/obpBRs6TyjTgt9Y6pM49fMcAGl+XiHnoFyYqHoA7/8YY4Cp0+4MgDuV
	ObAw==
X-Gm-Gg: AYBFou1IcbB54zUGnsCCcas5J4cz6KeL0NZ2udh9WSxziV5BxlID7QRIYceLm/liTYq
	p0KjasxGiL+iJuR/eYGkiHOtYCPwMAmNbQVUkeQ8FhoMvscWQ2M/hZ36RAliepQiPDuWnGYLJ6N
	6wgzGyZRE0G+95G//YBxota2qWPeAP7N59BubJJqNkmT/AQqBHxlKnBPVOawz0pJkRY4iB+3Cq8
	NF6w/aelUUfUftFBBIjKT65SopXUJcEupidfK5Coz88RNv+xNKTGrNf7deuUOXK39Z14shE72M1
	jcp50EUkl3gUcEGkAH4mEP6zreIq2tapSmTKwBcu6hEHc6V1cB1GnM56a6dX9q+VqhY3BPoLerZ
	npNeWTW0dTY90h6YYxpVpNaTaISeFvx/JkTZdaGtw45It43Rh3os0mR1a9xhmVwtclP9/567FCR
	zB3KSsufplJKkgaof1KEnULHT6OEg2vuPyoZCPBY4w7YG/VjUsaBhA1aFVOmJ9GQA5SkxH41zGd
	A0=
X-Received: by 2002:a17:907:f48b:b0:c42:bc58:f21 with SMTP id a640c23a62f3a-c46be5bfa80mr535482766b.15.1792953776614;
        Sun, 25 Oct 2026 11:42:56 -0700 (PDT)
X-Received: by 2002:a17:907:f48b:b0:c42:bc58:f21 with SMTP id a640c23a62f3a-c46be5bfa80mr535479266b.15.1792953775792;
        Sun, 25 Oct 2026 11:42:55 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c46bd66e51fsm230750866b.64.2026.10.25.11.42.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 25 Oct 2026 11:42:55 -0700 (PDT)
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
Subject: [PATCH v6 5/5] ceph: fail quarantined subvolume access with EACCES
Date: Sun, 25 Oct 2026 18:42:45 +0000
Message-Id: <ddf9dfb3e012576caa6953b42f5ce86adae14f95.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
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

Cached data, metadata and immutable snapshot capabilities can satisfy
VFS operations without consulting the MDS. A quarantine-aware client
must apply the MDS's restrictions to those paths before advertising
CEPHFS_FEATURE_QUARANTINE, so denied access returns EACCES while clients
with the appropriate q/Q MDS auth caps can perform recovery.

Reject cached access to directly marked inodes. Incomplete ancestry and
inherited marks require MDS authorization. Read confirmations are scoped
to the inode, credentials and namespace generation; writes require a
mode-specific OPEN. Saved authorization requires the same even generation
and no active splice. Revalidate after cap waits and lock drops, rolling
back provisional cap references when authorization expires. Nonblocking
acquisition performs no RPC, and locked folios are released before
blocking revalidation.

Cached head metadata requires a live AUTH_SHARED cap from a quarantine-
aware authoritative MDS. Without that revocation coverage, stat,
directory and encryption-policy/nonce ioctl access forces authoritative
GETATTR. A successful reply can authorize its current operation without
granting reusable cache capabilities.

Snapshot cache access requires a connected head inode matching the
target's MDS-provided subvolume ID, a valid authoritative AUTH_SHARED cap
and no local quarantine marks. Other head ancestors, unknown membership,
32-bit clients, detached snapshots and expired caps require an MDS answer.
Connected requests encode the snapshot path; disconnected requests use
LOOKUPINO with the exact inode and snapshot ID. Check reply identity and
required payloads, and perform normal wanted-cap acquisition after the
snapshot authorization check. Installed snapshot PTEs still depend on
server notifications for revocation.

Wait interruptibly for namespace writers and retry invalidated blocking
read/readdir authorizations. Splice-owner tracking and the fill-trace
recursion guard reject self-waits. Negotiated quarantine support enables
VFS ACL cache suppression and namespace mutation bookkeeping; the first
supporting session invalidates cached ACLs, and mutation tokens remain
paired across feature activation and reconnects.

LSM label reads during inode instantiation can wait for async CREATE
completion. Select synchronous CREATE before async preparation whenever
the new inode has a security blob, including before feature negotiation
because quarantine can activate after submission. Blob-free async CREATE
and async unlink use their normal admission rules.

Gate cached xattr and mmap access, and carry inherited ACLs in the encoded
xattr blob. Failed ACL installation returns ENOMEM. Detached xattr-buffer
ownership ends when its reference is released, including allocation retry
and cleanup paths. Uncertain async mutations are submitted to the MDS.

Select fscrypt's symlink-cache opt-out so encrypted readlink, traversal
and lstat reach ->get_link() revalidation. Targets are decrypted into a
temporary allocation without installing i_link. Fresh metadata replies
also allow recovery after a lost quarantine-disable notification.

Signed-off-by: Alex Markuze <amarkuze@redhat.com>
---
 fs/ceph/acl.c        |  33 ++-
 fs/ceph/addr.c       |  72 ++++--
 fs/ceph/caps.c       | 195 ++++++++++++++-
 fs/ceph/crypto.c     |   1 +
 fs/ceph/debugfs.c    |   1 +
 fs/ceph/dir.c        |  57 +++--
 fs/ceph/file.c       |  84 ++++++-
 fs/ceph/inode.c      | 547 ++++++++++++++++++++++++++++++++++++++-----
 fs/ceph/ioctl.c      |  13 +
 fs/ceph/mds_client.c |   5 +
 fs/ceph/mds_client.h |  14 +-
 fs/ceph/super.c      |   6 +-
 fs/ceph/super.h      |  42 +++-
 fs/ceph/xattr.c      |  60 ++++-
 14 files changed, 1000 insertions(+), 130 deletions(-)

diff --git a/fs/ceph/acl.c b/fs/ceph/acl.c
index dbc64ab6030881c799fe906e3ee492f08d7752a6..14feb719a1cf0006e855f14460b74c8e1e19adb2 100644
--- a/fs/ceph/acl.c
+++ b/fs/ceph/acl.c
@@ -18,18 +18,45 @@
 #include "mds_client.h"
 
 static inline void ceph_set_cached_acl(struct inode *inode,
-					int type, struct posix_acl *acl)
+				       int type, struct posix_acl *acl)
 {
 	struct ceph_inode_info *ci = ceph_inode(inode);
 
 	spin_lock(&ci->i_ceph_lock);
-	if (__ceph_caps_issued_mask_metric(ci, CEPH_CAP_XATTR_SHARED, 0))
+	if (!READ_ONCE(ceph_sb_to_mdsc(inode->i_sb)->quarantine_supported) &&
+	    __ceph_caps_issued_mask_metric(ci, CEPH_CAP_XATTR_SHARED, 0))
 		set_cached_acl(inode, type, acl);
 	else
 		forget_cached_acl(inode, type);
 	spin_unlock(&ci->i_ceph_lock);
 }
 
+void ceph_quarantine_uncache_inode_acls(struct inode *inode)
+{
+	struct ceph_inode_info *ci = ceph_inode(inode);
+	struct posix_acl *acl, *default_acl;
+
+	spin_lock(&ci->i_ceph_lock);
+	acl = xchg(&inode->i_acl, ACL_DONT_CACHE);
+	default_acl = xchg(&inode->i_default_acl, ACL_DONT_CACHE);
+	spin_unlock(&ci->i_ceph_lock);
+	if (!is_uncached_acl(acl))
+		posix_acl_release(acl);
+	if (!is_uncached_acl(default_acl))
+		posix_acl_release(default_acl);
+}
+
+void ceph_quarantine_disable_acl_cache(struct super_block *sb)
+{
+	struct inode *inode;
+
+	/* Cover inodes cached before the first supporting session opened. */
+	spin_lock(&sb->s_inode_list_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list)
+		ceph_quarantine_uncache_inode_acls(inode);
+	spin_unlock(&sb->s_inode_list_lock);
+}
+
 struct posix_acl *ceph_get_acl(struct inode *inode, int type, bool rcu)
 {
 	struct ceph_client *cl = ceph_inode_to_client(inode);
@@ -73,6 +100,8 @@ struct posix_acl *ceph_get_acl(struct inode *inode, int type, bool rcu)
 		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 	} else if (size == -ENODATA || size == 0) {
 		acl = NULL;
+	} else if (size == -EACCES) {
+		acl = ERR_PTR(-EACCES);
 	} else {
 		pr_err_ratelimited_client(cl, "%llx.%llx failed, err=%d\n",
 					  ceph_vinop(inode), size);
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index dd2bd8ed242499183d6d3acd250affc56095b5ca..79e396752601f5bffb9f4cdc2150d21ce37ab701 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -540,6 +540,10 @@ static int ceph_init_request(struct netfs_io_request *rreq, struct file *file)
 			want |= CEPH_CAP_FILE_LAZYIO;
 	}
 
+	/*
+	 * NETFS_READPAGE is synchronous. ceph_read_folio() holds caps for
+	 * its duration, including the authorization for a snapshot read.
+	 */
 	if (rreq->origin == NETFS_READAHEAD) {
 		/*
 		 * readahead callers do not necessarily hold Fcb caps
@@ -563,21 +567,6 @@ static int ceph_init_request(struct netfs_io_request *rreq, struct file *file)
 			ret = -EACCES;
 			goto out;
 		}
-	} else {
-		/*
-		 * Make sure we have caps, just in case read_folio was
-		 * called directly (e.g. by erofs) which may have
-		 * bypassed the usual Ceph cap checks.  This branch
-		 * uses __ceph_get_caps() which blocks until the
-		 * required cap has been granted.
-		 */
-		ret = __ceph_get_caps(inode, fi, CEPH_CAP_FILE_RD, want, -1,
-				      &got);
-		if (ret < 0) {
-			boutc(cl, "%llx.%llx, error getting cap\n",
-			      ceph_vinop(inode));
-			goto out;
-		}
 	}
 
 	priv->caps = got;
@@ -2069,8 +2058,44 @@ static int ceph_write_end(const struct kiocb *iocb,
 	return copied;
 }
 
+/* Direct read_folio callers may not have entered through read_iter or fault. */
+static int ceph_read_folio(struct file *file, struct folio *folio)
+{
+	struct address_space *mapping = folio->mapping;
+	struct inode *inode = mapping->host;
+	struct ceph_file_info *fi = file ? file->private_data : NULL;
+	int want = CEPH_CAP_FILE_CACHE;
+	int got, ret;
+
+	if (fi && ceph_find_rw_context(fi))
+		return netfs_read_folio(file, folio);
+
+	if (fi && (fi->fmode & CEPH_FILE_MODE_LAZY))
+		want |= CEPH_CAP_FILE_LAZYIO;
+
+	/* A blocking getattr can fill inline data into this folio. */
+	folio_unlock(folio);
+	got = 0;
+	ret = __ceph_get_caps(inode, fi, CEPH_CAP_FILE_RD, want, -1, &got);
+	if (ret < 0)
+		return ret;
+
+	folio_lock(folio);
+	if (folio->mapping != mapping) {
+		folio_unlock(folio);
+		ret = AOP_TRUNCATED_PAGE;
+	} else if (folio_test_uptodate(folio)) {
+		folio_unlock(folio);
+		ret = 0;
+	} else {
+		ret = netfs_read_folio(file, folio);
+	}
+	ceph_put_cap_refs(ceph_inode(inode), got);
+	return ret;
+}
+
 const struct address_space_operations ceph_aops = {
-	.read_folio = netfs_read_folio,
+	.read_folio = ceph_read_folio,
 	.readahead = netfs_readahead,
 	.writepages = ceph_writepages_start,
 	.write_begin = ceph_write_begin,
@@ -2649,9 +2674,24 @@ static const struct vm_operations_struct ceph_vmops = {
 int ceph_mmap_prepare(struct vm_area_desc *desc)
 {
 	struct address_space *mapping = desc->file->f_mapping;
+	struct inode *inode = file_inode(desc->file);
+	int err, got = 0;
 
 	if (!mapping->a_ops->read_folio)
 		return -ENOEXEC;
+	err = ceph_quarantine_revalidate(inode);
+	if (err)
+		return err;
+	if (vma_desc_test_all(desc, VMA_SHARED_BIT, VMA_WRITE_BIT) &&
+	    ceph_inode_quarantine_write_state(inode) != CEPH_Q_CLEAR) {
+		/* A read receipt cannot admit a writable shared mapping. */
+		err = ceph_get_caps(desc->file, CEPH_CAP_FILE_WR, 0, -1, &got);
+		if (err)
+			return err;
+		ceph_put_cap_refs(ceph_inode(inode), got);
+	}
+	if (ceph_inode_quarantine_direct(inode))
+		return -EACCES;
 	desc->vm_ops = &ceph_vmops;
 	return 0;
 }
diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index b07814d0038cd72a6fc10813f50846df58e9591a..7c85e84fa6493079244e56fb251af4c2740a47ee 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -3007,10 +3007,39 @@ enum {
 	/* first 8 bits are reserved for CEPH_FILE_MODE_FOO */
 	NON_BLOCKING	= (1 << 8),
 	CHECK_FILELOCK	= (1 << 9),
+	MDS_AUTHORIZED	= (1 << 10),
 };
 
+bool ceph_quarantine_head_cap_valid(struct inode *inode)
+{
+	struct ceph_inode_info *ci = ceph_inode(inode);
+	struct ceph_cap *cap;
+	bool valid;
+
+	spin_lock(&ci->i_ceph_lock);
+	cap = ci->i_auth_cap;
+	valid = cap && __cap_is_valid(ci, cap) &&
+		test_bit(CEPHFS_FEATURE_QUARANTINE, &cap->session->s_features) &&
+		(cap->issued & CEPH_CAP_AUTH_SHARED);
+	spin_unlock(&ci->i_ceph_lock);
+	return valid;
+}
+
+static bool ceph_cap_auth_valid(struct ceph_mds_client *mdsc, u64 epoch)
+{
+	/*
+	 * Order authorization and cap observations before checking the saved
+	 * generation. Moves and splices can invalidate it even with no marks.
+	 * The epoch updates in the writer and splice boundaries are ordered RMWs.
+	 */
+	smp_rmb();
+	return !(epoch & 1) &&
+	       (u64)atomic64_read_acquire(&mdsc->quarantine_epoch) == epoch &&
+	       !atomic_read(&mdsc->quarantine_splices);
+}
+
 static int try_get_cap_refs(struct inode *inode, int need, int want,
-			    loff_t endoff, int flags, int *got)
+			    loff_t endoff, int flags, u64 qepoch, int *got)
 {
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	struct ceph_mds_client *mdsc = ceph_inode_to_fs_client(inode)->mdsc;
@@ -3026,6 +3055,15 @@ static int try_get_cap_refs(struct inode *inode, int need, int want,
 again:
 	spin_lock(&ci->i_ceph_lock);
 
+	if (ceph_inode_quarantine_direct(inode)) {
+		ret = -EACCES;
+		goto out_unlock;
+	}
+	if ((flags & MDS_AUTHORIZED) && !ceph_cap_auth_valid(mdsc, qepoch)) {
+		ret = -EAGAIN;
+		goto out_unlock;
+	}
+
 	if ((flags & CHECK_FILELOCK) &&
 	    test_bit(CEPH_I_ERROR_FILELOCK_BIT, &ci->i_ceph_flags)) {
 		doutc(cl, "%p %llx.%llx error filelock\n", inode,
@@ -3047,6 +3085,15 @@ static int try_get_cap_refs(struct inode *inode, int need, int want,
 		}
 		__ceph_do_pending_vmtruncate(inode);
 		spin_lock(&ci->i_ceph_lock);
+		if (ceph_inode_quarantine_direct(inode)) {
+			ret = -EACCES;
+			goto out_unlock;
+		}
+		if ((flags & MDS_AUTHORIZED) &&
+		    !ceph_cap_auth_valid(mdsc, qepoch)) {
+			ret = -EAGAIN;
+			goto out_unlock;
+		}
 	}
 
 	have = __ceph_caps_issued(ci, &implemented);
@@ -3195,6 +3242,31 @@ static int try_get_cap_refs(struct inode *inode, int need, int want,
 	if (snap_rwsem_locked)
 		up_read(&mdsc->snap_rwsem);
 
+	/* References remain provisional across truncate, cap waits and lock drops. */
+	if (ret == 1) {
+		enum ceph_qstate qstate = CEPH_Q_CLEAR;
+
+		if (!(flags & MDS_AUTHORIZED) &&
+		    ceph_snapshot_needs_revalidate(inode))
+			qstate = CEPH_Q_UNKNOWN;
+		else if (!(flags & MDS_AUTHORIZED))
+			qstate = need & CEPH_CAP_FILE_WR ?
+				ceph_inode_quarantine_write_state(inode) :
+				ceph_inode_quarantine_state(inode);
+		else if (!ceph_cap_auth_valid(mdsc, qepoch))
+			qstate = CEPH_Q_UNKNOWN;
+		/* An MDS answer cannot override a new negative on this inode. */
+		if (ceph_inode_quarantine_direct(inode))
+			qstate = CEPH_Q_UNDER;
+
+		if (qstate != CEPH_Q_CLEAR) {
+			ceph_put_cap_refs(ci, *got);
+			*got = 0;
+			ret = qstate == CEPH_Q_UNDER &&
+			      ceph_inode_quarantine_direct(inode) ? -EACCES : -EAGAIN;
+		}
+	}
+
 	if (!ret)
 		ceph_update_cap_mis(&mdsc->metric);
 	else if (ret == 1)
@@ -3263,17 +3335,34 @@ int ceph_try_get_caps(struct inode *inode, int need, int want,
 	BUG_ON(want & ~(CEPH_CAP_FILE_CACHE | CEPH_CAP_FILE_LAZYIO |
 			CEPH_CAP_FILE_SHARED | CEPH_CAP_FILE_EXCL |
 			CEPH_CAP_ANY_DIR_OPS));
+	/* Immutable snapshot caps have no MDS revoke notifications. */
+	if (ceph_snapshot_needs_revalidate(inode))
+		return 0;
+
 	if (need) {
 		ret = ceph_pool_perm_check(inode, need);
 		if (ret < 0)
 			return ret;
 	}
 
+	switch (ceph_inode_quarantine_state(inode)) {
+	case CEPH_Q_UNDER:
+		return ceph_inode_quarantine_direct(inode) ? -EACCES : 0;
+	case CEPH_Q_UNKNOWN:
+		/*
+		 * Callers may hold locked folios or another inode's caps.
+		 * Leave blocking revalidation to ceph_get_caps().
+		 */
+		return 0;
+	default:
+		break;
+	}
+
 	flags = get_used_fmode(need | want);
 	if (nonblock)
 		flags |= NON_BLOCKING;
 
-	ret = try_get_cap_refs(inode, need, want, 0, flags, got);
+	ret = try_get_cap_refs(inode, need, want, 0, flags, 0, got);
 	/* three special error codes */
 	if (ret == -EAGAIN || ret == -EFBIG || ret == -EUCLEAN)
 		ret = 0;
@@ -3290,6 +3379,9 @@ int __ceph_get_caps(struct inode *inode, struct ceph_file_info *fi, int need,
 {
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	struct ceph_fs_client *fsc = ceph_inode_to_fs_client(inode);
+	struct ceph_mds_client *mdsc = fsc->mdsc;
+	bool snapshot = ceph_in_snap(inode) && ceph_snap(inode) != CEPH_SNAPDIR;
+	u64 qepoch = 0;
 	int ret, _got, flags;
 
 	ret = ceph_pool_perm_check(inode, need);
@@ -3304,15 +3396,71 @@ int __ceph_get_caps(struct inode *inode, struct ceph_file_info *fi, int need,
 
 	while (true) {
 		flags &= CEPH_FILE_MODE_MASK;
+		if (snapshot && ceph_snapshot_needs_revalidate(inode)) {
+			/*
+			 * i_snap_caps cannot be revoked, and an idle snapshot
+			 * inode may receive no quarantine notification at all.
+			 * An MDS answer authorizes only this acquisition.
+			 */
+			qepoch = atomic64_read_acquire(&mdsc->quarantine_epoch);
+			if (!ceph_cap_auth_valid(mdsc, qepoch)) {
+				ret = ceph_quarantine_wait(inode);
+				if (ret)
+					return ret;
+				continue;
+			}
+			ret = ceph_snapshot_read_auth(inode);
+			if (ret)
+				return ret;
+			flags |= MDS_AUTHORIZED;
+		} else {
+			enum ceph_qstate qstate = need & CEPH_CAP_FILE_WR ?
+				ceph_inode_quarantine_write_state(inode) :
+				ceph_inode_quarantine_state(inode);
+
+			switch (qstate) {
+			case CEPH_Q_UNDER:
+				if (ceph_inode_quarantine_direct(inode))
+					return -EACCES;
+				fallthrough;
+			case CEPH_Q_UNKNOWN:
+				if (!(need & CEPH_CAP_FILE_WR)) {
+					ret = ceph_quarantine_revalidate(inode);
+					if (ret)
+						return ret;
+					continue;
+				}
+				/* A GETATTR receipt cannot authorize writes. */
+				qepoch = atomic64_read_acquire(&mdsc->quarantine_epoch);
+				if (!ceph_cap_auth_valid(mdsc, qepoch)) {
+					ret = ceph_quarantine_wait(inode);
+					if (ret)
+						return ret;
+					continue;
+				}
+				ret = ceph_renew_caps(inode, flags, true);
+				if (ret)
+					return ret;
+				flags |= MDS_AUTHORIZED;
+				break;
+			default:
+				break;
+			}
+		}
+
 		if (vfs_inode_has_locks(inode))
 			flags |= CHECK_FILELOCK;
 		_got = 0;
 		ret = try_get_cap_refs(inode, need, want, endoff,
-				       flags, &_got);
-		WARN_ON_ONCE(ret == -EAGAIN);
+				       flags, qepoch, &_got);
+		if (ret == -EAGAIN) {
+			ret = ceph_quarantine_wait(inode);
+			if (ret)
+				return ret;
+			continue;
+		}
 		if (!ret) {
 #ifdef CONFIG_DEBUG_FS
-			struct ceph_mds_client *mdsc = fsc->mdsc;
 			struct cap_wait cw;
 #endif
 			DEFINE_WAIT_FUNC(wait, woken_wake_function);
@@ -3333,8 +3481,33 @@ int __ceph_get_caps(struct inode *inode, struct ceph_file_info *fi, int need,
 			add_wait_queue(&ci->i_cap_wq, &wait);
 
 			flags |= NON_BLOCKING;
-			while (!(ret = try_get_cap_refs(inode, need, want,
-							endoff, flags, &_got))) {
+			while (true) {
+				enum ceph_qstate qstate = CEPH_Q_CLEAR;
+
+				if (!(flags & MDS_AUTHORIZED))
+					qstate = need & CEPH_CAP_FILE_WR ?
+						ceph_inode_quarantine_write_state(inode) :
+						ceph_inode_quarantine_state(inode);
+				else if (!ceph_cap_auth_valid(mdsc, qepoch))
+					qstate = CEPH_Q_UNKNOWN;
+				if (ceph_inode_quarantine_direct(inode))
+					qstate = CEPH_Q_UNDER;
+				switch (qstate) {
+				case CEPH_Q_UNDER:
+					ret = ceph_inode_quarantine_direct(inode) ?
+						-EACCES : -EAGAIN;
+					break;
+				case CEPH_Q_UNKNOWN:
+					/* Revalidate outside the cap wait. */
+					ret = -EAGAIN;
+					break;
+				default:
+					ret = try_get_cap_refs(inode, need, want,
+							       endoff, flags, qepoch, &_got);
+					break;
+				}
+				if (ret)
+					break;
 				if (signal_pending(current)) {
 					ret = -ERESTARTSYS;
 					break;
@@ -3363,8 +3536,12 @@ int __ceph_get_caps(struct inode *inode, struct ceph_file_info *fi, int need,
 			spin_unlock(&mdsc->caps_list_lock);
 #endif
 
-			if (ret == -EAGAIN)
+			if (ret == -EAGAIN) {
+				ret = ceph_quarantine_wait(inode);
+				if (ret)
+					return ret;
 				continue;
+			}
 		}
 
 		if (fi && (fi->fmode & CEPH_FILE_MODE_WR) &&
@@ -3387,7 +3564,7 @@ int __ceph_get_caps(struct inode *inode, struct ceph_file_info *fi, int need,
 			if (ret == -EUCLEAN) {
 				/* session was killed or a waited cap
 				 * request needs a retry */
-				ret = ceph_renew_caps(inode, flags);
+				ret = ceph_renew_caps(inode, flags, false);
 				if (ret == 0)
 					continue;
 			}
diff --git a/fs/ceph/crypto.c b/fs/ceph/crypto.c
index 9e0ebb0718404fdb6e9ec1be2fac898158a3f5ae..de786a0e626c763787bfafda59cc42e7b7ff4f5c 100644
--- a/fs/ceph/crypto.c
+++ b/fs/ceph/crypto.c
@@ -92,6 +92,7 @@ static struct fscrypt_operations ceph_fscrypt_ops = {
 	.inode_info_offs	= (int)offsetof(struct ceph_inode_info, i_crypt_info) -
 				  (int)offsetof(struct ceph_inode_info, netfs.inode),
 	.needs_bounce_pages	= 1,
+	.no_symlink_cache	= 1,
 	.get_context		= ceph_crypt_get_context,
 	.set_context		= ceph_crypt_set_context,
 	.get_dummy_policy	= ceph_get_dummy_policy,
diff --git a/fs/ceph/debugfs.c b/fs/ceph/debugfs.c
index 6a9a5551d9d71d5adf2349daad01ee1adedd1a82..ef10e948a2d3427af9b0f532bebf3aa119f8de84 100644
--- a/fs/ceph/debugfs.c
+++ b/fs/ceph/debugfs.c
@@ -53,6 +53,7 @@ static const struct ceph_session_feature_desc ceph_session_feature_table[] = {
 	{ CEPHFS_FEATURE_HAS_OWNER_UIDGID, "HAS_OWNER_UIDGID" },
 	{ CEPHFS_FEATURE_MDS_AUTH_CAPS_CHECK, "MDS_AUTH_CAPS_CHECK" },
 	{ CEPHFS_FEATURE_SUBVOLUME_METRICS, "SUBVOLUME_METRICS" },
+	{ CEPHFS_FEATURE_QUARANTINE, "QUARANTINE" },
 };
 
 static int mdsmap_show(struct seq_file *s, void *p)
diff --git a/fs/ceph/dir.c b/fs/ceph/dir.c
index d8c8b7ad893092611014b6094864a14bd36aecca..d0687e731dea633d0d791cb416f6a72cfd19b170 100644
--- a/fs/ceph/dir.c
+++ b/fs/ceph/dir.c
@@ -349,6 +349,13 @@ static int ceph_readdir(struct file *file, struct dir_context *ctx)
 
 	ceph_blog_enter(fsc, &__ji);
 
+	/* Validate before returning cached entries, dots, or end-of-directory. */
+	err = ceph_quarantine_revalidate(inode);
+	if (err) {
+		ceph_blog_exit(&__ji);
+		return err;
+	}
+
 	boutc(cl, "%p %llx.%llx file %p pos %llx\n", inode,
 	      ceph_vinop(inode), file, ctx->pos);
 	if (dfi->file_info.flags & CEPH_F_ATEND) {
@@ -785,6 +792,7 @@ static loff_t ceph_dir_llseek(struct file *file, loff_t offset, int whence)
 struct dentry *ceph_handle_snapdir(struct ceph_mds_request *req,
 				   struct dentry *dentry)
 {
+	struct ceph_quarantine_splice qsplice;
 	struct ceph_fs_client *fsc = ceph_sb_to_fs_client(dentry->d_sb);
 	struct inode *parent = d_inode(dentry->d_parent); /* we hold i_rwsem */
 	struct ceph_client *cl = ceph_inode_to_client(parent);
@@ -795,9 +803,9 @@ struct dentry *ceph_handle_snapdir(struct ceph_mds_request *req,
 		struct dentry *res;
 		struct inode *inode = ceph_get_snapdir(parent);
 
-		ceph_quarantine_splice_start(parent->i_sb);
+		ceph_quarantine_splice_start(parent->i_sb, &qsplice);
 		res = d_splice_alias(inode, dentry);
-		ceph_quarantine_splice_finish(parent->i_sb);
+		ceph_quarantine_splice_finish(&qsplice);
 		boutc_formats(cl,
 			      "ENOENT on snapdir %p '%s', linking to snapdir %p %llx.%llx. Spliced dentry %p\n",
 			      "ENOENT on snapdir %p '%pd', linking to snapdir %p %llx.%llx. Spliced dentry %p\n",
@@ -904,8 +912,13 @@ static struct dentry *ceph_lookup(struct inode *dir, struct dentry *dentry,
 			ceph_dir_clear_complete(dir);
 	}
 
-	/* can we conclude ENOENT locally? */
-	if (d_really_is_negative(dentry)) {
+	/*
+	 * A marked directory, or one whose parents are not cached,
+	 * must not answer from the complete-dir cache. The MDS reply
+	 * is what clears a lost disable.
+	 */
+	if (d_really_is_negative(dentry) &&
+	    ceph_inode_quarantine_state(dir) == CEPH_Q_CLEAR) {
 		struct ceph_inode_info *ci = ceph_inode(dir);
 		struct ceph_dentry_info *di = ceph_dentry(dentry);
 
@@ -1068,9 +1081,7 @@ static int ceph_mknod(struct mnt_idmap *idmap, struct inode *dir,
 out_req:
 	ceph_mdsc_put_request(req);
 out:
-	if (!err)
-		ceph_init_inode_acls(d_inode(dentry), &as_ctx);
-	else
+	if (err)
 		d_drop(dentry);
 	ceph_release_acl_sec_ctx(&as_ctx);
 	ceph_blog_exit(&__ji);
@@ -1297,13 +1308,8 @@ static struct dentry *ceph_mkdir(struct mnt_idmap *idmap, struct inode *dir,
 		ret = dget(req->r_dentry);
 	ceph_mdsc_put_request(req);
 out:
-	if (!IS_ERR(ret)) {
-		if (ret)
-			dentry = ret;
-		ceph_init_inode_acls(d_inode(dentry), &as_ctx);
-	} else {
+	if (IS_ERR(ret))
 		d_drop(dentry);
-	}
 	ceph_release_acl_sec_ctx(&as_ctx);
 	ceph_blog_exit(&__ji);
 	return ret;
@@ -1312,6 +1318,7 @@ static struct dentry *ceph_mkdir(struct mnt_idmap *idmap, struct inode *dir,
 static int ceph_link(struct dentry *old_dentry, struct inode *dir,
 		     struct dentry *dentry)
 {
+	struct ceph_quarantine_splice qsplice;
 	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(dir->i_sb);
 	struct ceph_fs_client *fsc = mdsc->fsc;
 	struct ceph_client *cl = mdsc->fsc->client;
@@ -1375,9 +1382,9 @@ static int ceph_link(struct dentry *old_dentry, struct inode *dir,
 		d_drop(dentry);
 	} else if (!req->r_reply_info.head->is_dentry) {
 		ihold(d_inode(old_dentry));
-		ceph_quarantine_splice_start(dir->i_sb);
+		ceph_quarantine_splice_start(dir->i_sb, &qsplice);
 		d_instantiate(dentry, d_inode(old_dentry));
-		ceph_quarantine_splice_finish(dir->i_sb);
+		ceph_quarantine_splice_finish(&qsplice);
 	}
 	ceph_mdsc_put_request(req);
 	ceph_blog_exit(&__ji);
@@ -1441,8 +1448,17 @@ static int get_caps_for_async_unlink(struct inode *dir, struct dentry *dentry)
 {
 	struct ceph_inode_info *ci = ceph_inode(dir);
 	struct ceph_dentry_info *di;
+	struct inode *inode = d_inode(dentry);
 	int got = 0, want = CEPH_CAP_FILE_EXCL | CEPH_CAP_DIR_UNLINK;
 
+	/*
+	 * Async unlink completes in the cache. A marked inode, or one
+	 * whose parents are not cached, has to go to the MDS.
+	 */
+	if (ceph_inode_quarantine_write_state(dir) != CEPH_Q_CLEAR ||
+	    (inode && ceph_inode_quarantine_write_state(inode) != CEPH_Q_CLEAR))
+		return 0;
+
 	spin_lock(&ci->i_ceph_lock);
 	if ((__ceph_caps_issued(ci, NULL) & want) == want) {
 		ceph_take_cap_refs(ci, want, false);
@@ -1627,6 +1643,7 @@ static int ceph_rename(struct mnt_idmap *idmap, struct inode *old_dir,
 		       struct dentry *old_dentry, struct inode *new_dir,
 		       struct dentry *new_dentry, unsigned int flags)
 {
+	struct ceph_mds_client *qmdsc;
 	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(old_dir->i_sb);
 	struct ceph_fs_client *fsc = mdsc->fsc;
 	struct ceph_client *cl = mdsc->fsc->client;
@@ -1713,9 +1730,9 @@ static int ceph_rename(struct mnt_idmap *idmap, struct inode *old_dir,
 		 * to do it here.
 		 */
 		moved = d_inode(old_dentry);
-		ceph_quarantine_move_start(moved, old_dir, new_dir);
+		qmdsc = ceph_quarantine_move_start(moved, old_dir, new_dir);
 		d_move(old_dentry, new_dentry);
-		ceph_quarantine_move_finish(moved, old_dir, new_dir);
+		ceph_quarantine_move_finish(qmdsc);
 	}
 	ceph_mdsc_put_request(req);
 	ceph_blog_exit(&__ji);
@@ -2349,12 +2366,16 @@ static ssize_t ceph_read_dir(struct file *file, char __user *buf, size_t size,
 	struct ceph_dir_file_info *dfi = file->private_data;
 	struct inode *inode = file_inode(file);
 	struct ceph_inode_info *ci = ceph_inode(inode);
-	int left;
+	int left, err;
 	const int bufsize = 1024;
 
 	if (!ceph_test_mount_opt(ceph_sb_to_fs_client(inode->i_sb), DIRSTAT))
 		return -EISDIR;
 
+	err = ceph_quarantine_revalidate(inode);
+	if (err)
+		return err;
+
 	if (!dfi->dir_info) {
 		dfi->dir_info = kmalloc(bufsize, GFP_KERNEL);
 		if (!dfi->dir_info)
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 9a6eadb94ab4f7e67d565b258e780129d9a505ff..367bb1dcc4a803ed8478ae9f81f55cb512cca8eb 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -297,8 +297,10 @@ static int ceph_init_file(struct inode *inode, struct file *file, int fmode)
 
 /*
  * Retry cap acquisition after a stale session or a lost cap update.
+ * A forced request checks this operation's access on the MDS even when
+ * another opener already holds the requested caps.
  */
-int ceph_renew_caps(struct inode *inode, int fmode)
+int ceph_renew_caps(struct inode *inode, int fmode, bool force)
 {
 	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(inode->i_sb);
 	struct ceph_client *cl = mdsc->fsc->client;
@@ -308,9 +310,9 @@ int ceph_renew_caps(struct inode *inode, int fmode)
 
 	spin_lock(&ci->i_ceph_lock);
 	__ceph_touch_fmode(ci, mdsc, fmode);
-	wanted = __ceph_caps_file_wanted(ci);
+	wanted = force ? ceph_caps_for_mode(fmode) : __ceph_caps_file_wanted(ci);
 	issued = __ceph_caps_issued(ci, NULL);
-	if (__ceph_is_any_real_caps(ci) &&
+	if (!force && __ceph_is_any_real_caps(ci) &&
 	    (!(wanted & CEPH_CAP_ANY_WR) || ci->i_auth_cap) &&
 	    (issued & wanted) == wanted) {
 		spin_unlock(&ci->i_ceph_lock);
@@ -371,7 +373,9 @@ int ceph_open(struct inode *inode, struct file *file)
 	struct dentry *dentry;
 	char *path;
 	bool do_sync = false;
+	bool snapshot = ceph_in_snap(inode) && ceph_snap(inode) != CEPH_SNAPDIR;
 	int mask = MAY_READ;
+	enum ceph_qstate qstate;
 	struct ceph_journal_info __ji;
 
 	ceph_blog_enter(fsc, &__ji);
@@ -382,6 +386,23 @@ int ceph_open(struct inode *inode, struct file *file)
 		return 0;
 	}
 
+	/*
+	 * Existing caps can satisfy open without an MDS round-trip.
+	 * A short walk cannot.
+	 */
+	if (!snapshot) {
+		qstate = file->f_mode & FMODE_WRITE ?
+			ceph_inode_quarantine_write_state(inode) :
+			ceph_inode_quarantine_state(inode);
+		if (qstate == CEPH_Q_UNDER &&
+		    ceph_inode_quarantine_direct(inode)) {
+			ceph_blog_exit(&__ji);
+			return -EACCES;
+		}
+		if (qstate != CEPH_Q_CLEAR)
+			do_sync = true;
+	}
+
 	/* filter out O_CREAT|O_EXCL; vfs did that already.  yuck. */
 	flags = file->f_flags & ~(O_CREAT|O_EXCL);
 	if (S_ISDIR(inode->i_mode)) {
@@ -419,6 +440,7 @@ int ceph_open(struct inode *inode, struct file *file)
 		do_sync = true;
 	} else {
 		struct ceph_path_info path_info = {0};
+
 		path = ceph_mdsc_build_path(mdsc, dentry, &path_info, 0);
 		if (IS_ERR(path)) {
 			do_sync = true;
@@ -429,7 +451,7 @@ int ceph_open(struct inode *inode, struct file *file)
 		ceph_mdsc_free_path_info(&path_info);
 		dput(dentry);
 
-		/* For none EACCES cases will let the MDS do the mds auth check */
+		/* Let the MDS handle errors other than EACCES. */
 		if (err == -EACCES) {
 			ceph_blog_exit(&__ji);
 			return err;
@@ -445,12 +467,23 @@ int ceph_open(struct inode *inode, struct file *file)
 		return -EROFS;
 	}
 
-	/* trivially open snapdir */
+	/* A synthetic snapdir must be validated through its real parent. */
 	if (ceph_snap(inode) == CEPH_SNAPDIR) {
+		err = ceph_quarantine_revalidate(inode);
 		ceph_blog_exit(&__ji);
+		if (err)
+			return err;
 		return ceph_init_file(inode, file, fmode);
 	}
 
+	if (snapshot) {
+		err = ceph_snapshot_read_auth(inode);
+		if (err) {
+			ceph_blog_exit(&__ji);
+			return err;
+		}
+	}
+
 	/*
 	 * No need to block if we have caps on the auth MDS (for
 	 * write) or any MDS (for read).  Update wanted set
@@ -541,6 +574,13 @@ static int try_prep_async_create(struct inode *dir, struct dentry *dentry,
 	int got = 0, want = CEPH_CAP_FILE_EXCL | CEPH_CAP_DIR_CREATE;
 	u64 ino;
 
+	/*
+	 * Async create completes in the cache. A marked directory, or
+	 * one whose parents are not cached, has to go to the MDS.
+	 */
+	if (ceph_inode_quarantine_write_state(dir) != CEPH_Q_CLEAR)
+		return 0;
+
 	spin_lock(&ci->i_ceph_lock);
 	/* No auth cap means no chance for Dc caps */
 	if (!ci->i_auth_cap)
@@ -687,6 +727,7 @@ static int ceph_finish_async_create(struct inode *dir, struct inode *inode,
 				    struct ceph_acl_sec_ctx *as_ctx,
 				    struct ceph_file_layout *lo)
 {
+	struct ceph_quarantine_splice qsplice;
 	int ret;
 	char xattr_buf[4];
 	struct ceph_mds_reply_inode in = { };
@@ -785,9 +826,9 @@ static int ceph_finish_async_create(struct inode *dir, struct inode *inode,
 		if (d_in_lookup(dentry) || d_really_is_negative(dentry)) {
 			if (!d_unhashed(dentry))
 				d_drop(dentry);
-			ceph_quarantine_splice_start(dir->i_sb);
+			ceph_quarantine_splice_start(dir->i_sb, &qsplice);
 			dn = d_splice_alias(inode, dentry);
-			ceph_quarantine_splice_finish(dir->i_sb);
+			ceph_quarantine_splice_finish(&qsplice);
 			WARN_ON_ONCE(dn && dn != dentry);
 		}
 		file->f_mode |= FMODE_CREATED;
@@ -889,6 +930,14 @@ int ceph_atomic_open(struct inode *dir, struct dentry *dentry,
 			err = PTR_ERR(new_inode);
 			goto out_ctx;
 		}
+		/*
+		 * LSM label reads can wait on async create completion. Quarantine
+		 * may activate after submission, so keep blob-bearing creates
+		 * synchronous even before support is negotiated.
+		 */
+		if (ceph_security_xattr_wanted(new_inode))
+			try_async = false;
+
 		/* Async create can't handle more than a page of xattrs */
 		if (as_ctx.pagelist &&
 		    !list_is_singular(&as_ctx.pagelist->head))
@@ -2972,6 +3021,27 @@ static int get_rd_wr_caps(struct file *src_filp, int *src_got,
 	int ret = 0;
 	bool retrying = false;
 
+	if (ceph_in_snap(file_inode(src_filp)) &&
+	    ceph_snap(file_inode(src_filp)) != CEPH_SNAPDIR) {
+		/*
+		 * Snapshot caps have no MDS revocation state, so holding
+		 * them cannot prevent a destination cap grant. Validate
+		 * the snapshot before taking any destination references.
+		 */
+		ret = ceph_get_caps(src_filp, CEPH_CAP_FILE_RD,
+				    CEPH_CAP_FILE_SHARED, -1, src_got);
+		if (ret < 0)
+			return ret;
+		ret = ceph_get_caps(dst_filp, CEPH_CAP_FILE_WR,
+				    CEPH_CAP_FILE_BUFFER, dst_endoff, dst_got);
+		if (ret < 0) {
+			ceph_put_cap_refs(ceph_inode(file_inode(src_filp)),
+					  *src_got);
+			*src_got = 0;
+		}
+		return ret;
+	}
+
 retry_caps:
 	ret = ceph_get_caps(dst_filp, CEPH_CAP_FILE_WR, CEPH_CAP_FILE_BUFFER,
 			    dst_endoff, dst_got);
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index 048e0d502eb4ea361389bc4a6e5ddfa9fd9f6ac5..df69feaa8fba31dd623c12a1fa7d1b247a5e1649 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -60,6 +60,13 @@ static int ceph_set_ino_cb(struct inode *inode, void *data)
 #endif
 
 	inode_set_iversion_raw(inode, 0);
+#ifdef CONFIG_CEPH_FS_POSIX_ACL
+	/* The VFS ACL cache would bypass Ceph's quarantine checks. */
+	if (READ_ONCE(mdsc->quarantine_supported)) {
+		inode->i_acl = ACL_DONT_CACHE;
+		inode->i_default_acl = ACL_DONT_CACHE;
+	}
+#endif
 	percpu_counter_inc(&mdsc->metric.total_inodes);
 
 	return 0;
@@ -252,6 +259,8 @@ struct inode *ceph_get_snapdir(struct inode *parent)
 	inode_set_atime_to_ts(inode, inode_get_atime(parent));
 	ci->i_rbytes = 0;
 	ci->i_btime = ceph_inode(parent)->i_btime;
+	ceph_inode_set_subvolume(inode,
+				 READ_ONCE(ceph_inode(parent)->i_subvolume_id));
 
 #ifdef CONFIG_FS_ENCRYPTION
 	/* if encrypted, just borrow fscrypt_auth from parent */
@@ -768,6 +777,17 @@ static void ceph_quarantine_write_end(struct ceph_mds_client *mdsc)
 	if (atomic_dec_return(&mdsc->quarantine_writers) == 0)
 		atomic64_inc_return(&mdsc->quarantine_epoch);
 	spin_unlock(&mdsc->quarantine_lock);
+	wake_up_all(&mdsc->quarantine_waitq);
+}
+
+/* Called under mdsc->mutex before a supporting session starts its requests. */
+void ceph_quarantine_enable(struct ceph_mds_client *mdsc)
+{
+	if (READ_ONCE(mdsc->quarantine_supported))
+		return;
+
+	WRITE_ONCE(mdsc->quarantine_supported, true);
+	ceph_quarantine_disable_acl_cache(mdsc->fsc->sb);
 }
 
 void ceph_quarantine_set(struct ceph_inode_info *ci)
@@ -890,6 +910,46 @@ static bool ceph_qmds_confirmed(struct ceph_inode_info *ci, u64 epoch)
 	return confirmed;
 }
 
+static void ceph_quarantine_remember_clear(struct inode *inode, u64 epoch,
+					   const struct cred *cred)
+{
+	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(inode->i_sb);
+	struct ceph_inode_info *ci = ceph_inode(inode);
+	const struct cred *old = NULL;
+
+	if (!mdsc || atomic_read(&mdsc->quarantine_count) == 0)
+		return;
+
+	/* Serialize the credential and epoch pair against other receipts. */
+	spin_lock(&ci->i_ceph_lock);
+	if (atomic_read(&mdsc->quarantine_count) == 0 ||
+	    ceph_inode_quarantine_direct(inode) || (epoch & 1) ||
+	    atomic_read(&mdsc->quarantine_splices) ||
+	    (u64)atomic64_read_acquire(&mdsc->quarantine_epoch) != epoch)
+		goto out;
+
+	old = ci->i_qmds_cred;
+	/* Invalidate the old receipt before publishing its new credentials. */
+	atomic64_set_release(&ci->i_qmds, 0);
+	if (old != cred)
+		ci->i_qmds_cred = get_cred(cred);
+	else
+		old = NULL;
+
+	/* Pairs with atomic64_read_acquire() in ceph_qmds_confirmed(). */
+	atomic64_set_release(&ci->i_qmds, epoch | 1ULL);
+	/* Order the confirmation store before re-reading its generation. */
+	smp_mb();
+	if ((u64)atomic64_read(&mdsc->quarantine_epoch) != epoch ||
+	    atomic_read(&mdsc->quarantine_splices)) {
+		/* The epoch moved. Drop the confirmation. */
+		atomic64_set_release(&ci->i_qmds, 0);
+	}
+out:
+	spin_unlock(&ci->i_ceph_lock);
+	put_cred(old);
+}
+
 static void ceph_quarantine_forget_receipt(struct ceph_inode_info *ci)
 {
 	const struct cred *cred;
@@ -1114,67 +1174,161 @@ enum ceph_qstate ceph_inode_quarantine_write_state(struct inode *inode)
 	return __ceph_inode_quarantine_state(inode, false);
 }
 
-static struct ceph_mds_client *ceph_quarantine_move_mdsc(struct inode *inode,
-							 struct inode *old_dir,
-							 struct inode *new_dir)
+/* Wait for namespace writers without blocking a fill-trace's own LSM hook. */
+int ceph_quarantine_wait(struct inode *inode)
 {
-	if (!inode || old_dir == new_dir)
-		return NULL;
-	return ceph_sb_to_mdsc(inode->i_sb);
+	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(inode->i_sb);
+	struct ceph_quarantine_splice *splice;
+	bool own_splice = false;
+	int err;
+
+	/* A fill-trace LSM hook may own the splice that would wake us. */
+	if (ceph_current_fill_trace_request())
+		return -EBUSY;
+	/* Async create and mount-root instantiation can run hooks too. */
+	spin_lock(&mdsc->quarantine_lock);
+	list_for_each_entry(splice, &mdsc->quarantine_splice_owners, item) {
+		if (splice->task == current) {
+			own_splice = true;
+			break;
+		}
+	}
+	spin_unlock(&mdsc->quarantine_lock);
+	if (own_splice)
+		return -EBUSY;
+	if (signal_pending(current))
+		return -ERESTARTSYS;
+	err = wait_event_interruptible(mdsc->quarantine_waitq,
+				       !(atomic64_read_acquire(&mdsc->quarantine_epoch) & 1) &&
+				       !atomic_read_acquire(&mdsc->quarantine_splices));
+	if (err)
+		return err;
+	if (ceph_inode_is_shutdown(inode))
+		return -ESTALE;
+	cond_resched();
+	return 0;
+}
+
+/* PIN-only, stale and absent caps cannot deliver the first quarantine revoke. */
+static bool ceph_quarantine_head_needs_revalidate(struct inode *inode)
+{
+	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(inode->i_sb);
+
+	return !ceph_in_snap(inode) &&
+		READ_ONCE(mdsc->quarantine_supported) &&
+		!ceph_quarantine_head_cap_valid(inode);
 }
 
 /*
- * Bracket d_move(). The epoch is odd across the parent change, so a
- * cached false cannot be reused against the new parent. d_move() does
- * not sleep. Same-directory renames do not take a writer slot.
- *
- * Sleeping alias splices use a separate counter below.
+ * Snapshots need a fresh MDS answer unless a connected head cap can receive
+ * quarantine revocations. For head inodes, a direct mark fails the caller.
+ * Inherited marks may permit recovery through a path-scoped q/Q grant.
+ * A GETATTR read receipt covers only this inode, credentials and epoch;
+ * writes need a mode-specific OPEN. A new epoch invalidates the receipt.
  */
-void ceph_quarantine_move_start(struct inode *inode, struct inode *old_dir,
-				struct inode *new_dir)
+int ceph_quarantine_revalidate(struct inode *inode)
+{
+	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(inode->i_sb);
+	enum ceph_qstate q;
+	u64 epoch;
+	int err;
+
+	/* Immutable snapshot caps cannot receive quarantine notifications. */
+	if (ceph_in_snap(inode)) {
+		if (!ceph_snapshot_needs_revalidate(inode))
+			return 0;
+		if (ceph_snap(inode) == CEPH_SNAPDIR)
+			return ceph_do_getattr(inode, CEPH_CAP_AUTH_SHARED, true);
+		return ceph_snapshot_read_auth(inode);
+	}
+
+	for (;;) {
+		q = ceph_inode_quarantine_state(inode);
+		if (q == CEPH_Q_CLEAR &&
+		    !ceph_quarantine_head_needs_revalidate(inode))
+			return 0;
+		if (q == CEPH_Q_UNDER && ceph_inode_quarantine_direct(inode))
+			return -EACCES;
+		/* Wait rejects our own splice or fill-trace context before sleeping. */
+		err = ceph_quarantine_wait(inode);
+		if (err)
+			return err;
+		epoch = (u64)atomic64_read_acquire(&mdsc->quarantine_epoch);
+		if ((epoch & 1) || atomic_read(&mdsc->quarantine_splices))
+			continue;
+
+		err = ceph_do_getattr(inode, CEPH_STAT_CAP_INODE_ALL, true);
+		if (err)
+			return err;
+
+		if (ceph_inode_quarantine_direct(inode))
+			return -EACCES;
+		/*
+		 * This reply authorizes the current operation even if no cap
+		 * was granted. Physical clearing and reusable receipts have
+		 * separate freshness checks; cached access still needs its caps.
+		 */
+		if ((u64)atomic64_read_acquire(&mdsc->quarantine_epoch) == epoch &&
+		    !atomic_read_acquire(&mdsc->quarantine_splices))
+			return 0;
+	}
+}
+
+/* The returned token pairs the gate decision across feature activation. */
+struct ceph_mds_client *ceph_quarantine_move_start(struct inode *inode,
+						   struct inode *old_dir,
+						   struct inode *new_dir)
 {
-	ceph_quarantine_write_begin(ceph_quarantine_move_mdsc(inode, old_dir,
-							      new_dir));
+	struct ceph_mds_client *mdsc;
+
+	if (!inode || old_dir == new_dir)
+		return NULL;
+	mdsc = ceph_sb_to_mdsc(inode->i_sb);
+	if (!READ_ONCE(mdsc->quarantine_supported))
+		return NULL;
+	ceph_quarantine_write_begin(mdsc);
+	return mdsc;
 }
 
-void ceph_quarantine_move_finish(struct inode *inode, struct inode *old_dir,
-				 struct inode *new_dir)
+void ceph_quarantine_move_finish(struct ceph_mds_client *mdsc)
 {
-	ceph_quarantine_write_end(ceph_quarantine_move_mdsc(inode, old_dir,
-							    new_dir));
+	ceph_quarantine_write_end(mdsc);
 }
 
 /*
- * d_splice_alias() and d_instantiate() can sleep in the LSM hook before
- * changing ancestry. Keep the epoch even for that hook, but disallow
- * all cached answers throughout the splice. A fresh walk also samples
- * rename_lock, so it cannot accept a chain torn by a move. Bracket
- * first attachments too: descendants may hold MDS confirmations from
- * when the directory had no connected alias.
- *
- * Fully ordered atomics and quarantine_lock make the counter and epoch
- * transitions one writer operation. Entry disables cache use before
- * invalidating tags; exit invalidates tags before enabling cache use.
- * Adding two preserves the parity of any concurrent mark writer.
+ * LSM hooks can sleep and reenter Ceph during a splice. Keep the epoch
+ * even but disable cached receipts while the ancestry can change.
+ * Namespace operations on unsupported mounts do not take writer slots.
  */
-void ceph_quarantine_splice_start(struct super_block *sb)
+void ceph_quarantine_splice_start(struct super_block *sb,
+				  struct ceph_quarantine_splice *splice)
 {
 	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(sb);
 
+	splice->mdsc = NULL;
+	if (!READ_ONCE(mdsc->quarantine_supported))
+		return;
+	splice->mdsc = mdsc;
+	splice->task = current;
 	spin_lock(&mdsc->quarantine_lock);
+	list_add(&splice->item, &mdsc->quarantine_splice_owners);
 	atomic_inc_return(&mdsc->quarantine_splices);
 	atomic64_add_return(2, &mdsc->quarantine_epoch);
 	spin_unlock(&mdsc->quarantine_lock);
 }
 
-void ceph_quarantine_splice_finish(struct super_block *sb)
+void ceph_quarantine_splice_finish(struct ceph_quarantine_splice *splice)
 {
-	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(sb);
+	struct ceph_mds_client *mdsc = splice->mdsc;
 
+	if (!mdsc)
+		return;
 	spin_lock(&mdsc->quarantine_lock);
+	list_del(&splice->item);
 	atomic64_add_return(2, &mdsc->quarantine_epoch);
 	atomic_dec_return(&mdsc->quarantine_splices);
 	spin_unlock(&mdsc->quarantine_lock);
+	wake_up_all(&mdsc->quarantine_waitq);
 }
 
 static bool ceph_quarantine_reply_can_clear(struct ceph_inode_info *ci,
@@ -1618,9 +1772,12 @@ int ceph_fill_inode(struct inode *inode, struct folio *locked_folio,
 	 */
 	if (iinfo->xattr_len > 4) {
 		xattr_blob = ceph_buffer_new(iinfo->xattr_len, GFP_NOFS);
-		if (!xattr_blob)
+		if (!xattr_blob) {
 			pr_err_client(cl, "ENOMEM xattr blob %d bytes\n",
 				      iinfo->xattr_len);
+			err = -ENOMEM;
+			goto out;
+		}
 	}
 
 	if (iinfo->pool_ns_len > 0)
@@ -1630,6 +1787,9 @@ int ceph_fill_inode(struct inode *inode, struct folio *locked_folio,
 	if (ceph_in_snap(inode) && !ci->i_snapid_map)
 		ci->i_snapid_map = ceph_get_snapid_map(mdsc, ceph_snap(inode));
 
+	if (READ_ONCE(session->s_mdsc->quarantine_supported))
+		ceph_quarantine_uncache_inode_acls(inode);
+
 	spin_lock(&ci->i_ceph_lock);
 
 	/*
@@ -1852,12 +2012,12 @@ int ceph_fill_inode(struct inode *inode, struct folio *locked_folio,
 
 		if (IS_ENCRYPTED(inode)) {
 			/*
-			 * Encrypted symlinks need to be decrypted before we can
-			 * cache their targets in i_link. Don't touch it here.
+			 * Decrypt on access without installing i_link, so the VFS
+			 * cannot bypass the quarantine get_link check.
 			 */
 			inode->i_op = &ceph_encrypted_symlink_iops;
 		} else {
-			inode->i_link = ci->i_symlink;
+			/* VFS i_link would bypass the quarantine get_link check. */
 			inode->i_op = &ceph_symlink_iops;
 		}
 		break;
@@ -2078,6 +2238,7 @@ static void update_dentry_lease_careful(struct dentry *dentry,
  */
 static int splice_dentry(struct dentry **pdn, struct inode *in)
 {
+	struct ceph_quarantine_splice qsplice;
 	struct ceph_client *cl = ceph_inode_to_client(in);
 	struct dentry *dn = *pdn;
 	struct dentry *realdn;
@@ -2109,9 +2270,9 @@ static int splice_dentry(struct dentry **pdn, struct inode *in)
 	/* dn must be unhashed */
 	if (!d_unhashed(dn))
 		d_drop(dn);
-	ceph_quarantine_splice_start(dn->d_sb);
+	ceph_quarantine_splice_start(dn->d_sb, &qsplice);
 	realdn = d_splice_alias(in, dn);
-	ceph_quarantine_splice_finish(dn->d_sb);
+	ceph_quarantine_splice_finish(&qsplice);
 	if (IS_ERR(realdn)) {
 		pr_err_client(cl, "error %ld %p inode %p ino %llx.%llx\n",
 			      PTR_ERR(realdn), dn, in, ceph_vinop(in));
@@ -2145,6 +2306,7 @@ static int splice_dentry(struct dentry **pdn, struct inode *in)
  */
 int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 {
+	struct ceph_mds_client *qmdsc;
 	struct ceph_mds_session *session = req->r_session;
 	struct ceph_mds_reply_info_parsed *rinfo = &req->r_reply_info;
 	struct inode *in = NULL;
@@ -2268,17 +2430,24 @@ int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 	}
 
 	if (rinfo->head->is_target) {
+		struct ceph_vino expected;
+
 		/* Should be filled in by handle_reply */
 		BUG_ON(!req->r_target_inode);
 
 		in = req->r_target_inode;
 		ceph_inode_set_subvolume(in, rinfo->targeti.subvolume_id);
-		err = ceph_fill_inode(in, req->r_locked_folio, &rinfo->targeti,
-				NULL, session,
-				(!test_bit(CEPH_MDS_R_ABORTED, &req->r_req_flags) &&
-				 !test_bit(CEPH_MDS_R_ASYNC, &req->r_req_flags) &&
-				 rinfo->head->result == 0) ?  req->r_fmode : -1,
-				&req->r_caps_reservation);
+		expected = req->r_inode ? ceph_vino(req->r_inode) : req->r_ino1;
+		if (req->r_locked_folio &&
+		    (ceph_ino(in) != expected.ino || ceph_snap(in) != expected.snap))
+			err = -ESTALE;
+		else
+			err = ceph_fill_inode(in, req->r_locked_folio, &rinfo->targeti,
+					      NULL, session,
+					      (!test_bit(CEPH_MDS_R_ABORTED, &req->r_req_flags) &&
+					       !test_bit(CEPH_MDS_R_ASYNC, &req->r_req_flags) &&
+					       rinfo->head->result == 0) ? req->r_fmode : -1,
+					      &req->r_caps_reservation);
 		if (err < 0) {
 			pr_err_client(cl, "badness %p %llx.%llx\n", in,
 				      ceph_vinop(in));
@@ -2348,9 +2517,9 @@ int ceph_fill_trace(struct super_block *sb, struct ceph_mds_request *req)
 			ceph_dir_clear_ordered(olddir);
 
 			moved = d_inode(req->r_old_dentry);
-			ceph_quarantine_move_start(moved, olddir, dir);
+			qmdsc = ceph_quarantine_move_start(moved, olddir, dir);
 			d_move(req->r_old_dentry, dn);
-			ceph_quarantine_move_finish(moved, olddir, dir);
+			ceph_quarantine_move_finish(qmdsc);
 			boutc(cl, " src %p '%s' dst %p '%s'\n",
 			      req->r_old_dentry, req->r_old_dentry->d_name.name, dn, dn->d_name.name);
 
@@ -2959,14 +3128,43 @@ static void ceph_inode_work(struct work_struct *work)
 	iput(inode);
 }
 
+static int ceph_symlink_revalidate(struct inode *inode)
+{
+	/* Snapshot caps are immutable and cannot revoke a saved target. */
+	if (ceph_in_snap(inode) && ceph_snap(inode) != CEPH_SNAPDIR)
+		return ceph_snapshot_read_auth(inode);
+	return ceph_do_getattr(inode, CEPH_CAP_AUTH_SHARED, ceph_in_snap(inode));
+}
+
+static const char *ceph_get_link(struct dentry *dentry, struct inode *inode,
+				 struct delayed_call *done)
+{
+	int err;
+
+	if (!dentry)
+		return ERR_PTR(-ECHILD);
+	err = ceph_symlink_revalidate(inode);
+	if (err)
+		return ERR_PTR(err);
+	return ceph_inode(inode)->i_symlink;
+}
+
+/*
+ * ceph_fscrypt_ops disables symlink target caching, so encrypted readlink
+ * and traversal reach this callback and ceph_symlink_revalidate().
+ */
 static const char *ceph_encrypted_get_link(struct dentry *dentry,
 					   struct inode *inode,
 					   struct delayed_call *done)
 {
 	struct ceph_inode_info *ci = ceph_inode(inode);
+	int err;
 
 	if (!dentry)
 		return ERR_PTR(-ECHILD);
+	err = ceph_symlink_revalidate(inode);
+	if (err)
+		return ERR_PTR(err);
 
 	return fscrypt_get_symlink(inode, ci->i_symlink, i_size_read(inode),
 				   done);
@@ -2989,7 +3187,7 @@ static int ceph_encrypted_symlink_getattr(struct mnt_idmap *idmap,
  * symlinks
  */
 static const struct inode_operations ceph_symlink_iops = {
-	.get_link = simple_get_link,
+	.get_link = ceph_get_link,
 	.setattr = ceph_setattr,
 	.getattr = ceph_getattr,
 	.listxattr = ceph_listxattr,
@@ -3200,6 +3398,25 @@ int __ceph_setattr(struct mnt_idmap *idmap, struct inode *inode,
 		return PTR_ERR(req);
 	}
 
+	/*
+	 * Exclusive caps apply mode, owner, times, and a size increase
+	 * with no MDS round trip. The state check may schedule, so it runs
+	 * before i_ceph_lock. A short walk sends the setattr.
+	 */
+	switch (ceph_inode_quarantine_write_state(inode)) {
+	case CEPH_Q_UNDER:
+		if (ceph_inode_quarantine_direct(inode)) {
+			err = -EACCES;
+			goto out;
+		}
+		fallthrough;
+	case CEPH_Q_UNKNOWN:
+		do_sync = true;
+		break;
+	default:
+		break;
+	}
+
 	fill_fscrypt = false;
 	spin_lock(&ci->i_ceph_lock);
 	issued = __ceph_caps_issued(ci, NULL);
@@ -3238,7 +3455,7 @@ int __ceph_setattr(struct mnt_idmap *idmap, struct inode *inode,
 			kfree(ci->fscrypt_auth);
 			ci->fscrypt_auth = (u8 *)cia->fscrypt_auth;
 			ci->fscrypt_auth_len = len;
-		} else if ((issued & CEPH_CAP_AUTH_SHARED) == 0 ||
+		} else if (do_sync || (issued & CEPH_CAP_AUTH_SHARED) == 0 ||
 			   ci->fscrypt_auth_len != len ||
 			   memcmp(ci->fscrypt_auth, cia->fscrypt_auth, len)) {
 			req->r_fscrypt_auth = cia->fscrypt_auth;
@@ -3265,7 +3482,7 @@ int __ceph_setattr(struct mnt_idmap *idmap, struct inode *inode,
 		if (!do_sync && (issued & CEPH_CAP_AUTH_EXCL)) {
 			inode->i_uid = fsuid;
 			dirtied |= CEPH_CAP_AUTH_EXCL;
-		} else if ((issued & CEPH_CAP_AUTH_SHARED) == 0 ||
+		} else if (do_sync || (issued & CEPH_CAP_AUTH_SHARED) == 0 ||
 			   !uid_eq(fsuid, inode->i_uid)) {
 			req->r_args.setattr.uid = cpu_to_le32(
 				from_kuid(&init_user_ns, fsuid));
@@ -3283,7 +3500,7 @@ int __ceph_setattr(struct mnt_idmap *idmap, struct inode *inode,
 		if (!do_sync && (issued & CEPH_CAP_AUTH_EXCL)) {
 			inode->i_gid = fsgid;
 			dirtied |= CEPH_CAP_AUTH_EXCL;
-		} else if ((issued & CEPH_CAP_AUTH_SHARED) == 0 ||
+		} else if (do_sync || (issued & CEPH_CAP_AUTH_SHARED) == 0 ||
 			   !gid_eq(fsgid, inode->i_gid)) {
 			req->r_args.setattr.gid = cpu_to_le32(
 				from_kgid(&init_user_ns, fsgid));
@@ -3297,9 +3514,10 @@ int __ceph_setattr(struct mnt_idmap *idmap, struct inode *inode,
 		if (!do_sync && (issued & CEPH_CAP_AUTH_EXCL)) {
 			inode->i_mode = attr->ia_mode;
 			dirtied |= CEPH_CAP_AUTH_EXCL;
-		} else if ((issued & CEPH_CAP_AUTH_SHARED) == 0 ||
+		} else if (do_sync || (issued & CEPH_CAP_AUTH_SHARED) == 0 ||
 			   attr->ia_mode != inode->i_mode) {
-			inode->i_mode = attr->ia_mode;
+			if (!do_sync)
+				inode->i_mode = attr->ia_mode;
 			req->r_args.setattr.mode = cpu_to_le32(attr->ia_mode);
 			mask |= CEPH_SETATTR_MODE;
 			release |= CEPH_CAP_AUTH_SHARED;
@@ -3320,7 +3538,7 @@ int __ceph_setattr(struct mnt_idmap *idmap, struct inode *inode,
 					      &attr->ia_atime) < 0) {
 			inode_set_atime_to_ts(inode, attr->ia_atime);
 			dirtied |= CEPH_CAP_FILE_WR;
-		} else if ((issued & CEPH_CAP_FILE_SHARED) == 0 ||
+		} else if (do_sync || (issued & CEPH_CAP_FILE_SHARED) == 0 ||
 			   !timespec64_equal(&atime, &attr->ia_atime)) {
 			ceph_encode_timespec64(&req->r_args.setattr.atime,
 					       &attr->ia_atime);
@@ -3359,7 +3577,7 @@ int __ceph_setattr(struct mnt_idmap *idmap, struct inode *inode,
 				dirtied |= CEPH_CAP_FILE_EXCL;
 				ia_valid |= ATTR_MTIME;
 			}
-		} else if ((issued & CEPH_CAP_FILE_SHARED) == 0 ||
+		} else if (do_sync || (issued & CEPH_CAP_FILE_SHARED) == 0 ||
 			   attr->ia_size != isize) {
 			mask |= CEPH_SETATTR_SIZE;
 			release |= CEPH_CAP_FILE_SHARED | CEPH_CAP_FILE_EXCL |
@@ -3394,7 +3612,7 @@ int __ceph_setattr(struct mnt_idmap *idmap, struct inode *inode,
 			   timespec64_compare(&mtime, &attr->ia_mtime) < 0) {
 			inode_set_mtime_to_ts(inode, attr->ia_mtime);
 			dirtied |= CEPH_CAP_FILE_WR;
-		} else if ((issued & CEPH_CAP_FILE_SHARED) == 0 ||
+		} else if (do_sync || (issued & CEPH_CAP_FILE_SHARED) == 0 ||
 			   !timespec64_equal(&mtime, &attr->ia_mtime)) {
 			ceph_encode_timespec64(&req->r_args.setattr.mtime,
 					       &attr->ia_mtime);
@@ -3418,11 +3636,11 @@ int __ceph_setattr(struct mnt_idmap *idmap, struct inode *inode,
 			 * we need to choose a cap to dirty under, or do
 			 * a almost-no-op setattr
 			 */
-			if (issued & CEPH_CAP_AUTH_EXCL)
+			if (!do_sync && (issued & CEPH_CAP_AUTH_EXCL))
 				dirtied |= CEPH_CAP_AUTH_EXCL;
-			else if (issued & CEPH_CAP_FILE_EXCL)
+			else if (!do_sync && (issued & CEPH_CAP_FILE_EXCL))
 				dirtied |= CEPH_CAP_FILE_EXCL;
-			else if (issued & CEPH_CAP_XATTR_EXCL)
+			else if (!do_sync && (issued & CEPH_CAP_XATTR_EXCL))
 				dirtied |= CEPH_CAP_XATTR_EXCL;
 			else
 				mask |= CEPH_SETATTR_CTIME;
@@ -3478,6 +3696,12 @@ int __ceph_setattr(struct mnt_idmap *idmap, struct inode *inode,
 			ceph_free_cap_flush(prealloc_cf);
 			goto retry;
 		}
+		if (!err && do_sync) {
+			/* Existing exclusive caps may keep reply-fill from updating attrs. */
+			spin_lock(&ci->i_ceph_lock);
+			setattr_copy(idmap, inode, attr);
+			spin_unlock(&ci->i_ceph_lock);
+		}
 	}
 out:
 	boutc(cl, "%p %llx.%llx result=%d (%s locally, %d remote)\n", inode,
@@ -3578,6 +3802,149 @@ int ceph_try_to_choose_auth_mds(struct inode *inode, int mask)
 		return USE_ANY_MDS;
 }
 
+/* A snapshot path must reach a head inode to encode its snapshot name. */
+static bool ceph_snapshot_has_path(struct inode *inode, bool check_caps)
+{
+	struct dentry *cur;
+	u64 subvolume_id = CEPH_SUBVOLUME_ID_NONE;
+	unsigned int seq, depth = 0;
+	bool connected = false;
+
+	/* A torn membership ID cannot establish revocation coverage. */
+	if (check_caps && IS_ENABLED(CONFIG_64BIT))
+		subvolume_id = READ_ONCE(ceph_inode(inode)->i_subvolume_id);
+
+	rcu_read_lock();
+	seq = read_seqbegin(&rename_lock);
+	cur = d_find_alias_rcu(inode);
+	while (cur && depth++ < 256) {
+		struct inode *in = d_inode_rcu(cur);
+		struct dentry *parent;
+
+		if (!in)
+			break;
+		if (!ceph_in_snap(in)) {
+			connected = !check_caps ||
+				(subvolume_id != CEPH_SUBVOLUME_ID_NONE &&
+				 ceph_ino(in) == subvolume_id &&
+				 ceph_quarantine_head_cap_valid(in));
+			break;
+		}
+		if (d_unhashed(cur) ||
+		    (READ_ONCE(cur->d_flags) & DCACHE_DISCONNECTED))
+			break;
+		parent = READ_ONCE(cur->d_parent);
+		if (parent == cur)
+			break;
+		cur = parent;
+	}
+	if (read_seqretry(&rename_lock, seq))
+		connected = false;
+	rcu_read_unlock();
+	return connected;
+}
+
+/*
+ * Only the target's subvolume root supplies reliable quarantine revocations.
+ * A snapshot taken above that root can reach a head ancestor outside the
+ * subvolume; its cap stays valid when the target is quarantined. Require the
+ * MDS-provided subvolume ID to identify the head root whose AUTH_SHARED cap
+ * we check. Unknown IDs, 32-bit clients and other head ancestors need an MDS
+ * answer, as do detached snapshots, expired root caps and active quarantine.
+ */
+bool ceph_snapshot_needs_revalidate(struct inode *inode)
+{
+	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(inode->i_sb);
+	u64 epoch;
+
+	if (!ceph_in_snap(inode) || !READ_ONCE(mdsc->quarantine_supported))
+		return false;
+	epoch = atomic64_read_acquire(&mdsc->quarantine_epoch);
+	if ((epoch & 1) || atomic_read(&mdsc->quarantine_count) ||
+	    atomic_read(&mdsc->quarantine_splices) ||
+	    !ceph_snapshot_has_path(inode, true))
+		return true;
+	/* Do not accept a head cap observed across a revoke or parent change. */
+	smp_rmb();
+	return (u64)atomic64_read_acquire(&mdsc->quarantine_epoch) != epoch ||
+		atomic_read(&mdsc->quarantine_count) ||
+		atomic_read(&mdsc->quarantine_splices);
+}
+
+static int ceph_snapshot_reply_error(struct inode *inode,
+				     struct ceph_mds_request *req, int mask)
+{
+	struct ceph_inode_info *ci = ceph_inode(inode);
+	bool have_xattrs;
+
+	if (!req->r_target_inode ||
+	    ceph_ino(req->r_target_inode) != ceph_ino(inode) ||
+	    ceph_snap(req->r_target_inode) != ceph_snap(inode))
+		return -EOPNOTSUPP;
+
+	/* LOOKUPINO can authorize access without returning the requested blob. */
+	if ((mask & CEPH_CAP_XATTR_SHARED) &&
+	    req->r_reply_info.targeti.xattr_len < 4) {
+		spin_lock(&ci->i_ceph_lock);
+		have_xattrs = ci->i_xattrs.version != 0;
+		spin_unlock(&ci->i_ceph_lock);
+		if (!have_xattrs)
+			return -EOPNOTSUPP;
+	}
+	if ((mask & CEPH_CAP_FILE_RD) &&
+	    req->r_reply_info.targeti.inline_version == 0 &&
+	    ceph_has_inline_data(ci) && i_size_read(inode) > 0)
+		return -EOPNOTSUPP;
+	return 0;
+}
+
+static int ceph_snapshot_lookupino(struct inode *inode,
+				   struct folio *locked_folio, int mask)
+{
+	struct ceph_mds_client *mdsc = ceph_sb_to_mdsc(inode->i_sb);
+	struct ceph_mds_request *req;
+	int err;
+
+	req = ceph_mdsc_create_request(mdsc, CEPH_MDS_OP_LOOKUPINO, USE_ANY_MDS);
+	if (IS_ERR(req))
+		return PTR_ERR(req);
+	/* No r_inode: an NFS alias may not encode a snapshot pathname. */
+	req->r_ino1 = ceph_vino(inode);
+	req->r_args.lookupino.snapid = cpu_to_le64(ceph_snap(inode));
+	req->r_args.lookupino.mask = cpu_to_le32(mask);
+	req->r_num_caps = 1;
+	req->r_locked_folio = locked_folio;
+	err = ceph_mdsc_do_request(mdsc, NULL, req);
+	if (!err)
+		err = ceph_snapshot_reply_error(inode, req, mask);
+	if (locked_folio && !err) {
+		u64 version = req->r_reply_info.targeti.inline_version;
+
+		if (version == 0)
+			err = -EINVAL;
+		else if (version == CEPH_INLINE_NONE || version == 1)
+			err = -ENODATA;
+		else
+			err = req->r_reply_info.targeti.inline_len;
+	}
+	ceph_mdsc_put_request(req);
+	return err;
+}
+
+int ceph_snapshot_read_auth(struct inode *inode)
+{
+	if (!ceph_snapshot_needs_revalidate(inode))
+		return 0;
+
+	/*
+	 * Preserve a connected snapshot path: its head inode may have been
+	 * deleted and no longer be cached by the MDS. Disconnected handles
+	 * fall back to LOOKUPINO, with the exact inode and snapshot ID.
+	 * The authorization is scoped to this operation, never cached.
+	 */
+	return ceph_do_getattr(inode, CEPH_CAP_AUTH_SHARED, true);
+}
+
 /*
  * Verify that we have a lease on the given mask.  If not,
  * do a getattr against an mds.
@@ -3589,21 +3956,59 @@ int __ceph_do_getattr(struct inode *inode, struct folio *locked_folio,
 	struct ceph_client *cl = fsc->client;
 	struct ceph_mds_client *mdsc = fsc->mdsc;
 	struct ceph_mds_request *req;
+	bool head_revalidate;
+	u64 qepoch;
 	int mode;
 	int err;
 
 	if (ceph_snap(inode) == CEPH_SNAPDIR) {
+		struct inode *parent;
+
 		boutc(cl, "inode %p %llx.%llx SNAPDIR\n", inode,
 		      ceph_vinop(inode));
-		return 0;
+		if (!ceph_snapshot_needs_revalidate(inode))
+			return 0;
+		/* The synthetic snapdir has the real directory's ino. */
+		parent = ceph_lookup_inode(inode->i_sb, ceph_ino(inode));
+		if (IS_ERR(parent))
+			return PTR_ERR(parent);
+		err = ceph_do_getattr(parent, mask, true);
+		iput(parent);
+		return err;
+	}
+
+	head_revalidate = ceph_quarantine_head_needs_revalidate(inode);
+	if (head_revalidate) {
+		/* Do not recurse into an MDS request from our own splice hook. */
+		err = ceph_quarantine_wait(inode);
+		if (err)
+			return err;
+		mask |= CEPH_CAP_AUTH_SHARED;
 	}
 
+	/*
+	 * Cached caps would satisfy getattr after the MDS has revoked
+	 * access, and a short walk has no ancestor to consult. Ask the
+	 * MDS so a lost quarantine-disable can clear the mark, and so
+	 * an uncached parent chain is not treated as clear. Snapshot caps need
+	 * an MDS check unless a live head cap provides quarantine notifications.
+	 */
+	if (ceph_snapshot_needs_revalidate(inode) ||
+	    head_revalidate ||
+	    ceph_inode_quarantine_state(inode) != CEPH_Q_CLEAR)
+		force = true;
+
 	boutc(cl, "inode %p %llx.%llx mask %s mode 0%o\n", inode,
 	      ceph_vinop(inode), ceph_cap_string(mask), inode->i_mode);
 	if (!force && ceph_caps_issued_mask_metric(ceph_inode(inode), mask, 1))
 			return 0;
 
-	mode = ceph_try_to_choose_auth_mds(inode, mask);
+	if (ceph_in_snap(inode) && !ceph_snapshot_has_path(inode, false))
+		return ceph_snapshot_lookupino(inode, locked_folio, mask);
+
+	qepoch = (u64)atomic64_read_acquire(&mdsc->quarantine_epoch);
+	mode = head_revalidate ? USE_AUTH_MDS :
+		ceph_try_to_choose_auth_mds(inode, mask);
 	req = ceph_mdsc_create_request(mdsc, CEPH_MDS_OP_GETATTR, mode);
 	if (IS_ERR(req))
 		return PTR_ERR(req);
@@ -3613,6 +4018,15 @@ int __ceph_do_getattr(struct inode *inode, struct folio *locked_folio,
 	req->r_args.getattr.mask = cpu_to_le32(mask);
 	req->r_locked_folio = locked_folio;
 	err = ceph_mdsc_do_request(mdsc, NULL, req);
+	if (ceph_in_snap(inode)) {
+		if (err == -EINVAL || err == -ESTALE ||
+		    (!err && ceph_snapshot_reply_error(inode, req, mask))) {
+			ceph_mdsc_put_request(req);
+			return ceph_snapshot_lookupino(inode, locked_folio, mask);
+		}
+	}
+	if (!err && !ceph_in_snap(inode))
+		ceph_quarantine_remember_clear(inode, qepoch, req->r_cred);
 	if (locked_folio && err == 0) {
 		u64 inline_version = req->r_reply_info.targeti.inline_version;
 		if (inline_version == 0) {
@@ -3758,8 +4172,15 @@ int ceph_getattr(struct mnt_idmap *idmap, const struct path *path,
 		return -ESTALE;
 	}
 
-	/* Skip the getattr altogether if we're asked not to sync */
-	if ((flags & AT_STATX_SYNC_TYPE) != AT_STATX_DONT_SYNC) {
+	/*
+	 * AT_STATX_DONT_SYNC would return the cached attrs. A
+	 * quarantined inode, or one whose parents are not cached,
+	 * still has to ask the MDS. Snapshot caps need a live head cap for notifications.
+	 */
+	if (ceph_snapshot_needs_revalidate(inode) ||
+	    ceph_quarantine_head_needs_revalidate(inode) ||
+	    ceph_inode_quarantine_state(inode) != CEPH_Q_CLEAR ||
+	    (flags & AT_STATX_SYNC_TYPE) != AT_STATX_DONT_SYNC) {
 		err = ceph_do_getattr(inode,
 				statx_to_caps(request_mask, inode->i_mode),
 				flags & AT_STATX_FORCE_SYNC);
diff --git a/fs/ceph/ioctl.c b/fs/ceph/ioctl.c
index 12cb50e0a1665dec866eee405b081f970e89351a..d152cad10c23e92a26e7f93c5c1d5fd7e6c7014e 100644
--- a/fs/ceph/ioctl.c
+++ b/fs/ceph/ioctl.c
@@ -201,6 +201,10 @@ static long ceph_ioctl_get_dataloc(struct file *file, void __user *arg)
 	if (copy_from_user(&dl, arg, sizeof(dl)))
 		return -EFAULT;
 
+	r = ceph_do_getattr(inode, CEPH_STAT_CAP_LAYOUT, false);
+	if (r)
+		return r;
+
 	down_read(&osdc->lock);
 	ceph_calc_file_object_mapping(&ci->i_layout, dl.file_offset, 1,
 				      &dl.object_no, &dl.object_offset, &xlen);
@@ -403,12 +407,18 @@ long ceph_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		ret = vet_mds_for_fscrypt(file);
 		if (ret)
 			return ret;
+		ret = ceph_quarantine_revalidate(inode);
+		if (ret)
+			return ret;
 		return fscrypt_ioctl_get_policy(file, (void __user *)arg);
 
 	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
 		ret = vet_mds_for_fscrypt(file);
 		if (ret)
 			return ret;
+		ret = ceph_quarantine_revalidate(inode);
+		if (ret)
+			return ret;
 		return fscrypt_ioctl_get_policy_ex(file, (void __user *)arg);
 
 	case FS_IOC_ADD_ENCRYPTION_KEY:
@@ -431,6 +441,9 @@ long ceph_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		ret = vet_mds_for_fscrypt(file);
 		if (ret)
 			return ret;
+		ret = ceph_quarantine_revalidate(inode);
+		if (ret)
+			return ret;
 		return fscrypt_ioctl_get_nonce(file, (void __user *)arg);
 	}
 
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 5fec6e129d2822847c5dab6b2674560712db2765..730fd4bfaeffa3dac6be5cd03c7116c8a8c02bbc 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -4668,6 +4668,8 @@ static void handle_session(struct ceph_mds_session *session,
 		mdsc->s_cap_auths = cap_auths;
 
 		session->s_features = features;
+		if (test_bit(CEPHFS_FEATURE_QUARANTINE, &session->s_features))
+			ceph_quarantine_enable(mdsc);
 		if (test_bit(CEPHFS_FEATURE_METRIC_COLLECT,
 			     &session->s_features))
 			ceph_metric_bind_session(mdsc, session);
@@ -6480,6 +6482,9 @@ int ceph_mdsc_init(struct ceph_fs_client *fsc)
 	spin_lock_init(&mdsc->stopping_lock);
 	atomic_set(&mdsc->stopping_blockers, 0);
 	atomic_set(&mdsc->quarantine_count, 0);
+	mdsc->quarantine_supported = false;
+	init_waitqueue_head(&mdsc->quarantine_waitq);
+	INIT_LIST_HEAD(&mdsc->quarantine_splice_owners);
 	atomic_set(&mdsc->quarantine_writers, 0);
 	atomic_set(&mdsc->quarantine_splices, 0);
 	atomic64_set(&mdsc->quarantine_epoch, 0);
diff --git a/fs/ceph/mds_client.h b/fs/ceph/mds_client.h
index 816f5f2d32ccf19b8d0644a3d5c24a730fd1015b..422a27e44c38016f32d2073c16feccd73ad31ff5 100644
--- a/fs/ceph/mds_client.h
+++ b/fs/ceph/mds_client.h
@@ -39,7 +39,14 @@ enum ceph_feature_type {
 	CEPHFS_FEATURE_MDS_AUTH_CAPS_CHECK,
 	CEPHFS_FEATURE_SUBVOLUME_METRICS,
 
-	CEPHFS_FEATURE_MAX = CEPHFS_FEATURE_SUBVOLUME_METRICS,
+	/*
+	 * Bit 23 is CEPHFS_FEATURE_BLOCKDIFF on the MDS and is not
+	 * advertised here. Bit 24 is subvolume quarantine; it must stay
+	 * aligned with the userspace client.
+	 */
+	CEPHFS_FEATURE_QUARANTINE = 24,
+
+	CEPHFS_FEATURE_MAX = CEPHFS_FEATURE_QUARANTINE,
 };
 
 #define CEPHFS_FEATURES_CLIENT_SUPPORTED {	\
@@ -57,6 +64,7 @@ enum ceph_feature_type {
 	CEPHFS_FEATURE_HAS_OWNER_UIDGID,	\
 	CEPHFS_FEATURE_MDS_AUTH_CAPS_CHECK,	\
 	CEPHFS_FEATURE_SUBVOLUME_METRICS,	\
+	CEPHFS_FEATURE_QUARANTINE,		\
 }
 
 /*
@@ -507,6 +515,10 @@ struct ceph_mds_client {
 	spinlock_t              stopping_lock;  /* protect snap_empty */
 	int                     stopping;      /* the stage of shutting down */
 	atomic_t                stopping_blockers;
+	/* Once negotiated, keep tracking across reconnects and mixed ranks. */
+	bool			quarantine_supported;
+	wait_queue_head_t	quarantine_waitq;
+	struct list_head	quarantine_splice_owners; /* quarantine_lock */
 	/*
 	 * Inodes with CEPH_I_QUARANTINE set. Hot paths skip the
 	 * ancestor walk while this is zero.
diff --git a/fs/ceph/super.c b/fs/ceph/super.c
index ad9460d9673cb18230d8fbcb93a27aa26f7ace38..ed2eab9d69692ce6154095aaa66a9950879fe967 100644
--- a/fs/ceph/super.c
+++ b/fs/ceph/super.c
@@ -1137,11 +1137,13 @@ static struct dentry *open_root_dentry(struct ceph_fs_client *fsc,
 	err = ceph_mdsc_do_request(mdsc, NULL, req);
 	if (err == 0) {
 		struct inode *inode = req->r_target_inode;
+		struct ceph_quarantine_splice qsplice;
+
 		req->r_target_inode = NULL;
 		doutc(cl, "success\n");
-		ceph_quarantine_splice_start(fsc->sb);
+		ceph_quarantine_splice_start(fsc->sb, &qsplice);
 		root = d_make_root(inode);
-		ceph_quarantine_splice_finish(fsc->sb);
+		ceph_quarantine_splice_finish(&qsplice);
 		if (!root) {
 			root = ERR_PTR(-ENOMEM);
 			goto out;
diff --git a/fs/ceph/super.h b/fs/ceph/super.h
index 0264bd9d705fcb1bc904d0fc7fc94be2b6de3c66..8aecc6f1b62907e37556793793b4accf84800612 100644
--- a/fs/ceph/super.h
+++ b/fs/ceph/super.h
@@ -1292,6 +1292,8 @@ void ceph_inode_shutdown(struct inode *inode);
  * CEPH_Q_CLEAR: cached ancestry is clear, or the MDS confirmed read
  * access to this exact inode for the current epoch. Writers must use
  * ceph_inode_quarantine_write_state(), which ignores read receipts.
+ * Cached metadata access also needs a live cap for quarantine revocations;
+ * use ceph_quarantine_revalidate() before returning it without cap references.
  * CEPH_Q_UNDER: this inode or a cached ancestor is marked.
  * CEPH_Q_UNKNOWN: the parent chain is not fully cached. Ask the MDS.
  * Do not treat that as quarantined and do not use cached caps.
@@ -1306,16 +1308,27 @@ enum ceph_qstate ceph_inode_quarantine_state(struct inode *inode);
 enum ceph_qstate ceph_inode_quarantine_write_state(struct inode *inode);
 bool ceph_inode_quarantine_direct(struct inode *inode);
 int ceph_quarantine_revalidate(struct inode *inode);
+int ceph_quarantine_wait(struct inode *inode);
+bool ceph_snapshot_needs_revalidate(struct inode *inode);
+bool ceph_quarantine_head_cap_valid(struct inode *inode);
+void ceph_quarantine_enable(struct ceph_mds_client *mdsc);
 int ceph_snapshot_read_auth(struct inode *inode);
 void ceph_quarantine_set(struct ceph_inode_info *ci);
 bool ceph_quarantine_clear(struct ceph_inode_info *ci);
 bool ceph_quarantine_reset(struct ceph_inode_info *ci);
-void ceph_quarantine_move_start(struct inode *inode, struct inode *old_dir,
-				struct inode *new_dir);
-void ceph_quarantine_move_finish(struct inode *inode, struct inode *old_dir,
-				 struct inode *new_dir);
-void ceph_quarantine_splice_start(struct super_block *sb);
-void ceph_quarantine_splice_finish(struct super_block *sb);
+struct ceph_mds_client *ceph_quarantine_move_start(struct inode *inode,
+						   struct inode *old_dir,
+						   struct inode *new_dir);
+void ceph_quarantine_move_finish(struct ceph_mds_client *mdsc);
+struct ceph_quarantine_splice {
+	struct ceph_mds_client *mdsc;
+	struct task_struct *task;
+	struct list_head item;
+};
+
+void ceph_quarantine_splice_start(struct super_block *sb,
+				  struct ceph_quarantine_splice *splice);
+void ceph_quarantine_splice_finish(struct ceph_quarantine_splice *splice);
 void ceph_handle_quarantine_disable(struct ceph_mds_client *mdsc,
 				    struct ceph_mds_session *session,
 				    struct ceph_msg *msg);
@@ -1379,6 +1392,7 @@ static inline int ceph_security_init_secctx(struct dentry *dentry, umode_t mode,
 {
 	return 0;
 }
+
 static inline void ceph_security_invalidate_secctx(struct inode *inode)
 {
 }
@@ -1394,8 +1408,9 @@ int ceph_set_acl(struct mnt_idmap *idmap,
 		 struct dentry *dentry, struct posix_acl *acl, int type);
 int ceph_pre_init_acls(struct inode *dir, umode_t *mode,
 		       struct ceph_acl_sec_ctx *as_ctx);
-void ceph_init_inode_acls(struct inode *inode,
-			  struct ceph_acl_sec_ctx *as_ctx);
+void ceph_init_inode_acls(struct inode *inode, struct ceph_acl_sec_ctx *as_ctx);
+void ceph_quarantine_uncache_inode_acls(struct inode *inode);
+void ceph_quarantine_disable_acl_cache(struct super_block *sb);
 
 static inline void ceph_forget_all_cached_acls(struct inode *inode)
 {
@@ -1412,11 +1427,20 @@ static inline int ceph_pre_init_acls(struct inode *dir, umode_t *mode,
 {
 	return 0;
 }
+
 static inline void ceph_init_inode_acls(struct inode *inode,
 					struct ceph_acl_sec_ctx *as_ctx)
 {
 }
 
+static inline void ceph_quarantine_uncache_inode_acls(struct inode *inode)
+{
+}
+
+static inline void ceph_quarantine_disable_acl_cache(struct super_block *sb)
+{
+}
+
 static inline void ceph_forget_all_cached_acls(struct inode *inode)
 {
 }
@@ -1578,7 +1602,7 @@ static inline bool ceph_has_inline_data(const struct ceph_inode_info *ci)
 /* file.c */
 extern const struct file_operations ceph_file_fops;
 
-extern int ceph_renew_caps(struct inode *inode, int fmode);
+int ceph_renew_caps(struct inode *inode, int fmode, bool force);
 extern int ceph_open(struct inode *inode, struct file *file);
 extern int ceph_atomic_open(struct inode *dir, struct dentry *dentry,
 			    struct file *file, unsigned flags, umode_t mode);
diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
index 4cba6e7bffd3dd65dedaa9225546079b2e6e57c3..13d4dfef679de1d7348db14da7e7bfcf1c26d077 100644
--- a/fs/ceph/xattr.c
+++ b/fs/ceph/xattr.c
@@ -997,6 +997,7 @@ ssize_t __ceph_getxattr(struct inode *inode, const char *name, void *value,
 	struct ceph_vxattr *vxattr;
 	int req_mask;
 	ssize_t err;
+	bool ask_mds = false;
 
 	if (strncmp(name, XATTR_CEPH_PREFIX, XATTR_CEPH_PREFIX_LEN))
 		goto handle_non_vxattrs;
@@ -1034,7 +1035,19 @@ ssize_t __ceph_getxattr(struct inode *inode, const char *name, void *value,
 	      ceph_vinop(inode), name, ci->i_xattrs.version,
 	      ci->i_xattrs.index_version);
 
-	if (ci->i_xattrs.version == 0 ||
+	/*
+	 * A shared cap would answer from the cache. The state check may
+	 * schedule, so drop i_ceph_lock first. A reply reading the blob
+	 * it just installed must still use that cache.
+	 */
+	if (!ceph_current_fill_trace_request()) {
+		spin_unlock(&ci->i_ceph_lock);
+		ask_mds = ceph_snapshot_needs_revalidate(inode) ||
+			  ceph_inode_quarantine_state(inode) != CEPH_Q_CLEAR;
+		spin_lock(&ci->i_ceph_lock);
+	}
+
+	if (ask_mds || ci->i_xattrs.version == 0 ||
 	    !((req_mask & CEPH_CAP_XATTR_SHARED) ||
 	      __ceph_caps_issued_mask_metric(ci, CEPH_CAP_XATTR_SHARED, 1))) {
 		spin_unlock(&ci->i_ceph_lock);
@@ -1089,6 +1102,7 @@ ssize_t ceph_listxattr(struct dentry *dentry, char *names, size_t size)
 	struct ceph_client *cl = ceph_inode_to_client(inode);
 	struct ceph_inode_info *ci = ceph_inode(inode);
 	bool len_only = (size == 0);
+	bool ask_mds = false;
 	u32 namelen;
 	int err;
 	struct ceph_journal_info __ji;
@@ -1100,7 +1114,15 @@ ssize_t ceph_listxattr(struct dentry *dentry, char *names, size_t size)
 	      ceph_vinop(inode), ci->i_xattrs.version,
 	      ci->i_xattrs.index_version);
 
-	if (ci->i_xattrs.version == 0 ||
+	/* Same as __ceph_getxattr(): do not serve a shared cap hit. */
+	if (!ceph_current_fill_trace_request()) {
+		spin_unlock(&ci->i_ceph_lock);
+		ask_mds = ceph_snapshot_needs_revalidate(inode) ||
+			  ceph_inode_quarantine_state(inode) != CEPH_Q_CLEAR;
+		spin_lock(&ci->i_ceph_lock);
+	}
+
+	if (ask_mds || ci->i_xattrs.version == 0 ||
 	    !__ceph_caps_issued_mask_metric(ci, CEPH_CAP_XATTR_SHARED, 1)) {
 		spin_unlock(&ci->i_ceph_lock);
 		err = ceph_do_getattr(inode, CEPH_STAT_CAP_XATTR, true);
@@ -1222,6 +1244,7 @@ int __ceph_setxattr(struct inode *inode, const char *name,
 	int required_blob_size;
 	bool check_realm = false;
 	bool lock_snap_rwsem = false;
+	bool checked_quarantine = false;
 
 	if (ceph_in_snap(inode))
 		return -EROFS;
@@ -1305,7 +1328,8 @@ int __ceph_setxattr(struct inode *inode, const char *name,
 		struct ceph_buffer *blob;
 
 		spin_unlock(&ci->i_ceph_lock);
-		ceph_buffer_put(old_blob); /* Shouldn't be required */
+		ceph_buffer_put(old_blob);
+		old_blob = NULL;
 		boutc(cl, " pre-allocating new blob size=%d\n",
 		      required_blob_size);
 		blob = ceph_buffer_new(required_blob_size, GFP_NOFS);
@@ -1319,6 +1343,34 @@ int __ceph_setxattr(struct inode *inode, const char *name,
 		goto retry;
 	}
 
+	/*
+	 * XATTR_EXCL applies the new blob with no MDS round trip.
+	 * The state check may schedule, so drop i_ceph_lock first.
+	 */
+	if (!checked_quarantine) {
+		enum ceph_qstate qstate;
+
+		spin_unlock(&ci->i_ceph_lock);
+		qstate = ceph_inode_quarantine_write_state(inode);
+		if (qstate == CEPH_Q_UNDER &&
+		    ceph_inode_quarantine_direct(inode)) {
+			ceph_buffer_put(old_blob);
+			old_blob = NULL;
+			if (lock_snap_rwsem)
+				up_read(&mdsc->snap_rwsem);
+			err = -EACCES;
+			goto out;
+		}
+		if (qstate != CEPH_Q_CLEAR) {
+			ceph_buffer_put(old_blob);
+			old_blob = NULL;
+			goto do_sync_unlocked;
+		}
+		checked_quarantine = true;
+		spin_lock(&ci->i_ceph_lock);
+		goto retry;
+	}
+
 	err = __set_xattr(ci, newname, name_len, newval, val_len,
 			  flags, value ? 1 : -1, &xattr);
 
@@ -1331,6 +1383,7 @@ int __ceph_setxattr(struct inode *inode, const char *name,
 
 	spin_unlock(&ci->i_ceph_lock);
 	ceph_buffer_put(old_blob);
+	old_blob = NULL;
 	if (lock_snap_rwsem)
 		up_read(&mdsc->snap_rwsem);
 	if (dirty)
@@ -1341,6 +1394,7 @@ int __ceph_setxattr(struct inode *inode, const char *name,
 do_sync:
 	spin_unlock(&ci->i_ceph_lock);
 	ceph_buffer_put(old_blob);
+	old_blob = NULL;
 do_sync_unlocked:
 	if (lock_snap_rwsem)
 		up_read(&mdsc->snap_rwsem);

