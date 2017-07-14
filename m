Return-Path: <adilger@dilger.ca>
Return-Path: <adilger@dilger.ca>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <B17BECD5-98E6-4429-AAFB-454C5DA5BB40@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_252F5455-DDA5-4EA7-BA49-1713ED82BA6A";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 1/6] fscrypt: add v2 encryption context and policy
Date: Fri, 14 Jul 2017 13:08:10 -0700
In-Reply-To: <20170713225838.GA73286@gmail.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com>
 <20170712210035.51534-2-ebiggers3@gmail.com>
 <20170713222944.GA23111@google.com> <20170713225838.GA73286@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: Michael Halcrow <mhalcrow@google.com>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_252F5455-DDA5-4EA7-BA49-1713ED82BA6A
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jul 13, 2017, at 3:58 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
>=20
> Hi Michael,
>=20
> On Thu, Jul 13, 2017 at 03:29:44PM -0700, Michael Halcrow wrote:
>> On Wed, Jul 12, 2017 at 02:00:30PM -0700, Eric Biggers wrote:
>>> From: Eric Biggers <ebiggers@google.com>
>>>=20
>>> Currently, the fscrypt_context (i.e. the encryption xattr) does not
>>> contain a cryptographically secure identifier for the master key's
>>> payload.  Therefore it's not possible to verify that the correct key =
was
>>> supplied, which is problematic in multi-user scenarios.  To make =
this
>>> possible, define a new fscrypt_context version (v2) which includes a
>>> key_hash field, and allow userspace to opt-in to it when setting an
>>> encryption policy by setting fscrypt_policy.version to 2.  For now =
just
>>> zero the new field; a later patch will start setting it for real.
>>=20
>> The main concern that comes to mind is potentially blowing past the
>> inline xattr size limit and allocating a new inode block.  The
>> security benefit probably outweighs that concern in this case.
>>=20
>=20
> The way it adds up now for ext4 is:
>=20
> 128 bytes for base inode
> + 32 bytes for i_extra fields
> + 4 bytes for in-inode xattrs header
> + 20 bytes for encryption xattr header + name
> + 28 bytes for encryption xattr value
> ----------------------------------
> =3D 212 bytes total.
>=20
> By adding the 16-byte 'key_hash' field it grows to 228 bytes total.  =
So it still
> fits in a 256-byte inode, though it's getting closer to the limit.  We =
could
> save 8 bytes by instead using the design where master_key_descriptor =
is extended
> to 16 bytes and redefined as a cryptographically secure hash.  But as =
noted,
> that has some significant disadvantages.
>=20
> Also note that we don't really have to worry about leaving space for a =
SELinux
> xattr anymore because with 256-byte inodes + encryption the SELinux =
xattr is
> already being written to an external block, given that it requires =
about 52-62
> bytes (at least when using Android's SELinux policy; different SELinux =
policies
> may use different values), and 212 + 52 > 256.  So if someone wants =
both xattrs
> in-inode they need to use 512-byte inodes already.

It is probably time to consider changing to a default of 512-byte inodes =
for
larger filesystems anyway.  In our testing, this affected performance =
only by
a couple of percent under normal usage, and avoided a significant =
performance
drop if the xattrs ever fall out of the inode.

Cheers, Andreas






--Apple-Mail=_252F5455-DDA5-4EA7-BA49-1713ED82BA6A
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFZaSSqpIg59Q01vtYRAn4GAJ9XFN3HO0M0XU182bsIKADNJS0DrQCg5Eym
ddQgImO+FcoiHiwybZus14E=
=e7Vp
-----END PGP SIGNATURE-----

--Apple-Mail=_252F5455-DDA5-4EA7-BA49-1713ED82BA6A--
