Return-Path: <SRS0=SOoo=NC=esat.kuleuven.be=tomer.ashur@kernel.org>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <CA+_SqcDszvqfH7qvEyi8QW2RqkA1kpV6L7VWxhtw5Ogzeovhbg@mail.gmail.com>
From: Tomer Ashur <tomer.ashur@esat.kuleuven.be>
Message-ID: <2395454e-a0dc-408f-4138-9d15ab5f20b8@esat.kuleuven.be>
Date: Mon, 22 Oct 2018 12:19:16 +0200
MIME-Version: 1.0
In-Reply-To: <CA+_SqcDszvqfH7qvEyi8QW2RqkA1kpV6L7VWxhtw5Ogzeovhbg@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="9ai7PlPRh0rVaoqg57mToYswWl1CqmkA8"
To: Paul Crowley <paulcrowley@google.com>, Jason@zx2c4.com
Cc: ebiggers@kernel.org, linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, samuel.c.p.neves@gmail.com
List-ID: <linux-fscrypt@vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9ai7PlPRh0rVaoqg57mToYswWl1CqmkA8
Content-Type: multipart/mixed; boundary="Vrii3DnuM659TRJa8ZDF3dRbmeC5vWHNE";
 protected-headers="v1"
X-Kuleuven: This mail passed the K.U.Leuven mailcluster
From: Tomer Ashur <tomer.ashur@esat.kuleuven.be>
To: Paul Crowley <paulcrowley@google.com>, Jason@zx2c4.com
Cc: ebiggers@kernel.org, linux-crypto@vger.kernel.org,
 linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
 Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>,
 samuel.c.p.neves@gmail.com
Message-ID: <2395454e-a0dc-408f-4138-9d15ab5f20b8@esat.kuleuven.be>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <CA+_SqcDszvqfH7qvEyi8QW2RqkA1kpV6L7VWxhtw5Ogzeovhbg@mail.gmail.com>
In-Reply-To: <CA+_SqcDszvqfH7qvEyi8QW2RqkA1kpV6L7VWxhtw5Ogzeovhbg@mail.gmail.com>

--Vrii3DnuM659TRJa8ZDF3dRbmeC5vWHNE
Content-Type: text/html; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

<html style=3D"direction: ltr;">
  <head>
    <meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dutf=
-8">
    <style type=3D"text/css">body p { margin-bottom: 0cm; margin-top: 0pt=
; } </style>
  </head>
  <body bidimailui-charset-is-forced=3D"true" style=3D"direction: ltr;"
    text=3D"#000000" bgcolor=3D"#FFFFFF">
    <br>
    <br>
    <div class=3D"moz-cite-prefix">On 19-Oct-18 8:19 PM, Paul Crowley
      wrote:<br>
    </div>
    <blockquote type=3D"cite"
cite=3D"mid:CA+_SqcDszvqfH7qvEyi8QW2RqkA1kpV6L7VWxhtw5Ogzeovhbg@mail.gmai=
l.com">
      <pre wrap=3D"">I would prefer not to wait. Unlike a new primitive w=
hose strength can
only be known through attempts at cryptanalysis, Adiantum is a
construction based on
well-understood and trusted primitives; it is secure if the proof
accompanying it is correct. Given that (outside competitions or
standardization efforts) no-one ever issues public statements that
they think algorithms or proofs are good, what I'm expecting from
academia is silence <span class=3D"moz-smiley-s1" title=3D":)"><span>:)</=
span></span> The most we could hope for would be getting the
paper accepted at a conference, and we're pursuing that but there's a
good chance that won't happen simply because it's not very novel. It
basically takes existing ideas and applies them using a stream cipher
instead of a block cipher, and a faster hashing mode; it's also a
small update from HPolyC. I've had some private feedback that the
proof seems correct, and that's all I'm expecting to get.</pre>
    </blockquote>
    I tend to agree with Paul on this point. This is a place where
    academia needs to improve. An attempt to do so is the <i>Real World
      Crypto</i> conference (RWC; <a class=3D"moz-txt-link-freetext" href=
=3D"https://rwc.iacr.org/2019/">https://rwc.iacr.org/2019/</a>), but the
    deadline for submissions was October 1st. For HpolyC I asked a few
    people to take a look at the construction and the consensus was that
    it seems secure but that the proof style makes it hard to verify. I
    haven't had the time yet to read the Adiantum paper (and I'm not a <i=
>provable
      security </i>person anyway) <i></i>but I suppose Paul took the
    comments he received on this into account and that's the best we can
    hope for. Academia simply moves in a different pace and has
    different incentives. <br>
    <br>
    Tomer<br>
  </body>
</html>


--Vrii3DnuM659TRJa8ZDF3dRbmeC5vWHNE--

--9ai7PlPRh0rVaoqg57mToYswWl1CqmkA8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEEAzRy0e5O0UZdzbNUni5oBnW4MLcFAlvNpCQACgkQni5oBnW4
MLcM7Af/ROPvDKB/ItX8lXjv0t52A7jJRt9NjWLsfRxsqUKl/gLJ2eE+d6wzgh+b
2IE7bZmFv/X2GO5v96YzBp/mrC2jun4gsvcHPPLFdaOw+VLx3KH+i9L/Qo/BM39E
hlJCuuTl89cnqwnMyxcKho8k/Tdhm4nTPBfLIga6TyGKcNgTKuxdv2sLE+PYO+rS
L1MDDftrCkhk8EQaA4m2kOoRBXmLKnTyOJjMoHPiIGSmKfUDlIJBsA2gO6yxd0N8
hKdB9HAnxfu+5YIcf7gTAeUa9Vg75IGwHGSkhokQJSyrkF/spSjltGeZ8A5meixD
/tq3cZA6nc+gKzAONSFS72kKTWoHjA==
=aU+E
-----END PGP SIGNATURE-----

--9ai7PlPRh0rVaoqg57mToYswWl1CqmkA8--
