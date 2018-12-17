Return-Path: <SRS0=GycC=O2=vger.kernel.org=linux-integrity-owner@kernel.org>
Date: Mon, 17 Dec 2018 10:32:06 -0800
From: Eric Biggers <ebiggers@kernel.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181217183205.GA141684@gmail.com>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214044802.GA681@sol.localdomain>
 <20181217164949.GA18626@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217164949.GA18626@infradead.org>
Sender: linux-integrity-owner@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-fscrypt@vger.kernel.org>

On Mon, Dec 17, 2018 at 08:49:49AM -0800, Christoph Hellwig wrote:
> 
> > > Given that you alread use an ioctl as the interface what is the problem
> > > of passing this data through the ioctl?
> > 
> > Do you mean pass the verity metadata in a buffer?  That cannot work in general,
> > because it may be too large to fit into memory.
> 
> Have a pointer in the ioctl and do get_user_pages on it.

I don't see how that helps.  The Merkle tree can still be too large to fit in
memory.  In the worst case, it might not even fit in the address space.  And I
don't see how get_user_pages() helps either over just copy_from_user(); what are
you proposing to do with the pages after getting them, exactly?

- Eric
