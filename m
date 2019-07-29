Return-Path: <SRS0=rIno=V2=canb.auug.org.au=sfr@kernel.org>
Date: Mon, 29 Jul 2019 15:45:03 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Add fsverity tree to linux-next
Message-ID: <20190729154503.13aed678@canb.auug.org.au>
In-Reply-To: <20190729031226.GA2252@sol.localdomain>
References: <20190729031226.GA2252@sol.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/o/A/oFcwBKxzLJmh1WMQYp.";
 protocol="application/pgp-signature"; micalg=pgp-sha256
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-next@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, "Theodore Y. Ts'o" <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

--Sig_/o/A/oFcwBKxzLJmh1WMQYp.
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Sun, 28 Jul 2019 20:12:26 -0700 Eric Biggers <ebiggers@kernel.org> wrote:
>
> Can you please add the fsverity tree to linux-next?
>=20
>         https://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git#fsverity
>=20
> This branch contains the latest fs-verity patches
> (https://lore.kernel.org/linux-fsdevel/20190722165101.12840-1-ebiggers@ke=
rnel.org/T/#u).
> We are planning a pull request for 5.4.
>=20
> Please use as contacts:
>=20
>         Eric Biggers <ebiggers@kernel.org>
>         Theodore Y. Ts'o <tytso@mit.edu>

Added from tomorrow.

Thanks for adding your subsystem tree as a participant of linux-next.  As
you may know, this is not a judgement of your code.  The purpose of
linux-next is for integration testing and to lower the impact of
conflicts between subsystems in the next merge window.=20

You will need to ensure that the patches/commits in your tree/series have
been:
     * submitted under GPL v2 (or later) and include the Contributor's
        Signed-off-by,
     * posted to the relevant mailing list,
     * reviewed by you (or another maintainer of your subsystem tree),
     * successfully unit tested, and=20
     * destined for the current or next Linux merge window.

Basically, this should be just what you would send to Linus (or ask him
to fetch).  It is allowed to be rebased if you deem it necessary.

--=20
Cheers,
Stephen Rothwell=20
sfr@canb.auug.org.au

--Sig_/o/A/oFcwBKxzLJmh1WMQYp.
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0+h98ACgkQAVBC80lX
0GzVDgf/d55c2rZLDeEKeui7XemWo7U4YCJZVQsO2Ye1k4OURh8KuPB4OHFAxnrm
FXjilOcrXCqrXaNyoo4xaRfy2oZesdGslLLxjZL8Jnf6DLm5sxbA/JbxR+95wMkH
O4MxF5R7r5SbzzTt7j1DGlfn5SGW7xkNHmOPhurdtyyqq0J5ag6rk+U/nNn2TpAM
eZ9C+mJrmjIage8ogA2P8XGWZOU6nNJs+4nQ1pB79MiJyK9IkPJBH+dpC+TG9Rpy
Z6Z49aJa1DSBlM+FX2kRCpRlkBwsVg5yBDzYjyk6J5ODYInzCpdHsCXTjM2nvmST
+qr2gMk47+PWDhcI9yomBWndRIdLwg==
=p76q
-----END PGP SIGNATURE-----

--Sig_/o/A/oFcwBKxzLJmh1WMQYp.--
