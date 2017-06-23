Return-Path: <tytso@thunk.org>
Date: Fri, 23 Jun 2017 13:28:56 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 3/4] ubifs: don't bother checking for encryption key in
 ->mmap()
Message-ID: <20170623172856.aixyqcd4o4te6neb@thunk.org>
References: <20170523003945.14279-1-ebiggers3@gmail.com>
 <20170523003945.14279-4-ebiggers3@gmail.com>
 <CAFLxGvxaiWFKH5L_BwPXGuG9PxA+0BkJ1qMvaDgAeVwBw+nCoQ@mail.gmail.com>
 <20170623160907.ppwcqehvrehjtury@thunk.org>
 <20170623171807.GA84943@gmail.com>
 <82e7cbcc-5de8-4e10-8c5e-1537c9584a50@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <82e7cbcc-5de8-4e10-8c5e-1537c9584a50@nod.at>
To: Richard Weinberger <richard@nod.at>
Cc: Eric Biggers <ebiggers3@gmail.com>, linux-fscrypt@vger.kernel.org, Eric Biggers <ebiggers@google.com>, linux-f2fs-devel@lists.sourceforge.net, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, Jaegeuk Kim <jaegeuk@kernel.org>, linux-ext4@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Jun 23, 2017 at 07:20:51PM +0200, Richard Weinberger wrote:
> 
> The plan is that the fscrypt tree will just contain fscrypt "core" patches and
> global changes/cleanups go thought the individual filesystem trees, right?

Yes, it minimizes potential conflicts against other individual file
system trees if we keep patches that are file system specific in their
own tree.

There will be times when we can't do that --- for example, if we need
to make a change in the fscrypt directory that requires matching
changes in all of the users of fscrypt at the same time.  But when we
do that there is always the chance that there will be merge conflicts
that have to be manually reconciled by both Stephen Rothwell for
linux-next and Linus during the merge window.  But if we can avoid
needing to do that, it's generally easier for all concerned.

Cheers,

						- Ted
