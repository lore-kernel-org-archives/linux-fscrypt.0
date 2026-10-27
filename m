Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.44
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793105105;
	b=cuK14QdeggcLwICt7e7koDuqb7ki/84qN8qN5f0Ib9oRtwxje288DIpPJbpSQYqt1Sg/
	 3DY7Kl3O/jw+QM9QomjyQqVJ8D87g+Ey/HaOot6rTZNKtxO2cOTQq+5yPMDkk7BiI06FO
	 e59ozkUGw8QrQcIOnEA00BxqwEj9dfENHZfy/TJdMGkdYfF3Fc+hdNbBD3YpDnslX4zuA
	 TKiL5pe+aC2Q0sdFjwXWBxXs/G8SryJlpGqh586Bvm7sV9NYAxBxfgm6u+dtstjrRSzpx
	 f+DZeuZH4plD0pAspYTxF+h/+JME19jJFuPbjkFwJoUYA2r5KTcgqGNTxJNHjRHZ6Fw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793105105;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type;
	bh=tp5Z/PycBAJg9TMmmwDWZ/1o8EUvDrLUX04tXR+wyv0=;
	b=c1SN+ODYzINqOkHScN/jPy5xuJR3vG2l1ExG1cDI/7GY6Mhbltsj+P0CdA7/jo3I39cY
	 m6PyO58pAcy0L/CREa2LcY0LQjCL1ajeR/a0+z9P5Giop9hKx2AY9cp73Z1aTUXbcY2Va
	 19rAgHH9Qwq3EZZn8ZdPzKZkHt/Wp6XaGbx1j2JpBo1VI+QDsEF3tQA5GQ1UcJnL8LXAp
	 d/q1eA6w8ZyERbfvoncNdj4hpQBiOLeBYenahm4s06bPgdWiU8cIqCAheHGZR7k29EJKx
	 ROdEYYZgrWhza5gYJJiFVaE5geMXZt19gbbMzhbU06sYhoAAQZOg5Ds5EmGwjHE1iJA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=clyso.com;
	spf=pass smtp.mailfrom=clyso.com;
	dkim=pass header.d=clyso.com header.i=@clyso.com header.a=rsa-sha256 header.s=google header.b=fYGlF2xZ;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.44
