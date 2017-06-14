Return-Path: <adilger@dilger.ca>
Return-Path: <adilger@dilger.ca>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <72134F72-718F-4B14-891D-20F2CF781A16@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_D677EA3E-69F5-4A75-98CD-0364624B1082";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 1/3] ext4: require key for truncate(2) of encrypted file
Date: Tue, 13 Jun 2017 18:14:53 -0600
In-Reply-To: <20170613234755.111167-2-ebiggers3@gmail.com>
References: <20170613234755.111167-1-ebiggers3@gmail.com>
 <20170613234755.111167-2-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_D677EA3E-69F5-4A75-98CD-0364624B1082
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jun 13, 2017, at 5:47 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> From: Eric Biggers <ebiggers@google.com>
>=20
> Currently, filesystems allow truncate(2) on an encrypted file without
> the encryption key.  However, it's impossible to correctly handle the
> case where the size being truncated to is not a multiple of the
> filesystem block size, because that would require decrypting the final
> block, zeroing the part beyond i_size, then encrypting the block.
>=20
> As other modifications to encrypted file contents are prohibited =
without
> the key, just prohibit truncate(2) as well, making it fail with =
ENOKEY.

Out of curiosity, if an encrypted block is zero-filled at the end when
the key is unavailable, what would happen?  At worst this would result
in garbage at the end of the file when the zeroes are "decrypted"?

Is it possible to unlink files if they are encrypted without the key (if
the user has permission to write to the directory)?

Does file unlink result in the per-file crypto key being erased in the
inode, or is the inode just marked unused but not overwritten?  One of
the desirable features of per-file crypto is "secure erase" so that once
the inode is unlinked the crypto key is gone and there is no way to =
decrypt
the data after the fact, even if the filesystem/user key is later =
recovered.
If the per-file key is still sitting in the inode, then it may be =
possible
to decrypt the data long after the file was deleted if the key is later
compromised and the inode+data blocks were not re-used.

Cheers, Andreas

> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
> fs/ext4/inode.c | 8 ++++++++
> 1 file changed, 8 insertions(+)
>=20
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 5cf82d03968c..baf8630de6a5 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -5307,6 +5307,14 @@ int ext4_setattr(struct dentry *dentry, struct =
iattr *attr)
> 		loff_t oldsize =3D inode->i_size;
> 		int shrink =3D (attr->ia_size <=3D inode->i_size);
>=20
> +		if (ext4_encrypted_inode(inode)) {
> +			error =3D fscrypt_get_encryption_info(inode);
> +			if (error)
> +				return error;
> +			if (!fscrypt_has_encryption_key(inode))
> +				return -ENOKEY;
> +		}
> +
> 		if (!(ext4_test_inode_flag(inode, EXT4_INODE_EXTENTS))) =
{
> 			struct ext4_sb_info *sbi =3D =
EXT4_SB(inode->i_sb);
>=20
> --
> 2.13.1.508.gb3defc5cc-goog
>=20


Cheers, Andreas






--Apple-Mail=_D677EA3E-69F5-4A75-98CD-0364624B1082
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFZQH//pIg59Q01vtYRAla2AJ90SaY0+2olcFVUFQxmwnCD9ty2UQCdHkhZ
kFUDY2KF7HvByFVWB1nnHyY=
=Mm2s
-----END PGP SIGNATURE-----

--Apple-Mail=_D677EA3E-69F5-4A75-98CD-0364624B1082--
