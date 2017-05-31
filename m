Return-Path: <david@sigma-star.at>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v4] fscrypt: Add support for AES-128-CBC
From: David Gstir <david@sigma-star.at>
In-Reply-To: <20170523190041.GA132828@gmail.com>
Date: Wed, 31 May 2017 17:57:22 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <54DA453A-BC92-466E-B3D2-6C67D7D32A90@sigma-star.at>
References: <20170517180850.GA91213@gmail.com>
 <20170523051120.15698-1-david@sigma-star.at>
 <20170523190041.GA132828@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@sigma-star.at>, herbert@gondor.apana.org.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org, Daniel Walter <dwalter@sigma-star.at>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Eric,

> On 23 May 2017, at 21:00, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> Hi David,
>=20
> On Tue, May 23, 2017 at 07:11:20AM +0200, David Gstir wrote:
>> From: Daniel Walter <dwalter@sigma-star.at>
>>=20
>> fscrypt provides facilities to use different encryption algorithms =
which
>> are selectable by userspace when setting the encryption policy. =
Currently,
>> only AES-256-XTS for file contents and AES-256-CBC-CTS for file names =
are
>> implemented. This is a clear case of kernel offers the mechanism and
>> userspace selects a policy. Similar to what dm-crypt and ecryptfs =
have.
>>=20
>> This patch adds support for using AES-128-CBC for file contents and
>> AES-128-CBC-CTS for file name encryption. To mitigate watermarking
>> attacks, IVs are generated using the ESSIV algorithm. While AES-CBC =
is
>> actually slightly less secure than AES-XTS from a security point of =
view,
>> there is more widespread hardware support. Using AES-CBC gives us the
>> acceptable performance while still providing a moderate level of =
security
>> for persistent storage.
>>=20
>> Especially low-powered embedded devices with crypto accelerators such =
as
>> CAAM or CESA often only support AES-CBC. Since using AES-CBC over =
AES-XTS
>> is basically thought of a last resort, we use AES-128-CBC over =
AES-256-CBC
>> since it has less encryption rounds and yields noticeable better
>> performance starting from a file size of just a few kB.
>>=20
>> Signed-off-by: Daniel Walter <dwalter@sigma-star.at>
>> [david@sigma-star.at: addressed review comments]
>> Signed-off-by: David Gstir <david@sigma-star.at>
>=20
> Overall this looks good now; you can add
>=20
> Reviewed-by: Eric Biggers <ebiggers@google.com>

Thanks! :)


> I did notice a couple minor improvements that can be made, though:
>=20
>>=20
>> +	if (crypt_info->ci_data_mode =3D=3D =
FS_ENCRYPTION_MODE_AES_128_CBC) {
>> +		res =3D init_essiv_generator(crypt_info, raw_key, =
keysize);
>> +		if (res) {
>> +			pr_debug("%s: error %d (inode %lu) allocating =
essiv tfm\n",
>> +				 __func__, res, inode->i_ino);
>> +			goto out;
>> +		}
>> +	}
>=20
> Since the ESSIV generator is only needed for contents encryption, it =
should only
> be initialized when both 'S_ISREG(inode->i_mode) && =
crypt_info->ci_data_mode =3D=3D
> FS_ENCRYPTION_MODE_AES_128_CBC'.  Otherwise ->ci_essiv_tfm will be =
allocated for
> directories and symlinks too, then never used.
>=20
>> +static int init_essiv_generator(struct fscrypt_info *ci, const u8 =
*raw_key,
>> +				int keysize)
>> +{
>> +	int err;
>> +	struct crypto_cipher *essiv_tfm;
>> +	u8 salt[SHA256_DIGEST_SIZE];
>> +
>> +	if (WARN_ON_ONCE(keysize > sizeof(salt)))
>> +		return -EINVAL;
>> +
>=20
> The 'keysize > sizeof(salt)' check is now pointless and should be =
removed, since
> we decided not to key the ESSIV cipher with 'keysize' bytes, but =
rather with
> sizeof(salt) bytes.  So this function is compatible with any =
'keysize', not just
> keysize <=3D sizeof(salt).

You're right. Just let me know if I should send a new version of this =
patch with these minor issues fixed.


> You should also consider how it should be made possible to test these =
new
> encryption modes in xfstests.  Currently, while the "set_encpolicy" =
xfs_io
> command allows specifying different encryption modes and flags, in =
general the
> tests in the "encrypt" group are hardcoded to use AES_256_XTS and =
AES_256_CTS.
> Similarly, those modes are also used with the test_dummy_encryption =
mount
> option, which causes all new files to be automatically encrypted, and =
is used by
> the "encrypt" config for kvm-xfstests and gce-xfstests (currently =
ext4-specific,
> but other filesystems could support it too).

Sure! I'll do that.

Thanks,
David=
