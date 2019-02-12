Return-Path: <SRS0=UUxe=QT=linux.ibm.com=zohar@kernel.org>
Subject: Re: Proposal: Yet another possible fs-verity interface
From: Mimi Zohar <zohar@linux.ibm.com>
Date: Tue, 12 Feb 2019 09:44:39 -0500
In-Reply-To: <20190212051237.GQ23000@mit.edu>
References: <20190207031101.GA7387@mit.edu>
	 <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
	 <20190212051237.GQ23000@mit.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <1549982679.12743.248.camel@linux.ibm.com>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

> At that point, the merkle tree thing ends up fairly equivalent to
the
> > IMA "measurement" thing, with the exception that the filesystem *may*
> > optimize it to be long-term. Hmm?
> 
> Well, except that it's just a less efficient way of doing IMA
> "measurement" (if the file system doesn't support Merkle tree
> storage).
> 
> So adding that complexity is, in my view, not really worth it, since I
> very much doubt anyone would use a slower scheme.  I think the much
> better model is that fsverity is for file system where you can store
> the Merkle tree (and it's really not that hard for most file systems
> to store it); and if you are using a file system which doesn't, use
> IMA in good health.

Ted, one of the problems with IMA is that the file hash/signature
verification is at file open.  It isn't aware when files are brought
in from cache.  Does fs-verity re-verify blocks as they're restored
from cache?  For some use cases, that might justify the up front cost
associated with building the Merkle tree.

Mimi
