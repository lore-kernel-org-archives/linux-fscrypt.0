Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9B62423160
	for <linux-fscrypt@vger.kernel.org>; Wed, 12 Aug 2026 10:34:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.41
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786530866; cv=pass; b=Vu3TW1T1vF44xHRIGxe+Qt1R9rTeFytft0vlHZPf0ablnwkbucOmwlKfwpD4TdMNxJR5miu3m3RsZKH8Ua/YhzX1sFI33k14yweK47Jzhz5SVzDc2mOBjFmS1ZSRGBGLP3stN8fF/k3VTRznBXsx8Ev/YbNsIxpLXffl34zy6xU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786530866; c=relaxed/simple;
	bh=Mrnv8sptG1Ixrth/QH2KNpCMMGrMlDSEWTfDRFXg9Y4=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=J5bU+BbonwOpCUrCTBop7DDcTWVfIuR2zE1u9wK8tO8WxaSTbpSRydsCqLImx34cpxW5KclYJh9rEISyjdLTB62ictvz6alCmVuIRi5/R7ATvrke0ldomRVMcSftMFr3TqUP0d/T79YM5/nHizQhGTebwYKUpzNzfih+U8P5W8Y=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=PzFpQfz+; arc=pass smtp.client-ip=209.85.128.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="PzFpQfz+"
Received: by mail-wm1-f41.google.com with SMTP id 5b1f17b1804b1-4994c49f588so8024005e9.0
        for <linux-fscrypt@vger.kernel.org>; Wed, 12 Aug 2026 03:34:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786530862; cv=none;
        d=google.com; s=arc-20260327;
        b=YY0vnRiInCfakA5op+BcfG0888IvNNVrfgiPEOqC7aAykIqyo1j5EY74PTtviy9xor
         EMG8JzCu2Femr5WToxefNelD6HbeyaVjbhepHM6Dbrum+cnA1imhTiGxiC9ygrrUkZxx
         Mnswfkc3Etxr2WkhcPocquS76f7e6BVFDhPzKatOmFIYPIsaTmUv/tKJ6avZHNXczako
         0BdTEQ1Szppnag+KnrqE4TO9w+v48Mn7m9KIqar1qRXRWCjR/3Q7DAr0ZhLgLxUP/k3d
         oBwv1Ts7VOUNGXiiAZcSI3imXysGoUonfs9CZsOuCODkipcW3/PlNcADjzCkB1NQFRvh
         dQTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0opKHY0hArTd0tLmaIUqxiwMIhkUQB0s3SgD4CDSLQE=;
        fh=WKzbHNrpn1zqL82uUF8hfXSlgBvSrFQmFNA+8YpDq/E=;
        b=rP/eyFA2S+xalCsnutAlASgMPzLSR8XXoFhy94S3e58BdNaM6hUYmFV1ZqqzfW7PgM
         Ivb0DuBjT6s6kdNs2jR9CmBjDPNibD/MeTEoUIySqVhyhRza91GhSGIRWm8oBb+YoUWx
         HhFUa0gwSpAk028335P0v24+8DLDya0sVVV5FwsQ4CpoUEjiLuim5fI3fTgc7yyAzFkT
         gas+mtboEnNE0GxN7hcir2Pdf/HuYlsE5mdI0ynM05DiraeD2pqYvPPTfdD9xHDqv4NF
         cJpQ7bw8mIatwLylVcJ0HP18TDEV6ZmMP+9s5FHBxhVn5IbbLauvGrp5u5PgTI3xjTpC
         uOAg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1786530862; x=1787135662; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=0opKHY0hArTd0tLmaIUqxiwMIhkUQB0s3SgD4CDSLQE=;
        b=PzFpQfz+OwwVKHKttuRsZ7YV6zAePuAq84R1i8RDKBAGu02vNrgnKFzYGEx3URWAKK
         2VPb/3tMjSRUH5MX9Baw8KByEv6mslhJ9o8zDn9S9kZ60DZOObssBfUmiKzQvqRJpAjD
         YPqRp5XzR8kw3VGrBLYozqkU1wQnc2aZFXRds7ozjyFwNKFkuROBQIswg+N9ZRLQz/ix
         dsy2roUSFdxa9bogb4SUlDHcbp7byT/ZPdEBo8UJ8wr+VwfboT/yOPVHvdEeGC6xOrGp
         f0PKZxsQyKrlcrD3YEH4OvqQ35PdojMKX29L4R4oRuOqVVZM4ksuuaAX92mh7i7vt3m1
         dd6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786530862; x=1787135662;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=0opKHY0hArTd0tLmaIUqxiwMIhkUQB0s3SgD4CDSLQE=;
        b=SfMyMAqho9fH6ZYA+Uj3r3qNkwr71p6b4yfmrZQShXBl40kv80NxX6oCMdmvFz6sdh
         /hF7MhIFQ9czd67uu4LKF19UaPhuUtOR+IuuFcNYpHyPQo/56Thy4jw7c5PZDBPcf/+T
         29e3btsyLV6stQMRNaDF106MFxLh9+BAV/qC+Dyx+zwo6Mvjn3TdziRa1qZXi1NsF9Tr
         6tq9gqll0T7LlOqBoq86Sn0I9ZRhJhUx2DOK/SoFrwCu9Dx7dfIje4l4Olv6PaLfFv2G
         0DzI6fLkvPaLc+bXVX918bsFusNA4f1uhjUMMMTrsTc7eS0VzpS44FytulzIPDG52JP0
         IgZA==
