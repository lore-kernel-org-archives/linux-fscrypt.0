Return-Path: <ebiggers3@gmail.com>
Date: Fri, 23 Jun 2017 10:18:07 -0700
From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH 3/4] ubifs: don't bother checking for encryption key in
 ->mmap()
Message-ID: <20170623171807.GA84943@gmail.com>
References: <20170523003945.14279-1-ebiggers3@gmail.com>
 <20170523003945.14279-4-ebiggers3@gmail.com>
 <CAFLxGvxaiWFKH5L_BwPXGuG9PxA+0BkJ1qMvaDgAeVwBw+nCoQ@mail.gmail.com>
 <20170623160907.ppwcqehvrehjtury@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170623160907.ppwcqehvrehjtury@thunk.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Richard Weinberger <richard.weinberger@gmail.com>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

Ted + Richard,

On Fri, Jun 23, 2017 at 12:09:07PM -0400, Theodore Ts'o wrote:
> On Tue, May 23, 2017 at 04:14:20PM +0200, Richard Weinberger wrote:
> > On Tue, May 23, 2017 at 2:39 AM, Eric Biggers <ebiggers3@gmail.com> wrote:
> > > From: Eric Biggers <ebiggers@google.com>
> > >
> > > Since only an open file can be mmap'ed, and we only allow open()ing an
> > > encrypted file when its key is available, there is no need to check for
> > > the key again before permitting each mmap().
> > >
> > > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > 
> > Acked-by: Richard Weinberger <richard@nod.at>
> 
> There are some patches that were sent to linux-fscrypt (including this
> one) that are specific to ubifs that don't appear to be in linux-next
> as of this writing.
> 
> I can include them in the fscrypt tree (which I am updating somewhat
> belatedly; sorry, crazy travel schedule has made me be late attending
> to fscrypt), but it probably makes more sense for the change to go in
> via the ubifs tree.  The f2fs version of the "don't bother checking
> for encryption key" is already in linux-next, via the f2fs tree, for
> example.
> 
> So I'm planning on NOT taking the ubifs-specific patches that are in
> the linux-fscrypto patch queue; unless Richard, you want to
> specifically ask me to do so.
> 

The mmap and truncate patches were basically the same for each filesystem, but
yes it's fine for them to go in separately.  Richard, can you take for ubifs:

	ubifs: don't bother checking for encryption key in ->mmap()
	ubifs: require key for truncate(2) of encrypted file

and Ted can you take for ext4:

	ext4: don't bother checking for encryption key in ->mmap()
	ext4: require key for truncate(2) of encrypted file

- Eric
