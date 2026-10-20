Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792537232;
	b=sjrCymfUFmQDjCpLYWD8isvP4km2nhBWM9HladfXBxbaswlvrVl4YL0DZcwKtO1aB8hw
	 26/UlEl8RkI7GVcaJavQL8/MI/X8zv8cq48KcCMVwbRe+qbW2CBv2jnTVFyjNVe5O2FlO
	 aJ4zRGH0c3Er4ArDw+jCb9kM16WF07jhcpcgwpt2FR1A8cp04FAdHx6ysOFBymcW+priV
	 CBOsoqKEjGQZgcHndZ/+QxBUep6tzHh/qKXsaAHA3EZzj2BwtSsuTJ3ejAFUPnDygk0s5
	 aL2F6ZpCT+NpapRhV5txrkSI10wvOGeZMSeI+JMDVUEMgWKhmvt0QofmrA9IddK6q/Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792537232;
	h=Received:DKIM-Signature:Message-ID:From:Subject:Reply-To:To:Cc:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:Date;
	bh=5JuZeb7HV+Kn7Nku0j63hqJCnsvdnE8a5jCTwTsRoIQ=;
	b=iVmjdGtl6LL+OIlrPOROaFQxOb2lmaPbhwbt3umEb424T2Yb6CDreGqmdwJSfo5hmNh1
	 Avt4pHDSD390Pgbe/rgC5enIhZbXen8dX1tagIjbRFeV7/3cUB7Mzda8B7qnGiEyYR47h
	 mhwgwqh+Ze2gKn//iBB9Ua6lTtpvbcJhGBAYTKSsafDGFCou3oVb3ATAy4/TSImaJznNN
	 7qMr2IzBB5PFOy5t5dsdNwh+Uj12QWBcwGOmgb8TAvXd68gi+mxHA6NL/ZfN+s2WshUmL
	 vEBu20y2+B/sy3eWfOcYUb+FQNLxNU/jEUNJZ4aZte9UZ7cWF5LIZFFK8sqFUEa5oAQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z2xoQ0WM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8D4E606A31A
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 23:00:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z2xoQ0WM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EFFB91F000CE;
	Tue, 20 Oct 2026 23:00:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792537231;
	bh=5JuZeb7HV+Kn7Nku0j63hqJCnsvdnE8a5jCTwTsRoIQ=;
	h=From:Subject:Reply-To:To:Cc:In-Reply-To:References:Date;
	b=Z2xoQ0WMmWIrEuzmCI4LYIy1AWuer/X2Lz8qfKPrkQSK52s5v/4loYChKhOccRDVc
	 nbFSitc9z/ePalQTdLmvvXRkHwkus3ythj0OIOGqA8VDRi9S0Q0jkcoXSizsUbcWpe
	 0gFkFrcq44qlIb3Hg3p3CbzE80xzvQg3Uvf+ekE13TnE9u4pZ30PEbdmd+SHRO9z1+
	 blaGXSz+FJi3OrX1JMIi1n9Zbh7TtN/deD7sJUXqLNKpeGmj5NMcdOUP4ueLg7gwnc
	 TlMJr+FBjb2u4uWbLc7cn4JI/a5PrKPx7AlKqFqzAtfoT8kyBiB3noIfE55hnhsKFE
	 94+QnMupbGYxg==
Message-ID: <sashiko-outbox-179589@kernel.org>
From: sashiko-bot@kernel.org
Subject: Re: [PATCH v5 4/5] ceph: record subvolume quarantine from MDS cap
 updates
