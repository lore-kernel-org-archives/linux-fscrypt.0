Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.48
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793105224;
	b=K369Yz+j+zl1hNkhUGOOa1PeGKcJfKrqYwSjlNa6B82tPKRVjm6kUAfooY1T83DsncqO
	 dnOqa0subOz/uGOY5w1a4CJnrwhIVxC0V2hWLneOAOyfTUqWsKeWdQPTIHDJdKhXuG/oO
	 fJP9SE0rB2Z4L02qoNw7WLzq6j4LuhwKN0QnnkR+lW+nX5HepwT94kW1MZEyso1ovpYTo
	 iyfZnSjYM0eGGw8WTQUhdh7IS42rWiaDNnKZ2HYo/v5f0RQuEbNCDPLNMZHKgXmsWwrB8
	 wZMpRagtEmfwxl2ExzU6Qmyv0SUY8HJ9IHuKzpwtcwEcxuRliQyyikPhW+IRgQJMP6Q==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793105224;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=JZK1GHO+GSsb4xbufFZ7uhZY6/WpkMbk1T52bDV5hr4=;
	b=h/nUT0SRFVeI26+BfvvVMaIv1fx1ypnBidcBLW7rum7K6GoCd3ZoyPzOTL43SxE4EWTb
	 01KVFjs86c0n9tBm27KG39DPSOYvwQAT8gRnZou0+A/n4F39OFY25l894Nit91Ji9KFqr
	 SQ39m/BrnkUN6Sz4FxElZAphpeKuypLfWcjVPaTIPXogx4W4hI4UoaxVW+HCPWOEyU9wZ
	 Amkepy+KOoj2xf3TAWmn6hF7jK7LQui3tETZtg4JQg7abn9xkF6jNr6gEIFDG9kJNMOVx
	 7/+HFKmJCORLPxiuWYt0wMO3KPOT07u2/+XjxWq8UEqOI2EVcpTZLiPCSPn3j29qJxw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=clyso.com;
	spf=pass smtp.mailfrom=clyso.com;
	dkim=pass header.d=clyso.com header.i=@clyso.com header.a=rsa-sha256 header.s=google header.b=OdGNkcMo;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.48