Received: from mail-ej1-f44.google.com (mail-ej1-f44.google.com [209.85.218.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D850606A334
	for <linux-fscrypt@vger.kernel.org>; Tue, 27 Oct 2026 12:45:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3D850606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=clyso.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=clyso.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=clyso.com header.i=@clyso.com header.a=rsa-sha256 header.s=google header.b=fYGlF2xZ
Received: by mail-ej1-f44.google.com with SMTP id a640c23a62f3a-c4677aad67bso429040666b.0
        for <linux-fscrypt@vger.kernel.org>; Tue, 27 Oct 2026 05:45:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1793105101; cv=none;
        d=google.com; s=arc-20260327;
        b=Y7Uq42qKnHUHdfXtirDtysEVmvbRpKbPU73quTHRilz8zzi6XpqMUwuR/A69kN8QOX
         VJ0i8HvtTX/tYFgEP/qp23In87ZCLzu5241mBM6gFAlv1/JtDXYe8JVIsgrrstckGe72
         xUTOZE9WLOoLtaVezzwm172fcq0TmqInu6mTSuU/KmCzg3+U3m/B5F9z5k043urglHck
         2ep5VEUrnaHwyPi37z0neetOdK9YtBtECcYEJ0TH3n3Z3W2C7/EW8QEE8A4tgnL9iCmq
         Zwp41dcyyiLMGVsf6HwIRufK15E9bdqVHssCPclo0YVTamNYSM5ju6CyvHNh4m5Ohhxo
         2WmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=tp5Z/PycBAJg9TMmmwDWZ/1o8EUvDrLUX04tXR+wyv0=;
        fh=xlzvY62m57hDTnPIaX0uGBaw51SmopAmVek9y+VXkec=;
        b=fFsI01ZmgeBKQsGvQnQy8RgikUR20bniTej+oIqP9r++zGtz86u4bFAXn2d9ehQykI
         +fbQat8Cbdyt35L4TNpjxQ0E6fz1mE/ahZS7B0tJWVRHGFSpmgZphpGRXU1A+RtjFIir
         z5cIMYxWTU4N1TAVYO+rPyY69pJVXuGvm6RyFDn95fpFpUlGtSFEs9PBn6Av0X9qF4l8
         Eoa+/zABkIbYKvbLxHKzc7TgOhYW5v6LOM2H+uz3eB36Yl3u/lohnpt50an9qER/t7nj
         qi2zIUHP6wqYmqbL4GqyMBO8BIdnDKLxfXHoQVA3RbZSR+M2z4GB3w2wpcg62Uiy0otN
         XdXw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=clyso.com; s=google; t=1793105101; x=1793709901; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=tp5Z/PycBAJg9TMmmwDWZ/1o8EUvDrLUX04tXR+wyv0=;
        b=fYGlF2xZvMKZpXD35R3nsX3JNM8VYluoq0Sj5pX1aaLxFpGjyWGA43KLCVb2+L9ohT
         3AEYCqTkA7WblXENEhH2k+nw0OAYFhNUcjuSClCZgJumuylOegdtXosZ4pDVkyS6L1Db
         z/ewE+Sw5R165rqd36h2P2En56J8ih29CGIN6QKqlROosTvZ+ugDhzAA70CDkShIpFoT
         ySjqyqzy7o4YsQx0o9MM6OXqjIM6EX+pi9ZsNDiiF4Sl6l2GlS86ZeN9Ufi1kpsoEsnL
         G0xiTzsEOoMawiz7LwRXR5MsYFw7HUhYbicJXk7PCZJbx8R24ZeZu8BE1lVg3cMMTUKb
         vcxA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793105101; x=1793709901;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=tp5Z/PycBAJg9TMmmwDWZ/1o8EUvDrLUX04tXR+wyv0=;
        b=rWKSBIzKEdx1NRQDGnAjcqTizFWutl4qn8Q5EcqS13vDuUYiNwEEvbMs/sFti8m16s
         ZCwsfHwivakmnHy1Ey7ky5g0Qe/or3mBQzPoya2gtxKJ9FEd8dqusSdlx/jAX47JBfbL
         1Wu8vWqzTpmHkB7iOsGZr36CN+iNMsla4/O8PAJOtOnkklaXilTjyRnfeYGGz4AIZtK5
         K0Fvnpz0XMnG6dwne4SI6RghLcgL6ZZXxSX+5F66T5DBnHCe3jL/jXLgjCVnXgq+qnCk
         v4w2hxDproxgBjzhQP6t3pX5+KRblxdm3EFOrkEnvuez/Z2odZfbwRqJz/PmsYlW0Im+
         KsQg==
X-Forwarded-Encrypted: i=1; AKwUvByW4da5ccx+PYa4rcYGp2p3QwSNTT9LLoRxnkzXGBW08nzymWfgldoQY/gkN7eRKbOt87rMQuYokCYPt6kr@vger.kernel.org
X-Gm-Message-State: AFq9FYI27Y2/w4DKS1Ynxny9kjb0FL4XlwDeTwC6fF/m4tJ9R/6x+lT1
	ALMv0cbsm6MCvmqeiPCONpAOnpvrl03ItYL27fy9T33pedn6mw/lLpjDydBw4Yoij99XQJGAwXU
	A0BF/FDRBU5d83G0vBtdlDlUFvleLr9p+OM75SO4/Qg==
X-Gm-Gg: AYBFou1XA1kQTWq/xV33aVgNNVZTYeQLFaEe3YySyFptZMDrZNEWBgDlApOW0bXphrk
	iNxgWfyRHHPvOqH7y9dw3MI8ZuchszskjSZKag9V047O/H/HhAy9+2o3AGI3q/Yx4z6bsB8ukq4
	jjhjDQ7sWWGRs+Y6GYBFy+OtXI/vU8DeyAWeO21jNulfs1ql0PU7P0IZeoOo+RoaYPu8a/upDRg
	9cS+Re5v9j/SqxomUQszKUFiUuDLBIQqRXW6PpeyNncqTb+gme05txCnS5UsqHytTdrVAJBrWRN
	J687byq4GZqWKjYx/iNHNQIx9H0nVME4msvjt7iWmeea/5W2gd0R0ZjGYgt6n59P4/aGhAPOAZN
	vj1eHWN+tD0edqIRf95WvrHPsbet6zK9p9K2PVDg=
X-Received: by 2002:a17:907:3d56:b0:c46:2987:2156 with SMTP id
 a640c23a62f3a-c46bde530a6mr1170312866b.29.1793105101334; Tue, 27 Oct 2026
 05:45:01 -0700 (PDT)
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
In-Reply-To: <cover.20261025T182649Z.ca9ae7a18449.git.amarkuze@redhat.com>
From: Xiubo Li <xiubo.li@clyso.com>
Date: Tue, 27 Oct 2026 13:44:28 +0100
X-Gm-Features: AclHuK-ojbEjvM3prTzqiHVXlqJdtBT0a5aS99YgrWUgj8YCYdBw1ESDVDxY2OQ
Message-ID: <CAOJNxRKQETQbti6Rgdeekkuo+GAT1xHOvt-G8YvoHsLeDbcP_w@mail.gmail.com>
Subject: Re: [PATCH v6 0/5] ceph: support subvolume quarantine
To: Alex Markuze <amarkuze@redhat.com>
Cc: ceph-devel@vger.kernel.org, idryomov@gmail.com, slava@dubeyko.com, 
	viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz, 
	linux-fsdevel@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	ebiggers@kernel.org, tytso@mit.edu, jaegeuk@kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Hi Alex,

Thanks for v6.  I tested it on a KASAN + lockdep.

What is still slower with no quarantine at all (the MDS supports it, so
quarantine_supported is set):

  1. Non-owner path walks.  Every inode gets ACL_DONT_CACHE, so root,
     other users and group access pay ceph_get_acl() on every path component.
     d48 stat is 47% slower.  See 5/5, acl.c and ceph_set_ino_cb().
  2. Owner path walks.  __ceph_do_getattr() takes i_ceph_lock twice per path
      component.  d48 stat is 9% slower.  See 5/5,
ceph_quarantine_head_cap_valid().
  3. Snapshots outside a subvolume.  Every read() and stat() goes to the
     MDS.  See 5/5, ceph_snapshot_has_path().
  4. Async create is off whenever the inode has an LSM blob.  See 5/5,
     ceph_atomic_open().

All four can be fixed without weakening the quarantine checks.  My
reply to 5/5 has the diffs I tested, each under the code it changes.
"v6+fix" below is v6 5/5 plus those four diffs.  With them, the numbers
are back to base, and my quarantine tests still pass, plus new ones for
each change.

Benchmark method, for every table in this thread:

  - ABBA order, 12 rounds: base v6 fix fix v6 base base v6 fix fix v6
    base.  Each variant runs 4 rounds of 20000 ops, 80000 pooled.
  - One Python process repeats one syscall and times each call with
    perf_counter_ns().  It is pinned with taskset to a vCPU on a P core.
    Without the pinning, the hybrid host gave bimodal results.
  - The VM is rebooted before each campaign, because module reloads
    eventually exhaust lockdep and turn it off mid-run.
  - Paths:
      d48 = /mnt/qa/outside/pb/d1/.../d48   (48 components)
      d5  = /mnt/qa/outside/pb/s1/.../s5
      mount -t ceph admin@<fsid>.a=/ /mnt/qa \
            -o ms_mode=prefer-crc,noshare,nowsync
  - "owner" runs as the uid that created the directories.  "non-owner"
    runs the same loop as root, so acl_permission_check() falls through
    to check_acl().

Non-owner, latency in us:

  test            ops/s   p50    p90    p99   p99.9   max
  d48 stat
    base           7422  140.4  153.0  225.5  2174.8  6176.9
    v6             4909  206.5  216.8  290.3   877.5  2918.2
    v6+fix         8238  141.4  162.6  217.4   718.4  2132.9
  d48 symlink stat
    base           7334  143.3  153.2  190.7   359.2  2450.1
    v6             4968  210.3  221.1  279.6   777.0  4999.7
    v6+fix         7238  145.6  155.4  190.8   463.8  2456.1
  d48 readlink
    base           8482  138.5  148.3  174.6   307.1  1972.1
    v6             5046  205.0  214.8  267.3   389.2  1020.8
    v6+fix         7624  141.0  150.7  184.3   311.5  1233.9
  d48 open+close
    base           3826  257.6  277.1  912.5  1842.6  9565.7
    v6             3026  323.3  346.3  975.5  1721.0  3465.7
    v6+fix         3685  259.6  277.8  926.3  1755.6  2680.5
  d5 stat
    base          59504   15.3   17.6   32.7    51.3   565.1
    v6            30720   42.0   42.9   52.9    78.8   662.5
    v6+fix        48144   15.6   32.6   42.1    54.9   445.7

Owner, latency in us:

  test            ops/s   p50    p90    p99   p99.9   max
  d48 stat
    base           7514  141.7  151.7  195.2   968.1  1719.4
    v6             7393  154.4  164.5  202.9   739.2  1972.5
    v6+fix         7695  143.0  152.8  189.4   809.2  1747.5
  d48 symlink stat
    base           6887  145.2  154.9  200.9   335.3  2198.3
    v6             6409  159.3  169.8  215.4   348.4  2254.7
    v6+fix         6605  147.2  157.2  209.1   331.1  2132.3
  d48 readlink
    base           6907  141.1  151.0  206.8   319.1  3761.8
    v6             6350  154.2  164.3  229.1   373.0  4344.2
    v6+fix         6801  143.0  153.0  207.9   319.2  1511.6
  d5 stat
    base          35110   32.0   32.7   42.8    74.3   926.0
    v6            28277   34.6   37.2   45.7    75.5  1399.8
    v6+fix        30807   32.7   33.8   44.2    87.6  1388.9

pread is unchanged in all variants.  The owner numbers replace the
"symlinks and cached dentry lookups" section of my previous mail.  That
run did not pin the benchmark process, so plain stat looked like noise
there.

Snapshot test (plain directory, not a subvolume; 4M file, 52 entries),
MDS requests counted with kprobe:ceph_mdsc_submit_request:

                         base             v6                 v6+fix
  read4k (x1024)         8 req, 0.14 s    1041 req, 0.91 s     9 req, 0.16 s
  stat x1000             0 req, 0.07 s    6000 req, 4.49 s     0 req, 0.11 s
  ls -l                 59 req, 0.12 s     950 req, 0.74 s    60 req, 0.12 s

Async create, 500 O_CREAT opens on the nowsync mount, counted with
kprobe:try_prep_async_create:

  base: 500    v6: 0    v6+fix: 500


Thanks,
Xiubo

On Sun, 25 Oct 2026 at 19:42, Alex Markuze <amarkuze@redhat.com> wrote:
>
> CephFS subvolume quarantine restricts ordinary access while allowing
> recovery clients with q/Q MDS auth caps to operate. Add client support
> for quarantine notifications and enforce them on cached access paths.
>
> Based on the testing branch of https://github.com/ceph/ceph-client.git,
> commit ed0502cb11f8 ("ceph: validate encoded xattr name lengths").
> The full base is recorded below. The dcache and fscrypt prerequisites
> are included in this five-patch series.
>
> Changes since v5:
> - Describe the dcache export as a prerequisite and remove Reported-by
>   and Closes tags for it.
> - Reject foreign, disconnected and unhashed non-root aliases in ancestry
>   walks while accepting the live, unhashed superblock root.
> - Reset quarantine state only when the lost or reconnecting session is
>   the reporting MDS rank, including when its cap is already absent.
> - Check saved authorization's generation even when no inode is marked.
> - Check snapshot path access and acquire normal wanted caps after
>   quarantine authorization.
> - Clear detached xattr-buffer ownership after releasing its reference.
> - Use synchronous CREATE for new inodes with an LSM security blob,
>   before async preparation, including before feature negotiation.
> - Keep an existing quarantine mark across a zero-error IMPORT while
>   processing imported caps and negative quarantine errors normally.
> - Use the incoming wire cap mask for clear decisions, so PIN-only updates
>   cannot acquire clear authority from capability bits retained in a merge.
> - Update encrypted-symlink and capability comments to match their
>   interfaces.
>
> Validation: GCC x86_64 builds with fscrypt, ACLs and security enabled
> passed W=1 vmlinux/modules for the final tree and the recording patch.
> Twenty-six extracted-code quarantine state tests passed, using mocked
> kernel context. Live cluster, boot, KASAN/lockdep, LSM policy,
> failover, performance and LKMM validation have not been run.
>
> Previous submission:
> https://lore.kernel.org/r/cover.1792527529.git.amarkuze@redhat.com/
>
> Alex Markuze (5):
>   dcache: export d_find_alias_rcu() for modular filesystems
>   fscrypt: allow filesystems to disable symlink target caching
>   ceph: add subvolume quarantine wire definitions
>   ceph: record subvolume quarantine from MDS cap updates
>   ceph: fail quarantined subvolume access with EACCES
>
>  fs/ceph/acl.c                |  33 +-
>  fs/ceph/addr.c               |  72 ++-
>  fs/ceph/caps.c               | 323 +++++++++++-
>  fs/ceph/crypto.c             |   1 +
>  fs/ceph/debugfs.c            |   1 +
>  fs/ceph/dir.c                |  54 +-
>  fs/ceph/file.c               |  82 ++-
>  fs/ceph/inode.c              | 956 ++++++++++++++++++++++++++++++++++-
>  fs/ceph/ioctl.c              |  13 +
>  fs/ceph/mds_client.c         |  26 +-
>  fs/ceph/mds_client.h         |  30 +-
>  fs/ceph/super.c              |   4 +
>  fs/ceph/super.h              | 101 +++-
>  fs/ceph/xattr.c              |  60 ++-
>  fs/crypto/hooks.c            |  28 +-
>  fs/dcache.c                  |   1 +
>  include/linux/ceph/ceph_fs.h |  13 +
>  include/linux/fscrypt.h      |   7 +
>  net/ceph/ceph_common.c       |   2 +
>  19 files changed, 1706 insertions(+), 101 deletions(-)
>
>
> base-commit: ed0502cb11f84fff29f374238e526ae94d9bdfde
>
