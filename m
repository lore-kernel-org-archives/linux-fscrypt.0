Return-Path: <SRS0=q17V=XC=mit.edu=tytso@kernel.org>
Date: Sat, 7 Sep 2019 06:06:40 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH v3] e2fsck: check for consistent encryption policies
Message-ID: <20190907100640.GA6778@mit.edu>
References: <20190823162339.186643-1-ebiggers@kernel.org>
 <20190904155524.GA41757@gmail.com>
 <28D1848F-B84A-4D2A-880E-F0C8E8FD36C7@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28D1848F-B84A-4D2A-880E-F0C8E8FD36C7@dilger.ca>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Eric Biggers <ebiggers@kernel.org>, linux-ext4@vger.kernel.org, linux-fscrypt@vger.kernel.org
List-ID: <linux-fscrypt@vger.kernel.org>

On Fri, Sep 06, 2019 at 10:23:03PM -0600, Andreas Dilger wrote:
> If the number of files in the array get very large, then doubling the
> array size at the end may consume a *lot* of memory.  It would be
> somewhat better to cap new_capacity by the number of inodes in the
> filesystem, and better yet scale the array size by a fraction of the
> total number of inodes that have already been processed, but this array
> might still be several GB of RAM.
> 
> What about using run-length encoding for this?  It is unlikely that many
> different encryption policies are in a filesystem, and inodes tend to be
> allocated in groups by users, so it is likely that you will get large runs
> of inodes with the same policy_id, and this could save considerable space.

One approach that we could use is to allocate a separate bitmap for
each policy.  EXT2FS_BMAP_RBTREE effectively will use RLE.  The
downside is that if the inodes are not sparse, it will be quite
heavyweight; each extent costs 40 bytes.

So for file system with a very large number of policies (as opposed
less than two or three, which will be the case with the vast majority
of Android devices) this could be quite expensive.

Of course, we don't have to use an rbtree; the bitarray will be
created sequentially, so in theory we could create a new bitmap
backend which uses a sorted list, which is O(1) for ordered insert and
o(log n) for lookups.  That could be about 12 bytes per extent.  And
of course, we don't have to implement the sorted list back end right
away, switching it is just a matter of changing a parameter to
ext2fs_alloc_generic_bitmap().

      	     	       	    	     	      - Ted
