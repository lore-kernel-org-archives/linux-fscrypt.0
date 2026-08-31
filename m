Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 368A6233944;
	Mon, 31 Aug 2026 17:58:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788199099; cv=none; b=YbVb9MePVMU9kRYuZ6Aj47WxRz2CVe62DJ9P/AT30I02IfsJZhfVwtEwooGBzZtGXhfljwfH57IlDOwjH1vv/fP8n+cqR5JeW0tHnrm386F1jnf26fqdTsF5DHbM3BdKwlmiS9nEDp0K1Ykt+QxMgKHTvCjNzhWX7j1NdzYNXAo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788199099; c=relaxed/simple;
	bh=jYlByoaRCUxRRkyjfLu/xA70aQ+VziSSYvM4QRBxoGY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=VRP91iVGkCrcdsWraFyx2mKUXlI8DkSYZn25fE0Dyl/NDYnIl2aQhFoq0t1+RZOb52XTptd0ZQ3ViBVQh5JJMlP9NWeHt7UsKnNc8mDLmXc336qkfn4hqPaL/Y9u0u6SyXPzsGcXHEUREc1RZZxc/s3Bv1vNEwLkvjd5UlehT60=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ok647AGZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ok647AGZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9503C1F000E9;
	Mon, 31 Aug 2026 17:58:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788199097;
	bh=ktvRKtIGqqXYvl9p3K2R3omDvtm+OTnt3rQ/2HEs4ns=;
	h=From:To:Cc:Subject:Date;
	b=ok647AGZkSn1L9ocxiGhKvMHM8RqPKQ/7tkLCgq3KyQRURArUm1sDPklRD818zM5B
	 QWrpTRA19KF5KiaD5wZi8t6ZwnL1W2CPaBvFjBzBYwfiJka/7c8gnYmFgbTLYTeRYV
	 C5Lchv03ekux9lpnSXjrTy2xC8w78ZrKvfQi+l0UKiP3h9pz4xvZZXGlWllXr/0qlF
	 gXarFxdQEVjB359iTvatwg14FU7aGuHu2RiqCq3YvCm8QLvJl+bOHIn7oG5Xo6Xj1V
	 bBFpiEyD1Mm475VB32VBoI4zJEvDofjIPIWTpJFkIYCJoPquHtdBgl+NUsTcfLMa8m
	 QNyEEqyaL0VKA==
From: Eric Biggers <ebiggers@kernel.org>
To: util-linux@vger.kernel.org
Cc: Baoquan He <baoquan.he@linux.dev>,
	linux-fscrypt@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH util-linux] swapon: document encryption support and limitations
Date: Mon, 31 Aug 2026 10:57:38 -0700
Message-ID: <20260831175738.37770-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The Linux kernel was recently updated to explicitly disallow using a
filesystem-level encrypted file directly as a swap file
(https://git.kernel.org/linus/c310a8932a3107c9), since it was broken.

It is unlikely that anyone was doing this anyway, since encrypted swap
is actually done in other ways, usually dm-crypt.  However, as requested
(https://lore.kernel.org/linux-mm/amy7Biucbf-et5O2@MiWiFi-R3L-srv/) also
update the swapon(8) man page to explicitly document this.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 sys-utils/swapon.8.adoc | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/sys-utils/swapon.8.adoc b/sys-utils/swapon.8.adoc
index 923303cd3..ea4a786de 100644
--- a/sys-utils/swapon.8.adoc
+++ b/sys-utils/swapon.8.adoc
@@ -209,6 +209,12 @@ Since version 2.41, the command *mkswap --file* can create a new swap file with
 
 Swap over *NFS* may not work.
 
+=== Encryption
+
+Swap can be encrypted by using a dm-crypt device as the swap device.
+
+A filesystem-level encrypted file can also be used as swap, but only if a loop device is set up on top of it (see *losetup*(8)) and that loop device is used as the swap device. Using a filesystem-level encrypted file directly as a swap file is unsupported.
+
 === Suspend
 
 *swapon* automatically detects and rewrites a swap space signature with old software suspend data (e.g., *S1SUSPEND*, *S2SUSPEND*, ...). The problem is that if we don't do it, then we get data corruption the next time an attempt at unsuspending is made.

base-commit: c3275e32946289641faf567af6748539acb3e802
-- 
2.55.0

