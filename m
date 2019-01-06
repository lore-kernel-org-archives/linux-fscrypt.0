Return-Path: <linux-fscrypt-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:35162 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726014AbfAFRwM (ORCPT <rfc822;linux-fscrypt@vger.kernel.org>);
        Sun, 6 Jan 2019 12:52:12 -0500
Date: Sun, 6 Jan 2019 09:52:10 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [GIT PULL] fscrypt update for 4.21
Message-ID: <20190106175209.GB699@sol.localdomain>
References: <20190106134912.GA27028@mit.edu>
 <20190106172005.GA699@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190106172005.GA699@sol.localdomain>
Sender: linux-fscrypt-owner@vger.kernel.org
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Sun, Jan 06, 2019 at 09:20:07AM -0800, Eric Biggers wrote:
> On Sun, Jan 06, 2019 at 08:49:12AM -0500, Theodore Y. Ts'o wrote:
> > The following changes since commit 7beb01f74415c56f5992922b5b902b45d365e694:
> > 
> >   f2fs: clean up f2fs_sb_has_##feature_name (2018-11-26 15:53:55 -0800)
> > 
> > are available in the Git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/tytso/fscrypt.git tags/fscrypt_for_linus
> > 
> > for you to fetch changes up to 8094c3ceb21ad93896fd4d238e8ba41911932eaf:
> > 
> >   fscrypt: add Adiantum support (2019-01-06 08:36:21 -0500)
> > 
> > ----------------------------------------------------------------
> > Add Adiantum support for fscrypt
> > 
> > ----------------------------------------------------------------
> > Eric Biggers (1):
> >       fscrypt: add Adiantum support
> > 
> >  Documentation/filesystems/fscrypt.rst | 179 ++++++++++++---------
> >  fs/crypto/crypto.c                    |  28 ++--
> >  fs/crypto/fname.c                     |  22 +--
> >  fs/crypto/fscrypt_private.h           |  67 +++++++-
> >  fs/crypto/keyinfo.c                   | 351 ++++++++++++++++++++++++++++++++----------
> >  fs/crypto/policy.c                    |   5 +-
> >  include/uapi/linux/fs.h               |   4 +-
> >  7 files changed, 468 insertions(+), 188 deletions(-)
> 
> Hi Ted, that tag is still on an old commit.  Probably you forgot to push.
> 

Fixed now, so either Ted pushed or I screwed something up.

> Also, FYI Linus - the reason this is so late in the merge window is that this
> patch was in the fscrypt tree which also had the fsverity stuff, which had
> concerns raised.  But this patch is independent and has been in linux-next since
> Dec 4 (albeit under a different commit ID since it was applied after the
> fsverity stuff), and also tested on some Android devices.
> 

Also I forgot: last month I switched my personal desktop (which I'm sending this
email from) over to use an Adiantum encrypted home directory :-)

- Eric
