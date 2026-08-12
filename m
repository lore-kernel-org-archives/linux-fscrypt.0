Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7377542A15B
	for <linux-fscrypt@vger.kernel.org>; Wed, 12 Aug 2026 13:42:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.46
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786542150; cv=pass; b=FHmk7Jrzw+b66Y6AKrICu2kHeojx6nfvTRj8GAONSDsER81UMpOhrvv39+Z+I/MLheEhObXFmwlCICwFIo335h0Olr7Y7Z0O4XmYpmX/UjbFv6P8qb+G2JDHneNMhsUPePi217mn1pplqvS13aEfV7gcLFtfY3c8RkVGMUUQJ44=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786542150; c=relaxed/simple;
	bh=OaYKz/8UNJPHTqaurxpclVEI6MeOPbYBwJrUelUHVSU=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=gJckfmK9m0lDfZsh3XTY/Ewm4cNEivtIBWWU5svzZuf5TfnFFa0pBu43UJHHxwwMrzSEWotV7ut+hwDx497oTmS3AwsL/n52ImZ7MyY6+57zkAgboAsT2iupvYQeh7s4PVhdzMaPBR+BSTQ0z2AlK12yJw88Gcmxln+EkTF1FpU=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=HjdZP9Gb; arc=pass smtp.client-ip=209.85.128.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="HjdZP9Gb"
Received: by mail-wm1-f46.google.com with SMTP id 5b1f17b1804b1-49553515a8bso14142295e9.1
        for <linux-fscrypt@vger.kernel.org>; Wed, 12 Aug 2026 06:42:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786542145; cv=none;
        d=google.com; s=arc-20260327;
        b=XD4xj5hcZWQcWIXm+hRW5V3Ap12EnHJ3FHst6sTiipgRS295tBo8qpc37yyfg9e9bo
         uIxkkNeAXWU6LFE+pQJB6yGjE1R4m57JUe7/9lUqwBEWRZOz+V8S8W2kEenf6UlgJ6GT
         xWVc5+oHwkkSsujgJdOVoibl99BLUDA8M/2adbJn0cts8zclOv+UJ1hanMqrSRQDkJGy
         SqyIh6e6XiHOf75ui4F0Gh+uFe5aC9fDt6uwfKQxogMuBsG908HXI6cyFbHkDp0YnuP0
         vX+rklDYClk8s+2WpQ0rfKvGEBW7W7HyCBkGMqlN+0/WLZTWXosd0A5b55noQT9ICqat
         qhyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5tGpXLx/o7dEo7Q3/7U1JEPYlPhC8+W5F1DtfAIZ18E=;
        fh=tGYJFXlq2MJKnq1zs7YrF4ieQtSmIAKfUEBhwQp3f0o=;
        b=dgbMHTUgXQjPYcJ2hdLJDkQWMSrvQLn5p0o3I03nk6H1tw0OhqYHHySZhAE76XYlvd
         tJJS7BcP4USUS/3WGBjsxh/DT84yimYJLCUMCXpD2MhM6baDHxss/CZc9yva6tr1Ihj/
         TV3CaUXRSST9IRkx+swl6VTuR9hGuliEZ+gyZGIhpjI+TCu06aIhqegQf8fuADrZB38m
         siUBkCu72YYaMarzNp8SSu8G5pngUjhN9AK5GkKgjKYyhUB5UapN8wv4h7nAM8SmYpdS
         HLr4Mga9+xnFe4PjOV3twPxd+ZjxSII3uoPvu3V49ouCAqUb5KynjQcCHwvmjdRc5nxu
         +omw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1786542145; x=1787146945; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=5tGpXLx/o7dEo7Q3/7U1JEPYlPhC8+W5F1DtfAIZ18E=;
        b=HjdZP9GboP2C1f/GfQkYqllSxbidziD1jt+uCNcmfidvIEiYj7X6oGLk2SdETaeSv/
         FP3qlWyKUHkcpRXxTN+0jrkP4HJs/9qqh153fQvgKBAiYcrIZKWMpWux4Dsqben2uoo2
         jq093FKT3uA3aomdd2cHNrjpIRlOie6Xnx8HTUAdI+31sVJ84yBMM/bsT5a+pEYDil3U
         okCaDms5nJ9C88MF1JR6aB6nrXNpTL7Kp+XEeJgvlpofEJi+xTC/dW5nL7oZv1u5DkOI
         0h3GV3E3UVDkhGTD5f3Vug+cO26rsABqHAZS9nImESOa77Y+AEshR5wM0WD3ViSgl9aH
         Lk/Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786542145; x=1787146945;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=5tGpXLx/o7dEo7Q3/7U1JEPYlPhC8+W5F1DtfAIZ18E=;
        b=BgRD+Igo8fdW9jo/RzrADMfcbr+S1RFIdiV7VzYm0r4/lYb/pJPMSkl7CD+Q5xwmn8
         iML/uoZtBXje3JdnQ+J+wiDFABpg819vvxDxx3A8G+Ca4eXGYoD9QjfOtR44KIYMqqW0
         nPTnpRvR8kfTqukEtxhWjdBS1kdZUhn+5Q1kpqjPA0/D9Th9WjWRqsZocuXq6TzMP3/q
         uQycJaXmcoFENuBrKWQfd0XR+OORVUqr7+RJ3GcJPLvtX9+Sqk0f23L7cSdUYeI7mq3L
         anPJdtA3H4/VyZKxTYSu0q4HrdJedCR29Lm4vqZn5NePvqJahHEijDBp0aIg6R/j8++c
         /2dg==
