Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792953772;
	b=wK79uNzf5NDzniKfWIOjejbONVlm9DPPSG7fz885/oxDSybh89W5TY36d8u2fzIiHcX/
	 jdrqBruIzl9nteXlYiLJbwy0lgSX10E2OAtskTQAHskN7/mjgLeg21n5WOaxX87JFU2k6
	 ITUoU0xZSbyuqxXswA2bYLDrZ4dXaY9RMVQ9y/grDqknWXvWVZV9/eBFBQdfwpj0GBWpp
	 QmWnmq09Y1cvLrXezHuXe7lj9boqL7NGvCN/St4613xsxteogm78TWxS37Q04ddkT0V8r
	 fgBm/wtM4lNwqbZyINrtIXp2M950XoO2l/UQJ5vPxhQ1MotDH+D4gkPC7tB/yhSCacg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792953772;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=N1DCLvfOjDC42wmhEz6PCJeC1Bo8We6n6LwkJZv/JOA=;
	b=ozuMeoIYuFuVTKb6RJWwpEHavVRKixyDANrkHRi7nSDz7CUvUehgyeDPrLwvIL0y524Z
	 6mXnbhWzFBhQaCiZq+qATTH/Fya+5pEIVHUU+UCe9gDsCgUqQljtPnmk0vtabLL9fDE4x
	 VSTlPvd8GK8edqeFd2OwZpViOWhIsbsOs9KEq12tXdblBjDgFO6Tat/GG+lb2pW4lTz1D
	 dQ1oCj51PPpwyyRB00oAWIEYeIEswt3LVwDqt4p75IYqa2gOX+XcU0SHDZS9IP4MLC/Fa
	 SZaBNKMvOOTeOetrIuiBuwMWNKRxy3o7WFlZDxSFdAfWV0mkIYOeMKYnGs8UtSDxXXw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Gw2Zf1wC;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=VZw9ic3X;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4C2E6606A31B
	for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 18:42:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4C2E6606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Gw2Zf1wC;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=VZw9ic3X
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792953771;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=N1DCLvfOjDC42wmhEz6PCJeC1Bo8We6n6LwkJZv/JOA=;
	b=Gw2Zf1wCHWvvt3YMia2Jm0NThtpgphKKYovnZ7Kg5icHbB6O4dvGjhJuSVJHVLxh3zxS4g
	zqiHhLYzOdrBMbYar7O6lbz870L9e6eF33HDc68nzIZXOvTPXlvH3b5edQuSObl8eZ9Shi
	IPBnKqDgDp1gDSA7BVb/KIbMpfHpPDc=