X-Forwarded-Encrypted: i=1; AHgh+RrlFWkouuKY+yhBXgM5Yv6wHHLTDgLgWJ43gOwvCURcY/QN8ei6zUaMaI0wUpnQhxFKC3eVJQqHPBoYC1EN@vger.kernel.org
X-Gm-Message-State: AOJu0Yx5EUaNdImieb9MICVDgAKo9yiUBk9PmgHcyoqtV6IFNHg1Jzrn
	VcuDhYDpQKHENePmFGnqO4SgJnnzwdT8SvruarNRQAR6X0vRN6FHf2+qjuWtmDwSt1YGT9vW8bG
	2nZYXboH/HDeonPNPzuof2yQt9qF/MtqryDdfJSwOyA==
X-Gm-Gg: AR+sD11C/XuWrb2RNuLHqGaiHCBIjWPDoBoiNspjsBmgHk8utehnYJLczJID7eERuYR
	GLnxlA28tb8bTDYGbeZAUsffFV1iIAJEgSqEH+ZOd9UTOrTqbzn75C/n25i0Gem3N2NSHl5AaZ9
	2pXGh3B3uxtYVNawITkxqQ0a7IEOd/ajxKWCWBhFWMW4sBmXa4uvitOTXK2TlbwyP04tB3KJFCr
	SsfFPIBLh/w+JwPglnh2nn5EFvy3D6ndcPcqjAPCj6XM4ZZMaM/doKEDSdjZArfr+tfpzr5Y01p
	S6A+U6L5nND1VH8YWv7lquzwBRTB8I+bGmWuInxZcO7jQzBiLi11J6IWw40d9IcHsluC8xu9UBt
	efDv/nfdqoIm107A66y9SHe4nBcKebbYD88acsZ7Q7Q==
X-Received: by 2002:a05:600c:37ce:b0:495:58fe:88e5 with SMTP id
 5b1f17b1804b1-4997ac86c84mr89340595e9.2.1786530862046; Wed, 12 Aug 2026
 03:34:22 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-2-neelx@suse.com>
 <20260601224431.GA25574@quark>
In-Reply-To: <20260601224431.GA25574@quark>
From: Daniel Vacek <neelx@suse.com>
Date: Wed, 12 Aug 2026 12:34:10 +0200
X-Gm-Features: AUfX_mxapy1E6op8rEV2muUvuERnqCVwq3frUPTyyKjpA2GztEOk9ondTwecjNA
Message-ID: <CAPjX3Fe4yfrOWjZa-pW2AhBNG=6sfcrt82a8C9_cBzA5BkUbEg@mail.gmail.com>
Subject: Re: [PATCH v7 01/43] fscrypt: add per-extent encryption support
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, David Sterba <dsterba@suse.com>, 
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 00:44, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:35AM +0200, Daniel Vacek wrote:
> > From: Josef Bacik <josef@toxicpanda.com>
> >
> > This adds the code necessary for per-extent encryption.  We will store a
> > nonce for every extent we create, and then use the inode's policy and
> > the extents nonce to derive a per-extent key.
> >
> > This is meant to be flexible, if we choose to expand the on-disk extent
> > information in the future we have a version number we can use to change
> > what exists on disk.
> >
> > The file system indicates it wants to use per-extent encryption by
> > setting s_cop->has_per_extent_encryption.  This also requires the use of
> > inline block encryption.
> >
> > The support is relatively straightforward, the only "extra" bit is we're
> > deriving a per-extent key to use for the encryption, the inode still
> > controls the policy and access to the master key.
> >
> > Since extent based encryption uses a lot of keys, we're requiring the
> > use of inline block crypto if you use extent-based encryption.  This
> > enables us to take advantage of the built in pooling and reclamation of
> > the crypto structures that underpin all of the encryption.
>
> The whole reason for extent-based encryption is that extents can be
> shared between inodes.  So the repeated mentions of "the inode" are
> really confusing.  This shows up in a lot of different places.
>
> What's actually implemented is that each extent stores its own
> (encryption_mode, master_key_identifier, nonce), but for now the
> invariant is maintained that all inodes that reference an extent share
> the same (encryption_mode, master_key_identifier) as the extent.
>
> It would be helpful to document this stuff accordingly.

