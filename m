Return-Path: <SRS0=uxkk=OW=bombadil.srs.infradead.org=BATV+4e3cd478b9c4c419405f+5590+infradead.org+hch@kernel.org>
Date: Thu, 13 Dec 2018 12:22:49 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181213202249.GA3797@infradead.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212202609.GA193967@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Wed, Dec 12, 2018 at 12:26:10PM -0800, Eric Biggers wrote:
> > As this apparently got merged despite no proper reviews from VFS
> > level persons:
> 
> fs-verity has been out for review since August, and Cc'ed to all relevant
> mailing lists including linux-fsdevel, linux-ext4, linux-f2fs-devel,
> linux-fscrypt, linux-integrity, and linux-kernel.  There are tests,
> documentation (since v2), and a userspace tool.  It's also been presented at
> multiple conferences, and has been covered by LWN multiple times.  If more
> people want to review it, then they should do so; there's nothing stopping them.

But you did not got a review from someone like Al, Linus, Andrew or me,
did you?

> Can you elaborate on the actual problems you think the current solution has, and
> exactly what solution you'd prefer instead?  Keep in mind that (1) for large
> files the Merkle tree can be gigabytes long, (2) Linux doesn't have an API for
> file streams, and (3) when fs-verity is combined with fscrypt, it's important
> that the hashes be encrypted, so as to not leak information about the plaintext.

Given that you alread use an ioctl as the interface what is the problem
of passing this data through the ioctl?
