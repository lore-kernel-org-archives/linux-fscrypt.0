Return-Path: <SRS0=+RYZ=RU=canb.auug.org.au=sfr@kernel.org>
Date: Sun, 17 Mar 2019 16:19:08 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Update fscrypt git URL for linux-next
Message-ID: <20190317161908.03c8d104@canb.auug.org.au>
In-Reply-To: <20190312063422.GA9123@sol.localdomain>
References: <20190312063422.GA9123@sol.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/PM+lqPZUeC0Rhfn2kZHln1/"; protocol="application/pgp-signature"
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

--Sig_/PM+lqPZUeC0Rhfn2kZHln1/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Mon, 11 Mar 2019 23:34:23 -0700 Eric Biggers <ebiggers@kernel.org> wrote:
>
> Hi Stephen, we've updated the location of the fscrypt git tree:
>=20
> Old URL: git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git
> New URL: git://git.kernel.org/pub/scm/fs/fscrypt/fscrypt.git
>=20
> Branch is still "master".
>=20
> MAINTAINERS in mainline has already been updated accordingly.
>=20
> Can you make sure to update the URL for linux-next too?

Done.  I have also updated the URL for the fscrypt-current tree (using
the for-stable branch of the above new URL).  Should I also add you to
the contacts for those trees (currently I only have Ted listed)?

--=20
Cheers,
Stephen Rothwell

--Sig_/PM+lqPZUeC0Rhfn2kZHln1/
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlyN2MwACgkQAVBC80lX
0Gy0qgf9FHSXX5lhSWXaFfRJYkBdmGR2NUgEQxFtlgeeJLiTW4sdm0aI2rFY+NuI
bQ85vVWhGofC/il25fTtPzyrSIkkh6g+Uw6ckznly24qYVgULt3IsWtFXPKT6PR+
AN/s0TC21Lqr2sY8EXPmQAXDxOvbKkZvX0pll92Md46lejoi8gWJ8l7HHSALm7an
kxj/vlqEmLPcokUq9eAMdDXZa0Pk/3GgS4l9Cm1e3YKNJimbX6JbWN7stL/wpMxO
7jPGw2WdmDNfI+x2HoEvnNT58ks9rvixh86sSCqYhJ8NfCzkHhlfU/OKHtGoSI4U
DCWhSdjjugqYnpexodcMkrd3qnkBEw==
=ooid
-----END PGP SIGNATURE-----

--Sig_/PM+lqPZUeC0Rhfn2kZHln1/--
