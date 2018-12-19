Return-Path: <SRS0=8CPQ=O4=bombadil.srs.infradead.org=BATV+660da67c63f4a722ad6d+5596+infradead.org+hch@kernel.org>
Date: Tue, 18 Dec 2018 23:19:14 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181219071914.GA18852@infradead.org>
References: <20181101225230.88058-1-ebiggers@kernel.org>
 <20181101225230.88058-2-ebiggers@kernel.org>
 <20181212091406.GA31723@infradead.org>
 <20181212202609.GA193967@gmail.com>
 <20181213202249.GA3797@infradead.org>
 <20181214044802.GA681@sol.localdomain>
 <20181217200039.GD8111@magnolia>
 <20181219071149.GB2628@infradead.org>
 <CAHk-=wiB8vGbje+NgNkMZupHsZ_cqg6YEBV+ZXSF4wnywFLRHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wiB8vGbje+NgNkMZupHsZ_cqg6YEBV+ZXSF4wnywFLRHQ@mail.gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, ebiggers@kernel.org, linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, linux-kernel@vger.kernel.org, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Tue, Dec 18, 2018 at 11:16:08PM -0800, Linus Torvalds wrote:
> On Tue, Dec 18, 2018, 23:11 Christoph Hellwig <hch@infradead.org wrote:
> 
> >
> > I think the fd would have to be on the same fs for this interface to
> > make sense. But it could be an O_TMPFILE one.  And given that ext4
> > already supports a variant of swapext this interface should also work
> > with the existing ext4 on disk format.
> >
> 
> Why is the merkle tree not just an xattr of the file?

Because it is too large for our awkward xattrs interface..
