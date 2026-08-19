Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 23CED3B9616
	for <linux-fscrypt@vger.kernel.org>; Wed, 19 Aug 2026 14:22:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.221.53
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787149358; cv=pass; b=pkN79dq0wgClWjfacv4NSoppA/FUhrEgn1Nn8enXjLujVcULux0hPzuGrkmOA6avBZLgvnCl3JnRr1rorMxzKQ9TcE+c0rHcroiyN2BoNtjFRMVOJp4sHNyegQG2GljIF2y015VaHuAh/KadDWznF17D2Uiusz303mtrgj1Ap7A=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787149358; c=relaxed/simple;
	bh=WL0CzJuCKxnFNyuks1xwgxS4AVbpYe5kVLC/zCyuP48=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=OVWY3SsapysJB9gfUDUU8B5xYQFmahAnIHYR4CI8Pq1RDk+PQaNQTSQoj6b5s+KlzvUkNFs/HWjPHw805axSWst3YQsImV//ilR2d11DzNMRycdqjvUYEGvQosA+hYxFF1KvJtancVteiBwCLg3f0TWADRSnCHLOCAR9L0P29ls=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=X55aiLUn; arc=pass smtp.client-ip=209.85.221.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="X55aiLUn"
Received: by mail-wr1-f53.google.com with SMTP id ffacd0b85a97d-4799b3f7c83so697738f8f.2
        for <linux-fscrypt@vger.kernel.org>; Wed, 19 Aug 2026 07:22:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787149354; cv=none;
        d=google.com; s=arc-20260327;
        b=EeZsbbSV0JXp5xGJbnYCoA6E+9yngkdU9x7S8E/b3N9OuEaiJublC7mFUcXgSxlHQa
         w0fSKtaGEkqMlqs4Czvh7y/9M8L3ZyKlNT8YAiOV8TYo7hpt3eC9wHN5Gz+Yz7S2lKQ1
         ynx6kFrYzIGsY70VF1iEIBYEKyTwGoiX3qBYEzyUbOLk8UaD3isQDR/1Sfy2UkdGVFVF
         yitoJRkhjaa41namQAivd+0rv/bfO4JO4cf1O9ofAhRX3j05nBWkFYrqDyQGdew+FxtK
         Pm1zxyh6si+9seJi2TywxS5BrcajYBcTL6dKlBfeihSKEJtn5GWWu9efwwcPkG5im/Nf
         UoRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cQvDWR+gFuMyKUr3DP+1B7x5IuCKckvrgbg8XFRCHiM=;
        fh=MXnCwGWSCkALAq+x5cIxZ+kuhRsb9xa8GcRMD+6xC7o=;
        b=HAtZbjx4AzHl5svuNthee++eQFcVqevj4pC33lfFiIcNOW5G1Eg036wf6Is1D3qEqO
         np8DoB5mQRnT/pny5h6RE6UvI81sB7oO3q9QKVsCwbYPakCeKmyMiaQT/sygZ3TxnhLN
         k691NqN7tg+jRq+XZDcEfWxywhNyJzJLNapnqBbPk83zsqibvKU6HiKUnaP+ZwCKeFTv
         ZyfsERsJM2Jah3TufW3O5RrpuW5hFl8Snhlk25AZtXnuz8fXXi0M9Zu7iBNE1iEiJ4JZ
         BYGBcm3t6MCUu32Zk6Io3iKmZXubDGILB0pPZ2T+mHtMTGF6ik5gAbZh3nQZgBbg72jQ
         ilIg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1787149354; x=1787754154; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=cQvDWR+gFuMyKUr3DP+1B7x5IuCKckvrgbg8XFRCHiM=;
        b=X55aiLUnSO9BWT0vC/lXMnlXZNsGts0j+QV/FUoakYVLv53le8mps12TvXy7doKZjp
         +fNMDkmKY1T59u8G4gwbzoaVg8avuroLpRcS4cLvC+ymUKF98RtytMbZat4iqvLp9vHD
         dEwsy0uHUjGzuR+Kwa4OCDeP53+Lcx7jH815GBFUqgZLBuAyg/f75zC1/1u4dSbtc0AR
         H4kUoQNQoInUBKBYo4vy1xKhHNHtGUgiLTq3SdahS5ftFsYL3FTeHE6Aqx/XDFib2A++
         fMlGZLXIa4Lruw8j+nFupztiBGR+ALRima4Y2j5SPLHnXA6IhrhNg7WqFD6fgAeeNBJu
         qsgA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787149354; x=1787754154;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=cQvDWR+gFuMyKUr3DP+1B7x5IuCKckvrgbg8XFRCHiM=;
        b=TEIp4lbPl6kHC5KBT7RvOm/YUgg+kgIJtAZjV9pLHoTyNrzV/bOIy4dmOvewGRHcH4
         Tnj8WhqZ2igZX1uttS14EvhGup23Mzx+TJWsNENPvK8wU965m/j0jrRV85s6K80dANfv
         Iu10yb87rOiMa+5fNbIEDAl78HosBCoLijdfqD4TCJx/xbKA/11JfVQqO1NdX53wQhoS
         pyXwoijbiib0rBPgg5DyJYflAn6QIrtuKl9oIjoaZexF5lWr8CeP/3yp6mSFWSawZqxk
         jvljqdJ4SiasnL77brvQYCGWdGd64RR8DOFkiqtC7IIUin83ityysqO8gpwPyB+um3ND
         CNGQ==
