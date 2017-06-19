Return-Path: <adilger@dilger.ca>
Return-Path: <adilger@dilger.ca>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <CFA0E924-C86A-4B01-8104-4B89FDCDF10E@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_0DA0D103-7816-42DF-A1EF-01464FFA83AC";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2] ext4: forbid encrypting root directory
Date: Mon, 19 Jun 2017 15:18:24 -0600
In-Reply-To: <20170616183411.31587-1-ebiggers3@gmail.com>
References: <20170616183411.31587-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-ext4 <linux-ext4@vger.kernel.org>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_0DA0D103-7816-42DF-A1EF-01464FFA83AC
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jun 16, 2017, at 12:34 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
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
> Encrypting the root directory may also be of limited use because it is
> the "all-or-nothing" use case, for which dm-crypt can be used instead.
> (By design, encryption policies are inherited and cannot be =
overridden;
> so the root directory having an encryption policy implies that all =
files
> and directories on the filesystem have that same encryption policy.)
>=20
> In any case, encrypting the root directory is broken currently and =
must
> not be allowed; so start returning an error if userspace requests it.
> For now only do this in ext4, because f2fs and ubifs do not appear to
> have the lost+found requirement.  We could move it into
> fscrypt_ioctl_set_policy() later if desired, though.
>=20
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Andreas Dilger <adilger@dilger.ca>

> ---
>=20
> v2: use EPERM instead of EBUSY, and tweak commit message
>=20
> fs/ext4/super.c | 9 +++++++++
> 1 file changed, 9 insertions(+)
>=20
> diff --git a/fs/ext4/super.c b/fs/ext4/super.c
> index d37c81f327e7..d5b5c80c23f5 100644
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
> +		return -EPERM;
> +
> 	res =3D ext4_convert_inline_data(inode);
> 	if (res)
> 		return res;
> --
> 2.13.1.518.g3df882009-goog
>=20


Cheers, Andreas






--Apple-Mail=_0DA0D103-7816-42DF-A1EF-01464FFA83AC
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFZSD+ipIg59Q01vtYRAujzAKDQxZuweksAMa3jJpr4m3b9QgomowCeJz5s
nj2rW3OKpZtvlsNyZMkEG5Q=
=bk2p
-----END PGP SIGNATURE-----

--Apple-Mail=_0DA0D103-7816-42DF-A1EF-01464FFA83AC--
