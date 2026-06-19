Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D829840D561;
	Fri, 19 Jun 2026 00:02:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781827353; cv=none; b=LMdohgsOCw0jxtKl9XzNvmWGygbwp2GwbJ5U9WcMJSUcpagKoeAi5NCSlRcoGXtDHjI5x1UsRIweEUgYDlUg4qeJcGS4gocQ9TBpTw+p4sIb4+Pi7+2Dpdx/UbahKOwGy9WVeyFtmC31WwvICx/eINJVsUV216ruhNApUC+JlbE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781827353; c=relaxed/simple;
	bh=ZaV09OS0oLPlQ6Z3KZkwSqWAhKFKTqHfzxzIDlLb6WA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=mwCB4F4gnvZcxG+uF2389dxWgtKkjYxaGQeMAyL0KIzI4g2Pl2gow1a3CgTG3HF7jX9BYREJvVstq8KZXloUgyv3AL5SC6JgZne4rM/PvCyqn0rn9D7R/X/zptT79wJu5dROz7QlJ0kPCnuNWrtHMR4QBOnww3G0WT8f+LOHSiU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ABwaWO5S; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ABwaWO5S"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4FEDC1F000E9;
	Fri, 19 Jun 2026 00:02:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781827352;
	bh=rw8bi/NrO7vchro+RbX6Anbwfo3TNwlnz5xgEcwLeXo=;
	h=From:To:Cc:Subject:Date;
	b=ABwaWO5StIrxEFhEf0AuhO4kcxRXj1mVGM9zzHdBirx8JbGAV80pkhtWV4NFejcQ4
	 zk6XrRAljbqHSzAO+fQBP7FJPsAjzTrdwIzYN+vYk3Dfe55rp7xWQEaMFXgj0D5z87
	 o3yj190nUwDGA+QSYjHFhfJCgzc84iVLgps+3ip5D2Z+EGW/l1FoA/iq4ajZkOWc0i
	 ZwSPR+4ZWb2m0CkiOGs22EOCJLZ5oMN+GneoM3cw9CgfX8kaQvwBduYr6fcwfCPFui
	 cZvmv8NiY+VQTOdCqpVJvhcnG1x2qodsFK8tRJX8q8rVAULNGouQ1rTrF6kuTNh0oO
	 V69m+oXWDWETw==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: Simplify handling of errors during initcall
Date: Thu, 18 Jun 2026 17:00:30 -0700
Message-ID: <20260619000030.166851-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Since CONFIG_FS_ENCRYPTION is a bool, not a tristate, fs/crypto/ can
only be builtin or absent entirely; it can't be a loadable module.
Therefore, the error code that gets returned from the fscrypt_init()
initcall is never used.  If any part of the initcall does fail, which
should never happen, the kernel will be left in a bad state.

Following the usual convention for builtin code, just panic the kernel
if any of part of the initcall fails.  This simplifies the code.

This closely mirrors commit e77000ccc531 ("fsverity: simplify handling
of errors during initcall").

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/crypto.c          | 27 ++++-----------------------
 fs/crypto/fscrypt_private.h |  2 +-
 fs/crypto/keyring.c         | 18 ++++++++----------
 3 files changed, 13 insertions(+), 34 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 10097a3251f5..94dd6c89ddcd 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -367,19 +367,12 @@ void fscrypt_msg(const struct inode *inode, const char *level,
 	else
 		printk("%sfscrypt: %pV\n", level, &vaf);
 	va_end(args);
 }
 
-/**
- * fscrypt_init() - Set up for fs encryption.
- *
- * Return: 0 on success; -errno on failure
- */
 static int __init fscrypt_init(void)
 {
-	int err = -ENOMEM;
-
 	/*
 	 * Use an unbound workqueue to allow bios to be decrypted in parallel
 	 * even when they happen to complete on the same CPU.  This sacrifices
 	 * locality, but it's worthwhile since decryption is CPU-intensive.
 	 *
@@ -388,26 +381,14 @@ static int __init fscrypt_init(void)
 	 */
 	fscrypt_read_workqueue = alloc_workqueue("fscrypt_read_queue",
 						 WQ_UNBOUND | WQ_HIGHPRI,
 						 num_online_cpus());
 	if (!fscrypt_read_workqueue)
-		goto fail;
+		panic("failed to allocate fscrypt_read_queue");
 
 	fscrypt_inode_info_cachep = KMEM_CACHE(fscrypt_inode_info,
-					       SLAB_RECLAIM_ACCOUNT);
-	if (!fscrypt_inode_info_cachep)
-		goto fail_free_queue;
-
-	err = fscrypt_init_keyring();
-	if (err)
-		goto fail_free_inode_info;
-
+					       SLAB_RECLAIM_ACCOUNT |
+					       SLAB_PANIC);
+	fscrypt_init_keyring();
 	return 0;
-
-fail_free_inode_info:
-	kmem_cache_destroy(fscrypt_inode_info_cachep);
-fail_free_queue:
-	destroy_workqueue(fscrypt_read_workqueue);
-fail:
-	return err;
 }
 late_initcall(fscrypt_init)
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 45307f7fa540..8234ee542476 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -713,11 +713,11 @@ int fscrypt_add_test_dummy_key(struct super_block *sb,
 			       struct fscrypt_key_specifier *key_spec);
 
 int fscrypt_verify_key_added(struct super_block *sb,
 			     const u8 identifier[FSCRYPT_KEY_IDENTIFIER_SIZE]);
 
-int __init fscrypt_init_keyring(void);
+void __init fscrypt_init_keyring(void);
 
 /* keysetup.c */
 
 struct fscrypt_mode {
 	const char *friendly_name;
diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index 16bc348213ca..76e28d1e0064 100644
--- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -1218,23 +1218,21 @@ int fscrypt_ioctl_get_key_status(struct file *filp, void __user *uarg)
 		err = -EFAULT;
 	return err;
 }
 EXPORT_SYMBOL_GPL(fscrypt_ioctl_get_key_status);
 
-int __init fscrypt_init_keyring(void)
+void __init fscrypt_init_keyring(void)
 {
 	int err;
 
+	/*
+	 * Note that register_key_type() fails only if a key type with the same
+	 * name already exists, which should never happen here.
+	 */
 	err = register_key_type(&key_type_fscrypt_user);
 	if (err)
-		return err;
-
+		panic("failed to register .fscrypt key type (%d)", err);
 	err = register_key_type(&key_type_fscrypt_provisioning);
 	if (err)
-		goto err_unregister_fscrypt_user;
-
-	return 0;
-
-err_unregister_fscrypt_user:
-	unregister_key_type(&key_type_fscrypt_user);
-	return err;
+		panic("failed to register fscrypt-provisioning key type (%d)",
+		      err);
 }

base-commit: 83f1454877cc292b88baf13c829c16ce6937d120
prerequisite-patch-id: 319d2891e88c7df1ebb5ebf434d18b68f770399f
prerequisite-patch-id: f6157c86deab0ff5ec953ae3ed6b0e84f37741bf
prerequisite-patch-id: 5330c9e4b65644baae81bd177a46be6223d2b494
prerequisite-patch-id: 073cb85332cc58e4b5066bf8f7ac948c0d9a2bac
-- 
2.54.0

