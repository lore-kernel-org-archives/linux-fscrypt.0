Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795093043;
	b=NnPQhU7AAeT5ls/hXLDqskvHrt+d0bKms9d9GsEl2nEf3k1VyuDmEmj8tbhoFPJtxWzC
	 RL0BcFOhzW1niUkj4mQrTUvyHDsrU28C5rQyNTLgEjA7LLMQDCDlos9X1ECUwMvYUhgfi
	 naxzRSJDnxEW1Z3koNzRhLhSiSZiElY62AKUEUDD+p17B+2zv+kgHJvdiAjwmHnJ+Dtr+
	 c106HVc18kQ1J4+FkjnPl0t3WvASfOzPT9McrIbBYBuK9hvE/YgvfGx+ZQ+9X39k/MfLA
	 IhcoftpYlhIB/54RjPyneBhTCo+GTF+Vj9gpkL+JXTXUTnfvhsDIZGDNbLpDMyc4E1A==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795093043;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:Message-Id:X-B4-Tracking:
	 X-Change-ID:To:Cc:X-Mailer:X-Developer-Signature:X-Developer-Key:
	 X-Endpoint-Received:X-Original-From:Reply-To;
	bh=TdvjbVn6PVo/YxC1nWNnyc2VOQu8LWrEzkAq24zxhjY=;
	b=lroRqRIb55vJmHnOAH1Zm0twI4D3YYHbhxnfE7sg7gQFKGXTxewJDozEczI9+UoMMSJz
	 p6rSXmtaZTVI9phPokNZfVq9JPKTU4wTXqQYko/1rq3z42jyfgLP69FnscsYL5BzObCec
	 3uWu8Vyr2kdr1nJShe/ZKunE9V2hof5TeNR288fQv/AMWd7iq9I8/nL+WH0RXQQA6ScQ+
	 FGkoc7SNrdZxBLC24Ugb/M72qfugib0O4stmUZ+feR3i3LPU50iusGJrnGrOM+RKLRzZG
	 BZkZjiorn1jSGF7tGTRuZvCQhYIewR9tLdWZgdaaZ63VPkd+t0AwTX/4H70ea/3bBvA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CB0SLHyB;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E466606A33E;
	Thu, 19 Nov 2026 12:57:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CB0SLHyB
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1795093043;
	b=H3aTJqpSltis4OELg/E5Wx8lgAW4J/qH+DObQYImJ5w+oAjXnvI8TjxjONUk7PNdKdob
	 leaUs/LjnpAuS6hgtrPfE6IX2ipSEdKcsKhWF01jlqkLvoYFtfDtH5FkF+6x8TTjalAaA
	 oS/IOKMmFGP1VOrghZaFiTGG1Hbef9o/DaQQIrzuliP8luexbg/p6tSQEML+PE9mpakBA
	 ctIc0MgElN2aMw6BVsEyHveXjOeujQRE/N2qmZqJkR7wwl4o80AL+Oc57GNWbFweyISip
	 DQqd3YoKUZDwRgwJJ0kistpX9NLcDRufd7TJXKUxG2888OW5xkjL7KRAJsJl+asPjJA==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1795093043;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:X-B4-Tracking:X-Change-ID:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To;
	bh=TdvjbVn6PVo/YxC1nWNnyc2VOQu8LWrEzkAq24zxhjY=;
	b=NDfy/YMafCfsBufGEM5av2Jnjzxc+sO8M0+LTFEvHxiEtSCZVFu6+yWDjRRTXTju4w/9
	 YtmrLd+ywRletXa1gpy6NIhbEYcpRkNQXOmi/BjIzHYDjPa6G8UBU2SwnfRJhXvvIrIfU
	 yUWGZA7iMgxTjaIKe8PRSgpVq+3pAygq17Qeg5w1e2xEbnCPyVmeG+zdqzhnq+pQ70ox5
	 Z9had1G+fLXGCjDsMMIJmyRKysxKdApSOIicxpDtp5s6c+oJGJKUDG0+dDbsJdhz9mbpx
	 zAA7SdG6h6pHz3TjgiYAwj5ZMOIJ1thimiAGjvcBMdeRBPua50UxN/C/1Y+zG6sF8pA==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 118E71F000D1;
	Thu, 19 Nov 2026 12:57:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795093043;
	bh=TdvjbVn6PVo/YxC1nWNnyc2VOQu8LWrEzkAq24zxhjY=;
	h=From:Date:Subject:To:Cc:Reply-To;
	b=CB0SLHyBm1l8Zm9nWyWad8Kq4l6t+3nxsSlfVm5LVBHJJM7HciVDNFsQdVcJhxzAK
	 FqoF6InWcGLYYNtz43JO1VhWzqnayAwYQ8KZGjy6OOkciIIxkwTqeA0vHELbLq896J
	 fzRFUQpHdb0CmDdVM/Ng+VhDf3BuSTFx4eGyF2561w9vfrDr9CfS920LZ3xgw1n+hM
	 arUvfxB1DFNc0Ehnhy+UewqL3b6qMNnCYvwmVr0O1LTnZvFu4CHkF6Cl7Awh61b5ct
	 e6uC0s1MbM0GjoXsD7pQqKdEPDk/uE7D1G8M0lu0K9PIoZnrHNQkv2JwdPwPlxDxLc
	 OtwbNDdgtV6kQ==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 625A04B2B0;
	Thu, 19 Nov 2026 12:57:20 +0000 (UTC)
