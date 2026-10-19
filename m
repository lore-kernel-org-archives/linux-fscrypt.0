Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792425952;
	b=1KnQPUUZJk40ga1oF1roVsnDg6mfMSynMK2pTfH2A0hPIaw5+gbQb78oKcWnPvoyxe/o
	 EUxla+2PkfcSdBlPyiYzDOcR37oS1L6bz2Pj71AAl8pRujTas7KSH45xzBFgfc5ETfdqm
	 S9xOAwC31ONkLMZ9sZiHsSebG00wRsGzc1SUMyS35SvwzURkDOOxaRcF/rvrPKaI+rZZc
	 GDxrWvo3Fyb3q2EmdY/K1dpamUqDLBHXvZ3FpAtPKSVORv5HA2U4aRHMrfPLXexQxj6PB
	 VuXEB1q06gwjux+0Rn1c004Q9N6mDc3QOOOh+VzzuOqb3HLGtJybOEs8uBr594vUPLw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792425952;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=rJCzmqkUyBuAMTS2sRPCTNp4WMacGY+Q2zZ1Nvd28kE=;
	b=XzAzv52wWY68pNPDmr5PxPRJxJblJJq37sOwHN9DdES+cwDDn+KIMeOt7cdLW20J2Ozg
	 8gQBw26P3TzRg56HcVQpN5mZowhzp0xB69fPTTa+pNyfq+mklON+Mi3Ew0jFXErIiBvoc
	 UHhn6NVL1EFM7XAn2d5eWC1MS1+Z82fGYHT/xdDmFp3OGbwIYS4n9aS/877b/+Jj1GJ1L
	 tqGZ3K8ou0CywrQdBHkQAGcgp8/Euv0Ai7lY/CZKvFFx84hDXozyFSyRljGadQY08tUDg
	 re4zJC3xOpsHgggbAKwQWdvUTkPmNnb1ng1RdPW8DT5PcyD+lgCey6+6gj68l/nluRQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=hgJ3cPuE;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=p7w3l47y;
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E64E606AFAD
	for <linux-fscrypt@vger.kernel.org>; Mon, 19 Oct 2026 16:05:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8E64E606AFAD
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=hgJ3cPuE;
	dkim=pass (2048-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=p7w3l47y
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792425950;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=rJCzmqkUyBuAMTS2sRPCTNp4WMacGY+Q2zZ1Nvd28kE=;
	b=hgJ3cPuEBeeXqCxHyzsjcmbbDJJe4eI0Z5hpWzqkGY/Yz1d9alP0zdlMk8o06Y0U8IiZq9
	QN0FxyqUkQypactsnElnx+jzgz7mvCMwgXcn8tIR1Tq/5CS2kE3IwDoSx1tZxRJvhz/ltT
	nrRYPgOwnNMtnmaHJHyYd0wF3I3TX5I=
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com
 [209.85.217.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-530-Fdvxp7Y_NfiSdg_xOPi8AA-1; Mon, 19 Oct 2026 16:05:43 +0000
X-MC-Unique: Fdvxp7Y_NfiSdg_xOPi8AA-1
X-Mimecast-MFC-AGG-ID: Fdvxp7Y_NfiSdg_xOPi8AA_1792425942
Received: by mail-vs1-f70.google.com with SMTP id ada2fe7eead31-7cc0418036bso170045137.3
        for <linux-fscrypt@vger.kernel.org>; Mon, 19 Oct 2026 09:05:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792425942; cv=none;
        d=google.com; s=arc-20260327;
        b=PWIaRWmRT2eT4tmfwQhf36SbqAa+MY+IN2YYk+hopG/GBoQqBCr8nrjli/HRwGnSAc
         pOro0Iys7MBH6csL1fSZxmZ9Afuwf7DreQeN1K0U2AadbS/vg6oJNnBbcMOweDrQ7QVW
         icf/zkrN+iZVo56ULNcFPehrkWCRMoUi90eQZkGYmcYbi32Pg/O37n1ThoZKfKcHhcQS
         r7KS8LFPFwN7hHoxEBeaQJtU8ZPo9DRpU1jTopjpl7jpIxYpmqxvBJ/y6sf2U/fCeWwj
         FUhTqcNwkNrQpxACUcmkIfKbi8ceiyEd5XWJdTUXuL//hJww9+v8zsfG2qk+Bs/WMj+V
         /k6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=rJCzmqkUyBuAMTS2sRPCTNp4WMacGY+Q2zZ1Nvd28kE=;
        fh=XAefCMs8J+BCxV5S8NuKDEvR/QkYcllX4z9kCHgqOXY=;
        b=kPoHHww3Q938uT2UnCuC7PmCcpEnH8U5hZlxbSivklaLbacI0EfHO+4jw0Q9cxJ3gZ
         3g91pDRBV95uGELWgoJc+o1C8Rdf/K0ejdaWI+2cUZIP1m9MBp2piW3GyaYoafJrG4Jx
         SwRzlZ4e45YClaDON4y5IsQBaXMYM1OhvLXMEhaUAq6xZJdlKQ7G7pYWIVgOxy1QOE3y
         HYmwP8YUohFe+ai5gRtZlY3sM6u9Qoxmn7yn3GCwsS4frl/tzS+HC/xQPZw+ZrDa4HR5
         Qa0nqJPaUsBltU/UpLqbjhspNGmwg8TWhyFe3XJ2m5Uz96SHtUNTRHzbl2YMnFuQ67QI
         95Cw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792425942; x=1793030742; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=rJCzmqkUyBuAMTS2sRPCTNp4WMacGY+Q2zZ1Nvd28kE=;
        b=p7w3l47yyRW55YfMqlNOH87cD1yw0iklbf5fRZyOnaET1x0v93WzI1df4OKEBnXjNF
         FEacgH0Cg2wcEtKtQd+AEjmxeFbhhOYRC+7imrucDnOy6zIcDOzyJkCj3o4urQHRF6WD
         NS30ZPMtVozwYFnzzIj4FFOYfGF/CPcML5ak3nuyjQx2fYZd/cvLWnVCvtTqJGwO4xJs
         3xeWbHxw+xwNgNNspLvG72RuMr0YTFqqoe3VyaQ5LfT12IE+ycZV9efI5111tl/lsF+i
         sLR5BQvvXCz29W1x4xupMxtQ1ozTyv1j4zQKEUA0jf/vzHQFPRVgh1PhdaNEhZA2+nCa
         6t5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792425942; x=1793030742;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=rJCzmqkUyBuAMTS2sRPCTNp4WMacGY+Q2zZ1Nvd28kE=;
        b=SGgn15tC0oI4wmkAVMAxd0VuCe7tR6YUo8aWSaFqes5APLveX+xREFrM4PAlwj/b8T
         Ni8AVusIXX3UVCWHwTjYCqFmdGFeCifFSHYo02rFSPtluhZC8E6fknC9tq1rTbhCFMsN
         t1O4uFAxZM8iNZAkRngBwE/afP1u8WR9h8eO99XdBoaJhcbijC1j7wSc6ohGMZil8J9y
         WHcL638/nB1a/rSbpx1vjoLK5c/NBRe48PUeibI1cYU5KwPFT4Xsuyaw+QDL9Bxi+77n
         3Zd6RMEqshV0LWht0OrNO1WU9fFLDzeoGCtiDSuxS5SEo/ETF+/elq3GAotIBq5vQYgq
         FU0w==
X-Forwarded-Encrypted: i=1; AKwUvBxZvKvAbo2b6jwsbXMH0BLkcULKdCroVlngBiKdmyh1L7nCZqN6iK6j50UWFHVslbyCwBU1nEL9J22VBJzE@vger.kernel.org
X-Gm-Message-State: AFq9FYJUckxqq29QYTrTd36ljn0FfIzZfnu/Oo95G1ohivNzAuu7fup8
	sHtl9QqGQZZCGiHf01d0QggzBbUJ1KkuHXxIQ6dNlfk1HgeW0n9QtfrXa9ayto5Snp/RrvznI25
	oKwwJHxlZZID0olNtG4Hn/G4poA+rllwZ+Z0ORtsrl+tMsBqH0bNrrxsP9EGWHMzwbSnxZEdNBK
	ajBxfWSZqsgaTHj8UIpNWEMs6KsmJ5SzaMx2ZiEsGYgw==
X-Gm-Gg: AYBFou37h8SkUDY2eReobs0muWC/ARh07FTGO9VDlodgKOcSuJmD3LFUU3r8+Y31pY1
	StZzE/wzU+DlEcL+h7NRzWlv7MhYvHG823cywhXsRzYEZtWh05DZFTa/4uP7d/AK5lT/9j2hBsO
	zwyoagaMaaNzTzkxsejVmx77qbGvj1LdgzA0naB2NS/3AiL+TNTO93SfImZXMHm2VFP55VXfrfq
	i85aAQI4ErYwQ2bB1zWg8iSagg0d26eTN+f9vwsPxbpW6hEsbku75sgSFM0jqaphDvpM3iSV6Qg
	5r5VxNPCXgIRPSyomJDwOCiAqA==
X-Received: by 2002:a05:6102:5249:b0:7a7:19aa:f0d8 with SMTP id ada2fe7eead31-7cc36b48339mr1807110137.37.1792425942323;
        Mon, 19 Oct 2026 09:05:42 -0700 (PDT)
X-Received: by 2002:a05:6102:5249:b0:7a7:19aa:f0d8 with SMTP id
 ada2fe7eead31-7cc36b48339mr1807101137.37.1792425941758; Mon, 19 Oct 2026
 09:05:41 -0700 (PDT)
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <a01d0a297a3e174d21741a3ad586ce546327603e.1792081664.git.amarkuze@redhat.com>
 <20261015183548.GE2170687@google.com> <CAO8a2Sjr6XSizdgobZK1ZAO8PUd5tCDFKjdD-=3TXHwqOU6qfg@mail.gmail.com>
 <20261015193800.GH2170687@google.com> <CAO8a2SgiFTarbcg-qgTLgjk1RsOMLwHsjj9ko8HgT99F1DAYrg@mail.gmail.com>
 <CAOJNxR+zWN=UPKf5NcZDHDsTghu9XHuQuWDkTaHjA1j2rU_42w@mail.gmail.com>
In-Reply-To: <CAOJNxR+zWN=UPKf5NcZDHDsTghu9XHuQuWDkTaHjA1j2rU_42w@mail.gmail.com>
From: Alex Markuze <amarkuze@redhat.com>
Date: Mon, 19 Oct 2026 19:05:30 +0300
X-Gm-Features: AclHuK836x2QCsZgOmWJBCRabmDFLxRa7Rbm7icXR-nKnFjpLVPX_8WeuZ5WW8U
Message-ID: <CAO8a2Siubo8Dnj+RnQLf_AUxhJMuuE6d5JLu=OUjmnT0GJJcCg@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: allow filesystems to disable symlink target caching
To: Xiubo Li <xiubo.li@clyso.com>
Cc: Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, 
	"Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Ilya Dryomov <idryomov@gmail.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I''ll resend a combined v4

On Mon, Oct 19, 2026 at 3:56=E2=80=AFPM Xiubo Li <xiubo.li@clyso.com> wrote=
:
>
> On Thu, Oct 15, 2026 at 05:46:24PM +0000, Alex Markuze wrote:
> > fscrypt stores decrypted symlink targets in inode->i_link. The VFS can
> > use this field without calling the filesystem's ->get_link() callback.
>
> Agree with Eric that this belongs in the quarantine series, with the
> ceph_fscrypt_ops hunk folded into the patch that adds the ->get_link()
> check.
>
> I tested it on top of quarantine v3 with a KASAN/lockdep kernel and a
> v2-policy encrypted directory.  With v3 alone, the only access to a
> cached encrypted symlink that still succeeds during quarantine is
> readlinkat() on an O_PATH fd opened before quarantine, with an empty
> path.  Path-based readlink/follow/lstat and readlinkat(dirfd, name) are
> already refused by the lookup checks.  With this patch the O_PATH case
> returns EACCES as well.  Please describe that case in the changelog,
> since it is what justifies disabling the cache.
>
> Only the two writers need gating (the kmemdup() in
> __fscrypt_encrypt_symlink() and the cmpxchg_release() in
> fscrypt_get_symlink()).  If i_link is never populated, the READ_ONCE()s
> in fscrypt_get_symlink() and fscrypt_symlink_getattr() already see
> NULL, and the VFS reads i_link without looking at the flag anyway.  A
> writer-only version behaved identically in the same tests.  Please also
> update the fscrypt_symlink_getattr() kernel-doc, which still says that
> targets are cached in ->i_link.
>
> The cost is one allocation plus one decryption on every readlink,
> follow and lstat of an encrypted symlink: a re-read link went from a
> single fscrypt_get_symlink() call to one per access.  That is probably
> acceptable, but the changelog should say so.
>
> Thanks,
> Xiubo
>
>
> On Thu, 15 Oct 2026 at 21:45, Alex Markuze <amarkuze@redhat.com> wrote:
> >
> > I didn't want to conflate fscrypt patches with Ceph features; arguably
> > two distinct patchsets.
> >
> > I will CC you folks when this is acked then.
> >
> > On Thu, Oct 15, 2026 at 10:38=E2=80=AFPM Eric Biggers <ebiggers@kernel.=
org> wrote:
> > >
> > > On Thu, Oct 15, 2026 at 09:52:11PM +0300, Alex Markuze wrote:
> > > > Hi Eric,
> > > >
> > > > This supports the concurrent CephFS subvolume quarantine series.
> > > > There=E2=80=99s no Fixes: tag since this isn't addressing an existi=
ng upstream
> > > > regression.
> > > >
> > > > The quarantine series adds checks to Ceph's ->get_link(). However, =
if
> > > > an encrypted symlink target was cached prior to quarantine, the VFS
> > > > bypasses that callback entirely when following or reading it. While
> > > > the target data is still valid, access now needs to be denied.
> > > >
> > > > This patch adds an opt-out for symlink caching and enables it for
> > > > Ceph, handling the encrypted-symlink case for the concurrent series
> > > > without affecting other filesystems.
> > > >
> > >
> > > That series wasn't sent to me.  Is it
> > > https://lore.kernel.org/r/cover.1792074165.git.amarkuze@redhat.com/ ?
> > > It would make more sense to add this patch to that series so that the=
y
> > > can be reviewed together.  I can potentially apply a prerequisite pat=
ch
> > > by itself, but we'd first need to know that the rest has been reviewe=
d
> > > and will be accepted too, otherwise it will be unused code.
> > >
> > > - Eric
> > >
> >
>

