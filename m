Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3AF6C1EA84;
	Sun, 19 Jul 2026 03:33:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784432007; cv=none; b=Hhpj7pyIJMHLWIn9DEaASIb5h5clH2hR6MDdZ2kmEnUAY+6AdF+qfNbEEps+qvN4ZyCG1YZslPIa7LYtQL0yUIyvrFilSeoJMzB03j90sqQHD1x5gtpcPnDhEz1DguuwnqJDhxIAJaL34WMJtUIM2+O9oH4MMbnlKtjMJnZysZY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784432007; c=relaxed/simple;
	bh=auueHM22gwk3ZoyB7F0PqaSJr6Ppc2lH1hGfisJSHt4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=BsMmHAypbucYmsMqZ5+W6bUoso526bTTearQ4LzO/eoz7sS8fp2sEdbA59GXCuT5MkzXAvQTtHSbFbow9qGfOgr0D2fjf3bTEwfOKOy1DGaD21+KcW3ayCGHnVRg2W6faEpJMRnjRRc9VSYpCAqNbgKK7x2m6ra3B6tqajbT5Mg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Prx8SDZ2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Prx8SDZ2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A62D41F000E9;
	Sun, 19 Jul 2026 03:33:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784432005;
	bh=sqXj9cTOh3TCwpf7vuFFoZoI/vAAVMm1ty+3JLUXvsw=;
	h=From:To:Cc:Subject:Date;
	b=Prx8SDZ25PdMrI2sbmjqKS/BsY3dljVK30ol7Jr+0+82Zh46J3YKQ7CJMalqtu1gr
	 tmC4m2Gzeke+dagJROuuZ4Z3Gn1x+SBuYDbzYKJlyCgkU/hkz5FAWj71yjTs5KgoBW
	 NOMX9hNCDOH7K3QPTyrQ7riBSuTPdsSVbe+eQMJfCgoGPkV0SlKRCwtbn05GIk79YG
	 PfEmkKbNZ6MTFN0zk3ng92U7CTRGDkZ8Wgy81KBvdKh7kJ9nHTEbhb26/ahKxg6Ryl
	 kO+OoAtB7lD0WZ+e9oQayjgMSLPGZvAycb4eTVlffFecIyai9Hf9QtLN86Z6or1VUk
	 BnFzNovXMgNRA==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH] fscrypt: Add missing superblock check in find_or_insert_direct_key()
Date: Sat, 18 Jul 2026 20:31:20 -0700
Message-ID: <20260719033120.122120-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The legacy 'fscrypt_direct_keys' table caches master keys that are used
by v1 encryption policies that have FSCRYPT_POLICY_FLAG_DIRECT_KEY.
It's just a global table for all filesystems (since the keys can be
provided by the legacy process-subscribed keyrings mechanism, which
makes it difficult to reuse super_block::s_master_keys).

The entries in it ('struct fscrypt_direct_key') do contain a super_block
pointer, though, for passing to fscrypt_destroy_inline_crypt_key() when
the last inode that references the key is evicted.

However, when finding the fscrypt_direct_key for an inode, we weren't
actually comparing the super_block pointer.  As a result, inodes with
different super_blocks could point to the same fscrypt_direct_key.  That
could extend the lifetime of a fscrypt_direct_key beyond the
super_block it points to, causing a use-after-free later.

Fix this by creating distinct fscrypt_direct_key structs for distinct
super_block structs.

Note that this problem doesn't exist in the v2 policy equivalent
("per-mode keys"), since the data structures there are per super_block.

Fixes: 22e9947a4b2b ("fscrypt: stop holding extra request_queue references")
Cc: stable@vger.kernel.org
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/keysetup_v1.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/keysetup_v1.c b/fs/crypto/keysetup_v1.c
index e6e527c73f167..7e3a58dc4b566 100644
--- a/fs/crypto/keysetup_v1.c
+++ b/fs/crypto/keysetup_v1.c
@@ -147,13 +147,19 @@ find_or_insert_direct_key(struct fscrypt_direct_key *to_insert,
 		if (memcmp(ci->ci_policy.v1.master_key_descriptor,
 			   dk->dk_descriptor, FSCRYPT_KEY_DESCRIPTOR_SIZE) != 0)
 			continue;
+		/* The sb is used at eviction time, so it must be the same. */
+		if (ci->ci_inode->i_sb != dk->dk_sb)
+			continue;
 		if (ci->ci_mode != dk->dk_mode)
 			continue;
 		if (!fscrypt_is_key_prepared(&dk->dk_key, ci))
 			continue;
 		if (crypto_memneq(raw_key, dk->dk_raw, ci->ci_mode->keysize))
 			continue;
-		/* using existing tfm with same (descriptor, mode, raw_key) */
+		/*
+		 * Use an existing prepared key with the same (descriptor, sb,
+		 * mode, inlinecrypt, raw_key) combination.
+		 */
 		refcount_inc(&dk->dk_refcount);
 		spin_unlock(&fscrypt_direct_keys_lock);
 		free_direct_key(to_insert);

base-commit: f2ec6312bf711369561bdcb22f8a63c0b118c479
-- 
2.55.0