Yeah, that makes sense. I believe this is what we want - any file is
unlocked by one key. Not that you would need multiple keys for
unlocking different parts of a file.

> > +/*
> > + * fscrypt_extent_context - the encryption context of an extent
> > + *
> > + * This is the on-disk information stored for an extent.  The nonce is used as a
> > + * KDF input in conjuction with the inode context to derive a per-extent key for
> > + * encryption.  This is used only when the filesystem uses per-extent encryption.
> > + *
>
> Basically the same issue here.  The master_key_identifier is actually
> stored in the extent.  Just the current implementation enforces that
> when the filesystem accesses the extent through some inode, that inode
> also has the same master_key_identifier.  How about replacing the second
> sentence with something like: "The nonce and master_key_identifier are
> used to derive the key which encrypts the extent."

Right, this sounds better.

> > + * With the current implementation, master_key_identifier and encryption mode
> > + * must match the inode context.  These are here for future expansion where we
> > + * may want the option of mixing different keys and encryption modes for the
> > + * same file.
> > + */
>
> Likewise.  Something like: With the current implementation,
> master_key_identifier and encryption_mode always match the corresponding
> values from the fscrypt_context in each inode that shares the extent.

Do we actually want this freedom or should we drop the encryption_mode
and master_key_identifier and consider them implicit from
inode/fscrypt_context?
That would mean storing only the nonce in the extent context. The
version field still remains, preserving the flexibility to eventually
add them back later if we decide to.

> > +struct fscrypt_extent_context {
> > +     u8 version; /* FSCRYPT_EXTENT_CONTEXT_V1 */
> > +     u8 encryption_mode;
> > +     u8 master_key_identifier[FSCRYPT_KEY_IDENTIFIER_SIZE];
> > +     u8 nonce[FSCRYPT_FILE_NONCE_SIZE];
> > +};
>
> Well, it's an extent nonce, not a file nonce.  It seems it's handled
> completely separately from the existing file nonce, so it probably
> should get its own size constant FSCRYPT_EXTENT_NONCE_SIZE.

This actually sounds more confusing to me. They are both the same
thing. My understanding was that extent is "kind of file" on it's own.
If anything I'd argue for FSCRYPT_NONCE_SIZE used in both places. But
a FSCRYPT_FILE_NONCE_SIZE used in inode context as well as in extent
context sounds fine to me.

