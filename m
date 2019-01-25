Return-Path: <SRS0=dQBj=QB=infradead.org=willy@kernel.org>
Date: Thu, 24 Jan 2019 16:32:17 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Proposal: A new fs-verity interface
Message-ID: <20190125003217.GB18522@bombadil.infradead.org>
References: <20190110051500.GA32361@mit.edu>
 <20190114234101.GQ27534@dastard>
 <20190123051017.GA8785@mit.edu>
 <20190124212544.GS6173@dastard>
 <CAHk-=wh7jq6U3+ou_FDujB-ipg9JcJAGSjEQ_niCwLG313x6UA@mail.gmail.com>
 <20190124232237.GH8785@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124232237.GH8785@mit.edu>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net
List-ID: <linux-fscrypt@vger.kernel.org>

On Thu, Jan 24, 2019 at 06:22:37PM -0500, Theodore Y. Ts'o wrote:
> The main issue is that for a 129 MB file, the Merkle data is going to
> be a Megabyte.

127MB ... I pointed out this error the last time the documentation
was posted.

> We could store the metadata somewhere else --- for example, we could
> store it in another inode.  But inodes have overhead, and that would
> mean using two inodes for every fs-verity protected files --- and we
> don't need all of the other metadata (mtime, ctime, etc.) for the
> Merkle tree.  So that's how we got to where we were.  I think the
> approach of storing it using the same extent tree where we map logical
> block numbers to physical block numbers make a lot of sense for ext4
> and f2fs.
> 
> It seems that some file system (which may never even implement
> fs-verity) their developers hate that particular approach.  So that's
> where the suggestion of using a separate file descriptor to convey the
> Merkle tree data to the file system came from.  It wasn't my first
> choice.

I'll reiterate an API I suggested on December 21st:

: verity_fd = ioctl(fd, FS_IOC_VERITY_FD);
: write(verity_fd, &merkle_tree);
: close(verity_fd);
: 
: At final close of that verity_fd, the filesystem behaves in the same way
: that it does on receipt of this FS_IOC_ENABLE_VERITY ioctl today.