Received: from mail-ed1-f48.google.com (mail-ed1-f48.google.com [209.85.208.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6F2A606A31A
	for <linux-fscrypt@vger.kernel.org>; Tue, 27 Oct 2026 12:47:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D6F2A606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=clyso.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=clyso.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=clyso.com header.i=@clyso.com header.a=rsa-sha256 header.s=google header.b=OdGNkcMo
Received: by mail-ed1-f48.google.com with SMTP id 4fb4d7f45d1cf-6afbc363efeso5903937a12.3
        for <linux-fscrypt@vger.kernel.org>; Tue, 27 Oct 2026 05:47:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1793105221; cv=none;
        d=google.com; s=arc-20260327;
        b=ddGqM/ubAmmZFx8gAeVi/Y8g2I3gW9wEFTGmQCOahxqvWeq1rWC8vk0pZq31U/sYXw
         /9voJ6Z+6QX/HXgSSPIZ8TWJ2RrO1Rm8hvHg41y1/ebi4AohGDfDhMN7xf+7d5E+A9We
         phCUjryfytNz9omCdud1xfg/Aha+NJs7jMxG8CsG1UYYGinv04ibrwCRCk7CKKMJ6rKi
         yPVgbTMYGxVm7Gv0ZAOfzp9my4LUX22RXzrz/WiccWdsvaZlrN0KDzK6qUlhbLeZmknV
         pD7MM1vaLQcLkwaGnINfw7cq3sz16GF/WLs5IUAYvrhb0QKjl3I2zr8McmeMR2wPCxC8
         bD/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=JZK1GHO+GSsb4xbufFZ7uhZY6/WpkMbk1T52bDV5hr4=;
        fh=zfVslLKZsE5ubj0mqvjL5h5VWQrhp2ccEaA0xOzdKDE=;
        b=Iha6Wy7ef/zZAx1H/ZppcwSAMDP0eYKukk4dDMHXtwLQ5SgokoufOJL1YYwDKu0Kly
         3HfGk/TV/AjMZwxCAqjNaYdyRToKesUpGdsm42co0C/eRvvZJBXwQgWOoOC7ZHD96EF6
         7/oVT00uZCLPf7V/j4t1F+rsOpP3MbNkBz6HBnlCGDFFqtYdZs95ZZ/AUEgquv9R3QL8
         BSW+eQgsI3+H/aDTRlA+s3Su/Is3hTQR20OZTyAIp0nmnsgJ2um6dfEghvWhxUzgEX1m
         R1wb9BdePFSTBZ7IrooVSwjl+hAGCti/zZIls/pnCagfma3vfKCHiFSuDmLf5aGZNgwP
         2diA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=clyso.com; s=google; t=1793105221; x=1793710021; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=JZK1GHO+GSsb4xbufFZ7uhZY6/WpkMbk1T52bDV5hr4=;
        b=OdGNkcMozgJ6xH9Y6yDTsByHbnjK4SdJYSU6VId2Wh5iSmuV9uC3C7YfHB1nzQ1ukZ
         1tzwuJiLEoIS9MntZwfq6fVgSt8uLmNd1Ikd8YhAhOxS1g52hIpFbSimJE+0tlx3IFKf
         nN2k2piugFnjqtfPPOeSBPczp0gf+7n6ouel8x5GJAjCZY5+ZTSxLqX3IQaUfGk6kQ6w
         tq9pePc2II/D0z/5N/QlvbJSerGnDDB/bX8j/UaTyHlOhr8c7M+VPt107Ewp0JnPXyFR
         hTUIEBU/j65UG78V0c7o7Wy/KRUbaDW1WkVWZwTzlRWsqmXYOaWzIac2z1Cx17KeqhxT
         vguQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793105221; x=1793710021;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=JZK1GHO+GSsb4xbufFZ7uhZY6/WpkMbk1T52bDV5hr4=;
        b=VgmpWWnArPnp6P11sUpdN/L1csmHd7Sfg8CYOVOKCqvlDCrr/RESerKCMouFAkrLk5
         6hOMwCVMQ71IfCAs03O8E/EgO1IS4U+CLAQ+bbtQfxjm7CM5r0fy/K3DaxAJCqQEMPZ+
         cw3cq2RMkI/re2iD7DdzhbXSqvmhalnolmf6rzutrNkjn50xht1uAStFu21k5wGRnHT9
         o47UHEweefnRf+TzXbIBkOC9q2liIl3KZzKdSC+M0ahM70glpq3Er6TZ69Nlc+9wmoYr
         MgiBaoDJ2muuivY7rlAxIDl3w1nkESSTPdlwLmeQs7HF8RShfQIeUEoSAvW8syjCcGPC
         o0kQ==
X-Forwarded-Encrypted: i=1; AKwUvBxDXtPUTI+wBJZsrL832sjXE13UWEyc7sm/PBOmQeIAP5MwjT9qYgEDSUZIKZsrPD8pvVkM32ydm4rkrVih@vger.kernel.org
X-Gm-Message-State: AFq9FYIAazD3KFQ35Mo6jUMqWxPSq6P8OPLaaqd38bKou7unq8b+SVhd
	RV/B/Z8WCXTOih14OAsymQ7kojFPGaJiJZEpI7pT48F5FoG4ctgFiaXc7naCkBtl68D8Roz58H/
	tjYRbedI3WhsWzjwAUGvy9jDpHtJl9BqHVSY4r7NHI6Jtj36rdTt7ByUYNQ==
X-Gm-Gg: AYBFou3m+0KEKKLE4axSb+ZHy8vUTLF1XNTBr95IboezV0VhsZkuua/5sXec8W5TUk2
	bYrvX3a9j4lAHq5o19+GZKGqejA0U9EQcT/s90rxHdyp0oGFqlnuwgHR1hO62tsBL37+EuAkQRt
	I98ojjn3zZGkwsgGs9HfG11LNFIld3fUN7QwW5s8NSnTO8f4rAYRrlgXalihr4bUzBv4QgojHXs
	L8FnnbLgN1w6PZALyeN3kX5a2bXOFE/tfALR2ttAYj5SGOv3mk97C+koYyLmllXhgIJIkGZ+cYi
	ie0XQMjyk2lKjf/TUxIw6gM8+RO6UCcmNsigd23srGno3v07PB/K3Lr3KuBc+1Iflpk9dfm4Ddm
	ZfYHVEfUbdG004wlw+XhzRzzUcqUCAAQ2gSnxlqA=
X-Received: by 2002:a17:906:9f90:b0:c2e:6a4f:a88b with SMTP id
 a640c23a62f3a-c46bd905ee8mr1020706466b.0.1793105220635; Tue, 27 Oct 2026
 05:47:00 -0700 (PDT)
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
 <ddf9dfb3e012576caa6953b42f5ce86adae14f95.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
 <sashiko-outbox-184392@kernel.org>
In-Reply-To: <sashiko-outbox-184392@kernel.org>
From: Xiubo Li <xiubo.li@clyso.com>
Date: Tue, 27 Oct 2026 13:46:45 +0100
X-Gm-Features: AclHuK_x8IbpN71OSwnP-JLXCWHklkcQiGYlwjbNY-WcbzDLt8nCKA8gN_pK_0E
Message-ID: <CAOJNxRKZgXuu96dakhkDw8R3EB96aZtWpo57eymFayE67jk4-w@mail.gmail.com>
Subject: Re: [PATCH v6 5/5] ceph: fail quarantined subvolume access with EACCES
To: sashiko-reviews@lists.linux.dev
Cc: Alex Markuze <amarkuze@redhat.com>, idryomov@gmail.com, slava@dubeyko.com, 
	viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz, 
	linux-fscrypt@vger.kernel.org, ebiggers@kernel.org, tytso@mit.edu, 
	jaegeuk@kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Alex,

The benchmark setup and full tables are in my reply to 0/5.  All numbers
below were taken with no subvolume quarantined.

I put the change I tested under each comment.  The four diffs are
incremental on top of this patch.  They apply in this order:

  1. ACL cache;
  2. snapshots outside a subvolume;
  3. async create;
  4. single-lock getattr.

Their order in this mail follows the code instead.  I can send them as a
proper series if that is easier for you to fold in.

> diff --git a/fs/ceph/acl.c b/fs/ceph/acl.c
[...]
>  spin_lock(&ci->i_ceph_lock);
> - if (__ceph_caps_issued_mask_metric(ci, CEPH_CAP_XATTR_SHARED, 0))
> + if (!READ_ONCE(ceph_sb_to_mdsc(inode->i_sb)->quarantine_supported) &&
> +     __ceph_caps_issued_mask_metric(ci, CEPH_CAP_XATTR_SHARED, 0))
>  set_cached_acl(inode, type, acl);

[...]

> @@ -60,6 +60,13 @@ static int ceph_set_ino_cb(struct inode *inode, void *=
data)
[...]
> + /* The VFS ACL cache would bypass Ceph's quarantine checks. */
> + if (READ_ONCE(mdsc->quarantine_supported)) {
> + inode->i_acl =3D ACL_DONT_CACHE;
> + inode->i_default_acl =3D ACL_DONT_CACHE;
> + }

This is the largest regression in the series.  Once the MDS supports
quarantine, the ACL cache is off for every inode, quarantined or not.
acl_permission_check() then calls ceph_get_acl() for every path
component the caller does not own: root, other users, group access.
Each call parses the xattr blob again.

With no quarantine, for a non-owner:

  - d48 stat goes from 140.4us to 206.5us p50 (-34% ops/s);
  - d5 stat goes from 15.3us to 42.0us p50.

perf shows acl_permission_check() at 23.6% of a d48 symlink stat, up
from ~0% on base.

The bypass only matters while something is quarantined, so gate on
that instead of on support:

  - cache ACLs only while quarantine_count =3D=3D 0;
  - when the first mark raises the count, drop every cached ACL on the
    mount once the cap message is handled and the locks are released;
  - drop the ACL_DONT_CACHE setup and the per-fill uncache.

ceph_set_cached_acl() checks quarantine_count under i_ceph_lock, and
the walk takes each i_ceph_lock after the count is raised.  So an ACL
read before the mark is either dropped by the walk or never cached.
open/read stay protected by the quarantine check in ceph_permission()
in any case.

diff --git a/fs/ceph/acl.c b/fs/ceph/acl.c
index 14feb719a1cf..6c5d21989d53 100644
--- a/fs/ceph/acl.c
+++ b/fs/ceph/acl.c
@@ -22,8 +22,14 @@ static inline void ceph_set_cached_acl(struct inode *ino=
de,
 {
  struct ceph_inode_info *ci =3D ceph_inode(inode);

+ /*
+ * The VFS serves cached ACLs without asking Ceph, so cache only while
+ * no subvolume is quarantined. ceph_quarantine_forget_acls() takes
+ * i_ceph_lock after raising quarantine_count, so an ACL read before
+ * the mark is either seen and dropped by it or not cached here.
+ */
  spin_lock(&ci->i_ceph_lock);
- if (!READ_ONCE(ceph_sb_to_mdsc(inode->i_sb)->quarantine_supported) &&
+ if (!atomic_read(&ceph_sb_to_mdsc(inode->i_sb)->quarantine_count) &&
      __ceph_caps_issued_mask_metric(ci, CEPH_CAP_XATTR_SHARED, 0))
  set_cached_acl(inode, type, acl);
  else
@@ -31,29 +37,19 @@ static inline void ceph_set_cached_acl(struct inode *in=
ode,
  spin_unlock(&ci->i_ceph_lock);
 }

-void ceph_quarantine_uncache_inode_acls(struct inode *inode)
-{
- struct ceph_inode_info *ci =3D ceph_inode(inode);
- struct posix_acl *acl, *default_acl;
-
- spin_lock(&ci->i_ceph_lock);
- acl =3D xchg(&inode->i_acl, ACL_DONT_CACHE);
- default_acl =3D xchg(&inode->i_default_acl, ACL_DONT_CACHE);
- spin_unlock(&ci->i_ceph_lock);
- if (!is_uncached_acl(acl))
- posix_acl_release(acl);
- if (!is_uncached_acl(default_acl))
- posix_acl_release(default_acl);
-}
-
-void ceph_quarantine_disable_acl_cache(struct super_block *sb)
+/* Drop ACLs cached before the first quarantine mark on this mount. */
+void ceph_quarantine_forget_acls(struct super_block *sb)
 {
  struct inode *inode;

- /* Cover inodes cached before the first supporting session opened. */
  spin_lock(&sb->s_inode_list_lock);
- list_for_each_entry(inode, &sb->s_inodes, i_sb_list)
- ceph_quarantine_uncache_inode_acls(inode);
+ list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
+ struct ceph_inode_info *ci =3D ceph_inode(inode);
+
+ spin_lock(&ci->i_ceph_lock);
+ forget_all_cached_acls(inode);
+ spin_unlock(&ci->i_ceph_lock);
+ }
  spin_unlock(&sb->s_inode_list_lock);
 }

diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index 7c85e84fa649..87033ea5adfe 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -5194,6 +5194,9 @@ void ceph_handle_caps(struct ceph_mds_session *sessio=
n,
 done_unlocked:
  iput(inode);
 out:
+ /* A first mark is applied under i_ceph_lock; drop ACLs unlocked. */
+ if (atomic_xchg(&mdsc->quarantine_acl_flush, 0))
+ ceph_quarantine_forget_acls(mdsc->fsc->sb);
  ceph_dec_mds_stopping_blocker(mdsc);

  ceph_put_string(extra_info.pool_ns);
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index df69feaa8fba..7b63adc346f0 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -60,13 +60,6 @@ static int ceph_set_ino_cb(struct inode *inode, void *da=
ta)
 #endif

  inode_set_iversion_raw(inode, 0);
-#ifdef CONFIG_CEPH_FS_POSIX_ACL
- /* The VFS ACL cache would bypass Ceph's quarantine checks. */
- if (READ_ONCE(mdsc->quarantine_supported)) {
- inode->i_acl =3D ACL_DONT_CACHE;
- inode->i_default_acl =3D ACL_DONT_CACHE;
- }
-#endif
  percpu_counter_inc(&mdsc->metric.total_inodes);

  return 0;
@@ -787,7 +780,6 @@ void ceph_quarantine_enable(struct ceph_mds_client *mds=
c)
  return;

  WRITE_ONCE(mdsc->quarantine_supported, true);
- ceph_quarantine_disable_acl_cache(mdsc->fsc->sb);
 }

 void ceph_quarantine_set(struct ceph_inode_info *ci)
@@ -797,8 +789,8 @@ void ceph_quarantine_set(struct ceph_inode_info *ci)
  mdsc =3D ceph_sb_to_mdsc(ci->netfs.inode.i_sb);
  /* Every accepted negative invalidates earlier requests and receipts. */
  ceph_quarantine_write_begin(mdsc);
- if (mdsc)
- atomic_inc(&mdsc->quarantine_count);
+ if (mdsc && atomic_inc_return(&mdsc->quarantine_count) =3D=3D 1)
+ atomic_set(&mdsc->quarantine_acl_flush, 1);
  if (test_and_set_bit(CEPH_I_QUARANTINE_BIT, &ci->i_ceph_flags)) {
  if (mdsc)
  atomic_dec(&mdsc->quarantine_count);
@@ -1787,9 +1779,6 @@ int ceph_fill_inode(struct inode *inode, struct
folio *locked_folio,
  if (ceph_in_snap(inode) && !ci->i_snapid_map)
  ci->i_snapid_map =3D ceph_get_snapid_map(mdsc, ceph_snap(inode));

- if (READ_ONCE(session->s_mdsc->quarantine_supported))
- ceph_quarantine_uncache_inode_acls(inode);
-
  spin_lock(&ci->i_ceph_lock);

  /*
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 730fd4bfaeff..69ea8231189b 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -6482,6 +6482,7 @@ int ceph_mdsc_init(struct ceph_fs_client *fsc)
  spin_lock_init(&mdsc->stopping_lock);
  atomic_set(&mdsc->stopping_blockers, 0);
  atomic_set(&mdsc->quarantine_count, 0);
+ atomic_set(&mdsc->quarantine_acl_flush, 0);
  mdsc->quarantine_supported =3D false;
  init_waitqueue_head(&mdsc->quarantine_waitq);
  INIT_LIST_HEAD(&mdsc->quarantine_splice_owners);
diff --git a/fs/ceph/mds_client.h b/fs/ceph/mds_client.h
index 422a27e44c38..bd9ae871bd52 100644
--- a/fs/ceph/mds_client.h
+++ b/fs/ceph/mds_client.h
@@ -530,6 +530,7 @@ struct ceph_mds_client {
  * while it is non-zero. Each splice edge also bumps the epoch.
  */
  atomic_t quarantine_count;
+ atomic_t quarantine_acl_flush; /* first mark, drop ACLs */
  atomic_t quarantine_writers;
  atomic_t quarantine_splices;
  atomic64_t quarantine_epoch;
diff --git a/fs/ceph/super.h b/fs/ceph/super.h
index 8aecc6f1b629..762bed60bfe5 100644
--- a/fs/ceph/super.h
+++ b/fs/ceph/super.h
@@ -1409,8 +1409,7 @@ int ceph_set_acl(struct mnt_idmap *idmap,
 int ceph_pre_init_acls(struct inode *dir, umode_t *mode,
         struct ceph_acl_sec_ctx *as_ctx);
 void ceph_init_inode_acls(struct inode *inode, struct
ceph_acl_sec_ctx *as_ctx);
-void ceph_quarantine_uncache_inode_acls(struct inode *inode);
-void ceph_quarantine_disable_acl_cache(struct super_block *sb);
+void ceph_quarantine_forget_acls(struct super_block *sb);

 static inline void ceph_forget_all_cached_acls(struct inode *inode)
 {
@@ -1433,11 +1432,7 @@ static inline void ceph_init_inode_acls(struct
inode *inode,
 {
 }

-static inline void ceph_quarantine_uncache_inode_acls(struct inode *inode)
-{
-}
-
-static inline void ceph_quarantine_disable_acl_cache(struct super_block *s=
b)
+static inline void ceph_quarantine_forget_acls(struct super_block *sb)
 {
 }


I tested this: a cached ACL fails getfacl with EACCES after the
subvolume is quarantined and works again after disable.  The non-owner
numbers above come back to base.

> +void ceph_quarantine_disable_acl_cache(struct super_block *sb)
> +{
> + struct inode *inode;
> +
> + /* Cover inodes cached before the first supporting session opened. */
> + spin_lock(&sb->s_inode_list_lock);
> + list_for_each_entry(inode, &sb->s_inodes, i_sb_list)
> + ceph_quarantine_uncache_inode_acls(inode);
> + spin_unlock(&sb->s_inode_list_lock);
> +}

This walks the whole inode list under s_inode_list_lock without
cond_resched(), from handle_session() with mdsc->mutex held.  It only
runs when the first supporting session opens, so it mostly matters for
an MDS upgrade under a client with a large inode cache.  With the change
above, the walk runs on the first mark instead.  Either way it should
drop the lock periodically, the way evict_inodes() does.  My diff
above still uses the plain walk and needs the same treatment.

> +bool ceph_quarantine_head_cap_valid(struct inode *inode)
> +{
[...]
> + spin_lock(&ci->i_ceph_lock);
> + cap =3D ci->i_auth_cap;
> + valid =3D cap && __cap_is_valid(ci, cap) &&
> + test_bit(CEPHFS_FEATURE_QUARANTINE, &cap->session->s_features) &&
> + (cap->issued & CEPH_CAP_AUTH_SHARED);
> + spin_unlock(&ci->i_ceph_lock);

[...]

> + head_revalidate =3D ceph_quarantine_head_needs_revalidate(inode);
> + if (head_revalidate) {
[...]
> + if (ceph_snapshot_needs_revalidate(inode) ||
> +     head_revalidate ||
> +     ceph_inode_quarantine_state(inode) !=3D CEPH_Q_CLEAR)
> + force =3D true;

ceph_permission() calls __ceph_do_getattr() for every path component.
Each call now takes i_ceph_lock here and then again in
ceph_caps_issued_mask_metric(), so a depth-48 lookup takes 48 extra
spinlock round trips.  In the owner runs, where the ACL cache is not
involved:

  - d48 stat is 141.7us vs 154.4us p50;
  - d48 symlink stat is 145.2us vs 159.3us;
  - readlink is 141.1us vs 154.2us.

When quarantine_count is zero, the checks above reduce to "valid head
cap and cached caps", so both can go under one lock.  A miss falls
through to the existing slow path, which accounts for it:

diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
index 87033ea5adfe..87d2f995b1d9 100644
--- a/fs/ceph/caps.c
+++ b/fs/ceph/caps.c
@@ -3025,6 +3025,28 @@ bool ceph_quarantine_head_cap_valid(struct inode *in=
ode)
  return valid;
 }

+/*
+ * ceph_quarantine_head_cap_valid() plus the cached caps check, under one
+ * i_ceph_lock. A miss is left to the caller's slow path to account.
+ */
+bool ceph_quarantine_head_caps_issued(struct inode *inode, int mask)
+{
+ struct ceph_inode_info *ci =3D ceph_inode(inode);
+ struct ceph_cap *cap;
+ bool hit =3D false;
+
+ spin_lock(&ci->i_ceph_lock);
+ cap =3D ci->i_auth_cap;
+ if (cap && __cap_is_valid(ci, cap) &&
+     test_bit(CEPHFS_FEATURE_QUARANTINE, &cap->session->s_features) &&
+     (cap->issued & CEPH_CAP_AUTH_SHARED))
+ hit =3D __ceph_caps_issued_mask(ci, mask, 1);
+ spin_unlock(&ci->i_ceph_lock);
+ if (hit)
+ ceph_update_cap_hit(&ceph_inode_to_fs_client(inode)->mdsc->metric);
+ return hit;
+}
+
 static bool ceph_cap_auth_valid(struct ceph_mds_client *mdsc, u64 epoch)
 {
  /*
diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index 7f5b65d69077..b716080668ac 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -4001,6 +4001,17 @@ int __ceph_do_getattr(struct inode *inode,
struct folio *locked_folio,
  return err;
  }

+ /*
+ * With nothing quarantined on the mount, the checks below reduce to
+ * a valid head cap and cached caps. ceph_permission() gets here for
+ * every path component, so take i_ceph_lock once for both.
+ */
+ if (!force && !ceph_in_snap(inode) &&
+     READ_ONCE(mdsc->quarantine_supported) &&
+     !atomic_read(&mdsc->quarantine_count) &&
+     ceph_quarantine_head_caps_issued(inode, mask))
+ return 0;
+
  head_revalidate =3D ceph_quarantine_head_needs_revalidate(inode);
  if (head_revalidate) {
  /* Do not recurse into an MDS request from our own splice hook. */
diff --git a/fs/ceph/super.h b/fs/ceph/super.h
index 7edb482e3a82..674324308dd1 100644
--- a/fs/ceph/super.h
+++ b/fs/ceph/super.h
@@ -1316,6 +1316,7 @@ int ceph_quarantine_revalidate(struct inode *inode);
 int ceph_quarantine_wait(struct inode *inode);
 bool ceph_snapshot_needs_revalidate(struct inode *inode);
 bool ceph_quarantine_head_cap_valid(struct inode *inode);
+bool ceph_quarantine_head_caps_issued(struct inode *inode, int mask);
 void ceph_quarantine_enable(struct ceph_mds_client *mdsc);
 int ceph_snapshot_read_auth(struct inode *inode);
 void ceph_quarantine_set(struct ceph_inode_info *ci);

With this, owner d48 stat is 143.0us and symlink stat 147.2us.

> +static const char *ceph_get_link(struct dentry *dentry, struct inode *in=
ode,
> + struct delayed_call *done)
> +{
[...]
> + err =3D ceph_symlink_revalidate(inode);

With the two changes above, the extra getattr here costs ~2us at d48.
That is fine by me.

> + /*
> + * LSM label reads can wait on async create completion. Quarantine
> + * may activate after submission, so keep blob-bearing creates
> + * synchronous even before support is negotiated.
> + */
> + if (ceph_security_xattr_wanted(new_inode))
> + try_async =3D false;

i_security is non-NULL on basically every distro kernel.  So this turns
async create off for SELinux, AppArmor and Smack clients, whether or not
the MDS supports quarantine.  500 O_CREAT opens call
try_prep_async_create() 500 times on base and 0 times on v6.

The wait comes from the label read in d_splice_alias(): once a
quarantine is active, __ceph_getxattr() sets ask_mds, and
ceph_mdsc_submit_request() waits for the async create.  But the blob of
an inode whose create is still in flight is the one this client just
sent, and the MDS has nothing newer.  Serving the label from it while
CEPH_I_ASYNC_CREATE is set avoids the wait, and the create reply itself
enforces the quarantine.  Then this hunk can go:

diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 367bb1dcc4a8..b1b8eb366523 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -930,14 +930,6 @@ int ceph_atomic_open(struct inode *dir, struct
dentry *dentry,
  err =3D PTR_ERR(new_inode);
  goto out_ctx;
  }
- /*
- * LSM label reads can wait on async create completion. Quarantine
- * may activate after submission, so keep blob-bearing creates
- * synchronous even before support is negotiated.
- */
- if (ceph_security_xattr_wanted(new_inode))
- try_async =3D false;
-
  /* Async create can't handle more than a page of xattrs */
  if (as_ctx.pagelist &&
      !list_is_singular(&as_ctx.pagelist->head))
diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
index 13d4dfef679d..542c2b9388d6 100644
--- a/fs/ceph/xattr.c
+++ b/fs/ceph/xattr.c
@@ -1038,9 +1038,12 @@ ssize_t __ceph_getxattr(struct inode *inode,
const char *name, void *value,
  /*
  * A shared cap would answer from the cache. The state check may
  * schedule, so drop i_ceph_lock first. A reply reading the blob
- * it just installed must still use that cache.
+ * it just installed must still use that cache, and so must the LSM
+ * hook of an async create: the blob is the one we sent, and asking
+ * the MDS would wait for the create itself.
  */
- if (!ceph_current_fill_trace_request()) {
+ if (!ceph_current_fill_trace_request() &&
+     !(ci->i_ceph_flags & CEPH_I_ASYNC_CREATE)) {
  spin_unlock(&ci->i_ceph_lock);
  ask_mds =3D ceph_snapshot_needs_revalidate(inode) ||
    ceph_inode_quarantine_state(inode) !=3D CEPH_Q_CLEAR;
  I tested 200 async creates in a plain directory while
another subvolume was quarantined: no hangs, labels correct, and a
create inside the quarantined subvolume fails with EACCES.

> +/* A snapshot path must reach a head inode to encode its snapshot name. =
*/
> +static bool ceph_snapshot_has_path(struct inode *inode, bool check_caps)
> +{
[...]
> + if (!ceph_in_snap(in)) {
> + connected =3D !check_caps ||
> + (subvolume_id !=3D CEPH_SUBVOLUME_ID_NONE &&
> + ceph_ino(in) =3D=3D subvolume_id &&
> + ceph_quarantine_head_cap_valid(in));

For a snapshot of a directory that is in no subvolume, subvolume_id is
NONE, so this is always false.  Every read() and stat() of such a
snapshot goes to the MDS:

  - reading a 4M file in 4K reads issues 1041 MDS requests instead of 8;
  - 1000 stats issue 6000 requests and take 4.49s instead of 0.07s.

Backup tools that read .snap outside subvolumes will hit this.

The MDS encodes subvolume_id from the inode's snaprealm, snapshot
inodes included:

encode(realm ? realm->get_subvolume_ino() : inodeno_t(0), bl);

So a zero in an InodeStat v9 reply from a quarantine-capable session
means "in no subvolume", not "unknown".  On the client, that needs:

  - record in parse_reply_info_in() whether the field was present
    (struct_v >=3D 9);
  - in ceph_fill_inode(), when it is present, zero and from a
    CEPHFS_FEATURE_QUARANTINE session, store a generation in the inode
    (e.g. i_subvolume_none_gen =3D snap_subvol_gen + 1);
  - bump mdsc->snap_subvol_gen in ceph_handle_snap() for every snap
    message, because marking an existing directory as a subvolume
    splits or updates a realm;
  - here, accept a head ancestor with a valid AUTH_SHARED cap when the
    stored generation is current;
  - for CEPH_SNAPDIR, use the head directory's values: the snapdir is
    never filled by the MDS, and its revalidation already refreshes the
    head via GETATTR.

Bumping the generation on every snap message is coarse: creating a
snapshot also invalidates the answer, so each cached snapshot inode
pays one MDS round trip after that.  The kernel decodes the old
SnapRealmInfo, which has no subvolume flag, so I did not try to be more
precise.

diff --git a/fs/ceph/inode.c b/fs/ceph/inode.c
index 7b63adc346f0..7f5b65d69077 100644
--- a/fs/ceph/inode.c
+++ b/fs/ceph/inode.c
@@ -651,6 +651,7 @@ struct inode *ceph_alloc_inode(struct super_block *sb)
  ci->i_max_bytes =3D 0;
  ci->i_max_files =3D 0;
  ci->i_subvolume_id =3D CEPH_SUBVOLUME_ID_NONE;
+ ci->i_subvolume_none_gen =3D 0;
  ci->i_qtine_errno =3D 0;
  ci->i_qtine_mds =3D -1;
  atomic64_set(&ci->i_qtag, 0);
@@ -1369,6 +1370,7 @@ void ceph_evict_inode(struct inode *inode)
  percpu_counter_dec(&mdsc->metric.total_inodes);

  ci->i_subvolume_id =3D CEPH_SUBVOLUME_ID_NONE;
+ ci->i_subvolume_none_gen =3D 0;
  ceph_quarantine_forget_receipt(ci);
  ceph_quarantine_clear(ci);

@@ -1806,6 +1808,11 @@ int ceph_fill_inode(struct inode *inode, struct
folio *locked_folio,

  __ceph_update_quota(ci, iinfo->max_bytes, iinfo->max_files);
  ceph_inode_set_subvolume(inode, iinfo->subvolume_id);
+ if (iinfo->subvolume_known &&
+     iinfo->subvolume_id =3D=3D CEPH_SUBVOLUME_ID_NONE &&
+     test_bit(CEPHFS_FEATURE_QUARANTINE, &session->s_features))
+ WRITE_ONCE(ci->i_subvolume_none_gen,
+    atomic64_read(&mdsc->snap_subvol_gen) + 1);

 #ifdef CONFIG_FS_ENCRYPTION
  if (iinfo->fscrypt_auth_len &&
@@ -3791,17 +3798,34 @@ int ceph_try_to_choose_auth_mds(struct inode
*inode, int mask)
  return USE_ANY_MDS;
 }

+/*
+ * Outside any subvolume there is nothing to quarantine, as long as no sna=
p
+ * message since the MDS said so may have created a subvolume above it.
+ * A live head cap keeps those messages coming.
+ */
+static bool ceph_inode_in_no_subvolume(struct inode *inode)
+{
+ struct ceph_inode_info *ci =3D ceph_inode(inode);
+ struct ceph_mds_client *mdsc =3D ceph_sb_to_mdsc(inode->i_sb);
+
+ return READ_ONCE(ci->i_subvolume_id) =3D=3D CEPH_SUBVOLUME_ID_NONE &&
+        READ_ONCE(ci->i_subvolume_none_gen) =3D=3D
+        (u64)atomic64_read(&mdsc->snap_subvol_gen) + 1;
+}
+
 /* A snapshot path must reach a head inode to encode its snapshot name. */
 static bool ceph_snapshot_has_path(struct inode *inode, bool check_caps)
 {
  struct dentry *cur;
  u64 subvolume_id =3D CEPH_SUBVOLUME_ID_NONE;
  unsigned int seq, depth =3D 0;
- bool connected =3D false;
+ bool connected =3D false, no_subvol =3D false;

  /* A torn membership ID cannot establish revocation coverage. */
- if (check_caps && IS_ENABLED(CONFIG_64BIT))
+ if (check_caps && IS_ENABLED(CONFIG_64BIT)) {
  subvolume_id =3D READ_ONCE(ceph_inode(inode)->i_subvolume_id);
+ no_subvol =3D ceph_inode_in_no_subvolume(inode);
+ }

  rcu_read_lock();
  seq =3D read_seqbegin(&rename_lock);
@@ -3813,9 +3837,19 @@ static bool ceph_snapshot_has_path(struct inode
*inode, bool check_caps)
  if (!in)
  break;
  if (!ceph_in_snap(in)) {
+ /*
+ * The synthetic snapdir is never filled by the MDS; its
+ * revalidation refreshes the head directory instead.
+ */
+ if (check_caps && IS_ENABLED(CONFIG_64BIT) &&
+     ceph_snap(inode) =3D=3D CEPH_SNAPDIR) {
+ subvolume_id =3D READ_ONCE(ceph_inode(in)->i_subvolume_id);
+ no_subvol =3D ceph_inode_in_no_subvolume(in);
+ }
  connected =3D !check_caps ||
- (subvolume_id !=3D CEPH_SUBVOLUME_ID_NONE &&
- ceph_ino(in) =3D=3D subvolume_id &&
+ ((no_subvol ||
+   (subvolume_id !=3D CEPH_SUBVOLUME_ID_NONE &&
+    ceph_ino(in) =3D=3D subvolume_id)) &&
  ceph_quarantine_head_cap_valid(in));
  break;
  }
@@ -3838,8 +3872,9 @@ static bool ceph_snapshot_has_path(struct inode
*inode, bool check_caps)
  * A snapshot taken above that root can reach a head ancestor outside the
  * subvolume; its cap stays valid when the target is quarantined. Require =
the
  * MDS-provided subvolume ID to identify the head root whose AUTH_SHARED c=
ap
- * we check. Unknown IDs, 32-bit clients and other head ancestors need an =
MDS
- * answer, as do detached snapshots, expired root caps and active quaranti=
ne.
+ * we check, or an MDS answer that the inode is in no subvolume. Unknown I=
Ds,
+ * 32-bit clients and other head ancestors need an MDS answer, as do detac=
hed
+ * snapshots, expired head caps and active quarantine.
  */
 bool ceph_snapshot_needs_revalidate(struct inode *inode)
 {
diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
index 69ea8231189b..5a3f7d8bff84 100644
--- a/fs/ceph/mds_client.c
+++ b/fs/ceph/mds_client.c
@@ -153,6 +153,7 @@ static int parse_reply_info_in(void **p, void *end,
  u32 struct_len =3D 0;

  info->subvolume_id =3D CEPH_SUBVOLUME_ID_NONE;
+ info->subvolume_known =3D false;

  if (features =3D=3D (u64)-1) {
  ceph_decode_8_safe(p, end, struct_v, bad);
@@ -299,8 +300,10 @@ static int parse_reply_info_in(void **p, void *end,
  }

  /* struct_v 9 added subvolume_id */
- if (struct_v >=3D 9)
+ if (struct_v >=3D 9) {
  ceph_decode_64_safe(p, end, info->subvolume_id, bad);
+ info->subvolume_known =3D true;
+ }

  *p =3D end;
  } else {
@@ -6483,6 +6486,7 @@ int ceph_mdsc_init(struct ceph_fs_client *fsc)
  atomic_set(&mdsc->stopping_blockers, 0);
  atomic_set(&mdsc->quarantine_count, 0);
  atomic_set(&mdsc->quarantine_acl_flush, 0);
+ atomic64_set(&mdsc->snap_subvol_gen, 0);
  mdsc->quarantine_supported =3D false;
  init_waitqueue_head(&mdsc->quarantine_waitq);
  INIT_LIST_HEAD(&mdsc->quarantine_splice_owners);
diff --git a/fs/ceph/mds_client.h b/fs/ceph/mds_client.h
index bd9ae871bd52..dd6764a62bde 100644
--- a/fs/ceph/mds_client.h
+++ b/fs/ceph/mds_client.h
@@ -175,6 +175,7 @@ struct ceph_mds_reply_info_in {
  u64 rsnaps;
  u64 change_attr;
  u64 subvolume_id;
+ bool subvolume_known; /* InodeStat v9: zero means no subvolume */
 };

 struct ceph_mds_reply_dir_entry {
@@ -531,6 +532,7 @@ struct ceph_mds_client {
  */
  atomic_t quarantine_count;
  atomic_t quarantine_acl_flush; /* first mark, drop ACLs */
+ atomic64_t snap_subvol_gen; /* bumped by every snap message */
  atomic_t quarantine_writers;
  atomic_t quarantine_splices;
  atomic64_t quarantine_epoch;
diff --git a/fs/ceph/snap.c b/fs/ceph/snap.c
index f59b83a97d52..1c5d2f7ca667 100644
--- a/fs/ceph/snap.c
+++ b/fs/ceph/snap.c
@@ -1054,6 +1054,9 @@ void ceph_handle_snap(struct ceph_mds_client *mdsc,
  trace_len =3D le32_to_cpu(h->trace_len);
  p +=3D sizeof(*h);

+ /* A realm split or update may move inodes into a new subvolume. */
+ atomic64_inc(&mdsc->snap_subvol_gen);
+
  boutc(cl, "from mds%d op %s split %llx tracelen %d\n", mds,
        ceph_snap_op_name(op), split, trace_len);

diff --git a/fs/ceph/super.h b/fs/ceph/super.h
index 762bed60bfe5..7edb482e3a82 100644
--- a/fs/ceph/super.h
+++ b/fs/ceph/super.h
@@ -443,6 +443,11 @@ struct ceph_inode_info {
  */
 #define CEPH_SUBVOLUME_ID_NONE 0
  u64 i_subvolume_id;
+ /*
+ * snap_subvol_gen + 1 when a quarantine-capable MDS last said this
+ * inode is in no subvolume, 0 if it never did.
+ */
+ u64 i_subvolume_none_gen;

  /*
  * Cap oserrno from the MDS. -CEPH_EQUARANTINED means this inode

With this, the snapshot test above drops to 9, 0 and 60 requests.  I
also tried the case your comment worries about:

  1. snapshot a plain directory;
  2. read the snapshot, so the inodes are cached with subvolume_id 0;
  3. mark the directory as a subvolume;
  4. quarantine it.

Reading and stat'ing the old snapshot then fail with EACCES as they
should.  Snapshots inside a quarantined subvolume still fail too.

> + if (!snapshot) {
> + qstate =3D file->f_mode & FMODE_WRITE ?
> + ceph_inode_quarantine_write_state(inode) :
> + ceph_inode_quarantine_state(inode);
> + if (qstate =3D=3D CEPH_Q_UNDER &&
> +     ceph_inode_quarantine_direct(inode)) {
> + ceph_blog_exit(&__ji);
> + return -EACCES;
> + }

A direct mark fails open() without asking the MDS.  Suppose the
MQuarantineDisable is lost (session reset, message dropped by the
version check you will add in 4/5) and the inode has no wanted caps.
Then open() keeps failing until something else refreshes the inode from
the same rank.  ceph_quarantine_revalidate() has the same early return.
I would send one GETATTR before failing, as the inherited-mark path
already does, and fail only if the reply still says EQUARANTINED.

> + for (;;) {
> + q =3D ceph_inode_quarantine_state(inode);
[...]
> + epoch =3D (u64)atomic64_read_acquire(&mdsc->quarantine_epoch);
> + if ((epoch & 1) || atomic_read(&mdsc->quarantine_splices))
> + continue;

This loop has no bound while the global epoch keeps moving, and any
splice on the mount moves it.  I ran it against a depth-300 path, with
another subvolume quarantined and a create/rename/ls generator on the
same mount.  20000 ls+read iterations took 16 s, with ~41k
revalidations and ~2.8k MDS requests, so it converges in practice.  It
is still unbounded by design.  A retry limit, after which you fall back
to the MDS answer, would make it obviously finite.

Thanks,
Xiubo

On Sun, 25 Oct 2026 at 20:48, <sashiko-bot@kernel.org> wrote:
>
> Thank you for your contribution! Sashiko AI review found 4 potential issu=
e(s) to consider:
> - [High] ceph: missing head cap revalidation in ceph_open() and write cap=
 paths
> - [High] ceph: stale xattr cache in __ceph_setxattr() sync fallback with =
XATTR_EXCL
> - [High] ceph: infinite loop in __ceph_get_caps() when inline data reply =
lacks cache caps
> - [Medium] ceph: missing head cap revalidation in __ceph_getxattr() and c=
eph_listxattr()
> --
>
> commit 3b0481a00dbf8afa6f80793356dab3d1a012a099
> Author: Alex Markuze <amarkuze@redhat.com>
>
> ceph: fail quarantined subvolume access with EACCES
>
> This commit adds client-side enforcement for quarantined subvolumes befor=
e
> advertising CEPHFS_FEATURE_QUARANTINE to the MDS. It revalidates cached
> data, metadata, xattrs, ACLs, symlinks, and snapshot capabilities against
> quarantine state and requires MDS authorization when local state or
> revocation coverage is insufficient.
>
> > diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> > index dd2bd8ed24249..79e396752601f 100644
> > --- a/fs/ceph/addr.c
> > +++ b/fs/ceph/addr.c
> [ ... ]
> > @@ -2649,9 +2674,24 @@ static const struct vm_operations_struct ceph_vm=
ops =3D {
> >  int ceph_mmap_prepare(struct vm_area_desc *desc)
> >  {
> >       struct address_space *mapping =3D desc->file->f_mapping;
> > +     struct inode *inode =3D file_inode(desc->file);
> > +     int err, got =3D 0;
> >
> >       if (!mapping->a_ops->read_folio)
> >               return -ENOEXEC;
> > +     err =3D ceph_quarantine_revalidate(inode);
> > +     if (err)
> > +             return err;
> > +     if (vma_desc_test_all(desc, VMA_SHARED_BIT, VMA_WRITE_BIT) &&
> > +         ceph_inode_quarantine_write_state(inode) !=3D CEPH_Q_CLEAR) {
> > +             /* A read receipt cannot admit a writable shared mapping.=
 */
> > +             err =3D ceph_get_caps(desc->file, CEPH_CAP_FILE_WR, 0, -1=
, &got);
> > +             if (err)
> > +                     return err;
> > +             ceph_put_cap_refs(ceph_inode(inode), got);
> > +     }
>
> [Severity: High]
> Can a writable shared mapping be admitted here using only a read-only
> GETATTR confirmation when mdsc->quarantine_count is zero?
>
> In __ceph_inode_quarantine_state(), both ceph_inode_quarantine_state() an=
d
> ceph_inode_quarantine_write_state() return CEPH_Q_CLEAR immediately whene=
ver
> atomic_read(&mdsc->quarantine_count) =3D=3D 0:
>
> fs/ceph/inode.c:__ceph_inode_quarantine_state() {
>         ...
>         mdsc =3D ceph_sb_to_mdsc(inode->i_sb);
>         if (!mdsc || atomic_read(&mdsc->quarantine_count) =3D=3D 0)
>                 return CEPH_Q_CLEAR;
>         ...
> }
>
> If a subvolume is already quarantined before the client caches caps above
> CEPH_CAP_PIN (or after marked inodes are evicted), mdsc->quarantine_count=
 is
> 0. When a client with read-only recovery permission (q, but not Q) calls
> ceph_mmap_prepare(), ceph_quarantine_revalidate() succeeds via GETATTR
> without granting CEPH_CAP_AUTH_SHARED, leaving
> ceph_quarantine_head_needs_revalidate(inode) true.
>
> Because ceph_inode_quarantine_write_state(inode) still returns CEPH_Q_CLE=
AR
> when quarantine_count is 0, the check above is false and ceph_get_caps() =
for
> CEPH_CAP_FILE_WR is skipped.
>
> The same issue also affects __ceph_get_caps() and ceph_open() when
> quarantine_count is 0 and ceph_quarantine_head_needs_revalidate(inode) is
> true (for example, when ci->i_auth_cap only holds CEPH_CAP_PIN from a pri=
or
> read-only LOOKUP or GETATTR). In ceph_open() with FMODE_WRITE, do_sync
> remains false, allowing the fast path to succeed locally on the PIN-only
> ci->i_auth_cap without sending CEPH_MDS_OP_OPEN, and triggering
> ceph_uninline_data() on inline files.
>
> Should ceph_mmap_prepare(), __ceph_get_caps(), and ceph_open() also check
> ceph_quarantine_head_needs_revalidate(inode) on write paths?
>
> > diff --git a/fs/ceph/caps.c b/fs/ceph/caps.c
> > index b07814d0038cd..7c85e84fa6493 100644
> > --- a/fs/ceph/caps.c
> > +++ b/fs/ceph/caps.c
> [ ... ]
> > @@ -3304,15 +3396,71 @@ int __ceph_get_caps(struct inode *inode, struct=
 ceph_file_info *fi, int need,
> >
> >       while (true) {
> >               flags &=3D CEPH_FILE_MODE_MASK;
> > +             if (snapshot && ceph_snapshot_needs_revalidate(inode)) {
> > +                     /*
> > +                      * i_snap_caps cannot be revoked, and an idle sna=
pshot
> > +                      * inode may receive no quarantine notification a=
t all.
> > +                      * An MDS answer authorizes only this acquisition=
.
> > +                      */
> > +                     qepoch =3D atomic64_read_acquire(&mdsc->quarantin=
e_epoch);
> > +                     if (!ceph_cap_auth_valid(mdsc, qepoch)) {
> > +                             ret =3D ceph_quarantine_wait(inode);
> > +                             if (ret)
> > +                                     return ret;
> > +                             continue;
> > +                     }
> > +                     ret =3D ceph_snapshot_read_auth(inode);
> > +                     if (ret)
> > +                             return ret;
> > +                     flags |=3D MDS_AUTHORIZED;
>
> [Severity: High]
> Does __ceph_get_caps() loop infinitely when reading a snapshot file with
> inline data whose MDS reply authorizes access without granting
> CEPH_CAP_FILE_CACHE or CEPH_CAP_FILE_LAZYIO in info->cap.caps?
>
> If a snapshot regular file with inline data (ceph_has_inline_data(ci) &&
> i_size_read(inode) > 0) previously recorded CEPH_CAP_FILE_RD |
> CEPH_CAP_FILE_CACHE in ci->i_snap_caps, those bits are sticky in
> __ceph_caps_issued(). When folio 0 is not uptodate (for example after
> ceph_read_folio() unlocks a newly allocated folio and calls
> __ceph_get_caps()) and ceph_snapshot_needs_revalidate(inode) is true:
>
> 1. ceph_snapshot_read_auth(inode) succeeds and sets MDS_AUTHORIZED.
> 2. try_get_cap_refs() grants _got =3D CEPH_CAP_FILE_RD | CEPH_CAP_FILE_CA=
CHE
>    from ci->i_snap_caps.
> 3. At the bottom of the loop in __ceph_get_caps(), folio 0 is not uptodat=
e,
>    so __ceph_get_caps() drops _got and calls:
>
>    __ceph_do_getattr(inode, NULL, CEPH_STAT_CAP_INLINE_DATA, true)
>
> 4. In ceph_fill_inode(), fill_inline is only set when locked_folio is
>    non-NULL or info_caps from the current reply includes cache_caps:
>
> fs/ceph/inode.c:ceph_fill_inode() {
>         ...
>         if (iinfo->inline_version > 0 &&
>             iinfo->inline_version >=3D ceph_inline_version(ci)) {
>                 int cache_caps =3D CEPH_CAP_FILE_CACHE | CEPH_CAP_FILE_LA=
ZYIO;
>                 ceph_set_inline_version(ci, iinfo->inline_version);
>                 if (ceph_has_inline_data(ci) &&
>                     (locked_folio || (info_caps & cache_caps)))
>                         fill_inline =3D true;
>         }
>         ...
> }
>
> When the reply authorizes the read (such as for a recovery client or via
> LOOKUPINO) and returns inline data with targeti.inline_version > 1, but
> info->cap.caps does not include CEPH_CAP_FILE_CACHE | CEPH_CAP_FILE_LAZYI=
O,
> ceph_fill_inode() skips ceph_fill_inline_data(), __ceph_do_getattr() retu=
rns
> 0, and __ceph_get_caps() executes continue and repeats the RPC loop
> indefinitely because folio 0 is never marked uptodate.
>
> > diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
> > index 4cba6e7bffd3d..13d4dfef679de 100644
> > --- a/fs/ceph/xattr.c
> > +++ b/fs/ceph/xattr.c
> > @@ -997,6 +997,7 @@ ssize_t __ceph_getxattr(struct inode *inode, const =
char *name, void *value,
> >       struct ceph_vxattr *vxattr;
> >       int req_mask;
> >       ssize_t err;
> > +     bool ask_mds =3D false;
> >
> >       if (strncmp(name, XATTR_CEPH_PREFIX, XATTR_CEPH_PREFIX_LEN))
> >               goto handle_non_vxattrs;
> > @@ -1034,7 +1035,19 @@ ssize_t __ceph_getxattr(struct inode *inode, con=
st char *name, void *value,
> >             ceph_vinop(inode), name, ci->i_xattrs.version,
> >             ci->i_xattrs.index_version);
> >
> > -     if (ci->i_xattrs.version =3D=3D 0 ||
> > +     /*
> > +      * A shared cap would answer from the cache. The state check may
> > +      * schedule, so drop i_ceph_lock first. A reply reading the blob
> > +      * it just installed must still use that cache.
> > +      */
> > +     if (!ceph_current_fill_trace_request()) {
> > +             spin_unlock(&ci->i_ceph_lock);
> > +             ask_mds =3D ceph_snapshot_needs_revalidate(inode) ||
> > +                       ceph_inode_quarantine_state(inode) !=3D CEPH_Q_=
CLEAR;
> > +             spin_lock(&ci->i_ceph_lock);
> > +     }
>
> [Severity: Medium]
> Should __ceph_getxattr() and ceph_listxattr() also check
> ceph_quarantine_head_needs_revalidate(inode) when computing ask_mds, just=
 as
> ceph_getattr() does?
>
> If an inode holds CEPH_CAP_XATTR_SHARED (for example on a replica MDS cap=
,
> on a session without CEPHFS_FEATURE_QUARANTINE, or after
> CEPH_CAP_AUTH_SHARED was released) while ceph_inode_quarantine_state(inod=
e)
> returns CEPH_Q_CLEAR, omitting ceph_quarantine_head_needs_revalidate(inod=
e)
> allows __ceph_getxattr() and ceph_listxattr() to serve cached xattrs and
> POSIX ACLs without consulting the authoritative MDS.
>
> [ ... ]
> > @@ -1319,6 +1343,34 @@ int __ceph_setxattr(struct inode *inode, const c=
har *name,
> >               goto retry;
> >       }
> >
> > +     /*
> > +      * XATTR_EXCL applies the new blob with no MDS round trip.
> > +      * The state check may schedule, so drop i_ceph_lock first.
> > +      */
> > +     if (!checked_quarantine) {
> > +             enum ceph_qstate qstate;
> > +
> > +             spin_unlock(&ci->i_ceph_lock);
> > +             qstate =3D ceph_inode_quarantine_write_state(inode);
> > +             if (qstate =3D=3D CEPH_Q_UNDER &&
> > +                 ceph_inode_quarantine_direct(inode)) {
> > +                     ceph_buffer_put(old_blob);
> > +                     old_blob =3D NULL;
> > +                     if (lock_snap_rwsem)
> > +                             up_read(&mdsc->snap_rwsem);
> > +                     err =3D -EACCES;
> > +                     goto out;
> > +             }
> > +             if (qstate !=3D CEPH_Q_CLEAR) {
> > +                     ceph_buffer_put(old_blob);
> > +                     old_blob =3D NULL;
> > +                     goto do_sync_unlocked;
> > +             }
> > +             checked_quarantine =3D true;
> > +             spin_lock(&ci->i_ceph_lock);
> > +             goto retry;
> > +     }
>
> [Severity: High]
> When __ceph_setxattr() takes the goto do_sync_unlocked path here while th=
e
> inode holds CEPH_CAP_XATTR_EXCL, can the local xattr cache become stale o=
r
> overwrite the synchronous update on a later cap flush?
>
> __ceph_setxattr() only reaches this check when ci->i_xattrs.version !=3D =
0 and
> issued & CEPH_CAP_XATTR_EXCL is held, after __build_xattrs(inode) has
> already built ci->i_xattrs.index.
>
> Jumping to do_sync_unlocked calls ceph_sync_setxattr(), which only sets:
>
>         req->r_inode_drop =3D CEPH_CAP_XATTR_SHARED;
>
> It does not drop or flush CEPH_CAP_XATTR_EXCL. When the MDS reply arrives=
 in
> ceph_fill_inode(), issued is computed from cap->implemented |
> __ceph_caps_dirty(ci), and the xattr update is skipped whenever
> issued & CEPH_CAP_XATTR_EXCL is set:
>
> fs/ceph/inode.c:ceph_fill_inode() {
>         ...
>         if ((ci->i_xattrs.version =3D=3D 0 || !(issued & CEPH_CAP_XATTR_E=
XCL))  &&
>             le64_to_cpu(info->xattr_version) > ci->i_xattrs.version) {
>                 ...
>         }
>         ...
> }
>
> Unlike __ceph_setattr(), which explicitly applies setattr_copy() after a
> forced synchronous request when exclusive caps are held, __ceph_setxattr(=
)
> leaves the old blob and ci->i_xattrs.index intact, and if
> CEPH_CAP_XATTR_EXCL was already dirty from an earlier cached setxattr, th=
e
> subsequent cap flush will encode the stale RB-tree and lose the synchrono=
us
> xattr modification.
>
> --
> Sashiko AI review =C2=B7 https://sashiko.dev/#/patchset/cover.20261025T18=
2649Z.ca9ae7a18449.git.amarkuze@redhat.com?part=3D5
