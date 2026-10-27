Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.44
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793105210;
	b=LI53gCnR+EGAUI+MKGX84URnBON3Y6pV+lWEWMLrPVkhuEpbYTtsQGR+9vvgpptvld75
	 4qWz43q1jv0xzNZAUOCLRg4lnvQ1fXQkQmArtT9lyIKqBJrmGwQjlaRk0AxklerKY2oBo
	 FpSCWS0Gugba66ptAfID7OoZ5zvJehkdLUDGqMJcvAI5j1uV1BvcH8/yEZdxE1gYk6fJT
	 kyMoqHK9dkTA0tqlbuSHvbU8eUTGs8Vs5U0YRRTfyhkYQhk9utfPHDwQuvAsbOIuIo8Jb
	 ZVSoe6Q5c94+PBV7CD77I/tjSvZjfU5/pFB9qJZcC7AoqnoL0mCFk3Fh/x3sXSWtpCA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793105210;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=tM9z4Y/40xyWfahMedWVRhKTHJQqTvitq9arJ2Ee7fw=;
	b=QRxr0/c+10XYW/c79Yam7GHCQpEb3/bNpRIoe4y791OHqggf8HqT1YSEIrNFKzQq6+9P
	 h6o1o0xdryqt5PIB3AUw8Gmv1LV0lD1lYb21vBEatpEcgaDSTV/vh8X4XobQwzEQdxpJ5
	 kmYrwzDtCE1Gojz3m7Kqj/EBc7xE+oGKI241QmWmtx6kqvIdkXASX9mx9FVHyiu1jvb0i
	 Qf5bxDItK208PLB1HtAaj8vd9ibX5OVpe82xNzj8S6GPMz6dBR0osfdaJvZ9J5o0GU3tI
	 E75IWQ72erQKLCaXpEDOjygdMyQ90IicDKjAw8qq3pptuHu7rwSC12H3mg1MaZ352eQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=clyso.com;
	spf=pass smtp.mailfrom=clyso.com;
	dkim=pass header.d=clyso.com header.i=@clyso.com header.a=rsa-sha256 header.s=google header.b="kVg5w/kp";
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.44
Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 42346606A31B
	for <linux-fscrypt@vger.kernel.org>; Tue, 27 Oct 2026 12:46:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 42346606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=clyso.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=clyso.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=clyso.com header.i=@clyso.com header.a=rsa-sha256 header.s=google header.b=kVg5w/kp
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-6b1b13e09ffso5655151a12.3
        for <linux-fscrypt@vger.kernel.org>; Tue, 27 Oct 2026 05:46:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1793105208; cv=none;
        d=google.com; s=arc-20260327;
        b=O5aIF0L8bBgby+cpmBJHk9lStizyPCHo32C8nrjHDckPz7qhOlWM9eu86rZZXjAdGh
         uj1OiyQ2/i5VzMcI7ivDUBfxzYaYPkFyRqPQsBoxGCxqml8nQ/KdAoRnA8AKcfglqIDq
         RI7zy/DBh+LZ3XyUPLs4hPcapNY867Ah34cbw4etVMSVud4PNWo/Hv6zM/7fseYXvX2A
         1ZgAbaHD55NE+kE+3dtIZ5vrjaom/xVnqGbjPvvpEDIGfQvc4len6YckyrLAvsGbPzYc
         khZxBelpzBWkGFNhPLjTlotrq35bP3mIfkx2r1NGQiFCCbidssYcfmolJ3GWiUBK/XlC
         rxdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=tM9z4Y/40xyWfahMedWVRhKTHJQqTvitq9arJ2Ee7fw=;
        fh=eeXIDSgfLp+pQ2COEaM9sHRwv9Ff0srly4Pv7NB4Zrg=;
        b=g7cR1Mw3bfiLFC7X97puplZF7bm0VQeTgRXGK2oEDAQ7YVZgmJJkqerQOlbJlsIrEN
         PSrGweM6kjM2SotNCOau+P9LHKo7cTiR/6heX1xa2K0hUNWFoiZadtDiE+ahlzSPOP9r
         aUGJT2UjmreX8fm7KwrVAbQmBwwW38n0L78eW70KxPRAvdHnw8hBl1gtYwUazwK7EVTR
         TXBTFPBRNwj09ZzWh/r/ZSDzILVJuULmMOxDQ5RqaynAM9gIGTooTvbZczeFVYEC9ns9
         XZr2hBkR0dXdJs1bCxfAHGqmMG3hJBvribbK8qr/sphQt73wRnanFxeDCzWO3d7pGTwk
         O+sg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=clyso.com; s=google; t=1793105208; x=1793710008; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=tM9z4Y/40xyWfahMedWVRhKTHJQqTvitq9arJ2Ee7fw=;
        b=kVg5w/kp2jGxrl6CpkV9K3ZgAeMf4RSKfVYBiFxqoBCzzvh6F/b+oENnNnapRbKK4q
         +ZNo+940q5f1BPSA/vcpzFOhFC/QO6A5KXF3rQ5vW4c/9OGQHcxVYXmSMaIBcvLFNmYF
         UxJySwCRXMen2lXfJkswFYpjkjysn+dIzOkcX1IEzUYo/BTEqyNOYuuOlXf0Fj8npQYv
         f1hQuJneZIccHeuPQs8cb2pTIp+3VcaKDBLgfGozaVTsOVhUJVIECQm4/rR1xs5RUrPR
         F+9pQE5RuUBOPr3ysp8BuSc5CVdcbpGnOpgdGQfl/Iipg3bpkOTPNq2dTBAnjHRPUKFx
         2HoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793105208; x=1793710008;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=tM9z4Y/40xyWfahMedWVRhKTHJQqTvitq9arJ2Ee7fw=;
        b=ah0wJIyqbtkCVGghAeKsCkDldE6F1Pe6FCl1g4dcf9plu//0veIVFMHUrt+e8ox1sC
         Xxce/Z4UFjN11jxnPmbtyXb8jy6cAy9USg1GRyJ0k5TFsQFl4awex7g6A8tbXiFv+wxF
         RC8/6o80inhsXwymM1Ts44o5akZ06I3Up5WT8pEC6VQC3glwWnccGqyBm8eT0YSZyEgt
         2QsjgUUH1zGGOQQUhTtk0YMpyY7nkeiqJ2nd1Sk4+BeN5WbcC1gNeXOWhEQuH9aqr3oX
         Ew0PfEEyajGHrR7lHwSt9TsjKRSvULIHK9zXuz6cOMsIdleIg2DreGCmTcQk1TN8Nzsv
         TyTw==