Reply-To: sashiko-reviews@lists.linux.dev
To: "Alex Markuze" <amarkuze@redhat.com>
Cc: idryomov@gmail.com, xiubo.li@clyso.com, slava@dubeyko.com, viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz, linux-fscrypt@vger.kernel.org, ebiggers@kernel.org, tytso@mit.edu, jaegeuk@kernel.org
In-Reply-To: <ff90b10c248b7f46707d0448b5c05cffe85a2ce8.1792527529.git.amarkuze@redhat.com>
References: <cover.1792527529.git.amarkuze@redhat.com>
 <ff90b10c248b7f46707d0448b5c05cffe85a2ce8.1792527529.git.amarkuze@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Date: Tue, 20 Oct 2026 23:00:30 +0000
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
- [High] ceph: epoch self-invalidation in ceph_quarantine_reply_can_clear()
- [High] ceph: unhashed directory alias traversal in ceph_quarantine_walk_o=
nce()
- [High] ceph: pre-import cap sequence off-by-one in handle_cap_grant()
- [Medium] ceph: unconditional quarantine reset on non-reporting MDS sessio=
ns
--

commit 78e79694b7e226fb4224da6b24cf5abda7482a66
Author: Alex Markuze <amarkuze@redhat.com>

ceph: record subvolume quarantine from MDS cap updates

This commit decodes the MClientCaps v14 quarantine errno to maintain a
sticky, counted quarantine mark on inodes, and adds an epoch-based rcu
ancestry walk cache to track whether an inode is under a quarantined
subvolume.

> diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
> index b27bcdc24d29f..94f015112942d 100644
> --- a/fs/ceph/caps.c
> +++ b/fs/ceph/caps.c
> @@ -692,8 +692,9 @@ void change_auth_cap_ses(struct ceph_inode_info *ci,
>   * @fmode is the open file mode, if we are opening a file, otherwise
>   * it is < 0.  (This is so we can atomically add the cap and add an
>   * open file reference to it.)
> + * Returns false when the raw grant predates the recorded cap sequence.
>   */
> -void ceph_add_cap(struct inode *inode,
> +bool ceph_add_cap(struct inode *inode,
>  		  struct ceph_mds_session *session, u64 cap_id,
>  		  unsigned issued, unsigned wanted,
>  		  unsigned seq, unsigned mseq, u64 realmino, int flags,
> @@ -706,6 +707,7 @@ void ceph_add_cap(struct inode *inode,
>  	int mds =3D session->s_mds;
>  	int actual_wanted;
>  	u32 gen;
> +	bool cap_current =3D true;
> =20
>  	lockdep_assert_held(&ci->i_ceph_lock);
> =20
> @@ -737,6 +739,7 @@ void ceph_add_cap(struct inode *inode,
>  		atomic64_inc(&mdsc->metric.total_caps);
>  		spin_unlock(&session->s_cap_lock);
>  	} else {
> +		cap_current =3D ceph_seq_cmp(seq, cap->seq) >=3D 0;
>  		spin_lock(&session->s_cap_lock);
>  		list_move_tail(&cap->session_caps, &session->s_caps);
>  		spin_unlock(&session->s_cap_lock);
> @@ -823,6 +826,7 @@ void ceph_add_cap(struct inode *inode,
>  	cap->mseq =3D mseq;
>  	cap->cap_gen =3D gen;
>  	wake_up_all(&ci->i_cap_wq);
> +	return cap_current;
>  }

[ ... ]

> @@ -3757,6 +3769,45 @@ static int parse_inline_data(void **p, void *end,
>  	return -EIO;
>  }
> =20
> +/*
> + * Record quarantine state carried by an MClientCaps oserrno.
> + * Caller holds i_ceph_lock. Returns true when waiters should be woken
> + * because quarantine changed or a pending reset was resolved.
> + *
> + * -EQUARANTINED refreshes the sticky flag and its reporting MDS rank.
> + * A current grant above PIN with errno 0 clears only that rank's mark.
> + * Another rank needs a successful metadata request for the current epoc=
h.
> + * A PIN-only update may zero qtine_errno while leaving the flag set.
> + */
> +static bool ceph_apply_quarantine(struct ceph_inode_info *ci, int mds,
> +				  int newcaps, int oserrno)
> +{
> +	bool was, now, pending;
> +
> +	was =3D READ_ONCE(ci->i_qtine_errno) =3D=3D -CEPH_EQUARANTINED ||
> +	      test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags);
> +	pending =3D test_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags);
> +
> +	if ((newcaps & ~CEPH_CAP_PIN) && was && oserrno =3D=3D 0 &&
> +	    READ_ONCE(ci->i_qtine_mds) =3D=3D mds)
> +		ceph_quarantine_clear(ci);
> +
> +	if (oserrno =3D=3D -CEPH_EQUARANTINED) {
> +		ceph_quarantine_set(ci);
> +		WRITE_ONCE(ci->i_qtine_mds, mds);
> +	}
> +
> +	if (newcaps || was ||
> +	    test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags))
> +		WRITE_ONCE(ci->i_qtine_errno, oserrno);
> +
> +	now =3D READ_ONCE(ci->i_qtine_errno) =3D=3D -CEPH_EQUARANTINED ||
> +	      test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags);
> +	return was !=3D now ||
> +	       pending !=3D test_bit(CEPH_I_QUARANTINE_PENDING_BIT,
> +				   &ci->i_ceph_flags);
> +}
> +
>  /*
>   * Handle a cap GRANT message from the MDS.  (Note that a GRANT may
>   * actually be a revocation if it specifies a smaller cap set.)
> @@ -3781,6 +3832,7 @@ static void handle_cap_grant(struct inode *inode,
>  	u64 max_size =3D le64_to_cpu(grant->max_size);
>  	unsigned char check_caps =3D 0;
>  	bool was_stale =3D cap->cap_gen < atomic_read(&session->s_cap_gen);
> +	bool quarantine_current =3D ceph_seq_cmp(seq, cap->seq) >=3D 0;
>  	bool wake =3D false;
>  	bool writeback =3D false;
>  	bool queue_trunc =3D false;
> @@ -4128,6 +4180,15 @@ static void handle_cap_grant(struct inode *inode,
>  			fill_inline =3D true;
>  	}
> =20
> +	if (quarantine_current && extra_info->oserrno_valid &&
> +	    ceph_apply_quarantine(ci, session->s_mds, newcaps,
> +				  extra_info->oserrno)) {
> +		boutc(cl, "quarantine oserrno %d caps %s %llx.%llx\n",
> +		      extra_info->oserrno, ceph_cap_string(newcaps),
> +		      ceph_vinop(inode));
> +		wake =3D true;
> +	}

[Severity: High]
When an export target mds sends a cap message or reply just before cap
import, can ceph_seq_cmp(seq, cap->seq) >=3D 0 treat a pre-import sequence
number as current?

In fs/ceph/caps.c, when an export message arrives before the corresponding
import message, handle_cap_export() sets the target mds cap sequence to
t_issue_seq - 1 and merges the exported caps into cap->issued:

fs/ceph/caps.c:handle_cap_export() {
	if (tcap->cap_id =3D=3D t_cap_id &&
	    ceph_seq_cmp(tcap->seq, t_issue_seq) < 0) {
		tcap->cap_id =3D t_cap_id;
		tcap->seq =3D t_issue_seq - 1;
		tcap->issue_seq =3D t_issue_seq - 1;
		tcap->issued |=3D issued;
		...
	}
	...
	} else if (tsession) {
		ceph_add_cap(inode, tsession, t_cap_id, issued, 0,
			     t_issue_seq - 1, t_mseq, (u64)-1, flag, &new_cap);
	}
}

Both ceph_add_cap() and handle_cap_grant() treat any message with
ceph_seq_cmp(seq, cap->seq) <=3D 0 (including seq =3D=3D cap->seq, which is
t_issue_seq - 1) as a message sent before the cap import, and merge
cap->issued into issued or newcaps:

fs/ceph/caps.c:handle_cap_grant() {
	if (ceph_seq_cmp(seq, cap->seq) <=3D 0) {
		WARN_ON(cap !=3D ci->i_auth_cap);
		WARN_ON(cap->cap_id !=3D le64_to_cpu(grant->cap_id));
		seq =3D cap->seq;
		newcaps |=3D cap->issued;
	}
}

Because cap_current in ceph_add_cap() and quarantine_current in
handle_cap_grant() use ceph_seq_cmp(seq, cap->seq) >=3D 0, a pre-import
message with seq =3D=3D t_issue_seq - 1 satisfies both <=3D 0 and >=3D 0. In
handle_cap_grant(), newcaps is inflated with cap->issued from the export
placeholder before ceph_apply_quarantine() checks (newcaps & ~CEPH_CAP_PIN),
and in ceph_add_cap(), cap_current returns true to ceph_fill_inode() for a
pre-import reply.

Should pre-import messages with seq =3D=3D cap->seq (when the op is not
CEPH_CAP_OP_IMPORT) be excluded from updating or clearing quarantine state?

[ ... ]

> diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
> index 94f5215f8eed5..78e97cf2f9a41 100644
> --- a/fs/ceph/inode.c
> +++ b/fs/ceph/inode.c

[ ... ]

> +/*
> + * Parent walk with no inode references. Caller holds rcu_read_lock().
> + * Stops at the mount root, at an MDS mark, or at an ancestor whose
> + * cached answer is for this epoch. No hashed alias, or the depth
> + * limit, is not an answer: the caller must not cache it.
> + */
> +static int ceph_quarantine_walk_once(struct inode *inode, u64 epoch,
> +				     bool use_cache)
> +{
> +	struct inode *cur =3D inode;
> +	unsigned int depth =3D 0;
> +	bool under =3D false;
> +	bool done =3D false;
> +
> +	while (cur && depth++ < 256) {
> +		struct ceph_inode_info *ci =3D ceph_inode(cur);
> +		struct dentry *alias;
> +		struct dentry *parent;
> +		struct inode *next;
> +
> +		if (test_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_flags))
> +			break;
> +		if (READ_ONCE(ci->i_qtine_errno) =3D=3D -CEPH_EQUARANTINED ||
> +		    test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags)) {
> +			under =3D true;
> +			done =3D true;
> +			break;
> +		}
> +
> +		if (use_cache && cur !=3D inode &&
> +		    ceph_qtag_read(ci, epoch, &under)) {
> +			done =3D true;
> +			break;
> +		}
> +
> +		alias =3D d_find_alias_rcu(cur);
> +		if (!alias)
> +			break;
> +
> +		parent =3D READ_ONCE(alias->d_parent);
> +		/*
> +		 * The mount root is its own parent. A disconnected
> +		 * alias from d_obtain_alias(), or a secondary root from
> +		 * d_obtain_root(), has the same shape and is not a
> +		 * finished walk.
> +		 */
> +		if (!parent || parent =3D=3D alias) {
> +			if (parent =3D=3D alias && S_ISDIR(cur->i_mode) &&
> +			    alias =3D=3D READ_ONCE(inode->i_sb->s_root))
> +				done =3D true;
> +			break;
> +		}
> +
> +		next =3D d_inode_rcu(parent);

[Severity: High]
If a directory dentry is unhashed while still referenced, could
ceph_quarantine_walk_once() follow a stale d_parent chain to s_root and
cache a clear result in i_qtag?

Looking at d_find_alias_rcu() in fs/dcache.c, it only checks !d_unhashed()
for non-directory inodes, and returns the first alias unconditionally when
S_ISDIR(inode->i_mode) is true:

fs/dcache.c:d_find_alias_rcu() {
	if (likely(!(inode_state_read(inode) & I_FREEING) && !hlist_empty(l))) {
		if (S_ISDIR(inode->i_mode)) {
			de =3D hlist_entry(l->first, struct dentry, d_alias);
		} else {
			hlist_for_each_entry(de, l, d_alias)
				if (!d_unhashed(de))
					break;
		}
	}
	return de;
}

If a directory dentry is unhashed via d_drop(), d_delete(), or
d_invalidate() (for example, after a remote rename into a quarantined
subvolume) while held open or referenced by a child dentry, alias remains on
cur->i_dentry with d_unhashed(alias) true and alias->d_parent still pointing
to the old parent directory.

Since ceph_quarantine_walk_once() does not check d_unhashed(alias) when
parent !=3D alias, wouldn't the walk continue up the old parent chain to
s_root and publish a clear tag in ci->i_qtag?

[ ... ]

> +void ceph_quarantine_splice_start(struct super_block *sb)
> +{
> +	struct ceph_mds_client *mdsc =3D ceph_sb_to_mdsc(sb);
> +
> +	spin_lock(&mdsc->quarantine_lock);
> +	atomic_inc_return(&mdsc->quarantine_splices);
> +	atomic64_add_return(2, &mdsc->quarantine_epoch);
> +	spin_unlock(&mdsc->quarantine_lock);
> +}
> +
> +void ceph_quarantine_splice_finish(struct super_block *sb)
> +{
> +	struct ceph_mds_client *mdsc =3D ceph_sb_to_mdsc(sb);
> +
> +	spin_lock(&mdsc->quarantine_lock);
> +	atomic64_add_return(2, &mdsc->quarantine_epoch);
> +	atomic_dec_return(&mdsc->quarantine_splices);
> +	spin_unlock(&mdsc->quarantine_lock);
> +}
> +
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

> @@ -1407,7 +1866,7 @@ int ceph_fill_inode(struct inode *inode, struct fol=
io *locked_folio,
>  	/* were we issued a capability? */
>  	if (info_caps) {
>  		if (!ceph_in_snap(inode)) {
> -			ceph_add_cap(inode, session,
> +			bool cap_current =3D ceph_add_cap(inode, session,
>  				     le64_to_cpu(info->cap.cap_id),
>  				     info_caps,
>  				     le32_to_cpu(info->cap.wanted),
> @@ -1416,6 +1875,14 @@ int ceph_fill_inode(struct inode *inode, struct fo=
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
How can ceph_quarantine_reply_can_clear() succeed for req->r_target_inode or
later readdir entries when earlier steps in the same reply advance
mdsc->quarantine_epoch?

req->r_quarantine_epoch is sampled once in ceph_mdsc_create_request(), and
ceph_quarantine_reply_can_clear() requires req->r_quarantine_epoch =3D=3D e=
poch
when session->s_mds !=3D ci->i_qtine_mds. However, mdsc->quarantine_epoch is
also incremented by ceph_quarantine_clear(), ceph_quarantine_reset(), and
ceph_quarantine_splice_start()/finish():

1. In ceph_fill_trace(), ceph_fill_inode() is called on parent_dir before it
is called on req->r_target_inode:

fs/ceph/inode.c:ceph_fill_trace() {
	if (parent_dir) {
		ceph_inode_set_subvolume(parent_dir,
					 rinfo->diri.subvolume_id);
		err =3D ceph_fill_inode(parent_dir, NULL, &rinfo->diri,
				      rinfo->dirfrag, session, -1,
				      &req->r_caps_reservation);
		...
	}
	...
	if (rinfo->head->is_target) {
		in =3D req->r_target_inode;
		ceph_inode_set_subvolume(in, rinfo->targeti.subvolume_id);
		err =3D ceph_fill_inode(in, req->r_locked_folio, &rinfo->targeti,
				...);
	}
}

If filling parent_dir clears a quarantine mark on parent_dir,
ceph_quarantine_clear() advances mdsc->quarantine_epoch by 2, so
req->r_quarantine_epoch =3D=3D epoch becomes false before ceph_fill_inode()=
 runs
on req->r_target_inode.

2. In ceph_readdir_prepopulate(), each entry calls ceph_fill_inode() and,
for negative dentries, splice_dentry(), which calls
ceph_quarantine_splice_start() and ceph_quarantine_splice_finish(). On the
first entry that splices a dentry or clears a quarantine mark,
mdsc->quarantine_epoch advances, preventing ceph_quarantine_reply_can_clear=
()
from clearing quarantine on any subsequent entry in the readdir reply.

3. If a request is created before the old reporting session's cap is removed
or reset via __ceph_remove_cap(), remove_session_caps_cb(), or
reconnect_caps_cb(), ceph_quarantine_reset() advances mdsc->quarantine_epoch
after req->r_quarantine_epoch was recorded, so the reply cannot clear the
pending mark on another rank.

[ ... ]

> diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
> index d4ef8a355a480..bb7cf9384fd6d 100644
> --- a/fs/ceph/mds_client.c
> +++ b/fs/ceph/mds_client.c
> @@ -2041,10 +2041,12 @@ static int remove_session_caps_cb(struct inode *i=
node, int mds, void *arg)
>  	struct ceph_inode_info *ci =3D ceph_inode(inode);
>  	struct ceph_client *cl =3D ceph_inode_to_client(inode);
>  	bool invalidate =3D false;
> +	bool reset;
>  	struct ceph_cap *cap;
>  	int iputs =3D 0;
> =20
>  	spin_lock(&ci->i_ceph_lock);
> +	reset =3D ceph_quarantine_reset(ci);
>  	cap =3D __get_cap_for_mds(ci, mds);
>  	if (cap) {
>  		boutc(cl, " removing cap %p, ci is %p, inode is %p\n",
> @@ -2054,7 +2056,7 @@ static int remove_session_caps_cb(struct inode *ino=
de, int mds, void *arg)
>  	}
>  	spin_unlock(&ci->i_ceph_lock);
> =20
> -	if (cap)
> +	if (cap || reset)
>  		wake_up_all(&ci->i_cap_wq);
>  	if (invalidate)
>  		ceph_queue_invalidate(inode);
> @@ -2860,6 +2862,7 @@ ceph_mdsc_create_request(struct ceph_mds_client *md=
sc, int op, int mode)
> =20
>  	mutex_init(&req->r_fill_mutex);
>  	req->r_mdsc =3D mdsc;
> +	req->r_quarantine_epoch =3D atomic64_read_acquire(&mdsc->quarantine_epo=
ch);
>  	req->r_started =3D jiffies;
>  	req->r_start_latency =3D ktime_get();
>  	req->r_resend_mds =3D -1;
> @@ -5009,6 +5012,7 @@ static int reconnect_caps_cb(struct inode *inode, i=
nt mds, void *arg)
>  	struct ceph_path_info path_info =3D {0};
>  	int err;
>  	u64 snap_follows;
> +	bool reset =3D false;
> =20
>  	dentry =3D d_find_primary(inode);
>  	if (dentry) {
> @@ -5023,9 +5027,16 @@ static int reconnect_caps_cb(struct inode *inode, =
int mds, void *arg)
>  	}
> =20
>  	spin_lock(&ci->i_ceph_lock);
> +	/*
> +	 * Require a fresh MDS answer after reconnect. A PIN import may
> +	 * carry no quarantine errno, so it must not reopen cached snap caps.
> +	 */
> +	reset =3D ceph_quarantine_reset(ci);
>  	cap =3D __get_cap_for_mds(ci, mds);
>  	if (!cap) {
>  		spin_unlock(&ci->i_ceph_lock);
> +		if (reset)
> +			wake_up_all(&ci->i_cap_wq);
>  		err =3D 0;
>  		goto out_err;
>  	}

[Severity: Medium]
Should remove_session_caps_cb() and reconnect_caps_cb() check whether
READ_ONCE(ci->i_qtine_mds) =3D=3D mds before calling ceph_quarantine_reset(=
ci)?

In __ceph_remove_cap(), ceph_quarantine_reset(ci) is gated on
READ_ONCE(ci->i_qtine_mds) =3D=3D cap->mds so that only losing the reporting
rank's cap transitions the mark to pending. However,
remove_session_caps_cb() and reconnect_caps_cb() call
ceph_quarantine_reset(ci) unconditionally for every inode visited during a
session close or reconnect, even when the quarantine mark was reported by a
different mds rank whose session is still active.

[ ... ]

--=20
Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/cover.1792527529.gi=
t.amarkuze@redhat.com?part=3D4
