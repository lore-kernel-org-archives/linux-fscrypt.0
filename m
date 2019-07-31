Return-Path: <SRS0=zam+=V4=canb.auug.org.au=sfr@kernel.org>
Date: Wed, 31 Jul 2019 13:05:26 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warnings after merge of the keys tree
Message-ID: <20190731130526.53684e6b@canb.auug.org.au>
In-Reply-To: <20190731014034.GB687@sol.localdomain>
References: <20190730123042.1f17cdd4@canb.auug.org.au>
	<20190730034704.GA1966@sol.localdomain>
	<20190730135216.377a16d5@canb.auug.org.au>
	<20190731014034.GB687@sol.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/Z+JbBgYKmEVCFloWuRyZJGv";
 protocol="application/pgp-signature"; micalg=pgp-sha256
To: Eric Biggers <ebiggers@kernel.org>
Cc: David Howells <dhowells@redhat.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Linux Next Mailing List <linux-next@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

--Sig_/Z+JbBgYKmEVCFloWuRyZJGv
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Tue, 30 Jul 2019 18:40:34 -0700 Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Tue, Jul 30, 2019 at 01:52:16PM +1000, Stephen Rothwell wrote:
> > Hi Eric,
> >=20
> > On Mon, 29 Jul 2019 20:47:04 -0700 Eric Biggers <ebiggers@kernel.org> w=
rote: =20
> > >
> > > On Tue, Jul 30, 2019 at 12:30:42PM +1000, Stephen Rothwell wrote: =20
> > > > +static struct key_acl fsverity_acl =3D {
> > > > +	.usage	=3D REFCOUNT_INIT(1),
> > > > +	.possessor_viewable =3D true,   =20
> > >=20
> > > I don't think .possessor_viewable should be set here, since there's no
> > > KEY_POSSESSOR_ACE(KEY_ACE_VIEW) in the ACL.  David, this bool is supp=
osed to
> > > mean such an entry is present, right?  Is it really necessary, since =
it's
> > > redundant with the ACL itself? =20
> >=20
> > OK, I can take that out of the patch for tomorrow.
> >  =20
> > > Otherwise this looks good, thanks Stephen.  I'll want to remove a few=
 of these
> > > permissions in a separate patch later, but for now we can just keep it
> > > equivalent to the original code as you've done. =20
> >=20
> > Thanks for the review.
>=20
> Hmm, apparently it's not *exactly* equivalent, since the ACL is missing I=
NVAL
> and JOIN permission for the owner, while those were originally granted by=
 SEARCH
> permission.  We don't need those, but just to keep the merge resolution i=
tself
> as boring as possible, can you please use the following to make it equiva=
lent:
>=20
> static struct key_acl fsverity_acl =3D {
> 	.usage	=3D REFCOUNT_INIT(1),
> 	.nr_ace	=3D 2,
> 	.aces =3D {
> 		KEY_POSSESSOR_ACE(KEY_ACE_SEARCH | KEY_ACE_JOIN |
> 				  KEY_ACE_INVAL),
> 		KEY_OWNER_ACE(KEY_ACE_VIEW | KEY_ACE_READ | KEY_ACE_WRITE |
> 			      KEY_ACE_SEARCH | KEY_ACE_SET_SECURITY |
> 			      KEY_ACE_INVAL | KEY_ACE_REVOKE | KEY_ACE_JOIN |
> 			      KEY_ACE_CLEAR),
> 	}
> };

OK, I have fixed up the patch for today (not quite as above, but
equivalently since I am editting a patch and I usually get that
wrong :-))

--=20
Cheers,
Stephen Rothwell

--Sig_/Z+JbBgYKmEVCFloWuRyZJGv
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl1BBXYACgkQAVBC80lX
0GzYpgf/X5Vixn+4ADwkJhXZROfU827npywKt9xRqlT3VLTRl5tkZlG86U1jR5jt
Wz0MlRcm3iSDlADw/vLsDeR2TLsIQDyGKGtXeY5t/Cu0dqFcMH3nf1U5ZqZApQ2U
CXgkFa9wbTgqTTObl5MBEA44m5Jg6//grYmEeKWpfwqIe9O8ZF5M9CncpEHGQSy8
PUE76V3mMynth4/0QwAmqYSnc3y52jEKpK3uOH6m4DmWdDR0A64UwBHbezzGLYVl
m2dU9YwKzv72sTuxHMzQvOt4XuByYdkvXhGXoFehqeQcUuDFsyWSctBbRCMuQKqB
i/7MeQiTlGzkam5WoJNIZTces1KEVw==
=xb3H
-----END PGP SIGNATURE-----

--Sig_/Z+JbBgYKmEVCFloWuRyZJGv--
