Return-Path: <SRS0=kD35=RS=nod.at=richard@kernel.org>
From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 4/4] ubifs: Implement new mount option, fscrypt_key_required
Date: Fri, 15 Mar 2019 08:48:10 +0100
Message-ID: <3651600.xvQHXhhOD0@blindfold>
In-Reply-To: <20190314230702.GE6482@mit.edu>
References: <CAJfpegvX4ANfso-Jn1zaB+m4Q_0eK9i-+MCJ+sTH5QzD3PZFMQ@mail.gmail.com> <1957441.Hty6t2mpXG@blindfold> <20190314230702.GE6482@mit.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
To: Theodore Ts'o <tytso@mit.edu>
Cc: Eric Biggers <ebiggers@kernel.org>, linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org, jaegeuk@kernel.org, linux-unionfs@vger.kernel.org, miklos@szeredi.hu, amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, paullawrence@google.com
List-ID: <linux-fscrypt@vger.kernel.org>

Ted,

Am Freitag, 15. M=E4rz 2019, 00:07:02 CET schrieb Theodore Ts'o:
> Richard --- stepping back for a moment, in your use case, are you
> assuming that the encryption key is always going to be present while
> the system is running?

it is not a hard requirement, it is something what is common on embedded
systems that utilize UBIFS and fscrypt.

> Ubifs can't use dm-crypt, since it doesn't have a block device, but if
> you could, is much more like dm-crypt, in that you have the key
> *before* the file system is mounted, and you don't really expect the
> key to ever be expunged from the system while it is mounted?
>=20
> If that's true, maybe the real mismatch is in using fscrypt in the
> first place --- and in fact, something where you encrypt everything,
> including the file system metadata (ala dm-crypt), would actually give
> you much better security properties.

Well, fscrypt was chosen as UBIFS encryption backend because per-file encry=
ption
with derived keys makes a lot of sense.
Also the implementation was not super hard, David and I weren't keen to rei=
nvent
dm-crypt f=FCr UBI/MTD.

That said, I'm happy with fscrypt, it works well in production.
But being not able to use UBIFS as lower dir on overlayfs hurts.
On embedded systems where the key is always present the proposed hack works
fine. If we can get overlayfs work without that I'll be more than happy.

Thanks,
//richard
