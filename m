Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795148816;
	b=lswlxrrtLZZfNbUxudT2p0d2ST8AQEHn8/vtyHtfwOaxV1yN1pM8QJGcDS1EOLNpUUxb
	 wXpIWiU0JzM6RB0263MEfkn1ZEfho9QS5PehEnjA53vzRTqHbsbByAN8HPNQWTL1dux3/
	 souXQOI/kS+gbBzRA/hZezES2maEvaNVrA+FsQEtzw4vA5tOldaA5u/VxZb7ybIkPklLe
	 5x8IouAbiuTNOW8+NfPx3xpSqzqfEdXmZx1GG8s5P9jaTedmmXMYBrBIjITBqbUu7LgDJ
	 ryUPETXFIqusJHYvQHWkOlG5vX356esY9+tWiIj26/3cE4CTCU+SpsYM5ny9lwRhYTA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795148816;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Message-Id:X-B4-Tracking:
	 X-Change-ID:To:Cc:X-Mailer:X-Developer-Signature:X-Developer-Key:
	 X-Endpoint-Received:X-Original-From:Reply-To;
	bh=/7HhvEBlTjsYx3VJ0ZjxqLEYPqJcAw8xWS65A1UC11Q=;
	b=BxZlD2DHdmre9zVCPe02A4+XVtdawKjMsLSPfM40sYf1DxoLuQv8eHmhkoBaYnOCO2j2
	 tS11DRyQcyu8fhbIn0cyn/7WW/27jhPWVDHUiIudJon1fVF/SN42y45VHo2TRC3zZI1c5
	 2FKL+/Davz82c8HoYGMOU7HHHjORilG01t+pN9ghNcLi/wL1bDACZPsYN3RdAbmMQcAji
	 tgHS858ti2Fp8maxOH1WJg/fkeCC/YFynzruyNBbY0MNiJZmJXBApfrv5/mgFu79prF4F
	 oe78nAxG3TtQxFq+AjVjt7gSViAE3v0+c7DfI/jKmZxDCgXUOPQOyF/5xu9X8rPGV/A==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bXTqNSG2;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FA47606A320;
	Fri, 20 Nov 2026 04:26:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=bXTqNSG2
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1795148816;
	b=1ZQ820EV2lNYj0Wl3ggYn1UcEGcUNCfGFSle2iWh+pqhGOGCgS3xSKXF9wu32jPBWdVv
	 svDWz2y5z6wxxZoipiBazK0xwt8zjtTDstHjMB1dN7fmPD9qff1KFKfWie0VNS0CdWJ8v
	 7Q/M+xVfh0IDUWLZvkNUkWfXfZrOJyJmaENsMu8BfdyhiADQO6xjKsy6TfZmM7Gt53DzF
	 QMfxoPJ9u4P11yail3Rx+Aa2N4cQBrImtsTr03dp2l3EYzYDas8Vgd2ZSKaUVSsYRdOZC
	 GDxMRvdkbZ1VOHuImoTtudtY/KGz+SDjhdqkesmKLQ9LK+bYWLcIBNkCIgLm749WHgw==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1795148816;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To;
	bh=/7HhvEBlTjsYx3VJ0ZjxqLEYPqJcAw8xWS65A1UC11Q=;
	b=Liz8K+wcPCDhkLnnzqCk3yuoJdLqGUeZKj5H9LmVINrx/XfNOX0rgzwEiS47VaSBbs67
	 pqLMrGauWsJK/DNiLUv2FiVL4cFk102JXh3pbb5X+Oi5h6vWQwxETZGjHSgT2QWVvFVwG
	 Vvd1TQf1R1MIrOTsvxZG6pd47WGx/YEm4h8agepBnHghfol0BMUBobF6g4N5JmnGpFaze
	 E7dkhnpzBaf0S8LlReAz3WyK6z7nixGsVcrJUbOXG4wCH853v5ccbOcy+w3fVYHpxlV8L
	 SguoMga/KHACI9H9/D+06zZKBgPR3TTMNPI4b2YBEAt+K1Ch/b1GRVZVMUdmpsVl2Xg==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 816471F000C6;
	Fri, 20 Nov 2026 04:26:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795148816;
	bh=/7HhvEBlTjsYx3VJ0ZjxqLEYPqJcAw8xWS65A1UC11Q=;
	h=From:Date:Subject:To:Cc:Reply-To;
	b=bXTqNSG2D0I4PzxXReHLOVE8in1H80uJ+LPdBRlDZVzahHScwtoH7Bnb5e1Tn4+Fp
	 ka0VUwx1jKTBJYtexJw7oajKz5NkqnbBGE4ZKBTxWKSqoPaOOBTg3SHTbFOQw3XQyA
	 g7PhxvKmqiPvzs/u6sFG0wS8qqROI0zrzbLmZkHT/FLNqOWVRVpFmDrHeoJlYPDaye
	 GX4MA2z1hVsn1yOisXl4VGMBQ2etrpDa8GCB3+HNLptugkFy39IDxcvx2SwL5L+QXD
	 C5Y3a2hOdgB4D2cWVaHKrW+Mk9CUub46ZXhW+IOyx1fJBaJnbs4ezxCuLt8mWhLnvs
	 KLVKLP4a5W07w==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 11E8D49590;
	Fri, 20 Nov 2026 04:26:55 +0000 (UTC)
