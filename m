Return-Path: <adilger@dilger.ca>
Return-Path: <adilger@dilger.ca>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <2F4F7FA9-37C2-4FF1-9365-EF38D57FE7CA@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_45EAF68B-FB1A-41C0-91E4-F4ED373A3A5F";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Subject: Re: [PATCH] ext4: inherit encryption xattr before other xattrs
Date: Mon, 27 Feb 2017 13:28:28 -0700
In-Reply-To: <20170217233321.108637-1-ebiggers3@gmail.com>
References: <20170217233321.108637-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_45EAF68B-FB1A-41C0-91E4-F4ED373A3A5F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Feb 17, 2017, at 4:33 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> From: Eric Biggers <ebiggers@google.com>
>=20
> When using both encryption and SELinux (or another feature that =
requires
> an xattr per file) on a filesystem with 256-byte inodes, each file's
> xattrs usually spill into an external xattr block.  Currently, the
> xattrs are inherited in the order ACL, security, then encryption.
> Therefore, if spillage occurs, the encryption xattr will always end up
> in the external block.  This is not ideal because the encryption =
xattrs
> contain a nonce, so they will always be unique and will prevent the
> external xattr blocks from being deduplicated.
>=20
> To improve the situation, change the inheritance order to encryption,
> ACL, then security.  This gives the encryption xattr a better chance =
to
> be stored in-inode, allowing the other xattr(s) to be deduplicated.
>=20
> Note that it may be better for userspace to format the filesystem with
> 512-byte inodes in this case.  However, it's not the default.
>=20
> Signed-off-by: Eric Biggers <ebiggers@google.com>

Reviewed-by: Andreas Dilger <adilger@dilger.ca>

Note that we've been using 512-byte xattrs for Lustre metadata servers
for ages.  We may want to consider enabling this by default when the
filesystem features are set (e.g. crypto, inline data, etc).

Having a general mechanism to bias xattrs to in-inode or external xattr
storage would be nice also, but I don't know any way to do this beyond
just having a list of xattr names and then prioritizing the ones that
go into the in-inode space.

Cheers, Andreas

> ---
> fs/ext4/ialloc.c | 17 +++++++++++------
> 1 file changed, 11 insertions(+), 6 deletions(-)
>=20
> diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
> index b14bae2598bc..0304e28c2014 100644
> --- a/fs/ext4/ialloc.c
> +++ b/fs/ext4/ialloc.c
> @@ -1096,6 +1096,17 @@ struct inode *__ext4_new_inode(handle_t =
*handle, struct inode *dir,
> 	if (err)
> 		goto fail_drop;
>=20
> +	/*
> +	 * Since the encryption xattr will always be unique, create it =
first so
> +	 * that it's less likely to end up in an external xattr block =
and
> +	 * prevent its deduplication.
> +	 */
> +	if (encrypt) {
> +		err =3D fscrypt_inherit_context(dir, inode, handle, =
true);
> +		if (err)
> +			goto fail_free_drop;
> +	}
> +
> 	err =3D ext4_init_acl(handle, inode, dir);
> 	if (err)
> 		goto fail_free_drop;
> @@ -1117,12 +1128,6 @@ struct inode *__ext4_new_inode(handle_t =
*handle, struct inode *dir,
> 		ei->i_datasync_tid =3D handle->h_transaction->t_tid;
> 	}
>=20
> -	if (encrypt) {
> -		err =3D fscrypt_inherit_context(dir, inode, handle, =
true);
> -		if (err)
> -			goto fail_free_drop;
> -	}
> -
> 	err =3D ext4_mark_inode_dirty(handle, inode);
> 	if (err) {
> 		ext4_std_error(sb, err);
> --
> 2.11.0.483.g087da7b7c-goog
>=20


Cheers, Andreas






--Apple-Mail=_45EAF68B-FB1A-41C0-91E4-F4ED373A3A5F
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFYtIvtpIg59Q01vtYRAiLMAKDay2qlGXZEuIwHO9DQOT385aA+oQCgopgR
w/uMPtqP8bu3+Dfnxjj3FCk=
=OBUY
-----END PGP SIGNATURE-----

--Apple-Mail=_45EAF68B-FB1A-41C0-91E4-F4ED373A3A5F--
