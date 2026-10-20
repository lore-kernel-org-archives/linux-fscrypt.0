Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792539435;
	b=2Oqgd2Wl4vPfcMy4xqEpM7vffTEgMGEjVULs2Y6oowMEzS6E7BG5GzaydvkAyLXXDepS
	 rgbYBNRUCdXFBi4PjilnHn9K/jQG9enA/frjh9qkrx/KhbfYapABkaGWYO20xO3MM6AyZ
	 OIGGM/bNG37/f6e0/7TmJWJFuShBfSxFVkDW0aslyqQyjZg5y/z5/9bhK4JiChc/MbQhg
	 wFj5xl8AaDV/Sc/7U3Z4sbcihleu9gFrnevcdLXqL5UIFcG1UWhA+htWoj2/A/wZncyoS
	 Sefqup1LEVcJJaCRe32H4S8jO0lV8V2dP7/QEAC6xf6DzUhNAfZ7dfSHyo3PvEjUtCQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792539435;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=Eqzgo5K5Ndx7gbrdpdb8uU0PXlmNqY0IOrrZV9R4J0E=;
	b=hBI0ceCWDGmx5TU9pnYbHNvTzpOFXiMoRuCLsZzBpckobyeVIajRCgsRFHV0KxzewuSC
	 BzFwE40kPv1pkEYhFwwvBXHQPfm3KtWfb8zP2zgwXDioBlEbhl1dXM41dV807m3hXteJo
	 hcaLyb2JfYc0jjCM20uI5xlMTfSwG96MTDlwKIPRx5i4dJNFSlxIDFzqI5P6MlFbec5PQ
	 jROeCAWmemXiRQWOlamGnMVS8br5fkJsRIuhxf9HCf229ABS6hyhbRzcF2M0AEkiJ3d5U
	 XBeFpfeMOODzqj8wZ9oESKkRes7p7LHiRvxJPgUaIjAINroZ6hApKdLdOW9gKJjjXhg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g+5X7yZX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 00416606A31A
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 23:37:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=g+5X7yZX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DB9F01F000C9;
	Tue, 20 Oct 2026 23:37:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792539434;
	bh=Eqzgo5K5Ndx7gbrdpdb8uU0PXlmNqY0IOrrZV9R4J0E=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=g+5X7yZXYmwc2JnmD2fKnvi7S4qHNJVH4LC875qpcYfQd7i6yh9/Hx27BKkexwsPl
	 oucLwAs4JHWVfdaTQykSKp5ABS3Bkv54ggexuSXdpWV4SABoXEo6JDrVZMVb2Bpzt7
	 gTGbUGNQJsZt5D8886cm/z9j/aRM3Q/A7rLiWqnwacjSU2TcIko4UiETWO4sviYMHU
	 /TckGWzg+CQPCugyGZpYKtFQnMf/yl4uODRiNYrbSHLCzRCZXz/Xr4EwyHgqCc8mf+
	 COOh8gSjKy+0LFsuD7Fg2mvFq23tFHzFwMNlLjQgZwjIiqQKR3uk9nHVJewt3jOo35
	 qlwVUU1jYuiLg==
Message-ID: <sashiko-outbox-179606@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH v5 5/5] ceph: fail quarantined subvolume access with
 EACCES
Reply-To: sashiko-reviews@lists.linux.dev
To: "Alex Markuze" <amarkuze@redhat.com>
Cc: idryomov@gmail.com, xiubo.li@clyso.com, slava@dubeyko.com, viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz, linux-fscrypt@vger.kernel.org, ebiggers@kernel.org, tytso@mit.edu, jaegeuk@kernel.org
In-Reply-To: <345a4e8317cde90293b0d4ee9d8a3edfd229e204.1792527529.git.amarkuze@redhat.com>
References: <cover.1792527529.git.amarkuze@redhat.com>
 <345a4e8317cde90293b0d4ee9d8a3edfd229e204.1792527529.git.amarkuze@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Tue, 20 Oct 2026 23:37:13 +0000
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

