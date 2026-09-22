Received: from mail-wm2-f13.google.com (mail-wm2-f13.google.com [74.125.225.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E76C54CF6B
	for <linux-fscrypt@vger.kernel.org>; Tue, 22 Sep 2026 14:06:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.225.141
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790085973; cv=pass; b=Y5kMsQgFxG69+J8p0pTuhWUhdO+qf2SFcgjHenW7enRnCJsHvDVvPxmGTU7ojArNKutOBG64tFanwMUYYl7OFSkkhfA1F/xNwlWOQSbRfRCe+VYKCwWAAba+BkpIsZJpAy8X1yHlyNuzAKsxFDFN4L4WUhwGDJNWIXxHtJNcr/k=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790085973; c=relaxed/simple;
	bh=6V0JdsZmrDPONncSpMZX6xqR02M8d8On8QjmlhG5X+Y=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=udbMdbfsTjozDDYNKBWFcskxmLuPVqqtQ3MLZuFIHz8gBLz3xBIC4BTAmYoGrmcduPshXqObQWuup6l9cIdxZdKhZnO7r/k6YecClkqCNBsAJ0gHNzDXrSL6JdfZXXXyIHIrG8Fy9SfJP6pVk9+oo4qNOftltCS4fhcNKeuUEac=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=ET408zLj; arc=pass smtp.client-ip=74.125.225.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="ET408zLj"
Received: by mail-wm2-f13.google.com with SMTP id 5b1f17b1804b1-49cd4ba9f68so56235595e9.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 22 Sep 2026 07:06:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790085969; cv=none;
        d=google.com; s=arc-20260327;
        b=ndHhsHR+b7Wm5OmE+3KFZDRkpf5PQ6RV33hq5Y76RSUC0cJ7x3K9nPkZiUxEYLwG0H
         Ro5G1pLagN20ksiVxSakXJG2pWKZ35SdOFr5WKvFtjloQGiSlZaEk5INF3SEDQaUJfGj
         q3aTxCJEeXy8Wii1Jh761u9mDLHmV28iQ1+Lbn+0/l2a7ndRVB8mIbsuytfmRZboVSsX
         4HK7z0wwSvm+oXY/Zc0R5kW+MguASAthDFGgxJqiakvZRLzjOJwjMj7bkOutqURioPkq
         s93RL5fpddQWzwA4M9xl1wLa/zFjkfm9KdY2bzryVMigXJTxSAsyVbTtn6erS+S8PzD6
         0e0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=99HU+/JZi5dG2Cu1dueoA580pKUbZlE9+G71ugT35kg=;
        fh=+JJDvhk7ZJ5VLmILUhqfLIFhgV5dXkxnXrxkAXr637Y=;
        b=P2xfSiRElWH6DWVxQqHuvutS4Xk3zBktFzXKwpnGl2VjtrVDXlknzHF9rsZeZwx04r
         rHhsmgkzYWZ1FVtGMKZ5HOopLEpeNg/XRhRahKkg3oKmQ6YN2gTeN6+3S8l20pil6Evu
         A8t7YcJt1USevlqpcLROF+fEnluE4Vluu7ZZkOnK/yxATvp8VnPSw64Uiu1Zw+Vgsvbk
         HjxIY/KJCf+1GfWThJrC/oFF580bKz04XUrZ+qXCM5nxYiUYNg4lipuIXlGFeDOqHawP
         xVWxU21lxAue3Q/y/jKYCfHD9jB6Wf+e1zO/RD2ApTxvABDMpQM+Vy7oGqB8Kw7cqEJI
         MIsg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1790085969; x=1790690769; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=99HU+/JZi5dG2Cu1dueoA580pKUbZlE9+G71ugT35kg=;
        b=ET408zLjAzvCPY64foMxS80uN54uNuNIF6r4skc1oJu90iQbUarD8nhoXqWzkmWAhP
         OzdJ5SUo1qsNughomVYW4y3WageEMhf7g2TKk7Pj7NBIGWZITCafBLL445mCuVOYthBh
         A1C3YWvlMmt70ZJWhzmwhu+Ea0Pm26tvuWp/C7AOQ5B4sMwZGIZnuzK8qYiVQrcDyL5T
         YEZOVdbOCy31oUw1NwqNUH32rEsc4Jl0wWhKRxmhEld4/awf2LbVbWGX/sAXj9+262pr
         NqfMsnnyQ+k6fVEiZhuySOc6iy5v/62FKHzsDsmw0nFaS6lIAYqhPSt7wyRiAYiAFcfl
         ruGQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790085969; x=1790690769;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=99HU+/JZi5dG2Cu1dueoA580pKUbZlE9+G71ugT35kg=;
        b=Vnt4Zz1VXyiSv4LT6/AqhZJ8eBU0E4Uk2yGhJCe+9hJ8R9600AjjZU9o/GwusBPHnL
         Xy1nOOLg7j8ZpTmDez/cvOUwrStM37TVrJGSwd/ePplqudN6UfzjXx9O5qV58cTe/RHs
         Qif8z240hw1737YEwPpy/+aHNYnzJ/pkUnnnbrue1JM7SsKyF5G67rAA+2A3EpMUYeHG
         nfSBGVKU2ACTizhevR1e5nWyh7Mlbomime2OSbjKm0vdMb6qW9ILsNuo2jKH5fkhb5sU
         VL/gRQ4RmJYdyjdIDdLE+iSrZQhonh8B0grhGgeXGJaOnevb73uMxvC0XO+Yx4uDFk/H
         FNag==
X-Forwarded-Encrypted: i=1; AKwUvBytzYTR/bB3f9fGoNCqL1P1lOF4nvb/pdbpcqrttXfmudqHVAgfkl8uJZWZhpqXqFn7632JhbBU11cvdf0z@vger.kernel.org
X-Gm-Message-State: AFuF++mU2z2FkIDjIEtxQ7UzEXC1UOopsyoxeOZtcfw06S1shlRH4lw5
	SQMctrwvXnhBL0bf4vom0lc2CXg8z3FPAkqPkjhsSsOd0+Cef18XABjy1TGQgeiOp7bgsKIl+FJ
	KcWVl759T/aWDAoY64JLHTHtV7iM3iXqk0Qg2gIDxRQ==
X-Gm-Gg: AYBFou0scP5z8Ux7m96ONVUUf4VE1N5R3zIBfxibdt1YpgoEJDxamu/uF+G7gKJOMrF
	ylTdL1j4htjEUManKGHEqS5Q5aoQBZkcSwSahc5gBHLZhLKovl44aIM5oSbwyDWcthHZPxJc7TH
	/FYgxtxhzwWe6kTmP0q6LgqmEYY0UxK4gkIbaFgwWZ6vfNIaOksJvzWPRmDRufgCzrL54lT4Gkk
	V1RzZdrDWeERt85kAruKfXDwZgEFThaMGqU79n78rvNLVeMcYdjb6HXxeHuN4vMDupF5EHeV/dh
	SdtGxNgmmirhPeOFNzn05FqNywrzuIDCAM6ie0yRWPDIwuSQ9IpGpq23R+bZuk5atyjvAaNClfU
	RDcEy5AmpcPg8RkzyagIUK2tDkyhe8g9Zaidcrq0hlAbC47fMO89M
X-Received: by 2002:a05:600c:8b81:b0:49d:15f8:2bdb with SMTP id
 5b1f17b1804b1-49fc568125bmr178646965e9.7.1790085969364; Tue, 22 Sep 2026
 07:06:09 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-37-neelx@suse.com>
 <20260602024253.GD2295@sol>
In-Reply-To: <20260602024253.GD2295@sol>
From: Daniel Vacek <neelx@suse.com>
Date: Tue, 22 Sep 2026 16:05:58 +0200
X-Gm-Features: AclHuK94ZowdPkv8oLMNoMqk3wQaTqmzoE8-Amh55RA3X3wy5PPxpE6ut7cEYZ4
Message-ID: <CAPjX3FdyCWLszDifMeEuT=x=QScr8K-dKsHCyD_bJOxOSQEnMw@mail.gmail.com>
Subject: Re: [PATCH v7 36/43] btrfs: deal with encrypted symlinks in send
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, David Sterba <dsterba@suse.com>, 
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 04:44, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:53:10AM +0200, Daniel Vacek wrote:
> > From: Josef Bacik <josef@toxicpanda.com>
> >
> > Send needs to send the decrypted value of the symlinks, handle the case
> > where the inode is encrypted and decrypt the symlink name into a buffer
> > and copy this buffer into our fs_path struct.
> >
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> > Signed-off-by: Daniel Vacek <neelx@suse.com>
> > ---
> >
> > No changes in v7.
> > v6 changes:
> >  * read_symlink_encrypted() reworked from using pages to using folios.
> > v5: https://lore.kernel.org/linux-btrfs/4d97f35d6f85ff041b09bed33b63446a92b7a20c.1706116485.git.josef@toxicpanda.com/
> > ---
> >  fs/btrfs/send.c | 45 ++++++++++++++++++++++++++++++++++++++++++---
> >  1 file changed, 42 insertions(+), 3 deletions(-)
> >
> > diff --git a/fs/btrfs/send.c b/fs/btrfs/send.c
> > index 89d72d8cb85f..d5256c22fe7a 100644
> > --- a/fs/btrfs/send.c
> > +++ b/fs/btrfs/send.c
> > @@ -1701,9 +1701,7 @@ static int find_extent_clone(struct send_ctx *sctx,
> >       return ret;
> >  }
> >
> > -static int read_symlink(struct btrfs_root *root,
> > -                     u64 ino,
> > -                     struct fs_path *dest)
> > +static int read_symlink_unencrypted(struct btrfs_root *root, u64 ino, struct fs_path *dest)
> >  {
> >       int ret;
> >       BTRFS_PATH_AUTO_FREE(path);
> > @@ -1764,6 +1762,47 @@ static int read_symlink(struct btrfs_root *root,
> >       return fs_path_add_from_extent_buffer(dest, path->nodes[0], off, len);
> >  }
> >
> > +static int read_symlink_encrypted(struct btrfs_root *root, u64 ino, struct fs_path *dest)
> > +{
> > +     DEFINE_DELAYED_CALL(done);
> > +     const char *buf;
> > +     struct folio *folio;
> > +     struct btrfs_inode *inode;
> > +     int ret = 0;
> > +
> > +     inode = btrfs_iget(ino, root);
> > +     if (IS_ERR(inode))
> > +             return PTR_ERR(inode);
> > +
> > +     folio = read_mapping_folio(inode->vfs_inode.i_mapping, 0, NULL);
> > +     if (IS_ERR(folio)) {
> > +             iput(&inode->vfs_inode);
> > +             return PTR_ERR(folio);
> > +     }
> > +
> > +     buf = fscrypt_get_symlink(&inode->vfs_inode, folio_address(folio),
> > +                               BTRFS_MAX_INLINE_DATA_SIZE(root->fs_info),
> > +                               &done);
> > +     folio_put(folio);
> > +     iput(&inode->vfs_inode);
> > +
> > +     if (IS_ERR(buf))
> > +             return PTR_ERR(buf);
> > +
> > +     ret = fs_path_add(dest, buf, strlen(buf));
> > +     do_delayed_call(&done);
> > +     return ret;
> > +}
> > +
> > +
> > +static int read_symlink(struct btrfs_root *root, u64 ino,
> > +                     struct fs_path *dest)
> > +{
> > +     if (btrfs_fs_incompat(root->fs_info, ENCRYPT))
> > +             return read_symlink_encrypted(root, ino, dest);
> > +     return read_symlink_unencrypted(root, ino, dest);
> > +}
>
> This just assumes that all the symlinks on the filesystem are encrypted,
> without checking the actual encrypt flag in the inode.
>
> Of course, looking at the Sashiko review for this patch, it already
> found this, as well as a use-after-free.
>
> I don't know why I'm even reviewing this.

This is unrelated to fscrypt; it is internal to btrfs. Btrfs
encryption is experimental and under development. Not all features are
ready.
For now, btrfs send is not implemented or supported and it returns
EINVAL with an error message in the log before the code even reaches
this point. So far read_symlink() is never called on encrypted FS.
Yes, it can be improved, but it was not a priority right now.
I am really grateful for your insight as I am not familiar with all
the fscrypt internals. And don't get me wrong, for the next version
I'm also addressing the points Sashiko raised. I am sure we can all
work together to get btrfs encryption into a usable state.

--nX

> - Eric