X-Forwarded-Encrypted: i=1; AHgh+Rrcevus49ONS+FZabP5bGePefTiPCAHOwBtuDMJ+k9muILnCBI1S6XyZtoxMAtpuJOrlWXk45e11A8BnXgJ@vger.kernel.org
X-Gm-Message-State: AOJu0YwNdG8CcLbTDLrREJyh8M5R0vQHi1hEpYmAZ2eo+wUgR2RRdbPT
	LFZ9+TobXRzegHEUdxcp3ri+F5o/V6+eQl7IXSRriF3sp9XJi9DF8kH1Vl9is00vZFU3V/qiafP
	j5mI2Z0N3ehBkBJxYhTDUt91bMOkfBCxhrozkFxJ7Jg==
X-Gm-Gg: AR+sD13ih34YPXrHYytycGqy4xq19tq8Xa8PDyAGceo6g3S/R2PH6i80g7hOuSzi/Eq
	XPlM4npDORZUdTFRCp7oW3hgJbNScic+M+KZNl6RbwhGKwJJwE1K3W7v/5CmCt/I4ne0mWB/6E0
	Mzvhjx1Rr+cxptNndlZKBVasqDgSFWYsCF8L/VbtrwUR/uTLa9Oj18xZ27RnuqnW8rwgqEKnZKv
	bKH8RrVLy2BSIvWuJBAJjGarCYG2V+ydpX6guSEldS1AtGcUv+HtQVSkeUBTybZHqX0pJfHSYZ7
	bNaH9LzCxLn2JreZNYJL0ZLPhlgjdarn3vRknYFU0Y5m26UYodZdZAaxlOZWWd0M3R/N55+QnD0
	yM5b0zPvWdtdHYv+4rovFb6wkgKlqwNJDpuOkouhQIkU=
X-Received: by 2002:a05:600c:4690:b0:490:c6c2:52 with SMTP id
 5b1f17b1804b1-4997c0fe67cmr65880095e9.3.1786542145347; Wed, 12 Aug 2026
 06:42:25 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260513085340.3673127-1-neelx@suse.com> <20260513085340.3673127-3-neelx@suse.com>
 <20260601224920.GB25574@quark>
In-Reply-To: <20260601224920.GB25574@quark>
From: Daniel Vacek <neelx@suse.com>
Date: Wed, 12 Aug 2026 15:42:12 +0200
X-Gm-Features: AUfX_mxUX5B7ho1XknbfVlc-uLWV2Eu6v2suT3UDLMiVCVx6n4XVBbcNHB1dnXs
Message-ID: <CAPjX3FfouCuSTTBYASnjRgvu+kR7mJtRsd2WZ7Lc9om+P8hK0g@mail.gmail.com>
Subject: Re: [PATCH v7 02/43] fscrypt: allow inline encryption for extent
 based encryption
To: Eric Biggers <ebiggers@kernel.org>
Cc: Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>, Jens Axboe <axboe@kernel.dk>, David Sterba <dsterba@suse.com>, 
	linux-block@vger.kernel.org, linux-fscrypt@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Tue, 2 Jun 2026 at 00:49, Eric Biggers <ebiggers@kernel.org> wrote:
> On Wed, May 13, 2026 at 10:52:36AM +0200, Daniel Vacek wrote:
> > From: Josef Bacik <josef@toxicpanda.com>
> >
> > Instead of requiring -o inlinecrypt to enable inline encryption, allow
> > having s_cop->has_per_extent_encryption to indicate that this file
> > system supports inline encryption.
> >
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> > Signed-off-by: Daniel Vacek <neelx@suse.com>
> > ---
> >
> > v5: https://lore.kernel.org/linux-btrfs/ba0289bf103653d5d98ef576756c9a2a66192865.1706116485.git.josef@toxicpanda.com/
> >  * No changes since.
>
> There are multiple places that check SB_INLINECRYPT, and just one was
> updated.  Perhaps we should just require that if a filesystem sets
> has_per_extent_encryption, then it also sets SB_INLINECRYPT
> unconditionally?

has_per_extent_encryption means the kernel fs implementation supports
extent encryption, not that the mounted filesystem uses encryption.
That said it would result in all btrfs mounts setting SB_INLINECRYPT.
Is that what you meant?

--nX

> - Eric
