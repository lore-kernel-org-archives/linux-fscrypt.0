Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795090692;
	b=tDW7rPVRPvj2w5wYn3aJKgWQJDs3My40JHDm1VgRmgkK2JIKOicgJfM2mDpcqeOIcPX1
	 pLPX128Y5hMpr5G0WXQo8nHYVJWtXGbLWVoOYAMf2hWrgmP9xxmMssao72UXxuCmkmDpo
	 zz8/44wpG+nyfSN2w/MXUviaFg54k9XTgrMX0O6kcmz5hvMffG6C2Mo30N+AbyQ7NWwqr
	 vZEhDXEx/l8ZO+jDwBkM4AIr9MVqDYlFAkIf5KJPnoi6BoZZhnzw45JcIUyrDFtOKTnKp
	 ADCQRgxwR+UEqqtnoXBzZwuqfwMLN4/ZYVHFh1mExnExhkz55kArOr7GINBxhKMxB6A==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795090692;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=gqZVLpTgCP2ySw8awFBFsKWriU/az/ZtPImm1nmYhzQ=;
	b=47+5CPPlEEyC/ET3T5tNV4Dk0vsFLTxi4D/zD6po4RA6Eh3PqXnb+C3XMyMluW56n3YB
	 7lGEPXEAAyRaGKjq4mZr+GpuHasLKAD3GY/t2r/fMwmFb6ul9gqNuICVYJRpmlaJXk0K6
	 l30nIUge0z1/yk60eQEGwXCM31SEkJw8hfK0d5X8fM+MqohABFCBLlR6YnyXe+qg8a3+I
	 9ynNNSWU4qlb6/6zf9lkYquqKkOM03DclBDUfyQ+OGJL6KkyP1CqPds/UqV1Y4lYyA2tn
	 5CKn2VOrZV6GwH9OGLozoQqniyjYFEYJz0dVjH4/OrKtIas8vlJR30UUyBOh3pSSzqg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=ifOPtyq7;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=W8hMqnqB;
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AAE4E606A324
	for <linux-fscrypt@vger.kernel.org>; Thu, 19 Nov 2026 12:18:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AAE4E606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=ifOPtyq7;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=W8hMqnqB
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795090690;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=gqZVLpTgCP2ySw8awFBFsKWriU/az/ZtPImm1nmYhzQ=;
	b=ifOPtyq7o5N4Ryx1i6vms8hUs2TwLy/VT4TTh2PTFt5Ky+OtK2Z52Sg2aRI2r0PQwmRxBb
	acR+rLmvVt0D4OyixA7xHRuMWoYGjGUOCoPGcEsmuGXMRTaLIb6JOZFk6q6oA5x3CSRdRx
	qdccUlXVwKZytBZoZaDb4xPQUUNiPN4=
