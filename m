Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793293968;
	b=xAGl2VY36doJPhRiUaRsSrqj1Ke1tCubgUV9BeJgSce+EgJSKUSuo4goDgFwNJfjuMOD
	 TjfYBaWkEh0zMlVaEOM+q1dYj+yBcFi0+dTcmG80/qEUnITZycjqI/N32tvyXsSlmBE+6
	 nwhZFlFzLYI4vznpxISNaWwhe/SPlngjaCx0u6XMkM4O0IH9Tsan7Zt4ciSOcUmMqnIu5
	 f4cie1fmfmYNVAWACl0Oii6CeDooH85GjzN52C9exCNNUm9GQWxGqvsmp2CQs0FwbIDQW
	 aUmDsVUnW5FJNosjJy7+vhsICtVN7X6U0V3vVHNhaD8Fh/DU17zRBad85G9VS+nxNIw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793293968;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:In-Reply-To:References:Subject:Message-Id:Date:
	 MIME-Version:Content-Type:Content-Transfer-Encoding:X-Mailer;
	bh=dqlkwUV9tYAEbSb1BQ5TfPNY6DFBwHzpfk0RyIwAqNI=;
	b=UbpqWePBXBdi+qTFiuG/7Jxv4XdfBgsOcmuh4dJ3J/fZqdX1VaU3Z7sbIttW774q2Krr
	 ayY8jGEXTDWYDYGTFkvLtweV77ffILcfudthrr84IfVoc6iuslcgK4JagLWtxE8ndzpTK
	 RmpnETA15ejkFY1EnPHtngp0heHL3GH6oLKPtU+f29dpAEdccA9TmmKC0X7l1+sCzSGp8
	 n0WDXMefy1iTnmtoYHKVlQzxawxKfoogZT2qIjDbRbG78M3RJd4EA6VJobmE6+AhS3urH
	 uTKvI+By8ejg5m1qcuoIxCflU0cElIx+qumhGtqIwninAxhhK4j7qTnUF3JHUbRBLJA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=kernel.dk;
	spf=pass smtp.mailfrom=kernel.dk;
	arc=none smtp.remote-ip=209.85.161.46
