Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795047920;
	b=wvzgfmha/3KAk2/DmG5RFiARp81ymjDLCYe6ZkIQeVy9OTHBNH89yNOHrMFQWVs18seh
	 WtEXKnU0BppeeHKMrDEBbQ1O2KR/HkzM28o6ff4ecaddQgVsfNO9/aBkf/qC8xdnXENuC
	 f+1/hv1JmpspyfnrgcbAO9dtLLdCutb3+NWk9YB0xPb7foZes8U3BTN7sSU8HtrfaLHgc
	 r5pj6sv/J7vNIZPb0ug+fum3KcAnL2/t3jDtpbqnZ4C8tccZqQQlS5D83vXU5yPua0QEa
	 zr+FPUUOexh82o44eE7ERr9J4AFNu95p26o3IlmkrEMebPKXjj915qRgrFMsreLLG5A==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795047920;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:MIME-Version:References:In-Reply-To:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type:
	 Content-Transfer-Encoding;
	bh=M4+iI66pVBP+4vibL3T75xrw5k3lOfdLMjtLDFVvV8g=;
	b=Q/g2PiPeYiPLHwvjnJ0oeSlEuEmWdcA0k2OBumHvevDgERw7fxK5rfsuLQ998WI1F/7d
	 gYTCEiRlt26z3UaIqr/d1gOQQTOglAO3UxYuq92CLB1o/REsMtoMHPmsK7MSmRKUfMKZv
	 Ghnb4BRootvQA5KzTgp6KCVYkTUE9G4objuxp+xd09vvfbIhnR1sfksVgUjqXeh7HT3Is
	 5fivPfhoSsYtTBL0TDIXUWnl6j8zqtErBWQsTPFgZV0PCmygTb3aUvOOSe/IcXhYtWdMy
	 zsFbbGDauRbixbn/zuihAYQ90qIvQ/sKFzDO3rhjeys1EbLreGb/Ggp5EkIqknllrwg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=figiuMqN;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=cFVw0AE7;
	arc=pass header.oldest-pass=0 smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 52B8360A2605
	for <linux-fscrypt@vger.kernel.org>; Thu, 19 Nov 2026 00:25:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 52B8360A2605
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=figiuMqN;
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=google header.b=cFVw0AE7
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795047919;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=M4+iI66pVBP+4vibL3T75xrw5k3lOfdLMjtLDFVvV8g=;
	b=figiuMqNPSbJSC+rppKYW73jTrxg0F5RFlFTF8isncIxQMPE1WxN7Bn1FHZTvLkpofJq4d
	7m420J1xkEdKbn3Rcx5/MaC0RJqvUstWY08DU3pgmjHol80seQFiw6J/Lwkk9/s2t1SRbD
	9rIFexGnSFloom9KDpPKlHqDR/WtULw=
