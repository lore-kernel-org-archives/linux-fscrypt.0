Return-Path: <ebiggers3@gmail.com>
Date: Wed, 17 Jan 2018 15:44:58 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v2 0/5] ubifs: switch to new fscrypt helper functions
Message-ID: <20180117234458.iw37mht6jtp5gdwn@gmail.com>
References: <20171129204317.91205-1-ebiggers3@gmail.com>
 <CAFLxGvzGeMkm_1HhcFDe4twTGsVHaXvjoM6GezxtCNW+NZw84Q@mail.gmail.com>
 <20180117212354.xrsog7pekzoomq7p@gmail.com>
 <6120539.HEfP5UEqVm@blindfold>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6120539.HEfP5UEqVm@blindfold>
To: Richard Weinberger <richard@nod.at>
Cc: linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>, linux-mtd@lists.infradead.org, Adrian Hunter <adrian.hunter@intel.com>, Artem Bityutskiy <dedekind1@gmail.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jan 17, 2018 at 10:36:12PM +0100, Richard Weinberger wrote:
> Am Mittwoch, 17. Januar 2018, 22:23:54 CET schrieb Eric Biggers:
> > On Wed, Jan 17, 2018 at 10:12:27PM +0100, Richard Weinberger wrote:
> > > On Fri, Jan 5, 2018 at 11:11 PM, Richard Weinberger <richard@nod.at> 
> wrote:
> > > > Eric,
> > > > 
> > > > Am Freitag, 5. Januar 2018, 19:37:44 CET schrieb Eric Biggers:
> > > >> On Wed, Nov 29, 2017 at 12:43:12PM -0800, Eric Biggers wrote:
> > > >> > From: Eric Biggers <ebiggers@google.com>
> > > >> > 
> > > >> > This series switches ubifs to use the fscrypt helper functions for
> > > >> > open/link/rename/lookup/setattr introduced in v4.15.
> > > >> > 
> > > >> > These patches were originally sent in "[PATCH 00/25] fscrypt: add
> > > >> > some
> > > >> > higher-level helper functions".  I've rebased them onto v4.15-rc1.
> > > >> > 
> > > >> > Eric Biggers (5):
> > > >> >   ubifs: switch to fscrypt_file_open()
> > > >> >   ubifs: switch to fscrypt_prepare_link()
> > > >> >   ubifs: switch to fscrypt_prepare_rename()
> > > >> >   ubifs: switch to fscrypt_prepare_lookup()
> > > >> >   ubifs: switch to fscrypt_prepare_setattr()
> > > >> >  
> > > >> >  fs/ubifs/dir.c  | 43 +++++++++++++------------------------------
> > > >> >  fs/ubifs/file.c | 41 ++++-------------------------------------
> > > >> >  2 files changed, 17 insertions(+), 67 deletions(-)
> > > >> 
> > > >> Richard, can you take these for UBIFS for v4.16?
> > > > 
> > > > Yes. Thanks a lot for cleaning this up.
> > > 
> > > FYI, this series has merge conflicts with other fscrypt related
> > > changes that went via Ted into fs/ubifs.
> > 
> > How so?  These apply cleanly to both Linus' tree and to fscrypt/master
> > currently.
> 
> Just checked, the problem is this commit:
> 
> commit 9a2cebc6e2368072490a574eafe0f0747d330bbd
> Author: Eric Biggers <ebiggers@google.com>
> Date:   Fri Jan 5 11:30:03 2018 -0800
> 
>     ubifs: free the encrypted symlink target
> 
> It exists also in my tree. I'll drop it and force push.
> Sorry for messing up, next time I try hard to be more responsive.
> 
> Thanks,
> //richard
> 

Ah yes, sorry for the confusion.  The original plan was to just take the initial
patches in the "fscrypt: symlink helpers and fscrypt.h cleanup" series, but we
decided to take the fs-specific patches through the fscrypt tree too, since the
only merge conflict was a "trivial" one in f2fs_symlink(), and it otherwise
would have taken a long time to get all those patches as well as the follow-on
fscrypt patches applied.

Eric
