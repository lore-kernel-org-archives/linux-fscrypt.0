Return-Path: <SRS0=nqu/=RZ=nod.at=richard@kernel.org>
From: Richard Weinberger <richard@nod.at>
Subject: Re: [RFC PATCH v3 07/18] fscrypt: add FS_IOC_ADD_ENCRYPTION_KEY ioctl
Date: Fri, 22 Mar 2019 23:02:49 +0100
Message-ID: <4190811.5ckf3pJJgb@blindfold>
In-Reply-To: <20190318230830.GA40545@gmail.com>
References: <20190220065249.32099-1-ebiggers@kernel.org> <20190221184203.GB140206@gmail.com> <20190318230830.GA40545@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, Satya Tangirala <satyat@google.com>, "open list:ABI/API" <linux-api@vger.kernel.org>, linux-f2fs-devel@lists.sourceforge.net, keyrings@vger.kernel.org, linux-mtd@lists.infradead.org, linux-crypto@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Paul Crowley <paulcrowley@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Ericm

Am Dienstag, 19. M=E4rz 2019, 00:08:31 CET schrieb Eric Biggers:
> I tried using sb->s_bdi->name, but it's still "ubifs" for all UBIFS files=
ystems.

hmpf.
=20
> Perhaps there's a way you can make ->s_id for UBIFS unique?  There are al=
ready
> existing places that log ->s_id, so perhaps you should do it anyway regar=
dless
> of this patchset?

Yes, let me implement that.
ubifs does:
super_setup_bdi_name(sb, "ubifs_%d_%d", c->vi.ubi_num, c->vi.vol_id);

So, I try to set ->s_id also to ubifs_%d_%d.

> > >=20
> > > > Note that the keyring name isn't particularly important, since the =
ioctls will
> > > > work regardless.  But we might as well choose something logical, si=
nce the
> > > > keyring name will still show up in /proc/keys.
> > >=20
> > > I'm not done with reviewing your patches, but will it be possible to =
use keyctl?
> > > For the a unique name is helpful. :)
> > >=20
> >=20
> > Not for adding keys, removing keys, or getting a key's status -- those =
are what
> > the ioctls are for.
> >=20
> > See e.g. the discussion in patch 7 ("fscrypt: add FS_IOC_ADD_ENCRYPTION=
_KEY
> > ioctl") for why the keyrings syscalls are a poor fit for fscrypt.
> >=20
>=20
> Anyway, perhaps I should reconsider whether fscrypt should even use the k=
eyrings
> subsystem at all, even just "internally", as its quirks still leak out a =
bit.
> I'd prefer a nice clean API without any quirks like having to name the ke=
yrings
> and assign SELinux labels to the keys just to make the keyrings subsystem=
 happy.

IMHO the keys subsytem is a good fit. For example for stuff like this one:
https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1945778.html

We use UBIFS on many embedded systems with crypto hardware.

Thanks,
//richard
