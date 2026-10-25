Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792955537;
	b=TfiLFxfCL/33aUc3/S5GeedHol86AQe3pZRKKtqMZ4WBAQFOn+PskkAkyT/1RyU/9Oaf
	 Jv5GrnkJ8kPKEX6wPouoqWs11nI4UUD8awNAlnJueAXbMint8U806axFIMMvcrCPijANU
	 K3Cf3xLqh03o1TgLXLIMQKbo0ZqWco901fXtRT6p510VSuFCNEKL+jViE/D1cbIvJLhDU
	 A5Nx24GYg4Db/BDo2rjb/FarOuP0Z9eOXipSCCaLC/Nq2vPTD+uUfHUPshB3y6HEFQfr3
	 fee5EDGLBZUu8Cj2zLzc0D58biu5+uozdwRhpHJJ7sObN3n0u/BfG4Nyyvae9q9U/TA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792955537;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=VlE8ykuN6YWkkdsRmOeQ735SXG4eY3/HeHu26s+pVWM=;
	b=gDl5cOD3fxcYXUDB2w53yZmsYUkj1pjjzHswCKNAm3OlESN6hVXqdLkhnUv7XBgJwmiF
	 x7cvd6pppEoNxhYg0OnHbhtlqrbDR32i9Ho2wYtejXFSW5Mg39xhSZP9r2MZsNk7r9b5G
	 26dV33C6/RbEjqNIjwjSqOLyR1rlmqtS88tF/5mlhdLXk9KW9vOICvOwzl50qPGtNzN+n
	 lNesMuhlUScE9AR1PkSu8/ErJAtX2xT11sEvqS8xhxldsbonbIMyoExDO0NHvdJIzOeUa
	 Z3qMWbPhwtxrL4DvXEVNs87MjlcvKQDn/cUYMcu+hZ83ZgdfNSoBUBjOGjd7yf8zcfQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Vc9p1Lqm;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71822606A31A
	for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 19:12:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Vc9p1Lqm
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8BF901F01825;
	Sun, 25 Oct 2026 19:12:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792955537;
	bh=VlE8ykuN6YWkkdsRmOeQ735SXG4eY3/HeHu26s+pVWM=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=Vc9p1LqmOaXtIvW0PGH8Uq9qpK7PTj73VwycJrUjyo+drQ6TRxB5lflXNiEx7OmZ4
	 0jbfclUJqO9Gm851UhdDG7gZeP8FNMw3bFQRm6CiOpMPvE/UWvTY5oUu3JbOoU6s/D
	 3g1zZnoe/LUd+50g/QcFo71uWkawPBsNiCtJoOTVM/HNCmbdO1pRR01BnMJV+lrTyg
	 /BLYElS3gdPw62YGi7KTc1elq+IOtZ6cLBRFMlaj+oWlRxv8oEiANlGj7zKaQ+K4Yv
	 wOnUAF57G4dECWsYfcpWByt6VGtsZpE8ZbMZWK8pvTHxqQ8KB+7V8rAuFOCqifi/hQ
	 oczoO0rg91H0Q==
Message-ID: <sashiko-outbox-184356@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH v6 4/5] ceph: record subvolume quarantine from MDS cap
 updates
Reply-To: sashiko-reviews@lists.linux.dev
To: "Alex Markuze" <amarkuze@redhat.com>
Cc: idryomov@gmail.com, xiubo.li@clyso.com, slava@dubeyko.com, viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz, linux-fscrypt@vger.kernel.org, ebiggers@kernel.org, tytso@mit.edu, jaegeuk@kernel.org
In-Reply-To: <1b6167c472fe05e2cd650bde2ffc9421892ad4cc.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
References: <cover.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
 <1b6167c472fe05e2cd650bde2ffc9421892ad4cc.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Sun, 25 Oct 2026 19:12:16 +0000
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list

Thank you for your contribution! Sashiko AI review found 2 potential issue(=
s) to consider:
- [High] ceph: epoch self-invalidation in ceph_quarantine_reply_can_clear()
- [High] ceph: __ceph_remove_cap() resets quarantine mark during cap migrat=
ion
--

commit 8a2e69935d967838e52792bb963b124cfe229b88
Author: Alex Markuze <amarkuze@redhat.com>

ceph: record subvolume quarantine from MDS cap updates

