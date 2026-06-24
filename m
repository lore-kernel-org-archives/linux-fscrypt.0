Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D7593815D1;
	Wed, 24 Jun 2026 05:06:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782277562; cv=none; b=uaTQd+uImz5zSiMdBklY7SKFzyGKirKJ3Q5pCUu1ftrk//XzGP9oxkzFyltJoa7auZpGLW1YT2C3mDcPXS5yKq7MWRnqbEiUf0qhc9KNHysLirqqThajFBmNlrHlCEN1kOfEeS8QF2wKMCInGK8SRFnQyIhncVlxEMISwHiniII=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782277562; c=relaxed/simple;
	bh=dq0BmZxoH3aAGmxOmJvE3Cbjed7VxmAJmzpgdIvqX6I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KfaIJUGmoGzURvZI9jL7VtNHiwYssIQ87tRqqh4w/xoAzcgmkp2K1XHJoK/raWEai3516w+vpTJb2AbX22MPVH0k7YFlCMMVc8uns+o6EXpmcSUbgZIVtkGO+es2tn8yqk5dt7c/jCEdILf0hamrBKzSvfygNo1ISL1as6lvnXQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=evGwe6TF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="evGwe6TF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 887611F00A3A;
	Wed, 24 Jun 2026 05:06:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782277561;
	bh=Cwl6hQgfKO6Csoe5um0D99OROoj10S3TCZbNn7JJ3zg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=evGwe6TFWqGqJ03mmURc8BrgUZCcZ2HiV0K6oXCkjXKjbpr+wjv2IkFUGvQmPNUkO
	 c0v6eKn/6jG6vyWqws+wbPGexJOn8zH5Rcd3o92rqSbJm+pDEPm6XLXfM7bO0QJFOZ
	 UMM9TtxbHQ7pX/Z8JpajFHFe76VAa3l+t/l/Q6tkZ426iCJEq45DJrWt8mgoP1VxET
	 o2ofo1wNdjbFOs0j6/iSfM6UYvzkik1Gq7YaJ29QWl6h7EcoWq9wncmJGhb8IUPNoB
	 EsOEA6ELb6WhIYOq0EHkPiZTvqnOaIFYqU2RvaqCcJU06rYHYKf10fO4nSBH5Sc4ue
	 7VBQ65fjJiP7Q==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-block@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Theodore Ts'o <tytso@mit.edu>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Baokun Li <libaokun@linux.alibaba.com>,
	Jan Kara <jack@suse.cz>,
	Ojaswin Mujoo <ojaswin@linux.ibm.com>,
	Ritesh Harjani <ritesh.list@gmail.com>,
	Zhang Yi <yi.zhang@huawei.com>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Chao Yu <chao@kernel.org>,
	Eric Biggers <ebiggers@kernel.org>
Subject: [PATCH 04/16] fscrypt: Fully disallow IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE
Date: Tue, 23 Jun 2026 22:03:22 -0700
Message-ID: <20260624050334.124606-5-ebiggers@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260624050334.124606-1-ebiggers@kernel.org>
References: <20260624050334.124606-1-ebiggers@kernel.org>
Precedence: bulk
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

FSCRYPT_POLICY_FLAG_IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE works
only with the fs-layer implementation of file contents encryption, not
blk-crypto.  This is a problem for standardizing on blk-crypto.

Fortunately, no one should be using this combination anyway.  It doesn't
make sense because the entire point of IV_INO_LBLK_32 is to support
inline encryption hardware that is limited to 32-bit DUNs.

Thus, fully disallow IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE.

Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---
 Documentation/filesystems/fscrypt.rst |  3 +++
 fs/crypto/inline_crypt.c              | 13 -------------
 fs/crypto/policy.c                    | 17 +++++++++++++++++
 3 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/Documentation/filesystems/fscrypt.rst b/Documentation/filesystems/fscrypt.rst
