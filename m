Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794345641;
	b=aEuyLT+uxhlFOM9HJk0gV/NJ3ARNyGno5Ls3CDseqql8QcRQNxrsWX769UMKY+8bc6ET
	 ZPn8yVM4WLIw81FEqVFstDA67a72kNQ89w2w/NFQpjwGRDLofeucf533hEN4918c6CetL
	 9L/t0Oy48fSkENZmWS8/jGuVCen/o3kIktmwAejs9Gx7IE/0jYJwAfWXexi/zWKc9h8SP
	 J9TIKY20LMEFITGb4+ab7AGH4KZHOJufydeLy7CxtmAg9UV5UNhBQTNzEQqeX6b2lYrGK
	 GtzY6VH04rsr3Vvkeyvj1rIMuC44okRQ/aVRFjt8Ivs1TDTwzSwe4AVB73PpE8ZumxQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794345641;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=zUm2BSz9/z2c5sVywXbrw7njT+YA9vwtmg4EG8md0I8=;
	b=ij96C1KtRQeXb7Q47nI1FbrUizTRRtBPXuiq5z7xFsDTTtyJMhSSUUo4llYOQeDocnb8
	 iskTnCIWyIJlXuuM1BiQZM1090tF0caU06aWBcOV5pyZFf3ylJ0EDsqUCAPjMA2okGv1O
	 FxcXBDL+x/frn5cnRB1LpS6tydMarMpPBVEN5tGb8jI3xj5zcesTrPpkySy4RfOpJLSk0
	 7TNwYhoQauZodZW5E7Dk3iSVUTq8LMH9hJlL0MVoWwKscNFYcwoBN5aU3npdpD9fWFHlV
	 RXCq+5GQ5CXJ9iNd49pxtcRcPpLzTN7wF/U+z1thHAxXCTn+ZJ8UL0R1xAZDU3u8bCg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PwdyZiN5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1370C606A320;
	Tue, 10 Nov 2026 21:20:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PwdyZiN5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A12DA1F0089F;
	Tue, 10 Nov 2026 21:20:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794345640;
	bh=zUm2BSz9/z2c5sVywXbrw7njT+YA9vwtmg4EG8md0I8=;
	h=From:To:Cc:Subject:Date;
	b=PwdyZiN59bEIMnx0a/O6kMGUgpCtADsngBdCbawzyhn8NYMQj/yCwkcPGKIR+NLsh
	 BSQhuVlq1aQ0Z/0J3UkLEZa+xy6U//HmbXNLo+osEXUDtJWlyv7IGMySMKL6SW7DKn
	 F48hZWLefYEfcQDxuju5Dl5MfY/o5jGMDzpELO7mWJJFX+gVVgf0EmXpgUHfQB5YF/
	 CA70iuli9k67d7ESEAW8AmUJEjLoffkvd4JBNZdqYCIXYynDFV+kRESBv0XcElDxQV
	 J4KzpY8HHEf/Wvy4aJxl364dJcPeFBwqQiR3kVFzBdGz3J/pmsR6J/hGai+45Tdx0l
	 S5xpjwHZuKeAQ==
From: Eric Biggers <ebiggers@kernel.org>
To: linux-fscrypt@vger.kernel.org
Cc: Theodore Ts'o <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	linux-fsdevel@vger.kernel.org,
	Eric Biggers <ebiggers@kernel.org>,
	stable@vger.kernel.org,
	Ada Smith <adasmithgt@gmail.com>
Subject: [PATCH] fscrypt: Initialize ->ci_master_key before publication
Date: Tue, 10 Nov 2026 13:20:11 -0800
Message-ID: <20261110212011.35487-1-ebiggers@kernel.org>
X-Mailer: git-send-email 2.56.0
X-Mailing-List: linux-fscrypt@vger.kernel.org
List-Id: <linux-fscrypt.vger.kernel.org>
List-Post: <mailto:linux-fscrypt@vger.kernel.org>
List-Help: <mailto:linux-fscrypt+help@vger.kernel.org>
List-Subscribe: <mailto:linux-fscrypt+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-fscrypt+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-fscrypt+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

fscrypt_prepare_setflags() assumes that if the key for an inode with a
v2 encryption policy has been set up, then ->ci_master_key is non-NULL.
This is a reasonable assumption, but it does not take into account the
very short gap in fscrypt_setup_encryption_info() between the inode's
fscrypt_inode_info being set and ->ci_master_key being initialized.
Thus, a NULL pointer dereference was possible.

Fix this by closing the gap: make fscrypt_setup_encryption_info()
initialize ->ci_master_key before publication.  If it loses the cmpxchg
race afterwards, set it back to NULL so that put_crypt_info() continues
to have the same behavior.

Fixes: b1c0ec3599f4 ("fscrypt: add FS_IOC_REMOVE_ENCRYPTION_KEY ioctl")
Cc: stable@vger.kernel.org
Reported-by: Ada Smith <adasmithgt@gmail.com>
Signed-off-by: Eric Biggers <ebiggers@kernel.org>
---

This patch applies to v7.4-rc2, and I'm planning to take it via the
fscrypt tree.

 fs/crypto/keysetup.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/keysetup.c b/fs/crypto/keysetup.c
index a77b889d7578c..0beec01c04185 100644
--- a/fs/crypto/keysetup.c
+++ b/fs/crypto/keysetup.c
@@ -621,6 +621,13 @@ fscrypt_setup_encryption_info(struct inode *inode,
 	if (res)
 		goto out;
 
+	/*
+	 * Preemptively initialize ->ci_master_key, even though we don't know
+	 * whether we'll win the race below yet, because if we do win the race
+	 * then other tasks can see it right away and need ->ci_master_key.
+	 */
+	crypt_info->ci_master_key = mk;
+
 	/*
 	 * For existing inodes, multiple tasks may race to set the inode's
 	 * fscrypt info pointer.  So use cmpxchg_release().  This pairs with the
@@ -634,7 +641,6 @@ fscrypt_setup_encryption_info(struct inode *inode,
 		 * crypt_info.  Now link it into the master key's inode list.
 		 */
 		if (mk) {
-			crypt_info->ci_master_key = mk;
 			refcount_inc(&mk->mk_active_refs);
 			spin_lock(&mk->mk_decrypted_inodes_lock);
 			list_add(&crypt_info->ci_master_key_link,
@@ -642,6 +648,12 @@ fscrypt_setup_encryption_info(struct inode *inode,
 			spin_unlock(&mk->mk_decrypted_inodes_lock);
 		}
 		crypt_info = NULL;
+	} else {
+		/*
+		 * Lost the race, so we won't be taking an active reference to
+		 * the master key.  Clear ->ci_master_key accordingly.
+		 */
+		crypt_info->ci_master_key = NULL;
 	}
 	res = 0;
 out:

base-commit: 7475ea8b58616b33c04afb976cf0fbaad9dd63fb
-- 
2.56.0

