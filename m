Received: from mail-qt1-f182.google.com (mail-qt1-f182.google.com [209.85.160.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0544936494C
	for <linux-fscrypt@vger.kernel.org>; Sat, 25 Jul 2026 08:00:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784966415; cv=none; b=ah1RsZfmpspzPAu6hWuGzE50QcoHWVY85/S2mNmfVZl+kTEnWLyfx85cfhRkaHwMzMbz18s6ggA7EYMLZh1EUiUYJcTeG1+e18+prBdQVwXJujd8+jgtV9CrFnkeJzcNQCBpGxWXRyBWOcXuq2TAfoYrrQY90BIH7r5KM8czj1k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784966415; c=relaxed/simple;
	bh=x0azAcsCMMPMXxXDdBsJkovGUPenS+iAVlLZJGdkobQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=G6bMNvz5TVhbCtasJsnemMiji6oL8GyCvohaDSFlYzZKfzXGJb/S7zsqjp4TckbqKG+sqUoE/8Saed3744HEGFLgD1h1dVT9fMsDwIN7Y6OHzB/bk/ybfG6Q1ryvE1bVvyd6bzW6SNik/dm2EM4tCCwAwb9z2UGta5B3aB/gGx8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=IzO9y6IM; arc=none smtp.client-ip=209.85.160.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IzO9y6IM"
Received: by mail-qt1-f182.google.com with SMTP id d75a77b69052e-51c0c45c580so9286181cf.0
        for <linux-fscrypt@vger.kernel.org>; Sat, 25 Jul 2026 01:00:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1784966413; x=1785571213; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=aN3F1x7OR5ZXu0ndJb6FFcDobq/hnEMNM/moElJMtpE=;
        b=IzO9y6IMto5SfJXpoelyqw0Erf1g+5Pb0+cqmCD2rRcQPIVTzVDbvMDo4OwjB2XFPO
         N93eHsLSFAKgKGUab/FT+H54BkPXbMx/RUScRi1YoTxj6Yrcuwe+2czW8Xv0Cr0s9McG
         tBpmDMrtl1RnQGKy1rQIdh436Lq9H/VMo81OyzA14+P9GrwVG4akFvvm40e+mILimufZ
         lEjVwBN63xnKqk+kUhu/PC0jHGkf1wLoWDy3ygSQV0mYkUufFKJt5ZfhNZwhBhZCcd/n
         QeC5RtHuHcuR9K8836570hdYFrbXqJorqns4EL6lFp0K1VPqPYwAJI2NyYyLXpCDLaDq
         1xMw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784966413; x=1785571213;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=aN3F1x7OR5ZXu0ndJb6FFcDobq/hnEMNM/moElJMtpE=;
        b=YH04QyIS1kQcCnI5uJjzFltZhezd4wxrkgQYeQK4O5xzljIHak1NjKdCugsJLYODm3
         NdLRmbEvLdNyVFaD9Aj9klWQLahm+cvyRh91Dq78Dpw7E0OpL/BtiL/ZlpJmuGEokNz0
         aNFm1xhRq1TvDw8IEdlY/TP5UFEepKzYAkMWbLzjxlbzLYqAOLA7P6b7SUIbwbVOZ4yt
         YAvGFi+dUMiw9jFWMzh+dgQeMBKjoK+MEOkFBytV6ihthAvEbxJUOamel7B+gSzEL05t
         aSl1quZPpA2eN6mOT0+UnNA0UslL1PJwNzcR5iRPqYtd9lTKAV6/C9BnTJxKJ2+QGB3W
         P4ag==
X-Forwarded-Encrypted: i=1; AHgh+RrCaGTNYIljOXixu5UCoV/qC1i6vQGe43NA0o6JkEfWpvn2gzWorgdM+FybqwC7yzAyHahJmpvtpMaLsbzR@vger.kernel.org
X-Gm-Message-State: AOJu0YwxpPAWL6aii4Ks6sJAkayJs8M9RdpKhhj2DmwzFkBDSCHVDyik
	muJxBfNu8CxdMZDdCKR5pYs/TWJ2XS/vCqLaY2wi0tbqG4AYYMinoeyZ
X-Gm-Gg: AR+sD12VOQEADhsoTmZwahRP81V+O4aBUAeofst8MFsKsD3JNEY1we+nIDSchwigQ9U
	cwms4oSkRBH3zQ2Dh0torRaaTDPFPVWc9gWHVFGXR/XGvjSwTUAniagZoxPMuP7QHGiYxhXd+Bv
	eZ8zlBKVtDZheoaGFesH9OSxrulompvRmJNb3dsAxAVAxndkUqs/abYG1kK39MDwCTljd+KT7bE
	kGisiLems07+RpaUdmwzu6bB/nnRDvz25dR5URTYQN9sH+gUY1I0nn7NDv9wGv7iY/nWJiPQkhM
	F5bI6Usnb+3maUQO4aSgs+x3D3mxIP1tBo4gJdMSLTanVuHkXTozk7eD3+YB018/GY4TJPWBIt0
	6piWlTMfhNk8WvGsBqonbUxNF8D3myN56Nh4Z5x/VOCTLWR+zh0Ui6y2Zl4261GikY+tEL6GL0U
	Aq0XQAf7c9lH5rsZsPxQ==
X-Received: by 2002:ac8:5a47:0:b0:528:325c:2905 with SMTP id d75a77b69052e-529a8721edamr12780321cf.63.1784966412617;
        Sat, 25 Jul 2026 01:00:12 -0700 (PDT)
Received: from osman.mioffice.cn ([43.224.245.178])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-907e86a1b73sm15788896d6.32.2026.07.25.01.00.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 25 Jul 2026 01:00:11 -0700 (PDT)
From: Zhan Xusheng <zhanxusheng1024@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	linux-fscrypt@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Zhan Xusheng <zhanxusheng@xiaomi.com>,
	stable@vger.kernel.org
Subject: [PATCH] fscrypt: use the mount idmap for the owner check in fscrypt_ioctl_set_policy()
Date: Sat, 25 Jul 2026 16:00:04 +0800
Message-ID: <20260725080004.929328-1-zhanxusheng1024@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Zhan Xusheng <zhanxusheng@xiaomi.com>

fscrypt_ioctl_set_policy() calls inode_owner_or_capable() with
&nop_mnt_idmap before allowing an encryption policy to be set, instead of
the idmap of the mount the ioctl was issued on.

fscrypt is used by filesystems that support idmapped mounts (e.g. ext4,
f2fs), so on such a mount this compares the caller's fsuid against the
unmapped on-disk owner rather than the mapped owner: the actual owner can
be wrongly denied with -EACCES and an unrelated caller wrongly allowed.
Use file_mnt_idmap(filp) instead.

Fixes: 01beba7957a2 ("fs: port inode_owner_or_capable() to mnt_idmap")
Cc: stable@vger.kernel.org
Signed-off-by: Zhan Xusheng <zhanxusheng@xiaomi.com>
---
 fs/crypto/policy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index 9915e39362db..c80b24a941ad 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -534,7 +534,7 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 		return -EFAULT;
 	policy.version = version;
 
-	if (!inode_owner_or_capable(&nop_mnt_idmap, inode))
+	if (!inode_owner_or_capable(file_mnt_idmap(filp), inode))
 		return -EACCES;
 
 	ret = mnt_want_write_file(filp);
-- 
2.43.0

