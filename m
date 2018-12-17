Return-Path: <SRS0=GycC=O2=vger.kernel.org=linux-integrity-owner@kernel.org>
Date: Mon, 17 Dec 2018 11:15:50 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181217191549.GB141684@gmail.com>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214051722.GF20880@thunk.org>
 <20181217165231.GB18626@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217165231.GB18626@infradead.org>
Sender: linux-integrity-owner@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Cc: "Theodore Y. Ts'o" <tytso@mit.edu>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

Hi Christoph,

On Mon, Dec 17, 2018 at 08:52:31AM -0800, Christoph Hellwig wrote:
> [FYI, your mail never made it to my inbox, although I found the copy
> in linux-fsdevel now]
> 
> On Fri, Dec 14, 2018 at 12:17:22AM -0500, Theodore Y. Ts'o wrote:
> > I don't consider fs-verity to be part of core VFS, but rather a
> > library that happens to be used by ext4 and f2fs.  This is much like
> > fscrypt, which was originally an ext4-only thing, but the code was
> > always set up so it could be used by other file systems, and when f2fs
> > was interested in using it, we moved it to fs/crypto.  As such the
> > fscrypto code never got a review from Al, Andrew, or you, and when I
> > pushed it to Linus, he accepted the pull request.
> 
> And as a result we are stuck with a pretty bad interface, so this is
> a very good example for how to not do thing!  Just because a user
> interface is only implemented by one or two file systems doesn't mean
> it should skip the userspace ABI review, because we tend to generalize
> them unless they are deeply specific to fs internals.
> 

While I do have some improvements planned for the fscrypt interface,
specifically how encryption keys are managed [1], the issues are subtle enough
that I don't think there's any chance they could have been gotten "right" the
first time around, even if lots more people had reviewed it.  It took me over a
year working with fscrypt to put together my proposal for how to improve things,
and it was only really possible because I was able to consider all the people
actually using fscrypt and what problems they are having, if any.

Even so, the current fscrypt interface is actually good enough that there still
hasn't been much real interest in getting my proposed improvements merged yet.
(Not surprisingly, they've also been completely ignored by all the "VFS people"
you say should be reviewing this stuff...)

So for fscrypt I personally don't think that waiting would have changed much in
practice, besides ensuring that users wouldn't have any solution at all.

[1] https://lwn.net/Articles/737274/

- Eric