index c0dd35f1af12..92b8f311e211 100644
--- a/Documentation/filesystems/fscrypt.rst
+++ b/Documentation/filesystems/fscrypt.rst
@@ -334,10 +334,13 @@ This format is optimized for use with inline encryption hardware
 compliant with the eMMC v5.2 standard, which supports only 32 IV bits
 per I/O request and may have only a small number of keyslots.  This
 format results in some level of IV reuse, so it should only be used
 when necessary due to hardware limitations.
 
+IV_INO_LBLK_32 is supported only when the filesystem block size is
+equal to the page size.
+
 Key identifiers
 ---------------
 
 For master keys used for v2 encryption policies, a unique 16-byte "key
 identifier" is also derived using the KDF.  This value is stored in
diff --git a/fs/crypto/inline_crypt.c b/fs/crypto/inline_crypt.c
index 0d4c0dd04d20..4f045ad1dca8 100644
--- a/fs/crypto/inline_crypt.c
+++ b/fs/crypto/inline_crypt.c
@@ -110,23 +110,10 @@ int fscrypt_select_encryption_impl(struct fscrypt_inode_info *ci,
 
 	/* The filesystem must be mounted with -o inlinecrypt */
 	if (!(sb->s_flags & SB_INLINECRYPT))
 		return 0;
 
-	/*
-	 * When a page contains multiple logically contiguous filesystem blocks,
-	 * some filesystem code only calls fscrypt_mergeable_bio() for the first
-	 * block in the page. This is fine for most of fscrypt's IV generation
-	 * strategies, where contiguous blocks imply contiguous IVs. But it
-	 * doesn't work with IV_INO_LBLK_32. For now, simply exclude
-	 * IV_INO_LBLK_32 with blocksize != PAGE_SIZE from inline encryption.
-	 */
-	if ((fscrypt_policy_flags(&ci->ci_policy) &
-	     FSCRYPT_POLICY_FLAG_IV_INO_LBLK_32) &&
-	    sb->s_blocksize != PAGE_SIZE)
-		return 0;
-
 	/*
 	 * On all the filesystem's block devices, blk-crypto must support the
 	 * crypto configuration that the file would use.
 	 */
 	crypto_cfg.crypto_mode = ci->ci_mode->blk_crypto_mode;
diff --git a/fs/crypto/policy.c b/fs/crypto/policy.c
index f40fb5924e75..a7322dba7557 100644
--- a/fs/crypto/policy.c
+++ b/fs/crypto/policy.c
@@ -175,10 +175,27 @@ static bool supported_iv_ino_lblk_policy(const struct fscrypt_policy_v2 *policy,
 		fscrypt_warn(inode,
 			     "Can't use %s policy on filesystem '%s' because its maximum file size is too large",
 			     type, sb->s_id);
 		return false;
 	}
+
+	/*
+	 * IV_INO_LBLK_32 isn't compatible with inline encryption when
+	 * s_blocksize != PAGE_SIZE.  In that case the DUN can wrap around in
+	 * the middle of a page, but sometimes fscrypt_mergeable_bio() is called
+	 * only for the first block per page.  Since IV_INO_LBLK_32 exists only
+	 * to support inline encryption hardware that is limited to 32-bit DUNs,
+	 * just disallow IV_INO_LBLK_32 with s_blocksize != PAGE_SIZE entirely.
+	 */
+	if ((policy->flags & FSCRYPT_POLICY_FLAG_IV_INO_LBLK_32) &&
+	    sb->s_blocksize != PAGE_SIZE) {
+		fscrypt_warn(inode,
+			     "Can't use %s policy on filesystem '%s' with block size != PAGE_SIZE",
+			     type, sb->s_id);
+		return false;
+	}
+
 	return true;
 }
 
 static bool fscrypt_supported_v1_policy(const struct fscrypt_policy_v1 *policy,
 					const struct inode *inode)
-- 
2.54.0

