Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from lilium.sigma-star.at ([109.75.188.150]:53350 "EHLO
        lilium.sigma-star.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726424AbfCNR2P (ORCPT
        <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 14 Mar 2019 13:28:15 -0400
From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 4/4] ubifs: Implement new mount option, fscrypt_key_required
Date: Thu, 14 Mar 2019 18:15:59 +0100
Message-Id: <20190314171559.27584-5-richard@nod.at>
In-Reply-To: <20190314171559.27584-1-richard@nod.at>
References: <CAJfpegvX4ANfso-Jn1zaB+m4Q_0eK9i-+MCJ+sTH5QzD3PZFMQ@mail.gmail.com>
 <20190314171559.27584-1-richard@nod.at>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: linux-fscrypt-owner@vger.kernel.org
To: linux-mtd@lists.infradead.org
Cc: linux-fscrypt@vger.kernel.org, jaegeuk@kernel.org, tytso@mit.edu, linux-unionfs@vger.kernel.org, miklos@szeredi.hu, amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, paullawrence@google.com, Richard Weinberger <richard@nod.at>
List-ID: <linux-fscrypt@vger.kernel.org>

Usually fscrypt allows limited access to encrypted files even
if no key is available.
Encrypted filenames are shown and based on this names users
can unlink and move files.

This is not always what people expect. The fscrypt_key_required mount
option disables this feature.
If no key is present all access is denied with the -ENOKEY error code.

The side benefit of this is that we don't need ->d_revalidate().
Not having ->d_revalidate() makes an encrypted ubifs usable
as overlayfs upper directory.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 fs/ubifs/crypto.c |  2 +-
 fs/ubifs/dir.c    | 29 ++++++++++++++++++++++++++---
 fs/ubifs/super.c  | 15 +++++++++++++++
 fs/ubifs/ubifs.h  |  1 +
 4 files changed, 43 insertions(+), 4 deletions(-)

diff --git a/fs/ubifs/crypto.c b/fs/ubifs/crypto.c
index 4aaedf2d7f44..a6a48c5dc058 100644
--- a/fs/ubifs/crypto.c
+++ b/fs/ubifs/crypto.c
@@ -76,7 +76,7 @@ int ubifs_decrypt(const struct inode *inode, struct ubi=
fs_data_node *dn,
 }
=20
 const struct fscrypt_operations ubifs_crypt_operations =3D {
-	.flags			=3D FS_CFLG_OWN_PAGES,
+	.flags			=3D FS_CFLG_OWN_PAGES | FS_CFLG_OWN_D_OPS,
 	.key_prefix		=3D "ubifs:",
 	.get_context		=3D ubifs_crypt_get_context,
 	.set_context		=3D ubifs_crypt_set_context,
diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index b0cb913697c5..4d029f08b80d 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -208,6 +208,16 @@ static int dbg_check_name(const struct ubifs_info *c=
,
 	return 0;
 }
=20
+static void ubifs_set_dentry_ops(struct inode *dir, struct dentry *dentr=
y)
+{
+#ifdef CONFIG_FS_ENCRYPTION
+	struct ubifs_info *c =3D dir->i_sb->s_fs_info;
+
+	if (IS_ENCRYPTED(dir) && !c->fscrypt_key_required)
+		d_set_d_op(dentry, &fscrypt_d_ops);
+#endif
+}
+
 static struct dentry *ubifs_lookup(struct inode *dir, struct dentry *den=
try,
 				   unsigned int flags)
 {
@@ -224,7 +234,10 @@ static struct dentry *ubifs_lookup(struct inode *dir=
, struct dentry *dentry,
 	if (err)
 		return ERR_PTR(err);
=20
-	err =3D fscrypt_setup_filename(dir, &dentry->d_name, 1, &nm);
+	ubifs_set_dentry_ops(dir, dentry);
+
+	err =3D fscrypt_setup_filename(dir, &dentry->d_name,
+				     !c->fscrypt_key_required, &nm);
 	if (err)
 		return ERR_PTR(err);
=20
@@ -240,6 +253,11 @@ static struct dentry *ubifs_lookup(struct inode *dir=
, struct dentry *dentry,
 	}
=20
 	if (nm.hash) {
+		if (c->fscrypt_key_required) {
+			inode =3D ERR_PTR(-ENOKEY);
+			goto done;
+		}
+
 		ubifs_assert(c, fname_len(&nm) =3D=3D 0);
 		ubifs_assert(c, fname_name(&nm) =3D=3D NULL);
 		dent_key_init_hash(c, &key, dir->i_ino, nm.hash);
@@ -529,6 +547,9 @@ static int ubifs_readdir(struct file *file, struct di=
r_context *ctx)
 		if (err)
 			return err;
=20
+		if (c->fscrypt_key_required && !dir->i_crypt_info)
+			return -ENOKEY;
+
 		err =3D fscrypt_fname_alloc_buffer(dir, UBIFS_MAX_NLEN, &fstr);
 		if (err)
 			return err;
@@ -798,7 +819,8 @@ static int ubifs_unlink(struct inode *dir, struct den=
try *dentry)
 			return err;
 	}
=20
-	err =3D fscrypt_setup_filename(dir, &dentry->d_name, 1, &nm);
+	err =3D fscrypt_setup_filename(dir, &dentry->d_name, !c->fscrypt_key_re=
quired,
+				     &nm);
 	if (err)
 		return err;
=20
@@ -908,7 +930,8 @@ static int ubifs_rmdir(struct inode *dir, struct dent=
ry *dentry)
 			return err;
 	}
=20
-	err =3D fscrypt_setup_filename(dir, &dentry->d_name, 1, &nm);
+	err =3D fscrypt_setup_filename(dir, &dentry->d_name,
+				     !c->fscrypt_key_required, &nm);
 	if (err)
 		return err;
=20
diff --git a/fs/ubifs/super.c b/fs/ubifs/super.c
index 8dc2818fdd84..e081b00236b6 100644
--- a/fs/ubifs/super.c
+++ b/fs/ubifs/super.c
@@ -445,6 +445,9 @@ static int ubifs_show_options(struct seq_file *s, str=
uct dentry *root)
 			   ubifs_compr_name(c, c->mount_opts.compr_type));
 	}
=20
+	if (c->fscrypt_key_required)
+		seq_puts(s, ",fscrypt_key_required");
+
 	seq_printf(s, ",assert=3D%s", ubifs_assert_action_name(c));
 	seq_printf(s, ",ubi=3D%d,vol=3D%d", c->vi.ubi_num, c->vi.vol_id);
=20
@@ -952,6 +955,7 @@ enum {
 	Opt_assert,
 	Opt_auth_key,
 	Opt_auth_hash_name,
+	Opt_fscrypt_key_required,
 	Opt_ignore,
 	Opt_err,
 };
@@ -969,6 +973,7 @@ static const match_table_t tokens =3D {
 	{Opt_ignore, "ubi=3D%s"},
 	{Opt_ignore, "vol=3D%s"},
 	{Opt_assert, "assert=3D%s"},
+	{Opt_fscrypt_key_required, "fscrypt_key_required"},
 	{Opt_err, NULL},
 };
=20
@@ -1008,6 +1013,7 @@ static int ubifs_parse_options(struct ubifs_info *c=
, char *options,
 {
 	char *p;
 	substring_t args[MAX_OPT_ARGS];
+	unsigned int old_fscrypt_key_required =3D c->fscrypt_key_required;
=20
 	if (!options)
 		return 0;
@@ -1099,6 +1105,15 @@ static int ubifs_parse_options(struct ubifs_info *=
c, char *options,
 			if (!c->auth_hash_name)
 				return -ENOMEM;
 			break;
+		case Opt_fscrypt_key_required:
+			c->fscrypt_key_required =3D 1;
+
+			if (is_remount && (old_fscrypt_key_required !=3D c->fscrypt_key_requi=
red)) {
+				ubifs_err(c, "fscrypt_key_required cannot changed by remount");
+				return -EINVAL;
+			}
+
+			break;
 		case Opt_ignore:
 			break;
 		default:
diff --git a/fs/ubifs/ubifs.h b/fs/ubifs/ubifs.h
index 1ae12900e01d..71b03a6798ae 100644
--- a/fs/ubifs/ubifs.h
+++ b/fs/ubifs/ubifs.h
@@ -1304,6 +1304,7 @@ struct ubifs_info {
 	unsigned int rw_incompat:1;
 	unsigned int assert_action:2;
 	unsigned int authenticated:1;
+	unsigned int fscrypt_key_required:1;
=20
 	struct mutex tnc_mutex;
 	struct ubifs_zbranch zroot;
--=20
2.21.0
