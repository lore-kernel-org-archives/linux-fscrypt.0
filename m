Return-Path: <adilger@dilger.ca>
Return-Path: <adilger@dilger.ca>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <158B56CD-F458-4ED5-8B26-EB440E1883BD@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_0AAE96E1-1B2E-4400-A149-717A2C1CA204";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 1/3] ext4: require key for truncate(2) of encrypted file
Date: Tue, 13 Jun 2017 22:02:33 -0600
In-Reply-To: <20170614031245.GA605@zzz>
References: <20170613234755.111167-1-ebiggers3@gmail.com>
 <20170613234755.111167-2-ebiggers3@gmail.com>
 <72134F72-718F-4B14-891D-20F2CF781A16@dilger.ca> <20170614031245.GA605@zzz>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_0AAE96E1-1B2E-4400-A149-717A2C1CA204
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jun 13, 2017, at 9:12 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> Hi Andreas,
>=20
> On Tue, Jun 13, 2017 at 06:14:53PM -0600, Andreas Dilger wrote:
>> On Jun 13, 2017, at 5:47 PM, Eric Biggers <ebiggers3@gmail.com> =
wrote:
>>>=20
>>> From: Eric Biggers <ebiggers@google.com>
>>>=20
>>> Currently, filesystems allow truncate(2) on an encrypted file =
without
>>> the encryption key.  However, it's impossible to correctly handle =
the
>>> case where the size being truncated to is not a multiple of the
>>> filesystem block size, because that would require decrypting the =
final
>>> block, zeroing the part beyond i_size, then encrypting the block.
>>>=20
>>> As other modifications to encrypted file contents are prohibited =
without
>>> the key, just prohibit truncate(2) as well, making it fail with =
ENOKEY.
>>=20
>> Out of curiosity, if an encrypted block is zero-filled at the end =
when
>> the key is unavailable, what would happen?  At worst this would =
result
>> in garbage at the end of the file when the zeroes are "decrypted"?
>=20
> Currently ext4 just skips zeroing the final block entirely, which is =
perhaps the
> most reasonable behavior, but it's wrong because it breaks truncate() =
semantics.
> If it did zero the final block on-disk, yes it wouldn't actually be =
zeroes after
> being decrypted, so if the file were to be extended later the extended =
portion
> wouldn't be filled with zeroes, and more importantly even without =
extending, up
> to the last 15 bytes of the file would be corrupted since AES-XTS =
encryption
> operates on 16 byte blocks.  Also, the ciphertext page would likely =
end up in
> the pagecache, which is supposed to contain the plaintext.  So if the =
file were
> read later (which requires the key), up to the last PAGE_SIZE bytes of =
the file
> would appear as garbage.

It wouldn't be bad to add this kind of explanation to the commit =
message, so
that it is clear why simple zeroing of the partial block doesn't work.

>> Is it possible to unlink files if they are encrypted without the key =
(if
>> the user has permission to write to the directory)?
>=20
> Yes, that's supported.
>=20
>> Does file unlink result in the per-file crypto key being erased in =
the
>> inode, or is the inode just marked unused but not overwritten?  One =
of
>> the desirable features of per-file crypto is "secure erase" so that =
once
>> the inode is unlinked the crypto key is gone and there is no way to =
decrypt
>> the data after the fact, even if the filesystem/user key is later =
recovered.
>> If the per-file key is still sitting in the inode, then it may be =
possible
>> to decrypt the data long after the file was deleted if the key is =
later
>> compromised and the inode+data blocks were not re-used.
>=20
> I assume you're talking about the key derivation nonce in the =
encryption xattr
> (which is stored on-disk and is not really a "key"; although it's used =
as an
> AES-ECB key in derive_key_aes(), that's really an implementation =
detail, and the
> key derivation algorithm could/should be replaced with something less
> idiosyncratic like an HKDF).  This is a completely separate issue, but =
no, as
> far as I know we aren't securely erasing the nonce following a file =
deletion so
> that someone with access to both the raw disk and the master key can =
no longer
> derive the per-file key.  It's a good idea, though, and I think it =
should be
> done if practical.  Note, though, that the xattr may be stored in an =
external
> xattr block, and it also may have moved around over time --- so it may =
be
> necessary to zero the whole inode and xattr block.

While it is true that the crypto xattr _could_ exist in the external =
xattr block,
this is fairly unlikely since this xattr is created first, so it is most =
likely
to be in the inode xattr space.  Also, it is common that there is no =
external
xattr block.  In most cases, setting the xattr with the same size will =
overwrite
it in-place rather than try to allocate new space for it, so this should =
be
relatively easy to implement.

In the end, trying to zero this xattr and failing is no worse than not =
doing it
at all, so I think it reasonable to try.  It shouldn't result in any =
extra I/O,
since the inode always needs to be written out anyway to store the dtime =
and
nlink =3D 0.

Cheers, Andreas






--Apple-Mail=_0AAE96E1-1B2E-4400-A149-717A2C1CA204
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFZQLVbpIg59Q01vtYRAgxzAKDYcwGFh8xVu5gBfakJDSr6SuUG8ACg3UGi
FfQ4+R2VRdauEvJKdzv+Dks=
=oVGC
-----END PGP SIGNATURE-----

--Apple-Mail=_0AAE96E1-1B2E-4400-A149-717A2C1CA204--
