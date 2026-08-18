Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A526C3E3C7B;
	Tue, 18 Aug 2026 18:40:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787078403; cv=none; b=A2QTLenA/Cti5oYHPwmiF4K0fv2D4DOqMOolXbJp0jmeiblQ637PzwhdJ6s0NHiJi16E2N8KVVPBUFe/eLWlD03fgnyAn0nv3nfyay+OZrfj7E6QxCS1hnEHc6GQ1kHYI0VTofTwEzlsSQyh+EnW60I2WxnUlmH7BTG6cZ2eGuo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787078403; c=relaxed/simple;
	bh=5J56l1tOorwmJc600YNtNPrl5VwpCyN4uMxMy7jRQ4E=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=oqXNd3CWLuuMTpP5s6Ta5aqbl5DZvVkfGVp5vFC1Rzau8gS1lDL0WOSx5VQf64PUEl/hn6JF4iKgdI92GbcqVefxQiJS/tRH66U7H89x7z1D7Ab5vgRH5jzOd3ynjK5i75IQJPTcQbjVa1yRUrostNFI7aXpX4lo58AxbcTKzhM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QDmwFgeb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QDmwFgeb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 763821F000E9;
	Tue, 18 Aug 2026 18:39:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787078402;
	bh=F7I984AgEpmtAzDLu5TwUZqQO9XXY8OJsWUtuZP/6nI=;
	h=From:To:Cc:Subject:Date;
	b=QDmwFgebfkOh39ngVI1WEr9hTTgO9OCIvHdj/ovnP6F1GN+aLNANWrerN/Vr3H1Uw
	 2+hjTvexfcM74677eJOEGFy/SA+uDRu9/KCw6Vaa8CaL9i7XxFvA95A+oXfegx52XD
	 WrXZOqpCjoIoD5dKDkJ/bub9qlrPokZFD//VCfJaA0bGvXzEBXdCzFWdtu90RonTsU
	 izNuZr+uGfP8wyDuLmQDaWmfhr5uVSXHo9NZEB7H1iklFw38Q16Oe1LciKqDJ2hiD+
	 kympY5dkAREBwFLQs4bwyEa7hoj9wU+1KtR+Z/cJwGoSHMEFqnw/dJwCR0IgoG7ZwW
	 8eLM/8R7LCyMw==
From: Eric Biggers <ebiggers@kernel.org>
To: stable@vger.kernel.org
Cc: linux-fscrypt@vger.kernel.org,
	Zhan Xusheng <zhanxusheng@xiaomi.com>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 6.1] fscrypt: use the mount idmap for the owner check in fscrypt_ioctl_set_policy()
Date: Tue, 18 Aug 2026 11:38:21 -0700
Message-ID: <20260818183821.73242-1-ebiggers@kernel.org>
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
index 46757c3052ef9..d0f97caa20211 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -494,7 +494,7 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 		return -EFAULT;
 	policy.version = version;
 
-	if (!inode_owner_or_capable(&init_user_ns, inode))
+	if (!inode_owner_or_capable(file_mnt_user_ns(filp), inode))
 		return -EACCES;
 
 	ret = mnt_want_write_file(filp);

base-commit: e4f7d8be268ecf717f94ee2e242afa79ddeacaed
-- 
2.55.0