Thank you for your contribution! Sashiko AI review found 6 potential issue(=
s) to consider:
- [High] ceph: recursive MDS requests and deadlock in splice LSM hooks
- [High] ceph: ceph_open() skips access and snap_caps checks on snapshots
- [High] ceph: double ceph_buffer_put() of old_blob on retry in __ceph_setx=
attr()
- [Medium] ceph: ceph_cap_auth_valid() skips epoch checks when quarantine_c=
ount is 0
- [Medium] ceph: missing head cap validation in xattr, ACL, and lookup paths
- [Medium] ceph: __ceph_do_getattr() misses direct-mark and post-RPC epoch =
checks
--

commit 60ee77fdf7eb1f1cf01d2c90a0a3b53835663f69
Author: Alex Markuze <amarkuze@redhat.com>

ceph: fail quarantined subvolume access with EACCES

This commit advertises CEPHFS_FEATURE_QUARANTINE and gates cached data,
metadata, directory, symlink, xattr, ACL, ioctl, and snapshot operations so
that quarantined subvolume accesses fail with -EACCES. It also tracks
namespace mutations and splices to invalidate cached quarantine receipts and
prevent recursive LSM hooks from blocking on their own splice operations.

> diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
> index 94f015112942d..9b8afd0be194c 100644
> --- a/fs/ceph/caps.c
> +++ b/fs/ceph/caps.c
> @@ -3010,10 +3010,39 @@ enum {

[ ... ]

> +static bool ceph_cap_auth_valid(struct ceph_mds_client *mdsc, u64 epoch)
> +{
> +	if (!atomic_read(&mdsc->quarantine_count))
> +		return true;
> +
> +	/* Order authorization and cap observations before the generation check=
. */
> +	smp_rmb();
> +	return !(epoch & 1) &&
> +	       (u64)atomic64_read_acquire(&mdsc->quarantine_epoch) =3D=3D epoch=
 &&
> +	       !atomic_read(&mdsc->quarantine_splices);
> +}

[Severity: Medium]
Can ceph_cap_auth_valid() in fs/ceph/caps.c accept a stale or mid-mutation
epoch by returning true early when mdsc->quarantine_count is zero?

In fs/ceph/inode.c:ceph_quarantine_set(), ceph_quarantine_write_begin()
increments mdsc->quarantine_epoch to an odd value before
atomic_inc(&mdsc->quarantine_count) transitions quarantine_count from 0 to =
1:

    ceph_quarantine_write_begin(mdsc);
    if (mdsc)
        atomic_inc(&mdsc->quarantine_count);

Because the relaxed atomic_read(&mdsc->quarantine_count) in
ceph_cap_auth_valid() runs before smp_rmb() and before checking !(epoch & 1=
),
quarantine_epoch =3D=3D epoch, and !atomic_read(&mdsc->quarantine_splices),=
 a
concurrent caller in __ceph_get_caps() or try_get_cap_refs() can observe
quarantine_count =3D=3D 0 and treat the authorization as valid while the fi=
rst
quarantine mark is already being set.

In addition, for snapshot inodes in __ceph_get_caps(),
ceph_snapshot_needs_revalidate(inode) can be true when mdsc->quarantine_cou=
nt
is 0 (for example, when accessing an ancestor snapshot P/.snap/S/V/file whe=
re
quarantining V leaves no local marks on P, or while a splice or rename is in
progress). Returning true unconditionally when quarantine_count is 0 skips
waiting in ceph_quarantine_wait() when qepoch is odd or quarantine_splices =
is
non-zero, and skips detecting epoch changes in try_get_cap_refs().

> diff --git a/fs/ceph/file.c b/fs/ceph/file.c
> index 9a6eadb94ab4f..5b3a64c8571c9 100644
> --- a/fs/ceph/file.c
> +++ b/fs/ceph/file.c
> @@ -371,7 +373,9 @@ int ceph_open(struct inode *inode, struct file *file)

[ ... ]

> @@ -414,28 +435,31 @@ int ceph_open(struct inode *inode, struct file *fil=
e)
> =20
>  	if (fmode & CEPH_FILE_MODE_WR)
>  		mask |=3D MAY_WRITE;
> -	dentry =3D d_find_alias(inode);
> -	if (!dentry) {
> -		do_sync =3D true;
> -	} else {
> -		struct ceph_path_info path_info =3D {0};
> -		path =3D ceph_mdsc_build_path(mdsc, dentry, &path_info, 0);
> -		if (IS_ERR(path)) {
> +	if (!snapshot) {
> +		dentry =3D d_find_alias(inode);
> +		if (!dentry) {
>  			do_sync =3D true;
> -			err =3D 0;
>  		} else {
> -			err =3D ceph_mds_check_access(mdsc, path, mask);
> -		}
> -		ceph_mdsc_free_path_info(&path_info);
> -		dput(dentry);
> +			struct ceph_path_info path_info =3D {0};
> =20
> -		/* For none EACCES cases will let the MDS do the mds auth check */
> -		if (err =3D=3D -EACCES) {
> -			ceph_blog_exit(&__ji);
> -			return err;
> -		} else if (err < 0) {
> -			do_sync =3D true;
> -			err =3D 0;
> +			path =3D ceph_mdsc_build_path(mdsc, dentry, &path_info, 0);
> +			if (IS_ERR(path)) {
> +				do_sync =3D true;
> +				err =3D 0;
> +			} else {
> +				err =3D ceph_mds_check_access(mdsc, path, mask);
> +			}
> +			ceph_mdsc_free_path_info(&path_info);
> +			dput(dentry);
> +
> +			/* Let the MDS handle errors other than EACCES. */
> +			if (err =3D=3D -EACCES) {
> +				ceph_blog_exit(&__ji);
> +				return err;
> +			} else if (err < 0) {
> +				do_sync =3D true;
> +				err =3D 0;
> +			}
>  		}
>  	}
> =20
> @@ -445,12 +469,23 @@ int ceph_open(struct inode *inode, struct file *fil=
e)
>  		return -EROFS;
>  	}
> =20
> -	/* trivially open snapdir */
> +	/* A synthetic snapdir must be validated through its real parent. */
>  	if (ceph_snap(inode) =3D=3D CEPH_SNAPDIR) {
> +		err =3D ceph_quarantine_revalidate(inode);
>  		ceph_blog_exit(&__ji);
> +		if (err)
> +			return err;
>  		return ceph_init_file(inode, file, fmode);
>  	}
> =20
> +	if (snapshot) {
> +		err =3D ceph_snapshot_read_auth(inode);
> +		if (!err)
> +			err =3D ceph_init_file(inode, file, fmode);
> +		ceph_blog_exit(&__ji);
> +		return err;
> +	}

[Severity: High]
Does gating ceph_mds_check_access() on !snapshot and returning early from
ceph_open() in fs/ceph/file.c bypass MDS auth cap checks and i_snap_caps
verification when opening cached snapshot files?

In fs/ceph/inode.c:ceph_snapshot_read_auth(), the function returns 0 without
contacting the MDS whenever !ceph_snapshot_needs_revalidate(inode) holds:

    int ceph_snapshot_read_auth(struct inode *inode)
    {
        if (!ceph_snapshot_needs_revalidate(inode))
            return 0;

        return ceph_do_getattr(inode, CEPH_CAP_AUTH_SHARED, true);
    }

That condition is satisfied whenever mdsc->quarantine_supported is false, as
well as when quarantine_supported is true, mdsc->quarantine_count is 0, and
the connected subvolume root head inode holds a valid CEPH_CAP_AUTH_SHARED
cap.

When ceph_snapshot_read_auth() returns 0 from cache, ceph_open() now skips
both the local ceph_mds_check_access(mdsc, path, mask) check against
mdsc->s_cap_auths and any MDS OPEN or GETATTR request, allowing a caller
restricted by UID, GID, or path in s_cap_auths to open cached snapshot inod=
es
without getting -EACCES.

Returning unconditionally in the if (snapshot) block also skips checking
whether (ci->i_snap_caps & wanted) =3D=3D wanted (and ceph_snapshot_read_au=
th()
only requests CEPH_CAP_AUTH_SHARED rather than wanted when it does call the
MDS). This allows a snapshot inode that only holds CEPH_CAP_PIN (such as one
populated via LOOKUPINO) to be opened without CEPH_CAP_FILE_RD, and leaves =
the
existing snapshot cap check further down in ceph_open() unreachable:

    } else if (!do_sync && ceph_in_snap(inode) &&
               (ci->i_snap_caps & wanted) =3D=3D wanted) {

> diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
> index 78e97cf2f9a41..781b6d97daa0e 100644
> --- a/fs/ceph/inode.c
> +++ b/fs/ceph/inode.c
> @@ -3582,21 +3958,59 @@ int __ceph_do_getattr(struct inode *inode, struct=
 folio *locked_folio,
>  	struct ceph_client *cl =3D fsc->client;
>  	struct ceph_mds_client *mdsc =3D fsc->mdsc;
>  	struct ceph_mds_request *req;
> +	bool head_revalidate;
> +	u64 qepoch;
>  	int mode;
>  	int err;
> =20
>  	if (ceph_snap(inode) =3D=3D CEPH_SNAPDIR) {
> +		struct inode *parent;
> +
>  		boutc(cl, "inode %p %llx.%llx SNAPDIR\n", inode,
>  		      ceph_vinop(inode));
> -		return 0;
> +		if (!ceph_snapshot_needs_revalidate(inode))
> +			return 0;
> +		/* The synthetic snapdir has the real directory's ino. */
> +		parent =3D ceph_lookup_inode(inode->i_sb, ceph_ino(inode));
> +		if (IS_ERR(parent))
> +			return PTR_ERR(parent);
> +		err =3D ceph_do_getattr(parent, mask, true);
> +		iput(parent);
> +		return err;
>  	}
> =20
> +	head_revalidate =3D ceph_quarantine_head_needs_revalidate(inode);
> +	if (head_revalidate) {
> +		/* Do not recurse into an MDS request from our own splice hook. */
> +		err =3D ceph_quarantine_wait(inode);
> +		if (err)
> +			return err;
> +		mask |=3D CEPH_CAP_AUTH_SHARED;
> +	}

[Severity: High]
What happens when an LSM hook invoked from d_splice_alias(), d_instantiate(=
),
or d_make_root() re-enters __ceph_getxattr(), ceph_listxattr(), or
__ceph_do_getattr() while ceph_fill_inode() has already granted
CEPH_CAP_AUTH_SHARED or when splicing a snapshot or snapdir inode?

During d_splice_alias(), d_instantiate(), and d_make_root(), the VFS runs
security_d_instantiate(dentry, inode) before linking the dentry onto
inode->i_dentry. At the four splice sites outside ceph_fill_trace() --
ceph_finish_async_create() in fs/ceph/file.c, ceph_handle_snapdir() and
ceph_link() in fs/ceph/dir.c, and open_root_dentry() in fs/ceph/super.c --
ceph_current_fill_trace_request() is NULL while qsplice is active.

When selinux_d_instantiate() calls __vfs_getxattr() -> __ceph_getxattr() (or
ceph_listxattr()) in fs/ceph/xattr.c:

    if (!ceph_current_fill_trace_request()) {
        spin_unlock(&ci->i_ceph_lock);
        ask_mds =3D ceph_snapshot_needs_revalidate(inode) ||
                  ceph_inode_quarantine_state(inode) !=3D CEPH_Q_CLEAR;
        spin_lock(&ci->i_ceph_lock);
    }

because the dentry is not yet attached to the inode (d_find_alias_rcu(inode)
is NULL) and mdsc->quarantine_splices is non-zero,
ceph_inode_quarantine_state(inode) returns CEPH_Q_UNKNOWN whenever
mdsc->quarantine_count > 0, and ceph_snapshot_needs_revalidate(inode) retur=
ns
true for CEPH_SNAPDIR inodes even when mdsc->quarantine_count =3D=3D 0. Tha=
t sets
ask_mds =3D true, bypassing the xattr blob just installed by ceph_fill_inod=
e()
and calling ceph_do_getattr(inode, CEPH_STAT_CAP_XATTR, true).

In __ceph_do_getattr(), ceph_quarantine_wait(inode) -- the only helper that
checks mdsc->quarantine_splice_owners and ceph_current_fill_trace_request()=
 --
is only called when head_revalidate is true. However, ceph_fill_inode() has
already granted CEPH_CAP_AUTH_SHARED on ci->i_auth_cap in
ceph_finish_async_create(), ceph_fill_trace(), ceph_readdir_prepopulate(),
open_root_dentry(), and ceph_link(), and head_revalidate is always false for
snapshot and snapdir inodes. As a result, __ceph_do_getattr() skips
ceph_quarantine_wait(inode) and issues a synchronous CEPH_MDS_OP_GETATTR
request from inside the splice LSM hook:

1. In ceph_finish_async_create(), CEPH_I_ASYNC_CREATE_BIT and
   CEPH_DENTRY_ASYNC_CREATE_BIT are set before d_splice_alias(); the recurs=
ive
   GETATTR blocks in ceph_wait_on_async_create(inode) while d_inode(dentry)=
 is
   still NULL, deadlocking if the async create request fails or is forwarde=
d.
2. In ceph_fill_trace() and ceph_readdir_prepopulate(), an LSM hook calling
   ceph_getattr(), ceph_listxattr(), ceph_permission(), or ceph_get_link() =
on
   an inode with AUTH_SHARED or a snapshot inode deadlocks the MDS session
   thread on session->s_mutex.
3. In ceph_handle_snapdir(), __ceph_do_getattr() on CEPH_SNAPDIR calls
   ceph_do_getattr(parent, mask, true), either failing with -EBUSY and
   breaking SELinux snapdir labeling or sending a synchronous GETATTR while
   holding qsplice.

> +
> +	/*
> +	 * Cached caps would satisfy getattr after the MDS has revoked
> +	 * access, and a short walk has no ancestor to consult. Ask the
> +	 * MDS so a lost quarantine-disable can clear the mark, and so
> +	 * an uncached parent chain is not treated as clear. Snapshot caps need
> +	 * an MDS check unless a live head cap provides quarantine notification=
s.
> +	 */
> +	if (ceph_snapshot_needs_revalidate(inode) ||
> +	    head_revalidate ||
> +	    ceph_inode_quarantine_state(inode) !=3D CEPH_Q_CLEAR)
> +		force =3D true;
> =20
>  	boutc(cl, "inode %p %llx.%llx mask %s mode 0%o\n", inode,
>  	      ceph_vinop(inode), ceph_cap_string(mask), inode->i_mode);
>  	if (!force && ceph_caps_issued_mask_metric(ceph_inode(inode), mask, 1))
>  			return 0;
> =20
> -	mode =3D ceph_try_to_choose_auth_mds(inode, mask);
> +	if (ceph_in_snap(inode) && !ceph_snapshot_has_path(inode, false))
> +		return ceph_snapshot_lookupino(inode, locked_folio, mask);
> +
> +	qepoch =3D (u64)atomic64_read_acquire(&mdsc->quarantine_epoch);
> +	mode =3D head_revalidate ? USE_AUTH_MDS :
> +		ceph_try_to_choose_auth_mds(inode, mask);
>  	req =3D ceph_mdsc_create_request(mdsc, CEPH_MDS_OP_GETATTR, mode);
>  	if (IS_ERR(req))
>  		return PTR_ERR(req);
> @@ -3606,6 +4020,15 @@ int __ceph_do_getattr(struct inode *inode, struct =
folio *locked_folio,
>  	req->r_args.getattr.mask =3D cpu_to_le32(mask);
>  	req->r_locked_folio =3D locked_folio;
>  	err =3D ceph_mdsc_do_request(mdsc, NULL, req);
> +	if (ceph_in_snap(inode)) {
> +		if (err =3D=3D -EINVAL || err =3D=3D -ESTALE ||
> +		    (!err && ceph_snapshot_reply_error(inode, req, mask))) {
> +			ceph_mdsc_put_request(req);
> +			return ceph_snapshot_lookupino(inode, locked_folio, mask);
> +		}
> +	}
> +	if (!err && !ceph_in_snap(inode))
> +		ceph_quarantine_remember_clear(inode, qepoch, req->r_cred);

[Severity: Medium]
Should __ceph_do_getattr() in fs/ceph/inode.c also check
ceph_inode_quarantine_direct(inode) and retry when quarantine_epoch changes
across the GETATTR request, similar to ceph_quarantine_revalidate()?

Callers that rely on ceph_do_getattr() to validate quarantine access --
including ceph_getattr(), __ceph_getxattr(), ceph_listxattr(),
ceph_get_link(), ceph_encrypted_get_link(), ceph_snapshot_read_auth(),
ceph_permission(), and ceph_ioctl_get_dataloc() -- do not call
ceph_quarantine_revalidate().

Unlike ceph_quarantine_revalidate(), __ceph_do_getattr() does not check
ceph_inode_quarantine_direct(inode) before or after ceph_mdsc_do_request().
When head_revalidate is false (for example, the inode already holds
CEPH_CAP_AUTH_SHARED while an ancestor is marked or uncached) and force is =
set
because ceph_inode_quarantine_state(inode) !=3D CEPH_Q_CLEAR, __ceph_do_get=
attr()
does not wait in ceph_quarantine_wait(inode) before sampling qepoch and uses
ceph_try_to_choose_auth_mds(inode, mask), which can send the request to a
replica MDS (USE_ANY_MDS).

Furthermore, after ceph_mdsc_do_request() returns 0,
ceph_quarantine_remember_clear(inode, qepoch, req->r_cred) drops the receipt
if quarantine_epoch changed, a splice is active, or
ceph_inode_quarantine_direct(inode) became true during the RPC, but
__ceph_do_getattr() still returns 0 to the caller.

> diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
> index 4cba6e7bffd3d..9db250b2e7beb 100644
> --- a/fs/ceph/xattr.c
> +++ b/fs/ceph/xattr.c
> @@ -997,6 +997,7 @@ ssize_t __ceph_getxattr(struct inode *inode, const ch=
ar *name, void *value,

[ ... ]

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
> +
> +	if (ask_mds || ci->i_xattrs.version =3D=3D 0 ||
>  	    !((req_mask & CEPH_CAP_XATTR_SHARED) ||
>  	      __ceph_caps_issued_mask_metric(ci, CEPH_CAP_XATTR_SHARED, 1))) {
>  		spin_unlock(&ci->i_ceph_lock);
> @@ -1089,6 +1102,7 @@ ssize_t ceph_listxattr(struct dentry *dentry, char =
*names, size_t size)
>  	struct ceph_client *cl =3D ceph_inode_to_client(inode);
>  	struct ceph_inode_info *ci =3D ceph_inode(inode);
>  	bool len_only =3D (size =3D=3D 0);
> +	bool ask_mds =3D false;
>  	u32 namelen;
>  	int err;
>  	struct ceph_journal_info __ji;
> @@ -1100,7 +1114,15 @@ ssize_t ceph_listxattr(struct dentry *dentry, char=
 *names, size_t size)
>  	      ceph_vinop(inode), ci->i_xattrs.version,
>  	      ci->i_xattrs.index_version);
> =20
> -	if (ci->i_xattrs.version =3D=3D 0 ||
> +	/* Same as __ceph_getxattr(): do not serve a shared cap hit. */
> +	if (!ceph_current_fill_trace_request()) {
> +		spin_unlock(&ci->i_ceph_lock);
> +		ask_mds =3D ceph_snapshot_needs_revalidate(inode) ||
> +			  ceph_inode_quarantine_state(inode) !=3D CEPH_Q_CLEAR;
> +		spin_lock(&ci->i_ceph_lock);
> +	}
> +
> +	if (ask_mds || ci->i_xattrs.version =3D=3D 0 ||
>  	    !__ceph_caps_issued_mask_metric(ci, CEPH_CAP_XATTR_SHARED, 1)) {
>  		spin_unlock(&ci->i_ceph_lock);
>  		err =3D ceph_do_getattr(inode, CEPH_STAT_CAP_XATTR, true);

[Severity: Medium]
Should __ceph_getxattr() and ceph_listxattr() in fs/ceph/xattr.c (as well as
ceph_lookup() in fs/ceph/dir.c) also check
ceph_quarantine_head_needs_revalidate()?

In fs/ceph/dir.c:ceph_lookup(), negative complete-dir lookups only check
ceph_inode_quarantine_state(dir):

    if (d_really_is_negative(dentry) &&
        ceph_inode_quarantine_state(dir) =3D=3D CEPH_Q_CLEAR) {

When mdsc->quarantine_count is 0, ceph_inode_quarantine_state() returns
CEPH_Q_CLEAR immediately. Because __ceph_caps_issued_mask_metric() checks
whether CEPH_CAP_XATTR_SHARED or CEPH_CAP_FILE_SHARED is issued on any cap =
in
ci->i_caps (including replica MDS caps, sessions without
CEPHFS_FEATURE_QUARANTINE, or when ci->i_auth_cap lacks CEPH_CAP_AUTH_SHARE=
D),
__ceph_getxattr(), ceph_get_acl(), ceph_listxattr(), and ceph_lookup() can
serve cached xattrs, POSIX ACLs, and negative lookups without a quarantine-
aware authoritative AUTH_SHARED cap.

Similarly, when mdsc->quarantine_count > 0, __ceph_do_getattr() records a r=
ead
receipt via ceph_quarantine_remember_clear() even when no cap was granted by
the MDS. Subsequent calls to __ceph_getxattr(), ceph_get_acl(),
ceph_listxattr(), and ceph_lookup() in the same epoch see
ceph_inode_quarantine_state() =3D=3D CEPH_Q_CLEAR and reuse that receipt fr=
om
cache without a revocable cap.

> @@ -1222,6 +1244,7 @@ int __ceph_setxattr(struct inode *inode, const char=
 *name,
>  	int required_blob_size;
>  	bool check_realm =3D false;
>  	bool lock_snap_rwsem =3D false;
> +	bool checked_quarantine =3D false;
> =20
>  	if (ceph_in_snap(inode))
>  		return -EROFS;
> @@ -1319,6 +1342,33 @@ int __ceph_setxattr(struct inode *inode, const cha=
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
Can jumping to retry from the !checked_quarantine block in
fs/ceph/xattr.c:__ceph_setxattr() without releasing and clearing old_blob
cause a double ceph_buffer_put(old_blob)?

Just above this block in __ceph_setxattr(), when a prealloc_blob needs to be
allocated or grown, the code saves any previous ci->i_xattrs.prealloc_blob =
in
old_blob and jumps to retry without resetting old_blob =3D NULL after
ceph_buffer_put(old_blob):

    if (!ci->i_xattrs.prealloc_blob ||
        required_blob_size > ci->i_xattrs.prealloc_blob->alloc_len) {
        struct ceph_buffer *blob;

        spin_unlock(&ci->i_ceph_lock);
        ceph_buffer_put(old_blob); /* Shouldn't be required */
        ...
        blob =3D ceph_buffer_new(required_blob_size, GFP_NOFS);
        if (!blob)
            goto do_sync_unlocked;
        spin_lock(&ci->i_ceph_lock);
        /* prealloc_blob can't be released while holding i_ceph_lock */
        if (ci->i_xattrs.prealloc_blob)
            old_blob =3D ci->i_xattrs.prealloc_blob;
        ci->i_xattrs.prealloc_blob =3D blob;
        goto retry;
    }

If the first pass replaces an existing smaller ci->i_xattrs.prealloc_blob,
execution reaches the new !checked_quarantine block on the second pass with
old_blob !=3D NULL. That block drops ci->i_ceph_lock to call
ceph_inode_quarantine_write_state(inode), and when qstate =3D=3D CEPH_Q_CLE=
AR it
sets checked_quarantine =3D true, reacquires ci->i_ceph_lock, and jumps to =
retry
still holding the non-NULL old_blob.

If a concurrent cap flush or cap snap (__prep_cap() or ceph_queue_cap_snap()
calling __ceph_build_xattrs_blob()) runs while ci->i_ceph_lock is dropped a=
nd
consumes ci->i_xattrs.prealloc_blob (setting ci->i_xattrs.prealloc_blob =3D
NULL), the next pass of retry will enter the prealloc_blob allocation block
again. That block calls ceph_buffer_put(old_blob) to free old_blob, sees
ci->i_xattrs.prealloc_blob =3D=3D NULL so it leaves old_blob pointing to th=
e freed
buffer, and then the final ceph_buffer_put(old_blob) after __set_xattr() (or
at do_sync) frees old_blob a second time.

> =20
>  	err =3D __set_xattr(ci, newname, name_len, newval, val_len,
>  			  flags, value ? 1 : -1, &xattr);

[ ... ]

>
> --=20
> 2.51.0

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/cover.1792527529.gi=
t.amarkuze@redhat.com?part=3D5
