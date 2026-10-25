Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792957685;
	b=UJ9/iDAW2SwI4sSsg1Q3WvznBFJ5atkGlClyMHiuHCZrvE3DzBa+taITn2aqHg/NtwBQ
	 qwbHHMPnIdy+RjAzQSO7ygLoBRR3f13NvP1AV1M38MvEmvcmdlmaU5zFEASOPIz9JJqXP
	 9vYkkCCe15uFa08ks0mmykD5TgOJlby2HU0b0M4v/F7HwZSSHyShjRUP12+eX4Jr9+xaF
	 STlaH8XM4vtfrTeTCqyFQuOo56SmV4dE7aWEKqYTYkokyB7Cxmt/8dJM+cbwEjOodO7Ge
	 emyfzAQ85OVhWOfjn9NHB6SjY0ySO04wY4h8jN7r5WLpbVG1g8hRmcaFTkERX9173fg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792957685;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=2aZdVHtnW78dVnHU065rFZv3OZlVh8c28paAddfQqJM=;
	b=1G1wjNISLvX86ASrq9rYjCGTWKy1lnBSHS14arXQ688NukY9ZWELl/BcITR5/V12WkF8
	 P6MQ9kfEWh/lwBfAwJg+bhmVDh9TDsNC+VVRbRaKt+nkCDchCP8R5K4MfINPk2eUL7CeY
	 P+lQQ10HHMvK/ov83tVdQiYlEHtYQbxuFrsVR2QZXfh3FJ29DUiqxO4VhBdCUK9kRw3Cx
	 7kYLa9nNEQw4dZOt41UPhS5VvAdX8Ca3QhXgIYP5BU+tjDnOz81iwvdOHVynYVqMx2CO0
	 Y5nBl1Q+eylZSjiyZwIFl2HveAbZlTniQQOaeTJCy9gk1Ci5RZky5BL2FNnA+S1I9IA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YH1kPr9+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 73658606A31A
	for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 19:48:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YH1kPr9+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 751861F01825;
	Sun, 25 Oct 2026 19:48:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792957685;
	bh=2aZdVHtnW78dVnHU065rFZv3OZlVh8c28paAddfQqJM=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=YH1kPr9+jzpjXdJW4SC5Hrs+vSseq9UkhAUzyWr1JfudbARzZXJ81q4KjDS9BaQSg
	 LkzArnGQTOl/IAgq9DkfmkgCsUmdlSbjuWOCG8hd/CEkACa9FV7Tp9wGgvvi+2PK8p
	 J1NIvDO2kPsWpDGprvq5JTyj8e1pupPa07GS2F/sRp8owBhJkczS5SSahjKy8V60tC
	 e982GZKY+G/YsHLj5DAQX9e7pew35vXi6K6rCdQNqWAxzKlt0jvlsDTOeYVOm+qvUR
	 UR3nQaywljpWfYCAspic3SJh9u72SUnygLb45+w8bkFhTfUNyroMnejcMSah6zaWw1
	 8dbe97mEdyFJQ==
Message-ID: <sashiko-outbox-184392@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH v6 5/5] ceph: fail quarantined subvolume access with
 EACCES
Reply-To: sashiko-reviews@lists.linux.dev
To: "Alex Markuze" <amarkuze@redhat.com>
Cc: idryomov@gmail.com, xiubo.li@clyso.com, slava@dubeyko.com, viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz, linux-fscrypt@vger.kernel.org, ebiggers@kernel.org, tytso@mit.edu, jaegeuk@kernel.org
In-Reply-To: <ddf9dfb3e012576caa6953b42f5ce86adae14f95.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
References: <cover.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
 <ddf9dfb3e012576caa6953b42f5ce86adae14f95.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 25 Oct 2026 19:48:04 +0000
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

Thank you for your contribution! Sashiko AI review found 4 potential issue(=
s) to consider:
- [High] ceph: missing head cap revalidation in ceph_open() and write cap p=
aths
- [High] ceph: stale xattr cache in __ceph_setxattr() sync fallback with XA=
TTR_EXCL
- [High] ceph: infinite loop in __ceph_get_caps() when inline data reply la=
cks cache caps
- [Medium] ceph: missing head cap revalidation in __ceph_getxattr() and cep=
h_listxattr()
--

