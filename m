Return-Path: <SRS0=8CPQ=O4=bombadil.srs.infradead.org=BATV+660da67c63f4a722ad6d+5596+infradead.org+hch@kernel.org>
Date: Tue, 18 Dec 2018 23:11:49 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181219071149.GB2628@infradead.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214044802.GA681@sol.localdomain>
 <20181217200039.GD8111@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217200039.GD8111@magnolia>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Eric Biggers <ebiggers@kernel.org>, Christoph Hellwig <hch@infradead.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>
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
>
> If the merkle_fd isn't on the same filesystem as the fd we could at
> least use generic_copy_file_range (i.e. page cache copying) to land the
> merkle tree wherever we want.

I think the fd would have to be on the same fs for this interface to
make sense. But it could be an O_TMPFILE one.  And given that ext4
already supports a variant of swapext this interface should also work
with the existing ext4 on disk format.
