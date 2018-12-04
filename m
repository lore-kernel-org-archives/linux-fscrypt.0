Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:45984 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725875AbeLDXpJ (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Tue, 4 Dec 2018 18:45:09 -0500
Date: Tue, 4 Dec 2018 15:45:07 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH] fscrypt: remove CRYPTO_CTR dependency
Message-ID: <20181204234506.GD70682@gmail.com>
References: <20180905192400.71160-1-ebiggers@kernel.org>
 <CAKv+Gu8=dDk+bes8O7oOQ3zTgPHyVi49-gwH1btwdys-vgfyqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKv+Gu8=dDk+bes8O7oOQ3zTgPHyVi49-gwH1btwdys-vgfyqg@mail.gmail.com>
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y . Ts'o" <tytso@mit.edu>, linux-fscrypt@vger.kernel.org
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jaegeuk Kim <jaegeuk@kernel.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Sep 06, 2018 at 12:43:41PM +0200, Ard Biesheuvel wrote:
> On 5 September 2018 at 21:24, Eric Biggers <ebiggers@kernel.org> wrote:
> > From: Eric Biggers <ebiggers@google.com>
> >
> > fscrypt doesn't use the CTR mode of operation for anything, so there's
> > no need to select CRYPTO_CTR.  It was added by commit 71dea01ea2ed
> > ("ext4 crypto: require CONFIG_CRYPTO_CTR if ext4 encryption is
> > enabled").  But, I've been unable to identify the arm64 crypto bug it
> > was supposedly working around.
> >
> > I suspect the issue was seen only on some old Android device kernel
> > (circa 3.10?).  So if the fix wasn't mistaken, the real bug is probably
> > already fixed.  Or maybe it was actually a bug in a non-upstream crypto
> > driver.
> >
> > So, remove the dependency.  If it turns out there's actually still a
> > bug, we'll fix it properly.
> >
> > Signed-off-by: Eric Biggers <ebiggers@google.com>
> 
> Acked-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> 
> This may be related to
> 
> 11e3b725cfc2 crypto: arm64/aes-blk - honour iv_out requirement in CBC
> and CTR modes
> 
> given that the commit in question mentions CTS. How it actually works
> around the issue is unclear to me, though.
> 
> 
> 
> 
> > ---
> >  fs/crypto/Kconfig | 1 -
> >  1 file changed, 1 deletion(-)
> >
> > diff --git a/fs/crypto/Kconfig b/fs/crypto/Kconfig
> > index 02b7d91c92310..284b589b4774d 100644
> > --- a/fs/crypto/Kconfig
> > +++ b/fs/crypto/Kconfig
> > @@ -6,7 +6,6 @@ config FS_ENCRYPTION
> >         select CRYPTO_ECB
> >         select CRYPTO_XTS
> >         select CRYPTO_CTS
> > -       select CRYPTO_CTR
> >         select CRYPTO_SHA256
> >         select KEYS
> >         help
> > --
> > 2.19.0.rc2.392.g5ba43deb5a-goog
> >

Ping.  Ted, can you consider applying this to the fscrypt tree for 4.21?

Thanks,

- Eric