Received: from mail-yx1-f72.google.com (mail-yx1-f72.google.com
 [74.125.224.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-640-6-uyKBP8Moi7UzNo0If31g-1; Wed, 18 Nov 2026 19:25:18 -0500
X-MC-Unique: 6-uyKBP8Moi7UzNo0If31g-1
X-Mimecast-MFC-AGG-ID: 6-uyKBP8Moi7UzNo0If31g_1795047918
Received: by mail-yx1-f72.google.com with SMTP id 956f58d0204a3-677deb12bceso2354040d50.0
        for <linux-fscrypt@vger.kernel.org>; Wed, 18 Nov 2026 16:25:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795047917; cv=none;
        d=google.com; s=arc-20260327;
        b=Prv6zTVb2kJzxBCifNA5oXymE837Wdf9mSWhQ14NdQxLljNqedea7Yh+xXdh4o3Q4X
         1li0KOBhb2Ty6mp3RiLZ+QpIvu5pqaKEGMadvHf1X5VNXa51wgmdaW4xyPmQHLb+3+TZ
         6VFtZcGIwDROMDIsHYk1XnS4upNWB0IOTM5FP4q3apEDh/S+5R8J3q8mm6arPZj03OLN
         +F1MjvRaMWXNvY6MtpzfsDe2GS2XuJaNJm4in4ZFZVq0qFDokKAuJ8PjDKXYukmnlS8O
         HtAYNy5K7x/KjHwEPMaKVSZhs2cgf4Iy/c4FFjH3Hqsl1ZTJJJVr9S+B0Ey+FJUMzNuc
         lTcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=M4+iI66pVBP+4vibL3T75xrw5k3lOfdLMjtLDFVvV8g=;
        fh=snv+viYVJmo1CG3vmuQiDobIX23UValERvXgy/C36wQ=;
        b=dNpjzCE57I1RoHv4Ni52lrZVWghO1suvLZoKD483eRTYb5V9JbdKVvDGCu2UN0ADAR
         iRKSK4753xnCKR7v7wDZ277ggRDs7lMLmkv4Ztc6RDlQIFNhrrrGdVFp3mkqgC+AxtZ4
         5yTo6N5Y9CZX02rmPVSLYsktfOXtPseka0xqgpY1f7L8dhOQdRgaBVv47cNwKlBt3rUM
         Z7+5tLZNvSD77NyASL/+Xh1IaqkzsEfflcfzgTwdOnel2W68joxYgcvrsXfVuDukxjCV
         RhEa5DmS4JVoKQgiQpdrSoY+vIpv+oiJuoi4Om3a2CHsYHYbTLxpMnbZXSGpHe20LaWj
         3IZw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1795047917; x=1795652717; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=M4+iI66pVBP+4vibL3T75xrw5k3lOfdLMjtLDFVvV8g=;
        b=cFVw0AE7k4Sx3klhOI+hIwBtN7pzKUDLCwxIvf1GwEfUyqXl+PBjIT0RRQORJGI2M5
         cr2BBRmZtSCGNDYE5TPt41nwQkXbpYRg+5nucbc1EyR77axD55D/rR3B9wEO/uO+mByo
         19pL3U/soO/odNlWuJH9T++t7gllhpBDYBkgbumJk/d3GIiLVhUTgGFX/u2cI2o7FltH
         /behdt6HVdhB8gjxhLqdWz+ZcLdeAisVvcqYEqfwiIRg9p2BYheknbhM2KU7DM5iRlJe
         R8KwC8LwBJEykAvLNnC6BIN3sAPeAHyzoBlzurMX0iFs/hlpJIP9XFKvRiilgYXmDhGt
         x1Dg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795047917; x=1795652717;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=M4+iI66pVBP+4vibL3T75xrw5k3lOfdLMjtLDFVvV8g=;
        b=ef5WzB8aSCVPoRvb5b3klGaAzEmrt/L1jI/hoK5ksVj0kDelfoOndamnAyduUdR4Zt
         RX0bi99Gqvgnr4koG/TR6/fjLiXricuuL5CwzmsH+pYIB0IMKliqUWwDkRCw23P+kFXl
         UO6qC6C33taXaR90z1+XU/PV9LKyB2MEhDvzp8iFoKPERXo2xBv8FJzMdvsEOQsi4uAn
         47zqcsV5RYzCAEAqIq4NFqcADuC+96qPzRzj7niuox/7LufeP0E5eqRTHUf0owtjmMOX
         TpiQnHM1tWzwLHIFimaFo4HOTn+QgkwB2+MeVRFdUpE+WXu2dV+qowm6E9Nfo7et1Zci
         Mqug==
X-Forwarded-Encrypted: i=1; AL+hErHPsK6g8dvHWNgEpVXLajGZqIPURhXWi4g+d59ZDFymhrBre3sFJBMAucNiLKHUO3t0w5a2OuMJeJJF3ieO@vger.kernel.org
X-Gm-Message-State: APuU4Z/zSbjNFxo9LP/brg6tcRRqoCA5vCxAKcWd42He7KALxknUzp6C
	PygkbR8aVVy4wTbMAWPlSMoagkZYopRIFv/QkFcH2czaXegFtiVlXcawrr1Oq31U4gmYlnE/Yrq
	yf0rnHOhda3dJD7oZ+JP9ut010JkDof1HMYn/xlbpgn4hNEejlTXucsW3EMhAERoo6Z6Hb8l7PL
	NkkS7xLr9tb7pUtJTMhc+Fk6avXa1G74JtzxJSl6YDFA==
X-Gm-Gg: AZFdTZf04Ct4PakyqECHaM9KT8KzVmBQ54y17z0ct1HO4p9cruU1VHt9XKEP9u+Navt
	gIuv2rjCEPAX5BI6Cby3ani6ugEFOkKxmKnq1oLFqr9owDlMGlcMG5EC+nAyOqtu0l3MwwNE1jM
	Vqx2yGTg+mqyZ5XXD3nh9j1ieTgAZoekkc93wBlLW/uziRk5Ai8jUcQZpRZqeEyhd7wnqzCS4gA
	+CG4Zu+pU2kyPYIA2U3Nk6BXONESLbtATngbfyaYd5+Lw==
X-Received: by 2002:a05:690e:1553:20b0:67d:b309:a247 with SMTP id 956f58d0204a3-67dd3f89d1amr1300391d50.81.1795047917433;
        Wed, 18 Nov 2026 16:25:17 -0800 (PST)
X-Received: by 2002:a05:690e:1553:20b0:67d:b309:a247 with SMTP id
 956f58d0204a3-67dd3f89d1amr1300383d50.81.1795047916923; Wed, 18 Nov 2026
 16:25:16 -0800 (PST)
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261116171044.6938-1-jack@suse.cz> <20261118145941.1063127-21-jack@suse.cz>
In-Reply-To: <20261118145941.1063127-21-jack@suse.cz>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Thu, 19 Nov 2026 01:25:06 +0100
X-Gm-Features: AclHuK8SUbQZgISlLcenRaPXTNhazVJfuhMt4GCT6fjiABD73HgWRuB83sKw5Dc
Message-ID: <CAHc6FU7qgJ1R-bz2icUyQTQFs7_mKt=tat-ut66K-cgn-uet3Q@mail.gmail.com>
Subject: Re: [PATCH 08/13] fs: Provide inode_or_folios_dirty() helper
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

On Wed, Nov 18, 2026 at 4:00=E2=80=AFPM Jan Kara <jack@suse.cz> wrote:
> Provide a helper function checking whether inode itself or some of its
> folios are dirty. We'll use it in filesystems instead of direct i_state
> checks. Note that this check returns true also if only timestamps are
> dirty when lazytime is enabled.

This is confusing. Can we just say this here?

"Also returns true when only the timestamps are dirty."

> This is what users really want.
>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/linux/fs.h | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 025f5d890689..f602deacf953 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2228,6 +2228,13 @@ static inline bool inode_is_dirty(struct inode *in=
ode, bool datasync)
>         return inode_state_read_once(inode) & mask;
>  }
>
> +/* Check whether anything in the inode itself or its folios need writing=
 */
> +static inline bool inode_or_folios_dirty(struct inode *inode)
> +{
> +       return inode_state_read_once(inode) & I_DIRTY_ALL ||
> +               mapping_tagged(inode->i_mapping, PAGECACHE_TAG_DIRTY);
> +}
> +
>  static inline void set_inode_metadata_writeback(struct inode *inode)
>  {
>         spin_lock(&inode->i_lock);
> --
> 2.53.0
>

Thanks,
Andreas