From: Suyuan Wang via B4 Relay <devnull+shyckless.gmail.com@kernel.org>
Date: Fri, 20 Nov 2026 04:26:54 +0000
Subject: [PATCH v2] fscrypt: Don't set a policy on immutable or append-only
 directories
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
Content-Transfer-Encoding: 7bit
Message-Id: <20261120-fscrypt-v2-1-fb752135ea32@gmail.com>
X-B4-Tracking: v=1; b=H4sIAA3M/2oC/yXMQQ5AMBCF4avIrDVpu0BcRSwYU8aipIMQ6d0Vy
 y/537tBKDAJ1NkNgQ4WXnyCzTPAqfMjKR6SwWpbGGO1coLhWjdVlRrRuKGiUkOq10COz++paX/
 L3s+E2zuHGB9Z/Mw3awAAAA==
X-Change-ID: 20261120-fscrypt-870cc1fd8e70
To: ebiggers@kernel.org
Cc: tytso@mit.edu, jaegeuk@kernel.org, linux-kernel@vger.kernel.org, 
 linux-fscrypt@vger.kernel.org
X-Mailer: b4 0.15.2
X-Developer-Signature: v=1; a=ed25519-sha256; t=1795148814; l=3139;
 i=shyckless@gmail.com; s=default; h=from:subject:message-id;
 bh=HdhE/JCVYL2ShTcy8TLudc8o8wzmup9lBguCVgI9jFA=;
 b=u5JY19oJwFRT9thLPhYwuqQwILk8t5gZKg9f70tbYfLu8UCqK/d5b2jUitWeBGrpXS21ya+vb
 YmGkAV+dFAnDI3X1EzpcXLIrqA0SZocPubH7LDtmBMk3iHLgs5OSyis
X-Developer-Key: i=shyckless@gmail.com; a=ed25519;
 pk=pMtccVGiWES3bV+7YBFuBclkvq2n2HBHQ5azaBrK2lY=
X-Endpoint-Received: by B4 Relay for shyckless@gmail.com/default with
 auth_id=1498
X-Original-From: Suyuan Wang <shyckless@gmail.com>
Reply-To: shyckless@gmail.com

From: Suyuan Wang <stevewong@hust.edu.cn>

FS_IOC_SET_ENCRYPTION_POLICY stores an encryption context in the
directory (an xattr on ext4 and f2fs) and marks the inode as encrypted.
fscrypt_ioctl_set_policy() checks inode_owner_or_capable(), but not the
immutable or append-only inode flags, so the ioctl also succeeds on a
directory with one of those flags set. Setting any other xattr on the
same directory fails with -EPERM in may_write_xattr(), and
FS_IOC_ENABLE_VERITY refuses such files as well.

For example, on ext4 with the encrypt feature:

	mkdir d && chattr +i d
	setfattr -n user.x -v 1 d           -> Operation not permitted
	FS_IOC_SET_ENCRYPTION_POLICY on d   -> succeeds, d now has a policy

Return -EPERM for an immutable or append-only directory before setting
the policy, as may_write_xattr() does. Calls that find the same policy
already set still return 0, since they don't change the inode. Update
the documented EPERM cases to match.

Found with a static analysis tool and checked by hand.

Fixes: 9bd8212f981e ("ext4 crypto: add encryption policy and password salt support")
Fixes: f424f664f0e8 ("f2fs crypto: add encryption policy and password salt support")
Cc: stable@vger.kernel.org
Co-developed-by: Kaixuan Li <kaixuan.li@ntu.edu.sg>
Signed-off-by: Kaixuan Li <kaixuan.li@ntu.edu.sg>
Signed-off-by: Suyuan Wang <stevewong@hust.edu.cn>
---
Changes in v2:
- Point the Fixes tags at the ext4 and f2fs commits that added the
  ioctls, and ask for a stable backport (Eric).
- Document the new EPERM case in fscrypt.rst (Eric).

Tested in QEMU (x86_64, ext4 with -O encrypt, v1 policy). Before the
patch the ioctl succeeds on both immutable and append-only empty
directories; with it both get -EPERM, and an ordinary empty directory
still gets its policy.

v1: https://lore.kernel.org/all/20261119-fscrypt-v1-1-c07e1dd93644@gmail.com/
---
 Documentation/filesystems/fscrypt.rst | 2 +-
 fs/crypto/policy.c                    | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index 6e2e511a70bb..188295f09b21 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -736,7 +736,7 @@ FS_IOC_SET_ENCRYPTION_POLICY can fail with the following errors:
   feature flag enabled using ``tune2fs -O encrypt`` or ``mkfs.ext4 -O
   encrypt``.)
 - ``EPERM``: this directory may not be encrypted, e.g. because it is
-  the root directory of an ext4 filesystem
+  the root directory of an ext4 filesystem or is immutable or append-only
 - ``EROFS``: the filesystem is readonly
 
 Getting an encryption policy
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index 6dd510f93e6d..86a8254bc3a8 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -553,6 +553,8 @@ int fscrypt_ioctl_set_policy(struct file *filp, const void __user *arg)
 			ret = -ENOTDIR;
 		else if (IS_DEADDIR(inode))
 			ret = -ENOENT;
+		else if (IS_IMMUTABLE(inode) || IS_APPEND(inode))
+			ret = -EPERM;
 		else if (!inode->i_sb->s_cop->empty_dir(inode))
 			ret = -ENOTEMPTY;
 		else




