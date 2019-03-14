Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from lilium.sigma-star.at ([109.75.188.150]:53170 "EHLO
        lilium.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726867AbfCNRXO (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 14 Mar 2019 13:23:14 -0400
From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/4] fscrypt: Export fscrypt_d_ops
Date: Thu, 14 Mar 2019 18:15:57 +0100
Message-Id: <20190314171559.27584-3-richard@nod.at>
In-Reply-To: <20190314171559.27584-1-richard@nod.at>
References: <CAJfpegvX4ANfso-Jn1zaB+m4Q_0eK9i-+MCJ+sTH5QzD3PZFMQ@mail.gmail.com>
 <20190314171559.27584-1-richard@nod.at>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-mtd@lists.infradead.org
Cc: linux-fscrypt@vger.kernel.org, jaegeuk@kernel.org, tytso@mit.edu, linux-unionfs@vger.kernel.org, miklos@szeredi.hu, amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, paullawrence@google.com, Richard Weinberger <richard@nod.at>
List-ID: <linux-fscrypt@vger.kernel.org>

If a filesystem manages dentry operations itself it might want to
re-use fscrypt_d_ops.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 fs/crypto/crypto.c          | 1 +
 fs/crypto/fscrypt_private.h | 1 -
 include/linux/fscrypt.h     | 1 +
 3 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/crypto/crypto.c b/fs/crypto/crypto.c
index 4dc788e3bc96..8018f8bba50d 100644
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -357,6 +357,7 @@ static int fscrypt_d_revalidate(struct dentry *dentry=
, unsigned int flags)
 const struct dentry_operations fscrypt_d_ops =3D {
 	.d_revalidate =3D fscrypt_d_revalidate,
 };
+EXPORT_SYMBOL(fscrypt_d_ops);
=20
 void fscrypt_restore_control_page(struct page *page)
 {
diff --git a/fs/crypto/fscrypt_private.h b/fs/crypto/fscrypt_private.h
index 7da276159593..bced1ee4fd64 100644
--- a/fs/crypto/fscrypt_private.h
+++ b/fs/crypto/fscrypt_private.h
@@ -125,7 +125,6 @@ extern int fscrypt_do_page_crypto(const struct inode =
*inode,
 				  gfp_t gfp_flags);
 extern struct page *fscrypt_alloc_bounce_page(struct fscrypt_ctx *ctx,
 					      gfp_t gfp_flags);
-extern const struct dentry_operations fscrypt_d_ops;
=20
 extern void __printf(3, 4) __cold
 fscrypt_msg(struct super_block *sb, const char *level, const char *fmt, =
...);
diff --git a/include/linux/fscrypt.h b/include/linux/fscrypt.h
index 7139a110ac4f..2b9577e4707f 100644
--- a/include/linux/fscrypt.h
+++ b/include/linux/fscrypt.h
@@ -231,6 +231,7 @@ extern int __fscrypt_encrypt_symlink(struct inode *in=
ode, const char *target,
 extern const char *fscrypt_get_symlink(struct inode *inode, const void *=
caddr,
 				       unsigned int max_size,
 				       struct delayed_call *done);
+extern const struct dentry_operations fscrypt_d_ops;
 #else  /* !CONFIG_FS_ENCRYPTION */
=20
 static inline bool fscrypt_has_encryption_key(const struct inode *inode)
--=20
2.21.0
