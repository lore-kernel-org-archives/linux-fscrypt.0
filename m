Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Tue, 18 Dec 2018 19:16:03 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Message-ID: <20181219001603.GD25775@mit.edu>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214044802.GA681@sol.localdomain>
 <20181217200039.GD8111@magnolia>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20181217200039.GD8111@magnolia>
Subject: Re: [f2fs-dev] [PATCH v2 01/12] fs-verity: add a documentation file
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-integrity@vger.kernel.org, linux-ext4@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Dec 17, 2018 at 12:00:39PM -0800, Darrick J. Wong wrote:
> FWIW, if I were (hypothetically) working on an xfs implementation, I
> likely would have settled on passing a reference to a merkle tree
> through a (fd, length) pair, because that allows us plenty of options
> on the back end:
> 
> b) we could remap the tree into a new inode fork for merkle trees, or
> a) remap it as posteof blocks like ext4/f2fs does, or
> c) remap the blocks into the attribute fork as an (unusually large)
> extended attribute value.

Sure, but what would be the benefit of doing different things on the
back end?  I think this is a really more of a philophical objection
than anything else.  With both fsverity and fscrypt, well over 95% of
the implementation is shared between ext4 and f2fs.  And from a
cryptographic design, that's something I consider a feature, not a
bug.  Cryptographic code is subtle in very different ways compared to
file system code.  So it's a good thing to having it done once and
audited by crypto specialists, as opposed to having each file system
doing it differently / independently.

> If the merkle_fd isn't on the same filesystem as the fd we could at
> least use generic_copy_file_range (i.e. page cache copying) to land the
> merkle tree wherever we want.
> 
> Granted, it's not like we can't do any of those three things given the
> current interface.  I gather most of the grumbling has to do with
> feeling like we're associating the on-disk format to the ioctl interface
> too closely?

Right, the current interface makes it somewhat more awkward to do
these other things --- but the question is *why* would you want to in
the first place?  Why add the extra complexity?  I'm a big believer of
the KISS principle, and if there was a reason why a file system would
want to store the Merkle tree somewhere else, we could talk about it,
but I see only downside, and no upside.

      	       		     	- Ted


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
