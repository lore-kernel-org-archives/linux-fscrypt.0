Return-Path: <ebiggers3@gmail.com>
Date: Wed, 17 Jan 2018 13:23:54 -0800
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH v2 0/5] ubifs: switch to new fscrypt helper functions
Message-ID: <20180117212354.xrsog7pekzoomq7p@gmail.com>
References: <20171129204317.91205-1-ebiggers3@gmail.com>
 <20180105183744.GA44929@gmail.com>
 <2774377.VZm18AqBqi@blindfold>
 <CAFLxGvzGeMkm_1HhcFDe4twTGsVHaXvjoM6GezxtCNW+NZw84Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFLxGvzGeMkm_1HhcFDe4twTGsVHaXvjoM6GezxtCNW+NZw84Q@mail.gmail.com>
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Richard Weinberger <richard@nod.at>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>, linux-mtd@lists.infradead.org, Adrian Hunter <adrian.hunter@intel.com>, Artem Bityutskiy <dedekind1@gmail.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Jan 17, 2018 at 10:12:27PM +0100, Richard Weinberger wrote:
> On Fri, Jan 5, 2018 at 11:11 PM, Richard Weinberger <richard@nod.at> wrote:
> > Eric,
> >
> > Am Freitag, 5. Januar 2018, 19:37:44 CET schrieb Eric Biggers:
> >> On Wed, Nov 29, 2017 at 12:43:12PM -0800, Eric Biggers wrote:
> >> > From: Eric Biggers <ebiggers@google.com>
> >> >
> >> > This series switches ubifs to use the fscrypt helper functions for
> >> > open/link/rename/lookup/setattr introduced in v4.15.
> >> >
> >> > These patches were originally sent in "[PATCH 00/25] fscrypt: add some
> >> > higher-level helper functions".  I've rebased them onto v4.15-rc1.
> >> >
> >> > Eric Biggers (5):
> >> >   ubifs: switch to fscrypt_file_open()
> >> >   ubifs: switch to fscrypt_prepare_link()
> >> >   ubifs: switch to fscrypt_prepare_rename()
> >> >   ubifs: switch to fscrypt_prepare_lookup()
> >> >   ubifs: switch to fscrypt_prepare_setattr()
> >> >
> >> >  fs/ubifs/dir.c  | 43 +++++++++++++------------------------------
> >> >  fs/ubifs/file.c | 41 ++++-------------------------------------
> >> >  2 files changed, 17 insertions(+), 67 deletions(-)
> >>
> >> Richard, can you take these for UBIFS for v4.16?
> >
> > Yes. Thanks a lot for cleaning this up.
> 
> FYI, this series has merge conflicts with other fscrypt related
> changes that went via Ted into fs/ubifs.
> 

How so?  These apply cleanly to both Linus' tree and to fscrypt/master
currently.