Received: from mail-ej1-f72.google.com (mail-ej1-f72.google.com
 [209.85.218.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-595-SvspgwY-Mn-lo7rrTEjhRg-1; Sun, 25 Oct 2026 14:42:50 -0400
X-MC-Unique: SvspgwY-Mn-lo7rrTEjhRg-1
X-Mimecast-MFC-AGG-ID: SvspgwY-Mn-lo7rrTEjhRg_1792953769
Received: by mail-ej1-f72.google.com with SMTP id a640c23a62f3a-c3613c35145so256372766b.3
        for <linux-fscrypt@vger.kernel.org>; Sun, 25 Oct 2026 11:42:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792953769; x=1793558569; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=N1DCLvfOjDC42wmhEz6PCJeC1Bo8We6n6LwkJZv/JOA=;
        b=VZw9ic3X3a7UhX7gS/PKYUJhJw/npTrWYwFh4PSVJR7FzwU17ojJ06OL19l6qe8gFO
         nnctHZTJEEcbPzvqTqhj42B8XmW4WCW8zbrZApyczMa1W6EWM8V9LqRai/luJEY4hh6c
         ecEMM6sSkwz7qIJ2c+ndDO1NIIWxo6Mii0YReNz0cU6RqG/HiMO7Fe+cv0ulcAaLGljy
         0KJwKOgRliIoyk6pfaponjJKgsoWxd0jaBByiGrqbKKqViFuuHXCygjTGYGcKakzYn0Q
         Wcoj8GtVkT9VQD8xdcQCkfxFWRZTANEPmTYnRorN3g1INy8GyKOmLQZtT7EaZyxLxlL9
         vCgg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792953769; x=1793558569;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=N1DCLvfOjDC42wmhEz6PCJeC1Bo8We6n6LwkJZv/JOA=;
        b=n/7uqvu7lCqGsGvu9gv4COB7S6fp3aoJi7vRASlJxHNHcQbFl/9yzqI83zu8Z4dhRn
         uk5n22X2nGiPIKj+LRjAJZtUUHg81a0d+fyrsUVsywwqm6ivfjNMY/JiU/imvtthhWxM
         1wY3t1YV37fr+UZhvaeKe+MC0gW+7Nk/qkg300WxG6/OaBGlkmLtpZGPrzIH7Sh/VLmc
         TeKlMZ9UaGpm/nX8LmKVfVSsBDvy6RjSusrZl/n7N6zPqoNuIhelQN4U/tf8/ogIV9Fy
         EGZpyja+edPBCjI+MnStVY14e80w2LeeVuzRpjD/JdWgEvHCgrtFQZC3z6H21Ad0pRGv
         cH8w==
X-Forwarded-Encrypted: i=1; AKwUvBzuNwCqd69i+vGKVdmKh8H/TIYsFMtLg6EccVl9/b6MiPbzkt4JzF1il6rkO+YUnKD+Eac3qBTg4sIDP+o/@vger.kernel.org
X-Gm-Message-State: AFq9FYLBdjEqLDRs537EEucMGoybOyAc+iYR1p0waE3COKrsrKTHWQUT
	O6PsV/mhEZbW6/JHUyfV+9Bjc2/6DvYLLTxQ4tvkE7N6j2tDjwxT09ynS+W/IP4BypVpKtL6m8B
	GGCR1XMKJv1VUz3+fRMQAk1ubE1yONPSdhplfuQnl/W/qmzgGVCKHtPW7E+AdqhouR7E=
X-Gm-Gg: AYBFou0O1sJ+ypvnj4VClE+K490r2r6jeVGeFN32+5UxpFsv6Jkk3KECr/yc6o3VTR1
	LlirewCA13Y9YL5VYwMn0R+FcccjnbwmMIpw9pR9gbZkqygV4Fvhv3HnMseXPSIsxdLSoEJjJs6
	6XlpMPnFOsn/ejAUOj4rlMcE6rsihOI6PdfyolJXJQhAYzIgOLUMXuOrblpMwmI5muCSd2QT/NP
	6vMEvRTGXfOlFBcNcCwVMrJtfpn6CMPrzhO2ajfmn6uSi8EKOOR2ROvjMaCilkH4QowaN1enJ63
	YgMBWqk1+4O/gLkow+6aa8Nf2rdxCJSDM3JXfi4Vvwk1S2bvz/tQC/GF+8+giwZvIV38u/sNFsI
	d5+0buQzjfzK4/k7uS6bRApJbfFns/2Z3HA6dUT43Yr6e8TDEK2bcmH6o0PnX8cB1jbZR1BMO37
	l38NwLS19QP7RA/YZpLPt2azpHw5faskZlPn82PkMbOU9AJPAMm/g9drL16XqkTAhgmRCuY8KVx
	N4=
X-Received: by 2002:a17:907:2d92:b0:c40:f9ea:7375 with SMTP id a640c23a62f3a-c46bddaed7cmr640680066b.15.1792953768780;
        Sun, 25 Oct 2026 11:42:48 -0700 (PDT)
X-Received: by 2002:a17:907:2d92:b0:c40:f9ea:7375 with SMTP id a640c23a62f3a-c46bddaed7cmr640678766b.15.1792953768403;
        Sun, 25 Oct 2026 11:42:48 -0700 (PDT)
Received: from cluster.. (4f.55.790d.ip4.static.sl-reverse.com. [13.121.85.79])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c46bd66e51fsm230750866b.64.2026.10.25.11.42.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 25 Oct 2026 11:42:47 -0700 (PDT)
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
Subject: [PATCH v6 0/5] ceph: support subvolume quarantine
Date: Sun, 25 Oct 2026 18:42:40 +0000
Message-Id: <cover.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
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

CephFS subvolume quarantine restricts ordinary access while allowing
recovery clients with q/Q MDS auth caps to operate. Add client support
for quarantine notifications and enforce them on cached access paths.

Based on the testing branch of https://github.com/ceph/ceph-client.git,
commit ed0502cb11f8 ("ceph: validate encoded xattr name lengths").
The full base is recorded below. The dcache and fscrypt prerequisites
are included in this five-patch series.

Changes since v5:
- Describe the dcache export as a prerequisite and remove Reported-by
  and Closes tags for it.
- Reject foreign, disconnected and unhashed non-root aliases in ancestry
  walks while accepting the live, unhashed superblock root.
- Reset quarantine state only when the lost or reconnecting session is
  the reporting MDS rank, including when its cap is already absent.
- Check saved authorization's generation even when no inode is marked.
- Check snapshot path access and acquire normal wanted caps after
  quarantine authorization.
- Clear detached xattr-buffer ownership after releasing its reference.
- Use synchronous CREATE for new inodes with an LSM security blob,
  before async preparation, including before feature negotiation.
- Keep an existing quarantine mark across a zero-error IMPORT while
  processing imported caps and negative quarantine errors normally.
- Use the incoming wire cap mask for clear decisions, so PIN-only updates
  cannot acquire clear authority from capability bits retained in a merge.
- Update encrypted-symlink and capability comments to match their
  interfaces.

Validation: GCC x86_64 builds with fscrypt, ACLs and security enabled
passed W=1 vmlinux/modules for the final tree and the recording patch.
Twenty-six extracted-code quarantine state tests passed, using mocked
kernel context. Live cluster, boot, KASAN/lockdep, LSM policy,
failover, performance and LKMM validation have not been run.

Previous submission:
https://lore.kernel.org/r/cover.1792527529.git.amarkuze@redhat.com/

Alex Markuze (5):
  dcache: export d_find_alias_rcu() for modular filesystems
  fscrypt: allow filesystems to disable symlink target caching
  ceph: add subvolume quarantine wire definitions
  ceph: record subvolume quarantine from MDS cap updates
  ceph: fail quarantined subvolume access with EACCES

 fs/ceph/acl.c                |  33 +-
 fs/ceph/addr.c               |  72 ++-
 fs/ceph/caps.c               | 323 +++++++++++-
 fs/ceph/crypto.c             |   1 +
 fs/ceph/debugfs.c            |   1 +
 fs/ceph/dir.c                |  54 +-
 fs/ceph/file.c               |  82 ++-
 fs/ceph/inode.c              | 956 ++++++++++++++++++++++++++++++++++-
 fs/ceph/ioctl.c              |  13 +
 fs/ceph/mds_client.c         |  26 +-
 fs/ceph/mds_client.h         |  30 +-
 fs/ceph/super.c              |   4 +
 fs/ceph/super.h              | 101 +++-
 fs/ceph/xattr.c              |  60 ++-
 fs/crypto/hooks.c            |  28 +-
 fs/dcache.c                  |   1 +
 include/linux/ceph/ceph_fs.h |  13 +
 include/linux/fscrypt.h      |   7 +
 net/ceph/ceph_common.c       |   2 +
 19 files changed, 1706 insertions(+), 101 deletions(-)


base-commit: ed0502cb11f84fff29f374238e526ae94d9bdfde

