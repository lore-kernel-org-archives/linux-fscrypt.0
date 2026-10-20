Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792500776;
	b=aD2725Sg29zef5B3Ihp/sqw22LXQCvFclnVSHRVOXGgpAJKruBbE1/wVi2X078tq0/9+
	 WItTYNkUuzUlbZl0XQjYea8LhwYheBvUPqXOskySlcJJwUBWl40+Wtz7Qlbk2WJ+pITJa
	 7xIrkp4wIswoOOOZSZN3Hg/28Bs93hRcaGBNo5ONAzfeiwIZeXgXAg5mR/EDNTB8YGGkU
	 xR7OadQeiUczvlwxdb5gfEMi2iMulgpqU+DqW7CPuTWde/9SWlPVn3X4Gy89tXj09x4Ab
	 pvawv6yHwueyPRIDEp/dwPkc3ZsWpvK6ShEgyXYnQOoGCiTtTt4goFp5Rf/5jF3H7TQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792500776;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=/4u1vmaSqipBM0zxv3OAa4p5s287MyrcxTiYmzVTx/k=;
	b=ImvcaFW+dyez/jDKw9tZuLGrWbMaiz41vVd52tPLXXnUxOtSBmO2pKMsx8qZqXSFwsic
	 KWQfV/doYlL/3PMOQze0wI+WWKTneBJLYIE5MWcsYxPEeYvJh9N65yJELGVwRzvTx6tCk
	 vvOb5rrrkW2wze4ts85QckeK1aKq/LDArrEiWA58FGBEgYGdipmxPYUbV3Y3hdkUjNJ8L
	 b5z5gG34THcc1mlc856u2h0S+IaB1vL6p9yfbylJobEJOemnZbVxr3XOg5292s0HDoQ5F
	 T9H5P6xbLQx5fmnIp2dPN8ZWLdS6vX53AY64jYaJ2uaFfubteNpZWNT0VCygDjQT4jQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Yu6qNd1M;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=JA+2g4IK;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4BF2860A2602
	for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 12:52:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4BF2860A2602
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Yu6qNd1M;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=JA+2g4IK
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792500775;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=/4u1vmaSqipBM0zxv3OAa4p5s287MyrcxTiYmzVTx/k=;
	b=Yu6qNd1MqZskuVL53PVRAURxCskbEvlXeF1IriWvCtJm7W+5Q2qBt9eQvV/RNxHU4dVgXs
	HhE6MmOHmpo8KD20SDMCCx7xxfASBnpvk6Od5H7QH9v2W/4+ZLm/jMMRQMfYx+q80io2wj
	/9y1EUZFqPzAqB5zmUaQCONoIDsBvRY=
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com
 [209.85.208.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-554-I5lufdRINu-e0ChyYBzZ0Q-1; Tue, 20 Oct 2026 12:52:41 +0000
X-MC-Unique: I5lufdRINu-e0ChyYBzZ0Q-1
X-Mimecast-MFC-AGG-ID: I5lufdRINu-e0ChyYBzZ0Q_1792500760
Received: by mail-ed1-f69.google.com with SMTP id 4fb4d7f45d1cf-6b1a4c9eadeso3108627a12.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 20 Oct 2026 05:52:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792500760; x=1793105560; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=/4u1vmaSqipBM0zxv3OAa4p5s287MyrcxTiYmzVTx/k=;
        b=JA+2g4IKo1TpGTA0gXPRIyNRyC4/A95C2h9G8LbDi/kNLz/YZijJfR9D24SfengdgI
         wM0HcIpHAyqvXQjr+YMZa6onoQl1o980Nys5bJ1ZaHZtCfUNsuGd7YOPkqIke4T/fUU0
         3ANrxBXbesNuVmXU6KRqqF6BY1uyrL/ksjS4zifrlB+35OnqgFGUh+tiCgcXOiU7YAmQ
         Xulq+HU4UtsHtdqEVe+enpi+SMk7FgHe/kC8uUXr/LzkmbiareBGL5pk0f/Z5rQpM2N/
         /6Ktt3H7FjKUqshLaJE1wXiZZ7BJvYAFWKSp+NvQOB1Q/KYQ6mhh8EoiMEjzg0hvC2U/
         ml3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792500760; x=1793105560;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=/4u1vmaSqipBM0zxv3OAa4p5s287MyrcxTiYmzVTx/k=;
        b=Ufrjp6tRLRT8w75t8nILhX9IecmdGrZH5CUtwHAEukGtzuBVrEpRlHa658+NAXN6mm
         kayyXOYAAh7PLDXUu2Hak1URxiAJ4TBJOwOsxED+Hn3Ab12ozzZffLxGGHntVtMvDFrX
         PWFwsHkfSxJ0j2fl5z7b42Et7B19Lqck1PloxgEhh9zFVZKZwV5v6FcnFrEheZRXh4Ja
         7RvXHh/WtMhgwdRvrbLegyUqi16NyUUpy/YVsC4mESRsNPPtAkKMEKEVOFRgIwlJBlCG
         46r1mGu7BZOXY/ivLdmmUwI0bsZ8TnbZpRxtNGWB7IdOMfirySvO2LWgmlQ1Aw5tmyqV
         TAMQ==
X-Forwarded-Encrypted: i=1; AKwUvBzQjAS3dD/Af1Z67RDvMEnIWF8A34jssIbFXyZqf73cips3hoXRBoEoVHOnC95M2LFzFha1TFVPKGXATwPH@vger.kernel.org
X-Gm-Message-State: AFq9FYKU+cq1fIs4o9GMLjrSRmCgGeIO9gu4+PwnXN0G8IKWiZUr+N0m
	WOqPFeOFkAOwBrX03QmxQ0r5bTcqh42Gp2FdQPhLGas2Kecu+blhHXNff0G+AfW8VVng1YBGwtQ
	mFz3lbUG9/aQSqKTDpUfVHqb6sVc5bD/Gu059YuEPaB2VY8Hvft7zCBhuPfT5u+paltA=
X-Gm-Gg: AYBFou0PpN67qd/WG257l+QgVxa0Lx67rtSf28JiSVdSI2waBC5y4sd3hHzZNSvRFp7
	GZultz3sKOteZgcf5tPHMzfbcdD/1GRIJJ5iDPiB7J/YEHFes5kGql5jbE2yFhfwZivP4vR77W3
	G3f7jbRc3B5MuFfKg3a9CwclCC0oEBMpCeOpfPlJnG2kZwVpD9Xo2zovxGyBDvWNobtszDoHw5G
	yLvrS8LE2MG4lf1HuyYokshkv9k2vExexJXTVXrjz/y1vm0gntjf0lYRgbHEbuy4sfZ0w00RanN
	2gSCYtS7iLoIE+7YZMANF3RRrWMCcZ3XWfuXKksNYLbJ0wUxsMzeNYpHcZKGIfI9FQ3TN5c/HyS
	GxMhOcb2Stc735KpkWlkEesLzpUuTqELLHcWYYOLOJ8EdzDKlCG2gvC8WbBt4NQF2DDWEv2yf1Q
	i/0+mC+4g2Fg5D0P/ttHYIZH9tUR+OQHOq8p56koCKj/V/cxLSc01Sf6DyitEE36/6LDzwOMhmn
	iw=
X-Received: by 2002:a05:6402:11d1:b0:6b1:c5c3:9624 with SMTP id 4fb4d7f45d1cf-6b3a819086fmr6835223a12.22.1792500760228;
        Tue, 20 Oct 2026 05:52:40 -0700 (PDT)
X-Received: by 2002:a05:6402:11d1:b0:6b1:c5c3:9624 with SMTP id 4fb4d7f45d1cf-6b3a819086fmr6835205a12.22.1792500759746;
        Tue, 20 Oct 2026 05:52:39 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6b3c74eb8a7sm2982781a12.2.2026.10.20.05.52.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 05:52:39 -0700 (PDT)
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
Subject: [PATCH v4 0/5] ceph: support subvolume quarantine
Date: Tue, 20 Oct 2026 12:52:32 +0000
Message-Id: <cover.1792498351.git.amarkuze@redhat.com>
X-Mailer: git-send-email 2.34.1
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

CephFS subvolume quarantine isolates a subvolume while allowing recovery
clients with q/Q MDS auth caps to access it. Advertise support only after
cached data and metadata access paths can enforce quarantine.

This v4 combines the fscrypt symlink-cache prerequisite and the Ceph
quarantine series as requested by Eric and Xiubo. The dcache export is
retained. The generic fscrypt change precedes the Ceph patches, and its
Ceph opt-in is folded into the patch adding the get_link checks.

Changes since v3:
- Disable only the two fscrypt symlink-cache writers. Leave cache readers
  unchanged and update fscrypt_symlink_getattr() kernel-doc. Explain the
  held O_PATH descriptor / empty-path readlinkat() bypass and the allocation
  and decryption cost of uncached encrypted symlink accesses.
- Avoid unconditional snapshot RPCs only when the connected head inode is
  the target's actual subvolume root, identified by its nonzero MDS-provided
  subvolume ID, with a valid AUTH_SHARED cap from a quarantine-aware MDS and
  no local quarantine marks. A snapshot P/.snap/S/V/file cannot use ancestor
  P's cap to authorize access in V. Synthetic snapdirs inherit their parent's
  subvolume ID. Unknown IDs, other head ancestors, expired root caps and
  disconnected snapshots retain MDS checks. 32-bit clients also revalidate
  because membership IDs use plain 64-bit READ/WRITE_ONCE accesses.
- Wait interruptibly and retry unstable namespace generations or MDS
  authorizations in blocking cap acquisition and revalidation. Preserve
  nonblocking behavior. Track splice owners and reject recursive LSM hooks
  with EBUSY, including hooks outside MDS reply processing.
- Gate ACL cache suppression and namespace mutation bookkeeping on
  negotiated quarantine support. Invalidate older cached ACLs when support
  is first enabled and pair namespace tokens across that transition.
- Remove the impossible NULL d_parent guards raised during VFS review.

Validation:
Nine deterministic source-extraction regression runners pass, including
ASan/UBSan/LSan checks of VFS readlink and fscrypt target ownership. A warm
same-subvolume-root snapshot harness performs 1000 getattr calls, 1024 read
authorizations and 52 snapdir checks without an MDS RPC. A depth-300
harness completes 20000 blocking revalidations with injected namespace
splices without EAGAIN. Additional cases cover feature activation, ACL
cache invalidation, old-MDS caps, detached snapshots, epoch/rename races,
interrupted waits, recovery permissions and stale cap messages. The ancestor
snapshot regression fails on the earlier v4 draft and passes with the fix:
zero local marks and a valid outside head cap still require per-operation
MDS authorization for reads, cached stat and xattrs. Unknown IDs, non-root
head caps and 32-bit clients also retain MDS revalidation.
A complete W=1 kernel and module build passes with GCC 14.2.0 and the
normalized x86_64-rhel-9.4 robot config: vmlinux, bzImage and all 2233
configured modules, including ceph.ko and libceph.ko. MODPOST succeeds,
and the GPL d_find_alias_rcu export resolves. Additional W=1 builds pass
on x86-64 with ACL/encryption enabled and disabled, and on i386 with
those features enabled. All five patches pass strict checkpatch and
apply in order to reproduce the tested source tree.
These are source harnesses, not live CephFS benchmark results. Live
cluster, KASAN/lockdep, failover and snapshot throughput tests have not
been rerun for v4. Xiubo's v3 runtime results are separate evidence.

Remaining protocol limits:
Already installed snapshot PTEs still need server notifications to revoke
access without a new filesystem callback. Snapshots without proven coverage
by a cap on their own subvolume root, and all 32-bit snapshot operations,
still authorize each operation through the MDS.
Disable messages carry no generation, so same-rank ordering relies on
ordered delivery. Overlapping ordinary rw and q/Q grants still require
server-side auth-cap filtering; Xiubo reproduced that with ceph-fuse too.

v3: https://lore.kernel.org/r/cover.1792248177.33a6e2db0a.git.amarkuze@redhat.com/
v2: https://lore.kernel.org/r/cover.1792074165.git.amarkuze@redhat.com/
fscrypt discussion: https://lore.kernel.org/r/a01d0a297a3e174d21741a3ad586ce546327603e.1792081664.git.amarkuze@redhat.com/

Alex Markuze (5):
  dcache: export d_find_alias_rcu() for modular filesystems
  fscrypt: allow filesystems to disable symlink target caching
  ceph: add subvolume quarantine wire definitions
  ceph: record subvolume quarantine from MDS cap updates
  ceph: fail quarantined subvolume access with EACCES

 fs/ceph/acl.c                |  33 +-
 fs/ceph/addr.c               |  72 ++-
 fs/ceph/caps.c               | 317 +++++++++++-
 fs/ceph/crypto.c             |   1 +
 fs/ceph/debugfs.c            |   1 +
 fs/ceph/dir.c                |  54 +-
 fs/ceph/file.c               | 112 ++++-
 fs/ceph/inode.c              | 919 ++++++++++++++++++++++++++++++++++-
 fs/ceph/ioctl.c              |  13 +
 fs/ceph/mds_client.c         |  28 +-
 fs/ceph/mds_client.h         |  30 +-
 fs/ceph/super.c              |   4 +
 fs/ceph/super.h              |  99 +++-
 fs/ceph/xattr.c              |  54 +-
 fs/crypto/hooks.c            |  28 +-
 fs/dcache.c                  |   1 +
 include/linux/ceph/ceph_fs.h |  13 +
 include/linux/fscrypt.h      |   7 +
 net/ceph/ceph_common.c       |   2 +
 19 files changed, 1676 insertions(+), 112 deletions(-)