X-Forwarded-Encrypted: i=1; AHgh+RrzxG0qsbXxOOp+QUZ90tPuN7ZRbFURWRixnghPofkD21SIvmj2HpT+9eFvXKfra+rjdSrKtHXoTkDfgMlh@vger.kernel.org
X-Gm-Message-State: AOJu0YxNZ4fcKy4ViENiiVACqkYhqojXfmIKZg/hiinwTZY+KYGVpoVr
	aUBWoSTZwHhPFDnmrhF4KqLeGpnKBCn0cHMrRzDwKFS9owY39omK5r8j8Cb3wmIt/FuRaKS6+sE
	NOEP97r7WBwQ9jAAOZl121L77xOSDejejO9b9873uzw==
X-Gm-Gg: AR+sD10UW88d7Dk7BXY5nhmN1/eAHY0frtKCOdr7Kt8DtsjdrEG+bW2QGj4MI6VJUPM
	/ADeV0t61ympKcsmsoJ8aQJC0dIJC2NBP7xhmazEsfxat8pOamCOTxqeCvX8+kU1Bj7G8/eE49/
	ft6Gk5SxwbOG3o3Prp6mVjyZwsJZKfgwkAIPn1xrH214NV+U9qliM10J61pZh0QNHfu+fTjWqc2
	yYAwUZKQJdcvpar3ZHDHhxKAHHvS3FkWxeO3rjNp8Elt3dxKX8pIXV5cZ4UTvvNE7mCeEmMLEBn
	BtyQGRPzdPnGoCx9+m7dhaX5uTaDGX2dNl+hVhxg91xtUsiz3CCkiNup0bnVrzFXS5N95YvnQ0F
	Kl6pk4LlRzzin6HlXTIrzO+IAxNYNsI5PPORGWBtYr29BNz9wNG+2
X-Received: by 2002:a05:600c:a012:b0:499:52dd:c1f0 with SMTP id
 5b1f17b1804b1-499aa180132mr108268535e9.1.1787149354463; Wed, 19 Aug 2026
 07:22:34 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-5-neelx@suse.com>
 <20260601230406.GC25574@quark>
