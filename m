Return-Path: <SRS0=r2H5=PA=mit.edu=tytso@kernel.org>
Date: Sat, 22 Dec 2018 23:34:49 -0500
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v2 01/12] fs-verity: add a documentation file
Message-ID: <20181223043449.GF26547@mit.edu>
References: <20181219071420.GC2628@infradead.org>
 <20181219021953.GD31274@dastard>
 <20181219193005.GB6889@mit.edu>
 <20181219213552.GO6311@dastard>
 <20181220220158.GC2360@mit.edu>
 <20181221070447.GA21687@infradead.org>
 <20181221154714.GA26547@mit.edu>
 <CAHk-=wgdzWgoPSuHeVcqmGE1hB3Gan72r2_AhtC14e60=z45yg@mail.gmail.com>
 <20181222041712.GC26547@mit.edu>
 <CAHk-=wgPz4dfq4sPWxHwMR3g_R3xHhWjofXTu8rV0QU2DP0JhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wgPz4dfq4sPWxHwMR3g_R3xHhWjofXTu8rV0QU2DP0JhA@mail.gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Eric Biggers <ebiggers@kernel.org>, linux-fscrypt@vger.kernel.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-integrity@vger.kernel.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Victor Hsieh <victorhsieh@google.com>, Chandan Rajendra <chandan@linux.vnet.ibm.com>
List-ID: <linux-fscrypt@vger.kernel.org>

On Sat, Dec 22, 2018 at 02:47:22PM -0800, Linus Torvalds wrote:
> So I want to understand why this was made a filesystem operation in
> the first place. What's fs-specific about this implementation?

These are the things which are fs-specific.

*) We have to splice into the file system's readpage processing so we
   can verify the merkle tree hash before we mark the page up-to-date.
   This is most of the complexity involved in adding fs-verity
   support, and that's because both ext4 and f2fs have their own
   fs-specific readpage[s]() implementations, and both ext4 and f2fs
   also supports fscrypt, which *also* has to splice into readpage[s]().

*) The file system needs to define a file system feature bit in the
   superblock which means, "this file system uses fs-verity" --- so
   that old kernels will know that they need to refuse to mount the
   file system (f2fs) or mount the file system read-only (ext4).

*) The file system needs to define inode flag which is used to
   indicate "this is a fs-verity protected file".  This flag is not
   user-visible, so the file system just has to provide a single bit
   in the inode structure and a function which tests that bit.

*) Ext4 chose to have i_size on disk to be size of the data.  We did
   this so that the the fs-verity feature for ext4 could be a
   read-only compat feature.  (e.g., an old kernel can safely mount a
   file system with fs-verity protected files, but only for a
   read-only mount.)  This adds a bit more complexity for ext4 in that
   we need to look up in our extent tree to find the last block in the
   file (which is where the fs-verity superblock is located).

   For f2fs, it can just use the on-disk i_size to find the fs-verity
   superblock, and then from that, f2fs can find the original data
   i_size (which then gets presents to userspace when it calls
   stat(2).)

As far as the last point is concerned, ext4 could have done things the
f2fs way, which is simpler, and which would allowed us to make things
much more generic.  However, being able to support read-only mounts of
file systems with fs-verity protected files was important to me.

Everything else is generic and we tried to factor out as much common
code as possible into fs/verity.  But the model has always been that
at least *some* changes would be needed in the file system to call out
to the fs-verity code, primarily because we didn't want to make
changes to readpage()/readpages() VFS<->low-level fs interface.  That
would have required making changes in dozens of file systems, and
while that would have allowed us to factor out some duplicated code in
{ext4,f2fs}_readpage[s]() --- right now it's only those two file
systems out of 70 or so support fscrypt and fs-verity.  It's just not
worth it.

						- Ted
