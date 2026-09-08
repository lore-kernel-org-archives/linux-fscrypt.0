Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 373D15867CC
	for <linux-fscrypt@vger.kernel.org>; Tue,  8 Sep 2026 16:47:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.221.47
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788886062; cv=pass; b=UIHN7iIr/9SmLsaqvnHJSuFSpatLPNKl05vKg2OoQq/UE4tEc/jxYYPItYCmbcr4MwNOaJveDcivHnbS/sTf5Qc/8d6DCdSgbf1Cu5Goc21VLlM3UCxPA8hX66vBEi95yBeyzJu6WqEXiUMQw9ZUdHddPDRGHz/CxcmfVLOc7PI=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788886062; c=relaxed/simple;
	bh=mwAxvZMzHRoyoS5SlFNnDSEx6Xh8O3uTGsYLqZ4P580=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=HRa2MgvbQt62rpRLM3LuKPmNpB0UP60e4X2OaoeBgCUeVbCOPX+CDVGmJXUeTLDp+/GQbWPBu/UImKDckDLeeRHUSg9iDEx054lu1r2zf0uDTJCC2OkJgyubwCbB62M2VGiKXu12Q7clT+e1/9MmjyzmWUcPuewK9iXvzZopN0Y=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=ZeWDij5q; arc=pass smtp.client-ip=209.85.221.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="ZeWDij5q"
Received: by mail-wr1-f47.google.com with SMTP id ffacd0b85a97d-48441a2ba1bso3515516f8f.1
        for <linux-fscrypt@vger.kernel.org>; Tue, 08 Sep 2026 09:47:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1788886058; cv=none;
        d=google.com; s=arc-20260327;
        b=a+AhVFKzX/TOE9bAiaM18dGh+Wv6q5mdLvYcRMnC7A6m16ELnj+FRRg6cd7r1BBbLD
         JJ4kqiopnDhugGS9Jws9U0/yUqmyvY3Gv6vCsmf4GvYkf2OIb/9QW3d9OGbNffllmofA
         7Hg8ijWmqyO41jUCMwZS5ODZMasIPkylkVcJNnlv0BgUEjSam684FbexQ7fzLhXL+qO7
         UOeMkz4gSWaHE/EKgKj3+v5XRmchtnQ42r8XRgI4PT/28M3eapQTtbwW37T10xH4HE1g
         rsKJf8Y0nPSYnpj5zUAVUYbxv4INGdvlq/ZXFZToXPfD2jegx9gY0XL6wvv6shBvSYng
         ITVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lQTr2U76uYl3nor0tns8i6gi/m+LsiVvyKvG51LqGmw=;
        fh=BqkZwmuBBDzMjNzjgWD61jT4VFjpyHji1KuQEqWetg4=;
        b=Ei4tUuVO4YVowLS57D4q/kG4vFD8nHgSU4VSm/kcq++MTCXRA1We0PjwWR76cZbibJ
         1IYN2FaHDiJKUD/j12tkVPqIrtbgRbojgOT9Yo+RuoFpi//rz4kPFOerQXxP3kXq4Yye
         Z+A21T8hyPC8+iX02vLe/W+J3YwZDOjt8xsZdDteh88VkPmsWsXE8bezvR3uaCaOClIk
         VAWdyyVI7PiJEI6aLMlebXQDlRoieOh+TX8soGLsnmRAVx/75WnNBqC1jEprSz3M5vK0
         7QMvdjKdSzQvzPS8UN+AHBQCuPrc6Gft5uWtfeKZXL9+9zazwT0tTMU5ckN3QXf7K3Ju
         7i0Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1788886058; x=1789490858; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=lQTr2U76uYl3nor0tns8i6gi/m+LsiVvyKvG51LqGmw=;
        b=ZeWDij5qCX58pjNIOWqP5T0WwTbCTYmg9/C3jusLKLwjD09DWYEnX0tdae7ZguME6H
         lhfsqRR1a1twNwVjmiRA+E0Z25HLxcD1pvX4jHJ31YZQGRC/53qQgUw+lJo4NKHkLrRl
         425BHkFkIpOduF245QPbwxdQXdoQCVsk2ydZWdL7imUQtEWxlBpTYbCjPYw5HoDIPFwR
         ZN8SdF1WQAaYoiNp1EhGISVBI/RZ/M1e08APN4/r16Oo98wmnJsQKDSWMv72NL/0O7s2
         HmqaXM808bFk/ir0x0a7IPVbtg5GVCAvwUnHyidWwkWCBDD35wxITvIYgKUSz0wVWUgw
         DuJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788886058; x=1789490858;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=lQTr2U76uYl3nor0tns8i6gi/m+LsiVvyKvG51LqGmw=;
        b=bscZyde+aXXT6AaN2/ZsJFNzOVigY63qhUiyvLbQ2BRUJ6b0Qbc4pGpfEJIr1F68f2
         mJ2WfVDwot4xAjknCbc6G7p4TRoehYnw2VuiMvNz5Rin6VPiqo1y+rK5VK80ac4LW+eX
         FxEA3zInBAPmX74XNNVDoRjUYzeld8K2PqPWpuCLtlrdplFADs3N+mIGkksTXbZgsUjp
         4G5fdhe3mAgaWqKWRRk46/ODts2iywFjdbE3JRfgEcOIC4ddM6EzvXAz7XcrVNv3jRrA
         DIWD26ioWyjDSGnjZEj/vnHJXHJcDoSNvyqduNOeXpixb/bQvv0DZiaJwgyfiTj9RU4n
         4GPw==