In-Reply-To: <20260601230406.GC25574@quark>
From: Daniel Vacek <neelx@suse.com>
Date: Wed, 19 Aug 2026 16:22:23 +0200
X-Gm-Features: AcwNN1WuVLXRwMTVjG6424GkTTp3P9BzGVQP00nzsthmGhd0KVAoGe8C-GfV4As
Message-ID: <CAPjX3FdMBAbz9T5yW=0ytRJD8s6zYHpo+TcYY-9-+egBHL=TFw@mail.gmail.com>
Subject: Re: [PATCH v7 04/43] fscrypt: conditionally don't wipe mk secret
 until the last active user is done
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, David Sterba <dsterba@suse.com>, 
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 01:04, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:38AM +0200, Daniel Vacek wrote:
> > From: Josef Bacik <josef@toxicpanda.com>
> >
> > Previously we were wiping the master key secret when we do
> > FS_IOC_REMOVE_ENCRYPTION_KEY, and then using the fact that it was
> > cleared as the mechanism from keeping new users from being setup.
>
> This seems to be describing the state prior to commit 15baf55481de, not
> the current tip of tree.  We do still wipe on
> FS_IOC_REMOVE_ENCRYPTION_KEY, but there's a separate boolean that
> maintains the status and everyone looks at that now.

I see, I'll clear that out.

> >   * FSCRYPT_KEY_STATUS_INCOMPLETELY_REMOVED
> >   *   Removal of this key has been initiated, but some inodes that were
> > - *   unlocked with it are still in-use.  Like ABSENT, ->mk_secret is wiped,
> > - *   and the key can no longer be used to unlock inodes.  Unlike ABSENT, the
> > - *   key is still in the keyring; ->mk_decrypted_inodes is nonempty; and
> > + *   unlocked with it are still in-use.
> > + *   For filesystems using per-extent encryption ->mk_secret is still
> > + *   being kept as the per-extent keys are derived at writeout time.
> > + *   Otherwise, like ABSENT, ->mk_secret is wiped, and the key can
> > + *   no longer be used to unlock inodes.  Unlike ABSENT, the key is
> > + *   still in the keyring; ->mk_decrypted_inodes is nonempty; and
> >   *   ->mk_active_refs > 0, being equal to the size of ->mk_decrypted_inodes.
>
> This is saying that a bunch of things don't apply to extent-based
> encryption, due to being after the "Otherwise," when in fact they
> actually still do.  So the wording here needs improvement.  How about:
>
>     ->mk_secret exists only if the filesystem uses extent-based
>     encryption, to support key derivation during file data writeback;
>     otherwise it is wiped.  Either way, the key can no longer be used to
>     unlock inodes.  Unlike ABSENT, the key is still in the keyring;
>     ->mk_decrypted_inodes is nonempty; and ->mk_active_refs
>     > 0, being equal to the size of ->mk_decrypted_inodes.

Agreed, this sounds better. I'll use that.

> >   *
> >   *   This state transitions to ABSENT if ->mk_decrypted_inodes becomes empty,
> > diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
> > index be8e6e8011f2..796e02a0db25 100644
> > --- a/fs/crypto/keyring.c
> > +++ b/fs/crypto/keyring.c
> > @@ -110,6 +110,14 @@ void fscrypt_put_master_key_activeref(struct super_block *sb,
> >       WARN_ON_ONCE(mk->mk_present);
> >       WARN_ON_ONCE(!list_empty(&mk->mk_decrypted_inodes));
> >
> > +     /* We can't wipe the master key secret until the last activeref is
> > +      * dropped on the master key with per-extent encryption since the key
> > +      * derivation continues to happen as long as there are active refs.
> > +      * Wipe it here now that we're done using it.
> > +      */
> > +     if (sb->s_cop->has_per_extent_encryption)
> > +             wipe_master_key_secret(&mk->mk_secret);
>
> wipe_master_key_secret() is idempotent, so we might as well just do it
> unconditionally here.

While this is true, it also (kind of) documents that the secret should
already be wiped out by now in case of !extent encryption.

But I can wipe the secret unconditionally here if you insist.

--nX

> - Eric
