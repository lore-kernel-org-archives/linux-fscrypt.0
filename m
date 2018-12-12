Return-Path: <SRS0=xCEI=OV=thunk.org=tytso@kernel.org>
Date: Tue, 11 Dec 2018 21:40:14 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH] fscrypt: remove CRYPTO_CTR dependency
Message-ID: <20181212024014.GE4464@thunk.org>
References: <20180905192400.71160-1-ebiggers@kernel.org>
 <CAKv+Gu8=dDk+bes8O7oOQ3zTgPHyVi49-gwH1btwdys-vgfyqg@mail.gmail.com>
 <20181204234506.GD70682@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181204234506.GD70682@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: linux-fscrypt@vger.kernel.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Jaegeuk Kim <jaegeuk@kernel.org>, "open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Dec 04, 2018 at 03:45:07PM -0800, Eric Biggers wrote:
> On Thu, Sep 06, 2018 at 12:43:41PM +0200, Ard Biesheuvel wrote:
> > On 5 September 2018 at 21:24, Eric Biggers <ebiggers@kernel.org> wrote:
> > > From: Eric Biggers <ebiggers@google.com>
> > >
> > > fscrypt doesn't use the CTR mode of operation for anything, so there's
> > > no need to select CRYPTO_CTR.  It was added by commit 71dea01ea2ed
> > > ("ext4 crypto: require CONFIG_CRYPTO_CTR if ext4 encryption is
> > > enabled").  But, I've been unable to identify the arm64 crypto bug it
> > > was supposedly working around.
> > >
> > > I suspect the issue was seen only on some old Android device kernel
> > > (circa 3.10?).  So if the fix wasn't mistaken, the real bug is probably
> > > already fixed.  Or maybe it was actually a bug in a non-upstream crypto
> > > driver.
> > >
> > > So, remove the dependency.  If it turns out there's actually still a
> > > bug, we'll fix it properly.
> > >
> > > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > 
> > Acked-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Thanks, applied.

					- Ted
