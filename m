Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795047181;
	b=cwb2CNkkz9QDRyd1/555XFwYh5dlXaZ/eaxsQiP9r00wZ9FqbC7wKGZWZZTwpEbOo2lB
	 fRkDGpA3x4Ge76UpB5NzROAtZ0M5OxNuajnOZ2nebj1yfn8q1X5CT9IIWf4OWk7THKqo8
	 SdVfBNWZ1ntnRAmjEb3vvSB4Tfbc8M8pHtEuDlXhA7GU9tWNcFqbfYMv4hGaKwrAn0DAh
	 OQhoe6S3zPzFh7lShvwLfv5fyPtcv1rUBcWD1hjTvOgu5DfmFFxajvJKYI6kKjR0Spbo4
	 o1+/kNHHU7F+TbN/A7LSe2ixKxmA1g+SCsoPZ15DtAzSvDODVqlv9UMKxvQcr5Z4yDg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795047181;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=077/TizvhH3iQcetqO0vvepvTnfIkqb5hqSDa7XFIt8=;
	b=0lumJGzw81Y063PMARZzsjPzofD6iMs0pp4U1u9HucC0i6lB6OTK92TM0v6QMeOzWKA/
	 OCQb8hCXImfAyOuSlMO8KgpyJZpFevOVXkbMsfDn+B11T/DU4wtYPKXL1EohOOXJRZPvW
	 Un7X8g3/jdEaYfBEZTXaFfGYU9lSoJEODt00mro5aH11SIh+C4WqRg7L0EeQogxLpVyNl
	 05rIRM1xjIW+QWdWoPsvxaw8MT0aBPMpL/O9iJR7BBMRqX8tcj3Mdm2XMUb15JGoF33r8
	 GVgk2FjMDXCmjbla9elpbadFWwgVXO6rUfQ1wsiXo5x6gc3PiwKP6H6f3S4SUKkyT8Q==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=EjHXD+uH;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=gUck6dLA;
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6742606A32C
	for <linux-fscrypt@vger.kernel.org>; Thu, 19 Nov 2026 00:13:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C6742606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=EjHXD+uH;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=gUck6dLA
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795047179;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=077/TizvhH3iQcetqO0vvepvTnfIkqb5hqSDa7XFIt8=;
	b=EjHXD+uHIPilX0rB0j3Mlz2PJl5Wi/+DfCXmEOtxmu6urupg9yBolQ8etjCxA4Lu+f1RJA
	UnPoNl/XtRiUArG2jVcKflDK+1Z5hzEF1Pduh5IDJ0BymRJwdm4ZSe2v12QFbs5YyQUVYg
	glzbZU2VWYP3jIPfmZOsVF1LyqqNm7E=
