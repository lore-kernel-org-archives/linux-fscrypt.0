Return-Path: <SRS0=S9Pi=RQ=nod.at=richard@kernel.org>
From: Richard Weinberger <richard@nod.at>
Subject: Re: overlayfs vs. fscrypt
Date: Wed, 13 Mar 2019 17:24:10 +0100
Message-ID: <2287057.GpIlh1E3ca@blindfold>
In-Reply-To: <1552493632.3022.17.camel@HansenPartnership.com>
References: <4603533.ZIfxmiEf7K@blindfold> <20190313155144.GC703@sol.localdomain> <1552493632.3022.17.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Eric Biggers <ebiggers@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Amir Goldstein <amir73il@gmail.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Lawrence <paullawrence@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Am Mittwoch, 13. M=E4rz 2019, 17:13:52 CET schrieb James Bottomley:
> > What do you mean by "containment breaches by other tenants"?  Note
> > that while the key is added, fscrypt doesn't prevent access to the
> > encrypted files.
>=20
> You mean it's not multiuser safe?  Even if user a owns the key they add
> user b can still see the decrypted contents?

If user a reads the file before, yes. Then user b sees it because the conte=
nts
got cached.
That's why you need still make sure that your access control is sane.

Thanks,
//richard
