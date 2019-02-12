Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Tue, 12 Feb 2019 12:11:09 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Message-ID: <20190212171109.GS23000@mit.edu>
References: <20190207031101.GA7387@mit.edu>
 <CAHk-=wh2j+Yy28H_QxEdsP=k9xcHxjCG1PqKAF2Uv=ckK8oPug@mail.gmail.com>
 <20190212051237.GQ23000@mit.edu>
 <1549982679.12743.248.camel@linux.ibm.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <1549982679.12743.248.camel@linux.ibm.com>
Subject: Re: [f2fs-dev] Proposal: Yet another possible fs-verity interface
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-f2fs-devel>
List-Post: <mailto:linux-f2fs-devel@lists.sourceforge.net>
List-Help: <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel>,
 <mailto:linux-f2fs-devel-request@lists.sourceforge.net?subject=subscribe>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Errors-To: linux-f2fs-devel-bounces@lists.sourceforge.net
To: Mimi Zohar <zohar@linux.ibm.com>
Cc: Eric Biggers <ebiggers@kernel.org>, "Darrick J." Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>," linux-f2fs-devel@lists.sourceforge.net, Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Feb 12, 2019 at 09:44:39AM -0500, Mimi Zohar wrote:
> Ted, one of the problems with IMA is that the file hash/signature
> verification is at file open. =A0It isn't aware when files are brought
> in from cache. =A0Does fs-verity re-verify blocks as they're restored
> from cache? =A0For some use cases, that might justify the up front cost
> associated with building the Merkle tree.

fs-verity as designed and implemented today *only* verifies blocks as
they are read from the file system.  The Merkle tree is stored on
disk, and we don't verify all of the pages at open time.  That's the
whole *point* of fs-verity.  So when you say re-verify, that's simply
not correct.

Could we change it so that there is an optional mode where Merkle tree
is kept pinned in memory and recalculated the first time the file is
opened?  I suppose; the overhead is "only" 0.8% of the file size.  But
for big files, it adds up; and if you never use most of the file (say,
it's an unstripped executable with debugging information), you end up
paying twice --- once to calculate the Merkle tree (in CPU and Disk
time wasted), and a second time by pinning the full Merkle tree in
memory.  Also, it leaves open the question of how aggressively we drop
the Merkle tree once the file is closed.  Do we wait until the inode
gets purged from the inode cache?  That might pin the memory for way
too long.  Do we drop the Merkle tree the moment the inode's open
count goes to zero?

If it's not too hard to add, and if we're generating the Merkle tree
in the kernel, it's something we could do, I suppose.  But it's not
something *we're* going to use, so I'm not terribly excited about
wasting effort on work that just bitrots if no one is actually going
to use it in that way.

If you are willing to commit that IMA will use it in that way, and
you're fairly sure IMA users are going to be willing to pay the memory
tax, we can look into adding it, if it's doesn't add too much effort
on our part.  I just want to be clear that this is a "yes, we would
definitely use such a thing", as opposed to, "it might be nice...."

Cheers,

					- Ted


_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
