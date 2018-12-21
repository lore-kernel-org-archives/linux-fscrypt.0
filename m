Return-Path: <SRS0=zyzT=O6=infradead.org=willy@kernel.org>
Date: Fri, 21 Dec 2018 08:34:38 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181221163438.GE10600@bombadil.infradead.org>
References: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu>
 <20181219213552.GO6311@dastard>
 <20181220220158.GC2360@mit.edu>
 <20181221070447.GA21687@infradead.org>
 <20181221154714.GA26547@mit.edu>
 <20181221155354.GC10600@bombadil.infradead.org>
 <20181221162813.GB26547@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221162813.GB26547@mit.edu>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Dec 21, 2018 at 11:28:13AM -0500, Theodore Y. Ts'o wrote:
> On Fri, Dec 21, 2018 at 07:53:54AM -0800, Matthew Wilcox wrote:
> > In contrast to "we'll just fix it up later" (which usually applies
> > to in-kernel interfaces), we have a policy of not breaking userspace,
> > so accepting this interface means setting it in stone.  We should get
> > it right.
> 
> I'm not convinced it's a "fix", but my point is that if later on you
> want to add extra complexity transforming
> 
>      ioctl(fd, FS_IOC_ENABLE_VERITY);
> 
> so it does the equivalent of
> 
>      ioctl(fd, FS_IOC_ENABLE_VERITY_NOW_WITH_EXTRA_USELESS_COMPLEXITY,
> 	   fd, sizeof_data, sizeof_verity_data);

I disagree with your EXTRA_USELESS_COMPLEXITY appendage.  The interface
you designed reflects the implementation you did in ext4, so I understand
why it seems simple from your point of view.  From the user point of view,
it looks completely weird.  You write a file, being a series of bytes,
then all of a sudden have to know that it's composed of blocks, seek
to the next block, write a header, then this Merkle data structure,
then write a footer which isn't allowed to cross a block boundary
for some unknowable reason.  It seems much more logical to have the
header+Merkle+footer as a separate data stream which the filesystem can
then layout according to its own rules.
