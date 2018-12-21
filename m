Return-Path: <SRS0=zyzT=O6=infradead.org=willy@kernel.org>
Date: Fri, 21 Dec 2018 07:53:54 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181221155354.GC10600@bombadil.infradead.org>
References: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu>
 <20181219213552.GO6311@dastard>
 <20181220220158.GC2360@mit.edu>
 <20181221070447.GA21687@infradead.org>
 <20181221154714.GA26547@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221154714.GA26547@mit.edu>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Dec 21, 2018 at 10:47:14AM -0500, Theodore Y. Ts'o wrote:
> Linus --- we're going round and round, and I don't think this is
> really a technical dispute at this point, but rather an aesthetics
> one.  Will you be willing to accept my pull request for a feature
> which is being shippped on millions of Android phones, has been out
> for review for months, and for which, if we *really* need to add
> uselessly complicated interface later, we can do that?  It's always
> been the case for internal Kernel interfaces not to add code "just in
> case" it's useful, but rather when a user turns up.  I argue we should
> be doing the same thing for user-space visible interfaces.

To look at it another way, this is an aesthetic dispute in which all those
who have offered opinions from outside Google -- myself, Dave Chinner &
Christoph all really dislike this interface.  I'd be happy to discuss
alternative interfaces, particularly ones which allow for the current
internal implementation, but I think this interface is really bad.

In contrast to "we'll just fix it up later" (which usually applies
to in-kernel interfaces), we have a policy of not breaking userspace,
so accepting this interface means setting it in stone.  We should get
it right.
