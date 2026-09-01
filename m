Received: from mail-wr1-f52.google.com (mail-wr1-f52.google.com [209.85.221.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7DBC36F905
	for <linux-fscrypt@vger.kernel.org>; Tue,  1 Sep 2026 06:49:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.221.52
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788245368; cv=pass; b=nN8xg7DSBsxpk1atBihl02IpuEyq5wnOiUVTuIgDzU8UV7gM4+sbVYOPhG8/UI6y7YjKpPB9PtxlHYcQKEr6NiYFl+zbB1rp7sUMUKmaIccxAktoaC6/ZKfUBebbjFk3w5FkJ/0oNTBsuMwHwhiybekUAQC+MeZFAYBhYASHviQ=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788245368; c=relaxed/simple;
	bh=oNGTPV0Nte2s7Q4Q4v2+7pT7OOG+CNawxlnpt/7u8Oo=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=d27C7Yv+4k4BvZaEvsUxe6rGgwUV+W6rqhmD2/IumS/yFVXqA0OMkmmEvfAITfb+0ZW6ypHqo+L7cJjVNtZJOX+gmRGbTsDVnMNGCC9WCCz+c+bGIFZGtY5itV52qMTFsQ81/Wv4AeiaNcTucZOJpdnqHxwyNHbsmsCqmPzldbw=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=BpsrGk+A; arc=pass smtp.client-ip=209.85.221.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="BpsrGk+A"
Received: by mail-wr1-f52.google.com with SMTP id ffacd0b85a97d-482e61a34e5so155133f8f.3
        for <linux-fscrypt@vger.kernel.org>; Mon, 31 Aug 2026 23:49:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1788245365; cv=none;
        d=google.com; s=arc-20260327;
        b=cvkKSoSg+6v/WkK0YW67l+IqjDtieLbLA/Sxe1tkzwY0ulUgK31OamONEwT/2eLa2S
         dlqQnNlsxaAqDNBBRj9dwDopjgrg5zFi63OBitEA26amERHJyyiaUcFwLc+Wzs0QwYIi
         IokwfKu/HHbigVnML9bCJhnD22Mi1FBnhVJChQXK5AH5+0dx/VDx6L7vWqq/yVKP8tYp
         1YPkc6ChjGKE3/a8VjfA15xm80X5WfE1hSKXEfPMMEfsINkGJ8/JrWs/87j2im5c1ZJg
         GXyhJ24jPIIRXuikL/E8pZi7dE0eixNPJeL/PbB5fsfG/cWr6N1pQUZYD3zWscsFbjBP
         UUZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QZ0kwvuRo9QIP5y4Kks1XO3hGegOKMFKjzEnWHMijtc=;
        fh=zvICeMuv0rH7dgdnzOjgoUKrOol1XgUvXovab9k8hMU=;
        b=fTSCcRz3tBQDi286iI0+x+yopvnm1tAiW+gyx0WJQFjOG1lSx6NACEE7RzwrQQUAQs
         wwoUwjCMhOGpjzb3tPAVLdhyxyp3GX6F/LoLf2PxGW5UEOLqp4lwz/PYL+CqlHGvQNb6
         sxizFd1zQqO4QXJe/9mNnLaYQtNhzIl6WQ0tFkQmjZQ5MgPWCGuVminunawrGIWNjUGB
         mpFUK7qDbcb/vkd6/Qggv60ATpruUwRBL6TeLh83rHHf9ZmhLdRWqL9++rlx6ig9VIMT
         0dRyUyJbpLdETgCz+lzJ6ouNnCVcd7UE0U0tUKhxMlLwB1PacbWhG+E2iNPgQ+rMltBV
         TU0w==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1788245365; x=1788850165; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=QZ0kwvuRo9QIP5y4Kks1XO3hGegOKMFKjzEnWHMijtc=;
        b=BpsrGk+AP0QMLVKK63eMt9ayptIxw6Zo84n0T/bxYqygIWWDqt4o/f7vLmokBi18SI
         VctIFLw9q0fX64w0+LFO2ybgHFe4GeTREVbQbJN0/5vRwiCdVcN+Mmb5pOZjMpSA1Z7S
         kpvvZ5kIjaP5SjelpsK9pH5Zn0bOLdt6MiOYZXQZA07Wqo+yFVMLzh7sj8oUUKWeHR8j
         yCLsdXRoqhTeTP0CsH1qkUcupJQWoaBjECmFeOaY/xC1Nnh5J0vl2fivHai2xI4JSNRf
         HiMqGBnS5C9GOh66r6Gkvn4i4kkGwvYPy+b+XqfEnZFAwmtqLBp9uwiJagmWlwZlh02t
         NsVA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788245365; x=1788850165;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=QZ0kwvuRo9QIP5y4Kks1XO3hGegOKMFKjzEnWHMijtc=;
        b=puGJBSMWNk3fSwD1ZuCgr4mtcXeg/Lfj4P50Sc0p5O/3eXxssjzxEdofaPqTKNP+Wh
         9SBI6HKwMIiF8qz8ZZmFBFzsir+4Bfq8Rc4rqxS9Py0KCfpzvARhMdbDDNmbF3u8G8c2
         +9JLFhlFhRIu7kwRR7uEJnlQqcUAwWe2jKu2QMubn4ayG8n2nYR0KrII39rs1epKGkCT
         Kw3p1Ozj8mG+rWQyyqjPNn6kILhXMOQNQwobiV4ktamwR1W1DxQZMLMPnK/nhGu8DVcE
         ylBKcusWYoIu00bBXqh6oKYmeIvW3hEltmP9H/g7/iqDf63HJMAl9/Lu2N5BYAaRq6kB
         c9vw==
X-Forwarded-Encrypted: i=1; AKwUvBwyaxGWTVPpTgr/zcWPOi4HJq6f7N5hbAdAFNNuUyKj6Nit4wSzZle+sfFczloTyjjIZSx5qoNbk+zbpHr0@vger.kernel.org
X-Gm-Message-State: AFuF++kgye9ZlahvFIvygrAn286o5Opa3I5o2TlPnWcdiN3eO6On7+DF
	dO1pDrjWn1FS1WSh5QA/I/B4NZ5XmYcOqn4iKW4U+kMA/K274p1FFP9erPg680OJPpc3FQEkU0p
	kzQoDsjcozKuBwzyYtWA88uHjRvFTXbn0+7Y2KbNkww==
X-Gm-Gg: AYBFou01GAGiGCBiMRORqJ/cMAQNa4I0xpTBhlxC4Llej12/8ytZRbfqX29dSyJbiiS
	1DPzj8HOrTCmgTgSAMNimLaB1YqHUpp5/tzuinIkTXdq5MLWklNFWdCedcIyQlMIChLv1JHh11H
	zeQq/wJemfLMV1Bp9qmwoPW8t6aIX2yT/3IzqqTQr5ZusXGDMxv02yP3aAR8sF2ZLVlZEbjjPiZ
	aodyqSCP92sMad1hgRqyk6i1JAYTxMZlh+NGP8maBuCWTm6bQagax1QL5RoK6ARjq86KN/zbi2K
	FEOaSlbKP0+83z2BUUB8Wbzwdh0dRqIpP0VNi1yyGHjLoasWCaLtnuR6rNA5ai3s5CE/t77d3ld
	PZVTrNFc41V3nZE9BtQf7GHE8SbnEQr6Cm+kwWUBDQg==
X-Received: by 2002:a05:6000:4605:b0:482:daf8:a3d7 with SMTP id
 ffacd0b85a97d-482f7987c26mr52155535f8f.3.1788245364933; Mon, 31 Aug 2026
 23:49:24 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-5-neelx@suse.com>
 <20260601230406.GC25574@quark> <CAPjX3FdMBAbz9T5yW=0ytRJD8s6zYHpo+TcYY-9-+egBHL=TFw@mail.gmail.com>
 <20260819155907.GB133077@google.com>
In-Reply-To: <20260819155907.GB133077@google.com>
From: Daniel Vacek <neelx@suse.com>
Date: Tue, 1 Sep 2026 08:49:14 +0200
X-Gm-Features: AcwNN1WkYRRvmrS9cx6H6wX9ppPbN-o7Vdk1JkhuHWMyozjsn6o2JUHcNtEnIsk
Message-ID: <CAPjX3FftK4tz7d-MmwMbHTXbz4Y9L7=TmxkDNnMfghrPtvbqxw@mail.gmail.com>
Subject: Re: [PATCH v7 04/43] fscrypt: conditionally don't wipe mk secret
 until the last active user is done
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, David Sterba <dsterba@suse.com>, 
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Wed, 19 Aug 2026 at 17:59, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, Aug 19, 2026 at 04:22:23PM +0200, Daniel Vacek wrote:
> > > > +     /* We can't wipe the master key secret until the last activeref is
> > > > +      * dropped on the master key with per-extent encryption since the key
> > > > +      * derivation continues to happen as long as there are active refs.
> > > > +      * Wipe it here now that we're done using it.
> > > > +      */
> > > > +     if (sb->s_cop->has_per_extent_encryption)
> > > > +             wipe_master_key_secret(&mk->mk_secret);
> > >
> > > wipe_master_key_secret() is idempotent, so we might as well just do it
> > > unconditionally here.
> >
> > While this is true, it also (kind of) documents that the secret should
> > already be wiped out by now in case of !extent encryption.
> >
> > But I can wipe the secret unconditionally here if you insist.
>
> So leave a comment that mentions that it's not always needed.  Just like
> how fscrypt_free_master_key() does kfree_sensitive(), because why not.

Right. Thanks.

--nX

> - Eric
