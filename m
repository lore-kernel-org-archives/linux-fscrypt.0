Return-Path: <richard@nod.at>
From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH v2 0/5] ubifs: switch to new fscrypt helper functions
Date: Wed, 17 Jan 2018 22:36:12 +0100
Message-ID: <6120539.HEfP5UEqVm@blindfold>
In-Reply-To: <20180117212354.xrsog7pekzoomq7p@gmail.com>
References: <20171129204317.91205-1-ebiggers3@gmail.com> <CAFLxGvzGeMkm_1HhcFDe4twTGsVHaXvjoM6GezxtCNW+NZw84Q@mail.gmail.com> <20180117212354.xrsog7pekzoomq7p@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
To: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org
Cc: Eric Biggers <ebiggers@google.com>, linux-mtd@lists.infradead.org, Adrian Hunter <adrian.hunter@intel.com>, Artem Bityutskiy <dedekind1@gmail.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

Am Mittwoch, 17. Januar 2018, 22:23:54 CET schrieb Eric Biggers:
> On Wed, Jan 17, 2018 at 10:12:27PM +0100, Richard Weinberger wrote:
> > On Fri, Jan 5, 2018 at 11:11 PM, Richard Weinberger <richard@nod.at> 
wrote:
> > > Eric,
> > > 
> > > Am Freitag, 5. Januar 2018, 19:37:44 CET schrieb Eric Biggers:
> > >> On Wed, Nov 29, 2017 at 12:43:12PM -0800, Eric Biggers wrote:
> > >> > From: Eric Biggers <ebiggers@google.com>
> > >> > 
> > >> > This series switches ubifs to use the fscrypt helper functions for
> > >> > open/link/rename/lookup/setattr introduced in v4.15.
> > >> > 
> > >> > These patches were originally sent in "[PATCH 00/25] fscrypt: add
> > >> > some
> > >> > higher-level helper functions".  I've rebased them onto v4.15-rc1.
> > >> > 
> > >> > Eric Biggers (5):
> > >> >   ubifs: switch to fscrypt_file_open()
> > >> >   ubifs: switch to fscrypt_prepare_link()
> > >> >   ubifs: switch to fscrypt_prepare_rename()
> > >> >   ubifs: switch to fscrypt_prepare_lookup()
> > >> >   ubifs: switch to fscrypt_prepare_setattr()
> > >> >  
> > >> >  fs/ubifs/dir.c  | 43 +++++++++++++------------------------------
> > >> >  fs/ubifs/file.c | 41 ++++-------------------------------------
> > >> >  2 files changed, 17 insertions(+), 67 deletions(-)
> > >> 
> > >> Richard, can you take these for UBIFS for v4.16?
> > > 
> > > Yes. Thanks a lot for cleaning this up.
> > 
> > FYI, this series has merge conflicts with other fscrypt related
> > changes that went via Ted into fs/ubifs.
> 
> How so?  These apply cleanly to both Linus' tree and to fscrypt/master
> currently.

Just checked, the problem is this commit:

commit 9a2cebc6e2368072490a574eafe0f0747d330bbd
Author: Eric Biggers <ebiggers@google.com>
Date:   Fri Jan 5 11:30:03 2018 -0800

    ubifs: free the encrypted symlink target

It exists also in my tree. I'll drop it and force push.
Sorry for messing up, next time I try hard to be more responsive.

Thanks,
//richard
