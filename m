Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 137A71922FD
	for <linux-fscrypt@vger.kernel.org>; Fri, 25 Sep 2026 04:09:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790309346; cv=none; b=YR1FwpJ/nNkuP50FNw994vYsX0OiRJ6tY+f1oSgr5n7Z1Ls41TGWyjOjhnHM7pvAwXufFiJ1SHUi5XMCSkjKXwLhkPM/XuZYcUPXI8yb1oPUNyFLlKjNN8W0LMTv2KLCbiTSDMhf120qiyogXEK2Aydc2+Br6QBnHGd4SZ7yx9s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790309346; c=relaxed/simple;
	bh=acni0D8Juqmp6kxR4sBbVxs/lV/4ggSAUd9caHh0L9M=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ucAU/kd9pkWklyri9j3GiRbJKaD+PwUwrlj0GYjOZlOb6rfE45Vc8HNUAph3EI8HecOQ2KNNUlqBvWseJUJ56/wO8KOBjpbaCGBq5LbeqxdH5xwbclOjjZp9c6U94ebgjev8jGRUgPe6lx3SRDcOAPpS4i1RrUq8Y4Gb3+aEP4I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Aq/k1sqo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Aq/k1sqo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 85DEE1F000FF;
	Fri, 25 Sep 2026 04:09:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790309344;
	bh=L64ou5Irz51ME6GMRItGeLq1nMD1U8FOOm3XMJapreA=;
	h=From:To:Cc:Subject:Date;
	b=Aq/k1sqoDEz7Al0c+Uj/MYaonGXG3M3FBGIVi9ns5cHgXLr3WEc3a+DalVAGJRRP9
	 Ax1CK0YQJGsHhXd7wbtntzEDTiW9bU+vbgqRfjbrJFG+Y9Wg4MoUhtQAsl6HoVmgjh
	 sOAE450qBRty9PqkwOe1pw415K7eoB9k7NGv2dYCf+2iRtkt/9CLnWB7h+T6XmeVbt
	 7fLctr+ugoBez24JEV2uICl+cLLzJICVubyVtc+8i3RamTgqe8oUb0EfCCfNLhJGBF
	 hep/KjwXdBYXsaw/WjnUivDrYP+CS+EEWKI1rKI6e1DML6B/++e+LKPFfN242jXuUN
	 xCGBZyotycTRg==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH] fscrypt: Move several items from fscrypt_private.h to .c files
Date: Thu, 24 Sep 2026 21:08:53 -0700
Message-ID: <20260925040853.110410-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

enum fscrypt_direction_t, struct fscrypt_symlink_data, and struct
fscrypt_master_key_user are each used in only one file.  Move them to
their respective files.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 fs/crypto/crypto.c          |  5 +++++
 fs/crypto/fscrypt_private.h | 27 ---------------------------
 fs/crypto/hooks.c           |  9 +++++++++
 fs/crypto/keyring.c         | 13 +++++++++++++
 4 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 5286a124b0d9..8f212e7f39f6 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -98,6 +98,11 @@ void fscrypt_generate_iv(union fscrypt_iv *iv, u64 index,
 	iv->index = cpu_to_le64(index);
 }
 
+typedef enum {
+	FS_DECRYPT = 0,
+	FS_ENCRYPT,
+} fscrypt_direction_t;
+
 /* Encrypt or decrypt a single "data unit" of file contents. */
 static int fscrypt_crypt_data_unit(const struct fscrypt_inode_info *ci,
 				   fscrypt_direction_t rw, u64 index,
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 74329e0953d1..e602c31b3844 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -219,15 +219,6 @@ fscrypt_policy_du_bits(const union fscrypt_policy *policy,
 	BUG();
 }
 
-/*
- * For encrypted symlinks, the ciphertext length is stored at the beginning
- * of the string in little-endian format.
- */
-struct fscrypt_symlink_data {
-	__le16 len;
-	char encrypted_path[];
-} __packed;
-
 /**
  * struct fscrypt_prepared_key - a key prepared for actual encryption/decryption
  * @tfm: crypto API transform object
@@ -321,11 +312,6 @@ struct fscrypt_inode_info {
 	u8 ci_nonce[FSCRYPT_FILE_NONCE_SIZE];
 };
 
-typedef enum {
-	FS_DECRYPT = 0,
-	FS_ENCRYPT,
-} fscrypt_direction_t;
-
 /* crypto.c */
 extern struct kmem_cache *fscrypt_inode_info_cachep;
 int fscrypt_initialize(struct super_block *sb);
@@ -473,19 +459,6 @@ fscrypt_is_key_prepared(const struct fscrypt_prepared_key *prep_key,
 
 /* keyring.c */
 
-/*
- * fscrypt_master_key_user - a user's claim to a master key
- */
-struct fscrypt_master_key_user {
-	struct list_head link;
-	kuid_t uid;
-	/*
-	 * This 'struct key' contains no secret.  It exists solely to charge the
-	 * appropriate user's key quota.
-	 */
-	struct key *quota_key;
-};
-
 /*
  * fscrypt_master_key_secret - secret key material of an in-use master key
  */
diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
index a7a8a3f581a0..149498bdab94 100644
--- a/fs/crypto/hooks.c
+++ b/fs/crypto/hooks.c
@@ -9,6 +9,15 @@
 
 #include "fscrypt_private.h"
 
+/*
+ * For encrypted symlinks, the ciphertext length is stored at the beginning
+ * of the string in little-endian format.
+ */
+struct fscrypt_symlink_data {
+	__le16 len;
+	char encrypted_path[];
+} __packed;
+
 /**
  * fscrypt_file_open() - prepare to open a possibly-encrypted regular file
  * @inode: the inode being opened
diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index 76e28d1e0064..874cc183ee62 100644
--- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -145,6 +145,19 @@ static inline bool valid_key_spec(const struct fscrypt_key_specifier *spec)
 	return master_key_spec_len(spec) != 0;
 }
 
+/*
+ * fscrypt_master_key_user - a user's claim to a master key
+ */
+struct fscrypt_master_key_user {
+	struct list_head link;
+	kuid_t uid;
+	/*
+	 * This 'struct key' contains no secret.  It exists solely to charge the
+	 * appropriate user's key quota.
+	 */
+	struct key *quota_key;
+};
+
 static int fscrypt_user_key_instantiate(struct key *key,
 					struct key_preparsed_payload *prep)
 {

base-commit: 165768bb70265b5c38cf0b73fafd75be235f8b14
-- 
2.55.0

