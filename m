Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from lilium.sigma-star.at ([109.75.188.150]:53174 "EHLO
        lilium.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727012AbfCNRXO (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 14 Mar 2019 13:23:14 -0400
From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 3/4] ubifs: Simplify fscrypt_get_encryption_info() error handling
Date: Thu, 14 Mar 2019 18:15:58 +0100
Message-Id: <20190314171559.27584-4-richard@nod.at>
In-Reply-To: <20190314171559.27584-1-richard@nod.at>
References: <CAJfpegvX4ANfso-Jn1zaB+m4Q_0eK9i-+MCJ+sTH5QzD3PZFMQ@mail.gmail.com>
 <20190314171559.27584-1-richard@nod.at>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-mtd@lists.infradead.org
Cc: linux-fscrypt@vger.kernel.org, jaegeuk@kernel.org, tytso@mit.edu, linux-unionfs@vger.kernel.org, miklos@szeredi.hu, amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, paullawrence@google.com, Richard Weinberger <richard@nod.at>
List-ID: <linux-fscrypt@vger.kernel.org>

fscrypt_get_encryption_info() does not return -ENOKEY,
there is no need to handle this case.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 fs/ubifs/dir.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 5767b373a8ff..b0cb913697c5 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -526,7 +526,7 @@ static int ubifs_readdir(struct file *file, struct di=
r_context *ctx)
=20
 	if (encrypted) {
 		err =3D fscrypt_get_encryption_info(dir);
-		if (err && err !=3D -ENOKEY)
+		if (err)
 			return err;
=20
 		err =3D fscrypt_fname_alloc_buffer(dir, UBIFS_MAX_NLEN, &fstr);
@@ -794,7 +794,7 @@ static int ubifs_unlink(struct inode *dir, struct den=
try *dentry)
=20
 	if (ubifs_crypt_is_encrypted(dir)) {
 		err =3D fscrypt_get_encryption_info(dir);
-		if (err && err !=3D -ENOKEY)
+		if (err)
 			return err;
 	}
=20
@@ -904,7 +904,7 @@ static int ubifs_rmdir(struct inode *dir, struct dent=
ry *dentry)
=20
 	if (ubifs_crypt_is_encrypted(dir)) {
 		err =3D fscrypt_get_encryption_info(dir);
-		if (err && err !=3D -ENOKEY)
+		if (err)
 			return err;
 	}
=20
--=20
2.21.0
