Return-Path: <SRS0=SOoo=NC=esat.kuleuven.be=tomer.ashur@kernel.org>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
From: Tomer Ashur <tomer.ashur@esat.kuleuven.be>
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <CA+_SqcDszvqfH7qvEyi8QW2RqkA1kpV6L7VWxhtw5Ogzeovhbg@mail.gmail.com>
 <2395454e-a0dc-408f-4138-9d15ab5f20b8@esat.kuleuven.be>
Message-ID: <ebd9d96e-4a2c-528d-b8e8-67907f2a8be0@esat.kuleuven.be>
Date: Mon, 22 Oct 2018 13:20:51 +0200
MIME-Version: 1.0
In-Reply-To: <2395454e-a0dc-408f-4138-9d15ab5f20b8@esat.kuleuven.be>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="ZCGfLrfVDy08N23smGRyOzruVLw2UfQ7R"
To: Paul Crowley <paulcrowley@google.com>, Jason@zx2c4.com
Cc: ebiggers@kernel.org, linux-crypto@vger.kernel.org, linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>, Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>, samuel.c.p.neves@gmail.com
List-ID: <linux-fscrypt@vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ZCGfLrfVDy08N23smGRyOzruVLw2UfQ7R
Content-Type: multipart/mixed; boundary="qhDwaa5xkREPzW5outG79AHHk1KOV8i1d";
 protected-headers="v1"
X-Kuleuven: This mail passed the K.U.Leuven mailcluster
From: Tomer Ashur <tomer.ashur@esat.kuleuven.be>
To: Paul Crowley <paulcrowley@google.com>, Jason@zx2c4.com
Cc: ebiggers@kernel.org, linux-crypto@vger.kernel.org,
 linux-fscrypt@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
 Greg Kaiser <gkaiser@google.com>, Michael Halcrow <mhalcrow@google.com>,
 samuel.c.p.neves@gmail.com
Message-ID: <ebd9d96e-4a2c-528d-b8e8-67907f2a8be0@esat.kuleuven.be>
Subject: Re: [RFC PATCH v2 00/12] crypto: Adiantum support
References: <20181015175424.97147-1-ebiggers@kernel.org>
 <CAHmME9p1aiqWZ4+viaLscO8+qmixdVhMA1MAtMAFEHPG36DcPg@mail.gmail.com>
 <CA+_SqcDszvqfH7qvEyi8QW2RqkA1kpV6L7VWxhtw5Ogzeovhbg@mail.gmail.com>
 <2395454e-a0dc-408f-4138-9d15ab5f20b8@esat.kuleuven.be>
In-Reply-To: <2395454e-a0dc-408f-4138-9d15ab5f20b8@esat.kuleuven.be>

--qhDwaa5xkREPzW5outG79AHHk1KOV8i1d
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US

> On 19-Oct-18 8:19 PM, Paul Crowley wrote:
>> I would prefer not to wait. Unlike a new primitive whose strength can
>> only be known through attempts at cryptanalysis, Adiantum is a
>> construction based on
>> well-understood and trusted primitives; it is secure if the proof
>> accompanying it is correct. Given that (outside competitions or
>> standardization efforts) no-one ever issues public statements that
>> they think algorithms or proofs are good, what I'm expecting from
>> academia is silence :) The most we could hope for would be getting the=

>> paper accepted at a conference, and we're pursuing that but there's a
>> good chance that won't happen simply because it's not very novel. It
>> basically takes existing ideas and applies them using a stream cipher
>> instead of a block cipher, and a faster hashing mode; it's also a
>> small update from HPolyC. I've had some private feedback that the
>> proof seems correct, and that's all I'm expecting to get.
>
I tend to agree with Paul on this point. This is a place where academia
needs to improve. An attempt to do so is the Real World Crypto
conference (RWC; https://rwc.iacr.org/2019/), but the deadline for
submissions was October 1st. For HpolyC I asked a few people to take a
look at the construction and the consensus was that it seems secure but
that the proof style makes it hard to verify. I haven't had the time yet
to read the Adiantum paper (and I'm not a provable security person
anyway) but I suppose Paul took the comments he received on this into
account and that's the best we can hope for. Academia simply moves in a
different pace and has different incentives.

=C2=A0Tomer


--qhDwaa5xkREPzW5outG79AHHk1KOV8i1d--

--ZCGfLrfVDy08N23smGRyOzruVLw2UfQ7R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEEAzRy0e5O0UZdzbNUni5oBnW4MLcFAlvNspMACgkQni5oBnW4
MLcIRQf/SqN6tRXG9BL2vpVuxnoCUhohnGRKU41x21akRIDoEOt7MkJBntNIpJ7J
byG2eTv6FO7CB5J/6Ecc9S8rODO3rKOHTaV3wUNzH7xd6EQFEqI9i3ScBDWCTI7n
3QPBO25rrGCaWj+cMNBeqzjU6i7Sg3EBE6EYxZZoFnhOBIVpbcGFVXuwPY5Gx5Qt
/9tA9XrzPbRhCBoCmgNelIcZOBFOhWEmWZA/cdXNaTzAKgDEkBPmMmVakdb32QVs
DftFGaug1CuYWeDPScQYkthyIpiOV78YrjX7UI0PluD/55VqUOVYsBNy90uBG9eC
rUhnw6qW7/nVoEyC8tihQT6H6tEKMQ==
=HeL5
-----END PGP SIGNATURE-----

--ZCGfLrfVDy08N23smGRyOzruVLw2UfQ7R--
