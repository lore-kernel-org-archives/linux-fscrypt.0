Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 012E13B4EBD
	for <linux-fscrypt@vger.kernel.org>; Tue, 28 Jul 2026 05:44:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.44
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785217491; cv=pass; b=K1JxKFtBuFLdM+8sJK/o+zQOogkdjsEjOlz1aR/tIZdGG21f3WHuU2IG3jO8yDKd7p21gm1oG2Dwh1ae04X0g3lOx4pRJQq6N47Y2SRhDOYp6NAl3c9HQXlvC1lPBY0P6kr5ALTJLYR8DDrQMQj0pxpBLYD9OZhi0hRDaJsDleI=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785217491; c=relaxed/simple;
	bh=YfjN6gu+ln7t5y5mDONTsNJDbtGDekxXLrfrMU8/Ds4=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=CioXhClISyEelhB9BMOhMoDr/cHaEnVqI2MAqMlhGUsXaIRVZSrLFsKSC3X0KWwfdGF5XRgIxTJ3ygZM02h9n3lyuBLdSvnimSPEKKiqm3K56Ny1BgfUYmrURlVzfpHuR4CV4UoiSj5Bo6PUvs+mlOQIc5wvgP7L1lGfQPoj4sw=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=fBjaNva3; arc=pass smtp.client-ip=209.85.128.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="fBjaNva3"
Received: by mail-wm1-f44.google.com with SMTP id 5b1f17b1804b1-496bb7cdf51so18463195e9.2
        for <linux-fscrypt@vger.kernel.org>; Mon, 27 Jul 2026 22:44:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1785217488; cv=none;
        d=google.com; s=arc-20260327;
        b=EMsTs3AmKLx2YKRaSyAz2Tj5BqHWU/eiR+aXzRsNGrX6ICA0/BpkcwMno2w8+ocMHv
         mJr7p3Vn9nRQ8IHYvKOc8Ro+ATjjauONbSnFh1yhL0DXjSlw9kLdHz7eWWruVkeyqfse
         WZ7+TnOsHDnBlJCAPFpFl9HBrlX3gaR0pO3J65OyI8V87M/LhR0/O5kSRDPsjV7wE/7/
         w/rYYGK9wVZZ3LhljhCKDTepXkvBZPTHsPJotBH6Udx7vNHtQGfYkrBw4sfIc4OVeF6k
         RsKHcl2zQONH2JD+RCSQL7r+RdwTcNEY7DnYTmh2Iquim4A8LI6pssUppBYrVksm/xci
         2kow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YfjN6gu+ln7t5y5mDONTsNJDbtGDekxXLrfrMU8/Ds4=;
        fh=1IyYLPexakdVIldzypdToqfxz0/elpt6aYBE9QEvRuo=;
        b=PEh/bI73wGRZ9VvxGZkBDlPg2PvgI2Cv2N/990KF7PAI3TStjNP3N4TSRqZ+Y+sBrd
         l/LrHk3kBgL3xJ7yL/Eu8Jje4iSKXxEMIktfoB/StUOB+c6/pfjlC3jwDWOmDClHE9Rb
         b3iN7iugXLOKf0Rs/Y8N20a5dTjxvPkGdnrV2AoraSS0Dql5CKyeC940mzVFy4JPCf5p
         Z03l0AlN0i3FNGXALOVIpCoHZCLY3a9Swk6DPsap8GkPGjLkgc82lfRuEMGdIs8gdT8K
         YsQ9A8R7oCr8VztvRriw9xqjoresvS9l4evqZ4GEFtnI7KiplgKJzFw850uY/NbCye55
         id3Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1785217488; x=1785822288; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=YfjN6gu+ln7t5y5mDONTsNJDbtGDekxXLrfrMU8/Ds4=;
        b=fBjaNva39tUoIh3WdRtYTNHX6lXws0r73HuX15d2GPSulNVAVJug2chPtRkCxBctrT
         77fgXWVjRq4svwy/4Iy/mHq2Mf7BuTmIUSZgxS+pqU2tddt6Cz1jc+ba+k++HVdERP2u
         YTlyXEcjikO/XsTWJ+Ib7KoTgYlhV9JyoykvLCA+vLYLlDNa66LY8AA6t63oh39o+Lrm
         wDW/eKsE/q4VyshhT2rSJtcOjGvHaxZDnMcjzV0nygT/7ef6EezQbO67EtJgUo6U/DEU
         l2XoUeUA9dAonr3rbYVmbYUzoHKkN9KcrZ6/3wHbCjbDETMdv9MpHyAbC8TRmJQ3hoe9
         bWXw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785217488; x=1785822288;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=YfjN6gu+ln7t5y5mDONTsNJDbtGDekxXLrfrMU8/Ds4=;
        b=KjP0y3crvpSc9uo2fNjI9pa/QCoFwBi0LK3sMjo76hdTzG0UprzZhpZEgrpNqykNoH
         C7yApryWcZxjaaWK4WcX1xPNM2paw8h6WdUeXMpOU/Vv5ugJQ6QMYwRCgBAIGr6L8+wZ
         irC1S8Dw1k3/ni5kISSmnR3+3Ys+4DobnJOBW+a7F5N9QjoODC00b1JN5ZffS55XGzCJ
         9vwmCbE0UyX05CWd7+3kVOvDlwQAJN6spjgnhR/v2ujj0Zv/+o1cD1s/oq4NDtHZIQH7
         wUdYomOlaEX56KU7pqiureN47Q6VkdIzSJ/lBGoPrVHrKcKRMmiA7s1sEV39qckAD3UY
         f7Bg==