> > +/**
> > + * fscrypt_set_bio_crypt_ctx_from_extent() - prepare a file contents bio for
> > + *                                        inline crypto with extent
> > + *                                        encryption
> > + * @bio: a bio which will eventually be submitted to the file
> > + * @ei: the extent's crypto info
>
> @ei: the extent's crypto info, or NULL if the extent is unencrypted

True, the @ei is optional. I'll fix that.

> > + * If the contents of the file should be encrypted (or decrypted) with inline
> > + * encryption, then assign the appropriate encryption context to the bio.
>
> "If the contents of the file should be encrypted (or decrypted) with
> inline encryption" => "If the extent should be encrypted (or decrypted)"
>
> There's no "file" here.  And inline encryption is the only option for
> extents.

OK.

> > +/**
> > + * fscrypt_mergeable_extent_bio() - test whether data can be added to a bio
> > + * @bio: the bio being built up
> > + * @ei: the fscrypt_extent_info for this extent
>
> @ei: the extent's crypto info, or NULL if the extent is unencrypted

True.

> > + * @pos: the next extent logical offset (in bytes) in the I/O
> > + *
> > + * When building a bio which may contain data which should undergo inline
> > + * encryption (or decryption) via fscrypt,
>
> When building a bio which may contain data which should undergo extent
> encryption (or decryption)

Ack.

> > +static struct fscrypt_extent_info *
> > +setup_extent_info(struct inode *inode, const u8 nonce[FSCRYPT_FILE_NONCE_SIZE])
> > +{
> > +     struct fscrypt_extent_info *ei;
> > +     struct fscrypt_inode_info *ci;
> > +     struct fscrypt_master_key *mk;
> > +     u8 derived_key[FSCRYPT_MAX_RAW_KEY_SIZE];
> > +     int keysize;
> > +     int err;
> > +
> > +     ci = *fscrypt_inode_info_addr(inode);
>
> fscrypt_get_inode_info_raw()

That would add a useless VFS_WARN_ON_ONCE() which will never trigger;
otherwise, the next line would crash.
But I guess that's OK.

> > +/**
> > + * fscrypt_prepare_new_extent() - prepare to create a new extent for a file
> > + * @inode: the encrypted inode
> > + *
> > + * If the inode is encrypted, setup the fscrypt_extent_info for a new extent.
> > +
> > + * This will include the nonce and the derived key necessary for the extent to
> > + * be encrypted.  This is only meant to be used with inline crypto and on inodes
> > + * that need their contents encrypted.
>
> This is ambiguous and contradictory about what type of @inode is
> required.  It should be something like:
>
> * @inode: an encrypted regular file with its key already set up, on a
> *        filesystem that uses per-extent encryption
> *
> * Prepare to encrypt a new extent by generating a new extent nonce,
> * deriving an extent key, and allocating an fscrypt_extent_info.

OK.

> > * This doesn't persist the new extents encryption context, this is done later
> > * by calling fscrypt_set_extent_context().
>
> There's no function with that name

That should be fscrypt_context_for_new_extent(). I see it was renamed
in v5 but this one (and the one below) was forgotten.
Will fix.

> > +     if (WARN_ON_ONCE(!*fscrypt_inode_info_addr(inode)))
> > +             return ERR_PTR(-EOPNOTSUPP);
> > +     if (WARN_ON_ONCE(!fscrypt_inode_uses_inline_crypto(inode)))
> > +             return ERR_PTR(-EOPNOTSUPP);
>
> I'm confused what these checks are trying to do.  The first part checks
> for the inode's encryption key, but setup_extent_info() does that
> anyway.

setup_extent_info() dereferences ci right away. Without this check it
would crash if the inode was not encrypted.

> ... The second part is maybe intended to check that the file uses
> extent encryption, but it doesn't do it correctly.  That would require:
> fscrypt_needs_contents_encryption(inode) &&
> inode->i_sb->s_cop->has_per_extent_encryption.

This may be better. The comment says this is only meant to be used
with inline crypto but that actually looks fishy. We ensure this in
btrfs but fscrypt itself does not need to.

> It probably would make sense to check that directly in
> setup_extent_info(), so that it's closer to the call to
> fscrypt_hkdf_expand() which would has a *very* bad failure mode when
> !has_per_extent_encryption.

I think it makes sense to check before consuming entropy.
setup_extent_info() can have a second check if needed, though perhaps
it was not needed so far?

> > +/**
> > + * fscrypt_load_extent_info() - create an fscrypt_extent_info from the context
> > + * @inode: the inode
> > + * @ctx: the context buffer
> > + * @ctx_size: the size of the context buffer
> > + *
> > + * Create the fscrypt_extent_info and derive the key based on the
> > + * fscrypt_extent_context buffer that is provided.
> > + *
> > + * Return: The newly allocated fscrypt_extent_info on success, -EOPNOTSUPP if
> > + *      we're not encrypted, or another -errno code
> > + */
>
> What context is this expected to be called in?  I see the caller uses
> memalloc_nofs_save().  This would require making ->mk_sem nofs-safe; is
> there a plan to do that?  (Sashiko noticed this too, by the way.)

Honestly, I have to admit I was puzzled by Sashiko's explanation and I
did not trust it. It sounded rather off.

Trying to dig up the origin of that memalloc_nofs_save() - it is there
since the very beginning of Josef's [v1] posting. This was around the
time of Linux v6.6 but the code is still similar.
So far I don't see if it is really needed or why it was implemented
this way in the first place. It is called from
btrfs_do_readpage()->btrfs_get_extent() to set up the key context.
IIUC, this should not be called from a reclaim path. Hence, I think
that that memalloc_nofs_save() is redundant and it should be OK to
simply remove it.

[v1] https://lore.kernel.org/linux-btrfs/de7dec18d4dd440ebf3c538af5c765d747e1d3ef.1695750478.git.josef@toxicpanda.com/

> > +     const struct fscrypt_inode_info *ci = *fscrypt_inode_info_addr(inode);
>
> fscrypt_get_inode_info_raw(inode)

OK.

> > +/**
> > + * fscrypt_set_extent_context() - Set the fscrypt extent context of a new extent
>
> It seems the function name and semantics changed at some point, but the
> kerneldoc wasn't updated.

As mentioned above, I see V4 -> v5 rename. No semantics changes.

> > + * @inode: the inode this extent belongs to
>
> The inode that the extent will initially belong to, I guess?

Yes, at this point it's a new extent for this inode.

> > +ssize_t fscrypt_context_for_new_extent(struct inode *inode,
> > +                                    struct fscrypt_extent_info *ei, u8 *buf)
> > +{
> > +     struct fscrypt_extent_context *ctx = (struct fscrypt_extent_context *)buf;
> > +     const struct fscrypt_inode_info *ci = *fscrypt_inode_info_addr(inode);
>
> fscrypt_get_inode_info_raw(inode)

Again, adds an useless WARN_ON_ONCE, but won't hurt.

Thanks!

--nX

> - Eric
