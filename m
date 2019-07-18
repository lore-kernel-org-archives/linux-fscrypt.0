Return-Path: <SRS0=hZ0d=VP=dilger.ca=adilger@kernel.org>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <D9B442DB-51C2-4AAC-8113-AE462E7DA637@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_5BC3AC0D-AC2B-4712-BDD5-373BA2675BCC";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] e2fsck: check for consistent encryption policies
Date: Thu, 18 Jul 2019 00:25:42 -0600
In-Reply-To: <20190718011325.19516-1-ebiggers@kernel.org>
References: <20190718011325.19516-1-ebiggers@kernel.org>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_5BC3AC0D-AC2B-4712-BDD5-373BA2675BCC
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jul 17, 2019, at 7:13 PM, Eric Biggers <ebiggers@kernel.org> wrote:
>=20
> From: Eric Biggers <ebiggers@google.com>
>=20
> By design, the kernel enforces that all files in an encrypted =
directory
> use the same encryption policy as the directory.  It's not possible to
> violate this constraint using syscalls.  Lookups of files that violate
> this constraint also fail, in case the disk was manipulated.
>=20
> But this constraint can also be violated by accidental filesystem
> corruption.  E.g., a power cut when using ext4 without a journal might
> leave new files without the encryption bit and/or xattr.  Thus, it's
> important that e2fsck correct this condition.
>=20
> Therefore, this patch makes the following changes to e2fsck:
>=20
> - During pass 1 (inode table scan), create a map from inode number to
>  encryption xattr for all encrypted inodes.  If an encrypted inode has
>  a missing or clearly invalid xattr, offer to clear the inode.
>=20
> - During pass 2 (directory structure check), verify that all regular
>  files, directories, and symlinks in encrypted directories use the
>  directory's encryption policy.  Offer to clear any directory entries
>  for which this isn't the case.
>=20
> Add a new test "f_bad_encryption" to test the new behavior.
>=20
> Due to the new checks, it was also necessary to update the existing =
test
> "f_short_encrypted_dirent" to add an encryption xattr to the test =
file,
> since it was missing one before, which is now considered invalid.
>=20
> Google-Bug-Id: 135138675
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
> diff --git a/e2fsck/e2fsck.h b/e2fsck/e2fsck.h
> index 2d359b38..10dcb582 100644
> --- a/e2fsck/e2fsck.h
> +++ b/e2fsck/e2fsck.h
> @@ -135,6 +135,22 @@ struct dx_dirblock_info {
> #define DX_FLAG_FIRST		4
> #define DX_FLAG_LAST		8
>=20
> +/*
> + * The encrypted file information structure; stores information for =
files which
> + * are encrypted.
> + */
> +struct encrypted_file {
> +	ext2_ino_t ino;
> +	void *xattr_value;
> +	size_t xattr_size;
> +};

This structure is pretty memory inefficient.  4 byte ino, 8 bytes =
pointer, then a
8 byte size. I don't think that we need a full size_t to store a valid =
xattr size,
given that is limited to 64KB currently, while size_t is an unsigned =
long.

It would save 8 bytes per inode to rearrange these, and add a unique =
prefix to make
the fields easier to find:

struct e2fsck_encrypted_file {
	ext2_ino_t   eef_ino;
	unsigned int eef_xattr_size;
	void        *eef_xattr_value;
};

> +struct encrypted_files {
> +	size_t count;
> +	size_t capacity;
> +	struct encrypted_file *files;
> +};

Searching for "encrypted_file" vs. "encrypted_files" is not great.  =
Maybe
"e2fsck_encrypted_(file_)list" or "e2fsck_encrypted_(file_)array"?  As =
above,
better to have a prefix for these structure fields, like "eel_" or =
"eea_".

> +int add_encrypted_file(e2fsck_t ctx, struct problem_context *pctx)
> +{
> +	pctx->errcode =3D get_encryption_xattr(ctx, ino, =
&file->xattr_value,
> +					     &file->xattr_size);
> +	if (pctx->errcode) {
> +		if (fix_problem(ctx, PR_1_MISSING_ENCRYPTION_XATTR, =
pctx))
> +			return -1;

At this point, you don't really know if the inode _should_ be encrypted,
or if it is a stray bit flip in the EXT4_ENCRYPT_STATE that resulted in
add_encrypted_file being called.  This results in the inode being =
deleted,
even though it is possible that it was never encrypted.  This =
determination
should be made later when the inode's parent directory is known.  Either
the parent also has an encryption flag+xattr and it _should_ have been
encrypted and should be cleared, or the parent doesn't have an =
encryption
flag+xattr and only the child inode flag should be cleared...

> +	} else if (!possibly_valid_encryption_xattr(file->xattr_value,
> +						    file->xattr_size)) {
> +		ext2fs_free_mem(&file->xattr_value);
> +		file->xattr_size =3D 0;
> +		if (fix_problem(ctx, PR_1_CORRUPT_ENCRYPTION_XATTR, =
pctx))
> +			return -1;
> +	}


I can see in this case, where the inode is flagged and the encryption =
xattr
exists (named "c" if I read correctly?), but is corrupt, then there =
isn't
much to do for the file.

> @@ -1415,18 +1478,21 @@ skip_checksum:
> 			}
>=20
> -		if (encrypted && (dot_state) > 1 &&
> -		    encrypted_check_name(ctx, dirent, &cd->pctx)) {

No need for () around "dot_state".


Cheers, Andreas






--Apple-Mail=_5BC3AC0D-AC2B-4712-BDD5-373BA2675BCC
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEEDb73u6ZejP5ZMprvcqXauRfMH+AFAl0wEOcACgkQcqXauRfM
H+DiRg//SLlG922tFzGlKJkI1k2V9F1ocpL42Op21Lw4U7SsYjkxa53nmbPMIPH2
G5g7RM2OASe3X5nkkq+IFjUH53b+k4Gkf4qYt2oUBl60cRza3GX4S5+R5qfDLGog
0trXjJWIiw4AbQ/VAB3khX1bmaRABzXhEB50eMkcMk2xDrul0bwSV2TTzu4UrcNJ
mm4oCoRTjVIREJGWjsazYxfFP0UJVFDkuCTr68TJm24pDx8asI9pyZ8h1saLxCEW
uVuyNk3YXzOEVSm+LyYk84NW34dmftX2c40LxXuy5FE9lqyz4OKEBoxpzqLG1JDM
FvxIX1AbDkExJzgFnoH12O8G6TPl24iHgO65KaBqGPg+D/4WGAor7pousF5zElAf
AW263wkkc87fpnDiN8qmwp3gzP03B6HthJUmrZDpZ8G32S/oFUNtNRFKl+BKLjHy
jk3XwCiTW3udXfdngi/ctRc+ydtudGbnc0QjMP1F0Mf0TH/jevnvRLNCvGY2f6D9
fkLAtbsqjaWRnXxC8MR58FsnL7M4pxWgORy6Y6oSlWrPDTIu9ldrjEPTwI0P6UJp
+EWiK8DDDa4ryDdBwPSLiAjrHSL6Hn7O5OtqJSIK37ZnEeoGLQptbI1It9I+6M8Q
ar+bNwZ1rwo6AVQtHz0+HQ4Gc20WSKIX6XX94NyHPqs3jbrM39A=
=u0Er
-----END PGP SIGNATURE-----

--Apple-Mail=_5BC3AC0D-AC2B-4712-BDD5-373BA2675BCC--
