Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61BF83A7F62;
	Tue, 18 Aug 2026 18:41:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787078467; cv=none; b=H9Ylrcm9Oiu6u9VR5vWkkvnxIg7yp4KWdeX0XgmskX11pCOTnBImkrsXVxrNKcTpIVW6/LFHi35DM/Yg6/SEz2BEdfLFAwPI3jcOX2ui6GEwaE4eCWN0HPbPFCbAxpah7w27WYkMLSW9DjyVR5AYzAZ9lwuk9oO8oKin0+7txWM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787078467; c=relaxed/simple;
	bh=P8jNOScVA325C023+oADT33w26iJk/H4cegsL1CP/Ig=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=bOQo/ptEVbC0TJZ5tw1v6fTxUQLIIk9k6LGosVS/y3CGbKJHVTyAopYTwcGyJJCr6pEXuO4NLvuW4PtOxnAtASGflsMeyTqsszi3yVxoC4/5suAP+1k81GFl961K3RKS9iPyn4XDVjYjje8O+tziu3vIvN7gJiltZf+z+aUPme0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=luqRzLJn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="luqRzLJn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E7A4E1F000E9;
	Tue, 18 Aug 2026 18:41:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787078466;
	bh=unekuBrdL+UEnEHGFEKqOZsVPvNnWNrVaCTyCo3nGVo=;
	h=From:To:Cc:Subject:Date;
	b=luqRzLJnW6q2p8HY82V8nmmrlKVqfjtoA+KwB5FYnwqgEWazJRUQsyHuaLaK6apRk
	 QbKimOhBXkYixx8btzvrtkhdQtVlmQIl1YE9oSv5Oti925CygcIOVXYR0xWf//IdpI
	 ZHnQxJZUlbUC/K9IjMoP6oJCGnfMPU2xTHjSa1585OOh3KJAr4Gkc+Jc/r6R5LrTIU
	 o0Qv73wFF/bfnxLsUWvE8J3jOtSKx7+arGL9zCEhY7m2q1Xj8JhulndJcUpMh07s5Q
	 lxqCn/dSX6NcqopZlWBn6CSDE2aDiGGf104n6xaa+eKl42u8JZjxYi7W7XnwH6SgST
	 gMM0PIfhETCyw==
From: Eric Biggers <ebiggers@kernel.org>
To: stable@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org,
	Zhan Xusheng <zhanxusheng@xiaomi.com>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 5.15] fscrypt: use the mount idmap for the owner check in fscrypt_ioctl_set_policy()
Date: Tue, 18 Aug 2026 11:40:52 -0700
Message-ID: <20260818184052.80142-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Zhan Xusheng <zhanxusheng@xiaomi.com>

commit cf6c993c0feca7984797e634deba3c80342e199a upstream.

fscrypt_ioctl_set_policy() calls inode_owner_or_capable() with
&nop_mnt_idmap before allowing an encryption policy to be set, instead
of the idmap of the mount the ioctl was issued on.

fscrypt is used by filesystems that support idmapped mounts (e.g. ext4,
f2fs), so on such a mount this compares the caller's fsuid against the
unmapped on-disk owner rather than the mapped owner: the actual owner
can be wrongly denied with -EACCES and an unrelated caller wrongly
allowed.  Use file_mnt_idmap(filp) instead.

Fixes: 14f3db5542e6 ("ext4: support idmapped mounts")
Cc: stable@vger.kernel.org
Signed-off-by: Zhan Xusheng <zhanxusheng@xiaomi.com>
Link: https://patch.msgid.link/20260725080004.929328-1-zhanxusheng1024@gmail.com
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/policy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index cad34dbe8e298..42da1f9e6492b 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -465,7 +465,7 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 		return -EFAULT;
 	policy.version = version;
 
-	if (!inode_owner_or_capable(&init_user_ns, inode))
+	if (!inode_owner_or_capable(file_mnt_user_ns(filp), inode))
 		return -EACCES;
 
 	ret = mnt_want_write_file(filp);

base-commit: aabd761612dbeb7d40750d485da219d11433718a
-- 
2.55.0