X-Forwarded-Encrypted: i=1; AHgh+Rp3kmLQpKfDCTh+4s72Yk4+FlsjuQoovtcKg4MHFltRKtacCHtH1fIRx8HX1K0+surTQjxbI+vXeDPbpvyy@vger.kernel.org
X-Gm-Message-State: AOJu0YxtK/8N7CccRHfCN2ntq/NpbdggdyvKsxck6pTWbQ0SO9TLKopa
	8ajLEuCUQWemWaiQG7jgTMRBc3Lz0YcHLfBmJ3Lc58+bgtlE8qu1dEWcRYP8tz2916WG94xvaVX
	BCZOful/plElIuy0A8TDDVOUEK0hOGkq3Y5lq/suDP8dXu5mPXFz+m2S2/g==
X-Gm-Gg: AR+sD13e7JFZPgnPwuuNdgtdNPOmZOboSiMv8PwHm/LNENWBv/9+oxdN8n7X5taN6Re
	sTVbQfcLA9vgKXAsBsMUJjzlGTF8ToDBLYsvcvybwyJkG4oTnzNkQxTHCh6ny9SaibE+YcA4FIT
	cfSe/kLhlNO9IN/VGI+LfKqCAxftFxyh0NO966IK4d4+5FpxzPSQaM+v13Hw62q3zfdb78K5sKB
	sqLcVaY8YYTz9DmOMu5aKm16/7oBol7/GQiRVtb81B8aRFyBUu3b8abdKkQmHU+uiMvHTjvYjEl
	r7Ef6OmhFPdSCU3awiZV7Qx8v7dc3VYfnsGrxNX+YdVEgpu9HvzNHqj6rGI=
X-Received: by 2002:a05:600c:a012:b0:496:c18c:f9a2 with SMTP id
 5b1f17b1804b1-496c6586ad0mr8148725e9.34.1785217488357; Mon, 27 Jul 2026
 22:44:48 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260724133328.1837318-1-neelx@suse.com> <amgfuk12imPN2XJe@infradead.org>
In-Reply-To: <amgfuk12imPN2XJe@infradead.org>
From: Daniel Vacek <neelx@suse.com>
Date: Tue, 28 Jul 2026 07:44:37 +0200
X-Gm-Features: AUfX_mweqQ4DC10RBxGq9-w14Z5dbzAU5cW-2aUZfLxC0EG3IWa7sp-qvz-yJvY
Message-ID: <CAPjX3Fd1KPswrsNe=BeDpkDwi8CmL9HNKcPScMsgGN16MDyVEQ@mail.gmail.com>
Subject: Re: [PATCH 00/12] fstests: introduce fscrypt support for btrfs
To: Christoph Hellwig <hch@infradead.org>
Cc: fstests@vger.kernel.org, linux-btrfs@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, 
	linux-f2fs-devel@lists.sourceforge.net, zlang@redhat.com, djwong@kernel.org, 
	David Sterba <dsterba@suse.com>, linux-fscrypt@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Tue, 28 Jul 2026 at 05:19, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, Jul 24, 2026 at 03:33:16PM +0200, Daniel Vacek wrote:
> > This is a rebase and cleanup of older patches [0] from Sweet Tea and Josef
> > fixed to work with the recent kernel and btrfs-progs changes.
>
> I'm not sure if you post this just for reference or what the intent here
> is, especially with a cover letter like this that doesn't have much
> information.
>
> Before we doing anything for the btrfs-specific fscrypt changes in
> xfstests, those changes should be accepted upstream first.
>
> Maybe some thing like splitting tests might make sense without that,
> but then it should be posted separately.

Hi Christoph. Thanks for looking into this.

Yeah, I could have been more verbose, perhaps also using an RFC tag. I
wanted to get feedback and a review from a wider audience to see if
this is a viable direction. This is currently the base for my btrfs
fscrypt development testing.
Especially for upstream fscrypt changes, when sending those patches I
was asked about tests support. I understand to keep fstests OOT as
long as the kernel part is in development. But at the same time I'd
like to make fstests complement the kernel part and ensure they are
ready and available for everyone throughout the process. Kinda to
"bundle" them all the next iteration.

Would you suggest otherwise?

--nX
