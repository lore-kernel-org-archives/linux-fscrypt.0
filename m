Return-Path: <SRS0=CZeC=SU=nod.at=richard@kernel.org>
From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] ubifs: remove unnecessary #ifdef around fscrypt_ioctl_get_policy()
Date: Thu, 18 Apr 2019 21:31:22 +0200
Message-ID: <17887943.qBNreu9ReB@blindfold>
In-Reply-To: <20190418192953.GB20640@gmail.com>
References: <20190315205503.195400-1-ebiggers@kernel.org> <CAFLxGvx3M61E1+Ts38BYRYu93QzmH=XMWoYYrFHTqWXUM7zREg@mail.gmail.com> <20190418192953.GB20640@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
To: Eric Biggers <ebiggers@kernel.org>, linux-mtd@lists.infradead.org
Cc: linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Am Donnerstag, 18. April 2019, 21:29:53 CEST schrieb Eric Biggers:
> On Fri, Mar 15, 2019 at 10:08:02PM +0100, Richard Weinberger wrote:
> > On Fri, Mar 15, 2019 at 9:55 PM Eric Biggers <ebiggers@kernel.org> wrote:
> > >
> > > From: Eric Biggers <ebiggers@google.com>
> > >
> > > When !CONFIG_FS_ENCRYPTION, fscrypt_ioctl_get_policy() is already
> > > stubbed out to return -EOPNOTSUPP, so the extra #ifdef is not needed.
> > >
> > > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > > ---
> > >  fs/ubifs/ioctl.c | 7 +------
> > >  1 file changed, 1 insertion(+), 6 deletions(-)
> > >
> > > diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
> > > index 82e4e6a30b04..cd1d4212fc45 100644
> > > --- a/fs/ubifs/ioctl.c
> > > +++ b/fs/ubifs/ioctl.c
> > > @@ -205,13 +205,8 @@ long ubifs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
> > >                 return -EOPNOTSUPP;
> > >  #endif
> > >         }
> > > -       case FS_IOC_GET_ENCRYPTION_POLICY: {
> > > -#ifdef CONFIG_FS_ENCRYPTION
> > > +       case FS_IOC_GET_ENCRYPTION_POLICY:
> > >                 return fscrypt_ioctl_get_policy(file, (void __user *)arg);
> > > -#else
> > > -               return -EOPNOTSUPP;
> > > -#endif
> > > -       }
> > >
> > >         default:
> > >                 return -ENOTTY;
> > 
> > Thanks for that one too. :-)
> > 
> 
> Richard, can you take this through the ubifs tree for 5.2?

Sure. Queued for 5.2. :-)

Thanks,
//richard
