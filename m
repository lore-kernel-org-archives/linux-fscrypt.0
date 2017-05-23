Return-Path: <david@sigma-star.at>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] fscrypt: inline fscrypt_free_filename()
From: David Gstir <david@sigma-star.at>
In-Reply-To: <20170523011406.32718-1-ebiggers3@gmail.com>
Date: Tue, 23 May 2017 08:01:11 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <ED96E462-F332-4688-ACE9-9F60EFF4DA46@sigma-star.at>
References: <20170523011406.32718-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

> On 23 May 2017, at 03:14, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> From: Eric Biggers <ebiggers@google.com>
>=20
> fscrypt_free_filename() only needs to do a kfree() of crypto_buf.name,
> which works well as an inline function.  We can skip setting the =
various
> pointers to NULL, since no user cares about it (the name is always =
freed
> just before it goes out of scope).
>=20
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---
> fs/crypto/fname.c            | 9 ---------
> include/linux/fscrypt_supp.h | 7 ++++++-
> 2 files changed, 6 insertions(+), 10 deletions(-)
>=20
> diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
> index d1bb02b1ee58..ad9f814fdead 100644
> --- a/fs/crypto/fname.c
> +++ b/fs/crypto/fname.c
> @@ -453,12 +453,3 @@ int fscrypt_setup_filename(struct inode *dir, =
const struct qstr *iname,
> 	return ret;
> }
> EXPORT_SYMBOL(fscrypt_setup_filename);
> -
> -void fscrypt_free_filename(struct fscrypt_name *fname)
> -{
> -	kfree(fname->crypto_buf.name);
> -	fname->crypto_buf.name =3D NULL;
> -	fname->usr_fname =3D NULL;
> -	fname->disk_name.name =3D NULL;
> -}
> -EXPORT_SYMBOL(fscrypt_free_filename);
> diff --git a/include/linux/fscrypt_supp.h =
b/include/linux/fscrypt_supp.h
> index cd4e82c17304..32e2fcf13b01 100644
> --- a/include/linux/fscrypt_supp.h
> +++ b/include/linux/fscrypt_supp.h
> @@ -47,7 +47,12 @@ extern void fscrypt_put_encryption_info(struct =
inode *, struct fscrypt_info *);
> /* fname.c */
> extern int fscrypt_setup_filename(struct inode *, const struct qstr *,
> 				int lookup, struct fscrypt_name *);
> -extern void fscrypt_free_filename(struct fscrypt_name *);
> +
> +static inline void fscrypt_free_filename(struct fscrypt_name *fname)
> +{
> +	kfree(fname->crypto_buf.name);
> +}
> +
> extern u32 fscrypt_fname_encrypted_size(const struct inode *, u32);
> extern int fscrypt_fname_alloc_buffer(const struct inode *, u32,
> 				struct fscrypt_str *);
> --=20
> 2.13.0.219.gdb65acc882-goog

LGTM.
Reviewed-by: David Gstir <david@sigma-star.at>=20

David
