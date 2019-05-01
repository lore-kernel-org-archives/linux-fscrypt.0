Return-Path: <SRS0=+nDJ=TB=linux.ibm.com=chandan@kernel.org>
From: Chandan Rajendra <chandan@linux.ibm.com>
Subject: Re: [PATCH V2 02/13] Consolidate "read callbacks" into a new file
Date: Wed, 01 May 2019 18:02:39 +0530
In-Reply-To: <20190430180507.GD48973@gmail.com>
References: <20190428043121.30925-1-chandan@linux.ibm.com> <20190428043121.30925-3-chandan@linux.ibm.com> <20190430180507.GD48973@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="UTF-8"
Message-Id: <8267479.irDUbO2F3m@localhost.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-fscrypt@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, jaegeuk@kernel.org, yuchao0@huawei.com, hch@infradead.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Tuesday, April 30, 2019 11:35:08 PM IST Eric Biggers wrote:
> On Sun, Apr 28, 2019 at 10:01:10AM +0530, Chandan Rajendra wrote:
> > The "read callbacks" code is used by both Ext4 and F2FS. Hence to
> > remove duplicity, this commit moves the code into
> > include/linux/read_callbacks.h and fs/read_callbacks.c.
> >=20
> > The corresponding decrypt and verity "work" functions have been moved
> > inside fscrypt and fsverity sources. With these in place, the read
> > callbacks code now has to just invoke enqueue functions provided by
> > fscrypt and fsverity.
> >=20
> > Signed-off-by: Chandan Rajendra <chandan@linux.ibm.com>
> > ---
> >  fs/Kconfig                     |   4 +
> >  fs/Makefile                    |   4 +
> >  fs/crypto/Kconfig              |   1 +
> >  fs/crypto/bio.c                |  23 ++---
> >  fs/crypto/crypto.c             |  17 +--
> >  fs/crypto/fscrypt_private.h    |   3 +
> >  fs/ext4/ext4.h                 |   2 -
> >  fs/ext4/readpage.c             | 183 +++++----------------------------
> >  fs/ext4/super.c                |   9 +-
> >  fs/f2fs/data.c                 | 148 ++++----------------------
> >  fs/f2fs/super.c                |   9 +-
> >  fs/read_callbacks.c            | 136 ++++++++++++++++++++++++
> >  fs/verity/Kconfig              |   1 +
> >  fs/verity/verify.c             |  12 +++
> >  include/linux/fscrypt.h        |  20 +---
> >  include/linux/read_callbacks.h |  21 ++++
> >  16 files changed, 251 insertions(+), 342 deletions(-)
> >  create mode 100644 fs/read_callbacks.c
> >  create mode 100644 include/linux/read_callbacks.h
> >=20
> > diff --git a/fs/Kconfig b/fs/Kconfig
> > index 97f9eb8df713..03084f2dbeaf 100644
> > --- a/fs/Kconfig
> > +++ b/fs/Kconfig
> > @@ -308,6 +308,10 @@ config NFS_COMMON
> >  	depends on NFSD || NFS_FS || LOCKD
> >  	default y
> > =20
> > +config FS_READ_CALLBACKS
> > +       bool
> > +       default n
> > +
> >  source "net/sunrpc/Kconfig"
> >  source "fs/ceph/Kconfig"
> >  source "fs/cifs/Kconfig"
>=20
> This shouldn't be under the 'if NETWORK_FILESYSTEMS' block, since it has =
nothing
> to do with network filesystems.  When trying to compile this I got:
>=20
> 	WARNING: unmet direct dependencies detected for FS_READ_CALLBACKS
> 	  Depends on [n]: NETWORK_FILESYSTEMS [=3Dn]
> 	  Selected by [y]:
> 	  - FS_ENCRYPTION [=3Dy]
> 	  - FS_VERITY [=3Dy]
>=20
> Perhaps put it just below FS_IOMAP?
>=20
> > diff --git a/fs/Makefile b/fs/Makefile
> > index 9dd2186e74b5..e0c0fce8cf40 100644
> > --- a/fs/Makefile
> > +++ b/fs/Makefile
> > @@ -21,6 +21,10 @@ else
> >  obj-y +=3D	no-block.o
> >  endif
> > =20
> > +ifeq ($(CONFIG_FS_READ_CALLBACKS),y)
> > +obj-y +=3D	read_callbacks.o
> > +endif
> > +
> >  obj-$(CONFIG_PROC_FS) +=3D proc_namespace.o
> > =20
> >  obj-y				+=3D notify/
> > diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
> > index f0de238000c0..163c328bcbd4 100644
> > --- a/fs/crypto/Kconfig
> > +++ b/fs/crypto/Kconfig
> > @@ -8,6 +8,7 @@ config FS_ENCRYPTION
> >  	select CRYPTO_CTS
> >  	select CRYPTO_SHA256
> >  	select KEYS
> > +	select FS_READ_CALLBACKS
> >  	help
> >  	  Enable encryption of files and directories.  This
> >  	  feature is similar to ecryptfs, but it is more memory
>=20
> This selection needs to be conditional on BLOCK.
>=20
> 	select FS_READ_CALLBACKS if BLOCK
>=20
> Otherwise, building without BLOCK and with UBIFS encryption support fails.
>=20
> 	fs/read_callbacks.c: In function =E2=80=98end_read_callbacks=E2=80=99:
> 	fs/read_callbacks.c:34:23: error: storage size of =E2=80=98iter_all=E2=
=80=99 isn=E2=80=99t known
> 	  struct bvec_iter_all iter_all;
> 			       ^~~~~~~~
> 	fs/read_callbacks.c:37:20: error: dereferencing pointer to incomplete ty=
pe =E2=80=98struct buffer_head=E2=80=99
> 	   if (!PageError(bh->b_page))
>=20
> 	[...]
>

I will fix this in the next version of this patchset.

=2D-=20
chandan
