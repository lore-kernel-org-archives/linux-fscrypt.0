Return-Path: <SRS0=8CPQ=O4=bombadil.srs.infradead.org=BATV+660da67c63f4a722ad6d+5596+infradead.org+hch@kernel.org>
Date: Tue, 18 Dec 2018 23:09:15 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181219070915.GA2628@infradead.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214044802.GA681@sol.localdomain>
 <20181217164949.GA18626@infradead.org>
 <20181217183205.GA141684@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217183205.GA141684@gmail.com>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Dec 17, 2018 at 10:32:06AM -0800, Eric Biggers wrote:
> I don't see how that helps.  The Merkle tree can still be too large to fit in
> memory.  In the worst case, it might not even fit in the address space.  And I
> don't see how get_user_pages() helps either over just copy_from_user(); what are
> you proposing to do with the pages after getting them, exactly?

Write them out to a file system specific area on the media.  Note
that get_user_pages is indeed not going to work if you run out of
address space, but that seems like an odd use case.  Out of of memory
is not an issue as we generally iterate over a small number of pages
for each individual get_user_pages call.