From: Suyuan Wang via B4 Relay <devnull+shyckless.gmail.com@kernel.org>
Date: Thu, 19 Nov 2026 12:57:20 +0000
Subject: [PATCH] fscrypt: Don't set a policy on immutable or append-only
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
Message-Id: <20261119-fscrypt-v1-1-c07e1dd93644@gmail.com>
X-B4-Tracking: v=1; b=H4sIAC/y/moC/yXMQQ5AMBCF4avIrDVpu2jKVcSixmAskA5CxN0Vy
 y/537tAKDIJlNkFkXYWnqcEk2eAQ5h6Utwmg9XWGWMK1QnGc1mVDz44ry0G1JDqJVLHx/dU1b9
 la0bC9Z3DfT9gVfx9awAAAA==
X-Change-ID: 20261119-fscrypt-8a8a6802cac0
To: ebiggers@kernel.org
Cc: jaegeuk@kernel.org, tytso@mit.edu, linux-kernel@vger.kernel.org, 
 linux-fscrypt@vger.kernel.org
X-Mailer: b4 0.15.2
X-Developer-Signature: v=1; a=ed25519-sha256; t=1795093039; l=2183;
 i=shyckless@gmail.com; s=default; h=from:subject:message-id;
 bh=bkUMq9TQAUp7j8HTWB6oD7Om1tlULjPX8N2Xbu4lXn4=;
 b=BOF/mJPnAVkejDkaX0f8vEY4LP69odAYy37bE0kKTGiRbRAsRU4uGR+z41xKWLqJipS22RxD8
 ws7iITmByAYAheXTfuJcvUqTuQ1dC3MqNc7+Zr96JYKbV7UrH6H9PBd
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
already set still return 0, since they don't change the inode.

Found with a static analysis tool and checked by hand.

Fixes: 0b81d0779072 ("fs crypto: move per-file encryption from f2fs tree to fs/crypto")
Co-developed-by: Kaixuan Li <kaixuan.li@ntu.edu.sg>
Signed-off-by: Kaixuan Li <kaixuan.li@ntu.edu.sg>
Signed-off-by: Suyuan Wang <stevewong@hust.edu.cn>
---
Tested in QEMU (x86_64, ext4 with -O encrypt, v1 policy). Before the
patch the ioctl succeeds on both immutable and append-only empty
directories; with it both get -EPERM, and an ordinary empty directory
still gets its policy.

The Fixes: tag points to the commit that created fs/crypto/policy.c; the
ext4 and f2fs encryption policy code before it lacked these checks too.
I left out Cc: stable, as I'm not sure you'd want this backported.
---
 fs/crypto/policy.c | 2 ++
 1 file changed, 2 insertions(+)

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




