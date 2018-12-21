Return-Path: <linux-f2fs-devel-bounces@lists.sourceforge.net>
Date: Fri, 21 Dec 2018 10:47:14 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Message-ID: <20181221154714.GA26547@mit.edu>
References: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard> <20181219193005.GB6889@mit.edu>
 <20181219213552.GO6311@dastard> <20181220220158.GC2360@mit.edu>
 <20181221070447.GA21687@infradead.org>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20181221070447.GA21687@infradead.org>
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
To: Christoph Hellwig <hch@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, linux-integrity@vger.kernel.org, linux-ext4@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Victor Hsieh <victorhsieh@google.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Dec 20, 2018 at 11:04:47PM -0800, Christoph Hellwig wrote:
> Ted, I think you know yourself this isn't true.  Whenever we added
> useful interface to one of the major file systems we had other pick
> it up, and that is a good thing because the last thing we need is
> fragmentation of interfaces.  And even if that wasn't the case I don't
> think we should take short cuts, because even if an interface was just
> for a file system or two it still needs to be properly desgined.

This is why I think the interface argument is totally bogus.

If you're OK with Darrick's suggested interface, where you pass in a
file descriptor, offset and length --- that's just a superset of the
current interface, except where the file descriptor is in the file
which is going to be protected using fs-verity.  So there's if you're
OK with that interface, we can add that interface later, and it's
really no big deal; it certainly doesn't add any extra complexity for
XFS --- assuming that XFS even gets around to adding support for
fs-verity.

Adding that extra complexity is not necessary for the current users of
the interface, and as I've said multiple times before, there's no
*value* in allowing the Merkle tree to be passed in via some arbitrary
file descriptor, which might even be on a separate fhile system, as
opposed in the file which is about to be protected using fs-verity.

Linus --- we're going round and round, and I don't think this is
really a technical dispute at this point, but rather an aesthetics
one.  Will you be willing to accept my pull request for a feature
which is being shippped on millions of Android phones, has been out
for review for months, and for which, if we *really* need to add
uselessly complicated interface later, we can do that?  It's always
been the case for internal Kernel interfaces not to add code "just in
case" it's useful, but rather when a user turns up.  I argue we should
be doing the same thing for user-space visible interfaces.

Regards,

						- Ted



_______________________________________________
Linux-f2fs-devel mailing list
Linux-f2fs-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-f2fs-devel
