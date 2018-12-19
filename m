Return-Path: <SRS0=8CPQ=O4=bombadil.srs.infradead.org=BATV+660da67c63f4a722ad6d+5596+infradead.org+hch@kernel.org>
Date: Tue, 18 Dec 2018 23:14:20 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181219071420.GC2628@infradead.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214044802.GA681@sol.localdomain>
 <20181217200039.GD8111@magnolia>
 <20181219001603.GD25775@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219001603.GD25775@mit.edu>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Dec 18, 2018 at 07:16:03PM -0500, Theodore Y. Ts'o wrote:
> Sure, but what would be the benefit of doing different things on the
> back end?  I think this is a really more of a philophical objection
> than anything else.  With both fsverity and fscrypt, well over 95% of
> the implementation is shared between ext4 and f2fs.  And from a
> cryptographic design, that's something I consider a feature, not a
> bug.  Cryptographic code is subtle in very different ways compared to
> file system code.  So it's a good thing to having it done once and
> audited by crypto specialists, as opposed to having each file system
> doing it differently / independently.

Where the data is located on disk should not matter for the crypto
details.  If it does you have severe implementation issues.

> Right, the current interface makes it somewhat more awkward to do
> these other things --- but the question is *why* would you want to in
> the first place?  Why add the extra complexity?  I'm a big believer of
> the KISS principle, and if there was a reason why a file system would
> want to store the Merkle tree somewhere else, we could talk about it,
> but I see only downside, and no upside.

Filesystems already use blocks beyond EOF for preallocation, either
speculative by the file system itself, or explicitly by the user with
fallocate.  I bet you will run into bugs with your creative abuse
sooner or later.  Indepnd of that the interface simply is gross, which
is enough of a reason not to merge it.
