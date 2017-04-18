Return-Path: <linux-ext4-owner@vger.kernel.org>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <24675FA9-C45C-4067-B9E5-ED126F68D0A2@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_68D8930B-7508-491B-8939-0F39EC6525E0";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] fscrypt: use 32 bytes of encrypted filename
Date: Tue, 18 Apr 2017 17:37:59 -0600
In-Reply-To: <20170418210642.6039-1-gwendal@chromium.org>
References: <20170418210642.6039-1-gwendal@chromium.org>
Sender: linux-ext4-owner@vger.kernel.org
To: Gwendal Grignou <gwendal@chromium.org>
Cc: Ts'o Theodore <tytso@mit.edu>, Eric Biggers <ebiggers@google.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fscrypt@vger.kernel.org, kinaba@chromium.org, hashimoto@chromium.org
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_68D8930B-7508-491B-8939-0F39EC6525E0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 18, 2017, at 3:06 PM, Gwendal Grignou <gwendal@chromium.org> =
wrote:
> Subject: [PATCH] fscrypt: use 32 bytes of encrypted filename

> If we use only 16 bytes, due to how CBC works, if the names have the
> same beginning, their last ciphertext block (16 bytes) may be =
identical.

What is missing from the patch summary is: use the encrypted filename =
for
_what_?

>=20
> It happens when two file names share the first 16k bytes and both have

"16k bytes" for the file names?  Presumably you don't mean "16KB", but
rather "16n" or "multiple of 16 bytes" would be more clear.

> length withn 16 * n + 13 and 16 * n + 16.
>=20
> Instead use 32 bytes to build the filenames from encrypted data when
> directory is scrambled.
>=20
> The drawback is the scrambled filenames change after applying the =
patch.
> Consider an encrypted directory with:
>=20
> ls -il
> total 8
> 1177380 -rw-r--r--. 1 root root 0 Apr 18 12:10
> system@framework@boot-telephony-common.art.crc
> 1177379 -rw-r--r--. 1 root root 0 Apr 18 12:10
> system@framework@boot-telephony-common.oat.crc
>=20
> Once the key is invalidated, without the patch, ls -li produces:
> 1177379 -rw-r--r--. 1 root root 0 Apr 18 12:10
> _a1Psh01n8FdhC8s9pUywlAyFzlz7n6C3
> 1177379 -rw-r--r--. 1 root root 0 Apr 18 12:10
> _wJS,0akq14ehC8s9pUywlAyFzlz7n6C3
>=20
> Both files show with the same inode.
>=20
> After the patch, the names are different, but the inode information is
> now correct:
> ls -li
> 1177380 -rw-r--r--. 1 root root 0 Apr 18 12:10
> _a1Psh01n8FtxbeglW8BqhuthSUxMqh6cFKwz2nSJDXCIXMXOvfqLcD
> 1177379 -rw-r--r--. 1 root root 0 Apr 18 12:10
> _wJS,0akq14eJcuQks7f2Vsg,zE0Jdz98FKwz2nSJDXCIXMXOvfqLcD

It isn't clear to me what the difference is here.  In the first case
(without patch) the last 21 characters of the filename are the same,
but the first 11 characters are still different, so it isn't clear why
that isn't enough to distinguish the files, and why checking the whole
filename isn't enough to properly determine the inode number?

In the second case (with patch) the last 22 characters are also the =
same.

