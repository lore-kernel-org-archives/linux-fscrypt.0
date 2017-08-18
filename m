Return-Path: <adilger@dilger.ca>
Return-Path: <adilger@dilger.ca>
From: Andreas Dilger <adilger@dilger.ca>
Message-Id: <8EA94C5A-A3F7-48BC-91BE-3C0BD17D7927@dilger.ca>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_9142F810-BF1E-4FCD-B59A-DFBC65DA2F9F";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] fscrypt: add a documentation file for filesystem-level
 encryption
Date: Fri, 18 Aug 2017 15:06:52 -0600
In-Reply-To: <20170818194730.61575-1-ebiggers3@gmail.com>
References: <20170818194730.61575-1-ebiggers3@gmail.com>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: linux-fscrypt@vger.kernel.org, linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Richard Weinberger <richard@nod.at>, Michael Halcrow <mhalcrow@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>


--Apple-Mail=_9142F810-BF1E-4FCD-B59A-DFBC65DA2F9F
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii

On Aug 18, 2017, at 1:47 PM, Eric Biggers <ebiggers3@gmail.com> wrote:
> +Key hierarchy
> +=============
> +
> +Master Keys
> +-----------
> +
> +Userspace should generate master keys either using a cryptographically
> +secure random number generator, e.g. by reading from ``/dev/urandom``
> +or calling getrandom(), or by using a KDF (Key Derivation Function).
> +Note that whenever a KDF is used to "stretch" a lower-entropy secret
> +such as a passphrase, it is critical that a KDF designed for this
> +purpose be used, such as scrypt, PBKDF2, or Argon2.

One minor suggestion - when generating a master key for a filesystem,
I'd think it is preferable to use /dev/random instead of /dev/urandom
to ensure there is enough entropy.

Cheers, Andreas






--Apple-Mail=_9142F810-BF1E-4FCD-B59A-DFBC65DA2F9F
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iD8DBQFZl1bzpIg59Q01vtYRAiT+AKCc+13VtpBGDFhtCOJ8WDmEkYFxogCgyFGw
iriWUBdsXr50Ehp/uEDHOT8=
=OMjh
-----END PGP SIGNATURE-----

--Apple-Mail=_9142F810-BF1E-4FCD-B59A-DFBC65DA2F9F--