X-Forwarded-Encrypted: i=1; AKwUvBxqHIO5wQkfpqxUOXI/yEpRyg1HKT3NpchrzBP8kQPoijQT9Y7pk+sn8smuCyQrfMS1QH8T8Rc9zV9sf/2Q@vger.kernel.org
X-Gm-Message-State: AFuF++mDzEdHgHIfTsq5Pz/VQv+70j9Ldi9sXK96uDdWSY4O+X6SYWWw
	S4dIuuK0saT1Sd8fUYHQgMNYOClKTx6XRIJPI3u9SU9iuNz/2Qn1CH3nzx3bnjn7QhVHKbv0fMM
	NOrCKLkFRzPii+8VHQx0Ttky7tcWU+sYV5qGDRJnAHQ==
X-Gm-Gg: AYBFou3s0veVCmxtPM602sUVbDFAz2rKTy6V0cjDS2eb4uURjs5CVAnXfRD2mXvb3qS
	rTybMdqjPUslJSOYBb+TbdrC//oYrN8p7A5T03ZnaXq77RWRGnGeRKgnT5k4meN2pgt4AaINT02
	T3C95lN/9RB1KEUTqhFmZvcJsrLEOM5yD24qS7JNFocnDehWMzMuMJ1/heW/82frVNCEkFC/SYO
	U5yzw1X9C/gZmkZLBfYZYqSjDPM8t14ul/bWFwVzdGaaiZAp328jWZbwqfLrU5JDc6eJV129eQj
	uoD9QLBrz5wPX/rMj4IyHL8HWHupjwJu2CTwRg8yfVm4KOFmbFd8acNFEC9/PXVVLc78cGqV3iW
	hLe3kL63ROYtwJv6pbsqRz+FURRCNWsuexOzl0VUidA==
X-Received: by 2002:a05:600c:138e:b0:49d:daa:af6e with SMTP id
 5b1f17b1804b1-49d1c7b732amr46339715e9.16.1788886058021; Tue, 08 Sep 2026
 09:47:38 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-10-neelx@suse.com>
 <20260602025436.GF2295@sol>
In-Reply-To: <20260602025436.GF2295@sol>
From: Daniel Vacek <neelx@suse.com>
Date: Tue, 8 Sep 2026 18:47:27 +0200
X-Gm-Features: AcwNN1WHoSNszmavv4wORasY461K9gsH-mc9zR1O6zdN1S5pOlfHSeHNoKmuOnY
Message-ID: <CAPjX3Fd-YEgnzhMryAJi44tZNs_YsHRAAwsxaKbO_jpgvp=qQg@mail.gmail.com>
Subject: Re: [PATCH v7 09/43] btrfs: add infrastructure for safe em freeing
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, David Sterba <dsterba@suse.com>, 
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Boris Burkov <boris@bur.io>
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 04:56, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:43AM +0200, Daniel Vacek wrote:
> > +/*
> > + * Drop a ref for the extent map in the given tree.
> > + *
> > + * @tree:    tree that the em is a part of.
> > + * @em:              the em to drop the reference to.
> > + *
> > + * Drop the reference count on @em by one, if the reference count hits 0 and
> > + * there is an object on the em that can't be safely freed in the current
> > + * context (if we are holding the extent_map_tree->lock for example), then add
> > + * it to the freed_extents list on the extent_map_tree for later processing.
> > + *
> > + * This must be followed by a btrfs_free_pending_extent_maps() to clear
> > + * the pending frees.
> > + */
> > +void btrfs_free_extent_map_safe(struct extent_map_tree *tree,
> > +                             struct extent_map *em)
>
> The "unsafe" btrfs_free_extent_map() still exists.  Assuming both
> variants will continue to be needed, shouldn't the comment above the
> "unsafe" variant be updated to document the preconditions for using it?

Actually this could be cleaned up and unified into a single function
with optional argument.

> > diff --git a/fs/btrfs/extent_map.h b/fs/btrfs/extent_map.h
> > index 6f685f3c9327..a962012be1c3 100644
> > --- a/fs/btrfs/extent_map.h
> > +++ b/fs/btrfs/extent_map.h
> > @@ -97,11 +97,18 @@ struct extent_map {
> >       u32 flags;
> >       refcount_t refs;
> >       struct list_head list;
> > +     struct list_head free_list;
> > +};
>
> The comment above this struct says "Keep this structure as compact as
> possible, as we can have really large amounts of allocated extent maps
> at any time."  Is there any way to avoid adding a whole list_head?

Good catch. In fact we can reuse the old list member. No need for a new one.

--nX

> - Eric
