Return-Path: <SRS0=r2H5=PA=mit.edu=tytso@kernel.org>
Date: Sat, 22 Dec 2018 23:45:53 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181223044553.GG26547@mit.edu>
References: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu>
 <20181219213552.GO6311@dastard>
 <20181220220158.GC2360@mit.edu>
 <20181221070447.GA21687@infradead.org>
 <20181221154714.GA26547@mit.edu>
 <CAHk-=wgdzWgoPSuHeVcqmGE1hB3Gan72r2_AhtC14e60=z45yg@mail.gmail.com>
 <20181222041712.GC26547@mit.edu>
 <20181223041007.GL10600@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181223041007.GL10600@bombadil.infradead.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Dec 22, 2018 at 08:10:07PM -0800, Matthew Wilcox wrote:
> Pretty much every file format has the ability to put arbitrary blocks
> of information into a file somewhere the tools which don't know about
> it will skip it.  For example, ZIP "includes an extra field facility
> within file headers, which can be used to store extra data not defined
> by existing ZIP specifications, and which allow compliant archivers that
> do not recognize the fields to safely skip them. Header IDs 0–31 are
> reserved for use by PKWARE. The remaining IDs can be used by third-party
> vendors for proprietary usage. " (Wikipedia)
> 
> ELF, PNG, PDF and many other formats have the ability to put data
> _somewhere_.  It might not be at the tail of the file, but there's
> somewhere to do it.
> 
> (I appreciate this isn't what Linus is asking for, but I'm pointing out
> that this is by no means as intractable as you make it sound.)

That design would require the fs-verity code to know the type of eacho
file, and where to find the in-band Merkle tree for each file type
that we wanted to support.  And if you wanted to use fs-verity to
protect a sudoers text configuration file (for example), we'd have to
teach sudo how to ignore the userspace visible Merkle tree.

So I agree with you that it's *possible*.  But it's ***ugly***.  *Way*
uglier than putting the Merkle tree at the end of the file data and
then making it invisible to userspace.

Cheers,

						- Ted
