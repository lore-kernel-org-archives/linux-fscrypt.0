Return-Path: <david@sigma-star.at>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v4] fscrypt: Add support for AES-128-CBC
From: David Gstir <david@sigma-star.at>
In-Reply-To: <20170615204841.GA66403@gmail.com>
Date: Fri, 16 Jun 2017 09:39:07 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <5565BD72-986F-4338-8562-6B5F9FB72110@sigma-star.at>
References: <20170517180850.GA91213@gmail.com>
 <20170523051120.15698-1-david@sigma-star.at>
 <20170615204129.GA23647@google.com> <20170615204841.GA66403@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Michael Halcrow <mhalcrow@google.com>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@sigma-star.at>, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Daniel Walter <dwalter@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>


> On 15 Jun 2017, at 22:48, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> On Thu, Jun 15, 2017 at 01:41:29PM -0700, Michael Halcrow wrote:
>>> static int validate_user_key(struct fscrypt_info *crypt_info,
>>> 			struct fscrypt_context *ctx, u8 *raw_key,
>>> -			const char *prefix)
>>> +			const char *prefix, int min_keysize)
>>> {
>>> 	char *description;
>>> 	struct key *keyring_key;
>>> @@ -111,50 +116,60 @@ static int validate_user_key(struct =
fscrypt_info *crypt_info,
>>> 	master_key =3D (struct fscrypt_key *)ukp->data;
>>> 	BUILD_BUG_ON(FS_AES_128_ECB_KEY_SIZE !=3D =
FS_KEY_DERIVATION_NONCE_SIZE);
>>>=20
>>> -	if (master_key->size !=3D FS_AES_256_XTS_KEY_SIZE) {
>>> +	if (master_key->size < min_keysize || master_key->size > =
FS_MAX_KEY_SIZE
>>> +	    || master_key->size % AES_BLOCK_SIZE !=3D 0) {
>>=20
>> I suggest validating the provided key size directly against the mode.
>> Else, it looks to me that this code will accept a 128-bit key for
>> AES-256.
>>=20
>=20
> It's doing that already; min_keysize depends on the mode.

We are a bit more forgiving than the code was before: In case =
AES-128-CBC is
selected, we accept a longer key and use the first 128 bits of the =
derived key.
(see fscrypt_get_encryption_info())

The alternative is to make this check as strict as it was and just check =
for
master_key->size !=3D min_keysize.

IMO the current check is okay. I will however add a comment that =
documents this.
We could also add a pr_warn_once(), but I don't think this is really =
necessary.

David=