> Tested only on ext4.
>=20
> Signed-off-by: Gwendal Grignou <gwendal@chromium.org>
> ---
> Script to reproduce the error:
>=20
> BASE_DIR=3D"~/"
> DIR=3D"${BASE_DIR}/tmp"
> # Create directory.
> mkdir -p "${DIR}"
> echo foobar | e4crypt add_key "${DIR}"
> # Fill directory.
> cd "${DIR}"
> touch system@framework@boot-telephony-common.oat.crc
> touch system@framework@boot-telephony-common.art.crc
> cd ..
> # Check files have different inode.
> ls -il "${DIR}"
> # Invalidate key
> KEY=3D"$(keyctl show | grep $(e4crypt get_policy "${DIR}" | cut -d ':' =
-f 2) | sed -ne 's/\(.*\) --al.*/\1/p')"
> sync
> keyctl invalidate "${KEY}"
> echo 3 > /proc/sys/vm/drop_caches
> # Once the key is invalidated, both files have the same inode:
> ls -il "${DIR}"
> if [ $(ls -i1 "${DIR}" | cut -d ' ' -f 1 | uniq | wc -l) -eq 1 ] ; =
then
>  echo same inode!
> fi
> # if we try to remove the directory, we will get an error
> # : Structure needs cleaning
> # rm -rf "${DIR}"
>=20
> fs/crypto/fname.c | 20 +++++++++++++-------
> fs/ext4/namei.c   |  4 ++--
> 2 files changed, 15 insertions(+), 9 deletions(-)
>=20
> diff --git a/fs/crypto/fname.c b/fs/crypto/fname.c
> index 80bb956e14e5..71ddc3eaa62d 100644
> --- a/fs/crypto/fname.c
> +++ b/fs/crypto/fname.c
> @@ -274,7 +274,7 @@ int fscrypt_fname_disk_to_usr(struct inode *inode,
> 			struct fscrypt_str *oname)
> {
> 	const struct qstr qname =3D FSTR_TO_QSTR(iname);
> -	char buf[24];
> +	char buf[FS_FNAME_CRYPTO_DIGEST_SIZE + sizeof(u64)];
>=20
> 	if (fscrypt_is_dot_dotdot(&qname)) {
> 		oname->name[0] =3D '.';
> @@ -295,14 +295,19 @@ int fscrypt_fname_disk_to_usr(struct inode =
*inode,
> 		return 0;
> 	}
> 	if (hash) {
> -		memcpy(buf, &hash, 4);
> -		memcpy(buf + 4, &minor_hash, 4);
> +		memcpy(buf, &hash, sizeof(u32));
> +		memcpy(buf + 4, &minor_hash, sizeof(u32));

Should "4" be replaced with something here?  sizeof(u32), or something =
else?

> 	} else {
> 		memset(buf, 0, 8);

Likewise, should "8" be replaced with sizeof(u64) as it is with other =
changes?

> 	}
> -	memcpy(buf + 8, iname->name + iname->len - 16, 16);
> +	memcpy(buf + sizeof(u64),
> +	       iname->name + iname->len - FS_FNAME_CRYPTO_DIGEST_SIZE,
> +	       FS_FNAME_CRYPTO_DIGEST_SIZE);
> 	oname->name[0] =3D '_';
> -	oname->len =3D 1 + digest_encode(buf, 24, oname->name + 1);
> +	oname->len =3D 1 + digest_encode(
> +			buf,
> +			FS_FNAME_CRYPTO_DIGEST_SIZE + sizeof(u64),
> +			oname->name + 1);
> 	return 0;
> }
> EXPORT_SYMBOL(fscrypt_fname_disk_to_usr);
> @@ -375,10 +380,11 @@ int fscrypt_setup_filename(struct inode *dir, =
const struct qstr *iname,
> 	 */
> 	if (iname->name[0] =3D=3D '_')
> 		bigname =3D 1;
> -	if ((bigname && (iname->len !=3D 33)) || (!bigname && =
(iname->len > 43)))
> +	if ((bigname && iname->len !=3D 55) || (!bigname && (iname->len =
> 43)))

The "55" constant is no better than "33" in terms of clarity, nor is =
"43".
Having a (computed) constant for this would be more helpful, for example

   2 * sizeof(buf) + 1

or whatever.

> 		return -ENOENT;
>=20
> -	fname->crypto_buf.name =3D kmalloc(32, GFP_KERNEL);
> +	fname->crypto_buf.name =3D kmalloc(
> +			FS_FNAME_CRYPTO_DIGEST_SIZE + sizeof(u64), =
GFP_KERNEL);
> 	if (fname->crypto_buf.name =3D=3D NULL)
> 		return -ENOMEM;
>=20
> diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
> index c4a389a6027b..14b2a2335a32 100644
> --- a/fs/ext4/namei.c
> +++ b/fs/ext4/namei.c
> @@ -1257,8 +1257,8 @@ static inline int ext4_match(struct =
ext4_filename *fname,
> 			int ret;
> 			if (de->name_len < 16)
> 				return 0;
> -			ret =3D memcmp(de->name + de->name_len - 16,
> -				     fname->crypto_buf.name + 8, 16);
> +			ret =3D memcmp(de->name + de->name_len - 32,
> +				     fname->crypto_buf.name + 8, 32);
> 			return (ret =3D=3D 0) ? 1 : 0;

This could just be:

			return (ret =3D=3D 0);

> 		}
> 		name =3D fname->crypto_buf.name;
>                 len =3D fname->crypto_buf.len;
>         }
> #endif
>         if (de->name_len !=3D len)
>                 return 0;
>         return (memcmp(de->name, name, len) =3D=3D 0) ? 1 : 0;


And similarly:

	return (memcmp(de->name, name, len) =3D=3D 0);


Cheers, Andreas






--Apple-Mail=_68D8930B-7508-491B-8939-0F39EC6525E0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFY9qNZpIg59Q01vtYRAutaAKCbMJDMOtToNbN+ghvWdLIgXAkIagCfa5O+
rWx5y0iXWP9c9o90xfxvUE8=
=w/1N
-----END PGP SIGNATURE-----

--Apple-Mail=_68D8930B-7508-491B-8939-0F39EC6525E0--