This commit decodes the signed oserrno from MClientCaps v14 messages to
record a sticky subvolume quarantine mark and reporting MDS rank on each
inode, along with epoch-based caching and RCU parent walks to resolve
inherited quarantine state.

> diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
> index b27bcdc24d29f..b07814d0038cd 100644
> --- a/fs/ceph/caps.c
> +++ b/fs/ceph/caps.c

[ ... ]

> @@ -1264,6 +1265,11 @@ static void __ceph_remove_cap(struct ceph_inode_in=
fo *ci, struct ceph_cap *cap,
> =20
>  	mdsc =3D ceph_inode_to_fs_client(&ci->netfs.inode)->mdsc;
> =20
> +	/* Losing the reporting cap requires fresh MDS revalidation. */
> +	if (READ_ONCE(ci->i_qtine_mds) =3D=3D cap->mds &&
> +	    ceph_quarantine_reset(ci))
> +		wake_up_all(&ci->i_cap_wq);
> +
>  	/* remove from inode's cap rbtree, and clear auth cap */
>  	rb_erase(&cap->ci_node, &ci->i_caps);
>  	if (ci->i_auth_cap =3D=3D cap)
> @@ -3729,6 +3735,9 @@ struct cap_extra_info {
>  	u8 *fscrypt_auth;
>  	u32 fscrypt_auth_len;
>  	u64 fscrypt_file_size;
> +	/* MClientCaps v14 oserrno; valid only when oserrno_valid is set */
> +	s32 oserrno;
> +	bool oserrno_valid;
>  };
> =20
>  /*
> @@ -3757,6 +3766,46 @@ static int parse_inline_data(void **p, void *end,
>  	return -EIO;
>  }
> =20
> +/*
> + * Record quarantine state carried by an MClientCaps oserrno.
> + * Caller holds i_ceph_lock. Returns true when waiters should be woken
> + * because quarantine changed or a pending reset was resolved.
> + *
> + * -EQUARANTINED refreshes the sticky flag and its reporting MDS rank.
> + * A current non-IMPORT grant above PIN with errno 0 clears that rank's =
mark.
> + * IMPORT may carry a default zero without assessing quarantine permissi=
on.
> + * Another rank needs a successful metadata request for the current epoc=
h.
> + * A PIN-only update may zero qtine_errno while leaving the flag set.
> + */
> +static bool ceph_apply_quarantine(struct ceph_inode_info *ci, int mds,
> +				  int newcaps, int oserrno, bool is_import)
> +{
> +	bool was, now, pending;
> +
> +	was =3D READ_ONCE(ci->i_qtine_errno) =3D=3D -CEPH_EQUARANTINED ||
> +	      test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags);
> +	pending =3D test_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags);
> +
> +	if (!is_import && (newcaps & ~CEPH_CAP_PIN) && was && oserrno =3D=3D 0 =
&&
> +	    READ_ONCE(ci->i_qtine_mds) =3D=3D mds)
> +		ceph_quarantine_clear(ci);
> +
> +	if (oserrno =3D=3D -CEPH_EQUARANTINED) {
> +		ceph_quarantine_set(ci);
> +		WRITE_ONCE(ci->i_qtine_mds, mds);
> +	}

[Severity: High]
When a quarantined inode's capability is migrated between MDS ranks via
handle_cap_export() or handle_cap_import(), removing the exporting rank's
cap calls ceph_remove_cap() -> __ceph_remove_cap(), which sees
ci->i_qtine_mds =3D=3D cap->mds and calls ceph_quarantine_reset(ci).

When handle_cap_grant() then processes the CEPH_CAP_OP_IMPORT message from
the new authoritative rank with the default oserrno =3D=3D 0,
ceph_apply_quarantine() leaves CEPH_I_QUARANTINE_PENDING_BIT set and keeps
ci->i_qtine_mds set to the old exporting rank.

As a result:
1. ceph_inode_quarantine_direct() returns false and
   ceph_quarantine_walk_once() breaks out with CEPH_QWALK_INCOMPLETE instead
   of reporting the retained quarantine mark as CEPH_Q_UNDER.
2. Subsequent normal CEPH_CAP_OP_GRANT messages (above CEPH_CAP_PIN with
   oserrno =3D=3D 0) and CEPH_MSG_CLIENT_QUARANTINE_DISABLE messages from t=
he
   new authoritative rank cannot clear the mark in ceph_apply_quarantine()
   or ceph_handle_quarantine_disable() because ci->i_qtine_mds still holds
   the pre-migration rank.

