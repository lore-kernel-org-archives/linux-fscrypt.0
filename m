Return-Path: <david@sigma-star.at>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] fscrypt: Add support for AES-128-CBC
From: David Gstir <david@sigma-star.at>
In-Reply-To: <20170331062149.GA32409@zzz>
Date: Fri, 31 Mar 2017 13:11:59 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <033D8C72-1F2F-40EF-AD86-A1646EA1A0D6@sigma-star.at>
References: <20170330173840.72909-1-david@sigma-star.at> <20170331062149.GA32409@zzz>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: tytso@mit.edu, jaegeuk@kernel.org, dwalter@sigma-star.at, Richard Weinberger <richard@sigma-star.at>, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

thanks for the feedback!

> On 31.03.2017, at 08:21, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> [+Cc linux-fscrypt]

Oh, I didn't know about that list. I think MAINTAINERS should be updated =
to reflect that. :)

>=20
> Hi David and Daniel,
>=20
> On Thu, Mar 30, 2017 at 07:38:40PM +0200, David Gstir wrote:
>> From: Daniel Walter <dwalter@sigma-star.at>
>>=20
>> fscrypt provides facilities to use different encryption algorithms =
which are
>> selectable by userspace when setting the encryption policy. =
Currently, only
>> AES-256-XTS for file contents and AES-256-CBC-CTS for file names are =
implemented.
>> Which is a clear case of kernel offers the mechanism and userspace =
selects a
>> policy. Similar to what dm-crypt and ecryptfs have.
>>=20
>> This patch adds support for using AES-128-CBC for file contents and
>> AES-128-CBC-CTS for file name encryption. To mitigate watermarking =
attacks, IVs
>> are generated using the ESSIV algorithm. While AES-CBC is actually =
slightly
>> less secure than AES-XTS from a security point of view, there is more
>> widespread hardware support. Especially low-powered embedded devices =
crypto
>> accelerators such as CAAM or CESA support only AES-CBC-128 with an =
acceptable
>> speed. Using AES-CBC gives us the acceptable performance while still =
providing
>> a moderate level of security for persistent storage.
>>=20
>=20
> Thanks for sending this!  I can't object too much to adding =
AES-CBC-128 if you
> find it useful, though of course AES-256-XTS will remain the =
recommendation for
> general use. =20

Yes, AES-256-XTS should definitely be the recommendation and default =
here!
AES-128-CBC is a last resort if XTS is not possible for whatever reason.


> And I don't suppose AES-256-CBC is an option for you?

We went for AES-128 since it has less rounds and yields better =
performance. At least on the hardware we looked at, there was quite a =
difference in speed between AES-128-CBC and AES-256-CBC.

Anyways, AES-256-CBC could be added with just a few lines after this =
patch. :)


> Anyway, more comments below:

[...]

>> +	if (ctx.contents_encryption_mode =3D=3D =
FS_ENCRYPTION_MODE_AES_128_CBC &&
>> +	    ctx.filenames_encryption_mode !=3D =
FS_ENCRYPTION_MODE_AES_128_CTS)
>> +		return -EINVAL;
>> +
>=20
> I think for now we should only allow the two pairs:
>=20
> 	contents_encryption_mode=3DFS_ENCRYPTION_MODE_AES_256_XTS
> 	filenames_encryption_mode=3DFS_ENCRYPTION_MODE_AES_256_CTS
>=20
> and
>=20
> 	contents_encryption_mode=3DFS_ENCRYPTION_MODE_AES_128_CBC
> 	filenames_encryption_mode=3DFS_ENCRYPTION_MODE_AES_128_CTS
>=20
> Other combinations like AES-256-XTS paired with AES-128-CTS should be =
forbidden.

Yes, I agree.


> This also needs to be enforced in =
create_encryption_context_from_policy() so
> that FS_IOC_SET_ENCRYPTION_POLICY fails with bad combinations.
>=20
>> +	if (crypt_info->ci_data_mode =3D=3D =
FS_ENCRYPTION_MODE_AES_128_CBC) {
>> +		/* init ESSIV generator */
>> +		essiv_tfm =3D crypto_alloc_cipher("aes", 0, 0);
>> +		if (!essiv_tfm || IS_ERR(essiv_tfm)) {
>> +			res =3D essiv_tfm ? PTR_ERR(essiv_tfm) : =
-ENOMEM;
>> +			printk(KERN_DEBUG
>> +			       "%s: error %d (inode %u) allocating essiv =
tfm\n",
>> +			       __func__, res, (unsigned) inode->i_ino);
>> +			goto out;
>> +		}
>> +		/* calc sha of key for essiv generation */
>> +		memset(sha_ws, 0, sizeof(sha_ws));
>> +		sha_init(essiv_key);
>> +		sha_transform(essiv_key, raw_key, sha_ws);
>> +		res =3D crypto_cipher_setkey(essiv_tfm, (u8 *)essiv_key, =
keysize);
>> +		if (res)
>> +			goto out;
>> +
>> +		crypt_info->ci_essiv_tfm =3D essiv_tfm;
>> +	}
>=20
> I think the ESSIV hash should be SHA-256 not SHA-1.  SHA-1 is becoming =
more and
> more obsolete these days.  Another issue with SHA-1 is that it only =
produces a
> 20 byte hash, which means it couldn't be used if someone ever wanted =
to add
> AES-256-CBC as another mode.

Good point! We'll change this to always use sha-256.


I'll wait for some more feedback and will provide a v2 which includes =
all your comments.

Thanks,
David=
