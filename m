Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E9922221F12
	for <linux-fscrypt@vger.kernel.org>; Fri, 23 Jan 2026 07:30:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.194
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769153449; cv=none; b=WSrtNole1PRtY23+UDjPdF0jJXCV06rVBpXHXOva9bx7KJM/IQlB/UvmPxez0tLdIrh3bfuQAZ4FZ5kuuEKkKZS82FOj8m/lATjG4exhBk2am71MXGxumBdmU55sQih3oqAuaFd9G16vzz7A9eiY9eY7PpnjZ8yKm/VFYen7lPc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769153449; c=relaxed/simple;
	bh=g8GgA9QHBYqqibg8CbLuOuXUoACa9yDVt7JfIHcJGus=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=hNs38jLqpqr8UwXuwzWXBX9LWqKNpg4i1aD3ERlaYQ4VCqv67TyJ5Pey+cFnsTR9d366cmjHKgE5lVv+ofRKN4uzMCdufjOsbITw4kJ1A+pIe4eRA/FsgTyOj7Ankj0HcDIPkOkO7LS/TXkzpykCW/zYjb6xxw82aZtAZTJtjVM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=WH2EmAxu; arc=none smtp.client-ip=209.85.210.194
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WH2EmAxu"
Received: by mail-pf1-f194.google.com with SMTP id d2e1a72fcca58-82310b74496so618917b3a.3
        for <linux-fscrypt@vger.kernel.org>; Thu, 22 Jan 2026 23:30:47 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1769153447; x=1769758247; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=uoGsK/muQg9vgFdQLOIU9Dx/FgPplM5sZmLMNyZ79jA=;
        b=WH2EmAxuFx5lR5oCEAL6ZSUJHA+bgx4SaSuOwB2ttffDseJV/wOF39YKOInZToDMoF
         2dp6h+4TGKIc7AHuGSnaIkHOiK2EvYlrc1/AKIHzOqBIcNbAuH5pNjHao2qPMKB+tFza
         i/R6L3C8dvMjNq0UTi5gm9A+f3XxbjaWE42/VTOAFYZhTuh8Q7TGhi2A37Q7fqDUclis
         sqiDCFWiazzxut2Dvtv1w4P7EnRp0XIFPkxRn2VNTpGFZodvWqJYyrAFFF1rk3deGKrp
         35mOg3GSaf4eiqiXHIwF1j2M5lgwN3lNAOwgQIq0PlHoRrjZ0J8eBvP6Gif/kd5i+j0f
         tRlQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1769153447; x=1769758247;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=uoGsK/muQg9vgFdQLOIU9Dx/FgPplM5sZmLMNyZ79jA=;
        b=cVy6HB1vrPrLVEoiqU14xeEcNfeGUcBrWapLYf/izm8ibL32/JP4HcodX5CpCrvcDa
         oXkiM5RGSHCGkV7FsJ09ygXnpWxrdaKgQo4XIdVJypijf6WqwugUdImxDzFZsIrJppbd
         Xmrzxe6gremjZgk3J9JQmFmqyP9TW3wsRfAhHTEcNI38ZggW23ZGUzD4K1RDCfgPNRGX
         GAe9DLBBjwdcul670jAGZNGMXnRwri1p5Cppf2aogDGLEUucym9a5sRKEC2TwqlqvxCN
         piIPcl0N5+Wp5BxMQMojm9gDiIxSqfvhrkp3JZ1XVGk4HaAvIexzzihY3BJsE/pBQEzf
         LTVw==
X-Gm-Message-State: AOJu0YzQy6WYMM2aPhVHxUs497T5fnTfTCCH+W9FJ1Z/fIPvLTdeIyyp
	Aka66w0DR3HJ8OpXwYq9K8uTCGE8igcmaKKbgcfXmNRwnoqkIFy0m4TT
X-Gm-Gg: AZuq6aKkcc4UVSJ5ZdXNc+L4lxIcF6WRKh/71ySvomCsUpBDfNF1RqUiwTxX9fIEJET
	8y/TV78TqHhbOmbnIyyl0yMK0btcABBuAPDPz4JEZ0rt5EoKQIr/E2UWuercwEPYmfCeEESYqLl
	TRuYVKwo+4muRJFg/w5d2G3sUTRkShidcP+whxQkIHwySGSxwggNJyZZF467/6QW7nS5fFMmq1G
	aY473tNYac3yoKDaAXtFbRKnchfUUZKXm8h2oMuU44efxfHobHoHfTeBT7X9dbtPhMg94JF7fKM
	H+h7pqjC/DuB+a2M3TDISNrGcbYKvyDyCFSfIsmPLy0UndlCs8bvw0EIP3hFwl5/6UIaKOWz0I7
	bUcNjOMwBBMuolC3x4Kdmwyff6rCs3gXfOuhBmLqbEdaYoF+FjQAeh1dDNTiWba8X5Yt3GRpuBs
	lPAhYxho0wk7eWNHyJZu/NoPhga6mH7YWOxBNuOw==
X-Received: by 2002:a05:6a00:27a2:b0:81f:3cd5:2072 with SMTP id d2e1a72fcca58-82317c12b0amr1853255b3a.3.1769153447187;
        Thu, 22 Jan 2026 23:30:47 -0800 (PST)
Received: from lima-ubuntu.hz.ali.com ([47.246.98.220])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-8231873c117sm1339625b3a.47.2026.01.22.23.30.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 22 Jan 2026 23:30:46 -0800 (PST)
From: Qing Wang <wangqing7171@gmail.com>
To: ebiggers@kernel.org,
	tytso@mit.edu,
	jaegeuk@kernel.org
Cc: linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Qing Wang <wangqing7171@gmail.com>,
	syzbot+d130f98b2c265fae5297@syzkaller.appspotmail.com
Subject: [PATCH] fscrypt: Fix uninit-value in ovl_fill_real
Date: Fri, 23 Jan 2026 15:30:37 +0800
Message-Id: <20260123073037.4164303-1-wangqing7171@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Syzbot reported a KMSAN uninit-value issue in ovl_fill_real and it was
allocated from fscrypt_fname_alloc_buffer. Fixed it by kzalloc.

The call chain is:
__do_sys_getdents64()
    -> iterate_dir()
        ...
            -> ext4_readdir()
                -> fscrypt_fname_alloc_buffer() // alloc
                -> dir_emit()
                    -> ovl_fill_real() // use by strcmp()

Reported-by: syzbot+d130f98b2c265fae5297@syzkaller.appspotmail.com
Close: https://syzkaller.appspot.com/bug?extid=d130f98b2c265fae5297
Signed-off-by: Qing Wang <wangqing7171@gmail.com>
---
 fs/crypto/fname.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
index a9a4432d12ba..ba8282b96a2e 100644
--- a/fs/crypto/fname.c
+++ b/fs/crypto/fname.c
@@ -220,7 +220,7 @@ int fscrypt_fname_alloc_buffer(u32 max_encrypted_len,
 	u32 max_presented_len = max_t(u32, FSCRYPT_NOKEY_NAME_MAX_ENCODED,
 				      max_encrypted_len);
 
-	crypto_str->name = kmalloc(max_presented_len + 1, GFP_NOFS);
+	crypto_str->name = kzalloc(max_presented_len + 1, GFP_NOFS);
 	if (!crypto_str->name)
 		return -ENOMEM;
 	crypto_str->len = max_presented_len;
-- 
2.34.1