Should capability migration preserve the active mark and transfer
ci->i_qtine_mds to the importing rank instead of resetting the mark to
pending when the old rank's cap is removed?

[ ... ]

> diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
> index 94f5215f8eed5..048e0d502eb4e 100644
> --- a/fs/ceph/inode.c
> +++ b/fs/ceph/inode.c

[ ... ]

> +static bool ceph_quarantine_reply_can_clear(struct ceph_inode_info *ci,
> +					    struct ceph_mds_session *session)
> +{
> +	struct ceph_mds_client *mdsc =3D ceph_sb_to_mdsc(ci->netfs.inode.i_sb);
> +	struct ceph_mds_request *req;
> +	u64 epoch;
> +
> +	if (READ_ONCE(ci->i_qtine_mds) =3D=3D session->s_mds)
> +		return true;
> +	/* Different ranks have independent cap sequences. */
> +	req =3D ceph_current_mds_request(mdsc->fsc);
> +	epoch =3D (u64)atomic64_read_acquire(&mdsc->quarantine_epoch);
> +	return req && !(epoch & 1) && req->r_quarantine_epoch =3D=3D epoch &&
> +		!atomic_read(&mdsc->quarantine_splices);
> +}

[ ... ]

> @@ -1407,7 +1873,7 @@ int ceph_fill_inode(struct inode *inode, struct fol=
io *locked_folio,
>  	/* were we issued a capability? */
>  	if (info_caps) {
>  		if (!ceph_in_snap(inode)) {
> -			ceph_add_cap(inode, session,
> +			bool cap_current =3D ceph_add_cap(inode, session,
>  				     le64_to_cpu(info->cap.cap_id),
>  				     info_caps,
>  				     le32_to_cpu(info->cap.wanted),
> @@ -1416,6 +1882,14 @@ int ceph_fill_inode(struct inode *inode, struct fo=
lio *locked_folio,
>  				     le64_to_cpu(info->cap.realm),
>  				     info->cap.flags, &new_cap);
> =20
> +			/*
> +			 * Caps above PIN mean quarantine has been lifted,
> +			 * including when the disable message was lost.
> +			 */
> +			if (cap_current && (info_caps & ~CEPH_CAP_PIN) &&
> +			    ceph_quarantine_reply_can_clear(ci, session))
> +				ceph_quarantine_clear(ci);

[Severity: High]
Can ceph_quarantine_reply_can_clear() fail to clear quarantine on target
inodes and readdir entries when the reply comes from a rank different from
ci->i_qtine_mds because reply processing itself increments
mdsc->quarantine_epoch?

req->r_quarantine_epoch is sampled once in ceph_mdsc_create_request() and
never updated:

  req->r_quarantine_epoch =3D atomic64_read_acquire(&mdsc->quarantine_epoch=
);

During reply handling, ceph_fill_trace() processes parent_dir before
req->r_target_inode:

  ceph_fill_trace()
    if (parent_dir)
      ceph_fill_inode(parent_dir, ...)
        ceph_quarantine_clear(ci) -> advances mdsc->quarantine_epoch by 2
    ...
    if (rinfo->head->is_target)
      ceph_fill_inode(in, ...)
        ceph_quarantine_reply_can_clear(ci, session)

If both parent_dir and req->r_target_inode had CEPH_I_QUARANTINE_BIT set on
another rank, clearing parent_dir increments mdsc->quarantine_epoch by 2.
When ceph_fill_inode() then runs for req->r_target_inode,
req->r_quarantine_epoch =3D=3D epoch is false, leaving the target inode's
quarantine mark set.

The same self-invalidation happens in handle_reply() ->
ceph_readdir_prepopulate(), where each entry in the loop calls
ceph_fill_inode() and splice_dentry() (which calls
ceph_quarantine_splice_start() and ceph_quarantine_splice_finish(),
advancing mdsc->quarantine_epoch by 4), preventing
ceph_quarantine_reply_can_clear() from succeeding on subsequent entries in
the same readdir reply.

In addition, any unrelated dentry splice or cross-directory rename on the
superblock while the MDS request is in flight (or sampling an odd
mdsc->quarantine_epoch in ceph_mdsc_create_request()) will cause
req->r_quarantine_epoch =3D=3D epoch to fail even when no new quarantine ma=
rk was
set.

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/cover.20261025T1826=
49Z.ca9ae7a18449.git.amarkuze@redhat.com?part=3D4
