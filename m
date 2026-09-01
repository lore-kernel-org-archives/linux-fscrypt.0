Received: from mail-wm1-f50.google.com (mail-wm1-f50.google.com [209.85.128.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A0AD527FB37
	for <linux-fscrypt@vger.kernel.org>; Tue,  1 Sep 2026 12:33:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.50
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788266014; cv=pass; b=YBFUunFzPRMWNCFomQzoyONi7UBbUkPzG0my7eKHKYB85wZ/5DxLx8tBq1AXFUA0ZTYQI01vFCOsSLJp72X/czt5OvwBHqIXaEuqcAL2AknhVRXvzbrDxYyPjoHpyGX8/x5LKVhlyzx4fFHVYdgA0gblkLOj+H+17fYnIHF5bAU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788266014; c=relaxed/simple;
	bh=tTilPEePkpjTFCruJKJ/IvVnzIPmWB7ZxbAkmTpfbLA=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=PwM+yfWb215etYJOdftaqXjO9X4GuXF5sws+nR8/oFPJQX93XhGm9dAPLGp+XWuXCwXcG41crPmAYBWgeboEW0fueGwFDDb+Sev/EbtemnYWxn8uZNCy4xdSXhOqA450og8D147z/J7mJ49f8/9E8lWyqBigRkHaftwVceJ+60g=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=LwULko2B; arc=pass smtp.client-ip=209.85.128.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="LwULko2B"
Received: by mail-wm1-f50.google.com with SMTP id 5b1f17b1804b1-4956869750eso31933175e9.2
        for <linux-fscrypt@vger.kernel.org>; Tue, 01 Sep 2026 05:33:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1788266011; cv=none;
        d=google.com; s=arc-20260327;
        b=WWoGVLH0RQSyWHfaWSOT2ofN/+ZneWJo5Yfmg8rcW04QIe0jRaVQgK6frwdVBOIw5x
         PDF8Coy0Gzr2bVBiPPvWcoj4o+6lBF0HdZYTusLELkK8JprvBJW0ZFqvFQFspCSmlfxq
         k0hMfvyYFaYx9pe5JAKNPDk6bsXB+RdzoUqHtXp9kf/tI+XNRZB8cYFug9fOYIO/BSGj
         5ufdNzo/VP96DvkI2N8efcJ0Jy2qX/DSH9H4l7qzfDsaWfUg8qaZl8Xqp3ZpMAzQfyaE
         u6jL5bcq6t23ostQ6bQeMnAMlz9RbK5ba/pHf6vyvxXM0QOs6IvbstFUBNN+K0+9veyy
         Tq0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cfOC0PiJENFhgp3GUEin/fTduYk5GNhKZ1VkMcNkAxk=;
        fh=MC1cfOwbnG2B6Y/Sbb1Jr0NtPSb0QDIA3OzOUkBKeo8=;
        b=RTkyuh2J9wuiE58Vg0jMKsNYBMrHv/XqUrFdgj+F8DwxM5DM0zAD3KDV1cZRUjQ4Q6
         5Xs5O874d+x06HfRoalA1b3E/IhNZ8HP8wdYek4Kwf50jq403zjF0Ccx71JxB/G8e0zH
         a4W0gVmOtb6YpI5R0nAtO9jdB1cQVQx65H6i1i/pGJzPBCFjYn+QqfYih6lKSmG3S9V8
         prczob7wFWWlVsh1QkfvEVJLObCpa3NB4d83UmeDusPgk5jKkeb5QqAmvvZbnk+BYkm/
         jVXYhTb4hYO1MnSXX6cygbrug+vAd/x9ldQU8SZXlXqHUvpAdxI8NcPwg6BeJDZgWfM2
         RJ+g==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1788266011; x=1788870811; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=cfOC0PiJENFhgp3GUEin/fTduYk5GNhKZ1VkMcNkAxk=;
        b=LwULko2Bs2/mrcLVVTaUXuF8PSdjkYkM7/aT0kj3uLwex+mk+2tR4S+4gfN0f9f81f
         y0tITeUFsvdVAIOSundN4TaLgBLXIklaAiLC9FCYq/6oVyvNBCOATTVCaKQgmmkq5g91
         sVSJbFUHpl1v++n4aVhRL0t+np6VpsuFHXngdlrNwy1liHtUPiTZvsjdVx5oxjrzmVAc
         iIgvUafOTrGYjXM+hG8UghqxdwaEi4zYMeWAjKmGSl6/AcwLQ8ywIkVNCj0F8yv5XiOJ
         z6heTKm6E1Ho28SNQcNkp1eU/9ja4Q9ZgktC9cZXnzagpNWsy44ijRIIC9dlo5G9EXWJ
         qViA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788266011; x=1788870811;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=cfOC0PiJENFhgp3GUEin/fTduYk5GNhKZ1VkMcNkAxk=;
        b=jf60x0vHnc7lQJnK1u7hvYb+j2CVmlSKee1kU/xHy50MJdG5doaiyTKKNKP/NadZTM
         0Xuj9t+pBGRcg/NxWWtvzOsSyanZiBIWBVUJgiDXSSP0vu5Mio5Tzp6caxVF/qGFVv8/
         YSNevBYD7y2gB0AfCF6BtzYPgpRZYssRdf8ZcEM6nSJ804UnQtI0xHNni1n7T93mII4K
         OWIqkhwIAWL7z7x8gj2sQxVuAaSiC9Crai77TPIDZn/nQv4/wHK5q38xzH4Ffj5HGwRV
         nCUIUSdUff3ZbbyWzUAjpNMuEU9I4JNVMqkClsNqJ/gyNUPBNbcvCCHWfpHDdYypF5Ps
         kGhQ==
X-Forwarded-Encrypted: i=1; AHgh+RrCTx8tFbewapvfGU+qToXWrSfPKjuNE4Cstl+xvyiv6W4FKZVcMM0gDhWeeLlS1IJLzZRuod3040wTrGYe@vger.kernel.org
X-Gm-Message-State: AFuF++m+trYQMDVBmABcxR2yxQxbulEEyWdJx383xZORVVn9oTQ4MyUs
	7FWQFp2vecTPxxwfHyNqb1RaiemwCRgy/pu11R1z8XdNF3CfUnFmOPf6+JtkUIMKICCLmUTWVLd
	9Rs4yQUCPaN6GE/uENtarHSzK91jyVCD30QEmCdHXxw==
X-Gm-Gg: AR+sD13OuzoXmhW64F3PYRK32PyIjNRaCS8udPr/VcE2F6BfasdkMAJnZfUylIj7Kfz
	RMsUacj1sBqkok6EMPtGU3kDjJ3N06TpX99jFjZm+PngvvIfGumZoYNy+1Tw4U+KjeADOG8GQcN
	Vm0KOpmnOPuVLN3a6uGioKXDHBtxZ+1X2+MVGZxl8C75hc4CdexVCAl86SfJL6a3OgGOr0b5ir4
	abHoa3BcVEr/EyFn0kvIWe2o52as2OVYLJsgNMpnnGJ/c9nVoMsTh2Wsuktbk1W2D0LNwtcDOzU
	feNN4Usu8W6I2bIPWy8oaJ5QTtsITvaAmsNMPtGFW1i64uV5vn6HzW/pYCJR1LMcx+DyYkMRYpn
	jBKFJ6rPebOhaesokYJoINR8m0LxyGAvzNba+VhcfUQ==
X-Received: by 2002:a05:600c:4f92:b0:49b:90cc:3c87 with SMTP id
 5b1f17b1804b1-49b91c487b2mr523873155e9.13.1788266010932; Tue, 01 Sep 2026
 05:33:30 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-6-neelx@suse.com>
 <20260602024849.GE2295@sol>
In-Reply-To: <20260602024849.GE2295@sol>
From: Daniel Vacek <neelx@suse.com>
Date: Tue, 1 Sep 2026 14:33:18 +0200
X-Gm-Features: AcwNN1X9FeJn91s56e1qLRSgSxckd0pjW883fuhQnYtX531oivm_yi3cZJJZjtc
Message-ID: <CAPjX3FeiYo3XZUuO5qpNaOavwxsVuM_qgs=zRNuNe=bh_cGerQ@mail.gmail.com>
Subject: Re: [PATCH v7 05/43] blk-crypto: add a process bio callback
To: Eric Biggers <ebiggers@kernel.org>
Cc: Josef Bacik <josef@toxicpanda.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, David Sterba <dsterba@suse.com>, 
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Chris Mason <mason@kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 04:50, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:39AM +0200, Daniel Vacek wrote:
> >  /*
> >   * Supported types of keys.  Must be bitflags due to their use in
> >   * blk_crypto_profile::key_types_supported.
> > @@ -77,12 +85,14 @@ enum blk_crypto_key_type {
> >   *   filesystem block size or the disk sector size.
> >   * @dun_bytes: the maximum number of bytes of DUN used when using this key
> >   * @key_type: the type of this key -- either raw or hardware-wrapped
> > + * @proces_bio: optional callback to process encrypted bios.
> >   */
> >  struct blk_crypto_config {
> >       enum blk_crypto_mode_num crypto_mode;
> >       unsigned int data_unit_size;
> >       unsigned int dun_bytes;
> >       enum blk_crypto_key_type key_type;
> > +     blk_crypto_process_bio_t process_bio;
> >  };
>
> This new field needs to be initialized in
> fscrypt_select_encryption_impl().  Otherwise it breaks native inline
> encryption for ext4 and f2fs.

Ouch, sorry. I should do regression testing on at least one of these.

Thanks.

--nX

> - Eric
