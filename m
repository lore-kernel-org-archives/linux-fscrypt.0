Return-Path: <SRS0=Hoe/=O6=bombadil.srs.infradead.org=BATV+86e201e085fd36a9fd59+5598+infradead.org+hch@kernel.org>
Date: Thu, 20 Dec 2018 23:04:47 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181221070447.GA21687@infradead.org>
References: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu>
 <20181219213552.GO6311@dastard>
 <20181220220158.GC2360@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181220220158.GC2360@mit.edu>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Dec 20, 2018 at 05:01:58PM -0500, Theodore Y. Ts'o wrote:
> That's simply not true.  Number one, fsverity is not mandatory for all
> file systems to implement.  If XFS doesn't want to implement fscrypt
> or fsverity, it doesn't have to.  Number two, we're not *making* any
> changes to the kernel code; nothing in mm/filemap.c, et. al.  So
> saying that we are making changes that are impacted by /everyone/ just
> doesn't make any sense.

Ted, I think you know yourself this isn't true.  Whenever we added
useful interface to one of the major file systems we had other pick
it up, and that is a good thing because the last thing we need is
fragmentation of interfaces.  And even if that wasn't the case I don't
think we should take short cuts, because even if an interface was just
for a file system or two it still needs to be properly desgined.

There is no reason to rush interfacs in, because everytime we have done
that it has turned out to be a very bad idea in retrospective.
