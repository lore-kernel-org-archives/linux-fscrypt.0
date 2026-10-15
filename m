Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14C924C10CD
	for <linux-fscrypt@vger.kernel.org>; Thu, 15 Oct 2026 18:52:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=170.10.129.124
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792090355; cv=pass; b=QP2ZH0sf9QkSFewOTfYzcH8Xe8kzOLqeOCR5mpi/HLuMPgeWqsa3O/4te9eYNgB7JoQpmorr8NomW0UBbimKT2uUJ2dj2Yn4fw3LscezQ8Nh2cO8f34o6sTv2JNlSYIlS+DVTOLWEPCR/JS38yYEPWrcUqYVGhaVoXEi9U6rJ/U=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792090355; c=relaxed/simple;
	bh=GIdhD9TeSPWmNsy0fX+a8u6D/y/bXyVjLxaptbqD0Vs=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=MG/3ycxQ9/Lx9UI+AgScxGxMn/Yx7mrQj8a0x1FxQfkCdmCBTO8yQz5A+/BdYAaQ39n4+GPiLQpDVIsZpEhvPa8oHJzXWFCc/PskvxZPn10VoC1yXmPJjLl7mb2jvNLMM90FitY64w1FkfHpEdvHT/KGDUZDEsGdi6B8q4EPU7Y=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=MGgGYtAM; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=bUOWuOc/; arc=pass smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="MGgGYtAM";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="bUOWuOc/"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792090352;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=+sUmonbqyk5xIs2kC+9hn0/UcfQCr5PxfxA1r/ri1EQ=;
	b=MGgGYtAMd3WABz/Fj61R5q9Unq2HyTtDP5jmLWyPTwCYLHHtb1UZAZ+vH/0Ylbd3UfQ6Dh
	+wD37RgiGUxYmkCdxXM1IgaOg6fh5bpHD3yG4gUDS+z/IbdA79j/5kj/vfZVL4UZwnn9F5
	PpF0jRzmPly4Sjv6Wj0kJR9nYHjRJuM=
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com
 [209.85.222.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-657-Sg3Q1kqAN_yagfEmCPLBng-1; Thu, 15 Oct 2026 18:52:24 +0000
X-MC-Unique: Sg3Q1kqAN_yagfEmCPLBng-1
X-Mimecast-MFC-AGG-ID: Sg3Q1kqAN_yagfEmCPLBng_1792090344
Received: by mail-ua1-f71.google.com with SMTP id a1e0cc1a2514c-98c6374b678so4256863241.3
        for <linux-fscrypt@vger.kernel.org>; Thu, 15 Oct 2026 11:52:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792090344; cv=none;
        d=google.com; s=arc-20260327;
        b=KCUHiSuqibuRWrub0rAeAIO2wApBZqVDUikAgCnXbWiANinTMXv5i2FgmjVypBbN6a
         hWYgFTmFS1Poyh42OCxABk/ZYSiKgy5rO4FyFtDteb1EWIX7aUI0+lI3hbnv6OGAPq3n
         kICGBFRyr2zu0fIlNJaa5myzgtZCWDT6+09jnXAE3W8Ewj+qhBYirzlN0fU+1ojHxvN4
         qU0C+Yew3Ul3nMmAdf5UiUPUo+tdYsDSa2EuqbKWgzKCyTHHb3JYYCiEoVFNTIs4qDjg
         BHK2K0/vGBYQi7rIrpB57L07VQGyTIhjSMy0SAikTkxElOq/fEhfHgb7iT10TPBW1UyF
         rnzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=+sUmonbqyk5xIs2kC+9hn0/UcfQCr5PxfxA1r/ri1EQ=;
        fh=6tOcpB6h1Us2DBZxzkWb0+f5uwfdzmz0gr4tEFiZlZs=;
        b=OjcdlxUrtRGkUS2ZWxhm4P7X6BkD8XkNtAR7Uph4rtVO/UnzjorcnqUbpum4ifrE0K
         qbdHl2ThJ8BxBZCOgCaIgJiDKR9xJ4YNOqwF0lXqgWtiOHt5LYEjxGDAVto1eb0fq6R7
         iL7ucBEZMlG2EBo1xyhSaq0Pu7TyfWFrtzJlbfV0Yav8eWi6ljjc7g4WlCIsDWtINLtw
         bXdHPiQHaKC6FMXkR9eQaojhZyXgTyWOBAkSkhryYSrTCZbLxeS5kjrJAB79NB/MMspx
         i32KncYhl6P3N5ovxCLVuVbOIQAqRaPdnEBZSl+1jbcToOOEUgy/7rA2ZpWCwFkgvtxy
         In5Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1792090344; x=1792695144; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=+sUmonbqyk5xIs2kC+9hn0/UcfQCr5PxfxA1r/ri1EQ=;
        b=bUOWuOc/GcFMd69JKLy0eWuhWeOXCZmejxzKppZKvnxBVKtcEqwra1R5u/IUYrnR3L
         S8WGpJI23hnUttzv8T0/lNtyB+3n3aWA4LHlty9lDmeE/BSL5t+mRyE/KeZICyftM0Lb
         kP8CgJO8qy1u756dIQqpVmSBGCZ8GjnGuke4UNbt8qVVpa68OhLuQ41vyubXr8U8cZ5w
         3gCy05Q+T6Xcn+tgMAfLZc/IHPwQPQ6rsG06KTwb/LD1My/4PSu1rhi+LWcTcas7ItW5
         G/A6PNuGrRjolNgNnXSb+rZOm2pXTuq4U0wexdqogTTD53PPy0i28mtVhKnjapbF2UuA
         pvGA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792090344; x=1792695144;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=+sUmonbqyk5xIs2kC+9hn0/UcfQCr5PxfxA1r/ri1EQ=;
        b=vtOkFkPKi4SAoSlN1d6KtFfQnca+moEC3LYk4d5arg6/HAMuS/UVcOVWtQZrJmTtgw
         O5gmijrAU2pjaEPTCBJhYv8xZYJn1Y1aZBHQxoMJ7vZMVxNo4z7muV1rlsHHrjZNZeIJ
         URyOuWc+KHcZudHiRLN4b9Q5vtBU6NOG54jQ72+EwLywA2g4uSFDdR8qN0/4vnIodZrU
         ynphEPfF0lV7l3wqTX1SzhaGxek5tNMgtu/PLePUYwShAy1YehxPWt0sotyt06nYNh+F
         4tkCIBTgGmkTT4GtSb/sEliMguaiw+LYo9jJlSxN4Nijs+rVbLDY0LjKNSn1J08Fw+53
         n53g==
X-Gm-Message-State: AFq9FYLicetuIfajn54qlB9F0iE3jyvhu5HK2a+IXOgo3/dyZuAr7S+C
	jD+3g5lj63LUNW2ljobibwX9uebiyIvyXZJZe/6LYFcFkjsUAZ8n7a++imch+2U8dGu8kMoFJ66
	rYip4ODjoavUqV18HtPwj4CbyKDSLPc3KyBGeDoDWAWwzxfq8Yr3qL+9k1rxLxrIgJS2ojWTDAs
	4F7/FUYxsKUO0enG0uQ++HEYEWSUyIeKdYiQ0bErG2LQ==
X-Gm-Gg: AYBFou29DOLIKe+uY8iQa7BKvEA5fEeHc0m2WHhYyaLsMQ1YMQdZ/b/ekFd/leyh3OW
	/xcH7I6AyWQApmqvlqZLPBtK69TKj5Wo/YpDAZHLewMCbkrq9JCkukiYS6ZdZhKNvnqd9XMzDX5
	trHDWEuNNwCWF3NeoNcp3JlWuKZXTbHeoJ9jZ1hWT5Qn23zT4eo9pZv6pTi/MQ4yozdp0VFVQ2W
	sEYEx70l02yIpfHuV9VisTPsvO4Vz+KIcOueqQk1qcZd4wqK2+T8wwZnhODIjZDKfe+DwXgwrro
	ZUYcbRyizm2y1ITlywPH1CIvOg==
X-Received: by 2002:a05:6102:2909:b0:7bc:1de3:39b0 with SMTP id ada2fe7eead31-7cb3a15e9a1mr7057335137.32.1792090343783;
        Thu, 15 Oct 2026 11:52:23 -0700 (PDT)
X-Received: by 2002:a05:6102:2909:b0:7bc:1de3:39b0 with SMTP id
 ada2fe7eead31-7cb3a15e9a1mr7057329137.32.1792090343324; Thu, 15 Oct 2026
 11:52:23 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <a01d0a297a3e174d21741a3ad586ce546327603e.1792081664.git.amarkuze@redhat.com>
 <20261015183548.GE2170687@google.com>
In-Reply-To: <20261015183548.GE2170687@google.com>
From: Alex Markuze <amarkuze@redhat.com>
Date: Thu, 15 Oct 2026 21:52:11 +0300
X-Gm-Features: AclHuK8AcY6paQ-tWkxVfhofIbCNjjczg8Wu8LAM9XVRyc2K231BtACLuWOj-8w
Message-ID: <CAO8a2Sjr6XSizdgobZK1ZAO8PUd5tCDFKjdD-=3TXHwqOU6qfg@mail.gmail.com>
Subject: Re: [PATCH] fscrypt: allow filesystems to disable symlink target caching
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Ilya Dryomov <idryomov@gmail.com>, Xiubo Li <xiubo.li@clyso.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Eric,

This supports the concurrent CephFS subvolume quarantine series.
There=E2=80=99s no Fixes: tag since this isn't addressing an existing upstr=
eam
regression.

The quarantine series adds checks to Ceph's ->get_link(). However, if
an encrypted symlink target was cached prior to quarantine, the VFS
bypasses that callback entirely when following or reading it. While
the target data is still valid, access now needs to be denied.

This patch adds an opt-out for symlink caching and enables it for
Ceph, handling the encrypted-symlink case for the concurrent series
without affecting other filesystems.

On Thu, Oct 15, 2026 at 9:35=E2=80=AFPM Eric Biggers <ebiggers@kernel.org> =
wrote:
>
> On Thu, Oct 15, 2026 at 05:46:24PM +0000, Alex Markuze wrote:
> > fscrypt stores decrypted symlink targets in inode->i_link. The VFS can
> > use this field without calling the filesystem's ->get_link() callback.
> > The target can remain valid after the access policy changes.
> >
> > The CephFS subvolume quarantine series adds access checks to
> > ->get_link(). Quarantine can revoke access after a target is cached. Th=
e
> > VFS cache can bypass these checks.
> >
> > The no_symlink_cache option in fscrypt_operations gives filesystems
> > control of this cache. It applies during target creation, lookup and
> > getattr. With this option set, the helpers do not read or update
> > ->i_link. The filesystem callback can then revalidate access.
> >
> > Uncached targets use the existing delayed-free callback. Each uncached
> > lookup allocates a temporary buffer and decrypts or encodes the target.
> > This lets Ceph reuse fscrypt's target validation and buffer ownership.
> >
> > The default setting keeps the current cache behavior for other
> > filesystems. Ceph selects the option so cached targets cannot bypass it=
s
> > ->get_link() checks.
> >
> > Signed-off-by: Alex Markuze <amarkuze@redhat.com>
>
> This sounds like a bug fix?  If so, which commit is it fixing?
>
> - Eric
>