Received: from mail-oo1-f46.google.com (mail-oo1-f46.google.com [209.85.161.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8C8A606A31E
	for <linux-fscrypt@vger.kernel.org>; Thu, 29 Oct 2026 17:12:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A8C8A606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kernel.dk
Received: by mail-oo1-f46.google.com with SMTP id 006d021491bc7-6b1afdf5196so1007569eaf.2
        for <linux-fscrypt@vger.kernel.org>; Thu, 29 Oct 2026 10:12:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20260707.gappssmtp.com; s=20260707; t=1793293961; x=1793898761; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:date:message-id
         :subject:references:in-reply-to:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=dqlkwUV9tYAEbSb1BQ5TfPNY6DFBwHzpfk0RyIwAqNI=;
        b=jbB7m5xkSbMsVHA43BS/Wdw7yxNxRXuSxF9sZjwaxRsa+P9Adr+maDdfwjMVW0tt5z
         9xy96Ryetgo0KDwM83jlI3Qo/k8orojzOGXRu0ZmRbtx9rvEamnNQ0KR3vl9oElWqRvL
         AYaVN/0pXl3h5Hatlvx2he6KkzZ7uCNhnrEhE/2UFwIiYzli25MdkmJpnmm3BQS9c8Sr
         FM1+0Olm0viL1RsOGum9YEGxlmLxRhW/uYgQlvKZ8Sb0O3IZIQKgR4CuHeqkj6iv5dkO
         tu2hCzV+TdcC83N6D08b2nNAf8g+a+zQjqfkdjYRvCQ2rFNM4b/csRoyykbSApv5/jH0
         t+6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793293961; x=1793898761;
        h=content-transfer-encoding:content-type:mime-version:date:message-id
         :subject:references:in-reply-to:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=dqlkwUV9tYAEbSb1BQ5TfPNY6DFBwHzpfk0RyIwAqNI=;
        b=0GzG4HKIDkQv+Dkhl496ynr2NkpFSMw218BGqytT3cUZiVMM8XiYqM0CCKgKkQ1WN+
         SdahCwS5crWWeHsVsQDlZT/OgV+hLC32uPkzZxupHJODqROlmsdi07wv8rIpoRpqQPPx
         QE7ng7RFXmYFRbxNeQJZTvETkGUbTSNTTBktFgoaFvJ/pzE2cYEhvJvjfjSmSVjyG20f
         nzbTOerHtTZg029L85cTBirBLsy6YsBb6A+GpIlYWeB5k0iCwTEfdvXfxN3+UFfmlIuJ
         zuyMsKeN7EAksc13mCW0m/8rGfZE94KAT17hyzD+r7YsGnmQbSSeodyPcLvK0OLlWUHw
         Bxjg==
X-Forwarded-Encrypted: i=1; AKwUvBzldZIMk203asjeZRivjmUAGspoTrjii0fQbRgvD6k2mfKijaq0aJCR/6DM/K9h7JH7vOPzV0acOI6Jmp0u@vger.kernel.org
X-Gm-Message-State: AFq9FYI2EVRU0JmIYslMA7mdrFxwVdisEykPW4b7Ea+blNVZlIkvJ83r
	Dc/N9IVbeMKi9qD9AIqGHityN7KYUL+Oj+xABbSvnt+QS1Q41gPbQ5V4+6zhOELC1dM=
X-Gm-Gg: AYBFou0Vhadn1UMeabVsF3zVIUF9qBBztZ+omhg5KY0Ba9RBoxc4yPdumR0eUSuYs5c
	MTz8XIoOGI1oQOcLY8yrqAhzmU3wXIitfZGuKwXML3oByQftllsJCNgWgQLOKqpE+9qZyQkMJl6
	jIL9pHZLu/NTJXr1jSDnk2a4+aiH4ox8uQWvWfSQEyqiz+498UiF2HsW0sb650HyipfAMpxVl53
	ticuLoKU8e7TAgajBCgey9lkeLoIZJ1PKSm6Xj7yz5AWXLJ7+rvCBYBtFitshn8z+6sOrBxAJeI
	Doao81D7bICgL7hv9jBRjFcDnYq0YOumwPbOGFcpsIIYznizY4Y6yPC4q/fGTsOzynwXHu8D7S5
	Pk9iGqreTRpMJbiWEfFpiEIxgQc7TG5caqiJZ87fVKbWccKt4twgco9nSzT1o1LlQpnRENKQe+c
	HSwqVVQ8j0o+2M2CI5UpAgJj9nWvhdL+SBaw0WQuGYu45fUNPHfa8nAyHtnfvVM10JXHYdVtRD0
	cd1Eni6vyuJH2kXoT58Q0JHGVsk7OmzsEPSALy0hOAGKj6K6bcr8d89jGsKikXYQuRSBGKv11tw
	j93uESkkri/FZwiXm0xooYp3ZAAjByroH7A4weBwmIQm7A/FfkxXHQDrm8AzCcJykI40QGjW76z
	BcWcDx+OohA==
X-Received: by 2002:a05:6820:1505:b0:703:27e0:354 with SMTP id 006d021491bc7-713efb14bd8mr3282860eaf.66.1793293961512;
        Thu, 29 Oct 2026 10:12:41 -0700 (PDT)
Received: from [192.168.2.38] ([96.43.243.2])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a9049af7d1sm463fac.12.2026.10.29.10.12.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 10:12:40 -0700 (PDT)
From: Jens Axboe <axboe@kernel.dk>
To: linux-block@vger.kernel.org, Baokun Li <libaokun@linux.alibaba.com>
Cc: ebiggers@kernel.org, linux-fscrypt@vger.kernel.org, hch@lst.de, 
 dm-devel@lists.linux.dev, mpatocka@redhat.com, sweettea-kernel@dorminy.me, 
 stable@vger.kernel.org, Sashiko <sashiko-bot@kernel.org>
In-Reply-To: <20261023081908.3505413-1-libaokun@linux.alibaba.com>
References: <20261023081908.3505413-1-libaokun@linux.alibaba.com>
Subject: Re: [PATCH v3] blk-crypto: fix NULL deref and UAF in
 __blk_crypto_evict_key()
Message-Id: <179329395926.1528866.6542405425751626681.b4-ty@b4>
Date: Thu, 29 Oct 2026 11:12:39 -0600
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Mailer: b4 0.15.2


On Fri, 23 Oct 2026 16:19:08 +0800, Baokun Li wrote:
> Sashiko reported a possible NULL pointer dereference, triggered by the
> following flow:
> 
>   dm-inlinecrypt ctor            # first use of the fallback
>    ├─ blk_crypto_init_key()      # succeeds, ctx->key.size != 0
>    ├─ blk_crypto_start_using_key()
>    │   ├─ hw-wrapped key: -EOPNOTSUPP
>    │   │    # profile never allocated (NULL)
>    │   └─ raw key: fallback_start_using_mode()
>    │      └─ blk_crypto_fallback_init() fails
>    │         └─ kfree(profile)   # not NULLed
>    ├─ goto bad
>    └─ inlinecrypt_dtr()          # evicts whenever key.size is set
>       └─ blk_crypto_evict_key()
>          └─ blk_crypto_config_supported_natively() = false
>             └─ blk_crypto_fallback_evict_key()
>                └─ __blk_crypto_evict_key(blk_crypto_fallback_profile)
>                   └─ profile->num_slots # BOOM!!!
> 
> [...]

Applied, thanks!

[1/1] blk-crypto: fix NULL deref and UAF in __blk_crypto_evict_key()
      commit: c8c53d669d4e45b3a804013251a34387d7e11bfb

Best regards,
-- 
Jens Axboe