X-Forwarded-Encrypted: i=1; AKwUvBzAox6ib04nDt4h7m8qfYp5HFxEZQgK7lzp9q7MV0KA6V+bIMaWI4WUewvj8Yy2YVbap/TnUBkjfJ+7ZESw@vger.kernel.org
X-Gm-Message-State: AFq9FYI8IzAm4hahRz3Z2cQelzpojvSmBGvgJiN1mqtVDE2HdqnAnDsL
	2sw1SaF24vsZQzotWIqUQCAcwuRNSclW2DhXpjTQPt+XnVHt0W5LW4S5H7ZwzJoLAD9BX1fsTuR
	5zMvrlHv6WgA77eN7pM+mKZZd9stIm0b7F3/PncwLXg==
X-Gm-Gg: AYBFou2dqM7FI+B5gSxPZVnHxOx69nPhqmbOcwPDOyT9Cxd95vVp0Mo++AzCK0+q0yk
	aNjPz3MKWxiqZpaDhY6AQrjXpxQZOs9wUZsYD3n2weYDtKp7Au3fHLe3zq/l+eHAPdFmFFdiGYY
	9X5oDyr+BQzrubDxOI3MQ3iuMzhHjbVC1hW0gE77Nq7QPBE3UeEIMa4xQOjO67nehb89ITDPNgE
	10Zo3F5FKHmqYWIvUDi9PsVeDX3C8JXk8quxka6bXjH+a/Wjr+ANRSNv3yvp21QTaRSZvD009Ov
	dsuVRnpjzU5PJ2tBt+50kLfRhXLK00Tobw3/PMounEUGReVom1LvYydGq55BpOIFPkm1TggI2ud
	4J6Saxw/f4K+R2e7c6aEjmLsyWmPMOBI4HbNLolGSltZ67jXgN2h7Hy3BZTAw
X-Received: by 2002:a17:907:86a5:b0:c29:f5d5:5a9c with SMTP id
 a640c23a62f3a-c46bde938ebmr1066468966b.38.1793105208250; Tue, 27 Oct 2026
 05:46:48 -0700 (PDT)
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <cover.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
 <1b6167c472fe05e2cd650bde2ffc9421892ad4cc.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
 <sashiko-outbox-184356@kernel.org>
