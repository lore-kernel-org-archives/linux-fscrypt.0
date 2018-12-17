Return-Path: <SRS0=3+F3=O2=bombadil.srs.infradead.org=BATV+f285e7ccc7f72256db92+5594+infradead.org+hch@kernel.org>
Date: Mon, 17 Dec 2018 08:52:31 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181217165231.GB18626@infradead.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214051722.GF20880@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214051722.GF20880@thunk.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

[FYI, your mail never made it to my inbox, although I found the copy
in linux-fsdevel now]

On Fri, Dec 14, 2018 at 12:17:22AM -0500, Theodore Y. Ts'o wrote:
> I don't consider fs-verity to be part of core VFS, but rather a
> library that happens to be used by ext4 and f2fs.  This is much like
> fscrypt, which was originally an ext4-only thing, but the code was
> always set up so it could be used by other file systems, and when f2fs
> was interested in using it, we moved it to fs/crypto.  As such the
> fscrypto code never got a review from Al, Andrew, or you, and when I
> pushed it to Linus, he accepted the pull request.

And as a result we are stuck with a pretty bad interface, so this is
a very good example for how to not do thing!  Just because a user
interface is only implemented by one or two file systems doesn't mean
it should skip the userspace ABI review, because we tend to generalize
them unless they are deeply specific to fs internals.

> P.S.  And if you've purchased a Pixel 3 device, it's already using the
> fsverity code, so it's quite well tested (and yes, we have xfstests).

And all kinds of other code that would never pass review, so that isn't
really a good argument unfortunately :(  Note that I would want to buy
a piece of hardware coming with google spyware preinstalled.
