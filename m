Return-Path: <SRS0=S9Pi=RQ=nod.at=richard@kernel.org>
From: Richard Weinberger <richard@nod.at>
Subject: Re: overlayfs vs. fscrypt
Date: Wed, 13 Mar 2019 23:42:18 +0100
Message-ID: <4098793.CtYQtWW4dM@blindfold>
In-Reply-To: <20190313222610.GF10169@gmail.com>
References: <4603533.ZIfxmiEf7K@blindfold> <15244624.W7e5yEypHC@blindfold> <20190313222610.GF10169@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
To: Eric Biggers <ebiggers@kernel.org>
Cc: Amir Goldstein <amir73il@gmail.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-fscrypt@vger.kernel.org, overlayfs <linux-unionfs@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Lawrence <paullawrence@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

Am Mittwoch, 13. M=E4rz 2019, 23:26:11 CET schrieb Eric Biggers:
> On Wed, Mar 13, 2019 at 09:33:10PM +0100, Richard Weinberger wrote:
> > Am Mittwoch, 13. M=E4rz 2019, 15:26:54 CET schrieb Amir Goldstein:
> > > IMO, the best thing for UBIFS to do would be to modify fscrypt to sup=
port
> > > opting out of the revalidate behavior, IWO, sanitize your hack to an =
API.
> >=20
> > Given the WTF/s rate this thread has, this might me a good option.
> > Actually people already asked me how to disable this feature because
> > they saw no use of it.
> > Being able to delete encrypted files looks good on the feature list but=
 in
> > reality it has very few users but causes confusion, IMHO.
> >=20
> > I propose a new fscrypt_operations flag, FS_CFLG_NO_CRYPT_FNAMES.
> > If this flag is set, a) fscrypt_setup_filename() will return -EPERM if
> > no key is found.
> > And b) __fscrypt_prepare_lookup() will not attach fscrypt_d_ops to the =
dentry.
> >=20
> > Eric, what do you think?
> >=20
> > Thanks,
> > //richard
> >=20
>=20
> What specifically is wrong with supporting the ciphertext "view" of encry=
pted
> directories, and why do you want to opt UBIFS out of it specifically but =
not
> ext4 and f2fs?  (The fscrypt_operations are per-filesystem type, not
> per-filesystem instance, so I assume that's what you had in mind.)  Note =
that we
> can't unconditionally remove it because people need it to delete files wi=
thout
> the key.  We could add a mount option to disable it, but why exactly?

You are right, fscrypt_operations is the wrong structure.
My plan was having it per filesystem instance. So a mount-option seems like
a good option. Of course for all filesystems that support fscrypt, not just=
 UBIFS.

Over the last year I've converted many emebdded systems to fscrypt and it h=
appened
more than once that users, and more importantly, applications got confused =
that
you can mount and walk the filesystem even if you don't have the key loaded=
 yet.
=46or them it felt more natural that you cannot even readdir if you don't h=
ave the key.

In my opinion having such a mount option is useful to match these expectati=
ons.
And it is also useful because you can enable only the features you actually=
 need.
On embedded systems that I have in mind you never delete files without havi=
ng the key
and since fscrypt is used for the whole filesystem you can just recreate it=
 if you
really lost the key.

Thanks,
//richard
