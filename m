Received: from mail-ej1-f53.google.com (mail-ej1-f53.google.com [209.85.218.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E9B23EB7E9
	for <linux-fscrypt@vger.kernel.org>; Mon, 19 Oct 2026 12:56:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.53
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792414602; cv=pass; b=rxUnIQvKZnmTob4YTbYdVy1HrhhOCgH2z+cbRGVNuRss5sj0C1KqWUJsikICp8t0oWlbjBgfr1Hf1YIz5w76q4OfUMAYpEOBvvs+ZeHsg1bLnR1vU9XiL8F5FiXq0MoslTN9wxLn7sIDdY006RICWbg76HBFVvQnMr8SmNFdXtU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792414602; c=relaxed/simple;
	bh=vAgzI0iplg/XqWWtYAni1GCNMLi7Ggs/EbUO3M+2rBM=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=CGA+Ez+hvZbkCeKiq9JEeaOqrmmdmnefLo6qtylcUaXTWxw9jTDamSMEUGh7cTYyFMIj7iSg7blU7RDs2ynruAPIbPwvmo0oVXmtH39rmm1HFw2bDdSlQ0MxJ5n3iJ8b1Ru0Jol03+r/fbmq1DB5j1DBOMOEG6MXxUhFx8KwGyk=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=clyso.com; spf=pass smtp.mailfrom=clyso.com; dkim=pass (2048-bit key) header.d=clyso.com header.i=@clyso.com header.b=FGxWxned; arc=pass smtp.client-ip=209.85.218.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=clyso.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=clyso.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=clyso.com header.i=@clyso.com header.b="FGxWxned"
Received: by mail-ej1-f53.google.com with SMTP id a640c23a62f3a-c2afa22e1dcso314538966b.1
        for <linux-fscrypt@vger.kernel.org>; Mon, 19 Oct 2026 05:56:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792414598; cv=none;
        d=google.com; s=arc-20260327;
        b=H+deMHDzquwfOJV1oF0Ew2Piu3YqOFkl4d5Ol7jHpKKXyez62dE35YoqniPlNE085F
         nXWb+C3POdzS0uxQEg0zQ2WTosBL+snhC/m68AechwIrBGBCblW1O9R+1b9NL54m7bKu
         9W9sca9kBzJ022YfviB6EQs4vK7aNKjyKu/2OKpLZxS+zA3nW5tDiUnPDD7VJzB6til+
         ux7Tk1i87QNr1ZCWIpADBq/B5+7ijUK+Sz5l8pe2K3fZFpyrzCHrG4KCt2vNHPojyoJc
         Of9RzkfbyIpdgNszoadHgNf5Em1UvV1zBrLUCqdrwh8eu5PtiS37P7hFACbg7i207lZy
         GjFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=n3JjqP3LoG50YyWAVsfXppKDfSv9tlf4tiMRRF9oVbo=;
        fh=BGlWT3EQBaOTTDHe3/iA48Auj+4JVIWRv+l5LxgXBzc=;
        b=EfuI6vy3L9MVW58ZmmvXnVmhlKfY+o1WeZ2/Sim+Kp3U+5VxiItjzWSq9g35yo07JH
         gEufJKWkJUTdBMIhyc4GTD53DzoE5mWjoTaZsJExkcJbO5Nt6CL9wvkdiodnh1sLlhL7
         rZNrEPLgYBFZMrtwud17jNC2G5Ceb1121pM6lnK75uDNtc4Gee1yehL30+6le9BGKN+a
         LrcWNw4+v9odQGfTWFKDKAXzRotFOIBxnC4aEIAje1yQqTkzbHjHD1Re3RrnXOKFy4hF
         bFxjWWEexHklbTHs/kiK8vQe3uCUqdsPBBL/oMFGlZT3gblSeJz2FJXnSi+iYOs1Cv4c
         9sww==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=clyso.com; s=google; t=1792414598; x=1793019398; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=n3JjqP3LoG50YyWAVsfXppKDfSv9tlf4tiMRRF9oVbo=;
        b=FGxWxnedQmSunTw4KGa5ev1tC6I2tf/aO2ewREPVFI7t0anxDLKgOdp+zcXGs9prvL
         MdbGUW8JW0sIp3K3Y2rrRQC/8oN2rY9aLGmFNjrFEAOixoNxvzPIr9VyXnoOZz0Rrx3n
         C3Km/pV1rW9xqT0lcNRHPeijjei5L1tKpTExszOOOA/wN9h0bw8i4KC+kHiL90OFsmvZ
         eiT2oQdHk9prCC+OpgK5N0tmxLz2B1A3KwQg431aOnSQFVFUAkDdONG3EPbGCmZy/wpe
         KP3YTzZ6BFyhEno6w7oNjWPgLh5oEYBKioqvTdAbCeu6NMXgmLNz0t9D3PqaK9/YgpNN
         iRaA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792414598; x=1793019398;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=n3JjqP3LoG50YyWAVsfXppKDfSv9tlf4tiMRRF9oVbo=;
        b=IbplN9szMLNJzFa50+HpHwgm/p7fFKTnAkZFdHSUCGw74FsV0jXsOWGjpn8VIw/6i8
         UOLpa5ONeIm0D8GP+cq1z4FntCbSkRILCHcE+vmrkX/ng1W3D0ASSneURNF2yXoTr2fg
         kyYc9w2JVPmDa8k1r5Guq4pf+7jnvuXc3Idn8REGz1DfDHysNwRy1Yk8/u2TA0S5J649
         cW2r0OyKkKyLajYp+BxEl0SVRdrK0+QkDb7JJL3qSCU573n6ChxIQPAPIPzsGI8fwJsc
         Dvw+AZBQ3FOFJafWbkVVE59gGudnZ2shKU2OxiV7aYcq1CzxSJyE/wKBgRKJM1qGvMHv
         CILg==
X-Forwarded-Encrypted: i=1; AKwUvBzHsGOCrOnnZYPgNfAZlVi4x+0FZ9VXEkb3dryEz9lSXZBlAim0IRFE6eRMNaNobhlCr/I1zGkmlsHN+aWY@vger.kernel.org
X-Gm-Message-State: AFq9FYLhRElmc3fckY28aVOXJKc8MXoA0qNjeJwR0rTWrgi/6Q92kNSt
	D3bIHXfPJhR0/zLn4DVaLaLjGlrmcIDK6ilsu43e4oEq5tr1pawrwbMKTWPTUvo+KhJjWWiNcgg
	Tm85pKPJ4d3LduS8/ltWsXuauasp6cQnRtfVEmEo61A==
X-Gm-Gg: AYBFou0Im5+PD9L++X0pS9BzQTAPO4FL/O4Ah5+l1409E29NSt+SUzuxT0amZk7lwzx
	19EbTVMk+14/uq5HAQqHH2Ku5HEAB7GdIRrHKwKw2ha+jaPNQHcvKbo58FAOqxAtNcJCTfV6JHt
	Dquq6hnjJOZD40v5S+38mQyQGpZnAGi/waRgizHrX9TcxPix5zg684sJMs0w+Coo45BsCKHHZ/x
	Ti1v7RjlvuNht7VyniSgxCASdF4+m1lz2/7WQWUo9ccVGboSMQTFNXWoGe8WoXQRFLcBkD31EJD
	P7IL0bqAs4rs3m/aXNCcPLw2xGUId6C3s2zEFKUEABwOkJSP+pI1JMCwdg==
X-Received: by 2002:a17:907:9613:b0:c2e:5efe:f1cb with SMTP id
 a640c23a62f3a-c419d05e727mr580195966b.8.1792414598397; Mon, 19 Oct 2026
 05:56:38 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <a01d0a297a3e174d21741a3ad586ce546327603e.1792081664.git.amarkuze@redhat.com>
 <20261015183548.GE2170687@google.com> <CAO8a2Sjr6XSizdgobZK1ZAO8PUd5tCDFKjdD-=3TXHwqOU6qfg@mail.gmail.com>
 <20261015193800.GH2170687@google.com> <CAO8a2SgiFTarbcg-qgTLgjk1RsOMLwHsjj9ko8HgT99F1DAYrg@mail.gmail.com>
In-Reply-To: <CAO8a2SgiFTarbcg-qgTLgjk1RsOMLwHsjj9ko8HgT99F1DAYrg@mail.gmail.com>
From: Xiubo Li <xiubo.li@clyso.com>
Date: Mon, 19 Oct 2026 14:56:25 +0200
X-Gm-Features: AclHuK-F8mSSChjPrw3xtMipa7gc_SbaF2GeoOUl_trF5qnqBrun_SW2oyz5b9k
Message-ID: <CAOJNxR+zWN=UPKf5NcZDHDsTghu9XHuQuWDkTaHjA1j2rU_42w@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: allow filesystems to disable symlink target caching
To: Alex Markuze <amarkuze@redhat.com>
Cc: Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, 
	"Theodore Y. Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Ilya Dryomov <idryomov@gmail.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 15, 2026 at 05:46:24PM +0000, Alex Markuze wrote:
> fscrypt stores decrypted symlink targets in inode->i_link. The VFS can
> use this field without calling the filesystem's ->get_link() callback.

Agree with Eric that this belongs in the quarantine series, with the
ceph_fscrypt_ops hunk folded into the patch that adds the ->get_link()
check.

I tested it on top of quarantine v3 with a KASAN/lockdep kernel and a
v2-policy encrypted directory.  With v3 alone, the only access to a
cached encrypted symlink that still succeeds during quarantine is
readlinkat() on an O_PATH fd opened before quarantine, with an empty
path.  Path-based readlink/follow/lstat and readlinkat(dirfd, name) are
already refused by the lookup checks.  With this patch the O_PATH case
returns EACCES as well.  Please describe that case in the changelog,
since it is what justifies disabling the cache.

Only the two writers need gating (the kmemdup() in
__fscrypt_encrypt_symlink() and the cmpxchg_release() in
fscrypt_get_symlink()).  If i_link is never populated, the READ_ONCE()s
in fscrypt_get_symlink() and fscrypt_symlink_getattr() already see
NULL, and the VFS reads i_link without looking at the flag anyway.  A
writer-only version behaved identically in the same tests.  Please also
update the fscrypt_symlink_getattr() kernel-doc, which still says that
targets are cached in ->i_link.

The cost is one allocation plus one decryption on every readlink,
follow and lstat of an encrypted symlink: a re-read link went from a
single fscrypt_get_symlink() call to one per access.  That is probably
acceptable, but the changelog should say so.

Thanks,
Xiubo


On Thu, 15 Oct 2026 at 21:45, Alex Markuze <amarkuze@redhat.com> wrote:
>
> I didn't want to conflate fscrypt patches with Ceph features; arguably
> two distinct patchsets.
>
> I will CC you folks when this is acked then.
>
> On Thu, Oct 15, 2026 at 10:38=E2=80=AFPM Eric Biggers <ebiggers@kernel.or=
g> wrote:
> >
> > On Thu, Oct 15, 2026 at 09:52:11PM +0300, Alex Markuze wrote:
> > > Hi Eric,
> > >
> > > This supports the concurrent CephFS subvolume quarantine series.
> > > There=E2=80=99s no Fixes: tag since this isn't addressing an existing=
 upstream
> > > regression.
> > >
> > > The quarantine series adds checks to Ceph's ->get_link(). However, if
> > > an encrypted symlink target was cached prior to quarantine, the VFS
> > > bypasses that callback entirely when following or reading it. While
> > > the target data is still valid, access now needs to be denied.
> > >
> > > This patch adds an opt-out for symlink caching and enables it for
> > > Ceph, handling the encrypted-symlink case for the concurrent series
> > > without affecting other filesystems.
> > >
> >
> > That series wasn't sent to me.  Is it
> > https://lore.kernel.org/r/cover.1792074165.git.amarkuze@redhat.com/ ?
> > It would make more sense to add this patch to that series so that they
> > can be reviewed together.  I can potentially apply a prerequisite patch
> > by itself, but we'd first need to know that the rest has been reviewed
> > and will be accepted too, otherwise it will be unused code.
> >
> > - Eric
> >
>
