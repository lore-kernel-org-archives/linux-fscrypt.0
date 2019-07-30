Return-Path: <SRS0=ppIH=V3=canb.auug.org.au=sfr@kernel.org>
Date: Tue, 30 Jul 2019 13:52:16 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warnings after merge of the keys tree
Message-ID: <20190730135216.377a16d5@canb.auug.org.au>
In-Reply-To: <20190730034704.GA1966@sol.localdomain>
References: <20190730123042.1f17cdd4@canb.auug.org.au>
	<20190730034704.GA1966@sol.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/pz/0EQPg5Bro5FDVtffXc5m";
 protocol="application/pgp-signature"; micalg=pgp-sha256
To: Eric Biggers <ebiggers@kernel.org>
Cc: David Howells <dhowells@redhat.com>, "Theodore Y. Ts'o" <tytso@mit.edu>, Linux Next Mailing List <linux-next@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

--Sig_/pz/0EQPg5Bro5FDVtffXc5m
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Mon, 29 Jul 2019 20:47:04 -0700 Eric Biggers <ebiggers@kernel.org> wrote:
>
> On Tue, Jul 30, 2019 at 12:30:42PM +1000, Stephen Rothwell wrote:
> > +static struct key_acl fsverity_acl =3D {
> > +	.usage	=3D REFCOUNT_INIT(1),
> > +	.possessor_viewable =3D true, =20
>=20
> I don't think .possessor_viewable should be set here, since there's no
> KEY_POSSESSOR_ACE(KEY_ACE_VIEW) in the ACL.  David, this bool is supposed=
 to
> mean such an entry is present, right?  Is it really necessary, since it's
> redundant with the ACL itself?

OK, I can take that out of the patch for tomorrow.

> Otherwise this looks good, thanks Stephen.  I'll want to remove a few of =
these
> permissions in a separate patch later, but for now we can just keep it
> equivalent to the original code as you've done.

Thanks for the review.

> We'll have the same problem in fs/crypto/ in a week or two if/when I apply
> another patch series.  For that one I'll send you a merge resolution so y=
ou
> don't have to do it yourself...

That will be great, thanks.

--=20
Cheers,
Stephen Rothwell

--Sig_/pz/0EQPg5Bro5FDVtffXc5m
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0/vvAACgkQAVBC80lX
0Gxv3wf+OkCUtz8STSIUcFmQ7bpkopnYRpQOOUQfrUv48mAsFvT1y18ykC1U/dRh
Ukfl0lLZvqQgwWKBTSOjPj1KSgemYTqa54L7I41N6M1FAd7QVex3R0aAu89FLByp
jY69OpZjtiEFjst2zO/FO0jIAbt5bWrINwLJ75J/pwFLqN4ZifDwkBm4Z3kNntKc
7LgyWXZ9EnoUapU1j+eP/TlpZSp7E63itvOrXdvmpKzVDOwgt8HjYPJQqVIGx7iF
4xr/pJYJo8rskEByhC9SQk8mJRGJmGnnSM4NN/Bvv55w7oJKLxXTfK9XMj+hGvNn
o1e8IX8TWHJGL4xYkacHch5Qys7JgA==
=lCUr
-----END PGP SIGNATURE-----

--Sig_/pz/0EQPg5Bro5FDVtffXc5m--
