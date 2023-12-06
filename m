Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20230601.gappssmtp.com header.i=@toxicpanda-com.20230601.gappssmtp.com header.b="aVtNw5Op"
Received: from mail-oa1-x33.google.com (mail-oa1-x33.google.com [IPv6:2001:4860:4864:20::33])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 222E2FA
	for <linux-fscrypt@vger.kernel.org>; Tue,  5 Dec 2023 16:22:01 -0800 (PST)
Received: by mail-oa1-x33.google.com with SMTP id 586e51a60fabf-1faf152a1dbso3554148fac.0
        for <linux-fscrypt@vger.kernel.org>; Tue, 05 Dec 2023 16:22:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20230601.gappssmtp.com; s=20230601; t=1701822120; x=1702426920; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
        bh=WTn+v+GKlLUQg8fJn6ige+MxBInKYc740geNUOepq6Y=;
        b=aVtNw5OpnCAF8bLrNrg0nXoywfL/VF9UXj0g54pjxBkay0l/w8OdJdNcsmJiYot/Rm
         HRaAMvtsZ6QtWs3Cpzbm1GqA2ceoaMurhaOpybXg9aggWtA8sZwHQz+qZ/P+rL6WNLxi
         L7ArGtj9fEerpPD3rqc/50YKDGFm5PpSARFXcsPKcbrhXIlcqvBNgUmqVAvG3JrUqZFG
         5E3VICF45D9HpI4wlMBdn1L+i91SRtO3sscIXuE6sPh1d9+Yv/Q9NiwFnHqZkNNA+Els
         JHaUiNtgHDtTGEsBzEcR5u++VQwVul/RetfGrSf4XUctpuaQhitnhmMgJP9tsKrvns9T
         2W3A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1701822120; x=1702426920;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=WTn+v+GKlLUQg8fJn6ige+MxBInKYc740geNUOepq6Y=;
        b=ls4QwRuLJ1E/XPK3f50CpJAJyOE5m4rZVzoGQiMTtaAYnnQ932csWaEap1dIWFn/it
         SkNYptpCjq3JJ4c91OWPzI5vXgRY+gdiq/vTaABNIIsHmY5rPkoKoV2IELeCWhTy6GYT
         vgmgsQOBVQwa6LuAagHNse05WUtQTCQZ/jDTlVtdrfSLwVDjyWOeX52KuS35nuQxKqCB
         3tHow21YlmPlCbgds5CxxRMaT0nepPlJPOCGjr4HXc0Q/cJE8pfv8y+j0FjMkekmXVua
         gOXQddVB/kttLir6rSsDRQGDIziPt3HjkA5gFUx7Biv1VpYZ7yr4g8QS74G5vqfdcKYq
         652Q==
X-Gm-Message-State: AOJu0YylQu4JubogHkICR84DvNGWKZshDNK/qX8ZRR4U2hH7vaXKiVrw
	IISDxiqp51vZQ8Z+YlucaKYxTQ==
X-Google-Smtp-Source: AGHT+IEoqLzCem6jGF+DdIz2L7pGMZ7r07MIKLiuTT5p7WR7wzXVOcHhMrUPADMDUQWQYXqvSmihow==
X-Received: by 2002:a05:6871:829:b0:1fb:19b5:4065 with SMTP id q41-20020a056871082900b001fb19b54065mr4590oap.88.1701822120387;
        Tue, 05 Dec 2023 16:22:00 -0800 (PST)
Received: from localhost ([2620:10d:c090:600::2:f5a])
        by smtp.gmail.com with ESMTPSA id l19-20020a639853000000b005c2422a1171sm2883627pgo.66.2023.12.05.16.21.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 05 Dec 2023 16:21:59 -0800 (PST)
Date: Tue, 5 Dec 2023 16:21:58 -0800
From: Josef Bacik <josef@toxicpanda.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-btrfs@vger.kernel.org
Subject: Re: [PATCH] fscrypt: move the call to fscrypt_destroy_keyring() into
 ->put_super()
Message-ID: <20231206002158.GA89404@localhost.localdomain>
References: <20231206001325.13676-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20231206001325.13676-1-ebiggers@kernel.org>

On Tue, Dec 05, 2023 at 04:13:24PM -0800, Eric Biggers wrote:
> From: Eric Biggers <ebiggers@google.com>
> 
> btrfs, which is planning to add support for fscrypt, has a variety of
> asynchronous things it does with inodes that can potentially last until
> ->put_super, when it shuts everything down and cleans up all async work.
> Consequently, btrfs needs the call to fscrypt_destroy_keyring() to
> happen either after or within ->put_super.
> 
> Meanwhile, f2fs needs the call to fscrypt_destroy_keyring() to happen
> either *before* or within ->put_super, due to the dependency of
> f2fs_get_devices() on ->s_fs_info still existing.
> 
> To meet both of these constraints, this patch moves the keyring
> destruction into ->put_super.  This gives filesystems some flexibility
> into when it is done.  This does mean that the VFS no longer handles it
> automatically for filesystems, which is unfortunate, though this is in
> line with most of the other fscrypt functions.
> 
> (The fscrypt keyring destruction has now been changed an embarrassingly
> large number of times.  Hopefully this will be The Last Change That
> Finally Gets It Right!)
> 
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Josef Bacik <josef@toxicpanda.com>

Thanks,

Josef
