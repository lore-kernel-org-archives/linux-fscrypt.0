Date: Thu, 18 Apr 2019 12:29:53 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] ubifs: remove unnecessary #ifdef around
 fscrypt_ioctl_get_policy()
Message-ID: <20190418192953.GB20640@gmail.com>
References: <20190315205503.195400-1-ebiggers@kernel.org>
 <CAFLxGvx3M61E1+Ts38BYRYu93QzmH=XMWoYYrFHTqWXUM7zREg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFLxGvx3M61E1+Ts38BYRYu93QzmH=XMWoYYrFHTqWXUM7zREg@mail.gmail.com>
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Mar 15, 2019 at 10:08:02PM +0100, Richard Weinberger wrote:
> On Fri, Mar 15, 2019 at 9:55 PM Eric Biggers <ebiggers@kernel.org> wrote:
> >
> > From: Eric Biggers <ebiggers@google.com>
> >
> > When !CONFIG_FS_ENCRYPTION, fscrypt_ioctl_get_policy() is already
> > stubbed out to return -EOPNOTSUPP, so the extra #ifdef is not needed.
> >
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > ---
> >  fs/ubifs/ioctl.c | 7 +------
> >  1 file changed, 1 insertion(+), 6 deletions(-)
> >
> > diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
> > index 82e4e6a30b04..cd1d4212fc45 100644
> > --- a/fs/ubifs/ioctl.c
> > +++ b/fs/ubifs/ioctl.c
> > @@ -205,13 +205,8 @@ long ubifs_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
> >                 return -EOPNOTSUPP;
> >  #endif
> >         }
> > -       case FS_IOC_GET_ENCRYPTION_POLICY: {
> > -#ifdef CONFIG_FS_ENCRYPTION
> > +       case FS_IOC_GET_ENCRYPTION_POLICY:
> >                 return fscrypt_ioctl_get_policy(file, (void __user *)arg);
> > -#else
> > -               return -EOPNOTSUPP;
> > -#endif
> > -       }
> >
> >         default:
> >                 return -ENOTTY;
> 
> Thanks for that one too. :-)
> 
> -- 
> Thanks,
> //richard

Richard, can you take this through the ubifs tree for 5.2?

- Eric
