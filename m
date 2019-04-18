Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:49706 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729641AbfDRT3e (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Thu, 18 Apr 2019 15:29:34 -0400
Date: Thu, 18 Apr 2019 12:29:32 -0700
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] ubifs: remove unnecessary calls to set up directory key
Message-ID: <20190418192930.GA20640@gmail.com>
References: <20190315205432.195263-1-ebiggers@kernel.org>
 <CAFLxGvw1ETyuLf0yV_MqGyTKmUkxLu0vvZLh2QfLgvYExTosWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFLxGvw1ETyuLf0yV_MqGyTKmUkxLu0vvZLh2QfLgvYExTosWQ@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: linux-mtd@lists.infradead.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Mar 15, 2019 at 10:05:59PM +0100, Richard Weinberger wrote:
> On Fri, Mar 15, 2019 at 9:55 PM Eric Biggers <ebiggers@kernel.org> wrote:
> >
> > From: Eric Biggers <ebiggers@google.com>
> >
> > In ubifs_unlink() and ubifs_rmdir(), remove the call to
> > fscrypt_get_encryption_info() that precedes fscrypt_setup_filename().
> > This call was unnecessary, because fscrypt_setup_filename() already
> > tries to set up the directory's encryption key.
> >
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > ---
> >  fs/ubifs/dir.c | 12 ------------
> >  1 file changed, 12 deletions(-)
> >
> > diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
> > index 5767b373a8ff..c3311ea68fe5 100644
> > --- a/fs/ubifs/dir.c
> > +++ b/fs/ubifs/dir.c
> > @@ -792,12 +792,6 @@ static int ubifs_unlink(struct inode *dir, struct dentry *dentry)
> >                 dentry, inode->i_ino,
> >                 inode->i_nlink, dir->i_ino);
> >
> > -       if (ubifs_crypt_is_encrypted(dir)) {
> > -               err = fscrypt_get_encryption_info(dir);
> > -               if (err && err != -ENOKEY)
> > -                       return err;
> > -       }
> > -
> >         err = fscrypt_setup_filename(dir, &dentry->d_name, 1, &nm);
> >         if (err)
> >                 return err;
> > @@ -902,12 +896,6 @@ static int ubifs_rmdir(struct inode *dir, struct dentry *dentry)
> >         if (err)
> >                 return err;
> >
> > -       if (ubifs_crypt_is_encrypted(dir)) {
> > -               err = fscrypt_get_encryption_info(dir);
> > -               if (err && err != -ENOKEY)
> > -                       return err;
> > -       }
> > -
> >         err = fscrypt_setup_filename(dir, &dentry->d_name, 1, &nm);
> >         if (err)
> >                 return err;
> 
> Thanks for the cleanup, Eric!
> 
> -- 
> Thanks,
> //richard

Richard, can you take this through the ubifs tree for 5.2?

- Eric