Received: from mail-yx1-f69.google.com (mail-yx1-f69.google.com
 [74.125.224.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-362-TbIdoMF1OIqpS3fdwPs6yw-1; Thu, 19 Nov 2026 07:18:09 -0500
X-MC-Unique: TbIdoMF1OIqpS3fdwPs6yw-1
X-Mimecast-MFC-AGG-ID: TbIdoMF1OIqpS3fdwPs6yw_1795090689
Received: by mail-yx1-f69.google.com with SMTP id 956f58d0204a3-67935d0ddcdso3193129d50.3
        for <linux-fscrypt@vger.kernel.org>; Thu, 19 Nov 2026 04:18:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795090689; cv=none;
        d=google.com; s=arc-20260327;
        b=LFAYE2iP/+VchleyVJDClF2sukRwP4k8tx2beEWP9eRWngqgqZ/KXZbPnn4MAdi5qc
         QJZhnWq4sQ4asmXSHkCtqcRZhwZXusvcqovgRmzbZFH5sy5n04GAFWmzXTI9R8PyfDh5
         CnL+fqh+0dbPXvuvq3DRTeiX920mxuC9rbg8wzd3McyYN/XK3gsS/Nj8r9Q1BvyJIzkd
         Jeh89Bav8+aZWCJap3AEuiM7Fg8OvDSHJ1tNnBOEeZzhH2hkP8p5e02Ihd+wD0cR7ONW
         S1E6gQtlB9s64dxh10OTex086TcZdqoHszo0vh1d2i4zemEQvQJ3QjbDj8FCRAWiSaUu
         8HwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=gqZVLpTgCP2ySw8awFBFsKWriU/az/ZtPImm1nmYhzQ=;
        fh=FXBlWeMtlbO5xFzlrl6z62hCNrHgZE1NEwXEuqbvWyE=;
        b=FqvxER0Rt0F73Tcdxha2VjufWKSyel7Z54NGuqfCiX2Ifec00CSkW6//vVD1Q3lYEp
         C2gkBvxru7txhqVQPFlrp8z5LWWlsOtx/RD8moJnAy4saIaiAuBsT8c8ks3AaX9guTlX
         lrEI/6vzT4U3PgB1rahoS+Ovnc5HcJsM7z25gS/CoaPutNV2YtpzJoJffcWi7lnYzm5m
         SihKAR+cfCz1If1ebCDv1gY7x0AaP4ZLwP7RdHv+zkOBZ6rbHrFxWC90sSAiT/C+Y8/x
         Tsbn9oWKxgFtzUvEKXPRkD46mYU+KjDJdftQz/TpvD6OP/HKzcu9OIoddD1PnDo3AWtt
         h3Tw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795090689; x=1795695489; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=gqZVLpTgCP2ySw8awFBFsKWriU/az/ZtPImm1nmYhzQ=;
        b=W8hMqnqBRGair6EoKrRvZxO77dqdj+YfYgkTq7D/3LAyjuaoOoDi6CBjJj2/uTyIN/
         fDpxDop4wdBIhC4E/qClwWzfxDsRKlC+fQO3UGaRGo+wxRGTZreAoLQjwFDN+CvKuSdK
         Xfn4nra5rpcDvAioHGKENKEPM3Q9kGHAhtzrGoyfmonoJyWGpgd9XJyQO6Ah/a7T2Ppn
         zsB9YEoDNUbUZ+k9HrlxOWcwAWQDOlDoV3XTlJHvYLtC3OS9sGUDCz3KiS2aQ5OT+IOK
         ip3K9h84fcgxMAozSavkACkeLTUU+AZnecsWcPbDZVD/GsrbNUaLtT+6HgqlfHiMchXd
         tWww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795090689; x=1795695489;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gqZVLpTgCP2ySw8awFBFsKWriU/az/ZtPImm1nmYhzQ=;
        b=x6fiTY1O0qhfDNSvMaHKVlcWX7y/1KEIXdeF3+ecrD1jAyq1mDAGvY/jyve/E9fJLv
         pJeDBmE+XtJQjgMHYcCl7zvv0d2ql+o//JELJdfu0Hvpi7eTRhGOqk7WOGPm5pAOING2
         bBuIASaBgJtyKbPoq6q+HJwguRuqBiKwjIzVwrJQkBl1EsxI7KQjk8XwlK/g5isIc4kt
         vdn8pNPHcjRW2wBTcxAVXIllPTEnmv8Mnoh4cP0Ct2CA5werJNfEj9s4ohiMRkYj+9VR
         NAvprzRsHfS1pTpEP/CNs2jeKCUDl3KSaMX9zJnfWiD50L7D2nJEoaiXFKTUPO2ECfUJ
         Nm/w==
X-Forwarded-Encrypted: i=1; AL+hErGzQL7XRuFQka4RjlaqSyHbxThKxdCys8Z/bD75PmeIKt4W/txnaKN6oKhVu3RKPkqHC78mFUI/Cht+4U3J@vger.kernel.org
X-Gm-Message-State: APuU4Z+fPvB7PoiWqYicG8dpd79YPR1+/BjljNlKCnlyZ0IwlvJ7yzuT
	g/WdrLVIrU0TxViWuwGXwGmS4Xaim1kVynchuuB83dcAknPh1zgeZ+YND4m02HWrjMeCGlt0quv
	G8xwqcQ5zq0sh6xao46jKaTr4EFpkJfjqdBNRyrwaVpvN889v6/OsUoYhAFxSGwhtrVqmPzSh3m
	WSczUjbpNjCVbr8KWlWpTfPzy6/4uzvfbWoknn+6U4kw==
X-Gm-Gg: AZFdTZeZU+PIF6XHHZRLOYMVtfT8/zfoFD0cm7Hl0wMIiOsF+W0+Ca8sZtmGIsXl0Jb
	R1GUWAdazTkVMsqwO8mWvD+VUC2SQ6dTYibX4AszkOVa+1y7LDMlCC0FYNPHKQgGlBe/0EFfRuD
	5ArEO+8BY3Qnz9gKPYI/nrkkt+QvEZS+yiILDYT4gFJLSPgtjLnNYrgkozYnwXj5lUUzsjibukj
	XxmYeUtja16qk29E4CjgqCtnmEnvt6Q2N2hgZBe9zTX1A==
X-Received: by 2002:a05:690e:806:10b0:67d:a6fb:ceaa with SMTP id 956f58d0204a3-67dd3f193f3mr1716878d50.19.1795090688824;
        Thu, 19 Nov 2026 04:18:08 -0800 (PST)
X-Received: by 2002:a05:690e:806:10b0:67d:a6fb:ceaa with SMTP id
 956f58d0204a3-67dd3f193f3mr1716866d50.19.1795090688232; Thu, 19 Nov 2026
 04:18:08 -0800 (PST)
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116171044.6938-1-jack@suse.cz> <20261118145941.1063127-19-jack@suse.cz>
 <CAHc6FU7NoZua98SGP9Kuga58gAcco6X__u=kOPfsUqbefAKLFQ@mail.gmail.com> <wo5723b7wrmu35q5qffzs7zzqwnojk3ireel2jkit2kxgv6bra@yd3gbigdmmdk>
In-Reply-To: <wo5723b7wrmu35q5qffzs7zzqwnojk3ireel2jkit2kxgv6bra@yd3gbigdmmdk>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 19 Nov 2026 13:17:57 +0100
X-Gm-Features: AclHuK-GbM7XVFxqU3dJAQePNml2N4MUSkkmDt3mktzVCdVYt3Td22WOXOu6yXM
Message-ID: <CAHc6FU5HY9x5ntTOz_xk36T0XTzjNc8R4jy2zzpQKo=19HNMog@mail.gmail.com>
Subject: Re: [PATCH 06/13] gfs2: Avoid racy dirtiness check in gfs2_fsync()
To: Jan Kara <jack@suse.cz>
Cc: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org, gfs2@lists.linux.dev, 
	Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org, 
	Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, 
	Carlos Maiolino <cem@kernel.org>, linux-xfs@vger.kernel.org, 
	David Howells <dhowells@redhat.com>, Marc Dionne <marc.dionne@auristor.com>, 
	linux-afs@lists.infradead.org, Miklos Szeredi <miklos@szeredi.hu>, 
	fuse-devel@lists.linux.dev, linux-block@vger.kernel.org, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org, 
	Eric Biggers <ebiggers@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-fscrypt@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 19, 2026 at 1:05=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> On Thu 19-11-26 00:35:42, Andreas Gruenbacher wrote:
> > On Wed, Nov 18, 2026 at 4:00=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> > > Check for I_DIRTY_PAGES state in gfs2_fsync() is racy because
> > > __writeback_single_inode() unconditionally clears the flag and
> > > reinstates it only later based on PAGECACHE_TAG_DIRTY tag. If
> > > gfs2_fsync() unlocked read of i_state hits in between, it will not se=
e
> > > I_DIRTY_PAGES although there may be dirty folios in the mapping. Chec=
k
> > > for PAGECACHE_TAG_DIRTY instead and use inode_is_dirty() helper for
> > > inode metadata dirtiness check.
> > >
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> ...
> > > @@ -760,12 +760,8 @@ static int gfs2_fsync(struct file *file, loff_t =
start, loff_t end,
> > >                         return ret1;
> > >         }
> > >
> > > -       if (!gfs2_is_jdata(ip))
> > > -               sync_state &=3D ~I_DIRTY_PAGES;
> > > -       if (datasync)
> > > -               sync_state &=3D ~I_DIRTY_SYNC;
> > > -
> > > -       if (sync_state) {
> > > +       if (inode_is_dirty(inode, datasync) ||
> > > +           (gfs2_is_jdata(ip) && dirty_data)) {
> >
> > this adds back the I_DIRTY_TIME check explicitly removed in commit:
> >
> > 3aac630b5ce1 ("gfs2: don't worry about I_DIRTY_TIME in gfs2_fsync()")
> >
> > Could you please clarify what's going on?
>
> I wonder how you remember this after five years :). Anyway, the truth is =
I
> forgot fsync path is calling sync_lazytime() as well before calling into
> ->fsync and even if I remembered that, then it would be fragile for the
> helper to rely on that (and there are already users of inode_is_dirty() a=
nd
> inode_or_mapping_dirty() which want it). So to summarize you are correct
> that the added I_DIRTY_TIME check is unnecessary for gfs2_fsync() as it
> should never trigger just for that but it is also harmless and the helper
> is more robust that way.

Alright. Could you please include that in the commit message?

Reviewed-by: Andreas Gruenbacher <agruenba@redhat.com>

Thanks,
Andreas