commit 3b0481a00dbf8afa6f80793356dab3d1a012a099
Author: Alex Markuze <amarkuze@redhat.com>

ceph: fail quarantined subvolume access with EACCES

This commit adds client-side enforcement for quarantined subvolumes before
advertising CEPHFS_FEATURE_QUARANTINE to the MDS. It revalidates cached
data, metadata, xattrs, ACLs, symlinks, and snapshot capabilities against
quarantine state and requires MDS authorization when local state or
revocation coverage is insufficient.

> diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> index dd2bd8ed24249..79e396752601f 100644
> --- a/fs/ceph/addr.c
> +++ b/fs/ceph/addr.c
[ ... ]
> @@ -2649,9 +2674,24 @@ static const struct vm_operations_struct ceph_vmop=
s =3D {
>  int ceph_mmap_prepare(struct vm_area_desc *desc)
>  {
>  	struct address_space *mapping =3D desc->file->f_mapping;
> +	struct inode *inode =3D file_inode(desc->file);
> +	int err, got =3D 0;
> =20
>  	if (!mapping->a_ops->read_folio)
>  		return -ENOEXEC;
> +	err =3D ceph_quarantine_revalidate(inode);
> +	if (err)
> +		return err;
> +	if (vma_desc_test_all(desc, VMA_SHARED_BIT, VMA_WRITE_BIT) &&
> +	    ceph_inode_quarantine_write_state(inode) !=3D CEPH_Q_CLEAR) {
> +		/* A read receipt cannot admit a writable shared mapping. */
> +		err =3D ceph_get_caps(desc->file, CEPH_CAP_FILE_WR, 0, -1, &got);
> +		if (err)
> +			return err;
> +		ceph_put_cap_refs(ceph_inode(inode), got);
> +	}

[Severity: High]
Can a writable shared mapping be admitted here using only a read-only
GETATTR confirmation when mdsc->quarantine_count is zero?

In __ceph_inode_quarantine_state(), both ceph_inode_quarantine_state() and
ceph_inode_quarantine_write_state() return CEPH_Q_CLEAR immediately whenever
atomic_read(&mdsc->quarantine_count) =3D=3D 0:

fs/ceph/inode.c:__ceph_inode_quarantine_state() {
	...
	mdsc =3D ceph_sb_to_mdsc(inode->i_sb);
	if (!mdsc || atomic_read(&mdsc->quarantine_count) =3D=3D 0)
		return CEPH_Q_CLEAR;
	...
}

If a subvolume is already quarantined before the client caches caps above
CEPH_CAP_PIN (or after marked inodes are evicted), mdsc->quarantine_count is
0. When a client with read-only recovery permission (q, but not Q) calls
ceph_mmap_prepare(), ceph_quarantine_revalidate() succeeds via GETATTR
without granting CEPH_CAP_AUTH_SHARED, leaving
ceph_quarantine_head_needs_revalidate(inode) true.

Because ceph_inode_quarantine_write_state(inode) still returns CEPH_Q_CLEAR
when quarantine_count is 0, the check above is false and ceph_get_caps() for
CEPH_CAP_FILE_WR is skipped.

The same issue also affects __ceph_get_caps() and ceph_open() when
quarantine_count is 0 and ceph_quarantine_head_needs_revalidate(inode) is
true (for example, when ci->i_auth_cap only holds CEPH_CAP_PIN from a prior
read-only LOOKUP or GETATTR). In ceph_open() with FMODE_WRITE, do_sync
remains false, allowing the fast path to succeed locally on the PIN-only
ci->i_auth_cap without sending CEPH_MDS_OP_OPEN, and triggering
ceph_uninline_data() on inline files.

Should ceph_mmap_prepare(), __ceph_get_caps(), and ceph_open() also check
ceph_quarantine_head_needs_revalidate(inode) on write paths?

> diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
> index b07814d0038cd..7c85e84fa6493 100644
> --- a/fs/ceph/caps.c
> +++ b/fs/ceph/caps.c
[ ... ]
> @@ -3304,15 +3396,71 @@ int __ceph_get_caps(struct inode *inode, struct c=
eph_file_info *fi, int need,
> =20
>  	while (true) {
>  		flags &=3D CEPH_FILE_MODE_MASK;
> +		if (snapshot && ceph_snapshot_needs_revalidate(inode)) {
> +			/*
> +			 * i_snap_caps cannot be revoked, and an idle snapshot
> +			 * inode may receive no quarantine notification at all.
> +			 * An MDS answer authorizes only this acquisition.
> +			 */
> +			qepoch =3D atomic64_read_acquire(&mdsc->quarantine_epoch);
> +			if (!ceph_cap_auth_valid(mdsc, qepoch)) {
> +				ret =3D ceph_quarantine_wait(inode);
> +				if (ret)
> +					return ret;
> +				continue;
> +			}
> +			ret =3D ceph_snapshot_read_auth(inode);
> +			if (ret)
> +				return ret;
> +			flags |=3D MDS_AUTHORIZED;

[Severity: High]
Does __ceph_get_caps() loop infinitely when reading a snapshot file with
inline data whose MDS reply authorizes access without granting
CEPH_CAP_FILE_CACHE or CEPH_CAP_FILE_LAZYIO in info->cap.caps?

If a snapshot regular file with inline data (ceph_has_inline_data(ci) &&
i_size_read(inode) > 0) previously recorded CEPH_CAP_FILE_RD |
CEPH_CAP_FILE_CACHE in ci->i_snap_caps, those bits are sticky in
__ceph_caps_issued(). When folio 0 is not uptodate (for example after
ceph_read_folio() unlocks a newly allocated folio and calls
__ceph_get_caps()) and ceph_snapshot_needs_revalidate(inode) is true:

1. ceph_snapshot_read_auth(inode) succeeds and sets MDS_AUTHORIZED.
2. try_get_cap_refs() grants _got =3D CEPH_CAP_FILE_RD | CEPH_CAP_FILE_CACHE
   from ci->i_snap_caps.
3. At the bottom of the loop in __ceph_get_caps(), folio 0 is not uptodate,
   so __ceph_get_caps() drops _got and calls:

   __ceph_do_getattr(inode, NULL, CEPH_STAT_CAP_INLINE_DATA, true)

4. In ceph_fill_inode(), fill_inline is only set when locked_folio is
   non-NULL or info_caps from the current reply includes cache_caps:

fs/ceph/inode.c:ceph_fill_inode() {
	...
	if (iinfo->inline_version > 0 &&
	    iinfo->inline_version >=3D ceph_inline_version(ci)) {
		int cache_caps =3D CEPH_CAP_FILE_CACHE | CEPH_CAP_FILE_LAZYIO;
		ceph_set_inline_version(ci, iinfo->inline_version);
		if (ceph_has_inline_data(ci) &&
		    (locked_folio || (info_caps & cache_caps)))
			fill_inline =3D true;
	}
	...
}

When the reply authorizes the read (such as for a recovery client or via
LOOKUPINO) and returns inline data with targeti.inline_version > 1, but
info->cap.caps does not include CEPH_CAP_FILE_CACHE | CEPH_CAP_FILE_LAZYIO,
ceph_fill_inode() skips ceph_fill_inline_data(), __ceph_do_getattr() returns
0, and __ceph_get_caps() executes continue and repeats the RPC loop
indefinitely because folio 0 is never marked uptodate.

> diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
> index 4cba6e7bffd3d..13d4dfef679de 100644
> --- a/fs/ceph/xattr.c
> +++ b/fs/ceph/xattr.c
> @@ -997,6 +997,7 @@ ssize_t __ceph_getxattr(struct inode *inode, const ch=
ar *name, void *value,
>  	struct ceph_vxattr *vxattr;
>  	int req_mask;
>  	ssize_t err;
> +	bool ask_mds =3D false;
> =20
>  	if (strncmp(name, XATTR_CEPH_PREFIX, XATTR_CEPH_PREFIX_LEN))
>  		goto handle_non_vxattrs;
> @@ -1034,7 +1035,19 @@ ssize_t __ceph_getxattr(struct inode *inode, const=
 char *name, void *value,
>  	      ceph_vinop(inode), name, ci->i_xattrs.version,
>  	      ci->i_xattrs.index_version);
> =20
> -	if (ci->i_xattrs.version =3D=3D 0 ||
> +	/*
> +	 * A shared cap would answer from the cache. The state check may
> +	 * schedule, so drop i_ceph_lock first. A reply reading the blob
> +	 * it just installed must still use that cache.
> +	 */
> +	if (!ceph_current_fill_trace_request()) {
> +		spin_unlock(&ci->i_ceph_lock);
> +		ask_mds =3D ceph_snapshot_needs_revalidate(inode) ||
> +			  ceph_inode_quarantine_state(inode) !=3D CEPH_Q_CLEAR;
> +		spin_lock(&ci->i_ceph_lock);
> +	}

[Severity: Medium]
Should __ceph_getxattr() and ceph_listxattr() also check
ceph_quarantine_head_needs_revalidate(inode) when computing ask_mds, just as
ceph_getattr() does?

If an inode holds CEPH_CAP_XATTR_SHARED (for example on a replica MDS cap,
on a session without CEPHFS_FEATURE_QUARANTINE, or after
CEPH_CAP_AUTH_SHARED was released) while ceph_inode_quarantine_state(inode)
returns CEPH_Q_CLEAR, omitting ceph_quarantine_head_needs_revalidate(inode)
allows __ceph_getxattr() and ceph_listxattr() to serve cached xattrs and
POSIX ACLs without consulting the authoritative MDS.

[ ... ]
> @@ -1319,6 +1343,34 @@ int __ceph_setxattr(struct inode *inode, const cha=
r *name,
>  		goto retry;
>  	}
> =20
> +	/*
> +	 * XATTR_EXCL applies the new blob with no MDS round trip.
> +	 * The state check may schedule, so drop i_ceph_lock first.
> +	 */
> +	if (!checked_quarantine) {
> +		enum ceph_qstate qstate;
> +
> +		spin_unlock(&ci->i_ceph_lock);
> +		qstate =3D ceph_inode_quarantine_write_state(inode);
> +		if (qstate =3D=3D CEPH_Q_UNDER &&
> +		    ceph_inode_quarantine_direct(inode)) {
> +			ceph_buffer_put(old_blob);
> +			old_blob =3D NULL;
> +			if (lock_snap_rwsem)
> +				up_read(&mdsc->snap_rwsem);
> +			err =3D -EACCES;
> +			goto out;
> +		}
> +		if (qstate !=3D CEPH_Q_CLEAR) {
> +			ceph_buffer_put(old_blob);
> +			old_blob =3D NULL;
> +			goto do_sync_unlocked;
> +		}
> +		checked_quarantine =3D true;
> +		spin_lock(&ci->i_ceph_lock);
> +		goto retry;
> +	}

[Severity: High]
When __ceph_setxattr() takes the goto do_sync_unlocked path here while the
inode holds CEPH_CAP_XATTR_EXCL, can the local xattr cache become stale or
overwrite the synchronous update on a later cap flush?

__ceph_setxattr() only reaches this check when ci->i_xattrs.version !=3D 0 =
and
issued & CEPH_CAP_XATTR_EXCL is held, after __build_xattrs(inode) has
already built ci->i_xattrs.index.

Jumping to do_sync_unlocked calls ceph_sync_setxattr(), which only sets:

	req->r_inode_drop =3D CEPH_CAP_XATTR_SHARED;

It does not drop or flush CEPH_CAP_XATTR_EXCL. When the MDS reply arrives in
ceph_fill_inode(), issued is computed from cap->implemented |
__ceph_caps_dirty(ci), and the xattr update is skipped whenever
issued & CEPH_CAP_XATTR_EXCL is set:

fs/ceph/inode.c:ceph_fill_inode() {
	...
	if ((ci->i_xattrs.version =3D=3D 0 || !(issued & CEPH_CAP_XATTR_EXCL))  &&
	    le64_to_cpu(info->xattr_version) > ci->i_xattrs.version) {
		...
	}
	...
}

Unlike __ceph_setattr(), which explicitly applies setattr_copy() after a
forced synchronous request when exclusive caps are held, __ceph_setxattr()
leaves the old blob and ci->i_xattrs.index intact, and if
CEPH_CAP_XATTR_EXCL was already dirty from an earlier cached setxattr, the
subsequent cap flush will encode the stale RB-tree and lose the synchronous
xattr modification.

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/cover.20261025T1826=
49Z.ca9ae7a18449.git.amarkuze@redhat.com?part=3D5