In-Reply-To: <sashiko-outbox-184356@kernel.org>
From: Xiubo Li <xiubo.li@clyso.com>
Date: Tue, 27 Oct 2026 13:45:27 +0100
X-Gm-Features: AclHuK-sYpg2h3MTlNgp-i_UZSC8bHA1yVOe6oLZ66x7r66CL4rBT9LPbMbxzKQ
Message-ID: <CAOJNxR+6M7MLXOD5o-sd6uXMqp1AFwZJj2oNvVv7GW4Axoeb=g@mail.gmail.com>
Subject: Re: [PATCH v6 4/5] ceph: record subvolume quarantine from MDS cap updates
To: sashiko-reviews@lists.linux.dev
Cc: Alex Markuze <amarkuze@redhat.com>, idryomov@gmail.com, slava@dubeyko.com, 
	viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz, 
	linux-fscrypt@vger.kernel.org, ebiggers@kernel.org, tytso@mit.edu, 
	jaegeuk@kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Alex,

> +void ceph_handle_quarantine_disable(struct ceph_mds_client *mdsc,
> +     struct ceph_mds_session *session,
> +     struct ceph_msg *msg)
> +{
[...]
> + if (msg->front.iov_len < sizeof(*h)) {
[...]
> + vino.ino =3D le64_to_cpu(h->ino);
> + vino.snap =3D CEPH_NOSNAP;
> + inode =3D ceph_find_inode(sb, vino);

The message is never validated beyond its length:

  - h->oserrno is ignored;
  - msg->hdr.version is never checked, and MQuarantineDisable is
    versioned (HEAD_VERSION 1).

A future v2 with a different layout, or a disable that carries an
error, would clear the mark all the same.  Please reject unknown
versions and act only on oserrno =3D=3D 0.

> +static bool ceph_quarantine_reply_can_clear(struct ceph_inode_info *ci,
> +     struct ceph_mds_session *session)
> +{
[...]
> + req =3D ceph_current_mds_request(mdsc->fsc);
> + epoch =3D (u64)atomic64_read_acquire(&mdsc->quarantine_epoch);
> + return req && !(epoch & 1) && req->r_quarantine_epoch =3D=3D epoch &&
> + !atomic_read(&mdsc->quarantine_splices);

r_quarantine_epoch is compared against the mount-wide epoch, which every
splice on the mount moves.  In ceph_readdir_prepopulate(), splice_dentry()
for entry N runs before ceph_fill_inode() for entry N+1, so a readdir
reply invalidates itself after its first entry.  From then on the reply
can never clear a mark from another rank.  This is sashiko's point; I
agree with it.

Comparing against a snapshot taken when this reply started filling, or
counting only splices from other tasks, would avoid the self-invalidation.

> + ceph_quarantine_splice_start(parent->i_sb);
[...]
> + ceph_quarantine_move_start(moved, old_dir, new_dir);

5/5 changes both signatures again (struct ceph_quarantine_splice and
the owner list).  Please introduce the final API here, so 5/5 does not
have to rewrite every caller.

Thanks,
Xiubo

On Sun, 25 Oct 2026 at 20:12, <sashiko-bot@kernel.org> wrote:
>
> Thank you for your contribution! Sashiko AI review found 2 potential issu=
e(s) to consider:
> - [High] ceph: epoch self-invalidation in ceph_quarantine_reply_can_clear=
()
> - [High] ceph: __ceph_remove_cap() resets quarantine mark during cap migr=
ation
> --
>
> commit 8a2e69935d967838e52792bb963b124cfe229b88
> Author: Alex Markuze <amarkuze@redhat.com>
>
> ceph: record subvolume quarantine from MDS cap updates
>
> This commit decodes the signed oserrno from MClientCaps v14 messages to
> record a sticky subvolume quarantine mark and reporting MDS rank on each
> inode, along with epoch-based caching and RCU parent walks to resolve
> inherited quarantine state.
>
> > diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
> > index b27bcdc24d29f..b07814d0038cd 100644
> > --- a/fs/ceph/caps.c
> > +++ b/fs/ceph/caps.c
>
> [ ... ]
>
> > @@ -1264,6 +1265,11 @@ static void __ceph_remove_cap(struct ceph_inode_=
info *ci, struct ceph_cap *cap,
> >
> >       mdsc =3D ceph_inode_to_fs_client(&ci->netfs.inode)->mdsc;
> >
> > +     /* Losing the reporting cap requires fresh MDS revalidation. */
> > +     if (READ_ONCE(ci->i_qtine_mds) =3D=3D cap->mds &&
> > +         ceph_quarantine_reset(ci))
> > +             wake_up_all(&ci->i_cap_wq);
> > +
> >       /* remove from inode's cap rbtree, and clear auth cap */
> >       rb_erase(&cap->ci_node, &ci->i_caps);
> >       if (ci->i_auth_cap =3D=3D cap)
> > @@ -3729,6 +3735,9 @@ struct cap_extra_info {
> >       u8 *fscrypt_auth;
> >       u32 fscrypt_auth_len;
> >       u64 fscrypt_file_size;
> > +     /* MClientCaps v14 oserrno; valid only when oserrno_valid is set =
*/
> > +     s32 oserrno;
> > +     bool oserrno_valid;
> >  };
> >
> >  /*
> > @@ -3757,6 +3766,46 @@ static int parse_inline_data(void **p, void *end=
,
> >       return -EIO;
> >  }
> >
> > +/*
> > + * Record quarantine state carried by an MClientCaps oserrno.
> > + * Caller holds i_ceph_lock. Returns true when waiters should be woken
> > + * because quarantine changed or a pending reset was resolved.
> > + *
> > + * -EQUARANTINED refreshes the sticky flag and its reporting MDS rank.
> > + * A current non-IMPORT grant above PIN with errno 0 clears that rank'=
s mark.
> > + * IMPORT may carry a default zero without assessing quarantine permis=
sion.
> > + * Another rank needs a successful metadata request for the current ep=
och.
> > + * A PIN-only update may zero qtine_errno while leaving the flag set.
> > + */
> > +static bool ceph_apply_quarantine(struct ceph_inode_info *ci, int mds,
> > +                               int newcaps, int oserrno, bool is_impor=
t)
> > +{
> > +     bool was, now, pending;
> > +
> > +     was =3D READ_ONCE(ci->i_qtine_errno) =3D=3D -CEPH_EQUARANTINED ||
> > +           test_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags);
> > +     pending =3D test_bit(CEPH_I_QUARANTINE_PENDING_BIT, &ci->i_ceph_f=
lags);
> > +
> > +     if (!is_import && (newcaps & ~CEPH_CAP_PIN) && was && oserrno =3D=
=3D 0 &&
> > +         READ_ONCE(ci->i_qtine_mds) =3D=3D mds)
> > +             ceph_quarantine_clear(ci);
> > +
> > +     if (oserrno =3D=3D -CEPH_EQUARANTINED) {
> > +             ceph_quarantine_set(ci);
> > +             WRITE_ONCE(ci->i_qtine_mds, mds);
> > +     }
>
> [Severity: High]
> When a quarantined inode's capability is migrated between MDS ranks via
> handle_cap_export() or handle_cap_import(), removing the exporting rank's
> cap calls ceph_remove_cap() -> __ceph_remove_cap(), which sees
> ci->i_qtine_mds =3D=3D cap->mds and calls ceph_quarantine_reset(ci).
>
> When handle_cap_grant() then processes the CEPH_CAP_OP_IMPORT message fro=
m
> the new authoritative rank with the default oserrno =3D=3D 0,
> ceph_apply_quarantine() leaves CEPH_I_QUARANTINE_PENDING_BIT set and keep=
s
> ci->i_qtine_mds set to the old exporting rank.
>
> As a result:
> 1. ceph_inode_quarantine_direct() returns false and
>    ceph_quarantine_walk_once() breaks out with CEPH_QWALK_INCOMPLETE inst=
ead
>    of reporting the retained quarantine mark as CEPH_Q_UNDER.
> 2. Subsequent normal CEPH_CAP_OP_GRANT messages (above CEPH_CAP_PIN with
>    oserrno =3D=3D 0) and CEPH_MSG_CLIENT_QUARANTINE_DISABLE messages from=
 the
>    new authoritative rank cannot clear the mark in ceph_apply_quarantine(=
)
>    or ceph_handle_quarantine_disable() because ci->i_qtine_mds still hold=
s
>    the pre-migration rank.
>
> Should capability migration preserve the active mark and transfer
> ci->i_qtine_mds to the importing rank instead of resetting the mark to
> pending when the old rank's cap is removed?
>
> [ ... ]
>
> > diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
> > index 94f5215f8eed5..048e0d502eb4e 100644
> > --- a/fs/ceph/inode.c
> > +++ b/fs/ceph/inode.c
>
> [ ... ]
>
> > +static bool ceph_quarantine_reply_can_clear(struct ceph_inode_info *ci=
,
> > +                                         struct ceph_mds_session *sess=
ion)
> > +{
> > +     struct ceph_mds_client *mdsc =3D ceph_sb_to_mdsc(ci->netfs.inode.=
i_sb);
> > +     struct ceph_mds_request *req;
> > +     u64 epoch;
> > +
> > +     if (READ_ONCE(ci->i_qtine_mds) =3D=3D session->s_mds)
> > +             return true;
> > +     /* Different ranks have independent cap sequences. */
> > +     req =3D ceph_current_mds_request(mdsc->fsc);
> > +     epoch =3D (u64)atomic64_read_acquire(&mdsc->quarantine_epoch);
> > +     return req && !(epoch & 1) && req->r_quarantine_epoch =3D=3D epoc=
h &&
> > +             !atomic_read(&mdsc->quarantine_splices);
> > +}
>
> [ ... ]
>
> > @@ -1407,7 +1873,7 @@ int ceph_fill_inode(struct inode *inode, struct f=
olio *locked_folio,
> >       /* were we issued a capability? */
> >       if (info_caps) {
> >               if (!ceph_in_snap(inode)) {
> > -                     ceph_add_cap(inode, session,
> > +                     bool cap_current =3D ceph_add_cap(inode, session,
> >                                    le64_to_cpu(info->cap.cap_id),
> >                                    info_caps,
> >                                    le32_to_cpu(info->cap.wanted),
> > @@ -1416,6 +1882,14 @@ int ceph_fill_inode(struct inode *inode, struct =
folio *locked_folio,
> >                                    le64_to_cpu(info->cap.realm),
> >                                    info->cap.flags, &new_cap);
> >
> > +                     /*
> > +                      * Caps above PIN mean quarantine has been lifted=
,
> > +                      * including when the disable message was lost.
> > +                      */
> > +                     if (cap_current && (info_caps & ~CEPH_CAP_PIN) &&
> > +                         ceph_quarantine_reply_can_clear(ci, session))
> > +                             ceph_quarantine_clear(ci);
>
> [Severity: High]
> Can ceph_quarantine_reply_can_clear() fail to clear quarantine on target
> inodes and readdir entries when the reply comes from a rank different fro=
m
> ci->i_qtine_mds because reply processing itself increments
> mdsc->quarantine_epoch?
>
> req->r_quarantine_epoch is sampled once in ceph_mdsc_create_request() and
> never updated:
>
>   req->r_quarantine_epoch =3D atomic64_read_acquire(&mdsc->quarantine_epo=
ch);
>
> During reply handling, ceph_fill_trace() processes parent_dir before
> req->r_target_inode:
>
>   ceph_fill_trace()
>     if (parent_dir)
>       ceph_fill_inode(parent_dir, ...)
>         ceph_quarantine_clear(ci) -> advances mdsc->quarantine_epoch by 2
>     ...
>     if (rinfo->head->is_target)
>       ceph_fill_inode(in, ...)
>         ceph_quarantine_reply_can_clear(ci, session)
>
> If both parent_dir and req->r_target_inode had CEPH_I_QUARANTINE_BIT set =
on
> another rank, clearing parent_dir increments mdsc->quarantine_epoch by 2.
> When ceph_fill_inode() then runs for req->r_target_inode,
> req->r_quarantine_epoch =3D=3D epoch is false, leaving the target inode's
> quarantine mark set.
>
> The same self-invalidation happens in handle_reply() ->
> ceph_readdir_prepopulate(), where each entry in the loop calls
> ceph_fill_inode() and splice_dentry() (which calls
> ceph_quarantine_splice_start() and ceph_quarantine_splice_finish(),
> advancing mdsc->quarantine_epoch by 4), preventing
> ceph_quarantine_reply_can_clear() from succeeding on subsequent entries i=
n
> the same readdir reply.
>
> In addition, any unrelated dentry splice or cross-directory rename on the
> superblock while the MDS request is in flight (or sampling an odd
> mdsc->quarantine_epoch in ceph_mdsc_create_request()) will cause
> req->r_quarantine_epoch =3D=3D epoch to fail even when no new quarantine =
mark was
> set.
>
> --
> Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/cover.20261025T18=
2649Z.ca9ae7a18449.git.amarkuze@redhat.com?part=3D4
