Return-Path: <adilger@dilger.ca>
Return-Path: <adilger@dilger.ca>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <F7BF6774-18AA-4A57-AF64-D7D125A7E73C@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_6F02D73A-D315-4927-AA89-45FB59E93E59";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] ext4: forbid encrypting root directory
Date: Wed, 14 Jun 2017 20:02:05 -0600
In-Reply-To: <20170615002453.GA30126@gmail.com>
References: <20170614231753.113206-1-ebiggers3@gmail.com>
 <350BEDC7-0307-4624-A1E7-301D29747159@dilger.ca>
 <20170615002453.GA30126@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-ext4 <linux-ext4@vger.kernel.org>, linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_6F02D73A-D315-4927-AA89-45FB59E93E59
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jun 14, 2017, at 6:24 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> Hi Andreas,
>=20
> On Wed, Jun 14, 2017 at 06:00:33PM -0600, Andreas Dilger wrote:
>> On Jun 14, 2017, at 5:17 PM, Eric Biggers <ebiggers3@gmail.com> =
wrote:
>>>=20
>>> From: Eric Biggers <ebiggers@google.com>
>>>=20
>>> Currently it's possible to encrypt all files and directories on an =
ext4
>>> filesystem by deleting everything, including lost+found, then =
setting an
>>> encryption policy on the root directory.  However, this is =
incompatible
>>> with e2fsck because e2fsck expects to find, create, and/or write to
>>> lost+found and does not have access to any encryption keys.  =
Especially
>>> problematic is that if e2fsck can't find lost+found, it will create =
it
>>> without regard for whether the root directory is encrypted.  This is
>>> wrong for obvious reasons, and it causes a later run of e2fsck to
>>> consider the lost+found directory entry to be corrupted.
>>>=20
>>> It's not clear it would be useful to support encrypting the root
>>> directory, because in that scenario dm-crypt might as well be used
>>> instead.
>>=20
>> The benefit of per-file encryption over dm-crypt is that it isn't an
>> all-or-nothing usage case like dm-crypt (e.g. there could be =
different
>> users/keys for different subdirectories), and secure file delete (as
>> mentioned earlier) works properly with per-file encryption, and =
doesn't
>> work at all with dm-crypt.
>=20
> Well, encrypting the root directory *is* the all-or-nothing use case =
--- all
> files and directories on the filesystem would be encrypted with the =
same key,
> and by design it cannot be overridden for individual =
files/directories.
>=20
> "Secure file delete" would be an advantage if/when it's implemented, =
though.
>=20
>>> But in any case, it's broken currently and must not be allowed; so
>>> start returning an error if userspace tries to set an encryption
>>> policy on the root directory.
>>>=20
>>> For now do this in ext4 only, because f2fs and ubifs do not appear =
to
>>> have the lost+found requirement.  We could move it into
>>> fscrypt_ioctl_set_policy() later if desired, though.
>>=20
>> What about a special case to handle an unencrypted lost+found inode?
>>=20
>> There was also a patch series a while ago to explicitly add =
lost+found
>> into the superblock so that it could be found even if the root =
directory
>> was corrupted, and to allow flexibility in whether it is always shown =
in
>> the root directory or not (e.g. allowing ".lost+found" or similar).
>=20
> It could be done if the lost+found inode was not linked to from any =
directory
> and instead had its inode number stored in the superblock so that =
e2fsck could
> still find it.  However, if e2fsck put files in a lost+found directory =
that
> doesn't exist in the filesystem directory structure, how would users =
retrieve
> those files?  Would users be required to run a special e2fsprogs =
command to
> list/read/delete the files in lost+found?

I was thinking that readdir on the root inode could insert the =
"lost+found"
or ".lost+found" entry dynamically, or (a bit less pleasant) is to add a
special case that this entry is just never encrypted (could compare the
inode number to the one stored in the superblock, instead of comparing =
names)?

Cheers, Andreas

>>> +	/*
>>> +	 * Encrypting the root directory is not allowed because e2fsck =
expects
>>> +	 * lost+found to exist and be unencrypted, and encrypting the =
root
>>> +	 * directory would imply encrypting the lost+found directory as =
well as
>>> +	 * the filename "lost+found" itself.
>>> +	 */
>>> +	if (inode->i_ino =3D=3D EXT4_ROOT_INO)
>>> +		return -EBUSY;
>>=20
>> Why -EBUSY and not -EPERM?
>>=20
>=20
> No strong reason; I had in mind that EBUSY is returned when running a =
command
> like 'rmdir /mnt'.  Probably EPERM would be better.
>=20
> Eric


Cheers, Andreas






--Apple-Mail=_6F02D73A-D315-4927-AA89-45FB59E93E59
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFZQeqfpIg59Q01vtYRAhjMAKDd/0t0eslzr1jFNtIL+WpvFck+nwCfSRCo
BV1UNy3ob7WBzmV4V/ERaqg=
=Scj4
-----END PGP SIGNATURE-----

--Apple-Mail=_6F02D73A-D315-4927-AA89-45FB59E93E59--
