Return-Path: <adilger@dilger.ca>
Return-Path: <adilger@dilger.ca>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <350BEDC7-0307-4624-A1E7-301D29747159@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_A19AF8F1-6517-4DC5-BE85-5A74D3591DAF";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] ext4: forbid encrypting root directory
Date: Wed, 14 Jun 2017 18:00:33 -0600
In-Reply-To: <20170614231753.113206-1-ebiggers3@gmail.com>
References: <20170614231753.113206-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-ext4 <linux-ext4@vger.kernel.org>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_A19AF8F1-6517-4DC5-BE85-5A74D3591DAF
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jun 14, 2017, at 5:17 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> From: Eric Biggers <ebiggers@google.com>
>=20
> Currently it's possible to encrypt all files and directories on an =
ext4
> filesystem by deleting everything, including lost+found, then setting =
an
> encryption policy on the root directory.  However, this is =
incompatible
> with e2fsck because e2fsck expects to find, create, and/or write to
> lost+found and does not have access to any encryption keys.  =
Especially
> problematic is that if e2fsck can't find lost+found, it will create it
> without regard for whether the root directory is encrypted.  This is
> wrong for obvious reasons, and it causes a later run of e2fsck to
> consider the lost+found directory entry to be corrupted.
>=20
> It's not clear it would be useful to support encrypting the root
> directory, because in that scenario dm-crypt might as well be used
> instead.

The benefit of per-file encryption over dm-crypt is that it isn't an
all-or-nothing usage case like dm-crypt (e.g. there could be different
users/keys for different subdirectories), and secure file delete (as
mentioned earlier) works properly with per-file encryption, and doesn't
work at all with dm-crypt.

> But in any case, it's broken currently and must not be allowed; so
> start returning an error if userspace tries to set an encryption
> policy on the root directory.
>=20
> For now do this in ext4 only, because f2fs and ubifs do not appear to
> have the lost+found requirement.  We could move it into
> fscrypt_ioctl_set_policy() later if desired, though.

What about a special case to handle an unencrypted lost+found inode?

There was also a patch series a while ago to explicitly add lost+found
into the superblock so that it could be found even if the root directory
was corrupted, and to allow flexibility in whether it is always shown in
the root directory or not (e.g. allowing ".lost+found" or similar).

Cheers, Andreas

> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
> fs/ext4/super.c | 9 +++++++++
> 1 file changed, 9 insertions(+)
>=20
> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
> index d37c81f327e7..ed8eacdf61da 100644
> --- a/fs/ext4/super.c
> +++ b/fs/ext4/super.c
> @@ -1145,6 +1145,15 @@ static int ext4_set_context(struct inode =
*inode, const void *ctx, size_t len,
> 	handle_t *handle =3D fs_data;
> 	int res, res2, retries =3D 0;
>=20
> +	/*
> +	 * Encrypting the root directory is not allowed because e2fsck =
expects
> +	 * lost+found to exist and be unencrypted, and encrypting the =
root
> +	 * directory would imply encrypting the lost+found directory as =
well as
> +	 * the filename "lost+found" itself.
> +	 */
> +	if (inode->i_ino =3D=3D EXT4_ROOT_INO)
> +		return -EBUSY;

Why -EBUSY and not -EPERM?

> 	res =3D ext4_convert_inline_data(inode);
> 	if (res)
> 		return res;
> --
> 2.13.1.508.gb3defc5cc-goog
>=20


Cheers, Andreas






--Apple-Mail=_A19AF8F1-6517-4DC5-BE85-5A74D3591DAF
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD4DBQFZQc4hpIg59Q01vtYRAmG8AKCXC5dAe4qFJpCP7GieBc6WgKGr9ACYmEYG
l61iuQtkWyuZQN0YhOTyUA==
=ewQr
-----END PGP SIGNATURE-----

--Apple-Mail=_A19AF8F1-6517-4DC5-BE85-5A74D3591DAF--
