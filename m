Return-Path: <SRS0=3+F3=O2=bombadil.srs.infradead.org=BATV+f285e7ccc7f72256db92+5594+infradead.org+hch@kernel.org>
Date: Mon, 17 Dec 2018 08:49:49 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181217164949.GA18626@infradead.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214044802.GA681@sol.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214044802.GA681@sol.localdomain>
To: Eric Biggers <ebiggers@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Dec 13, 2018 at 08:48:03PM -0800, Eric Biggers wrote:
> Sure, those specific people (modulo you just now) haven't responded to the
> fs-verity patches yet.  But again, the patches have been out for review for
> months.  Of course, we always prefer more reviews over fewer, and we strongly
> encourage anyone interested to review fs-verity!  (The Documentation/ file may
> be a good place to start.)  But ultimately we cannot force reviews, and as you
> know kernel reviews can be very hard to come by.  Yet, people still need
> fs-verity anyway; it isn't just some toy.  And we're committed to maintaining
> it, similar to fscrypt.  The ext4 and f2fs maintainers are also satisfied with
> the current approach to storing the verity metadata past EOF; in fact it was
> even originally Ted's idea, I think.

But you also can't force inclusion.  And Linus just recently complained
about merging common code patches through trees for a specific fs
without proper VFS ACKs.  And that was a for a case without userspace
ABI implications, so we really need a much better review here.

Including a VFS person ACK, CC to linux-abi and man pages for the
interface.

> > Given that you alread use an ioctl as the interface what is the problem
> > of passing this data through the ioctl?
> 
> Do you mean pass the verity metadata in a buffer?  That cannot work in general,
> because it may be too large to fit into memory.

Have a pointer in the ioctl and do get_user_pages on it.