Received: from mail-yw1-f198.google.com (mail-yw1-f198.google.com
 [209.85.128.198]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-520-8N3LWwowP6CH__qStBLeuA-1; Wed, 18 Nov 2026 19:12:58 -0500
X-MC-Unique: 8N3LWwowP6CH__qStBLeuA-1
X-Mimecast-MFC-AGG-ID: 8N3LWwowP6CH__qStBLeuA_1795047178
Received: by mail-yw1-f198.google.com with SMTP id 00721157ae682-8b50256700cso20076797b3.3
        for <linux-fscrypt@vger.kernel.org>; Wed, 18 Nov 2026 16:12:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795047178; cv=none;
        d=google.com; s=arc-20260327;
        b=Cj2Rmh09oxvsg4vTogpe9aBCuMymNL0ZUX3iOz3frkO3VME73uj4AyLqC3EJv8riuE
         +dOLanD35oqaklgjZFC+9+ZL1EzoqrWSevtr8NKsEP3/PrsWyBfgUau5bhqiVevlDs6I
         1iMMJpv977QMVv2n8Wq1SXo7WQZjSWQ+g0XEopOOMQNDyQTuuOisZRTS4NFVK2AKNLva
         qOTkI/DqKGmS3Yq+B8sgRzR9asO/YoDmIy6Oj0HsJOYaeVwRsizLHIZdHUf3NHcVQLRu
         T9BM/Q979/AhwOR6FigeL0REisP8sr1e/kYR1e8wlrhZv5EvwlCQOISnOCgNEh4NgaW3
         38aw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=077/TizvhH3iQcetqO0vvepvTnfIkqb5hqSDa7XFIt8=;
        fh=AyK5rm5NkHmaJKt18HQO3D2JbBXXalnhHCApqyPRVRk=;
        b=Yw4WKNd3UwheOSuYosUorzbFkwZgkKX35p+aNq7dcn2cHpnSaURcy2HEubsIG7At+y
         +KL1I5vJF16rjOELpBhV89V3+N0mK0hrvqpiY0Sil28VbLnT70M/hbXBcfz7+MGq6Buh
         /CnulNXD64NFR+puCx/6pc/F4Kxc0XnP7z2+57y2t2NyInsHOmvA04W2SlhKm4qQll3Z
         gEDtBXU0Q7/mP+EfWpfnqgPhe0Y4K+Ut1CnkAbCzwt9o9qsVgCgBpcJ3wFQzcmbDX0kL
         fyBJBGG/fI3+JxEOUoaGTdC5ygZ3wirWuSHOyas0E+GAOxSEUdZDLEUBuzrd4+hLgGCx
         W3XQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795047178; x=1795651978; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=077/TizvhH3iQcetqO0vvepvTnfIkqb5hqSDa7XFIt8=;
        b=gUck6dLAwdhYR60Buifwx95UYkvNlKNRmPnyo7USrjas+FkHH6q0XlA8zMbJUAOSEc
         4esQdx6pFabYHTtqUnRAbnqHQA+DgcA1v9Z8q382bLMxM7p546hudO1FBCaRByt15IEm
         /5vyT5BVDmw2cAmmuJOGyhMjBm6Z38q8chTcv+ssHh/G49YDGn4gHaXvGAwNX+jSP5Bt
         Y6dNlXK3huhbk8odG0lKZoxQMQgtT0ra6l6EpuazzBV6saVVp3imwrgtOTJyno51uUmc
         6zZmOUm07V1gdA8XhQX9VKm6Mrqa2q5yZBP+0CYfzheFkQJZm4upXymWAt8SIYWCbdr8
         DWBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795047178; x=1795651978;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=077/TizvhH3iQcetqO0vvepvTnfIkqb5hqSDa7XFIt8=;
        b=xvGwF+WXaY3rxYcNV8QfQfmyq+hdpObnVAsgqb7XIdlPLaC803zpyCdBfX2tLtGTdf
         KTTp3w5s4ypcwX3g1nbfq8ZI1xVjuREe+Cf2GIFbxCRa/1T+jbJtUOpFw1I1pCMvLR1D
         ctDYWGkccxUBmcY5FMz/mgo3raM7+4Cvj2vFre98dRF7jk6dNJx85kUvTgJYPbnDqVHd
         HNOuRQAkvcLslX7pkvTe9SUY/MCaMIux/rZ1cHZ/v2O1FXZ9z+bgjGbSKn/zD3I4J8Lq
         965/wKaqUdbOgQA14Ap8WEvVTr41YZdjDGvvxfswSAwOwBz4N/1XLSsEVar+lymkuhpf
         /77w==
X-Forwarded-Encrypted: i=1; AL+hErFueQ/sS9ywzQNOyok6DkljL8nVr6yWNRFRDK/KBF0Bmy1UVJS8AwsNGB8xk3dLrK3K8G50E17sGWg2MA5q@vger.kernel.org
X-Gm-Message-State: APuU4Z/cpjt1FIZ+Ac9oTuWhnm7PH4V6wXYwmuV5DMUcu4xZxMwjSf5K
	eFlEkGZxL7Ifi7R3ObH1V9x+4tmGedY9P/g9dbf2ocB1cS+Iry9yjybirBRk+USTIxi2OQB5nAI
	b/aXniAhrRudnG05BpS94av5A6n/lbt9swKhKDsq04EJyBnF2l9BUQ98VpM297RuZr3S0U8hlCn
	uGI1nl/tDPwIlXD306Gia1sIAyYY8AALYaMfJFUy8Aog==
X-Gm-Gg: AZFdTZcKwcrtoyyJUSmTez09Ls2F0oPrkmqAW/6n825BnznHMSTlpZcphsM9LFI9Shg
	3BQFZudfAiW6rR495Wr2T4Eyz1jmlLJ2Vqz8RFsDN9cBnbN66e5GKYPX85e66iUmXTw4S1k1l1I
	nsXPBTkP3/cbq6s8aij8jY7mhwInCwEuLTSscTdrVXBNdksYP792IalmHs6G6149MHzSaeX2179
	wnlDMh/yVmbsrU+rXRJup8dOUc2vuamrLRvI+aXmdmxEQ==
X-Received: by 2002:a05:690e:1907:b0:67d:b34c:9f19 with SMTP id 956f58d0204a3-67dd3fdcc80mr1565902d50.106.1795047177731;
        Wed, 18 Nov 2026 16:12:57 -0800 (PST)
X-Received: by 2002:a05:690e:1907:b0:67d:b34c:9f19 with SMTP id
 956f58d0204a3-67dd3fdcc80mr1565894d50.106.1795047177150; Wed, 18 Nov 2026
 16:12:57 -0800 (PST)
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116171044.6938-1-jack@suse.cz> <20261118145941.1063127-22-jack@suse.cz>
In-Reply-To: <20261118145941.1063127-22-jack@suse.cz>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 19 Nov 2026 01:12:45 +0100
X-Gm-Features: AclHuK8R-2iEv0c9btS3snfH7Yzq75Yl9vf1mN1FPuSVCWTRM2Ut7aYcwFy-L9Y
Message-ID: <CAHc6FU4+FV=A2UK1oPejHSt5XQ2Ox+CyvZfT4Q17YaceJ+NJ1w@mail.gmail.com>
Subject: Re: [PATCH 09/13] gfs2: Fix dirtiness checks in gfs2_write_inode()
 and evict_linked_inode()
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

Ja,


thanks for catching this.

On Wed, Nov 18, 2026 at 4:00=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> The checks are bogus because they check against inode->i_flags instead
> of inode->i_state. Use the inode_or_folios_dirty() helper which actually
> checks what was intended.
>
> Fixes: 957a7acd46e6 ("gfs2: Remove inode from ordered write list in gfs2_=
write_inode()")
> Fixes: bd67f17718cc ("gfs2: Fix data loss during inode evict")
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/gfs2/super.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/fs/gfs2/super.c b/fs/gfs2/super.c
> index 04bb4cf787d4..9b723dd591a5 100644
> --- a/fs/gfs2/super.c
> +++ b/fs/gfs2/super.c
> @@ -460,7 +460,7 @@ static int gfs2_write_inode(struct inode *inode, stru=
ct writeback_control *wbc)
>                 mark_inode_dirty_sync(inode);
>         else {
>                 spin_lock(&inode->i_lock);
> -               if (!(inode->i_flags & I_DIRTY))
> +               if (!inode_or_folios_dirty(inode))
>                         gfs2_ordered_del_inode(ip);
>                 spin_unlock(&inode->i_lock);
>         }
> @@ -1418,7 +1418,8 @@ static int evict_linked_inode(struct inode *inode, =
struct gfs2_holder *gh)
>         struct address_space *metamapping =3D gfs2_glock2aspace(gl);
>         int ret;
>
> -       if (!(test_bit(GLF_DIRTY, &gl->gl_flags) || inode->i_flags & I_DI=
RTY))
> +       if (!(test_bit(GLF_DIRTY, &gl->gl_flags) ||
> +             inode_or_folios_dirty(inode)))
>                 goto clean;
>
>         /* The inode glock must be held exclusively and be instantiated. =
*/
> --
> 2.53.0
>

Reviewed-by: Andreas Gruenbacher <agruenba@redhat.com>

Andreas

