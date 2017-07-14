Return-Path: <smueller@chronox.de>
From: Stephan =?ISO-8859-1?Q?M=FCller?= <smueller@chronox.de>
Subject: Re: [PATCH 3/6] fscrypt: use HKDF-SHA512 to derive the per-inode encryption keys
Date: Fri, 14 Jul 2017 17:50:06 +0200
Message-ID: <6581107.6MsbyqD4B1@positron.chronox.de>
In-Reply-To: <20170713181057.GA143898@gmail.com>
References: <20170712210035.51534-1-ebiggers3@gmail.com> <2034167.Brpu2WxA6s@tauon.chronox.de> <20170713181057.GA143898@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
To: Eric Biggers <ebiggers3@gmail.com>
Cc: herbert@gondor.apana.org.au, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Alex Cope <alexcope@google.com>, Eric Biggers <ebiggers@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Am Donnerstag, 13. Juli 2017, 20:10:57 CEST schrieb Eric Biggers:

Hi Eric,

> Hi Stephan,
>=20
> On Thu, Jul 13, 2017 at 04:54:55PM +0200, Stephan M=FCller wrote:
> > Am Mittwoch, 12. Juli 2017, 23:00:32 CEST schrieb Eric Biggers:
> >=20
> > Hi Herbert,
> >=20
> > This patch adds a second KDF to the kernel -- the first is found in the
> > keys subsystem.
> >=20
> > The next KDF that may come in is in the TLS scope.
> >=20
> > Would it make sense to warm up the KDF patches adding generic KDF suppo=
rt
> > to the kernel crypto API that I supplied some time ago? The advantages
> > would be to have one location of KDF implementations and the benefit of
> > the testmgr.
> That may be a good idea.  Looking at the old thread, I share Herbert's
> concern (http://www.spinics.net/lists/linux-crypto/msg21231.html) about
> there likely not being more than one implementation of each KDF algorithm=
=2E=20
> So, perhaps some simple helper functions would be more appropriate.=20
> However, making the KDFs be covered by self-tests would be very nice.

I agree that it is likely that specific KDF implementations may only be use=
d=20
once. But still, I would recommend to maintain those implementation under t=
he=20
crypto API umbrella, as KDFs are cryptographic operations.

>=20
> Also, it seems your patch
> (http://www.spinics.net/lists/linux-crypto/msg21137.html) doesn't allow a
> salt to be passed in.  In order to fully support HKDF, crypto_rng_reset()
> (which as I understand would be the way to invoke the "extract" step) wou=
ld
> somehow need to accept both the input keying material and salt, both of
> which are arbitrary length binary.

I concur with you. I have implemented the HKDF in my libkcapi as well and s=
aw=20
the need for a salt.

Let me work on an update to the KDF patch for the kernel crypto API.

Ciao
Stephan
